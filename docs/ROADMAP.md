# Roadmap

Ordered by what unblocks the most, not by what is easiest.

## Now

1. **Audio.** Get `cellAudio` to produce sound on a machine with a device, and confirm the game's own mixer output.
2. **The blue triangle.** Diagnose it rather than leaving it in a screenshot.
3. **The three unimplemented imports.** Replace the explicit errors with real behaviour.

## Next

4. **Play the opening mission to its end.** The game is in game; it has not been played through a mission.
5. **Saves.** `cellSaveData` is imported once (`cellSaveDataListDelete`); the load/save path is unexercised.
6. **A real display.** Measure the frame rate without Xvfb's software presentation.

## Later

7. **Windows.** The runtime builds there; this port has not been tried on it.
8. **Widescreen and resolution options.** Not implemented.
9. **Performance.** Profile on an idle machine, on real presentation, and name the bottlenecks instead of guessing.

## Not a goal

Rewriting the game's logic. The code that runs is the disc's own code.
