# Instructions for AI coding agents

Read this before changing anything in this repository. It applies to every automated contributor and to the people
who run them. Human contributors: the same rules are in [CONTRIBUTING.md](.github/CONTRIBUTING.md).

Adapted from the same file in [Project Vekta](https://github.com/gustavomorinaga/project-vekta), the Killzone HD port
(MIT), which in turn adapted it from Project Helghast and Project Pyrrhus.

## The project

Project Grove is an unofficial PC port of **Grand Theft Auto: San Andreas** for PS3 (title **BLES02219**, Europe,
v01.02) made by **static recompilation**: the game's PowerPC code is lifted to C++ ahead of time and compiled into a
native Linux x64 program, and the PS3 system software it calls is reimplemented; graphics go through Vulkan. The
repository holds only the port. Each player lifts and builds the game's code from their own copy. Overview:
[README.md](../README.md) and [HOW-IT-WORKS.md](HOW-IT-WORKS.md). Status: [FEATURES.md](FEATURES.md),
[KNOWN_ISSUES.md](KNOWN_ISSUES.md).

## Repository map

| Path | What it holds |
|---|---|
| `port/grove/` | the port's own code: boot, HLE overrides, corrections this title needs |
| `port/patches/` | numbered patches to the runtime and `series`, the order they apply in |
| `tools/` | `env.sh` (paths), `install.sh`, `setup-vfs.sh`, `lift.sh`, `build.sh`, `play.sh`, `check-tree.sh` |
| `docs/` | public documentation; `docs/dev/` holds engineering notes |
| `CHANGELOG.md` | what each release contains, newest first |

## Rules for everyone

- **No game material, ever.** Never commit, attach, paste, request or link to: files from the disc, decrypted
  binaries (`EBOOT.elf`, firmware modules), lifted game code, extracted assets, saves, keys or firmware. Numbers,
  names, structure layouts and formulas recovered from the game are fine. `Game/` and `work/` stay out of git
  (`.gitignore`); do not weaken it.
- **No circumvention.** The repository ships no decryption or copy-protection circumvention tools, no keys and no
  instructions for decrypting game or firmware files. The docs only say what the player must have
  ([GETTING-FILES.md](GETTING-FILES.md)).
- **No GPL code.** RPCS3 (GPL-2.0) may be read as a reference for behaviour and data layouts; never copy, translate
  or closely paraphrase its code. Write behaviour from your own understanding and say so in the change.
- **Gameplay stays original by default.** Mark features the PS3 game does not have `ENHANCEMENT:`; anything that
  changes gameplay is opt-in. Mark values not yet recovered from the binary `ASSUMPTION:` and never restate one as
  fact. Keep original function addresses in comments.
- **Online is opt-in.** Nothing may contact the network unless the player chose it.
- **Never a fake success.** An unimplemented syscall, import or function returns an explicit error and logs its name.
  Returning `CELL_OK` from something that did not run tells the caller its state was created when it was not, and the
  failure then surfaces far from its cause.
- **Never transcribe a structure, enum or table from memory.** When a header or a reference implementation is
  available, read it. Retyping field order, offsets or signatures is a guess that fails quietly.
- **Measure, then conclude.** A conclusion drawn from the absence of a log is invalid until you have shown the log
  could have appeared. Two hardware-level claims in this tree were refuted by their own instrumentation; the
  refutations are in `docs/dev/` and stay there.

## Licence and attribution

- The port's code, tools and docs are MIT ([LICENSE](../LICENSE)). The game itself is covered by no licence here.
- A new dependency needs a licence compatible with MIT distribution and a row in [NOTICE.md](../NOTICE.md) in the
  same change.
- **Credit what you absorb.** Work taken from an upstream project, a pull request, a fork or another port is credited
  in the commit message and in NOTICE.md. Never remove or shorten existing credits.

## Build and test

Build steps: [BUILDING.md](BUILDING.md). **Never write into the player's game files**, and keep them out of the
repository.

- Before a pull request, `tools/check-tree.sh` must find no game files, personal paths or secrets.
- Cap builds at `-j 8`. This machine is shared.
- A runtime fix comes with a note in `docs/dev/` that says what was measured, what was refuted, and what proves the
  fix.
