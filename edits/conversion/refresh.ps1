#Requires -Version 5.1
# Git workflow around an ax4 conversion: converted/ + edits/ pair, then import to master.
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$StampPath = "edits/conversion/stamp"
$ConvertCmd = Join-Path $PSScriptRoot "convert.cmd"
$PairPaths = @("src", "src-steam", $StampPath)

function Show-Usage {
    @"
Usage: refresh.cmd <command> [options]

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
"@
}

function Die([string]$Message) {
    [Console]::Error.WriteLine("error: $Message")
    exit 1
}

Set-Location -LiteralPath $Root
if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Die "git is required" }
git rev-parse --is-inside-work-tree 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) { Die "not a git repository" }

function Get-StatePath { (git rev-parse --git-path drh-refresh-suffix).Trim() }
function Get-WorktreePathFile { (git rev-parse --git-path drh-refresh-worktree).Trim() }
function Get-PendingPath { (git rev-parse --git-path drh-refresh-pending).Trim() }

function Invoke-Git {
    git @args
    if ($LASTEXITCODE -ne 0) { Die "git $($args -join ' ') failed ($LASTEXITCODE)" }
}

function Test-Ref([string]$Ref) {
    git rev-parse --verify --quiet $Ref 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Save-Suffix([string]$Suffix) {
    Set-Content -LiteralPath (Get-StatePath) -Value $Suffix -NoNewline
}

function Read-Suffix {
    $path = Get-StatePath
    if (-not (Test-Path -LiteralPath $path)) { Die "no in-progress conversion (run start first)" }
    (Get-Content -LiteralPath $path -Raw).Trim()
}

function Get-PairSuffixFromStamp([string]$Ref = "edits/latest") {
    if (-not (Test-Ref $Ref)) { Die "no $Ref" }
    git cat-file -e "${Ref}:$StampPath" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) { Die "no $StampPath on $Ref" }
    $line = git show "${Ref}:$StampPath" | Where-Object { $_ -like "branch=*" } | Select-Object -First 1
    if (-not $line) { Die "no branch= in $StampPath on $Ref" }
    $line.Substring("branch=".Length).Trim()
}

function Assert-FullWorktree {
    if (-not (Test-Path -LiteralPath (Join-Path $Root "project.xml"))) {
        Die "need a full worktree (project.xml missing). Stay on master; converted/ and edits/ are src-only."
    }
    $branch = (git branch --show-current).Trim()
    if ($branch -like "converted/*" -or $branch -like "edits/*") {
        Die "current branch is $branch; stay on master (converted/ and edits/ are src-only orphans)"
    }
}

function Test-WorktreeSequencer([string]$Wt) {
    if (-not (Test-Path -LiteralPath $Wt)) { return $false }
    $gd = git -C $Wt rev-parse --git-dir 2>$null
    if ($LASTEXITCODE -ne 0) { return $false }
    $gd = $gd.Trim()
    return (Test-Path -LiteralPath (Join-Path $gd "rebase-merge")) -or
        (Test-Path -LiteralPath (Join-Path $gd "rebase-apply")) -or
        (Test-Path -LiteralPath (Join-Path $gd "CHERRY_PICK_HEAD"))
}

function Assert-NoSequencer {
    $merge = git rev-parse --git-path rebase-merge
    $apply = git rev-parse --git-path rebase-apply
    $cherry = git rev-parse --git-path CHERRY_PICK_HEAD
    if ((Test-Path -LiteralPath $merge) -or (Test-Path -LiteralPath $apply) -or (Test-Path -LiteralPath $cherry)) {
        Die "rebase or cherry-pick in progress (use continue or abort)"
    }
    $file = Get-WorktreePathFile
    if (Test-Path -LiteralPath $file) {
        $wt = (Get-Content -LiteralPath $file -Raw).Trim()
        if (Test-WorktreeSequencer $wt) {
            Die "rebase or cherry-pick in progress in $wt (use continue or abort)"
        }
    }
}

function Normalize-Reasons([string]$Raw) {
    $hasDr = $false; $hasJpexs = $false; $hasAx4 = $false
    foreach ($part in $Raw.Split('+')) {
        switch ($part) {
            "dr" { $hasDr = $true }
            "jpexs" { $hasJpexs = $true }
            "ax4" { $hasAx4 = $true }
            "" { }
            default { Die "unknown reason '$part' (expected dr, jpexs, ax4)" }
        }
    }
    $out = @()
    if ($hasDr) { $out += "dr" }
    if ($hasJpexs) { $out += "jpexs" }
    if ($hasAx4) { $out += "ax4" }
    if ($out.Count -eq 0) { Die "need at least one reason (dr, jpexs, ax4)" }
    $out -join '+'
}

function Find-Sibling([string]$Name) {
    $candidate = Join-Path (Split-Path -Parent $Root) $Name
    if (Test-Path -LiteralPath $candidate -PathType Container) {
        return (Resolve-Path -LiteralPath $candidate).Path
    }
    return $null
}

function Find-DecompiledDir {
    if ($env:DECOMPILED_DIR) {
        if (-not (Test-Path -LiteralPath $env:DECOMPILED_DIR -PathType Container)) {
            Die "Decompiled directory not found: $($env:DECOMPILED_DIR)"
        }
        return (Resolve-Path -LiteralPath $env:DECOMPILED_DIR).Path
    }
    $found = Find-Sibling "Dungeon-Rampage-Decompiled"
    if (-not $found) { Die "Dungeon-Rampage-Decompiled not found. Pass --decompiled / DECOMPILED_DIR." }
    return $found
}

function Read-DecompiledBuildId {
    $dir = Find-DecompiledDir
    $stamp = Join-Path $dir "tools\official.buildid"
    if (-not (Test-Path -LiteralPath $stamp)) {
        Die "no $stamp (run the decompiled repo sync, or pass --buildid)"
    }
    $buildId = ([System.IO.File]::ReadAllText($stamp)).Trim()
    if ($buildId -notmatch '^[0-9]+$') { Die "invalid BuildID in $stamp" }
    return $buildId
}

function Get-SiblingHead([string]$Name) {
    $dir = Join-Path (Split-Path -Parent $Root) $Name
    if (Test-Path -LiteralPath (Join-Path $dir ".git")) {
        $sha = git -C $dir rev-parse HEAD 2>$null
        if ($LASTEXITCODE -eq 0) { return $sha.Trim() }
    }
    ""
}

function Write-Stamp([string]$Suffix, [string]$StampDate, [string]$Id, [string]$StampReasons) {
    $full = Join-Path $Root $StampPath
    $dir = Split-Path -Parent $full
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    $text = @"
branch=$Suffix
date=$StampDate
buildid=$Id
reasons=$StampReasons
jpexs=$(Get-SiblingHead 'jpexs-decompiler')
ax4=$(Get-SiblingHead 'ax4')
"@
    [System.IO.File]::WriteAllText($full, $text.TrimEnd() + "`n")
}

function Point-Latest([string]$Suffix) {
    Invoke-Git branch -f "converted/latest" "converted/$Suffix"
    Invoke-Git branch -f "edits/latest" "edits/$Suffix"
    $state = Get-StatePath
    if (Test-Path -LiteralPath $state) { Remove-Item -LiteralPath $state }
    Write-Host "converted/latest and edits/latest -> $Suffix"
}

function Commit-Sparse([string]$Message, [string]$Parent = "", [string]$Worktree = $Root) {
    $index = Join-Path ([System.IO.Path]::GetTempPath()) ("drh-idx-" + [guid]::NewGuid().ToString("N"))
    if (Test-Path -LiteralPath $index) { Remove-Item -LiteralPath $index -Force }
    $oldIndex = $env:GIT_INDEX_FILE
    try {
        Push-Location -LiteralPath $Worktree
        $env:GIT_INDEX_FILE = $index
        Invoke-Git add -f -- @PairPaths
        $tree = (git write-tree).Trim()
        if ($LASTEXITCODE -ne 0) { Die "git write-tree failed" }
        if ($Parent) {
            $commit = (git commit-tree $tree -p $Parent -m $Message).Trim()
        }
        else {
            $commit = (git commit-tree $tree -m $Message).Trim()
        }
        if ($LASTEXITCODE -ne 0) { Die "git commit-tree failed" }
        return $commit
    }
    finally {
        if ($oldIndex) { $env:GIT_INDEX_FILE = $oldIndex } else { Remove-Item Env:GIT_INDEX_FILE -ErrorAction SilentlyContinue }
        if (Test-Path -LiteralPath $index) { Remove-Item -LiteralPath $index -Force }
        Pop-Location
    }
}

function Get-SquashWithMsg([string]$Message) {
    $hits = @()
    foreach ($line in ($Message -split "`n")) {
        if ($line.TrimEnd() -match '^Squash-with: ([0-9a-fA-F]{7,40})$') {
            $hits += $Matches[1]
        }
    }
    $hits
}

function Get-SquashWith([string]$Sha) {
    Get-SquashWithMsg ((git log -1 --format='%B' $Sha) -join "`n")
}

function Get-SquashAsMsg([string]$Message) {
    $subject = $null
    $body = New-Object System.Collections.Generic.List[string]
    $inAs = $false
    foreach ($line in ($Message -split "`n")) {
        $t = $line.TrimEnd("`r")
        if ($t -match '^Squash-as: (.+)$') {
            $subject = $Matches[1]
            $body = New-Object System.Collections.Generic.List[string]
            $inAs = $true
            continue
        }
        if (-not $inAs) { continue }
        if ($t -match '^Squash-with: [0-9a-fA-F]{7,40}$') { continue }
        if ($t -match '^Co-authored-by: ') { continue }
        $body.Add($t)
    }
    if (-not $subject) { return $null }
    while ($body.Count -gt 0 -and $body[0] -eq "") { $body.RemoveAt(0) }
    while ($body.Count -gt 0 -and $body[$body.Count - 1] -eq "") { $body.RemoveAt($body.Count - 1) }
    $parts = New-Object System.Collections.Generic.List[string]
    $parts.Add($subject)
    if ($body.Count -gt 0) {
        $parts.Add("")
        foreach ($b in $body) { $parts.Add($b) }
    }
    ($parts -join "`n").TrimEnd()
}

function Get-SquashAs([string]$Sha) {
    Get-SquashAsMsg ((git log -1 --format='%B' $Sha) -join "`n")
}

function Assert-SquashTrailers([string]$Message) {
    $hasAs = $false
    foreach ($line in ($Message -split "`n")) {
        $t = $line.TrimEnd("`r")
        if ($t -match '^Squash-as:') {
            $hasAs = $true
            if ($t -notmatch '^Squash-as: ') { Die "Squash-as: requires a space after the colon" }
            $rest = $t.Substring("Squash-as:".Length)
            if ($rest -notmatch '\S') { Die "empty Squash-as:" }
        }
    }
    $hasWith = (@(Get-SquashWithMsg $Message).Count -gt 0)
    if ($hasAs -and -not $hasWith) { Die "Squash-as: requires Squash-with:" }
    if ($hasWith -and -not $hasAs) { Die "Squash-with: requires Squash-as:" }
}

function Assert-StackSquashPairs([string[]]$Shas) {
    foreach ($sha in $Shas) {
        Assert-SquashTrailers ((git log -1 --format='%B' $sha) -join "`n")
    }
}

function Assert-SquashTargetsInStack([string]$Message) {
    Assert-SquashTrailers $Message
    $needles = @(Get-SquashWithMsg $Message)
    if ($needles.Count -eq 0) { return }
    if (-not (Test-Ref "refs/heads/converted/latest")) { Die "no converted/latest" }
    $shas = @(git rev-list --reverse "converted/latest..edits/latest")
    if ($LASTEXITCODE -ne 0 -or $shas.Count -eq 0) {
        Die "Squash-with: edits/latest has no commits beyond converted/latest"
    }
    foreach ($needle in $needles) {
        [void](Resolve-InSet $needle $shas)
    }
}

function Resolve-InSet([string]$Needle, [string[]]$Shas) {
    $full = git rev-parse --verify --quiet "${Needle}^{commit}"
    if ($LASTEXITCODE -ne 0 -or -not $full) { Die "Squash-with: $Needle is not a commit" }
    $full = $full.Trim()
    $matches = @()
    foreach ($sha in $Shas) {
        $got = (git rev-parse --verify "${sha}^{commit}").Trim()
        if ($got -eq $full) { $matches += $sha }
    }
    if ($matches.Count -ne 1) { Die "Squash-with: $Needle must refer to exactly one commit in the replay set" }
    $full
}

function Format-CommitMessage([string]$Sha) {
    $subject = (git log -1 --format='%s' $Sha).TrimEnd("`r")
    $body = git log -1 --format='%b' $Sha
    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in ($body -split "`n")) {
        $t = $line.TrimEnd("`r")
        if ($t -match '^Squash-with: [0-9a-fA-F]{7,40}$') { continue }
        if ($t -match '^Squash-as: ') { continue }
        if ($t -match '^Co-authored-by: ') { continue }
        $lines.Add($t)
    }
    while ($lines.Count -gt 0 -and $lines[0] -eq "") { $lines.RemoveAt(0) }
    while ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -eq "") { $lines.RemoveAt($lines.Count - 1) }
    $parts = New-Object System.Collections.Generic.List[string]
    $parts.Add($subject)
    if ($lines.Count -gt 0) {
        $parts.Add("")
        foreach ($b in $lines) { $parts.Add($b) }
    }
    ($parts -join "`n").TrimEnd()
}

function Test-SquashAsOriginal([string]$AsMsg) {
    if (-not $AsMsg) { return $false }
    $first = ($AsMsg -split "`n")[0].TrimEnd("`r")
    return ($first -eq "original")
}

function Combine-Messages([string[]]$Shas) {
    if ($Shas.Count -eq 0) { return "" }
    $parts = New-Object System.Collections.Generic.List[string]
    $authors = New-Object System.Collections.Generic.List[string]
    $seen = @{}
    foreach ($sha in $Shas) {
        $body = git log -1 --format='%b' $sha
        foreach ($line in ($body -split "`n")) {
            $t = $line.TrimEnd("`r")
            if ($t -match '^Co-authored-by: ') {
                if (-not $seen.ContainsKey($t)) { $seen[$t] = $true; $authors.Add($t) }
            }
        }
    }
    $sawOriginal = $false
    for ($i = $Shas.Count - 1; $i -ge 0; $i--) {
        $asMsg = Get-SquashAs $Shas[$i]
        if ($asMsg) {
            if (Test-SquashAsOriginal $asMsg) {
                $sawOriginal = $true
                continue
            }
            $parts.Add($asMsg)
            if ($authors.Count -gt 0) {
                $parts.Add("")
                foreach ($a in $authors) { $parts.Add($a) }
            }
            return (($parts -join "`n").TrimEnd() + "`n")
        }
    }
    if ($sawOriginal) {
        $parts.Add((Format-CommitMessage $Shas[0]))
        if ($authors.Count -gt 0) {
            $parts.Add("")
            foreach ($a in $authors) { $parts.Add($a) }
        }
        return (($parts -join "`n").TrimEnd() + "`n")
    }
    Die "Squash-with: requires Squash-as:"
}

function Get-SortedByPrefix([string[]]$Shas) {
    $order = @("air", "cpp", "bug", "font", "feat")
    $buckets = @{}
    foreach ($p in $order) { $buckets[$p] = New-Object System.Collections.Generic.List[string] }
    $unknown = New-Object System.Collections.Generic.List[string]
    foreach ($sha in $Shas) {
        $subject = (git log -1 --format='%s' $sha).TrimEnd()
        $hit = $false
        foreach ($p in $order) {
            if ($subject.StartsWith("${p}:")) {
                $buckets[$p].Add($sha)
                $hit = $true
                break
            }
        }
        if (-not $hit) { $unknown.Add($sha) }
    }
    if ($unknown.Count -eq $Shas.Count) { return $Shas }
    $out = New-Object System.Collections.Generic.List[string]
    foreach ($p in $order) { foreach ($sha in $buckets[$p]) { $out.Add($sha) } }
    foreach ($sha in $unknown) { $out.Add($sha) }
    $out.ToArray()
}

function Get-FoldGroups([string[]]$Shas) {
    $parent = @{}
    foreach ($sha in $Shas) { $parent[$sha] = $sha }
    function Find-Root([string]$X) {
        while ($parent[$X] -ne $X) {
            $parent[$X] = $parent[$parent[$X]]
            $X = $parent[$X]
        }
        $X
    }
    foreach ($sha in $Shas) {
        foreach ($target in (Get-SquashWith $sha)) {
            $resolved = Resolve-InSet $target $Shas
            foreach ($member in $Shas) {
                if ((git rev-parse --verify "${member}^{commit}").Trim() -eq $resolved) {
                    $parent[(Find-Root $sha)] = Find-Root $member
                    break
                }
            }
        }
    }
    $emitted = @{}
    $groups = @()
    foreach ($sha in $Shas) {
        $root = Find-Root $sha
        if ($emitted.ContainsKey($root)) { continue }
        $emitted[$root] = $true
        $group = @()
        foreach ($member in $Shas) {
            if ((Find-Root $member) -eq $root) { $group += $member }
        }
        $groups += , $group
    }
    $groups
}

function Remove-RefreshWorktree {
    $file = Get-WorktreePathFile
    if (-not (Test-Path -LiteralPath $file)) { return }
    $wt = (Get-Content -LiteralPath $file -Raw).Trim()
    Remove-Item -LiteralPath $file -Force
    if (Test-Path -LiteralPath $wt) {
        git worktree remove --force $wt 2>$null | Out-Null
        git worktree prune 2>$null | Out-Null
        if (Test-Path -LiteralPath $wt) { Remove-Item -LiteralPath $wt -Recurse -Force }
    }
}

function Ensure-RefreshWorktree([string]$StartRef) {
    $file = Get-WorktreePathFile
    if (Test-Path -LiteralPath $file) {
        $wt = (Get-Content -LiteralPath $file -Raw).Trim()
        if (Test-Path -LiteralPath $wt) { return $wt }
        Remove-Item -LiteralPath $file -Force
    }
    $wt = Join-Path ([System.IO.Path]::GetTempPath()) ("drh-refresh-" + [guid]::NewGuid().ToString("N"))
    Invoke-Git worktree add --detach $wt $StartRef
    Set-Content -LiteralPath $file -Value $wt -NoNewline
    $wt
}

function Restore-SrcToWorktree([string]$Ref) {
    Invoke-Git checkout $Ref -- @PairPaths
    Invoke-Git reset -q HEAD -- @PairPaths
}

function Publish-EditsHead([string]$Suffix, [string]$Wt) {
    Invoke-Git -C $Wt checkout --quiet --detach HEAD
    $head = (git -C $Wt rev-parse HEAD).Trim()
    Invoke-Git branch -f "edits/$Suffix" $head
    Point-Latest $Suffix
    Remove-RefreshWorktree
    Restore-SrcToWorktree "edits/latest"
}

function Invoke-ApplyGroups([string]$Wt, [object[]]$Groups) {
    $pendingPath = Get-PendingPath
    for ($i = 0; $i -lt $Groups.Count; $i++) {
        # A conflict stops the script here: continue resumes with the groups after this one.
        $rest = @(for ($j = $i + 1; $j -lt $Groups.Count; $j++) { (@($Groups[$j]) -join ' ') })
        Set-Content -LiteralPath $pendingPath -Value $rest
        $members = @($Groups[$i])
        if ($members.Count -eq 1) {
            Invoke-Git -C $Wt cherry-pick $members[0]
            continue
        }
        foreach ($sha in $members) {
            Invoke-Git -C $Wt cherry-pick -n $sha
        }
        $msg = Combine-Messages $members
        Invoke-Git -C $Wt commit -m $msg
    }
    Remove-Item -LiteralPath $pendingPath -ErrorAction SilentlyContinue
}

function Invoke-ApplyPendingGroups([string]$Wt) {
    $pendingPath = Get-PendingPath
    if (-not (Test-Path -LiteralPath $pendingPath)) { return }
    $pending = @(Get-Content -LiteralPath $pendingPath | Where-Object { $_.Trim() } | ForEach-Object { , @($_.Trim() -split ' ') })
    Remove-Item -LiteralPath $pendingPath
    if ($pending.Count -gt 0) { Invoke-ApplyGroups $Wt $pending }
}

function Invoke-ReplayOnto([string]$Suffix, [string[]]$Shas) {
    Assert-StackSquashPairs $Shas
    Save-Suffix $Suffix
    $groups = @(Get-FoldGroups $Shas)
    $wt = Ensure-RefreshWorktree "converted/$Suffix"
    Invoke-Git -C $wt checkout --quiet --detach "converted/$Suffix"
    Invoke-ApplyGroups $wt $groups
    Publish-EditsHead $Suffix $wt
}

function Invoke-Start([string[]]$Argv) {
    $buildId = $null
    $reasons = $null
    $stampDate = $null
    $skipConvert = $false
    $convertArgs = @()
    $i = 0
    while ($i -lt $Argv.Count) {
        switch ($Argv[$i]) {
            "--buildid" { $buildId = $Argv[$i + 1]; $i += 2 }
            "--reasons" { $reasons = $Argv[$i + 1]; $i += 2 }
            "--date" { $stampDate = $Argv[$i + 1]; $i += 2 }
            "--decompiled" { $env:DECOMPILED_DIR = $Argv[$i + 1]; $i += 2 }
            "--skip-convert" { $skipConvert = $true; $i += 1 }
            "--" { $i += 1; if ($i -lt $Argv.Count) { $convertArgs = $Argv[$i..($Argv.Count - 1)] }; $i = $Argv.Count }
            default { Die "unknown option: $($Argv[$i])" }
        }
    }
    Assert-FullWorktree
    if (-not $buildId) {
        $buildId = Read-DecompiledBuildId
        Write-Host "BuildID $buildId from decompiled tools/official.buildid"
    }
    if ($buildId -notmatch '^[0-9]+$') { Die "buildid must be numeric" }
    if (-not $reasons) { Die "start requires --reasons" }
    $reasons = Normalize-Reasons $reasons
    if (-not $stampDate) { $stampDate = Get-Date -Format "yyyy-MM-dd" }
    if ($stampDate -notmatch '^\d{4}-\d{2}-\d{2}$') { Die "date must be YYYY-MM-DD" }

    Assert-NoSequencer

    $suffix = "$stampDate-b$buildId-$reasons"
    $branch = "converted/$suffix"
    if (Test-Ref "refs/heads/$branch") { Die "branch already exists: $branch" }
    Save-Suffix $suffix

    if (-not $skipConvert) {
        & $ConvertCmd @convertArgs
        if ($LASTEXITCODE -ne 0) { Die "convert failed ($LASTEXITCODE)" }
    }

    Write-Stamp $suffix $stampDate $buildId $reasons
    $jpexs = Get-SiblingHead "jpexs-decompiler"
    $ax4 = Get-SiblingHead "ax4"
    $msg = @"
Convert $stampDate b$buildId ($reasons)

BuildID: $buildId
reasons: $reasons
jpexs: $jpexs
ax4:   $ax4
"@
    $commit = Commit-Sparse $msg
    Invoke-Git branch $branch $commit
    Write-Host "created $branch ($commit)"
    if (Test-Ref "refs/heads/edits/latest") {
        Write-Host "next: refresh.cmd rebase"
    }
    else {
        Invoke-Git branch "edits/$suffix" $commit
        Point-Latest $suffix
        Write-Host "first pair: stay on this full worktree, refresh.cmd commit to stack, then refresh.cmd import"
    }
}

function Invoke-RebaseCmd {
    Assert-FullWorktree
    Assert-NoSequencer
    if (-not (Test-Ref "refs/heads/edits/latest")) { Die "no edits/latest" }
    if (-not (Test-Ref "refs/heads/converted/latest")) { Die "no converted/latest" }
    $suffix = Read-Suffix
    if (-not (Test-Ref "refs/heads/converted/$suffix")) { Die "no converted/$suffix (run start first)" }
    $shas = @(git rev-list --reverse "converted/latest..edits/latest")
    if ($LASTEXITCODE -ne 0 -or $shas.Count -eq 0) {
        Die "edits/latest has no commits beyond converted/latest"
    }
    $shas = @(Get-SortedByPrefix $shas)
    Invoke-ReplayOnto $suffix $shas
}

function Invoke-Replay([string[]]$Shas) {
    Assert-FullWorktree
    Assert-NoSequencer
    $suffix = Read-Suffix
    if (-not (Test-Ref "refs/heads/converted/$suffix")) { Die "no converted/$suffix (run start first)" }
    if ($Shas.Count -eq 0) {
        if (-not (Test-Ref "refs/heads/edits/latest")) { Die "no edits/latest and no commit list" }
        if (-not (Test-Ref "refs/heads/converted/latest")) { Die "no converted/latest" }
        $Shas = @(git rev-list --reverse "converted/latest..edits/latest")
        if ($LASTEXITCODE -ne 0 -or $Shas.Count -eq 0) {
            Die "edits/latest has no commits beyond converted/latest"
        }
    }
    Invoke-ReplayOnto $suffix $Shas
}

function Invoke-CommitCmd([string[]]$Argv) {
    Assert-FullWorktree
    Assert-NoSequencer
    if (-not (Test-Ref "refs/heads/edits/latest")) { Die "no edits/latest" }
    $msg = $null
    $i = 0
    while ($i -lt $Argv.Count) {
        switch ($Argv[$i]) {
            "-m" { $msg = $Argv[$i + 1]; $i += 2 }
            "--message" { $msg = $Argv[$i + 1]; $i += 2 }
            default { Die "unknown option: $($Argv[$i])" }
        }
    }
    if (-not $msg) { Die "commit requires -m MSG" }
    if (-not $msg.Trim()) { Die "empty commit message" }
    Assert-SquashTargetsInStack $msg
    $suffix = Get-PairSuffixFromStamp "edits/latest"
    $parent = (git rev-parse edits/latest).Trim()
    $commit = Commit-Sparse $msg $parent
    Invoke-Git branch -f "edits/$suffix" $commit
    Invoke-Git branch -f edits/latest $commit
    Write-Host "edits/$suffix $commit"
    if ((Get-SquashWith $commit).Count -gt 0) {
        Write-Host "Squash-with trailer recorded; folded by rebase or squash"
    }
}

function Invoke-Squash {
    Assert-FullWorktree
    Assert-NoSequencer
    if (-not (Test-Ref "refs/heads/edits/latest")) { Die "no edits/latest" }
    if (-not (Test-Ref "refs/heads/converted/latest")) { Die "no converted/latest" }
    $suffix = Get-PairSuffixFromStamp "edits/latest"
    $shas = @(git rev-list --reverse "converted/latest..edits/latest")
    if ($LASTEXITCODE -ne 0 -or $shas.Count -eq 0) {
        Die "edits/latest has no commits beyond converted/latest"
    }
    $hasFold = $false
    foreach ($sha in $shas) {
        if ((Get-SquashWith $sha).Count -gt 0) { $hasFold = $true; break }
    }
    if (-not $hasFold) { Die "no Squash-with: trailer in converted/latest..edits/latest" }
    Invoke-ReplayOnto $suffix $shas
}

function Invoke-Continue {
    $suffix = Read-Suffix
    $file = Get-WorktreePathFile
    if (-not (Test-Path -LiteralPath $file)) { Die "no refresh worktree (use continue only after rebase/replay)" }
    $wt = (Get-Content -LiteralPath $file -Raw).Trim()
    if (-not (Test-Path -LiteralPath $wt)) { Die "refresh worktree missing: $wt" }
    $gd = (git -C $wt rev-parse --git-dir).Trim()
    if (Test-Path -LiteralPath (Join-Path $gd "CHERRY_PICK_HEAD")) {
        Invoke-Git -C $wt cherry-pick --continue
        if (Test-Path -LiteralPath (Join-Path $gd "CHERRY_PICK_HEAD")) {
            Write-Host "cherry-pick continues in $wt; resolve then refresh.cmd continue"
            return
        }
    }
    elseif ((Test-Path -LiteralPath (Join-Path $gd "rebase-merge")) -or (Test-Path -LiteralPath (Join-Path $gd "rebase-apply"))) {
        Invoke-Git -C $wt rebase --continue
    }
    else {
        Die "no rebase or cherry-pick in progress in $wt"
    }
    Invoke-ApplyPendingGroups $wt
    Publish-EditsHead $suffix $wt
}

function Invoke-Abort {
    $file = Get-WorktreePathFile
    if (Test-Path -LiteralPath $file) {
        $wt = (Get-Content -LiteralPath $file -Raw).Trim()
        if (Test-Path -LiteralPath $wt) {
            $gd = (git -C $wt rev-parse --git-dir).Trim()
            if (Test-Path -LiteralPath (Join-Path $gd "CHERRY_PICK_HEAD")) {
                git -C $wt cherry-pick --abort | Out-Null
            }
            elseif ((Test-Path -LiteralPath (Join-Path $gd "rebase-merge")) -or (Test-Path -LiteralPath (Join-Path $gd "rebase-apply"))) {
                git -C $wt rebase --abort | Out-Null
            }
            Remove-RefreshWorktree
            Remove-Item -LiteralPath (Get-PendingPath) -ErrorAction SilentlyContinue
            Write-Host "aborted"
            return
        }
    }
    $merge = git rev-parse --git-path rebase-merge
    $apply = git rev-parse --git-path rebase-apply
    $cherry = git rev-parse --git-path CHERRY_PICK_HEAD
    if ((Test-Path -LiteralPath $merge) -or (Test-Path -LiteralPath $apply)) {
        Invoke-Git rebase --abort
        Write-Host "rebase aborted"
        return
    }
    if (Test-Path -LiteralPath $cherry) {
        Invoke-Git cherry-pick --abort
        Write-Host "cherry-pick aborted"
        return
    }
    Die "no rebase or cherry-pick in progress"
}

function Invoke-Import {
    Assert-FullWorktree
    Assert-NoSequencer
    if (-not (Test-Ref "refs/heads/edits/latest")) { Die "no edits/latest" }
    $current = (git branch --show-current).Trim()
    if ($current -ne "master") { Invoke-Git checkout master }
    $source = (git rev-parse --abbrev-ref edits/latest).Trim()
    Invoke-Git checkout edits/latest -- @PairPaths
    Invoke-Git commit -m "Refresh src from $source"
}

if ($args.Count -eq 0) { Show-Usage; exit 1 }
$Command = $args[0]
$Argv = @()
if ($args.Count -gt 1) { $Argv = [string[]]$args[1..($args.Count - 1)] }

switch ($Command) {
    "start" { Invoke-Start $Argv }
    "rebase" { Invoke-RebaseCmd }
    "replay" { Invoke-Replay $Argv }
    "commit" { Invoke-CommitCmd $Argv }
    "squash" { Invoke-Squash }
    "continue" { Invoke-Continue }
    "abort" { Invoke-Abort }
    "import" { Invoke-Import }
    { $_ -in @("-h", "--help") } { Show-Usage }
    default { Show-Usage; Die "unknown command: $Command" }
}
