# Known issues

Measured problems, with what is known about each. Nothing here is a guess presented as a fact.

## A blue triangle near the BMX

On the Grove Street screen there is a blue triangular artefact floating beside the player's BMX. Not diagnosed.
Candidates: a rendering target drawn where it should not be, a mission marker, or a missing texture. Recorded rather
than guessed at.

## Shader files requested and absent

The title opens `/dev_bdvd/PS3_GAME/USRDIR/Shaders/<name>.vert` and `<name>.pix` and gets `ENOENT`. Those files
are not on the disc and not in either `.obb` (the two indexes list 76 and 244 entries; none is a shader). Rendering
still works, so the path is either inactive or the title has a fallback. Unexplained.

## Three imports unimplemented

`cellSysutil::cellVideoOutGetNumberOfDevice`, `cellGame::cellGameGetParamInt` and `cellAudio::cellAudioAddData`
are reached and return an explicit error rather than a fake success. None has blocked progress so far.

## No sound

`cellAudioInit` succeeds, but SDL cannot open an output device in this container. Whether the game's mixer produces
correct audio is untested.

## Frame rate measured only under Xvfb

Every figure in [FEATURES.md](FEATURES.md) was taken with software presentation. The rasterisation is on the GPU
(RTX 4060) but presentation goes through Xvfb, which costs frame time. A real-display measurement is missing.
