#!/bin/sh
# setup-vfs.sh -- build the folder the game runs from, out of the player's own files.
#
# The archives are copied, not extracted: the title parses them itself through
# its own file system code and its .idx, so the runtime only has to serve bytes.
set -eu
. "$(dirname "$0")/env.sh"

note "checking your files in $GAME"
for f in EBOOT.elf PS3DataMain.obb PS3DataMain.obb.idx PS3Data.obb PS3Data.obb.idx \
         PS3DataText.zip PS3DataText.zip.idx PS3DataText2.zip PS3DataText2.zip.idx; do
    require_file "$GAME/$f"
done

# The .obb files are stored ZIPs; a wrong or truncated copy fails loudly here
# rather than as a mysterious read error deep in a run.
for f in PS3DataMain.obb PS3Data.obb PS3DataText.zip PS3DataText2.zip; do
    magic=$(od -An -tx1 -N4 "$GAME/$f" | tr -d ' \n')
    [ "$magic" = "504b0304" ] || die "$f does not start with a ZIP signature (got $magic)"
done

note "building $VFS"
rm -rf "$VFS"
mkdir -p "$VFS/dev_bdvd/PS3_GAME/USRDIR" "$VFS/dev_hdd0/home/00000001/savedata"
for f in PS3DataMain.obb PS3DataMain.obb.idx PS3Data.obb PS3Data.obb.idx \
         PS3DataText.zip PS3DataText.zip.idx PS3DataText2.zip PS3DataText2.zip.idx; do
    cp "$GAME/$f" "$VFS/dev_bdvd/PS3_GAME/USRDIR/$f"
done
echo "setup-vfs: $VFS ready"
