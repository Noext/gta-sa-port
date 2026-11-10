#!/bin/sh
# play.sh -- run the game in a window.
#
# Deliberately NOT wrapped in a timeout: a run you watch must not be closed by
# its own launcher. Kill it by process group when you are done.
set -eu
. "$(dirname "$0")/env.sh"

[ -x "$BUILD/ps3base" ] || die "no binary at $BUILD/ps3base; run tools/build.sh first"
[ -d "$VFS/dev_bdvd" ] || die "no VFS at $VFS; run tools/setup-vfs.sh first"

export PS3BASE_DISC_DIR="$VFS/dev_bdvd"
export PS3BASE_LOG=${PS3BASE_LOG:-info}
exec "$BUILD/ps3base" --no-launcher "$@"
