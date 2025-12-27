#include <stdio.h>
#include <TargetConditionals.h>

int main() {
    printf("Hello from Darwin 20 cross-compiled binary!\n");
    printf("Compiled for: ");
    #if TARGET_CPU_ARM64
    printf("Apple Silicon (arm64)\n");
    #elif TARGET_CPU_X86_64
    printf("Intel x86_64\n");
    #else
    printf("Unknown architecture\n");
    #endif
    printf("Target: macOS 11+ (Big Sur)\n");
    return 0;
}
