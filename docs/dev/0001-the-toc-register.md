# 0001 -- The TOC register, and why a HLE import must save it

**Date:** 2026-11-10
**Status:** fixed and verified

## Symptom

The title crashed 0.54 s after entry, 82 syscalls in, before presenting a single frame:

```
E crash: signal 11 at 0x...314ea0c, fault 0x...ff898d (guest 0xffff898d) thread main_thread
E crash:   #0 ppu::ld32          runtime/include/ppu/ops.h:43
E crash:   #1 f_0064ee60_body    out/ppu/gta_063.cpp
E crash:   #2 f_0001a844_body    out/ppu/gta_000.cpp
E crash:   #3 f_001568a4_body    out/ppu/gta_013.cpp
E crash:   guest regs: r2=0x1 ...
```

The faulting instruction is `ld32(r2 + -30324)`. With `r2 = 1` the effective address is `0xffff898d`, which is not
mapped. The title's TOC is `0x7855e8`, printed by the loader.

## Two hypotheses, both refuted by measurement

**First: a HLE handler clobbers `r2`.** Instrumentation reported, per call and per import, any change to `r2`.
Result: **zero** changes over 543 indirect transitions and zero across every HLE import. Refuted. The "restore the
caller's TOC after every import" change this hypothesis produced did not alter the crash either, so it was removed
from the tree rather than kept.

**Second: the entry path is wrong.** Also refuted: the entry OPD (`0x77b718`) carries `code = 0x62b7f4`,
`toc = 0x7855e8`, and the game enters its own code 192 times with the correct TOC.

## What the disc actually says

Disassembling the original binary (not the lifted C++) with capstone at `0x18490`:

```
000184d0  bl       0x6fcfdc          ; import stub: cellAudioOutConfigure
000184d4  ld       r2, 0x28(r1)      ; reload the TOC
000184d8  bl       0x6fd4bc          ; import stub: cellAudioInit
000184dc  ld       r2, 0x28(r1)      ; reload the TOC again
000184e0  bl       0x1568a4
```

And the stub it calls, at `0x6fd4bc`:

```
006fd4bc  li       r12, 0
006fd4c0  oris     r12, r12, 0x75
006fd4c4  lwz      r12, 0x544(r12)
006fd4c8  std      r2, 0x28(r1)      ; <-- the save, in the STUB
006fd4cc  lwz      r0, 0(r12)
006fd4d0  lwz      r2, 4(r12)
006fd4d4  mtctr    r0
006fd4d8  bctr
```

The save is in the **stub**, not in the caller. A lifter replaces the stub entirely with a call of its own, so that
`std` stops happening — and the caller's `ld r2, 0x28(r1)` then reads whatever the frame last held. Measured value
at that point: `1`, which is exactly the `r2` seen in the crash dump.

## Fix

`runtime/src/ppu_runtime.cpp`: perform `std r2, 0x28(r1)` at the top of the import dispatch, for **both** the LLE and
the HLE path, before either runs. The LLE path was already doing it; the HLE path never did.

```c
{
    const uint32_t frame_sp = static_cast<uint32_t>(ctx.gpr[1]);
    st64(base, frame_sp + 0x28, ctx.gpr[2]);
}
```

## Proof

After the fix: zero TOC mismatches across a full session, the first frame is presented, the title builds
`CdStream` and `textdb`, opens `PS3DataMain.obb.idx` then `PS3Data.obb`, and reaches `cellSync2`. The game is in
game.

## The lesson worth keeping

The generic-looking question ("does a HLE clobber r2?") produced nothing; the specific one ("what does the disc do
between the call and the reload?") produced the answer in one disassembly. When a register holds a wrong value, read
the original instructions around its last write, not the C++ around its last use.
