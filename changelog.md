Working changelog for the next release. Update it as work lands.
At tag time, copy these sections into the GitHub release notes under `Changelog`.


### Improved

- Linux: the game takes about 115 MB less on disk, and its download is 25 MB smaller: the executable and its two native libraries no longer carry the names of their functions.

### Internal

- CI: a build compiles the files a change touches, where every build compiled all 5,500 of them: the objects are kept in hxcpp's compile cache, which finds one by what it was compiled from. On the same commit a build takes 11 minutes on Linux, 13 on Windows and 26 on macOS, where it took 1 h 18, 1 h 51 and 2 h 34.
- Releases: each platform's function names are kept in a file of the release (`Linux.symbols.tar.xz`, `Windows.symbols.zip`, `macOS.symbols.tar.xz`): `.debug` files that gdb and perf read next to the binaries, a PDB, and a dSYM per architecture. A native crash on Windows could not be traced to a function before.
