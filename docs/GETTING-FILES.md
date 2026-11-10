# Getting your files

**You need your own copy of the game.** Project Grove ships no game material of any kind, ever: no executable, no
archive, no asset, no key, no firmware. What follows says what you must have and how the scripts check it. It does not
explain how to obtain or decrypt anything; that is yours to do, with your own tools, from your own disc.

## What you need

| What | Which | Checked by |
|---|---|---|
| `EBOOT.elf` | a plain ELF from your own **BLES02219** disc (Europe, v01.02) | the lift asserts `ELF64 MSB PowerPC64` and reads the crash-safe text range; `tools/check-tree.sh` refuses any `.elf` inside the repository |
| `PS3DataMain.obb`, `PS3Data.obb`, `PS3DataText.zip`, `PS3DataText2.zip` | the four data archives from `PS3_GAME/USRDIR/`, with their `.idx` | `tools/setup-vfs.sh` copies them and checks each begins with the ZIP signature `50 4b 03 04` |
| `liblv2`, `libsysmodule`, `libsre`, `libgcm_sys`, `libfs`, `libvdec`, `libsmvd2` | the firmware modules the title imports from, as plain ELFs, from your own firmware | `tools/lift.sh` fails on the first one that is missing; [port/manifests/README.md](../port/manifests/README.md) says why they are lifted rather than reimplemented |

The seven firmware modules are what the game calls into and what this port does **not** reimplement: lifting them from
your own firmware means the game runs Sony's own `libfs`, `libgcm_sys`, `libsre` and the rest, instead of a guess at
what they did. They stay in `Game/fw/`, which is git-ignored like everything else here.

## Where they go

Put them in `Game/`, which is git-ignored:

```
Game/
  EBOOT.elf
  PS3DataMain.obb       PS3DataMain.obb.idx
  PS3Data.obb           PS3Data.obb.idx
  PS3DataText.zip       PS3DataText.zip.idx
  PS3DataText2.zip      PS3DataText2.zip.idx
  fw/
    liblv2.elf  libsysmodule.elf  libsre.elf  libgcm_sys.elf
    libfs.elf   libvdec.elf       libsmvd2.elf
```

The four archives are read from the disc folder itself when you start the game with one (`tools/prepare.sh --game`
and `tools/play.sh --game`, which is what RecompLauncher passes), so you do not have to copy 2.2 GB to play; `Game/`
only has to hold them for the older `tools/setup-vfs.sh` flow.

## Version matters

The port targets **v01.02**. A different revision of the executable is a different binary with different function
addresses, and the recovered addresses in this tree would not describe it. The lift prints the ELF's SHA-256 and the
size of its text range; if they do not match the values in [dev/0003](dev/0003-the-title.md), the port will not behave
as documented.

The disc folder is checked for this too, before anything is lifted: `tools/prepare.sh` reads `PS3_GAME/PARAM.SFO`
and refuses a `TITLE_ID` that is not `BLES02219`, so a different release is one line at the start instead of a
failure three hours into a build.
