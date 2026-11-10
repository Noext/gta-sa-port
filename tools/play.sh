#!/bin/sh
# play.sh -- run the game in a window.
#
# Deliberately NOT wrapped in a timeout: a run you watch must not be closed by
# its own launcher. Kill it by process group when you are done.
#
#   tools/play.sh [--game <disc folder>] [--fullscreen] [--scale K] [--no-fps]
#                 [--no-sound] [--no-async-shaders] [-- <title arguments>]
#
# --game starts the game straight from that disc folder, the one that contains
# PS3_GAME, instead of the copy tools/setup-vfs.sh made. RecompLauncher passes
# the copy the player picked. The other options are each one of the runtime's
# own settings, set for this run only; without them nothing changes.
set -eu
. "$(dirname "$0")/env.sh"

[ -x "$BUILD/ps3base" ] || die "no binary at $BUILD/ps3base; run tools/build.sh first"

disc=""
while [ $# -gt 0 ]; do
    case "$1" in
        --game)         [ $# -ge 2 ] || die "--game needs a path"; disc=$2; shift ;;
        --game=*)       disc=${1#--game=}; shift ;;
        --fullscreen)   GOWA_FULLSCREEN=1 ;;
        --scale)        [ $# -ge 2 ] || die "--scale needs a number"; GOWA_RES_SCALE=$2; shift ;;
        --no-fps)       GOWA_FPS_OSD=0 ;;
        --no-sound)     GOWA_AUDIO=0 ;;
        --no-async-shaders) GOWA_ASYNC_SHADERS=0 ;;
        --)             shift; break ;;
        *)              break ;;
    esac
    shift
done

if [ -n "$disc" ]; then
    # The same three names for one disc that prepare.sh accepts: the root, the
    # PS3_GAME folder, or its USRDIR.
    [ -d "$disc" ] || die "no folder at $disc"
    case "$(basename "$disc")" in
        USRDIR)   disc=$(cd "$disc/../.." && pwd) ;;
        PS3_GAME) disc=$(cd "$disc/.." && pwd) ;;
        *)        disc=$(cd "$disc" && pwd) ;;
    esac
    # Exit 2, not 1: recomplauncher.json turns 2 into "your disc folder has
    # moved, pick it again", which is a fix the player can act on, while 1 is
    # the runtime's own "it would not start".
    [ -f "$disc/PS3_GAME/USRDIR/PS3DataMain.obb" ] || {
        echo "error: $disc does not look like the disc folder: no PS3_GAME/USRDIR/PS3DataMain.obb" >&2
        exit 2
    }
    export PS3BASE_DISC_DIR="$disc"
elif [ -f "$WORK/.disc-path" ]; then
    # The copy tools/prepare.sh set up, which is what a player who has just run
    # the setup step has: use it rather than making them pass it again.
    disc=$(cat "$WORK/.disc-path")
    [ -f "$disc/PS3_GAME/USRDIR/PS3DataMain.obb" ] || {
        echo "error: the disc folder recorded at $WORK/.disc-path is gone: $disc" >&2
        echo "       pick it again with --game <disc folder>" >&2
        exit 2
    }
    export PS3BASE_DISC_DIR="$disc"
else
    [ -d "$VFS/dev_bdvd" ] || die "no VFS at $VFS; run tools/setup-vfs.sh first, or pass --game <disc folder>"
    export PS3BASE_DISC_DIR="$VFS/dev_bdvd"
fi

mkdir -p "$VFS/dev_hdd0/home/00000001/savedata" "$VFS/dev_hdd1" "$VFS/dev_usb000"
# The runtime resolves the images the lift named ("Game/EBOOT.elf") from here,
# and writes its log and save data under work/, which is where the player looks
# for them. Neither path is passed on the title's own command line.
export GOWA_ROOT="$ROOT"
export PS3BASE_VFS_DIR="$VFS"
cd "$WORK" || die "no work folder at $WORK"
export PS3BASE_LOG=${PS3BASE_LOG:-info}
# Unset when the player did not pick them, and an unset variable is how the
# runtime says "use my own default": set -u would trip on the export below, so
# they are given their empty value first rather than exported by name.
export GOWA_FULLSCREEN=${GOWA_FULLSCREEN:-} GOWA_RES_SCALE=${GOWA_RES_SCALE:-}
export GOWA_FPS_OSD=${GOWA_FPS_OSD:-} GOWA_AUDIO=${GOWA_AUDIO:-}
export GOWA_ASYNC_SHADERS=${GOWA_ASYNC_SHADERS:-}

exec "$BUILD/ps3base" --no-launcher "$@"
