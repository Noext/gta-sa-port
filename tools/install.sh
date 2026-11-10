#!/bin/sh
# install.sh -- the one command: check your files, set up, lift, build.
set -eu
. "$(dirname "$0")/env.sh"

echo "Project Grove -- one-command build"
echo
if [ ! -f "$GAME/EBOOT.elf" ]; then
    echo "Put your own files in $GAME first:"
    echo "  EBOOT.elf and the four data archives with their .idx files"
    echo "  see docs/GETTING-FILES.md"
    exit 2
fi
[ -n "${PS3BASE:-}" ] || die "set PS3BASE to your ps3base checkout"

"$ROOT/tools/setup-vfs.sh"
"$ROOT/tools/lift.sh"
"$ROOT/tools/build.sh"
echo
echo "done. tools/play.sh plays."
