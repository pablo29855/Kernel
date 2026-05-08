#!/bin/bash
# ChicKernel Build Script for Redmi Note 12 (tapas)

set -e

VARIANT=${1:-ksun} # standard, ksun, ksun-susfs
export ARCH=arm64
export CC=clang
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CROSS_COMPILE_COMPAT=arm-linux-gnueabi-
export O=out

echo "Building ChicKernel Variant: $VARIANT"

# Ensure toolchains are in PATH
if ! command -v clang &> /dev/null; then
    echo "Error: clang not found in PATH."
    echo "Please download AOSP Clang and add to PATH."
    exit 1
fi

# Determine config
if [ "$VARIANT" = "standard" ]; then
    DEFCONFIG="chickernel_defconfig"
elif [ "$VARIANT" = "ksun" ]; then
    DEFCONFIG="chickernel_defconfig chickernel-variants/ksun.config"
    # Ensure KSU is available
    if [ ! -d "../KernelSU-Next" ]; then
        echo "Cloning KernelSU-Next..."
        git clone https://github.com/rifsxd/KernelSU-Next.git -b next ../KernelSU-Next
    fi
elif [ "$VARIANT" = "ksun-susfs" ]; then
    DEFCONFIG="chickernel_defconfig chickernel-variants/ksun.susfs.config"
    if [ ! -d "../KernelSU-Next" ]; then
        echo "Cloning KernelSU-Next..."
        git clone https://github.com/rifsxd/KernelSU-Next.git -b next ../KernelSU-Next
    fi
else
    echo "Unknown variant: $VARIANT"
    exit 1
fi

echo "Cleaning out directory..."
make O=$O clean
make O=$O mrproper

echo "Generating config: $DEFCONFIG"
make O=$O $DEFCONFIG

echo "Starting build..."
make -j$(nproc --all) O=$O

echo "Build complete! Kernel Image at $O/arch/arm64/boot/Image"
