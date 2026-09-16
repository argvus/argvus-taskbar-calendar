# Security Policy

## Supported Versions

Only the latest tagged release is actively supported.

| Version | Supported |
| ------- | --------- |
| latest tag | Yes |
| older releases | No |

## Reporting a Vulnerability

Please **do not** open a public issue for security vulnerabilities. Report
them privately so they can be addressed before disclosure:

- GitHub Security Advisories (preferred): `https://github.com/argvus/argvus-taskbar-calendar/security/advisories/new`
- Otherwise, contact the maintainers directly.

Please include:

1. Affected version/tag and package name (`argvus-taskbar-calendar`)
2. Steps to reproduce (commands, inputs)
3. Impact (what a malicious actor could do)
4. Suggested fix, if you have one

We aim to acknowledge reports within 5 business days and to triage a fix
within a reasonable window depending on severity.

## Verifying published packages

Releases published in `argvus/packages` are GPG-signed. To verify integrity:

```sh
gpg --verify argvus-taskbar-calendar-<VERSION>-1-x86_64.pkg.tar.zst.sig argvus-taskbar-calendar-<VERSION>-1-x86_64.pkg.tar.zst
```

The signing key for the repository database (`argvus.db.tar.gz` and
`argvus.files.tar.gz`, signed alongside each release) is the same key used to
sign the packages. Import and locally sign it through `pacman-key` before
installing from the repository.

## Scope

This project produces an Arch Linux package (`.pkg.tar.zst`) built from this
repository. Security-sensitive behavior includes: the `sha256sums` validation
(no `SKIP`), the GPG signing of packages and repository metadata, and the
source archive URL used by the CI PKGBUILD (`packaging/arch/ci/PKGBUILD`).

If you are reporting an issue in software this package ships, report it to the
upstream project and link it here.
