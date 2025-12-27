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

## Toolchain Versions

### Native (PowerElyan / POWER8)
- GCC 10.5.0
- Clang 12.0.0
- LLVM 12

### Cross-Compiler (Darwin PPC)
- powerpc-apple-darwin9-gcc 10.5.0
- Target: Mac OS X 10.5 Leopard (PowerPC)

## Model Performance (PSE-enabled)

| Model | Size | Active Params | Speed |
|-------|------|---------------|-------|
| DeepSeek-V3 (671B) | 228 GB | ~33B MoE | 0.5 t/s |
| Grok-2 (270B) | 164 GB | ~50B MoE | 0.3 t/s |
| TinyLlama (1.1B) | 638 MB | 1.1B dense | 92 t/s |

