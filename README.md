# Dungeon Rampage Haxe
DRH is a port of [Dungeon Rampage](https://store.steampowered.com/app/3053950/Dungeon_Rampage/) from AS3/AIR to Haxe, targeting native Linux, macOS and Windows.

It relies on OpenFL, a graphical library re-implementing the Flash/AIR APIs with various added benefits.

# Installation instructions
Download it [here](https://github.com/Tutez64/Dungeon-Rampage-Haxe/releases), unzip it then launch DungeonBustersProject.

You need to have Steam open with the official game bought. Otherwise, it won't be able to connect to the official servers.

# Why?
Because DR runs very poorly and has really annoying delay issues. 

On average, you should get much more FPS using DRH, especially in the "Quality" mode which is often unusable in the official game, and no delay issue!

Similarly to the official game, restarting it before each new party is recommended, as performance degrades overtime.

# Join the Discord
More info are available in the [Discord server](https://discord.gg/VvWbNspZrQ). Any feedback is appreciated!

# How?
This project required months of hard work, most of it being put into the following open-source projects:
- [ax4](https://github.com/Tutez64/ax4), my AS3 to Haxe converter, based on ax3.
- [OpenFL](https://github.com/Tutez64/openfl), [SWF](https://github.com/Tutez64/swf), [Lime](https://github.com/Tutez64/lime) and [SWF](https://github.com/Tutez64/hxcpp)
- [SteamWrap](https://github.com/Tutez64/SteamWrap), to replace the Steam ANE.

# How to compile it yourself

The project depends on forked versions of OpenFL, Lime, SWF, hxcpp and SteamWrap, which are included as Git submodules.

## Requirements

- Haxe
- A C++ toolchain supported by hxcpp

Install the regular haxelib dependencies first:

```bash
haxelib install hxcpp
haxelib install format
haxelib install hxp
```

## Clone the repository

```bash
git clone --recurse-submodules https://github.com/Tutez64/Dungeon-Rampage-Haxe
cd Dungeon-Rampage-Haxe
```

If you cloned without `--recurse-submodules`, initialize the submodules afterwards:

```bash
git submodule update --init --recursive
```

## Configure local development libraries

The project file references the submodules directly, but registering them with haxelib is useful for commands such as `haxelib run openfl` and for rebuilding tools:

```bash
haxelib dev lime submodules/lime
haxelib dev openfl submodules/openfl
haxelib dev swf submodules/swf
haxelib dev steamwrap submodules/SteamWrap
haxelib dev hxcpp submodules/hxcpp
```

## Rebuild helper tools

Rebuild the SWF command-line tools:

```bash
cd submodules/swf
haxe rebuild.hxml
cd ../..
```

Rebuild the hxcpp command-line tools::
```bash
haxelib run lime rebuild hxcpp
```

SteamWrap already includes usable prebuilt binaries for Windows and Linux, so rebuilding it is usually not needed on these platforms.

The macOS binaries need to be rebuilt locally:

```bash
cd submodules/SteamWrap
./setup.sh
./build
cd ../..
```

On Windows, the equivalent commands are:

```bat
cd submodules\SteamWrap
setup.bat
build.bat
cd ..\..
```

## Build the game

From the repository root:

```bash
haxelib run openfl build project.xml cpp
```

For a debug build:

```bash
haxelib run openfl build project.xml cpp -debug
```

Replace `build` with `test` if you want the game to launch automatically after compiling.