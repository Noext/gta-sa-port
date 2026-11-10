# How it works

Project Grove runs the game's own PowerPC code natively. Nothing interprets a CPU at play time, and no game logic is
rewritten: the code that runs is the code on the disc, translated to C++ ahead of time.

## The three layers

**Lifted game code.** `tools/lift.sh` reads your decrypted `EBOOT.elf` and emits one C++ function per PowerPC
function: 20,082 of them for BLES02219 v01.02, in about 71 translation units. clang compiles that into the program.
A lifted function looks like the original instruction stream, one C statement per instruction, which is why a fault
in it can be read against the disc's own disassembly.

**The runtime.** Around the lifted code sits a runtime that provides what the game expects from the console's system
software: LV2 syscalls (threads, memory, synchronisation, files), the RSX graphics command stream replayed on Vulkan,
and the system libraries the title imports. Some of those libraries are themselves lifted from your own firmware
(`liblv2`, `libfs`, `libgcm_sys`, `libsre`); the rest are reimplemented.

**The port's own code** (`port/grove/`) sits on top: boot, platform glue, and the corrections this title needs that
are not general enough to belong in the runtime.

## PowerPC calling convention, and the one register that bites

PPU code follows the 64-bit PowerPC ABI. `r2` is the **table of contents** register: globals are reached as
`[r2 + offset]` rather than by absolute address. A function saves the caller's `r2` in its own frame and restores it
after a call.

Import stubs follow a fixed shape on this disc:

```
li    r12, 0
oris  r12, r12, 0x75
lwz   r12, 0xNNN(r12)     ; the import table entry
std   r2, 0x28(r1)        ; save the CALLER's TOC into the caller's frame
lwz   r0, 0(r12)
lwz   r2, 4(r12)          ; load the callee's TOC
mtctr r0
bctr
```

A lifter replaces that whole stub with a call of its own. The `std` above is then the caller's problem, not the
callee's: if the replacement does not perform it, the caller's next `ld r2, 0x28(r1)` reads whatever the previous
frame left there. That was this port's first real wall, and it is described in [dev/0001](dev/0001-the-toc-register.md).

## Data

The game ships its content in four archives beside the executable: `PS3DataMain.obb` (1.48 GB), `PS3Data.obb`
(709 MB), `PS3DataText.zip` and `PS3DataText2.zip`, each with a paired `.idx`. They are **ordinary stored ZIP
archives**; the `.idx` is a flat index (`u32 count`, then `u32 offset, u32 size, u16 name_len, name`). The runtime
serves the bytes and the title parses them itself, through its own file system code. See
[dev/0002](dev/0002-the-data-archives.md).

## SPU

There is none. This title imports no `cellSpurs` function and ships no SPU programs in its executable; the lift
pipeline accepts an empty block manifest and still writes the registry the build expects. That removes an entire
class of problem that other PS3 ports spend most of their time on.
