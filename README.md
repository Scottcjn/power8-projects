# Ubuntu 22.04 for POWER8 Build Project

## Problem
Ubuntu 22.04 officially dropped POWER8 support - binaries are compiled with POWER9+ instructions.

## Solution
1. Use debootstrap to create minimal Ubuntu 22.04 rootfs
2. Cross-compile critical packages with -mcpu=power8
3. Build Docker image from custom rootfs
4. Create installer ISO

## Status
- [ ] Set up cross-compilation toolchain
- [ ] debootstrap base system
- [ ] Rebuild glibc for POWER8
- [ ] Rebuild critical system packages
- [ ] Create Docker image
- [ ] Create bootable ISO
