#!/usr/bin/env bash
# Git workflow around an ax4 conversion: converted/ + edits/ pair, then import to master.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
STAMP_PATH="edits/conversion/stamp"
CONVERT_CMD="$SCRIPT_DIR/convert.cmd"
PAIR_PATHS=(src src-steam "$STAMP_PATH")

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [options]

  start [--buildid ID] --reasons REASONS [--date YYYY-MM-DD] [--skip-convert]
        [--decompiled DIR] [--] [convert options]
                    Create converted/DATE-bID-reasons from src/ + src-steam/ + stamp
  rebase            Replay edits/latest onto the converted/ branch created by start
                    (air: → cpp: → bug: → font: → feat:)
  replay [sha...]   Cherry-pick commits onto that converted/ branch
                    (default: converted/latest..edits/latest)
  commit [-m MSG]   Append a src-only commit on edits/latest from the worktree
                    (Squash-with:/Squash-as: recorded; rebase/squash fold)
  squash            Fold Squash-with: trailers on the current edits/ pair
  continue          Resume rebase or cherry-pick after resolving conflicts
  abort             Abort rebase or cherry-pick
  import            Copy src/, src-steam/, and stamp from edits/latest onto master

Stay on a full-tree branch (master). Do not check out converted/ or edits/.

Squash-with: <sha> as its own line marks a commit to fold into the referenced one
on rebase/replay/squash. Squash-as: <message> is required with it (newest in
the group wins; everything after that line is the body, kept as written).
Squash-as: original keeps the message the rest of the group would have produced
(newest non-original Squash-as:, else the oldest commit).

Edits titles use air: cpp: bug: font: feat: (rebase sorts by that order).
Reasons: dr, jpexs, ax4 (any subset; stored as dr > jpexs > ax4).
BuildID defaults to Dungeon-Rampage-Decompiled/tools/official.buildid.
Convert flags after -- go to convert.cmd.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

cd "$ROOT"
command -v git >/dev/null 2>&1 || die "git is required"
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || die "not a git repository"

STATE="$(git rev-parse --git-path drh-refresh-suffix)"
WT_PATH_FILE="$(git rev-parse --git-path drh-refresh-worktree)"
PENDING_FILE="$(git rev-parse --git-path drh-refresh-pending)"

in_rebase() {
  local gitdir="${1:-}"
  if [[ -n "$gitdir" ]]; then
    [[ -d "$gitdir/rebase-merge" || -d "$gitdir/rebase-apply" ]]
  else
    [[ -d "$(git rev-parse --git-path rebase-merge)" || -d "$(git rev-parse --git-path rebase-apply)" ]]
  fi
}

in_cherry_pick() {
  local gitdir="${1:-}"
  if [[ -n "$gitdir" ]]; then
    [[ -f "$gitdir/CHERRY_PICK_HEAD" ]]
  else
    [[ -f "$(git rev-parse --git-path CHERRY_PICK_HEAD)" ]]
  fi
}

require_no_sequencer() {
  if in_rebase || in_cherry_pick; then
    die "rebase or cherry-pick in progress (use continue or abort)"
  fi
  if [[ -f "$WT_PATH_FILE" ]]; then
    local wt
    wt="$(cat "$WT_PATH_FILE")"
    if [[ -d "$wt" ]]; then
      local gd
      gd="$(git -C "$wt" rev-parse --git-dir 2>/dev/null || true)"
      if [[ -n "$gd" && ( -d "$gd/rebase-merge" || -d "$gd/rebase-apply" || -f "$gd/CHERRY_PICK_HEAD" ) ]]; then
        die "rebase or cherry-pick in progress in $wt (use continue or abort)"
      fi
    fi
  fi
}

git_has_ref() {
  git rev-parse --verify --quiet "$1" >/dev/null
}

save_suffix() {
  printf '%s\n' "$1" > "$STATE"
}

read_suffix() {
  [[ -f "$STATE" ]] || die "no in-progress conversion (run start first)"
  cat "$STATE"
}

pair_suffix_from_stamp() {
  local ref="${1:-edits/latest}"
  git_has_ref "$ref" || die "no $ref"
  git cat-file -e "$ref:$STAMP_PATH" 2>/dev/null || die "no $STAMP_PATH on $ref"
  git show "$ref:$STAMP_PATH" | sed -n 's/^branch=//p' | head -1
}

assert_full_worktree() {
  [[ -f "$ROOT/project.xml" ]] || die "need a full worktree (project.xml missing). Stay on master; converted/ and edits/ are src-only."
  local branch
  branch="$(git branch --show-current || true)"
  case "$branch" in
    converted/*|edits/*)
      die "current branch is $branch; stay on master (converted/ and edits/ are src-only orphans)"
      ;;
  esac
}

normalize_reasons() {
  local has_dr=0 has_jpexs=0 has_ax4=0 part
  local IFS=+
  # shellcheck disable=SC2086
  set -- $1
  for part in "$@"; do
    case "$part" in
      dr) has_dr=1 ;;
      jpexs) has_jpexs=1 ;;
      ax4) has_ax4=1 ;;
      "") ;;
      *) die "unknown reason '$part' (expected dr, jpexs, ax4)" ;;
    esac
  done
  local out=()
  [[ "$has_dr" -eq 1 ]] && out+=(dr)
  [[ "$has_jpexs" -eq 1 ]] && out+=(jpexs)
  [[ "$has_ax4" -eq 1 ]] && out+=(ax4)
  [[ "${#out[@]}" -gt 0 ]] || die "need at least one reason (dr, jpexs, ax4)"
  local IFS=+
  echo "${out[*]}"
}

sibling_head() {
  local dir="$ROOT/../$1"
  if [[ -d "$dir/.git" || -f "$dir/.git" ]]; then
    git -C "$dir" rev-parse HEAD 2>/dev/null || true
  fi
}

find_sibling() {
  local dir="$ROOT/../$1"
  if [[ -d "$dir" ]]; then
    (cd "$dir" && pwd)
    return 0
  fi
  return 1
}

find_decompiled_dir() {
  if [[ -n "${DECOMPILED_DIR:-}" ]]; then
    [[ -d "$DECOMPILED_DIR" ]] || die "Decompiled directory not found: $DECOMPILED_DIR"
    (cd "$DECOMPILED_DIR" && pwd)
    return 0
  fi
  find_sibling Dungeon-Rampage-Decompiled || die "Dungeon-Rampage-Decompiled not found. Pass --decompiled / DECOMPILED_DIR."
}

read_decompiled_buildid() {
  local dir stamp
  dir="$(find_decompiled_dir)"
  stamp="$dir/tools/official.buildid"
  [[ -f "$stamp" ]] || die "no $stamp (run the decompiled repo sync, or pass --buildid)"
  local buildid
  buildid="$(tr -d '[:space:]' < "$stamp")"
  [[ "$buildid" =~ ^[0-9]+$ ]] || die "invalid BuildID in $stamp"
  printf '%s\n' "$buildid"
}

write_stamp() {
  local suffix="$1" date="$2" buildid="$3" reasons="$4"
  mkdir -p "$(dirname "$ROOT/$STAMP_PATH")"
  cat > "$ROOT/$STAMP_PATH" <<EOF
branch=$suffix
date=$date
buildid=$buildid
reasons=$reasons
jpexs=$(sibling_head jpexs-decompiler)
ax4=$(sibling_head ax4)
EOF
}

point_latest() {
  local suffix="$1"
  git branch -f "converted/latest" "converted/$suffix"
  git branch -f "edits/latest" "edits/$suffix"
  rm -f "$STATE"
  echo "converted/latest and edits/latest -> $suffix"
}

# Orphan (or parented) commit whose tree is only src/, src-steam/, and the stamp.
commit_sparse() {
  local message="$1"
  local parent="${2:-}"
  local worktree="${3:-$ROOT}"
  local index tree commit
  index="$(mktemp)"
  rm -f "$index"
  (
    cd "$worktree"
    export GIT_INDEX_FILE="$index"
    git add -f -- "${PAIR_PATHS[@]}"
    tree="$(git write-tree)"
    if [[ -n "$parent" ]]; then
      commit="$(git commit-tree "$tree" -p "$parent" -m "$message")"
    else
      commit="$(git commit-tree "$tree" -m "$message")"
    fi
    printf '%s\n' "$commit"
  )
  rm -f "$index"
}

parse_squash_with_msg() {
  printf '%s\n' "$1" | grep -E '^Squash-with: [0-9a-fA-F]{7,40}$' | sed 's/^Squash-with: //' || true
}

parse_squash_with() {
  parse_squash_with_msg "$(git log -1 --format='%B' "$1")"
}

# Last Squash-as: in the message; every following line is the body, kept as written.
parse_squash_as_msg() {
  local line subject="" capturing=0
  local -a body_lines=()
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^Squash-as:\ (.+)$ ]]; then
      subject="${BASH_REMATCH[1]}"
      body_lines=()
      capturing=1
      continue
    fi
    [[ "$capturing" -eq 1 ]] || continue
    if [[ "$line" =~ ^Squash-with:\ [0-9a-fA-F]{7,40}$ ]]; then
      continue
    fi
    if [[ "$line" =~ ^Co-authored-by:\  ]]; then
      continue
    fi
    body_lines+=("$line")
  done < <(printf '%s\n' "$1")
  [[ -n "$subject" ]] || return 0
  printf '%s\n' "$subject"
  if [[ "${#body_lines[@]}" -gt 0 ]]; then
    while [[ "${#body_lines[@]}" -gt 0 && -z "${body_lines[0]}" ]]; do
      body_lines=("${body_lines[@]:1}")
    done
    while [[ "${#body_lines[@]}" -gt 0 && -z "${body_lines[-1]}" ]]; do
      unset 'body_lines[-1]'
    done
    if [[ "${#body_lines[@]}" -gt 0 ]]; then
      printf '\n'
      printf '%s\n' "${body_lines[@]}"
    fi
  fi
}

parse_squash_as() {
  parse_squash_as_msg "$(git log -1 --format='%B' "$1")"
}

assert_squash_trailers() {
  local line rest has_as=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^Squash-as: ]]; then
      has_as=1
      rest="${line#Squash-as:}"
      [[ "$rest" == ' '* ]] || die "Squash-as: requires a space after the colon"
      if [[ ! "$rest" =~ [^[:space:]] ]]; then
        die "empty Squash-as:"
      fi
    fi
  done < <(printf '%s\n' "$1")
  local has_with=0
  [[ -n "$(parse_squash_with_msg "$1")" ]] && has_with=1
  if [[ "$has_as" -eq 1 && "$has_with" -eq 0 ]]; then
    die "Squash-as: requires Squash-with:"
  fi
  if [[ "$has_with" -eq 1 && "$has_as" -eq 0 ]]; then
    die "Squash-with: requires Squash-as:"
  fi
}

assert_stack_squash_pairs() {
  local sha
  for sha in "$@"; do
    assert_squash_trailers "$(git log -1 --format='%B' "$sha")"
  done
}

assert_squash_targets_in_stack() {
  local needles=() sha shas=()
  assert_squash_trailers "$1"
  mapfile -t needles < <(parse_squash_with_msg "$1")
  [[ "${#needles[@]}" -gt 0 ]] || return 0
  git_has_ref refs/heads/converted/latest || die "no converted/latest"
  mapfile -t shas < <(git rev-list --reverse converted/latest..edits/latest)
  [[ "${#shas[@]}" -gt 0 ]] || die "Squash-with: edits/latest has no commits beyond converted/latest"
  for sha in "${needles[@]}"; do
    resolve_in_set "$sha" "${shas[@]}" >/dev/null
  done
}

resolve_in_set() {
  local needle="$1"
  shift
  local sha full matches=()
  full="$(git rev-parse --verify --quiet "${needle}^{commit}" || true)"
  [[ -n "$full" ]] || die "Squash-with: $needle is not a commit"
  for sha in "$@"; do
    if [[ "$(git rev-parse --verify "${sha}^{commit}")" == "$full" ]]; then
      matches+=("$sha")
    fi
  done
  [[ "${#matches[@]}" -eq 1 ]] || die "Squash-with: $needle must refer to exactly one commit in the replay set"
  printf '%s\n' "$full"
}

uf_find() {
  local x="$1"
  while [[ "${UF_PARENT[$x]}" != "$x" ]]; do
    UF_PARENT[$x]="${UF_PARENT[${UF_PARENT[$x]}]}"
    x="${UF_PARENT[$x]}"
  done
  printf '%s\n' "$x"
}

uf_union() {
  local a b
  a="$(uf_find "$1")"
  b="$(uf_find "$2")"
  UF_PARENT[$a]="$b"
}

collect_coauthors() {
  grep -E '^Co-authored-by: ' || true
}

# Oldest commit subject + body, without squash trailers or Co-authored-by.
format_commit_message() {
  local subject body line
  local -a body_lines=()
  subject="$(git log -1 --format='%s' "$1")"
  body="$(git log -1 --format='%b' "$1")"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    if [[ "$line" =~ ^Squash-with:\ [0-9a-fA-F]{7,40}$ ]]; then
      continue
    fi
    if [[ "$line" =~ ^Squash-as:\  ]]; then
      continue
    fi
    if [[ "$line" =~ ^Co-authored-by:\  ]]; then
      continue
    fi
    body_lines+=("$line")
  done < <(printf '%s\n' "$body")
  while [[ "${#body_lines[@]}" -gt 0 && -z "${body_lines[0]}" ]]; do
    body_lines=("${body_lines[@]:1}")
  done
  while [[ "${#body_lines[@]}" -gt 0 && -z "${body_lines[-1]}" ]]; do
    unset 'body_lines[-1]'
  done
  printf '%s\n' "$subject"
  if [[ "${#body_lines[@]}" -gt 0 ]]; then
    printf '\n'
    printf '%s\n' "${body_lines[@]}"
  fi
}

squash_as_is_original() {
  local first="${1%%$'\n'*}"
  [[ "$first" == "original" ]]
}

combine_messages() {
  local sha body authors="" line as_msg saw_original=0
  local -A seen_author=()
  local shas=("$@")
  [[ "${#shas[@]}" -ge 1 ]] || return 0
  for sha in "${shas[@]}"; do
    body="$(git log -1 --format='%b' "$sha")"
    while IFS= read -r line; do
      [[ -n "$line" ]] || continue
      if [[ -z "${seen_author[$line]+x}" ]]; then
        seen_author[$line]=1
        authors+="$line"$'\n'
      fi
    done < <(printf '%s\n' "$body" | collect_coauthors)
  done
  local idx
  for (( idx=${#shas[@]}-1; idx>=0; idx-- )); do
    as_msg="$(parse_squash_as "${shas[idx]}")"
    if [[ -n "$as_msg" ]]; then
      if squash_as_is_original "$as_msg"; then
        saw_original=1
        continue
      fi
      printf '%s\n' "$as_msg"
      if [[ -n "$authors" ]]; then
        printf '\n%s' "$authors"
      fi
      return 0
    fi
  done
  if [[ "$saw_original" -eq 1 ]]; then
    format_commit_message "${shas[0]}"
    if [[ -n "$authors" ]]; then
      printf '\n%s' "$authors"
    fi
    return 0
  fi
  die "Squash-with: requires Squash-as:"
}

PREFIX_ORDER=(air cpp bug font feat)

# Keep relative order inside each prefix. Unprefixed commits stay put and skip the sort.
sort_by_prefix() {
  local shas=("$@")
  local sha p subject prefixed=0
  local -A bucket=()
  local unknown=()
  for p in "${PREFIX_ORDER[@]}"; do
    bucket[$p]=""
  done
  for sha in "${shas[@]}"; do
    subject="$(git log -1 --format='%s' "$sha")"
    prefixed=0
    for p in "${PREFIX_ORDER[@]}"; do
      if [[ "$subject" == "$p:"* ]]; then
        bucket[$p]+="$sha"$'\n'
        prefixed=1
        break
      fi
    done
    if [[ "$prefixed" -eq 0 ]]; then
      unknown+=("$sha")
    fi
  done
  if [[ "${#unknown[@]}" -eq "${#shas[@]}" ]]; then
    printf '%s\n' "${shas[@]}"
    return 0
  fi
  for p in "${PREFIX_ORDER[@]}"; do
    if [[ -n "${bucket[$p]}" ]]; then
      printf '%s' "${bucket[$p]}"
    fi
  done
  if [[ "${#unknown[@]}" -gt 0 ]]; then
    printf '%s\n' "${unknown[@]}"
  fi
}

# Print groups oldest-first: each line is space-separated shas in original order.
fold_groups() {
  local shas=("$@")
  local sha target resolved root
  declare -gA UF_PARENT=()
  for sha in "${shas[@]}"; do
    UF_PARENT[$sha]="$sha"
  done
  for sha in "${shas[@]}"; do
    while IFS= read -r target; do
      [[ -n "$target" ]] || continue
      resolved="$(resolve_in_set "$target" "${shas[@]}")"
      # Map resolved full sha back to the list entry
      local member
      for member in "${shas[@]}"; do
        if [[ "$(git rev-parse --verify "${member}^{commit}")" == "$resolved" ]]; then
          uf_union "$sha" "$member"
          break
        fi
      done
    done < <(parse_squash_with "$sha")
  done
  declare -A emitted=()
  for sha in "${shas[@]}"; do
    root="$(uf_find "$sha")"
    [[ -z "${emitted[$root]+x}" ]] || continue
    emitted[$root]=1
    local group=() member
    for member in "${shas[@]}"; do
      if [[ "$(uf_find "$member")" == "$root" ]]; then
        group+=("$member")
      fi
    done
    printf '%s\n' "${group[*]}"
  done
}

worktree_gitdir() {
  git -C "$1" rev-parse --git-dir
}

remove_refresh_worktree() {
  [[ -f "$WT_PATH_FILE" ]] || return 0
  local wt
  wt="$(cat "$WT_PATH_FILE")"
  rm -f "$WT_PATH_FILE"
  if [[ -d "$wt" ]]; then
    git worktree remove --force "$wt" 2>/dev/null || rm -rf "$wt"
    git worktree prune 2>/dev/null || true
  fi
}

ensure_refresh_worktree() {
  local start_ref="$1"
  local wt
  if [[ -f "$WT_PATH_FILE" ]]; then
    wt="$(cat "$WT_PATH_FILE")"
    if [[ -d "$wt" ]]; then
      printf '%s\n' "$wt"
      return 0
    fi
    rm -f "$WT_PATH_FILE"
  fi
  wt="$(mktemp -u /tmp/drh-refresh-XXXXXX)"
  git worktree add --detach "$wt" "$start_ref" >/dev/null
  printf '%s\n' "$wt" > "$WT_PATH_FILE"
  printf '%s\n' "$wt"
}

restore_src_to_worktree() {
  local ref="$1"
  git checkout "$ref" -- "${PAIR_PATHS[@]}"
  git reset -q HEAD -- "${PAIR_PATHS[@]}"
}

# Worktree stays detached so `git branch -f edits/$suffix` is allowed.
publish_edits_head() {
  local suffix="$1"
  local wt="$2"
  git -C "$wt" checkout --quiet --detach HEAD
  git branch -f "edits/$suffix" "$(git -C "$wt" rev-parse HEAD)"
  point_latest "$suffix"
  remove_refresh_worktree
  restore_src_to_worktree "edits/latest"
}

apply_groups() {
  local wt="$1"
  shift
  local groups=("$@") i sha
  for ((i = 0; i < ${#groups[@]}; i++)); do
    # A conflict stops the script here: continue resumes with the groups after this one.
    printf '%s\n' "${groups[@]:i+1}" > "$PENDING_FILE"
    # shellcheck disable=SC2206
    local members=(${groups[i]})
    if [[ "${#members[@]}" -eq 1 ]]; then
      git -C "$wt" cherry-pick "${members[0]}"
      continue
    fi
    for sha in "${members[@]}"; do
      git -C "$wt" cherry-pick -n "$sha"
    done
    git -C "$wt" commit -m "$(combine_messages "${members[@]}")"
  done
  rm -f "$PENDING_FILE"
}

apply_pending_groups() {
  local wt="$1" pending=()
  [[ -f "$PENDING_FILE" ]] || return 0
  mapfile -t pending < <(grep -v '^$' "$PENDING_FILE" || true)
  rm -f "$PENDING_FILE"
  [[ "${#pending[@]}" -eq 0 ]] || apply_groups "$wt" "${pending[@]}"
}

cmd_start() {
  local buildid="" reasons="" date="" skip_convert=0
  local convert_args=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --buildid) buildid="$2"; shift 2 ;;
      --reasons) reasons="$2"; shift 2 ;;
      --date) date="$2"; shift 2 ;;
      --decompiled) export DECOMPILED_DIR="$2"; shift 2 ;;
      --skip-convert) skip_convert=1; shift ;;
      --) shift; convert_args+=("$@"); break ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
  done
  assert_full_worktree
  if [[ -z "$buildid" ]]; then
    buildid="$(read_decompiled_buildid)"
    echo "BuildID $buildid from decompiled tools/official.buildid"
  fi
  [[ "$buildid" =~ ^[0-9]+$ ]] || die "buildid must be numeric"
  [[ -n "$reasons" ]] || die "start requires --reasons"
  reasons="$(normalize_reasons "$reasons")"
  [[ -n "$date" ]] || date="$(date +%F)"
  [[ "$date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || die "date must be YYYY-MM-DD"

  require_no_sequencer

  local suffix="${date}-b${buildid}-${reasons}"
  local branch="converted/$suffix"
  git_has_ref "refs/heads/$branch" && die "branch already exists: $branch"

  save_suffix "$suffix"

  if [[ "$skip_convert" -eq 0 ]]; then
    "$CONVERT_CMD" "${convert_args[@]+"${convert_args[@]}"}"
  fi

  write_stamp "$suffix" "$date" "$buildid" "$reasons"
  local commit
  commit="$(commit_sparse "$(cat <<EOF
Convert ${date} b${buildid} (${reasons})

BuildID: ${buildid}
reasons: ${reasons}
jpexs: $(sibling_head jpexs-decompiler)
ax4:   $(sibling_head ax4)
EOF
)")"
  git branch "$branch" "$commit"

  echo "created $branch ($commit)"
  if git_has_ref refs/heads/edits/latest; then
    echo "next: $(basename "$0") rebase"
  else
    git branch "edits/$suffix" "$commit"
    point_latest "$suffix"
    echo "first pair: stay on this full worktree, $(basename "$0") commit to stack, then $(basename "$0") import"
  fi
}

cmd_rebase() {
  assert_full_worktree
  require_no_sequencer
  git_has_ref refs/heads/edits/latest || die "no edits/latest"
  git_has_ref refs/heads/converted/latest || die "no converted/latest"
  local suffix shas=()
  suffix="$(read_suffix)"
  git_has_ref "refs/heads/converted/$suffix" || die "no converted/$suffix (run start first)"
  mapfile -t shas < <(git rev-list --reverse converted/latest..edits/latest)
  [[ "${#shas[@]}" -gt 0 ]] || die "edits/latest has no commits beyond converted/latest"
  mapfile -t shas < <(sort_by_prefix "${shas[@]}")
  replay_onto "$suffix" "${shas[@]}"
}

cmd_replay() {
  assert_full_worktree
  require_no_sequencer
  local suffix shas=()
  suffix="$(read_suffix)"
  git_has_ref "refs/heads/converted/$suffix" || die "no converted/$suffix (run start first)"
  if [[ $# -eq 0 ]]; then
    git_has_ref refs/heads/edits/latest || die "no edits/latest and no commit list"
    git_has_ref refs/heads/converted/latest || die "no converted/latest"
    mapfile -t shas < <(git rev-list --reverse converted/latest..edits/latest)
    [[ "${#shas[@]}" -gt 0 ]] || die "edits/latest has no commits beyond converted/latest"
  else
    shas=("$@")
  fi
  replay_onto "$suffix" "${shas[@]}"
}

replay_onto() {
  local suffix="$1"
  shift
  local shas=("$@")
  local wt groups=()
  assert_stack_squash_pairs "${shas[@]}"
  save_suffix "$suffix"
  mapfile -t groups < <(fold_groups "${shas[@]}")
  wt="$(ensure_refresh_worktree "converted/$suffix")"
  git -C "$wt" checkout --quiet --detach "converted/$suffix"
  apply_groups "$wt" "${groups[@]}"
  publish_edits_head "$suffix" "$wt"
}

cmd_commit() {
  assert_full_worktree
  require_no_sequencer
  git_has_ref refs/heads/edits/latest || die "no edits/latest"
  local msg="" suffix parent commit
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -m|--message) msg="$2"; shift 2 ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown option: $1" ;;
    esac
  done
  if [[ -z "$msg" ]]; then
    local tmp
    tmp="$(mktemp)"
    "${EDITOR:-vi}" "$tmp"
    msg="$(cat "$tmp")"
    rm -f "$tmp"
  fi
  [[ -n "$(printf '%s' "$msg" | tr -d '[:space:]')" ]] || die "empty commit message"
  assert_squash_targets_in_stack "$msg"
  suffix="$(pair_suffix_from_stamp edits/latest)"
  parent="$(git rev-parse edits/latest)"
  commit="$(commit_sparse "$msg" "$parent")"
  git branch -f "edits/$suffix" "$commit"
  git branch -f edits/latest "$commit"
  echo "edits/$suffix $commit"
  if [[ -n "$(parse_squash_with "$commit")" ]]; then
    echo "Squash-with trailer recorded; folded by rebase or squash"
  fi
}

cmd_squash() {
  assert_full_worktree
  require_no_sequencer
  git_has_ref refs/heads/edits/latest || die "no edits/latest"
  git_has_ref refs/heads/converted/latest || die "no converted/latest"
  local suffix shas=()
  suffix="$(pair_suffix_from_stamp edits/latest)"
  mapfile -t shas < <(git rev-list --reverse converted/latest..edits/latest)
  [[ "${#shas[@]}" -gt 0 ]] || die "edits/latest has no commits beyond converted/latest"
  local groups=() has_fold=0 sha
  mapfile -t groups < <(fold_groups "${shas[@]}")
  for sha in "${shas[@]}"; do
    if [[ -n "$(parse_squash_with "$sha")" ]]; then
      has_fold=1
      break
    fi
  done
  [[ "$has_fold" -eq 1 ]] || die "no Squash-with: trailer in converted/latest..edits/latest"
  save_suffix "$suffix"
  replay_onto "$suffix" "${shas[@]}"
}

cmd_continue() {
  local suffix wt
  suffix="$(read_suffix)"
  [[ -f "$WT_PATH_FILE" ]] || die "no refresh worktree (use continue only after rebase/replay)"
  wt="$(cat "$WT_PATH_FILE")"
  [[ -d "$wt" ]] || die "refresh worktree missing: $wt"
  if git -C "$wt" rev-parse -q --verify CHERRY_PICK_HEAD >/dev/null; then
    git -C "$wt" cherry-pick --continue
    if git -C "$wt" rev-parse -q --verify CHERRY_PICK_HEAD >/dev/null; then
      echo "cherry-pick continues in $wt; resolve then $(basename "$0") continue"
      return
    fi
  elif [[ -d "$(git -C "$wt" rev-parse --git-path rebase-merge)" || -d "$(git -C "$wt" rev-parse --git-path rebase-apply)" ]]; then
    git -C "$wt" rebase --continue
  else
    die "no rebase or cherry-pick in progress in $wt"
  fi
  apply_pending_groups "$wt"
  publish_edits_head "$suffix" "$wt"
}

cmd_abort() {
  local wt=""
  if [[ -f "$WT_PATH_FILE" ]]; then
    wt="$(cat "$WT_PATH_FILE")"
  fi
  if [[ -n "$wt" && -d "$wt" ]]; then
    if git -C "$wt" rev-parse -q --verify CHERRY_PICK_HEAD >/dev/null; then
      git -C "$wt" cherry-pick --abort
    elif [[ -d "$(git -C "$wt" rev-parse --git-path rebase-merge)" || -d "$(git -C "$wt" rev-parse --git-path rebase-apply)" ]]; then
      git -C "$wt" rebase --abort
    fi
    remove_refresh_worktree
    rm -f "$PENDING_FILE"
    echo "aborted"
    return
  fi
  if in_rebase; then
    git rebase --abort
    echo "rebase aborted"
    return
  fi
  if in_cherry_pick; then
    git cherry-pick --abort
    echo "cherry-pick aborted"
    return
  fi
  die "no rebase or cherry-pick in progress"
}

cmd_import() {
  assert_full_worktree
  require_no_sequencer
  git_has_ref refs/heads/edits/latest || die "no edits/latest"
  local current source
  current="$(git branch --show-current)"
  [[ "$current" == master ]] || git checkout master
  source="$(git rev-parse --abbrev-ref edits/latest)"
  git checkout edits/latest -- "${PAIR_PATHS[@]}"
  git commit -m "Refresh src from ${source}"
}

[[ $# -gt 0 ]] || { usage >&2; exit 1; }
cmd="$1"
shift
case "$cmd" in
  start) cmd_start "$@" ;;
  rebase) cmd_rebase ;;
  replay) cmd_replay "$@" ;;
  commit) cmd_commit "$@" ;;
  squash) cmd_squash ;;
  continue) cmd_continue ;;
  abort) cmd_abort ;;
  import) cmd_import ;;
  -h|--help) usage ;;
  *) usage >&2; die "unknown command: $cmd" ;;
esac
