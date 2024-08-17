#!/bin/bash

# Define paths
WORKSPACE=~/workspace/cross-compiler
SRC=$WORKSPACE/src
BUILD_BINUTILS=$WORKSPACE/build-binutils
BUILD_GCC=$WORKSPACE/build-gcc
PREFIX=$WORKSPACE/tools
TARGET=i686-elf
NUM_CORES=$(nproc)

# Create necessary directories
mkdir -p $SRC $BUILD_BINUTILS $BUILD_GCC $PREFIX

# Install required dependencies
sudo apt update
sudo apt install -y build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo wget

# Download Binutils
if [ ! -d "$SRC/binutils-2.41" ]; then
    echo "Downloading Binutils..."
    cd $SRC
    wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.gz
    tar -xvf binutils-2.41.tar.gz
fi

# Download GCC
if [ ! -d "$SRC/gcc-13.2.0" ]; then
    echo "Downloading GCC..."
    cd $SRC
    wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.gz
    tar -xvf gcc-13.2.0.tar.gz
fi

# Build and Install Binutils
if [ ! -f "$PREFIX/bin/$TARGET-as" ]; then
    echo "Building and installing Binutils..."
    cd $BUILD_BINUTILS
    $SRC/binutils-2.41/configure --target=$TARGET --prefix=$PREFIX --disable-nls --disable-werror
    make -j$NUM_CORES
    make install
fi

# Build and Install GCC
if [ ! -f "$PREFIX/bin/$TARGET-gcc" ]; then
    echo "Building and installing GCC..."
    cd $BUILD_GCC
    $SRC/gcc-13.2.0/configure --target=$TARGET --prefix=$PREFIX --disable-nls --enable-languages=c,c++ --without-headers
    make all-gcc -j$NUM_CORES
    make all-target-libgcc -j$NUM_CORES
    make install-gcc
    make install-target-libgcc
fi

# Add the cross-compiler to PATH
if ! grep -q "$PREFIX/bin" ~/.bashrc; then
    echo 'export PATH="$PREFIX/bin:$PATH"' >> ~/.bashrc
    echo "Cross-compiler path added to ~/.bashrc. Please run 'source ~/.bashrc' to update your PATH."
fi

echo "Cross-compiler setup completed successfully."
