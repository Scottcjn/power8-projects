# Darwin x86_64 Cross-Compiler for Modern macOS

## Target Versions
- Darwin 14 = OS X 10.10 Yosemite
- Darwin 15 = OS X 10.11 El Capitan  
- Darwin 16 = macOS 10.12 Sierra
- Darwin 17 = macOS 10.13 High Sierra
- Darwin 18 = macOS 10.14 Mojave
- Darwin 19 = macOS 10.15 Catalina
- Darwin 20 = macOS 11 Big Sur
- Darwin 21 = macOS 12 Monterey
- Darwin 22 = macOS 13 Ventura
- Darwin 23 = macOS 14 Sonoma

## Build Method
Using osxcross - the most reliable way to cross-compile for macOS from Linux.

## Requirements
- Xcode SDK (or extracted SDK from macOS)
- clang/llvm
- cmake, git, libxml2-dev, libssl-dev

## Notes
Mac OS X 10.6+ dropped PowerPC - x86_64 only for Darwin 10+
