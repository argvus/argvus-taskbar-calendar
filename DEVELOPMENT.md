# Development

Guide for developers who want to install, build, compile and publish this
package (part of the [ARGVUS](https://gitlab.com/argvus/) organization).

## Project layout

```text
packaging/
  arch/
    ci/        PKGBUILD used by GitHub Actions (release built from a tag)
    local/     PKGBUILD used for local builds (from the working tree)
crates/        Rust workspace crates (application binary)
tools/
  sh/
    pkgbuild_local.sh   source archive and makepkg driver (make package)
build/         build outputs (git-ignored)
  artifacts/   source .tar.gz + src/ + pkg/ (kept for inspection)
  dist/        final .pkg.tar.zst (ready to install / publish)
.github/workflows/
  ci.yml       validates PKGBUILDs (push/PR)
  release.yml  build + signing + publish to argvus/packages (tags v*)
```

## Prerequisites (development machine)

Arch-based system with `make`, `git`, `cargo`, `gnupg` and the `base-devel`
group.

```sh
sudo pacman -S --needed base-devel cargo git gnupg make pacman-contrib shellcheck
```

- `pacman-contrib` provides `updpkgsums` (regenerates PKGBUILD checksums).
- `shellcheck` is used to validate `pkgbuild_local.sh`.
- Optional: `namcap` (package linting) and `git-cliff` (changelog generation,
  `make changelog`). Spellchecking runs in CI with cspell (`cspell.json`).

## Local build

```sh
make check
make package
```

What happens:

1. The script creates `build/artifacts/<pkgname>-<pkgver>.tar.gz` from the
   working tree, excluding VCS data and generated build outputs.
2. The archive checksum is injected into a temporary `PKGBUILD.local`, which
   is removed automatically when the build finishes.
3. `makepkg` runs `cargo build --release --locked`, the workspace tests, and
   the package installation steps with `PKGDEST` set to `build/dist`.

Result:

```text
build/dist/<pkgname>-<pkgver>-1-x86_64.pkg.tar.zst # ready-to-use package
build/artifacts/...                               # source tar.gz + src/ + pkg/
```

Install the locally built package:

```sh
make install
```

Clean build outputs:

```sh
make clean
```

## Validation

```sh
make validate   # shellcheck + PKGBUILD lint (makepkg --printsrcinfo)
make lint       # shellcheck only
```

`ci.yml` runs the Rust checks, metadata validation, a complete local package
build, `namcap` on both PKGBUILDs and the resulting package, and a cspell
spellcheck (config in `cspell.json`, dictionary in `.cspell/`).

## Checksums, signing and validation

- There is no `SKIP`: `sha256sums` is always a real digest, computed at build
  time (local) or via `updpkgsums` (release CI).
- Releases are GPG-signed (package `.sig`, `argvus.db.tar.gz`,
  `argvus.files.tar.gz`, `argvus.db`, `argvus.files`).
- Keep `sha256sums=()` **empty** in the repository (no `SKIP` in the PKGBUILD
  line): the local build computes it and release CI runs `updpkgsums`.

## Prepare the GPG key

Generate a dedicated key (e.g. for `argvus/packages`):

```sh
gpg --full-generate-key            # RSA 4096, no expiry recommended
gpg --list-secret-keys --with-colons | grep ^sec:   # note the KEY_ID
```

Export the private key in ASCII-armored form (this is what the workflow
imports):

```sh
gpg --armor --export-secret-keys KEY_ID
```

## Configure the GitHub secrets

In **Settings → Secrets and variables → Actions** of the repository:

| Secret | Value |
| --- | --- |
| `GPG_PRIVATE_KEY` | output of `gpg --armor --export-secret-keys KEY_ID` (full PEM block) |
| `GPG_PASSPHRASE` | passphrase of the key (if it has one) |
| `PACKAGES_REPO_TOKEN` | PAT with `contents:write` scope on the `argvus/packages` repo |

If the key has no passphrase, leave `GPG_PASSPHRASE` empty (the workflow
signs without it).

## Publish a release

1. Fill in the repository metadata in both PKGBUILDs:
   - GitHub: `url="https://github.com/argvus/argvus-taskbar-calendar"` (the source uses
     `${url}/archive/refs/tags/v${pkgver}.tar.gz`).
   - GitLab: adjust `source=` only if the repository is moved away from GitHub.
2. Check versions/metadata in `packaging/arch/local/PKGBUILD` and
   `packaging/arch/ci/PKGBUILD`.
3. Generate and commit the changelog (see
   [Changelog](#changelog-changelogmd)).
4. Create and push the tag:

   ```sh
   git tag v0.1.0
   git push origin v0.1.0
   ```

5. `release.yml` runs: `updpkgsums` (validates the source) → `makepkg`
   (produces the `.zst`) → GPG signing → `actions/upload-artifact` →
   `repo-add` → commit/push in `argvus/packages` (`public/arch/x86_64`).

## Changelog (`CHANGELOG.md`)

`CHANGELOG.md` is generated from the git history
([Conventional Commits](CONTRIBUTING.md#development-flow)) with
[git-cliff](https://git-cliff.org):

```sh
make changelog    # = git-cliff -o CHANGELOG.md
```

Run it **before tagging a release**:

```sh
# 1. commit conventional commits on main (feat:, fix:, docs:, ...)

# 2. generate the changelog up to the pending commits
make changelog

# 3. commit the regenerated CHANGELOG.md
git add CHANGELOG.md
git commit -m "docs(changelog): update for v0.1.0"

# 4. create and push the tag (triggers release.yml)
git tag v0.1.0
git push origin v0.1.0
```

How it behaves:

- `git-cliff` builds the `[Unreleased]` section from commits **since the last
  tag**. With no tags yet, everything lands under `[Unreleased]`.
- If you generate **after** tagging, the new commits are already attributed to
  the version; the dated entry only settles on the next run. Generating before
  tagging keeps the flow clean: `[Unreleased]` → commit → tag → next cycle the
  section becomes `[0.1.0] - <date>` automatically.

Useful tools:

```sh
git-cliff --unreleased --strip header   # preview only the pending changes
git-cliff --bump                        # suggest the next version (semver)
```

> The changelog is generated from the git history, so a freshly initialized
> repository needs at least one commit before the first `make changelog`
> (an unborn `HEAD` makes git-cliff fail with
> `reference 'refs/heads/main' not found`).

## Local checks before committing

```sh
make validate
make build
```

Optionally regenerate the changelog with `make changelog` (requires
`git-cliff`).

## Troubleshooting

- **`sudo` inside `make install` during the build**: the `package()` of the
  PKGBUILDs installs files directly (`install -Dm755 ...`), without depending
  on the Makefile `install` target. If an old build shows this error again,
  make sure `package()` does not call `make install`.
- **`libfakeroot.so ... LD_PRELOAD`**: usually follows the `sudo` error
  above; it goes away after the previous step.
- **Release fails at "Retrieving sources"**: check that the repository URL,
  tag name, and archive URL format match the host (GitHub vs GitLab) — see the
  release section.

See also [CONTRIBUTING.md](CONTRIBUTING.md) for the contribution workflow.
