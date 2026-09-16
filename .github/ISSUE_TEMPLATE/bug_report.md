---
name: Bug Report
about: Report a packaging bug (build, install, signing or release)
title: "fix(packaging): "
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**Where it happens**
Select the context of the failure:

- [ ] Local build (`make build`)
- [ ] Local install (`make install`)
- [ ] CI validation (`.github/workflows/ci.yml`)
- [ ] CI release (`.github/workflows/release.yml`)
- [ ] Published package (`argvus/packages`)

**To Reproduce**
Steps to reproduce the behavior:

1. Run `make build` (or the failing command)
2. Run `make install`
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Actual behavior**
Paste the command output or error message.

```text

```

**Repository state**

- Commit / tag: e.g. `main@abc1234`, `v0.1.0`
- PKGBUILD involved: `packaging/arch/local/PKGBUILD` / `packaging/arch/ci/PKGBUILD`
- `url` in the CI PKGBUILD: [filled / empty]

**Environment (please complete the following information):**

- OS / distro: [e.g. Arch Linux, EndeavourOS, Manjaro]
- Architecture: [e.g. x86_64, aarch64]
- `pacman` version: [output of `pacman -Q pacman`]
- `pacman-contrib`: [output of `pacman -Q pacman-contrib`]
- Package version built: [e.g. `<pkgname> 0.1.0-1`]

**Additional context**
Add any other context about the problem here (installer behavior, checksum or
GPG signing errors, artifacts left in `build/`, etc.).
