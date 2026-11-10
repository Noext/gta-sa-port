# shellcheck shell=sh
# Paths shared by the tools. Source this; do not run it.
#
# Everything the tools make lives under work/, and everything the player brings
# lives under Game/. Both are git-ignored, so a build can never leak game
# material into a commit.

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
export ROOT

# The port's runtime checkout. In this repository it is the sibling tree the
# patches in port/patches are meant for; set PS3BASE to point elsewhere.
PS3BASE=${PS3BASE:-"$ROOT/third_party/ps3base"}
export PS3BASE

GAME=${GAME:-"$ROOT/Game"}
WORK=${WORK:-"$ROOT/work"}
LIFT="$WORK/lift"
VFS="$WORK/vfs"
BUILD="$WORK/build"
export GAME WORK LIFT VFS BUILD

die() { echo "error: $*" >&2; exit 1; }
note() { echo "== $*"; }

# Cap parallelism: this machine is shared and the repository's own instructions
# say -j 8 is the ceiling.
JOBS=${JOBS:-8}
export JOBS

require_file() { [ -f "$1" ] || die "missing $1 -- see docs/GETTING-FILES.md"; }
