#!/bin/sh
# prepare.sh -- the windowless setup step: check the player's disc, lift and build.
#
# RecompLauncher runs this from recomplauncher.json before the first start, and
# again whenever the player picks a different copy. It prints "progress 0.4 ..."
# lines on stdout, everything else on stderr, opens no window, and exits 0 only
# when the port is ready to start.
#
#   tools/prepare.sh --game <path>
#
# <path> is the player's disc folder: the one that contains PS3_GAME. Nothing is
# copied out of it; tools/play.sh --game points the game at it where it lies.
#
# Without --game nothing here runs: tools/install.sh stays the interactive way.
set -eu
. "$(dirname "$0")/env.sh"

progress() { printf 'progress %s %s\n' "$1" "$2"; }

usage() {
    sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'
}

game=""
while [ $# -gt 0 ]; do
    case "$1" in
        --game) [ $# -ge 2 ] || die "--game needs a path"; game=$2; shift 2 ;;
        --game=*) game=${1#--game=}; shift ;;
        -h|--help) usage; exit 0 ;;
        *) die "unknown argument $1 (try --help)" ;;
    esac
done
[ -n "$game" ] || die "--game <path> is required: the folder that contains PS3_GAME"

# ---------------------------------------------------------- the player's copy
# Accept the disc root, or PS3_GAME itself, or its USRDIR: a player who browses
# to their files picks whichever of the three they see first, and all three name
# the same disc.
[ -d "$game" ] || die "no folder at $game"
case "$(basename "$game")" in
    PS3_GAME)    disc=$(cd "$game/.." && pwd) ;;
    USRDIR)      disc=$(cd "$game/../.." && pwd) ;;
    *)           disc=$(cd "$game" && pwd) ;;
esac
[ -d "$disc/PS3_GAME/USRDIR" ] || die "$game is not a PS3 disc folder: expected PS3_GAME/USRDIR in $disc"
[ -f "$disc/PS3_GAME/PARAM.SFO" ] || die "no PS3_GAME/PARAM.SFO in $disc: that folder is not a PS3 disc"

progress 0.03 "Reading your disc folder"
title_id=$(python3 - "$disc/PS3_GAME/PARAM.SFO" <<'PY'
import sys
# PARAM.SFO: a 0x14-byte header (magic, version, key table offset, data table
# offset, entry count), then one 16-byte entry per key -- key offset, format,
# length, max length, data offset -- with the key strings and the values at the
# two offsets the header gives. Offsets are relative to their own table.
data = open(sys.argv[1], "rb").read()
try:
    keys = int.from_bytes(data[8:12], "little")
    values = int.from_bytes(data[12:16], "little")
    count = int.from_bytes(data[16:20], "little")
    for i in range(count):
        e = 0x14 + i * 16
        key = keys + int.from_bytes(data[e:e + 2], "little")
        name = data[key:data.index(b"\0", key)]
        if name != b"TITLE_ID":
            continue
        length = int.from_bytes(data[e + 4:e + 8], "little")
        at = values + int.from_bytes(data[e + 12:e + 16], "little")
        print(data[at:at + length].rstrip(b"\0").decode("ascii", "replace"))
        break
except (ValueError, IndexError):
    pass
PY
)
# The port lifts one revision of one release. Saying so here is kinder than a
# mismatch three hours into a build.
if [ -n "$title_id" ] && [ "$title_id" != "BLES02219" ]; then
    die "this is $title_id. Project Grove is built from BLES02219 (Europe, v01.02) and no other release."
fi
progress 0.05 "Your copy is ${title_id:-BLES02219}"

# The four archives, checked the same way tools/setup-vfs.sh checks them, so a
# bad copy fails here in seconds rather than deep inside the build.
usrdir="$disc/PS3_GAME/USRDIR"
for f in PS3DataMain.obb PS3DataMain.obb.idx PS3Data.obb PS3Data.obb.idx \
         PS3DataText.zip PS3DataText.zip.idx PS3DataText2.zip PS3DataText2.zip.idx; do
    [ -f "$usrdir/$f" ] || die "$usrdir/$f is missing: your disc folder is incomplete"
done
for f in PS3DataMain.obb PS3Data.obb PS3DataText.zip PS3DataText2.zip; do
    magic=$(od -An -tx1 -N4 "$usrdir/$f" | tr -d ' \n')
    [ "$magic" = "504b0304" ] || die "$f does not start with a ZIP signature (got $magic): that copy is truncated or wrong"
done
progress 0.08 "Your four data archives are complete"

# ----------------------------------------------------------- what you bring
# Game/ holds the files the disc cannot supply because they are decrypted: the
# executable, and the firmware modules the lift links. Both are the player's
# own, made with their own tools from their own copy; docs/GETTING-FILES.md
# says what each one is. This repository ships neither.
missing=""
[ -f "$GAME/EBOOT.elf" ] || missing="$missing Game/EBOOT.elf"
for m in liblv2 libsysmodule libsre libgcm_sys libfs libvdec libsmvd2; do
    [ -f "$GAME/fw/$m.elf" ] || missing="$missing Game/fw/$m.elf"
done
if [ -n "$missing" ]; then
    cat >&2 <<EOF
prepare: your copy needs files the disc cannot provide, and these are missing:
EOF
    for m in $missing; do echo "    $m" >&2; done
    cat >&2 <<EOF

  They are your own files: the decrypted executable and the firmware modules the
  lift links. docs/GETTING-FILES.md says what each one is and where to put it.
  Nothing here can stand in for them, and this project never ships them.
EOF
    exit 1
fi

# ---------------------------------------------------------- the runtime tree
# The port compiles against a separate checkout of the ps3base runtime.
if [ ! -d "$PS3BASE" ]; then
    cat >&2 <<EOF
prepare: no runtime checkout at $PS3BASE.

  Project Grove's code compiles against the ps3base runtime, which is a
  separate checkout rather than part of this download. Put it there, or set
  PS3BASE to wherever yours is:

      git clone https://github.com/Noext/ps3base2 third_party/ps3base
      export PS3BASE=\$PWD/third_party/ps3base

  Nothing here fetches it for you: this port makes no network connection you
  did not ask for. docs/BUILDING.md says the same for the interactive install.
EOF
    exit 1
fi

# ------------------------------------------------ already set up for this copy?
# The launcher runs this again when the player changes their copy. Re-lifting
# and recompiling 22,000 functions to answer "is it still the same disc?" would
# be most of an hour of the player's time, so the fingerprint decides.
stamp="$WORK/.prepare-stamp"
fingerprint() {
    {
        printf '%s\n' "$disc"
        for f in PS3DataMain.obb PS3Data.obb PS3DataText.zip PS3DataText2.zip; do
            printf '%s %s\n' "$f" "$(stat -c '%s' "$usrdir/$f")"
        done
        sha256sum "$GAME/EBOOT.elf" | cut -d' ' -f1
        for m in liblv2 libsysmodule libsre libgcm_sys libfs libvdec libsmvd2; do
            sha256sum "$GAME/fw/$m.elf" | cut -d' ' -f1
        done
    } | sha256sum | cut -d' ' -f1
}
want=$(fingerprint)
if [ -f "$stamp" ] && [ "$(cat "$stamp")" = "$want" ] && [ -x "$BUILD/ps3base" ]; then
    progress 1 "Already set up from this copy"
    exit 0
fi

# ------------------------------------------------------------------- the work
# The folder the game writes to: saves and the console's own home directory. The
# disc is read where it lies, so nothing here copies the player's 2.2 GB.
mkdir -p "$VFS/dev_hdd0/home/00000001/savedata" "$VFS/dev_hdd1" "$VFS/dev_usb000"

progress 0.12 "Translating the game's code (this is one of the long steps)"
"$ROOT/tools/lift.sh" >&2
progress 0.55 "Compiling Project Grove (this is the other long step)"
"$ROOT/tools/build.sh" >&2

printf '%s\n' "$want" >"$stamp"
# Where the disc is, for a start that is given no path of its own.
printf '%s\n' "$disc" >"$WORK/.disc-path"
progress 1 "Ready to play"
