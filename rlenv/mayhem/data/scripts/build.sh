#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/cargo-geiger/
#
# Original image: ghcr.io/mayhemheroes/cargo-geiger:master
# Git revision: 39cfa23d989aef0beed5303e601bee3751cb8c7c

# Change to the source directory
cd /rlenv/source/cargo-geiger

# Build instrumented harnesses
echo "Building instrumented harnesses..."
bash -c "pushd geiger/fuzz && cargo +nightly -Z sparse-registry fuzz build --target x86_64-unknown-linux-gnu && popd"
mv geiger/fuzz/target/x86_64-unknown-linux-gnu/release/find_unsafe /find_unsafe
echo "Instrumented harness build complete"

# Build non-instrumented harnesses
echo "Building non-instrumented harnesses..."
export RUSTFLAGS="--cfg fuzzing -Clink-dead-code -Cdebug-assertions -C codegen-units=1"
bash -c "pushd geiger/fuzz && cargo +nightly -Z sparse-registry build --release --target x86_64-unknown-linux-gnu && popd"
mv geiger/fuzz/target/x86_64-unknown-linux-gnu/release/find_unsafe /find_unsafe_no_inst
echo "Non-instrumented harness build complete"

# Verify build artifacts exist
if [ ! -f /find_unsafe ]; then
    echo "Error: Instrumented harness /find_unsafe not found"
    exit 1
fi

if [ ! -f /find_unsafe_no_inst ]; then
    echo "Error: Non-instrumented harness /find_unsafe_no_inst not found"
    exit 1
fi

echo "Build successful! Artifacts:"
echo "  - /find_unsafe (instrumented)"
echo "  - /find_unsafe_no_inst (non-instrumented)"
