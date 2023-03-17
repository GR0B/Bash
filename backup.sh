#!/bin/bash
####################################
# Robert Sturzbecher 2023
# Backup script 

function log {
    # Echo message to console as well as to syslog.
    echo "${1}"
    logger "${1}"
}

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    log "You must run this script with sudo privileges. Example: sudo bash $0"
    exit 1
fi

#Source files do backup (can be multiple folders)
folders="/boot /etc /opt /var/www /home /var/spool/mail"

#Destination path. where our backup will go
dest="/mnt/backup"

# backup filename
hostname=$(hostname -s)
date=$(date -I)
archive="$hostname-$date.tgz"

log "Backup Started"
log "Sources:" $sources
log "Dest Archive:" $dest/$archive

# Backup the files using tar.
tar czf $dest/$archive $folders
   if [ $? -ne 0 ]; then
       log "Backup script reported an error."
   fi

log "Backup Completed"

