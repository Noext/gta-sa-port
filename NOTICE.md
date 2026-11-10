# Notices and credits

Project Grove is MIT ([LICENSE](LICENSE)). That licence covers this repository's own code, patches, tools and
documentation, and nothing else.

## The game

**Grand Theft Auto: San Andreas** is (c) Rockstar Games / Take-Two Interactive Software, Inc. The PS3 release
(BLES02219) was ported by War Drum Studios. "Grand Theft Auto", "San Andreas", "Rockstar" and related marks are
trademarks of their owners. No game code, data, asset, key or firmware is included here, and none ever will be.

This is a fan project. It is not affiliated with, endorsed by or supported by Sony Interactive Entertainment,
Rockstar Games, Take-Two Interactive or War Drum Studios.

## The runtime this port is built on

- **[ps3base](https://github.com/snuri00/GoWA-pc)**, a generic PS3 static-recompilation runtime (MIT). This port's
  runtime is the ps3base v2 tree plus the patches in `port/patches/`.
- **RPCS3** (GPL-2.0) was read as a reference for structure layouts, constants and observable behaviour. No code was
  copied or translated from it.
- **[ps3recomp](https://github.com/sp00nznet/ps3recomp)** (MIT), the recompiler family the runtime's lifter descends
  from.

## Projects this repository's shape is adapted from

- **[Project Vekta](https://github.com/gustavomorinaga/project-vekta)** (Killzone HD, MIT): the layout of this
  repository, its README structure, its `AGENTS.md` and its documentation conventions are adapted from it.
- Through Vekta: **[Project Helghast](https://github.com/undecuple/project-helghast)** and
  **[Project Pyrrhus](https://github.com/undecuple/project-pyrrhus)** (Killzone 3 and 2, MIT).

## Tools

- **capstone** (BSD-3-Clause) for disassembling the original binary while diagnosing.
- **7-Zip** was used to inspect the disc's data archives; it is not a build dependency.
- **pycryptodome** and **zlib** are used by the file preparation tools.

## Fonts and images

`docs/screenshots/` holds screenshots of the port running. They show the game's own output; no asset file is
redistributed.
