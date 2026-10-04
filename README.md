# Homebrew tap for fusion-cli

Install the open-source Autodesk Fusion CAD CLI on macOS:

```bash
brew install DeanDiasti/tap/fusion-cli
fusion-install-addin
fusion help
```

Save your work and restart Fusion, then run CadBot from Scripts and Add-Ins.
Autodesk Fusion is installed and licensed separately. AI chat is optional and
requires Codex sign-in. Offline help does not require Fusion or an account.

- [Project and release scope](https://github.com/DeanDiasti/fusion-cli)
- [Website and installation guide](https://deandiasti.github.io/fusion-cli/)
- [Security policy](https://github.com/DeanDiasti/fusion-cli/blob/main/SECURITY.md)
- [Formula](Formula/fusion-cli.rb)

The formula installs a versioned, checksummed source archive and Python 3.14 in an
isolated environment. Every SDK dependency is pinned to an immutable upstream
wheel URL and SHA-256. `dependencies.json` records the same resource set for
maintenance; the Ruby formula is authoritative during installation. This tap uses
upstream native SDK wheels and is independent of Homebrew core.

Apple Silicon and Intel have architecture-specific wheel resources. CI tests the
formula installation, offline help, SDK import, and temporary add-in installation
on both macOS architectures. These checks do not certify native Fusion geometry.
Fusion support remains limited to the validation in the project release report.

Save your work and stop CadBot before upgrading:

```bash
brew update
brew upgrade DeanDiasti/tap/fusion-cli
fusion-install-addin
```

Run `fusion-install-addin` after every upgrade and before `brew cleanup`, then
restart Fusion. Upgrading the formula does not automatically replace a running
add-in. Removing the formula does not remove the separately installed add-in,
bridge token, backups, or conversation history.

Report package failures here, with private paths and credentials redacted. Report
CAD behavior issues in the main project. Security vulnerabilities should use the
main project's private reporting channel.

Formula code is GPL-3.0-only. Dependencies and Autodesk Fusion retain their own
licenses. Update source URLs and checksums only after testing an immutable release;
never move a published version tag or allow unconstrained dependency downloads.
