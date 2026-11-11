#!/usr/bin/env python3
"""make_overlay.py <repository> <output dir> : the classpath a bench build puts over the game's.

It holds PerfBot and PerfProbe, a copy of src/import.hx, and src/brain/facade/Facade.hx with
three hooks: PerfBot.frame() on each frame, the wall clock read in whole milliseconds (see the
README), and PerfBot.cheatCount() where the game counts a suspicious second."""
import os, re, shutil, sys

root, out = sys.argv[1], sys.argv[2]
bench = os.path.dirname(os.path.abspath(__file__))
path = os.path.join(root, 'src/brain/facade/Facade.hx')
source = open(path).read()


def hook(pattern, replacement, what):
    global source
    found = re.findall(pattern, source, flags=re.M)
    if len(found) != 1:
        sys.exit('make_overlay.py: %s: expected once in %s, found %d times. Update the hook.' % (what, path, len(found)))
    source = re.sub(pattern, replacement, source, flags=re.M)


def name(pattern, what):
    found = re.findall(pattern, source, flags=re.M)
    if len(found) != 1:
        sys.exit('make_overlay.py: %s: expected once in %s, found %d times. Update the hook.' % (what, path, len(found)))
    return found[0]


delta = name(r'^\s*var (\w+) = mGameClock\.update\(\);$', 'the game clock update')
ratio = name(r'^\s*if \((\w+) > 1\.1\) \{$', 'the speed ratio test')
hook(r'^(\tpublic function mainLoop\(event:Event\) \{\n)', r'\1\t\tPerfBot.frame(this);\n', 'mainLoop')
hook(r'^(\s*)mCurrentTime = Date\.now\(\)\.getTime\(\);$',
     r'\1var perfRawNow = Date.now().getTime();\n'
     r'\1PerfBot.clockProbe(perfRawNow, %s);\n'
     r'\1// Whole milliseconds, as Date.getTime() gives on AIR\n'
     r'\1mCurrentTime = Math.ffloor(perfRawNow);' % delta, 'the wall clock read')
hook(r'^(\s*)(mCheatCount = mCheatCount \+ 1;)$', r'\1\2\n\1PerfBot.cheatCount(mCheatCount, %s);' % ratio, 'the cheat count')

shutil.rmtree(out, ignore_errors=True)
os.makedirs(os.path.join(out, 'brain/facade'))
open(os.path.join(out, 'brain/facade/Facade.hx'), 'w').write(source)
shutil.copy(os.path.join(root, 'src/import.hx'), out)
for file in os.listdir(os.path.join(bench, 'overlay')):
    shutil.copy(os.path.join(bench, 'overlay', file), out)
