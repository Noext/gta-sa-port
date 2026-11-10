# Building

## Requirements

- Linux x64
- clang and clang++ (gcc is not supported: the runtime's SPU float helpers use a macro named `slow` that gcc
  mishandles)
- CMake 3.20 or newer, Ninja
- Python 3.10 or newer
- SDL3 and the Vulkan headers (SDK)
- a CPU with AVX2 (`x86-64-v3`) and a Vulkan-capable GPU

## One command

```sh
tools/install.sh
```

It asks where your files are, checks them, lifts the game, builds, and remembers the paths.

## Step by step

```sh
tools/setup-vfs.sh    # the folder the game runs from, in work/vfs
tools/lift.sh         # translates your EBOOT.elf into work/lift
tools/build.sh        # work/build/ps3base
tools/play.sh         # plays in a window
```

## Never trust an incremental tree

A `build/` carried through many edits can produce a binary that segfaults while the same commit in a clean tree runs
fine. If a crash is new and unexplained, `rm -rf work/build` and rebuild before investigating. The tell is a binary
much smaller than it should be.

## Parallelism

Cap builds at `-j 8`. On a shared machine higher values make it unusable for everything else.
