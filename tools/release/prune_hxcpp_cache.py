#!/usr/bin/env python3
"""prune_hxcpp_cache.py <cache dir> <build dir> [--lists N]

Removes from hxcpp's compile cache (HXCPP_COMPILE_CACHE) the objects of the game that the build which
just ended did not link, so that the cache a CI run saves holds one build and not every build since
the first.

hxcpp names a cached object after a hash of its source, of the headers it depends on, of the
compiler's options and of its version: a source that changes leaves its old object behind. The
linker's lists (`all_objs`, one per architecture under the build directory) name the objects in use.

Only the objects of the cache's `haxe` project are pruned. Its precompiled headers are kept: an
object older than its precompiled header is compiled again, so removing the one in use would cost a
whole build. Nothing is removed when fewer than N lists are found (2 on macOS, where a list missing
would take one architecture's objects away), or when a list names no cached object.
"""
import argparse
import os
import sys
from pathlib import Path


def normal(path):
    return os.path.normcase(os.path.normpath(os.path.abspath(path)))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("cache")
    parser.add_argument("build")
    parser.add_argument("--lists", type=int, default=1)
    args = parser.parse_args()

    project = Path(args.cache) / "haxe"
    if not project.is_dir():
        print(f"No {project}: nothing to prune")
        return

    root = normal(project) + os.sep
    lists = sorted(Path(args.build).rglob("all_objs"))
    used = set()
    for path in lists:
        named = 0
        for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
            entry = line.strip().strip('"')
            # Objects under the build directory are written relative to it: they are not cached ones
            if entry and os.path.isabs(entry) and normal(entry).startswith(root):
                used.add(normal(entry))
                named += 1
        print(f"{path}: {named} cached objects")
        if named == 0:
            print("A list names no cached object: nothing pruned")
            return
    if len(lists) < args.lists:
        print(f"{len(lists)} list(s) found under {args.build}, {args.lists} expected: nothing pruned")
        return

    kept = removed = 0
    kept_bytes = removed_bytes = 0
    for folder in project.iterdir():
        # Objects are in folders named by two hexadecimal digits; `pch...` and `lib` hold the rest
        if not folder.is_dir() or len(folder.name) != 2:
            continue
        for file in folder.iterdir():
            size = file.stat().st_size
            if normal(file) in used:
                kept += 1
                kept_bytes += size
            else:
                file.unlink()
                removed += 1
                removed_bytes += size
        if not any(folder.iterdir()):
            folder.rmdir()

    headers = [folder for folder in project.iterdir() if folder.is_dir() and folder.name.startswith("pch")]
    total = sum(file.stat().st_size for file in Path(args.cache).rglob("*") if file.is_file())
    megabytes = 1024 * 1024
    print(f"Kept {kept} objects ({kept_bytes // megabytes} MB), removed {removed} ({removed_bytes // megabytes} MB)")
    print(f"{len(headers)} precompiled header folder(s); the cache holds {total // megabytes} MB")


if __name__ == "__main__":
    sys.exit(main())
