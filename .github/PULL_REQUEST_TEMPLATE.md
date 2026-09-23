# Summary

- <short description of the change and why it is needed>

## Type

- [ ] feat
- [ ] fix
- [ ] docs
- [ ] refactor
- [ ] test
- [ ] ci/build/chore

## Author Checklist

- [ ] `shellcheck tools/sh/pkgbuild_local.sh` passes
- [ ] `cd packaging/arch/ci && makepkg -p PKGBUILD --printsrcinfo >/dev/null` passes
- [ ] `make build` produces the expected `.pkg.tar.zst` in `build/dist/`
- [ ] `sha256sums` does **not** use `SKIP` (only `sha256sums=()` committed)
- [ ] No `build/` artifacts or `PKGBUILD.local` are committed
- [ ] No secrets (`GPG_PRIVATE_KEY`, `GPG_PASSPHRASE`, `GPG_KEY_ID`, `PACKAGES_REPO_TOKEN`) are added or logged
- [ ] `packaging/arch/local/PKGBUILD` and `packaging/arch/ci/PKGBUILD` stay in sync (version, `url`, sources)
- [ ] Conventional commit (`feat:`/`fix:`/`docs:`/`chore:`/`refactor:`/`test:`/`ci:`)

## Validation

- [ ] `make build`
- [ ] `make install`
- [ ] Installed payload verified: `pacman -Ql <pkgname>` / `argvus-hello`

## Notes

- Related issue: `Closes #...`
- Changes to release behavior (signing, `repo-add`, `argvus/packages` publish,
  archive URL format) should be called out for maintainer review.
