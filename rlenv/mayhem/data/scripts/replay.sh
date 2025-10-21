#! /bin/bash

set -euo pipefail

if [ $# -ne 1 ]; then
    echo "Usage: $0 [FILE]"
    exit 1
fi

export ASAN_OPTIONS=symbolize=0:print_stacktrace=0

# Disable ASLR for reproducible crashes
# Use noaslr if available, otherwise fall back to setarch
if command -v noaslr >/dev/null 2>&1; then
    noaslr /find_unsafe $1
else
    # setarch -R disables address space randomization
    setarch $(uname -m) -R /find_unsafe $1
fi
