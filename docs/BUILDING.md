# Building

## Requirements

- Linux x64
- clang and clang++ (gcc is not supported: the runtime's SPU float helpers use a macro named `slow` that gcc
  mishandles)
- CMake 3.20 or newer, Ninja
- Python 3.10 or newer
- SDL3 and the Vulkan headers (SDK)
- a CPU with AVX2 (`x86-64-v3`) and a Vulkan-capable GPU
- the **ps3base runtime**, a separate checkout this port compiles against (see below)

## The runtime

`port/patches/` are patches against [ps3base](https://github.com/Noext/ps3base2); the build compiles that runtime and
links your lifted game code into it. The checkout is not part of this repository, because it is not the port.

```sh
git clone https://github.com/Noext/ps3base2 third_party/ps3base
```

`tools/env.sh` finds it at `third_party/ps3base`, or beside this folder (`../ps3base`, `../ps3base2`), or wherever
`PS3BASE` points. Set `PS3BASE` when it lives somewhere else.

## One command

```sh
tools/install.sh
```

It asks where your files are, checks them, lifts the game, builds, and remembers the paths.

## The setup step

```sh
tools/prepare.sh --game <disc folder>
```

is the same work without a question and without a window: it checks the disc folder's `TITLE_ID` and archives, then
lifts and builds. It prints `progress <fraction> <text>` lines and exits 0 only when the port is ready. It is what
`recomplauncher.json` runs, and it is safe to run again: a fingerprint of your files skips the hour of work when
nothing changed. Without `--game` it does nothing, so the commands below are unchanged.

## Step by step

```sh
tools/setup-vfs.sh    # the folder the game runs from, in work/vfs
tools/lift.sh         # translates your EBOOT.elf into work/lift
tools/build.sh        # work/build/ps3base
tools/play.sh         # plays in a window
```

`tools/play.sh --game <disc folder>` starts straight from a disc folder instead of `work/vfs`, which saves copying
2.2 GB of archives; the rest of `--fullscreen`, `--scale`, `--no-fps`, `--no-sound` and `--no-async-shaders` set one
of the runtime's settings for that run. RecompLauncher passes them for the settings it shows. Without them the game
starts exactly as before.

## Every release

```sh
tools/package-release.sh
```

writes `out/ProjectGrove-v<version>-Linux-x64.zip`: the port's sources, `tools/` and `docs/`, with
`recomplauncher.json` at the top of the zip. It runs `tools/check-tree.sh` first and refuses to write a zip that
would carry game material. It is what the release workflow should attach.

## Never trust an incremental tree

A `build/` carried through many edits can produce a binary that segfaults while the same commit in a clean tree runs
fine. If a crash is new and unexplained, `rm -rf work/build` and rebuild before investigating. The tell is a binary
much smaller than it should be.

## Parallelism

Cap builds at `-j 8`. On a shared machine higher values make it unusable for everything else.
