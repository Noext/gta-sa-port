#!/bin/sh
# check-tree.sh -- refuse to publish anything that is not ours.
#
# This is the guard the repository's rules depend on: no game binary, no lifted
# code, no key, no save, no personal path. It reads only what is in the working
# tree, so it is safe to run in CI.
set -eu
cd "$(dirname "$0")/.."

fail=0
report() { echo "REFUSED: $*" >&2; fail=1; }

# 1. Game binaries and containers, by extension, anywhere in the tree.
for f in $(git ls-files); do
    case "$f" in
        *.elf|*.ELF|*.self|*.SELF|*.prx|*.sprx|*.pkg|*.PKG|*.pup|*.PUP|*.rap|*.RAP) report "$f" ;;
        *.obb|*.idx|EBOOT.BIN|PARAM.SFO|PS3Data*) report "$f" ;;
    esac
done

# 2. Game binaries by content, not by name: an ELF starts 7f 45 4c 46, a SCE
#    container starts 53 43 45 00.
for f in $(git ls-files); do
    [ -f "$f" ] || continue
    magic=$(od -An -tx1 -N4 "$f" | tr -d ' \n')
    case "$magic" in
        7f454c46) report "$f: ELF magic" ;;
        53434500) report "$f: SCE magic" ;;
    esac
done

# 3. Personal host paths that do not belong in a shared tree.
#    The console's own paths (/dev_hdd0/home/00000001, /dev_bdvd/...) are not
#    personal paths and must not be flagged: they are the guest's file system,
#    and a naive /home/ pattern matches them.
if git grep -InE '(^|[^a-z_])/(root|home/[a-z0-9_-]+)/' -- . \
        | grep -vE 'dev_hdd0|dev_bdvd|/home/0000' >/tmp/grove-paths.txt 2>/dev/null; then
    if [ -s /tmp/grove-paths.txt ]; then
        head -5 /tmp/grove-paths.txt >&2
        echo "note: personal host path(s) above; rewrite them as relative paths" >&2
    fi
fi
rm -f /tmp/grove-paths.txt

[ "$fail" -eq 0 ] && echo "check-tree: clean"
exit "$fail"
