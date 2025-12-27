# PowerElyan Linux & POWER8 Development Tools

## PowerElyan Linux 1.0 (Codename: AltiVec)
A custom Linux distribution optimized for IBM POWER8 with PSE Vec_Perm.

### ISO Download
- `powerelyan-1.0-ppc64le.iso` (755 MB)

### Features
- Debian Bookworm base (POWER8 compatible)
- Pre-installed llama.cpp with PSE optimizations
- Vec_Perm Non-Bijunctive Collapse
- mftb Hardware Entropy Injection
- RAM Coffers NUMA Optimization
- Demo scripts for Grok-2 inference

### Default Credentials
- User: `powerelyan` / Password: `powerelyan`

---

## Cross-Compilers

### Darwin PPC (Mac OS X 10.5 PowerPC)
- Target: `powerpc-apple-darwin9`
- GCC 10.5.0
- Location: `/opt/darwin-ppc/`

### Darwin x86_64/ARM64 (macOS 11+ Big Sur)
- Targets: `x86_64-apple-darwin20.4`, `arm64-apple-darwin20.4`
- Via osxcross
- Location: `/opt/osxcross/`

---

## PSE (Probabilistic Sequence Evolution)
Custom AI inference optimizations for POWER8:
- Vec_Perm dual-source shuffle (5 ops vs 80 on GPU)
- Non-bijunctive collapse (prune + duplicate in single cycle)
- mftb timebase entropy injection
- L2/L3 resident prefetch via DCBT hints

---

by Elyan Labs
