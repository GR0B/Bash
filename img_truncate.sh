#!/bin/bash
set -e
echo "Robert Sturzbecher 2026-04-01"
echo "Truncate .img disk image file to partition size"

IMG="$1"

if [ -z "$IMG" ]; then
    echo "Usage: img_truncate.sh disk.img"
    exit 1
fi

parted -ms $IMG print

# get the end of the last partition 
PART_END=$(parted -ms "$IMG" unit B print | tail -n 1 | cut -d: -f2 | tr -d B) 

echo "!! Will truncated $IMG to $(( PART_END + 1000000)) bytes ($(( (PART_END + 1000000)/1000000))MB) to match partition size"
read -n 1 -p "Press Y to continue or any other key to quit: " key
echo    # move to next line
if [[ "$key" =~ [Yy] ]]; then
	# truncate the image file 1MB past the end of the last partition 
	truncate -s $(( PART_END + 1000000)) "$IMG"
else
    echo "Quitting..."
    exit 1
fi
echo "Done."



