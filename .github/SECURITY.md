# Security

## Reporting

Report privately through the repository's Security tab rather than in a public issue, for anything that could get
someone's machine compromised or their files exposed.

## Scope

This port runs lifted code from **your own** game files and reimplements system libraries. Two things matter:

- **The runtime executes guest code natively.** A malformed game file is not a supported input; the port is built for
  your own, unmodified disc.
- **Nothing here contacts the network.** The port and its scripts make no connection of their own.

## What is not a security issue

A crash on a file that is not your own unmodified disc. A wrong rendering result. A missing feature.
