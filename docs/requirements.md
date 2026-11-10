# Requirements

## The machine

| | |
|---|---|
| CPU | x86-64 with AVX2 (`x86-64-v3`). Without AVX2 the generated code will not run |
| GPU | a Vulkan 1.1+ capable device. Developed on an NVIDIA RTX 4060 Laptop; AMD and Intel are untested |
| RAM | 8 GB is enough to build and run; the lift is the memory-hungry step |
| Disk | about 4 GB for the lifted sources and the build, plus your own game files |
| Display | a real display is not required to build, but it is to see the game: under Xvfb presentation is software and the frame rate is not representative |

## The software

| | |
|---|---|
| OS | Linux x64 |
| compiler | clang and clang++ (gcc is not supported) |
| build | CMake 3.20+, Ninja |
| language runtime | Python 3.10+ for the tools |
| libraries | SDL3, the Vulkan headers and loader |

## Tested configuration

Everything in [FEATURES.md](FEATURES.md) was measured on Linux x64, clang, an Intel CPU with AVX2 and an NVIDIA
RTX 4060 Laptop GPU. Other configurations should work and are not verified; a report on one is welcome.

## What is not supported

- Windows and macOS. The runtime builds for Linux here; neither of the others has been tried.
- ARM. The generated code targets x86-64.
- Running without your own copy of the game. Nothing in this repository can stand in for it.
