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
	echo "[ERROR] Couldn't open chunk file $1"
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

##	echo "[DEBUG] Raw chunk bytes (hex): $location"

	sectors=$((0x${location:6:2}))

##	echo "[DEBUG] offset = $offset (${location:0:6}) || sectors = $sectors"
##	echo "[DEBUG] chunk timestamp raw (hex) = $(tail -c+$((($offset*4)+4097)) $1|head -c4|xxd -p -c 4)"

	timestamp=$((0x$(tail -c+$((($offset*4)+4097)) $1|head -c4|xxd -p -c 4)))

	echo "[DEBUG] chunk timestamp = $timestamp = $(date -d @$timestamp)" # moved this to only show if chunk > 0 bytes

	#obtain the length and compression type

#	chunkheader=$(tail -c+$(($offset*4096)) $1|head -c8|xxd -p -c 8);
	chunkheader=$(tail -c+$(($offset*4096+1)) $1|head -c8|xxd -p -c 8);
##	echo '[DEBUG] tail -c+$(('"$offset"'*4096+1)) '"$1"'|head -c8|xxd -p -c 8'
##	echo "[DEBUG] chunk $chunk_number header: "$(echo $chunkheader|xxd -r -p|xxd -c 8)
##	echo "[DEBUG] compression type: $((0x${chunkheader:8:2}))"


	chunk_length=$(((16777216 * 0x${chunkheader:0:2}) + (65536 * 0x${chunkheader:2:2}) + (256 * 0x${chunkheader:4:2}) + 0x${chunkheader:6:2}))
##	echo '[DEBUG] chunk_length=$(((16777216 * 0x'"${chunkheader:0:2})"' + (65536 * 0x'"${chunkheader:2:2}"') + (256 * 0x'"${chunkheader:4:2}"') + 0x'"${chunkheader:6:2}"'))'
##	echo "[DEBUG] chunk_length = $chunk_length"
##	echo "[DEBUG] Chunk data from " $(($offset*4096)) " + $chunk_length"

	# Decode chunk header.
	if [[ $chunk_length -gt 0 ]]; then	#skip zero-length chunks
		echo "[DEBUG] Chunk number: $chunk_number"
##		echo "[DEBUG] Chunk offset: $offset (${location:0:6}) || sectors = $sectors"
##		echo "[DEBUG] Chunk length: " $((0x${chunkheader:0:4})) "bytes"
##		echo "[DEBUG] chunk timestamp raw (hex) = $(tail -c+$(($offset+4096)) $1|head -c4|xxd -p -c 4)"
##	        echo "[DEBUG] chunk timestamp = $timestamp = $(date -d @$timestamp)"
##		echo "[DEBUG] Extracting chunk $chunk_number to out/$chunk_number.nbt"
##		echo -n '"\x1f\x8b\x08\x00\x00\x00\x00\x00" |cat - <(tail -c+$((('"$offset"'*4096)+6)) '$1'|head -c$(('$chunk_length' -1))) > out/'$chunk_number'.nbt.gz'

		# We tack on the gzip magic at the beginning, but I believe it's missing something (e.g. crc) at the end of the file. As such, gzip normally errors out, so we ignore that.
		# still seems to be valid after decompression :)
		gzip -dcq <(printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" |cat - <(tail -c+$((($offset*4096)+6)) $1|head -c$(($chunk_length -1 )))) 2>/dev/null > out/$chunk_number.nbt
#		printf "\x1f\x8b\x08\x00\x00\x00\x00\x00" |cat - <(tail -c+$((($offset*4096)+6)) $1|head -c$(($chunk_length -1 )))  > out/$chunk_number.nbt.gz
	fi;
		echo;
done

# i think we have an off-by-one with because of head counting characters starting at 1 vs bytes starting at 0
