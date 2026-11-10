# Getting your files

**You need your own copy of the game.** Project Grove ships no game material of any kind, ever: no executable, no
archive, no asset, no key, no firmware. What follows says what you must have and how the scripts check it. It does not
explain how to obtain or decrypt anything; that is yours to do, with your own tools, from your own disc.

## What you need

| What | Which | Checked by |
|---|---|---|
| `EBOOT.elf` | a plain ELF from your own **BLES02219** disc (Europe, v01.02) | the lift asserts `ELF64 MSB PowerPC64` and reads the crash-safe text range; `tools/check-tree.sh` refuses any `.elf` inside the repository |
| `PS3DataMain.obb`, `PS3Data.obb`, `PS3DataText.zip`, `PS3DataText2.zip` | the four data archives from `PS3_GAME/USRDIR/`, with their `.idx` | `tools/setup-vfs.sh` copies them and checks each begins with the ZIP signature `50 4b 03 04` |

Put them in `Game/`, which is git-ignored:

```
Game/
  EBOOT.elf
  PS3DataMain.obb       PS3DataMain.obb.idx
  PS3Data.obb           PS3Data.obb.idx
  PS3DataText.zip       PS3DataText.zip.idx
  PS3DataText2.zip      PS3DataText2.zip.idx
```

## Version matters

The port targets **v01.02**. A different revision of the executable is a different binary with different function
addresses, and the recovered addresses in this tree would not describe it. The lift prints the ELF's SHA-256 and the
size of its text range; if they do not match the values in [dev/0003](dev/0003-the-title.md), the port will not behave
as documented.
