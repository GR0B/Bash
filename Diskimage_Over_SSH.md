## Diskimage over SSH ##

Lets say you have an instance on AWS that you want to take a disk image of. Well AWS make it easy to 
take a snapshot, make a backup or clone the instance but they don't make it easy for you to download 
that disk image. It is almost like they want to lock you into their ecosystem.

Well this was my solution to the issue, you will need to customize before running

```bash
# run on your local system, no the AWS instance
ssh -i AWS_Privatekey.pem admin@ec2-3-27-111-133.ap-southeast-2.compute.amazonaws.com "sudo bzip2 -c /dev/xvsda1 " | bzip2 -d > image.img
```


A version of the same command but with some extra comments explaining the steps
```bash
# Update this with your private key for the server, you make need to copy the key to ~/.ssh/
PrivateKey="AWS_Privatekey.pem"

# Change this to your server address
Server="admin@ec2-3-27-111-133.ap-southeast-2.compute.amazonaws.com"

# The filename that you want the diskimage to be saved into on your local machine.
OutputFilename="/~/backups/image.img"

# You can use /dev/sda on common Linux installs by my AWS instance the block device was /dev/xvsda1
# You can run "lsblk" to list the block devices, "df -h" can also be usefull to see what is mounted and space used.
# bzip2 is used to compress the data in transit, and decompressed when saved locally 
ssh -i $PrivateKey $Server "sudo bzip2 -c /dev/xvsda1 " | bzip2 -d > $OutputFilename
```


Extra protip: You can use 7-zip to open the image files under Windows. 



If you did not want to compress in transit, or do not use a keypair to login via SSH you could also use dd
```bash
# run on local machine
ssh root@10.0.1.13 "dd if=/dev/sda " | dd of=~/backups/sda.img status=progress
```


To write the image to a remote machine 
```bash
dd if=~/backups/sda.img | ssh root@10.0.0.13 "dd of=/dev/sda"
```
