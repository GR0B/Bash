#!/bin/bash
set -e
echo "Robert Sturzbecher 2026-04-01"
echo "Converts Pi img raw disk images files down to 8Gb images"
echo "besides saving space, Not writing out a full SDcard leaves more free blocks ware leveling"
echo "Usage: shrink.sh image.img"


IMG="$1"
TARGET_SIZE_GB=8 


if [ -z "$IMG" ]; then
    echo "Usage: img_shrink.sh disk.img"
    exit 1
fi

trim_log() {
    # uses tail to keep just the last 1000 lines of a log file, is injected back into it's self to preserve inode/permissions/flags
    local file="$1"
    if [ -z "$file" ]; then
        echo "Usage: trim_log <file> "
        return 1
    fi
    if [ ! -f "$file" ]; then
        echo "trim_log: '$file' not found"
        return 1
    fi
    echo "trim_log: Triming '$file' down to 1000 lines"
    local tmp="${file}.trim.$$"
    tail -n 1000 "$file" > "$tmp" 2>/dev/null
    cat "$tmp" > "$file"
    rm -f "$tmp"
}


clean_syslogs() {
    echo "Mounting FS to clear logs..."
    #mount loopback partition 1 with fs trim support to mnt 
    mount -o discard $LOOP /mnt/loop

    #delete old logs   
    find /mnt/loop/var/log -type f -name "*.gz" -delete
    find /mnt/loop/var/log -type f -name "*.1" -delete

    #trim logs down to a max of the last 1000 lines, preserving inode/permissions
    trim_log "/mnt/loop/var/log/syslog"
    trim_log "/mnt/loop/var/log/user.log" 
    trim_log "/mnt/loop/var/log/kern.log" 
    trim_log "/mnt/loop/var/log/daemon.log" 

    #clear these logs, preserving inode/permissions
    : >/mnt/loop/var/log/messages
    : >/mnt/loop/var/log/debug

    sync
    # unmounting
    umount /mnt/loop
}

clean_freespace() {
    # fill the free diskspace with zeros, this makes the img file more compressible

    # now to double check and zero out freespace
    echo "Attaching loop device..."
    LOOP=$(losetup -f --show -o "$PART_START" "$IMG")
    #double check the FS, not needed but good to double check
    #e2fsck -f -y "$LOOP"
    mount -o discard $LOOP /mnt/loop
    #fill the freespace 
    dd if=/dev/zero of=/mnt/loop/zero.tmp bs=16M status=progress || true
    rm /mnt/loop/zero.tmp
    sync
    umount /mnt/loop
}



# Convert GB → bytes
# TARGET_BYTES=$(( TARGET_SIZE_GB * 1024 * 1024 * 1024 )) 
TARGET_BYTES=$(( TARGET_SIZE_GB * 1000 * 1000 * 995 ))  #SDcards capacity is really smaller then GB or GiB, 
# 8GB is really 7.9GB so we calc smaller so that we can flash onto a 8GB card if needed 



echo "Getting partition info..."
PART_START=$(parted -ms "$IMG" unit B print | tail -n 1 | cut -d: -f2 | tr -d B)

# Create loop device for the filesystem
echo "Attaching loop device..."
LOOP=$(losetup -f --show -o "$PART_START" "$IMG")
#LOOP=$(losetup --discard -f --show -o "$PART_START" "$IMG") # added discard but it is unrecognized

echo "Checking filesystem..."
e2fsck -f -y "$LOOP"

echo "Shrinking filesystem to fit inside ${TARGET_SIZE_GB}GB..."
# EXT4 needs some overhead; shrink to slightly less than target
FS_TARGET=$(( (TARGET_BYTES - PART_START) / 4096 ))   # blocks
resize2fs "$LOOP" "$FS_TARGET"

clean_syslogs

echo "Detaching loop..."
losetup -d "$LOOP"

echo "Resizing partition..."
# -s does not work, need to remove and type yes
# parted -s "$IMG" unit B resizepart 2 $(( PART_START + TARGET_BYTES )) # ?! bad maths
#parted -s "$IMG" unit B resizepart 2 $(( TARGET_BYTES - PART_START))
echo Yes | parted "$IMG"  unit B resizepart 2 $(( TARGET_BYTES - PART_START))

echo "Truncating image..."
# needs to be an extra 1MB of extra space at the end
#truncate -s $(( PART_START + TARGET_BYTES + 1000000)) "$IMG"
# dd if=/dev/zero bs=1M count=1 >> $IMG # add 1MB to fix

# get the end of the last partition 
PART_END=$(parted -ms "$IMG" unit B print | tail -n 1 | cut -d: -f2 | tr -d B) 
# truncate the image file 1MB past the end of the last partition 
truncate -s $(( PART_END + 1000000)) "$IMG"

echo "Compressing image..."
# -1 low compression (higher levels don't save much extra and really slow things down)
# -k is to keep the img file after compressing
# gzip -1 MC_SD_Role1_backup_2025-08-26.img -k

echo "Done."
