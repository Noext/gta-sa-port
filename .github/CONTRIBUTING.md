# Contributing

Thanks for looking. This is a fan port; the rules exist because the project cannot ship anything that is not ours.

## Before you open a pull request

- `tools/check-tree.sh` must print `check-tree: clean`. It refuses game binaries by name **and** by magic number, so
  a renamed file does not slip through.
- No game material. Not in a commit, not in an attachment, not pasted into an issue: no disc file, no "decrypted
  EBOOT so you can reproduce", no archive, no save, no key, no firmware module.
- A fix to the runtime comes with a note in `docs/dev/` saying what you measured, what you tried that did not work,
  and what proves the fix. A refuted hypothesis written down is worth more than a confident one.
- Credit what you absorbed. If a change comes from an upstream patch, a fork or another port, say so in the commit
  message and add the credit to `NOTICE.md`.

## Reporting a problem

Include: the commit you built, your `PS3BASE_LOG=info` log from startup to the problem, what you expected, and what
happened. If the game renders wrongly, a screenshot of the window beats a description. Do not attach game files.

## What is welcome

- tests on other GPUs, CPUs and displays
- audio output confirmation on a machine with a sound device
- fixes to the HLE modules listed in [docs/KNOWN_ISSUES.md](../docs/KNOWN_ISSUES.md)
