# Manifests

`images-grove.json` names the guest images the lifter translates. Paths are relative to this
directory.

Two things are worth knowing before editing it:

- **The first entry is the title.** The runtime loads the first image as the game when no game profile
  names one. Putting a firmware module first boots the firmware instead of the game.
- **Every entry except the first is a firmware module lifted from your own dump.** They are listed
  because the title imports from them; the runtime resolves those imports against the lifted
  module rather than reimplementing them.

`Game/fw/` is git-ignored. This title needs `liblv2`, `libsysmodule`, `libsre`, `libgcm_sys`, `libfs`,
`libvdec` and `libsmvd2`; see `docs/GETTING-FILES.md`.
