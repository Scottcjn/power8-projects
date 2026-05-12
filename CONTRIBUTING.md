# Contributing to PowerElyan Linux

Thanks for helping with PowerElyan Linux and the surrounding POWER8 project
notes. This repository documents a multi-architecture Linux distribution and
POWER8-focused workloads, so clear reproduction details are essential.

## Useful Contributions

- Improve ISO download, install, or verification instructions.
- Add tested notes for POWER8, ppc64le, x86_64, or aarch64 hardware.
- Clarify PSE, RustChain miner, container, or development-toolchain sections.
- Fix broken links, stale package names, or confusing command examples.
- Add troubleshooting notes for boot, installer, networking, or mining setup.

## Development Workflow

1. Fork the repository and create a focused branch.
2. Keep changes scoped to one edition, architecture, or documentation section.
3. Include hardware and OS details for any behavior change.
4. Use plain Markdown and avoid committing generated logs or local images unless
   the repository already tracks them intentionally.

## Validation

- Documentation-only changes: run `git diff --check`.
- Script changes: run the script in a shell compatible with the target system
  and include the command output.
- ISO or installation changes: include checksum, boot target, and the point in
  the install flow that was validated.

## Pull Request Checklist

- The PR explains the affected architecture or edition.
- Commands and observed results are included.
- Download URLs and checksums are verified when touched.
- Hardware-specific advice names the tested machine.
- Generated temporary files are not committed.

## Reporting Issues

Include the edition, architecture, machine model, firmware notes, boot medium,
and full command or installer output. For mining issues, include node endpoint,
miner command, and relevant log lines with secrets removed.
