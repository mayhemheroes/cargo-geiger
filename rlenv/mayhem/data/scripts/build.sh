#!/bin/bash
set -euo pipefail

# RLENV Build Script
# This script rebuilds the application from source located at /rlenv/source/cargo-geiger/
#
# Original image: ghcr.io/mayhemheroes/cargo-geiger:master
# Git revision: 39cfa23d989aef0beed5303e601bee3751cb8c7c

# Change to the source directory
cd /rlenv/source/cargo-geiger

# Build fuzz target using cargo-fuzz in development mode (unoptimized)
# This helps trigger stack exhaustion bugs by using larger stack frames
echo "Building fuzz target with --dev flag..."
cd geiger/fuzz
cargo +nightly fuzz build --dev --target x86_64-unknown-linux-gnu find_unsafe

# Overwrite existing binary with new one
# Note: --dev builds to debug directory instead of release
# Use cat for busybox compatibility when we can't remove the file
cat target/x86_64-unknown-linux-gnu/debug/find_unsafe > /find_unsafe
echo "Fuzz target build complete"

# Verify build artifact exists
if [ ! -f /find_unsafe ]; then
    echo "Error: Fuzz target /find_unsafe not found"
    exit 1
fi

echo "Build successful! Artifact:"
echo "  - /find_unsafe"
