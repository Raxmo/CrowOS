#!/bin/bash
set -e

echo "Building CrowOS ISO..."
echo "Version: $(date +%Y.%m.%d)"

# Create cache directory if it doesn't exist
mkdir -p pkg-cache

# Build in Docker container with package caching
docker run --rm --privileged \
  -v $(pwd)/crowos-profile:/profile \
  -v $(pwd)/out:/out \
  -v $(pwd)/pkg-cache:/var/cache/pacman/pkg \
  archlinux:latest bash -c "
    # Update mirrorlist to use fast US mirrors
    echo 'Server = https://mirrors.kernel.org/archlinux/\$repo/os/\$arch' > /etc/pacman.d/mirrorlist
    echo 'Server = https://mirror.rackspace.com/archlinux/\$repo/os/\$arch' >> /etc/pacman.d/mirrorlist
    echo 'Server = https://mirrors.ocf.berkeley.edu/archlinux/\$repo/os/\$arch' >> /etc/pacman.d/mirrorlist
    
    # Update and install archiso
    pacman -Sy --noconfirm archiso
    
    # Build the ISO
    mkarchiso -v -w /tmp/work -o /out /profile
  "

echo ""
echo "Build complete! ISO is in: ./out/"
ls -lh out/*.iso
