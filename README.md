# PowerElyan Linux

```
  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗██╗  ██╗   ██╗ █████╗ ███╗   ██╗
  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██║  ╚██╗ ██╔╝██╔══██╗████╗  ██║
  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗  ██║   ╚████╔╝ ███████║██╔██╗ ██║
  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝  ██║    ╚██╔╝  ██╔══██║██║╚██╗██║
  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗███████╗██║   ██║  ██║██║ ╚████║
  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
                              by Elyan Labs
```

A multi-architecture Linux distribution optimized for AI inference, cryptocurrency mining, and exotic hardware.

## Downloads

**ISO Downloads**: [http://50.28.86.153/powerelyan/](http://50.28.86.153/powerelyan/)

| Edition | ppc64le | x86_64 | aarch64 |
|---------|---------|--------|---------|
| Server | ✅ | 🔄 Soon | 🔄 Soon |
| Workstation (MATE) | ✅ | 🔄 Soon | 🔄 Soon |
| Full | ✅ | 🔄 Soon | 🔄 Soon |
| Miner | ✅ | 🔄 Soon | 🔄 Soon |

## Editions

| Edition | Desktop | Size | Use Case |
|---------|---------|------|----------|
| **Server** | CLI | ~1.5 GB | Headless, containers, databases |
| **Workstation** | MATE | ~3 GB | Development, daily use |
| **Full** | MATE+ | ~4.5 GB | Everything + multimedia |
| **Miner** | CLI | ~800 MB | RustChain mining node |

## Features

### PSE (Probabilistic Sequence Evolution)
- **Vec_Perm Non-Bijunctive Collapse** - AI attention in single instruction
- **mftb Hardware Entropy** - True randomness from POWER8 timebase
- **RAM Coffers** - NUMA-aware weight banking
- **L2/L3 Resident Prefetch** - Keep weights hot in cache

### Pre-installed Software
- llama.cpp with PSE optimizations
- RustChain miner (Miner edition)
- Docker & container tools (Server+)
- Development toolchain (Workstation+)
- MATE Desktop (Workstation+)

## Quick Start

```bash
# Write ISO to USB
sudo dd if=powerelyan-server-1.0-ppc64le.iso of=/dev/sdX bs=4M

# Default login
Username: powerelyan
Password: powerelyan
```

## Documentation

- [Full Roadmap](POWERELYAN_ROADMAP.md)
- [Package Lists](packages-*.txt)
- [Build Scripts](build_powerelyan.sh)

## Cross-Compilers Included

| Target | Toolchain | Location |
|--------|-----------|----------|
| powerpc-apple-darwin9 | GCC 10.5.0 | /opt/darwin-ppc/ |
| x86_64-apple-darwin20 | Clang 12 | /opt/osxcross/ |
| arm64-apple-darwin20 | Clang 12 | /opt/osxcross/ |

---

**Created by Elyan Labs**

*AltiVec predates CUDA by 7 years*
