# PowerElyan Linux - Multi-Architecture OS Roadmap

```
  ██████╗  ██████╗ ██╗    ██╗███████╗██████╗ ███████╗██╗  ██╗   ██╗ █████╗ ███╗   ██╗
  ██╔══██╗██╔═══██╗██║    ██║██╔════╝██╔══██╗██╔════╝██║  ╚██╗ ██╔╝██╔══██╗████╗  ██║
  ██████╔╝██║   ██║██║ █╗ ██║█████╗  ██████╔╝█████╗  ██║   ╚████╔╝ ███████║██╔██╗ ██║
  ██╔═══╝ ██║   ██║██║███╗██║██╔══╝  ██╔══██╗██╔══╝  ██║    ╚██╔╝  ██╔══██║██║╚██╗██║
  ██║     ╚██████╔╝╚███╔███╔╝███████╗██║  ██║███████╗███████╗██║   ██║  ██║██║ ╚████║
  ╚═╝      ╚═════╝  ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝
```

## Vision
PowerElyan is a multi-architecture Linux distribution optimized for:
- AI/ML inference on non-x86 hardware
- RustChain cryptocurrency mining
- Vintage/exotic hardware preservation
- Server and workstation use

---

## Architecture Support

| Architecture | Codename | Status | Target Hardware |
|-------------|----------|--------|-----------------|
| **ppc64le** | AltiVec | ✅ Active | IBM POWER8/9, OpenPOWER |
| **x86_64** | Classic | 🔄 Planned | Intel/AMD servers |
| **aarch64** | Cortex | 🔄 Planned | Raspberry Pi, ARM servers |
| **sparc64** | Solaris | 📋 Future | Sun/Oracle SPARC |
| **powerpc** | G4/G5 | 📋 Future | Classic Mac PowerPC |

---

## Editions

### 1. PowerElyan Server
- **Size**: ~1.5 GB
- **Desktop**: None (CLI only)
- **Use Case**: Headless servers, containers, databases
- **Packages**: Docker, nginx, PostgreSQL, Redis, monitoring tools

### 2. PowerElyan Workstation  
- **Size**: ~3 GB
- **Desktop**: MATE
- **Use Case**: Development, daily use
- **Packages**: Server + MATE desktop, Firefox, LibreOffice, dev tools

### 3. PowerElyan Full
- **Size**: ~4-5 GB
- **Desktop**: MATE + extras
- **Use Case**: Complete workstation
- **Packages**: Workstation + multimedia, virtualization, scientific tools

### 4. PowerElyan Miner (Special Edition)
- **Size**: ~1 GB
- **Desktop**: None (CLI only)
- **Use Case**: RustChain mining node
- **Packages**: Minimal + RustChain miner, Python, networking
- **Features**: Auto-starts miner on boot, hardware fingerprinting

---

## PSE (Probabilistic Sequence Evolution)

PowerElyan includes custom AI inference optimizations:

### Vec_Perm Non-Bijunctive Collapse
- Dual-source vector shuffle in single instruction
- Prune weak paths + duplicate strong paths simultaneously
- 5 ops vs 80 on GPU for same result

### mftb Hardware Entropy
- POWER8 timebase register for true randomness
- Seeds non-deterministic token generation
- Creates behavioral divergence in LLM outputs

### RAM Coffers
- NUMA-aware weight distribution across memory banks
- Subject-based routing (Science → Node 1, Creative → Node 0)
- L2/L3 resident prefetch via DCBT hints

---

## Download Links

### ppc64le (POWER8)
| Edition | Size | Download |
|---------|------|----------|
| Server | ~1.5 GB | [powerelyan-server-1.0-ppc64le.iso](http://50.28.86.153/powerelyan/) |
| Workstation | ~3 GB | [powerelyan-workstation-1.0-ppc64le.iso](http://50.28.86.153/powerelyan/) |
| Full | ~4.5 GB | [powerelyan-full-1.0-ppc64le.iso](http://50.28.86.153/powerelyan/) |
| Miner | ~1 GB | [powerelyan-miner-1.0-ppc64le.iso](http://50.28.86.153/powerelyan/) |

### x86_64 (Coming Soon)
| Edition | Size | Download |
|---------|------|----------|
| Server | TBD | Coming Soon |
| Workstation | TBD | Coming Soon |
| Miner | TBD | Coming Soon |

---

## Default Credentials
- **Username**: `powerelyan`
- **Password**: `powerelyan`
- **Root**: `powerelyan`

---

## Quick Start

### Boot from USB
```bash
# Write ISO to USB drive
sudo dd if=powerelyan-server-1.0-ppc64le.iso of=/dev/sdX bs=4M status=progress

# Boot your POWER8 from USB
```

### Run AI Inference
```bash
# llama.cpp with PSE is pre-installed
cd ~/llama.cpp/build-pse-collapse/bin
./llama-cli -m /path/to/model.gguf -p "Hello world" -n 50
```

### Start RustChain Miner (Miner Edition)
```bash
# Miner auto-starts on boot, or manually:
systemctl start rustchain-miner
journalctl -u rustchain-miner -f
```

---

## Build From Source

```bash
git clone https://github.com/Scottcjn/power8-projects.git
cd power8-projects

# Build Server edition
./build_powerelyan.sh server

# Build Workstation edition
./build_powerelyan.sh workstation

# Build Full edition
./build_powerelyan.sh full

# Build Miner edition
./build_powerelyan.sh miner
```

---

## Hardware Requirements

### Minimum (Server)
- CPU: POWER8 or compatible (ppc64le)
- RAM: 4 GB
- Storage: 20 GB

### Recommended (Workstation)
- CPU: POWER8 8-core or better
- RAM: 16 GB
- Storage: 100 GB SSD

### AI Inference (Full)
- CPU: POWER8 16-core (128 threads)
- RAM: 128 GB+ (576 GB for Grok-2)
- Storage: 500 GB+ NVMe

---

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## License

PowerElyan Linux is free software, based on Debian.
PSE optimizations are proprietary to Elyan Labs.

---

## Credits

**Created by Elyan Labs**
- Scott - Lead Developer
- Sophia - AI Integration

*AltiVec predates CUDA by 7 years (1999 vs 2006)*
*Vec_Perm: The original vector processor*

