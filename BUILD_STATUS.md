# PowerElyan HSA Kernel Build Status

## Current Build: IN PROGRESS 🔄

**Started**: January 10, 2026 16:22 UTC  
**Platform**: IBM POWER8 S824 (Debian Bookworm container on Ubuntu 20.04 host)

### Build Environment
```
Host Kernel:      5.4.0-216-generic (Ubuntu 20.04)
Container:        Debian Bookworm (12)
Target Kernel:    6.1.x with CONFIG_HSA_AMD=y
Build Threads:    128 (POWER8 SMT8)
```

### Build Stages
- [x] Stage 1/6: Installing build dependencies
- [ ] Stage 2/6: Downloading kernel source
- [ ] Stage 3/6: Getting Debian ppc64el config
- [ ] Stage 4/6: Enabling CONFIG_HSA_AMD
- [ ] Stage 5/6: Building kernel (2-4 hours)
- [ ] Stage 6/6: Packaging .deb files

### Key Config Changes
```
CONFIG_HSA_AMD=y             # ← ENABLED (was disabled in Debian)
CONFIG_DRM_AMDGPU=m          # AMDGPU driver as module
CONFIG_DRM_AMDGPU_USERPTR=y  # Userspace pointers
CONFIG_MMU_NOTIFIER=y        # Required by HSA_AMD
```

### Why This Matters
- Debian Bookworm kernel 6.1.x **supports** HSA_AMD on PPC64 (upstream)
- But Debian **disabled** it in their ppc64el config
- This build enables it for ROCm GPU compute on POWER8

### Build Log
See: `/opt/powerelyan-build/kernel-build.log` on POWER8

---
*PowerElyan by Elyan Labs - First ROCm on POWER8*
