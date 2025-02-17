# Bash
Misc debian bash script

CA_update.sh - a script that fixes the issue of Debian Jessie giving a SSL expired error caused by not having the CA cert installed that is used by LetsEncrypt. 


backup.sh - A generic debian script that backs up some folders to a tgz. Needs to run as sudo due to the folders selected. 
to use 'crontab -e' then '0 2 * * * /root/backup.sh' to run at 2am every day    

hashcheck.sh - Create an csv index of all files in a path with MD5 hash, or compare hash of files with hash in index file. 
