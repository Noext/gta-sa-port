# 0004 -- How to judge a run, and two ways I got it wrong

**Date:** 2026-11-10
**Status:** rules that cost a round trip each

## The mechanical verdict

A run is **alive** when the process reaches its budget with the flip counter rising, and **crashed** when it ends
early on a signal. Never grep for the word "crash": one handled page fault prints a dozen stack lines and looks like
a dozen crashes.

```
exit code  : 124 means the budget was reached (good); 139 is a SIGSEGV
flips      : rsx frame flips; 0 means the renderer never ran
```

## Mistake 1: counting "nonblack" pixels on a GPU dump

The frame dumper reported `nonblack 0/921600 (0.00%)` on every frame while the screen plainly showed a legible menu
at 53 fps. The dump reads the presented buffer, and **under Xvfb's software presentation it is not the buffer that
reaches the screen**. The number was measuring the wrong thing, and I read it as "nothing is drawn".

The only judge that stood up was a capture of the window itself:

```sh
W=$(DISPLAY=:0 xdotool search --name 'San Andreas' | tail -1)
DISPLAY=:0 import -window "$W" shot.png
```

## Mistake 2: putting a timeout on a run someone is watching

Every run was launched as `timeout N ./ps3base`. The log then said:

```
gpu: window closed, exiting
```

at 74.99 s and 89.99 s -- exactly the two budgets. The window the operator was playing in was closed by my own
command, not by a crash.

**A run you measure is bounded. A run you watch is not.**

```sh
nohup setsid env DISPLAY=:0 ./ps3base --no-launcher > run.log 2>&1 < /dev/null &
disown
```

Kill by process group (`kill -9 -- -$PID`), never by image name: `pkill -9 -x ps3base` kills other people's runs.

## Instrumentation that paid for itself

`PS3BASE_TOC_TRACE` was added to report, at three boundaries, whether `r2` still matches the calling image's TOC: on
each indirect call, on each import, and around each lifted call. It is inert unless set. It is what turned "a HLE
somewhere is wrong" into "the save in the import stub never happens" in one run.
