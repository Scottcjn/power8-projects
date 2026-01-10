# ROCm HSA Support on IBM POWER8

## Status Summary

| Component | Version | Status | Notes |
|-----------|---------|--------|-------|
| **ROCT-Thunk-Interface** | 5.7.1 | ✅ Built | HSA kernel interface |
| **LLVM/Clang** | 17.0.0 | ✅ Built | AMDGPU + PowerPC targets |
| **ROCR-Runtime** | 5.7.1 | ✅ Built | libhsa-runtime64.so |
| **Debian Kernel 6.1** | 6.1.137 | ⚠️ Partial | AMDGPU=m, HSA_AMD=n |
| **Custom Kernel** | 6.1.x | ✅ Required | Must enable CONFIG_HSA_AMD=y |

## The HSA_AMD Problem

### Kernel Support Timeline
- **Kernel ≤5.x**: HSA_AMD only supported X86_64 and ARM64
- **Kernel 6.x+**: PPC64 added to HSA_AMD Kconfig depends

### Current Debian Bookworm (6.1.137) ppc64el Config
```
CONFIG_DRM_AMDGPU=m          # ✅ AMDGPU driver enabled
CONFIG_DRM_AMDGPU_SI=y       # ✅ Southern Islands support
CONFIG_DRM_AMDGPU_CIK=y      # ✅ Sea Islands support
CONFIG_DRM_AMDGPU_USERPTR=y  # ✅ Userspace pointers
# CONFIG_HSA_AMD is not set  # ❌ HSA/KFD NOT enabled!
```

### What This Means
- `/dev/kfd` will NOT appear even with Debian Bookworm kernel
- ROCm compute (HIP, rocBLAS, etc.) will NOT work
- Display/graphics output WILL work

## Solution: PowerElyan HSA Kernel

PowerElyan includes a custom-built kernel with:
```
CONFIG_HSA_AMD=y             # ✅ HSA kernel driver enabled
CONFIG_DRM_AMDGPU=m          # ✅ AMDGPU as module
CONFIG_DRM_AMDGPU_USERPTR=y  # ✅ Userspace pointers
CONFIG_MMU_NOTIFIER=y        # ✅ Required by HSA_AMD
```

## Building the HSA Kernel

### Prerequisites
```bash
apt-get install build-essential libncurses-dev bison flex libssl-dev libelf-dev
```

### Get Debian Kernel Source
```bash
apt-get source linux
cd linux-6.1.*
```

### Enable HSA_AMD
```bash
# Copy Debian config
cp /boot/config-$(uname -r) .config

# Enable HSA_AMD
scripts/config --enable HSA_AMD
scripts/config --enable MMU_NOTIFIER
scripts/config --enable DRM_AMDGPU_USERPTR

# Update config
make olddefconfig
```

### Build
```bash
make -j$(nproc) bindeb-pkg LOCALVERSION=-powerelyan-hsa
```

### Install
```bash
dpkg -i ../linux-image-6.1.*-powerelyan-hsa*.deb
reboot
```

## Verification

After booting the HSA kernel:
```bash
# Check for KFD device
ls -la /dev/kfd
# Should show: crw-rw---- 1 root render 234, 0 /dev/kfd

# Check ROCm detection
/opt/rocm/bin/rocminfo
# Should list AMD GPU agents
```

## Supported GPUs

| GPU | Architecture | PCIe Atomics | Status |
|-----|--------------|--------------|--------|
| RX 580 | Polaris (GCN4) | Required | ✅ Works with atomics |
| RX 5700 | RDNA 1 | Required | ✅ Works with atomics |
| RX 6800 | RDNA 2 | Not required | ✅ Works |
| Radeon VII | Vega 20 | Not required | ✅ Works |

**Note**: GCN4 (Polaris) GPUs like RX 580 require PCIe atomics support from the platform. POWER8 supports PCIe atomics via CAPI.

## ROCm Installation Path

```
/opt/rocm/
├── bin/           # rocminfo, rocm-smi
├── lib/           # libhsa-runtime64.so, libhsakmt.a
├── include/hsa/   # HSA headers
└── llvm/bin/      # clang with AMDGPU target
```

## References

- [ROCm GitHub](https://github.com/RadeonOpenCompute)
- [HSA_AMD Kconfig](https://cateee.net/lkddb/web-lkddb/HSA_AMD.html)
- [AMDGPU Documentation](https://www.kernel.org/doc/html/latest/gpu/amdgpu.html)

---
*PowerElyan by Elyan Labs - First ROCm on POWER8*
