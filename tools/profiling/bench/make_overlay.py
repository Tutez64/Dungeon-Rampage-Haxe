#!/usr/bin/env python3
"""make_overlay.py <repository> <output dir> : the classpath a bench build puts over the game's.

It holds PerfBot and PerfProbe, a copy of src/import.hx, and copies of a few of the game's files
with hooks:

- brain/facade/Facade.hx: PerfBot.frame() on each frame, the wall clock read in whole
  milliseconds (see the README), PerfBot.cheatCount() where the game counts a suspicious second,
  and a timer around each work manager and the views;
- starling/core/Starling.hx: a timer around the frame's advance and its render;
- starling/filters/FragmentFilter.hx: the filter passes counted;
- networkCode/DcSocket.hx: a timer around the handling of received data;
- OpenFL's openfl/display/DisplayObjectRenderer.hx (from submodules/openfl): each cached bitmap that is
  drawn again is told to PerfBot.

DRH_BENCH_PATCHES names a folder of patches (git diff of files under src/) applied over all that:
changes under test, each written `if (PerfBot.on(k)) new else old`, so that src/ stays as it is.

Hooks only change function bodies: a new member would change the class's header and have hxcpp
recompile every file that includes it, for the bench build and again for the next normal one."""
import os, re, shutil, sys

root, out = sys.argv[1], sys.argv[2]
bench = os.path.dirname(os.path.abspath(__file__))


class Source:
    def __init__(self, relative, base='src'):
        self.relative = relative
        self.path = os.path.join(root, base, relative)
        self.text = open(self.path).read()

    def fail(self, what, count):
        sys.exit('make_overlay.py: %s: expected once in %s, found %d times. Update the hook.' % (what, self.path, count))

    def hook(self, pattern, replacement, what):
        found = re.findall(pattern, self.text, flags=re.M)
        if len(found) != 1:
            self.fail(what, len(found))
        self.text = re.sub(pattern, replacement, self.text, flags=re.M)

    def name(self, pattern, what):
        found = re.findall(pattern, self.text, flags=re.M)
        if len(found) != 1:
            self.fail(what, len(found))
        return found[0]

    def time(self, statement, block):
        """Times a statement that is a whole line into a block of PerfBot."""
        self.hook(r'^(\s*)(%s)$' % statement,
                  r'\1var perfT%s = PerfBot.begin();\n\1\2\n\1PerfBot.end(PerfBot.B_%s, perfT%s);' % (block, block, block), statement)

    def save(self):
        target = os.path.join(out, self.relative)
        os.makedirs(os.path.dirname(target), exist_ok=True)
        open(target, 'w').write(self.text)


shutil.rmtree(out, ignore_errors=True)
os.makedirs(out)

facade = Source('brain/facade/Facade.hx')
delta = facade.name(r'^\s*var (\w+) = mGameClock\.update\(\);$', 'the game clock update')
ratio = facade.name(r'^\s*if \((\w+) > 1\.1\) \{$', 'the speed ratio test')
facade.hook(r'^(\tpublic function mainLoop\(event:Event\) \{\n)', r'\1\t\tPerfBot.frame(this);\n', 'mainLoop')
facade.hook(r'^(\s*)mCurrentTime = Date\.now\(\)\.getTime\(\);$',
            r'\1var perfRawNow = Date.now().getTime();\n'
            r'\1PerfBot.clockProbe(perfRawNow, %s);\n'
            r'\1// Whole milliseconds, as Date.getTime() gives on AIR\n'
            r'\1mCurrentTime = Math.ffloor(perfRawNow);' % delta, 'the wall clock read')
facade.hook(r'^(\s*)(mCheatCount = mCheatCount \+ 1;)$', r'\1\2\n\1PerfBot.cheatCount(mCheatCount, %s);' % ratio, 'the cheat count')
facade.time(r'mRealClockWorkManager\.update\(mRealClock\);', 'REALWORK')
facade.time(r'mLogicalWorkManager\.update\(mGameClock\);', 'LOGICAL')
facade.time(r'mPhysicsWorkManager\.update\(mGameClock\);', 'PHYSICS')
facade.time(r'mPreRenderWorkManager\.update\(mGameClock\);', 'PRERENDER')
facade.time(r'View\.renderInterpolatedAll\(\w+\);', 'VIEWS')
facade.time(r'mLayerRenderWorkManager\.update\(mRealClock\);', 'LAYERS')
facade.save()

starling = Source('starling/core/Starling.hx')
starling.time(r'advanceTime\(_loc\d+_\);', 'ADVANCE')
# render() as a whole line at this depth is nextFrame's; the one of onEnterFrame is deeper
starling.hook(r'^(\t\t)(render\(\);)$', r'\1var perfTRender = PerfBot.begin();\n\1\2\n\1PerfBot.end(PerfBot.B_RENDER, perfTRender);', "nextFrame's render")
starling.save()

filters = Source('starling/filters/FragmentFilter.hx')
filters.hook(r'^(\s*)(_helper\.start\(numPasses, \w+\);)$', r'\1\2\n\1PerfBot.passes += numPasses;\n\1PerfBot.filters++;', 'the start of the filter passes')
filters.save()

socket = Source('networkCode/DcSocket.hx')
socket.time(r'ProcessMoreSocketData\(event\.bytes\);', 'NETWORK')
socket.save()

renderer = Source('openfl/display/DisplayObjectRenderer.hx', 'submodules/openfl/src')
renderer.hook(r'^(\t+)(displayObject\.__cacheBitmap\.clippingLayer = displayObject\.__mask;\n\n\t+if \(needRender\)\n\t+\{\n)',
              r'\1\2\1\tPerfBot.cacheBitmapRendered(displayObject, (displayObject.__renderDirty ? 1 : 0) | (softwareDirty ? 2 : 0)'
              r' | (hardwareDirty ? 4 : 0) | (renderType == OPENGL ? 8 : 0) | (renderer.__type == OPENGL ? 16 : 0)'
              r' | (hasFilters ? 32 : 0) | (renderer.__type == OPENGL && (cast renderer : openfl.display.OpenGLRenderer).__defaultRenderTarget == null ? 64 : 0));\n',
              'the render of a cached bitmap')
renderer.save()

patches = os.environ.get('DRH_BENCH_PATCHES')
if patches:
    import glob, subprocess
    for patch in sorted(glob.glob(os.path.join(patches, '*.patch'))):
        for line in open(patch):
            # a file a patch changes is first taken from src/, unless a hook already put it there
            if line.startswith('+++ b/src/'):
                relative = line[len('+++ b/src/'):].strip()
                target = os.path.join(out, relative)
                if not os.path.exists(target):
                    os.makedirs(os.path.dirname(target), exist_ok=True)
                    shutil.copy(os.path.join(root, 'src', relative), target)
        done = subprocess.run(['patch', '-p2', '--no-backup-if-mismatch', '-d', out, '-i', patch], capture_output=True, text=True)
        if done.returncode != 0:
            sys.exit('make_overlay.py: %s does not apply:\n%s%s' % (patch, done.stdout, done.stderr))
        print('patched: ' + os.path.basename(patch))

shutil.copy(os.path.join(root, 'src/import.hx'), out)
for file in os.listdir(os.path.join(bench, 'overlay')):
    shutil.copy(os.path.join(bench, 'overlay', file), out)
