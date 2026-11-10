# 0003 -- The title, and its numbers

**Date:** 2026-11-10
**Status:** verified against the disc

Numbers recovered from the binary, kept here so a build can be checked against them.

## Identity

| Field | Value | Source |
|---|---|---|
| TITLE_ID | **BLES02219** | `PARAM.SFO` |
| TITLE | GTA San Andreas | `PARAM.SFO` |
| VERSION | 01.02 | `PARAM.SFO` |
| CAT | DG (disc) | `PARAM.SFO` |
| PS3_SYSTEM_VER | 04.7600 | `PARAM.SFO` |

## Executable

| Field | Value |
|---|---|
| `EBOOT.BIN` size | 8,113,656 |
| SELF `self_type` | 4 (APP) |
| `key_revision` | 0x1C |
| `EBOOT.elf` size | 8,111,224 |
| ELF class | ELF64, MSB, PowerPC64 |
| entry point | `0x77b718` (an OPD: code `0x62b7f4`, TOC `0x7855e8`) |
| text range | `0x00010200` - `0x006fccdc` |
| PID | `0x475001` |
| primary priority | 550 |
| primary stack | `0x40000` |
| TLS | `0x77e17c` / `0x17c` / `0x17c` |

## Program headers

`readelf -l` reports eight: two real `PT_LOAD` (code R E at `0x10000`, data RW at `0x750000` with `MemSiz` 4.3 MB
larger than `FileSiz`, i.e. `.bss`), one `PT_TLS`, and two `LOOS+0x1`/`LOOS+0x2` segments. The `0x60000001`-style
process-parameter segment that some titles carry is not among them.

## Translation

| | |
|---|---|
| PPU functions | **20,082** |
| translation units | 71 |
| imports | **116**, all resolved |
| exports | 0 |

## Import table by module

| Module | Imports | Provided by lifted firmware |
|---|---|---|
| `cellGcmSys` | 25 | yes |
| `cellSysutil` | 19 | no |
| `sysPrxForUser` | 15 | yes |
| `cellSync2` | 13 | no |
| `sys_fs` | 11 | yes |
| `cellGame` | 11 | mostly |
| `cellAudio` | 8 | mostly |
| `sceNpTrophy` | 6 | no |
| `sys_io` | 5 | no |
| `cellSysmodule` | 1 | no |
| `cellSysutilAvconfExt` | 1 | no |
| `cellSaveData` | 1 | no |

**52 of the 116 are supplied by the lifted firmware modules** already present; the remaining 64 are reimplemented.

## No SPU

The import table contains no `cellSpurs` function, and the executable ships no SPU program images. The lift
pipeline is run with an empty block manifest and still writes the registry the build expects. If a future run shows
SPU code being interpreted, something is wrong with the assumption, not with the pipeline.
