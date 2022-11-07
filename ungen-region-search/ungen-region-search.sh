#!/bin/bash

# List ungenerated Minecraft region files ranging from r.-100.-100.mca to r.100.100.mca

# five parameters: regionDir startX, startZ, endX, endZ
if [ $# -ne 5 ]; then
    echo "List ungenerated Minecraft region files within a specified range"
    echo "Usage: $0 regionDir startX startZ endX endZ"
    exit 1
fi

# Verify regionDir exists
if [ ! -d $1 ]; then
    echo "regionDir $1 does not exist"
    exit 1
fi

for x_region in $(seq $2 $3); do
    for z_region in $(seq $4 $5); do
        region_file="$1/r.$x_region.$z_region.mca"
        if [ ! -f "$region_file" ]; then
            echo "Region $x_region $z_region has not yet been generated"
        fi
    done
done
