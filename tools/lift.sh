#!/bin/sh
# lift.sh -- translate the player's EBOOT.elf into C++.
#
# Two manifests matter and only one of them is obvious:
#   - the image manifest names the ELF to lift;
#   - the SPU block manifest lists SPU blocks with their offsets IN THE ELF.
# This title has no SPU code, so its block manifest is empty on purpose. Using
# another title's manifest here is not a harmless mismatch: every line is an
# offset into a different binary.
set -eu
. "$(dirname "$0")/env.sh"

require_file "$GAME/EBOOT.elf"
[ -d "$PS3BASE" ] || die "no runtime at $PS3BASE; set PS3BASE to your ps3base checkout"

note "lifting $GAME/EBOOT.elf into $LIFT"
rm -rf "$LIFT"
mkdir -p "$LIFT"

PKG="$PS3BASE"
OUT="$LIFT" NID="$PKG/ref/nid_db.json" MANIFEST="$ROOT/port/manifests/images-grove.json" \
python3 - "$PKG" "$GAME/EBOOT.elf" "$LIFT" "$ROOT" <<'PY'
import json, os, subprocess, sys

pkg, elf, lift, root = sys.argv[1:5]
images = json.load(open(os.path.join(root, "port", "manifests", "images-grove.json")))

# The manifest's "elf" paths are relative to the manifest's own directory.
base = os.path.join(root, "port", "manifests")
resolved = []
for spec in images:
    spec = dict(spec)
    spec["elf"] = os.path.join(base, spec["elf"])
    if not os.path.isabs(spec["elf"]):
        spec["elf"] = os.path.abspath(spec["elf"])
    resolved.append(spec)
manifest = os.path.join(lift, "images.json")
json.dump(resolved, open(manifest, "w"), indent=1)

out_ppu = os.path.join(lift, "ppu")
subprocess.run(
    [sys.executable, os.path.join(pkg, "recomp", "ppu", "codegen.py"),
     manifest, os.path.join(pkg, "ref", "nid_db.json"), out_ppu],
    check=True)
print("lift: PPU code in", out_ppu)

# No SPU blocks for this title. An empty manifest is the measured truth, not a
# placeholder: the executable ships no SPU images and imports no cellSpurs.
open(os.path.join(lift, "empty_manifest.txt"), "w").close()
out_spu = os.path.join(lift, "spu")
subprocess.run(
    [sys.executable, os.path.join(pkg, "recomp", "spu", "codegen.py"), out_spu,
     os.path.join(lift, "empty_manifest.txt")],
    check=True)
# The runtime's CMake refuses to configure unless the native SPU directory says
# what it holds. For a title with no SPU code the honest answer is an empty
# stamp: "there are none, by design", not a missing directory.
os.makedirs(os.path.join(lift, "spu_native"), exist_ok=True)
open(os.path.join(lift, "spu_native", "generated.txt"), "w").close()
print("lift: SPU registry in", out_spu, "(0 blocks, by design)")
PY

echo "lift: done"
