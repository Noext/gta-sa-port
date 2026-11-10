# Changelog

All notable changes to this port are recorded here. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- The port: boot, the lifted PPU translation of BLES02219 v01.02, and the HLE modules this title needs.
- `cellSync2` (13 imports), implemented with real host synchronisation rather than stubs.
- Documentation: how it works, how to build, how to supply your own files, known issues, roadmap, and engineering
  notes on the TOC register, the data archives, the title's recovered numbers and how to judge a run.
- RecompLauncher support: `recomplauncher.json` (Easy Setup and settings, with the disc folder checked and the port
  built on the player's PC by `tools/prepare.sh`), the "Get it on RecompLauncher" badge in the README, and
  `tools/package-release.sh`, which writes the release zip with the file at its top.
- `tools/prepare.sh`: the same setup as `tools/install.sh` without a question or a window, printing
  `progress <fraction> <text>` lines, skipping the lift and build when your files have not changed.
- `tools/play.sh` takes `--game <disc folder>` to play straight from a disc instead of `work/vfs`, and
  `--fullscreen`, `--scale`, `--no-fps`, `--no-sound` and `--no-async-shaders` for one run. Without them it
  starts the game as before.
- `docs/GETTING-FILES.md` now says the port also needs the seven firmware modules the title imports from. They were
  always required by `port/manifests/images-grove.json`; the page did not say so.

### Fixed
- The import dispatch now performs the `std r2, 0x28(r1)` that the disc's import stubs carry, for both the LLE and
  the HLE path. Without it the caller restored a stale table-of-contents register and faulted on its next global read.
  See `docs/dev/0001-the-toc-register.md`.

### Known at this version
- In game at Grove Street with a full HUD; no mission played past the opening.
- No audio (no device in the environment this was developed in).
- A blue triangular artefact near the starting BMX.
