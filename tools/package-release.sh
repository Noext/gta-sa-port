#!/bin/sh
# package-release.sh -- make the zip RecompLauncher installs, with recomplauncher.json on top.
#
#   tools/package-release.sh [--out DIR]
#
# The zip holds the port, not the game: sources, patches, tools and docs, and
# recomplauncher.json next to the scripts that use it. The player's own files
# are read at setup time by tools/prepare.sh, which the launcher runs, and the
# game is lifted and compiled on their machine. Nothing from Game/ or work/ is
# ever in it.
#
# The name carries the system and the processor, one file per system, because
# that is how the launcher tells which build is for the player's PC.
set -eu
. "$(dirname "$0")/env.sh"

out="$ROOT/out"
while [ $# -gt 0 ]; do
    case "$1" in
        --out) [ $# -ge 2 ] || die "--out needs a directory"; out=$2; shift 2 ;;
        *) die "unknown argument $1" ;;
    esac
done

version=$(cat "$ROOT/VERSION")
name="ProjectGrove-v$version-Linux-x64"
stage="$out/$name"

note "checking the tree"
"$ROOT/tools/check-tree.sh"

note "building the release in $stage"
rm -rf "$stage"
mkdir -p "$stage"
# Everything the port is, and nothing the player brings. .git is not part of a
# release; .gitignore and .gitattributes are, so a checkout made from the zip
# behaves like a clone.
(cd "$ROOT" && tar -cf - \
    --exclude='./Game' --exclude='./work' --exclude='./out' --exclude='./out-*' \
    --exclude='./.git' --exclude='./third_party/ps3base' \
    --exclude='__pycache__' \
    .) | (cd "$stage" && tar -xf -)

# The two things the launcher reads, checked here rather than by a player: the
# file has to be at the top of the zip, and it has to be valid JSON.
[ -f "$stage/recomplauncher.json" ] || die "recomplauncher.json is not at the top of the release"
python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$stage/recomplauncher.json" ||
    die "recomplauncher.json is not valid JSON"
for f in tools/prepare.sh tools/play.sh; do
    [ -x "$stage/$f" ] || die "$f is not executable in the release"
done

note "writing $out/$name.zip"
rm -f "$out/$name.zip"
(cd "$out" && zip -qr "$name.zip" "$name")
echo "package-release: $out/$name.zip"
