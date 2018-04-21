#!/bin/bash
echo "+=============================+"
echo "| region-parser.sh by Sudofox |"
echo "+=============================+"

# Some values related to the format
# There are 1,024 chunks in each region file, occupying the first 4096 bytes of the file

# xxd -r -p to get raw binary back from a string like 01020304
# xxd -p -c 8 to get 8 bytes as an unbroken string of hex

# Validation

# File exists?

if [ ! -f $1 ]; then
	echo "Couldn't open chunk file $1"
	exit;
fi

echo "[INFO] Deleting all NBT files in ./out"
rm -f out/*.nbt

chunk_number=-1 # until we get the location of the chunk I guess

for location in $(head -c4096 $1 |xxd -p -c 4); do

	chunk_number=$((chunk_number+1))
	offset=$((0x${location:0:6}))
	if [[ $offset == 0 ]]; then
		continue; # No chunk
	fi

#	echo "[INFO] Raw chunk bytes (hex): $location"

	sectors=$((0x${location:6:2}))

#	echo "[INFO] offset = $offset (${location:0:6}) || sectors = $sectors"
#	echo "[INFO] chunk timestamp raw (hex) = $(tail -c+$(($offset+4096)) $1|head -c4|xxd -p -c 4)"

	timestamp=$((0x$(tail -c+$(($offset+4096)) $1|head -c4|xxd -p -c 4)))

#	echo "[INFO] chunk timestamp = $timestamp = $(date -d @$timestamp)" # moved this to only show if chunk > 0 bytes

	#obtain the length and compression type

	chunkheader=$(tail -c+$(($offset*4096)) $1|head -c8|xxd -p -c 8);
#	echo -n $chunkheader|xxd -r -p|xxd -c 8

	chunk_length=$((0x${chunkheader:0:4}));
#	echo "[INFO] Chunk data from " $(($offset*4096)) " + $chunk_length"

	# Decode chunk header.
	if [[ $((0x${chunkheader:0:4})) -gt 0 ]]; then	#skip zero-length chunks

		echo "[INFO] Chunk length:" $((0x${chunkheader:0:4})) "bytes"
		echo "[INFO] chunk timestamp raw (hex) = $(tail -c+$(($offset+4096)) $1|head -c4|xxd -p -c 4)"
	        echo "[INFO] chunk timestamp = $timestamp = $(date -d @$timestamp)"
		echo "[INFO] Extracting chunk $chunk_number to out/$chunk_number.nbt"
#		echo -n '"\x1f\x8b\x08\x00\x00\x00\x00\x00" |cat - <(tail -c+$((('"$offset"'*4096)+6)) '$1'|head -c$(('$chunk_length' -1))) > out/'$chunk_number'.nbt.gz'
		# TODO: Not sure if we need to subtract 1 from the $chunk_length in the head command below, or not. nbted seems to have no issues either way.
		gzip -dcq <(printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" |cat - <(tail -c+$((($offset*4096)+6)) $1|head -c$(($chunk_length -1 )))) 2>/dev/null > out/$chunk_number.nbt
		echo;
	fi;
done

# i think we have an off-by-one with because of head counting characters starting at 1 vs bytes starting at 0
