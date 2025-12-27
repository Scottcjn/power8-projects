# POWER8 Projects Repository

## Projects

### 1. Ubuntu 22.04 for POWER8
Building a POWER8-compatible Ubuntu 22.04 installer since official support was dropped at 20.04.

**Approach**: Use Debian Bookworm (still supports POWER8) as base, overlay Ubuntu packages.

### 2. PSE LLM Inference
vec_perm non-bijunctive collapse optimization for llama.cpp on POWER8.

### 3. Darwin PPC Cross-Compilation
osxcross setup for building PowerPC Mac software on POWER8 (128 threads = fast builds!)

### 4. RustChain Mining
POWER8 attestation for RustChain with enhanced fingerprinting.

## Hardware
- IBM Power System S824 (8286-42A)
- Dual 8-core POWER8 = 16 cores (128 SMT threads)
- 576 GB DDR3 RAM (4 NUMA nodes)
- 1.8 TB SAS storage

## Quick Start
\`\`\`bash
# SSH access (via Tailscale)
ssh sophia@100.94.28.32
\`\`\`
