#
# @author sudofox
#
# Extract and print the chunk timestamps from a minecraft region file
#

import sys

# usage: ./region_timestamps.py <region file>

if len(sys.argv) == 1:
    print("usage: ./extract_region_timestamps.py <region file>")
    sys.exit(1)

# open the region file
region_file = open(sys.argv[1], "rb")

# read the header (8 kB)

# header layout is as follows:
# byte 0-4095: locations (1024 entries)
# byte 4096-8191: timestamps (1024 entries)
# byte 8192: data (chunks and unused space)

region_file.seek(0)
header = region_file.read(8192)

# read all the chunk timestamps
timestamps = []
for i in range(1024):
    timestamp = header[4096 + i*4:4096 + (i+1)*4]
    timestamp = int.from_bytes(timestamp, byteorder="big")
    timestamps.append(timestamp)

# print the timestamps separated by newlines
for timestamp in timestamps:
    print(timestamp)
