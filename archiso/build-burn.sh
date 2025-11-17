#!/bin/bash
set -e

# Check if drive argument is provided
if [ -z "$1" ]; then
    echo "Usage: ./build-burn.sh <drive>"
    echo "Example: ./build-burn.sh sdb"
    echo ""
    echo "Available drives:"
    lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk"
    exit 1
fi

DRIVE=$1

# Validate drive exists
if [ ! -b "/dev/$DRIVE" ]; then
    echo "Error: /dev/$DRIVE does not exist"
    echo ""
    echo "Available drives:"
    lsblk -d -o NAME,SIZE,TYPE,MOUNTPOINT | grep -E "disk"
    exit 1
fi

# Safety check - make sure it's not the main system drive
if mount | grep -q "^/dev/${DRIVE}.*on / "; then
    echo "ERROR: /dev/$DRIVE appears to be your root filesystem!"
    echo "Refusing to overwrite your system drive."
    exit 1
fi

echo "======================================"
echo "CrowOS Build and Burn"
echo "======================================"
echo "Target drive: /dev/$DRIVE"
echo ""
lsblk "/dev/$DRIVE"
echo ""
read -p "This will ERASE everything on /dev/$DRIVE. Continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Building ISO..."
./build-crowos.sh

echo ""
echo "Step 2: Unmounting drive..."
sudo umount /dev/${DRIVE}* 2>/dev/null || true

echo ""
echo "Step 3: Writing ISO to /dev/$DRIVE..."
ISO_FILE=$(ls -t out/crowos-*.iso | head -1)
echo "Using: $ISO_FILE"

sudo dd if="$ISO_FILE" of="/dev/$DRIVE" bs=4M status=progress oflag=sync

echo ""
echo "Step 4: Syncing..."
sync

echo ""
echo "======================================"
echo "Done! /dev/$DRIVE is ready to boot."
echo "======================================"
