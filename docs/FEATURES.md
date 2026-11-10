# Features

What works, measured. Anything unmeasured is marked so.

## Works

| | |
|---|---|
| Boot | the title loads, registers its system modules, mounts its disc |
| Legal screen | drawn by the title, text legible |
| Title screen | drawn, animated |
| Intro cutscene | plays |
| Gameplay | **in game at Grove Street**: the player, the world, and the HUD (clock, money, health, radar) all render |
| Rendering | about 22,000 draws and 1.9 million vertices per session, 3 pipelines |

## Partial

| | |
|---|---|
| Frame rate | 11 to 26 fps depending on the scene, measured **under Xvfb** (software presentation). Not measured on a real display |
| Audio | `cellAudio` initialises but this machine has no audio device, so nothing is heard. Untested with one |
| Shaders | the title asks for `Shaders/*.vert` and `*.pix` files that are absent from the disc and from the two `.obb` archives; rendering proceeds anyway |

## Not reached

| | |
|---|---|
| Missions | not played past the opening |
| Saves | not exercised |
| Trophies | `sceNpTrophy` is imported; behaviour unmeasured |
| Settings menu | not exercised |

## Not present in this title

Confirmed absent from the import table, so out of scope: `cellSpurs*`, `cellPngDec`, `cellJpgDec`, `cellFont`,
`cellOskDialog`, `cellUserInfo`, `cellVdec`, `cellNetCtl`, `sys_net`, `sceNp`/`sceNp2`.
