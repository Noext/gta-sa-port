#!/bin/sh
# build.sh -- compile the lifted game and the runtime.
set -eu
. "$(dirname "$0")/env.sh"

[ -d "$LIFT/ppu" ] || die "no lifted code in $LIFT; run tools/lift.sh first"
[ -d "$PS3BASE" ] || die "no runtime at $PS3BASE"

note "configuring in $BUILD"
cmake -S "$PS3BASE" -B "$BUILD" -G Ninja \
      -DCMAKE_BUILD_TYPE=RelWithDebInfo \
      -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ \
      -DPS3BASE_GENERATED_DIR="$LIFT/ppu" \
      -DGOWA_SPU_GENERATED_DIR="$LIFT/spu" \
      -DPS3BASE_SPU_NATIVE_GEN_DIR="$LIFT/spu_native"

note "building"
cmake --build "$BUILD" -j "$JOBS" --target ps3base
echo "build: $BUILD/ps3base"
