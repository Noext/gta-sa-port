#!/bin/sh
# setup-vfs.sh -- build the folder the game runs from, out of the player's own files.
#
# The archives are copied, not extracted: the title parses them itself through
# its own file system code and its .idx, so the runtime only has to serve bytes.
#
#   tools/setup-vfs.sh [disc-folder]
#
# Without an argument the files come from Game/, the layout docs/GETTING-FILES.md
# describes. With one, they are read from that player's disc folder instead -- the
# folder holding PS3_GAME/USRDIR -- which is what RecompLauncher passes, and
# nothing is copied into Game/ for it.
set -eu
. "$(dirname "$0")/env.sh"

# A disc folder names the same files as Game/ does, only in their own place. A
# player who browses to their disc picks PS3_GAME, USRDIR or the root of it,
# so accept all three.
src="$GAME"
disc=${1:-}
if [ -n "$disc" ]; then
    [ -d "$disc" ] || die "no folder at $disc"
    case "$(basename "$disc")" in
        USRDIR) src="$disc" ;;
        PS3_GAME) src="$disc/USRDIR" ;;
        *) src="$disc/PS3_GAME/USRDIR" ;;
    esac
fi

note "checking your files in $src"
for f in PS3DataMain.obb PS3DataMain.obb.idx PS3Data.obb PS3Data.obb.idx \
         PS3DataText.zip PS3DataText.zip.idx PS3DataText2.zip PS3DataText2.zip.idx; do
    require_file "$src/$f"
done
if [ -z "$disc" ]; then
    require_file "$GAME/EBOOT.elf"
fi

# The .obb files are stored ZIPs; a wrong or truncated copy fails loudly here
# rather than as a mysterious read error deep in a run.
for f in PS3DataMain.obb PS3Data.obb PS3DataText.zip PS3DataText2.zip; do
    magic=$(od -An -tx1 -N4 "$src/$f" | tr -d ' \n')
    [ "$magic" = "504b0304" ] || die "$f does not start with a ZIP signature (got $magic)"
done

note "building $VFS"
rm -rf "$VFS"
mkdir -p "$VFS/dev_bdvd/PS3_GAME/USRDIR" "$VFS/dev_hdd0/home/00000001/savedata"
for f in PS3DataMain.obb PS3DataMain.obb.idx PS3Data.obb PS3Data.obb.idx \
         PS3DataText.zip PS3DataText.zip.idx PS3DataText2.zip PS3DataText2.zip.idx; do
    cp "$src/$f" "$VFS/dev_bdvd/PS3_GAME/USRDIR/$f"
done
# The disc's own metadata, when the files came from the disc itself: it names
# the title and its revision, which the runtime reports and the launcher uses to
# tell one release from another. Game/ never holds it, so it stays optional.
for f in PS3_GAME/PARAM.SFO PS3_GAME/ICON0.PNG PS3_DISC.SFB; do
    [ -f "$disc/$f" ] || [ -f "$disc/../$f" ] || continue
    if [ -f "$disc/$f" ]; then cp "$disc/$f" "$VFS/dev_bdvd/$f"
    else cp "$disc/../$f" "$VFS/dev_bdvd/$f"; fi
done
echo "setup-vfs: $VFS ready"
