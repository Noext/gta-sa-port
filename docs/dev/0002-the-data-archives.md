# 0002 -- The data archives are stored ZIP files

**Date:** 2026-11-10
**Status:** verified

## What they look like

The disc's content is not in plain directories. `PS3_GAME/USRDIR/` holds four archives, each with a `.idx`:

| File | Size | Entries |
|---|---|---|
| `PS3DataMain.obb` | 1,479,813,213 | 244 |
| `PS3Data.obb` | 708,640,703 | 76 |
| `PS3DataText.zip` | 11,400,486 | many small `.dat` |
| `PS3DataText2.zip` | 9,523,770 | |

## They are ZIP

```
$ xxd -l 16 PS3Data.obb
00000000: 504b 0304 0a00 0000 0000 00a7 4845 72a4   PK..........HEr.
```

`50 4b 03 04` is the local file header, and the compression method is `0` (**stored**), so a reader can treat the
archive as a flat byte range per entry.

```
$ 7z l PS3Data.obb | tail -2
2015-11-02 22:39:57          708628413    708628413  76 files
```

Note that the sum of the entry sizes equals the file size minus the headers: nothing is compressed.

## The `.idx` is a flat index

Not code, not a cache. Layout:

```
u32 count
repeat count times:
    u32 offset      ; relative to the start of the archive's data area
    u32 size
    u16 name_len
    char name[name_len]
```

Verified by parsing it and comparing with what 7z lists: 76 entries for 76 files, and the second-to-last entry's
`offset + size` lands exactly on the last entry's offset.

## Consequence for the port

Nothing to reverse-engineer and nothing to reimplement. The title reads these through `sys_fs` and does its own
parsing; the runtime only has to serve the bytes. The names confirm the ancestry (`data/script/mainPS3.scm`,
`data/handling.cfg`, `Text/PS3/*.gxt`, `Textures/fonts/`): this is the PC-era data tree of San Andreas.

## A trap

It is tempting to read `.obb` as Android's OBB format, because the extension matches and this release descends from a
mobile port. It is not: there is no `OBB` magic, no media directory, no encryption. The extension is a name.
