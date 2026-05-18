# Contributing to PowerElyan Linux

Thanks for helping improve PowerElyan Linux. This repository tracks the build
assets, package lists, documentation, and release structure for an
Elyan Labs Linux distribution focused on POWER8 and related architectures.

## Good First Contributions

- Improve setup, build, or installer documentation.
- Fix typos, stale paths, or unclear command examples.
- Update package lists when a package is added, removed, or renamed.
- Improve comments in shell scripts without changing their behavior.
- Add notes for tested POWER8, ppc64le, x86_64, or aarch64 hardware.

## Before You Open a Pull Request

1. Check existing issues and pull requests to avoid duplicate work.
2. Keep changes focused on one topic.
3. Use clear commit messages, such as `docs: clarify ISO build steps`.
4. Do not include generated ISO images, package caches, logs, or credentials.
5. If you change a script, explain how you tested it or why it is docs-only.

## Documentation Guidelines

- Prefer copy-pasteable commands.
- Mention the target edition or architecture when it matters.
- Keep hardware claims tied to files, scripts, or documented test results.
- Use relative links for files in this repository.
- Keep README changes concise and move longer notes into `docs/` when possible.

## Build Script Guidelines

- Keep shell scripts POSIX-friendly unless the file already requires Bash.
- Preserve existing executable bits.
- Quote paths and variables when practical.
- Avoid broad formatting rewrites in the same pull request as a functional
  change.

## Pull Request Checklist

- [ ] The change is scoped to PowerElyan Linux.
- [ ] Documentation links and file paths were checked.
- [ ] Scripts changed by the PR were run, syntax-checked, or clearly marked as
      not run.
- [ ] No generated build artifacts or local machine-specific files were added.

## Review Process

Maintainers may ask for smaller commits, clearer testing notes, or a narrower
scope before merging. That feedback keeps the distribution easier to build,
review, and release across supported architectures.
