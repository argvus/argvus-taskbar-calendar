# Contributing

Thanks for your interest in contributing to this ARGVUS project. This document
outlines the guidelines for reporting issues and submitting changes. Short
version: be clear, be respectful, and keep changes focused and reviewable.

Please also read [DEVELOPMENT.md](DEVELOPMENT.md) for the build, signing and
release workflow.

## Code of Conduct

By participating, you agree to abide by the
[Contributor Covenant v2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
Instances of unacceptable behavior may be reported to the project maintainers.

## What to contribute

- Bug reports and reproductions
- Documentation improvements (`README.md`, `DEVELOPMENT.md`, this file)
- Packaging fixes (PKGBUILDs, build tooling)
- Anything in the issue tracker labeled `good first issue` or `help wanted`

Please open an issue first for larger changes or anything that alters behavior,
so the approach can be agreed on before work starts.

## Reporting bugs

- Search the issue tracker first to avoid duplicates.
- Use a clear, descriptive title.
- Include, when relevant:
  - Distro / Arch version and architecture (`pacman -Q core/pacman`)
  - Commands run and their output
  - `make build` log output
  - The relevant version/tag you are on
- Label the issue with `bug` if you can.

## Feature requests

- Open an issue labeled `enhancement`, describing the problem being solved and
  a suggested approach.
- Keep the scope small; large proposals are easier to review in pieces.

## Development flow

1. Read [DEVELOPMENT.md](DEVELOPMENT.md) and set up your environment.

2. Create a branch from `main`:

   ```sh
   git checkout -b feat/describe-the-change
   ```

   Branch naming: `fix/...`, `feat/...`, `docs/...`, `chore/...`,
   `refactor/...`.

3. Make small, focused commits following
   [Conventional Commits](https://www.conventionalcommits.org/):

   ```text
   feat(pkgbuild): add missing runtime dependency
   fix(release): validate source checksum before building
   docs: explain GitHub secrets setup
   ```

4. Validate locally before pushing:

   ```sh
   make validate
   make build
   ```

   `ci.yml` runs the same checks (plus `namcap` and cspell) on push/PR.

5. Push and open a pull request against `main`.

### Pull requests

- Reference the issue it fixes: `Closes #123`.
- Keep the diff minimal; do not mix unrelated changes.
- Do not commit build outputs (`build/`) or generated `PKGBUILD.local`.
- Rebase on `main` before requesting review if needed.
- One reviewer approval is required before merge (`requires-code-owner` / repo
  settings may apply).
- Squash-merge keeps history clean.

### Checksums

The PKGBUILDs must **never** contain `sha256sums=('SKIP')`. Keep `sha256sums=()`
empty in the repository; the build generates and validates the real digest.
See [DEVELOPMENT.md](DEVELOPMENT.md#checksums-signing-and-validation).

## Signing and secrets (maintainers)

Creating a release requires the following GitHub secrets:

| Secret | Purpose |
| --- | --- |
| `GPG_PRIVATE_KEY` | private key used to sign packages and the repo database |
| `GPG_PASSPHRASE` | passphrase of the GPG key (empty if none) |
| `PACKAGES_REPO_TOKEN` | PAT with `contents:write` on `argvus/packages` |

Only maintainers manage these. See
[DEVELOPMENT.md](DEVELOPMENT.md#configure-the-github-secrets).

## Releasing

Releases are cut from `main` by pushing a tag:

```sh
git tag v0.1.0
git push origin v0.1.0
```

`release.yml` builds, signs and publishes the package to `argvus/packages`.
Make sure `url` is set correctly in `packaging/arch/ci/PKGBUILD` before
tagging.

## Style and tooling

- Follow `base-devel` packager conventions and the existing PKGBUILD style.
- Shell scripts: `set -euo pipefail`, checked with `shellcheck`.
- Respect `.editorconfig`.
- Keep the cspell workspace dictionary (`.cspell/`) updated when adding
  technical terms, if spell-checking is enabled.

## License

Contributions are accepted under the terms of the
[GPL-3.0 License](LICENSE) that covers this project.
