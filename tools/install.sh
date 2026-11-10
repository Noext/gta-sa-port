#!/bin/sh
# install.sh -- the one command: check your files, set up, lift, build.
#
# Tools/prepare.sh is the same steps without the questions, which is what
# RecompLauncher runs as the setup step; this one is for a person, so it says
# what it expects before it starts and what it made when it finishes.
set -eu
. "$(dirname "$0")/env.sh"

echo "Project Grove -- one-command build"
echo
if [ ! -f "$GAME/EBOOT.elf" ]; then
    echo "Put your own files in $GAME first:"
    echo "  EBOOT.elf, the four data archives with their .idx files, and fw/ with the seven"
    echo "  firmware modules the title imports from"
    echo "  see docs/GETTING-FILES.md"
    exit 2
fi
for m in liblv2 libsysmodule libsre libgcm_sys libfs libvdec libsmvd2; do
    [ -f "$GAME/fw/$m.elf" ] || {
        echo "missing $GAME/fw/$m.elf: the lift needs the firmware modules" >&2
        echo "see docs/GETTING-FILES.md" >&2
        exit 2
    }
done
[ -d "$PS3BASE/recomp/ppu" ] || die "no runtime at $PS3BASE; set PS3BASE to your ps3base checkout (docs/BUILDING.md)"

"$ROOT/tools/setup-vfs.sh"
"$ROOT/tools/lift.sh"
"$ROOT/tools/build.sh"
echo
echo "done. tools/play.sh plays, tools/play.sh --game <disc folder> plays straight from a disc."
