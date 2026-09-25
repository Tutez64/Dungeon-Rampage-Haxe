#!/usr/bin/env python3
"""Stage and restore Lime's per-library SWF cache.

Lime skips a library when its zip is newer than the source. A git checkout
stamps every source with the job time, so a restored zip looks stale. An exact
cache hit can refresh every zip. A prefix hit restored an older tree: only the
libraries whose source hash still matches the stored manifest are refreshed.
The others are removed so Lime rebuilds those alone.
"""

import argparse
import hashlib
import os
from pathlib import Path
import shutil
import sys
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[2]
STAGE = ROOT / ".ci-cache" / "swf"
MANIFEST = STAGE / "manifest.tsv"


def library_name(element):
    name = element.get("id") or element.get("name")
    if name:
        return name
    path = element.get("path") or ""
    return Path(path.replace("\\", "/")).stem


def libraries():
    found = {}
    for xml_path in (ROOT / "generated_swf_libraries.xml", ROOT / "project.xml"):
        if not xml_path.is_file():
            continue
        for element in ET.parse(xml_path).getroot().iter("library"):
            source = element.get("path")
            if not source:
                continue
            found[library_name(element)] = source.replace("\\", "/")
    return found


def digest(path):
    hasher = hashlib.sha256()
    with open(path, "rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            hasher.update(chunk)
    return hasher.hexdigest()


def read_manifest():
    if not MANIFEST.is_file():
        return None
    rows = {}
    for line in MANIFEST.read_text(encoding="utf-8").splitlines():
        name, hashed, source = line.split("\t", 2)
        rows[name] = (hashed, source)
    return rows


def write_manifest(entries):
    lines = [f"{name}\t{hashed}\t{source}" for name, hashed, source in entries]
    MANIFEST.parent.mkdir(parents=True, exist_ok=True)
    MANIFEST.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")


def class_files(classes_path, generated):
    if not classes_path.is_file():
        return []
    paths = []
    for line in classes_path.read_text(encoding="utf-8", errors="replace").splitlines():
        class_name = line.strip()
        if not class_name or class_name.startswith("#"):
            continue
        paths.append(generated / (class_name.replace(".", "/") + ".hx"))
    return paths


def touch(path):
    if path.exists():
        os.utime(path, None)


def remove(path):
    if path.is_file():
        path.unlink()


def install(platform):
    libraries_dir = ROOT / "bin" / platform / "obj" / "libraries"
    generated = ROOT / "bin" / platform / "haxe" / "_generated"
    staged_libraries = STAGE / "libraries"
    staged_generated = STAGE / "generated"
    libraries_dir.mkdir(parents=True, exist_ok=True)
    generated.mkdir(parents=True, exist_ok=True)
    if staged_libraries.is_dir():
        shutil.copytree(staged_libraries, libraries_dir, dirs_exist_ok=True)
    if staged_generated.is_dir():
        shutil.copytree(staged_generated, generated, dirs_exist_ok=True)

    current = libraries()
    known = read_manifest()
    if known is None:
        for path in (libraries_dir, generated):
            for child in path.rglob("*"):
                touch(child)
            touch(path)
        print("SWF cache has no manifest; refreshed every restored library")
        return

    kept = 0
    rebuilt = 0
    for name, source in sorted(current.items()):
        source_path = ROOT / source
        cached = known.get(name)
        fresh = source_path.is_file() and cached is not None and cached[0] == digest(source_path)
        zip_path = libraries_dir / f"{name}.zip"
        classes_path = libraries_dir / f"{name}.classes.txt"
        if fresh:
            touch(zip_path)
            touch(classes_path)
            for hx_path in class_files(classes_path, generated):
                touch(hx_path)
            kept += 1
            continue
        for hx_path in class_files(classes_path, generated):
            remove(hx_path)
        remove(zip_path)
        remove(classes_path)
        rebuilt += 1
        print(f"SWF cache drop {name}")

    wanted = set(current)
    for zip_path in libraries_dir.glob("*.zip"):
        if zip_path.stem not in wanted:
            classes_path = libraries_dir / f"{zip_path.stem}.classes.txt"
            for hx_path in class_files(classes_path, generated):
                remove(hx_path)
            remove(classes_path)
            remove(zip_path)
            print(f"SWF cache drop {zip_path.stem}")
    print(f"SWF cache kept {kept}, dropped {rebuilt}")


def stage(platform):
    libraries_dir = ROOT / "bin" / platform / "obj" / "libraries"
    generated = ROOT / "bin" / platform / "haxe" / "_generated"
    staged_libraries = STAGE / "libraries"
    staged_generated = STAGE / "generated"
    staged_libraries.mkdir(parents=True, exist_ok=True)
    staged_generated.mkdir(parents=True, exist_ok=True)
    if libraries_dir.is_dir():
        shutil.copytree(libraries_dir, staged_libraries, dirs_exist_ok=True)
    if generated.is_dir():
        shutil.copytree(generated, staged_generated, dirs_exist_ok=True)

    entries = []
    for name, source in sorted(libraries().items()):
        source_path = ROOT / source
        if source_path.is_file():
            entries.append((name, digest(source_path), source))
    write_manifest(entries)
    print(f"Staged {len(entries)} SWF library hash(es)")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("install", "stage"))
    parser.add_argument("--platform", required=True)
    args = parser.parse_args()
    if args.command == "install":
        install(args.platform)
    else:
        stage(args.platform)


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(error, file=sys.stderr)
        sys.exit(1)
