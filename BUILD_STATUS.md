# PowerElyan HSA Kernel Build Status

## Current Build: IN PROGRESS 🔄

**Started**: January 10, 2026 16:24 UTC  
**Platform**: IBM POWER8 S824 (Debian Bookworm container on Ubuntu 20.04 host)

### Build Stages
- [x] Stage 0/6: Adding deb-src to sources.list
- [x] Stage 1/6: Installing build dependencies ✅
- [x] Stage 2/6: Downloading kernel source (6.1.159 - 138 MB) 🔄
- [ ] Stage 3/6: Getting Debian ppc64el config
- [ ] Stage 4/6: Enabling CONFIG_HSA_AMD
- [ ] Stage 5/6: Building kernel (2-4 hours)
- [ ] Stage 6/6: Packaging .deb files

### Kernel Version
```
Target: linux-6.1.159 (latest Debian Bookworm)
Size: 138 MB source tarball
```

### Key Config Changes
```
CONFIG_HSA_AMD=y             # ← ENABLED (was disabled in Debian)
CONFIG_DRM_AMDGPU=m          # AMDGPU driver as module
CONFIG_DRM_AMDGPU_USERPTR=y  # Userspace pointers
CONFIG_MMU_NOTIFIER=y        # Required by HSA_AMD
```

### Build Environment
```
Host Kernel:      5.4.0-216-generic (Ubuntu 20.04)
Container:        Debian Bookworm (12)
Target Kernel:    6.1.159 with CONFIG_HSA_AMD=y
Build Threads:    128 (POWER8 SMT8)
```

### Fun Fact
We're building a NEWER kernel (6.1.159) inside a container running on an OLDER kernel (5.4.0)! 🤯

---
*PowerElyan by Elyan Labs - First ROCm on POWER8*
