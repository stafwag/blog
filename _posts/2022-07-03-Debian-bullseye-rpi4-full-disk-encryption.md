---
layout: post
title: "Debian bullseye on the RPI 4 with full disk encryption."
date: 2022-07-03 8:33:01 +0100
comments: true
categories: [  "raspberry-pi", "rpi" , "linux", "debian", "security", "kubernetes", "k3s", "kvm", "libvirt", "arm64", "archlinux", "archlinuxarm" ] 
excerpt_separator: <!--more-->
---


---

***Updated @ Sun Jul 17 07:51:58 PM CEST 2022: Added blkid section UUID cryptroot. Changed dropbear port to 2222.***

---

<a href="{{ '/images/debian/debian-logo-534x576.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/debian/debian-logo-534x576.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="323" alt="debian" /> </a>

I use a few [Raspberry PI's 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) to run [virtual machines](https://stafwag.github.io/blog/blog/2020/07/23/howto-use-cloud-images-on-rpi4/) and [k3s](https://k3s.io/).

I was using the [Manjaro Linux with full disk encryption](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/) but I'll switch to [Debian GNU/Linux](https://www.debian.org/), the main reason is that [libvirt](https://libvirt.org/) is currently [broken on archlinuxarm](https://archlinuxarm.org/forum/viewtopic.php?f=15&t=16037&p=69506&hilit=qemu#p69506).

You'll find my journey to get Debian GNU/Linux bullseye up and running on the Raspberry PI with full disk encryption below.

<!--more-->

# Download

All actions below are executed on a Debian 11 (bullseye) GNU/Linux virtual machine.

## Download image

Debian provides more information on how to use Debian GNU/Linux on: [https://raspi.debian.net/](https://raspi.debian.net/).
You can download the images from: [https://raspi.debian.net/tested-images/](https://raspi.debian.net/tested-images/).

Download the latest bullseye release image/sha2sum/signature from [[https://raspi.debian.net/tested-images/](https://raspi.debian.net/tested-images/).

## Verify signatures

Go to the directory with the download files.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ ls
20220121_raspi_4_bullseye.img.xz
20220121_raspi_4_bullseye.img.xz.sha256
20220121_raspi_4_bullseye.img.xz.sha256.asc
staf@debian11:~/Downloads/iso/debian/raspi$ 
```

Verify that the signature of the checksum file is correct.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ gpg --auto-key-retrieve  --verify 20220121_raspi_4_bullseye.img.xz.sha256.asc
gpg: Signature made Fri 21 Jan 2022 06:19:50 PM CET
gpg:                using EDDSA key 60B3093D96108E5CB97142EFE2F63B4353F45989
gpg: key 2404C9546E145360: public key "Gunnar Wolf <gwolf@gwolf.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1
gpg: Good signature from "Gunnar Wolf <gwolf@gwolf.org>" [unknown]
gpg:                 aka "Gunnar Eyal Wolf Iszaevich <gwolf@iiec.unam.mx>" [unknown]
gpg:                 aka "Gunnar Wolf <gwolf@debian.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 4D14 0506 53A4 02D7 3687  049D 2404 C954 6E14 5360
     Subkey fingerprint: 60B3 093D 9610 8E5C B971  42EF E2F6 3B43 53F4 5989
gpg: WARNING: not a detached signature; file '20220121_raspi_4_bullseye.img.xz.sha256' was NOT verified!
staf@debian11:~/Downloads/iso/debian/raspi$ 
```

You can verify if the checksum file is signed by a trusted key of the Debian project at: [https://db.debian.org/search.cgi](https://db.debian.org/search.cgi).

You can search for the name of the maintainer's key.

If you want to import the key into your trusted key ring execute.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ wget 'https://db.debian.org/fetchkey.cgi?fingerprint=4D14050653A402D73687049D2404C9546E145360' -O gwolf_gpg_public_key.asc
gpg --import gwolf_gpg_public_key.asc
--2022-06-19 11:00:26--  https://db.debian.org/fetchkey.cgi?fingerprint=4D14050653A402D73687049D2404C9546E145360
Resolving db.debian.org (db.debian.org)... 82.195.75.106, 2001:41b8:202:deb:1a1a:0:52c3:4b6a
Connecting to db.debian.org (db.debian.org)|82.195.75.106|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [text/plain]
Saving to: ‘gwolf_gpg_public_key.asc’

gwolf_gpg_public_key.asc                 [ <=>                                                                 ]  19.25K  --.-KB/s    in 0.01s   

2022-06-19 11:00:27 (1.27 MB/s) - ‘gwolf_gpg_public_key.asc’ saved [19709]

gpg: key 2404C9546E145360: 24 signatures not checked due to missing keys
gpg: key 2404C9546E145360: "Gunnar Wolf <gwolf@gwolf.org>" 27 new signatures
gpg: Total number processed: 1
gpg:         new signatures: 27
gpg: no ultimately trusted keys found
staf@debian11:~/Downloads/iso/debian/raspi$
```

To verify the public key is imported execute.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ gpg --list-keys
/home/staf/.gnupg/pubring.kbx
-----------------------------
pub   ed25519 2019-11-22 [SC] [expires: 2024-09-05]
      4D14050653A402D73687049D2404C9546E145360
uid           [ unknown] Gunnar Wolf <gwolf@gwolf.org>
uid           [ unknown] Gunnar Eyal Wolf Iszaevich <gwolf@iiec.unam.mx>
uid           [ unknown] Gunnar Wolf <gwolf@debian.org>
sub   ed25519 2019-11-22 [A] [expires: 2022-09-06]
sub   ed25519 2019-11-22 [S] [expires: 2022-09-06]
sub   cv25519 2019-11-22 [E] [expires: 2022-09-06]

staf@debian11:~/Downloads/iso/debian/raspi$ 
```

Verify the signature again.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ gpg --verify 20220121_raspi_4_bullseye.img.xz.sha256.asc 
gpg: Signature made Fri 21 Jan 2022 06:19:50 PM CET
gpg:                using EDDSA key 60B3093D96108E5CB97142EFE2F63B4353F45989
gpg: Good signature from "Gunnar Wolf <gwolf@gwolf.org>" [unknown]
gpg:                 aka "Gunnar Eyal Wolf Iszaevich <gwolf@iiec.unam.mx>" [unknown]
gpg:                 aka "Gunnar Wolf <gwolf@debian.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 4D14 0506 53A4 02D7 3687  049D 2404 C954 6E14 5360
     Subkey fingerprint: 60B3 093D 9610 8E5C B971  42EF E2F6 3B43 53F4 5989
gpg: WARNING: not a detached signature; file '20220121_raspi_4_bullseye.img.xz.sha256' was NOT verified!
staf@debian11:~/Downloads/iso/debian/raspi$ echo $?
0
staf@debian11:~/Downloads/iso/debian/raspi$ 
```

You can ignore the ```gpg: WARNING: not a detached signature;``` this is just that gpg also tries to verify 
the checksum. If you want to get rid of this warning you can move the checksum to another directory and run the
```gpg verify``` command again. 

## Extract

Extract the download image.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ xz -d 20220121_raspi_4_bullseye.img.xz
staf@debian11:~/Downloads/iso/debian/raspi$ 
``` 

## Copy

Copy the image to keep the original intact.

```bash
staf@debian11:~/Downloads/iso/debian/raspi$ cp 20220121_raspi_4_bullseye.img image
staf@debian11:~/Downloads/iso/debian/raspi$ 
```

# Create tarball

## Verify the image

Verify the image layout with ```fdisk -l```.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# fdisk -l image
Disk image: 1.95 GiB, 2097152000 bytes, 4096000 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xec6a3321

Device     Boot  Start     End Sectors  Size Id Type
image1            8192  819199  811008  396M  c W95 FAT32 (LBA)
image2          819200 4095999 3276800  1.6G 83 Linux
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

We’ll use ```kpartx``` to map the partitions in the image so we can mount them.

Install kpartx.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# apt install kpartx
```

Map the partitions in the image with ```kpartx -ax```, the “-a” option add the image, “-v” makes it verbose so we can see where the partitions are mapped to.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# kpartx -av image
add map loop0p1 (253:3): 0 811008 linear 7:0 8192
add map loop0p2 (253:4): 0 3276800 linear 7:0 819200
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

Create the destination directory.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# mkdir /mnt/chroot
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

Mount the partitions. Debian (and also Ubuntu) uses ```/boot/firmware``` as the raspberry-pi boot filesystem.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# mount /dev/mapper/loop0p2 /mnt/chroot
root@debian11:/home/staf/Downloads/iso/debian/raspi# mount /dev/mapper/loop0p1 /mnt/chroot/boot/firmware/
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

Verify that the filesystems are mounted.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# df -h
Filesystem                     Size  Used Avail Use% Mounted on
udev                           1.9G     0  1.9G   0% /dev
tmpfs                          394M  1.2M  392M   1% /run
/dev/mapper/debian11--vg-root   19G   11G  6.6G  62% /
tmpfs                          2.0G     0  2.0G   0% /dev/shm
tmpfs                          5.0M  4.0K  5.0M   1% /run/lock
/dev/vda1                      470M  264M  182M  60% /boot
tmpfs                          394M  840K  393M   1% /run/user/1000
tmpfs                          394M   48K  394M   1% /run/user/114
/dev/mapper/loop0p2            1.6G  557M  886M  39% /mnt/chroot
/dev/mapper/loop0p1            396M   75M  322M  19% /mnt/chroot/boot/firmware
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

Create the tarball.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# cd /mnt/chroot/
root@debian11:/mnt/chroot# 
```

```bash
root@debian11:/mnt/chroot# tar czvpf /home/staf/Downloads/iso/debian/raspi/debian_bullseye.tgz .
```

Umount

```bash
root@debian11:/mnt/chroot# cd
root@debian11:~# umount /mnt/chroot/boot/firmware
root@debian11:~# umount /mnt/chroot
```

# Partition and create filesystems

## Create partitions

Partition your harddisk delete all partitions if there are partition on the harddisk.

***Make sure that you execute the commands below on the correct harddisk.
I executed my commands on a Virtual Machine.***

I’ll create 3 partitions on my harddisk

* boot partitions of 500MB (Type c ‘W95 FAT32 (LBA)’
* root partitions of 50G
* rest

Empty the partition table.

```bash
root@debian11:~# fdisk /dev/sda

Welcome to fdisk (util-linux 2.36.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): o
Created a new DOS disklabel with disk identifier 0xe93a7e99.

Command (m for help): 
```

Create the boot partition.

```bash
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (65535-117210239, default 65535): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (65535-117210239, default 117210239): +500M

Created a new partition 1 of type 'Linux' and of size 512 MiB.

Command (m for help): 
```

Set type partition type to vfat.

```bash
Command (m for help): t
Selected partition 1
Hex code or alias (type L to list all): c
Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.

Command (m for help): 
```

Create the root partition.

```bash
Command (m for help): t
Selected partition 1
Hex code or alias (type L to list all): c
Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (1114095-117210239, default 1114095): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (1114095-117210239, default 117210239): +50G

Created a new partition 2 of type 'Linux' and of size 50 GiB.

Command (m for help): 
```

Write the partition table to the disk.

```bash
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@debian11:~# 
```

## Create filesystems

### boot file system

The Raspberry PI uses a FAT filesystem for the boot partition.

```bash
root@debian11:~# mkfs.vfat /dev/sda1
mkfs.fat 4.2 (2021-01-31)
root@debian11:~# 
```

### Create the root filesystem

#### Overwrite the root partition with random data

Because we are creating an encrypted filesystem it’s a good idea to overwrite it with random data. We’ll use ```badblocks``` for this.
Another method is to use ```dd if=/dev/random of=/dev/xxx```, the ```dd``` method is probably the best method but is a lot slower.

```bash
root@debian11:~# badblocks -c 10240 -s -w -t random -v /dev/sda2
Checking for bad blocks in read-write mode
From block 0 to 52427999
Testing with random pattern: ^[^[[A^[[A^C3.81% done, 0:49 elapsed. (0/0/0 errors)

Interrupted at block 2027520
root@debian11:~# badblocks -c 10240 -s -w -t random -v /dev/sda2
Checking for bad blocks in read-write mode
From block 0 to 52427999
Testing with random pattern: done                                                 
Reading and comparing: done                                                 
Pass completed, 0 bad blocks found. (0/0/0 errors)
root@debian11:~# 
```
#### Encrypt the root filesystem

##### Benchmark

I ran a ```cryptsetup benchmark``` on one of my Raspberry PI running Manjaro.

```bash
[root@minerva ~]# cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       529049 iterations per second for 256-bit key
PBKDF2-sha256     853889 iterations per second for 256-bit key
PBKDF2-sha512     674759 iterations per second for 256-bit key
PBKDF2-ripemd160  440578 iterations per second for 256-bit key
PBKDF2-whirlpool  165286 iterations per second for 256-bit key
argon2i       4 iterations, 271370 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 295124 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b       108.6 MiB/s       111.8 MiB/s
    serpent-cbc        128b        48.3 MiB/s        49.6 MiB/s
    twofish-cbc        128b        75.5 MiB/s        80.4 MiB/s
        aes-cbc        256b        85.8 MiB/s        87.5 MiB/s
    serpent-cbc        256b        48.8 MiB/s        49.6 MiB/s
    twofish-cbc        256b        75.5 MiB/s        80.6 MiB/s
        aes-xts        256b       112.8 MiB/s       114.0 MiB/s
    serpent-xts        256b        50.0 MiB/s        49.7 MiB/s
    twofish-xts        256b        77.8 MiB/s        81.0 MiB/s
        aes-xts        512b        88.3 MiB/s        89.2 MiB/s
    serpent-xts        512b        50.0 MiB/s        49.6 MiB/s
    twofish-xts        512b        77.9 MiB/s        80.7 MiB/s
[root@minerva ~]# 
```

The aes-xts cipher seems to have the best performance on the RPI4.

##### Create the Luks volume

```bash
root@debian11:~# cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 256 --hash sha256 --use-random /dev/sda2

WARNING!
========
This will overwrite data on /dev/sda2 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/sda2: 
Verify passphrase: 
Ignoring bogus optimal-io size for data device (33553920 bytes).
root@debian11:~# 
```

##### Open the Luks volume

```bash
root@debian11:~# cryptsetup luksOpen /dev/sda2 cryptroot
Enter passphrase for /dev/sda2: 
root@debian11:~# 
```

##### Create the root filesystem

```bash
root@debian11:~# mkfs.ext4 /dev/mapper/cryptroot
mke2fs 1.46.2 (28-Feb-2021)
Creating filesystem with 13102903 4k blocks and 3276800 inodes
Filesystem UUID: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (65536 blocks): done
Writing superblocks and filesystem accounting information: done   

root@debian11:~# 
```

#### Mount and extract

Create a directory to mount the root filesystem.

```bash
root@debian11:~# mkdir -p /mnt/chroot
root@debian11:~# 
```

Mount the root filesystem.

```bash
root@debian11:~# mount /dev/mapper/cryptroot /mnt/chroot/
root@debian11:~# 
```

Debian and also Ubuntu uses ```/boot/firmware``` as the boot partition on a Raspberry PI.

Create the ```/boot/firmware``` directory on the root filesystem.

```bash
root@debian11:~# mkdir -p /mnt/chroot/boot/firmware
root@debian11:~# 
```

Mount the boot filesystem.

```
~# mount /dev/sda1 /mnt/chroot/boot/firmware
~# 
```

Verify that the filesystem are mounted.

```
~# df -h
Filesystem                     Size  Used Avail Use% Mounted on
udev                           1.9G     0  1.9G   0% /dev
tmpfs                          394M  1.2M  393M   1% /run
/dev/mapper/debian11--vg-root   19G   11G  6.9G  60% /
tmpfs                          2.0G     0  2.0G   0% /dev/shm
tmpfs                          5.0M  4.0K  5.0M   1% /run/lock
/dev/vda1                      470M  113M  333M  26% /boot
tmpfs                          394M   48K  394M   1% /run/user/114
tmpfs                          394M   44K  394M   1% /run/user/1000
/dev/mapper/cryptroot           49G   32K   47G   1% /mnt/chroot
/dev/sda1                      500M     0  500M   0% /mnt/chroot/boot/firmware
~# 
```

Extract the tarball.

```bash
root@debian11:~# cd /home/staf/Downloads/iso/debian/raspi
root@debian11:/home/staf/Downloads/iso/debian/raspi# tar xzvpf debian_bullseye.tgz -C /mnt/chroot/
<snip>
root@debian11:/home/staf/Downloads/iso/debian/raspi# sync
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

### chroot

To continue the setup we need to boot or chroot into the operating system. It possible to run ARM64 code on a x86_64 system with qemu - qemu will emulate an ARM64 CPU -.

#### Install the qemu-arm-static package

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# apt install -y qemu-user-static
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  binfmt-support
The following NEW packages will be installed:
  binfmt-support qemu-user-static
0 upgraded, 2 newly installed, 0 to remove and 0 not upgraded.
Need to get 41.1 MB/41.2 MB of archives.
After this operation, 288 MB of additional disk space will be used.
Get:1 http://security.debian.org/debian-security bullseye-security/main amd64 qemu-user-static amd64 1:5.2+dfsg-11+deb11u2 [41.1 MB]
Fetched 22.5 MB in 5s (4,111 kB/s)          
Selecting previously unselected package binfmt-support.
(Reading database ... 147695 files and directories currently installed.)
Preparing to unpack .../binfmt-support_2.2.1-1_amd64.deb ...
Unpacking binfmt-support (2.2.1-1) ...
Selecting previously unselected package qemu-user-static.
Preparing to unpack .../qemu-user-static_1%3a5.2+dfsg-11+deb11u2_amd64.deb ...
Unpacking qemu-user-static (1:5.2+dfsg-11+deb11u2) ...
Setting up qemu-user-static (1:5.2+dfsg-11+deb11u2) ...
Setting up binfmt-support (2.2.1-1) ...
Created symlink /etc/systemd/system/multi-user.target.wants/binfmt-support.service → /lib/systemd/system/binfmt-support.servic
e.
Processing triggers for man-db (2.9.4-2) ...
Scanning processes...                                                                                                         
Scanning linux images...                                                                                                      

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

#### mount proc & co

To be able to run programs in the chroot we need the ```proc```, ```sys``` and ```dev``` filesystems mapped into the chroot.

```bash
root@debian11:~# mount -t proc none /mnt/chroot/proc
root@debian11:~# mount -t sysfs none /mnt/chroot/sys
root@debian11:~# mount -o bind /dev /mnt/chroot/dev
root@debian11:~# mount -o bind /dev/pts /mnt/chroot/dev/pts
root@debian11:~# 
```

#### chroot

Chroot into ARM64 installation.

```bash
root@debian11:~# LANG=C chroot /mnt/chroot/
root@debian11:/# 
```

Set the PATH.

```
root@debian11:/# export PATH=/sbin:/bin:/usr/sbin:/usr/bin
root@debian11:/# 
```

And verify that we are running aarch64.

```
root@debian11:/# uname -a
Linux debian11 5.10.0-15-amd64 #1 SMP Debian 5.10.120-1 (2022-06-09) aarch64 GNU/Linux
root@debian11:/# 
```

#### update

```bash
root@debian11:/# apt update
Get:1 http://deb.debian.org/debian bullseye InRelease [116 kB]                      
Get:2 http://security.debian.org/debian-security bullseye-security InRelease [44.1 kB]
Get:3 http://security.debian.org/debian-security bullseye-security/main arm64 Packages [159 kB]
Get:4 http://security.debian.org/debian-security bullseye-security/main Translation-en [99.8 kB]
Get:5 http://deb.debian.org/debian bullseye/main arm64 Packages [8070 kB]
Get:6 http://deb.debian.org/debian bullseye/main Translation-en [6241 kB]                                                    
Get:7 http://deb.debian.org/debian bullseye/contrib arm64 Packages [40.8 kB]                                                 
Get:8 http://deb.debian.org/debian bullseye/contrib Translation-en [46.9 kB]                                                 
Get:9 http://deb.debian.org/debian bullseye/non-free arm64 Packages [69.6 kB]                                                
Get:10 http://deb.debian.org/debian bullseye/non-free Translation-en [91.3 kB]                                               
Fetched 15.0 MB in 14s (1106 kB/s)                                                                                           
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
34 packages can be upgraded. Run 'apt list --upgradable' to see them.
root@debian11:/# 
```

```bash
root@debian11:/# apt upgrade -y
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
Calculating upgrade... Done
The following NEW packages will be installed:
  linux-image-5.10.0-15-arm64
The following packages will be upgraded:
  base-files bsdutils dpkg fdisk gpgv gzip libblkid1 libc-bin libc6 libcryptsetup12 libexpat1 libfdisk1 liblzma5 libmount1
  libpam-systemd libsmartcols1 libssl1.1 libsystemd0 libudev1 libuuid1 linux-image-5.10.0-11-arm64 linux-image-arm64 mount
  openssl rsyslog systemd systemd-sysv systemd-timesyncd sysvinit-utils tasksel tasksel-data udev util-linux zlib1g
34 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 110 MB of archives.
After this operation, 257 MB of additional disk space will be used.
Get:1 http://security.debian.org/debian-security bullseye-security/main arm64 dpkg arm64 1.20.10 [2513 kB]
Get:2 http://deb.debian.org/debian bullseye/main arm64 base-files arm64 11.1+deb11u3 [70.1 kB]
<snip>
Fetched 110 MB in 22s (4981 kB/s)                                                                                            
Extracting templates from packages: 100%
Preconfiguring packages ...
(Reading database ... 18210 files and directories currently installed.)
Preparing to unpack .../base-files_11.1+deb11u3_arm64.deb ...
Unpacking openssl (1.1.1n-0+deb11u2) over (1.1.1k-1+deb11u1) ...
<snip>
Setting up libexpat1:arm64 (2.2.10-2+deb11u3) ...
Setting up linux-image-5.10.0-15-arm64 (5.10.120-1) ...
I: /vmlinuz is now a symlink to boot/vmlinuz-5.10.0-15-arm64
I: /initrd.img is now a symlink to boot/initrd.img-5.10.0-15-arm64
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-5.10.0-15-arm64
W: Couldn't identify type of root file system for fsck hook
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
/etc/kernel/postinst.d/z50-raspi-firmware:
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
Setting up linux-image-arm64 (5.10.120-1) ...
Setting up linux-image-5.10.0-11-arm64 (5.10.92-2) ...
/etc/kernel/postinst.d/initramfs-tools:
update-initramfs: Generating /boot/initrd.img-5.10.0-11-arm64
W: Couldn't identify type of root file system for fsck hook
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
/etc/kernel/postinst.d/z50-raspi-firmware:
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
Setting up rsyslog (8.2102.0-2+deb11u1) ...
Running in chroot, ignoring request.
Setting up udev (247.3-7) ...
A chroot environment has been detected, udev not started.
Setting up libfdisk1:arm64 (2.36.1-8+deb11u1) ...
Setting up mount (2.36.1-8+deb11u1) ...
Setting up libcryptsetup12:arm64 (2:2.3.7-1+deb11u1) ...
Setting up openssl (1.1.1n-0+deb11u2) ...
Setting up systemd (247.3-7) ...
Initializing machine ID from random generator.
Setting up fdisk (2.36.1-8+deb11u1) ...
Setting up systemd-timesyncd (247.3-7) ...
Setting up systemd-sysv (247.3-7) ...
Setting up libpam-systemd:arm64 (247.3-7) ...
Setting up tasksel (3.68+deb11u1) ...
Setting up tasksel-data (3.68+deb11u1) ...
Processing triggers for initramfs-tools (0.140) ...
update-initramfs: Generating /boot/initrd.img-5.10.0-15-arm64
W: Couldn't identify type of root file system for fsck hook
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
Processing triggers for libc-bin (2.31-13+deb11u3) ...
Processing triggers for dbus (1.12.20-2) ...
root@debian11:/# 
```

#### Install required packages 

It's always useful to have ```apt-file``` installed.

```
root@debian11:/# apt install apt-file
root@debian11:/# apt-file update
```

Install the required packages for the disk encryption.

```
root@debian11:~# apt install busybox cryptsetup dropbear-initramfs
```

### Update boot settings

On Debian 10 "buster", it was required to add ```CRYPTSETUP=y```` to the ````/etc/cryptsetup-initramfs/``` configuration.
This isn't required anymore on Debian 11 "bullseye" the ```update-initramfs``` will automatically detect the encrypted root filesystem and include the required config into the boot initramfs boot image.

Another pitfall might be that the default console on Debian 11 is the serial port on the Raspberry PI. It'll ask for the unlock password on the serial unless you update the console configuration (see below).

#### Label boot partition

Verify labels that are used by Debian GNU/Linux on the Rapberry Pi. Review the labels that are used in ```/etc/fstab```.

```bash
root@debian11:~# cat /etc/fstab 
# The root file system has fs_passno=1 as per fstab(5) for automatic fsck.
LABEL=RASPIROOT / ext4 rw 0 1
# All other file systems have fs_passno=2 as per fstab(5) for automatic fsck.
LABEL=RASPIFIRM /boot/firmware vfat rw 0 2
root@debian11:~# 
```

Label the ```/boot/firmware``` partition with the ```RASPIFIRM```

```bash
root@debian11:/# fatlabel /dev/sda1 "RASPIFIRM"
root@debian11:/# 
```

#### Update fstab

Update ```/etc/fstab``` to use ```cryptroot``` as the root filesystem.

```
root@debian11:~# cd /etc
root@debian11:/etc# vi fstab
```

```
# The root file system has fs_passno=1 as per fstab(5) for automatic fsck.
/dev/mapper/cryptroot / ext4 rw 0 1
# All other file systems have fs_passno=2 as per fstab(5) for automatic fsck.
LABEL=RASPIFIRM /boot/firmware vfat rw 0 2
```

##### Create /etc/cryptab

Update ```/etc/cryptab``` to include the crypted root.

Find the ```UUID``` for the ```cryptroot``` filesystem.
I open a second session to the x86 host that is used during the installation.

```
root@debian11:/etc# ls -l /dev/disk/by-uuid/ | grep -i sda2
lrwxrwxrwx 1 root root 10 Jul  2 06:19 xxxxxxxx-xxxx-xxxx-xxxxxxxxxxxxxxxxx -> ../../sda2
root@debian11:/etc# 
```

If the partition is not list in ```/dev/disk/by-uuid/```, you can also use the ```blkid``` utility to get the ```UUID```

```
root@debian11:/dev/mapper# blkid /dev/sda2
/dev/sda2: UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" TYPE="crypto_LUKS" PARTUUID="xxxxxxxx-xx"
root@debian11:/dev/mapper# 
```

Edit ```/etc/crypttab```.

```
root@debian11:~# vi /etc/crypttab 
root@debian11:~# 
```

```
# <target name> <source device>         <key file>      <options>
cryptroot UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx none luks,discard
```

##### Generated initramfs

Create the boot image and verify that you don't have errors related to the cryptsetup.

```
root@debian11:/etc/default# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-5.10.0-15-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
dropbear: WARNING: Invalid authorized_keys file, SSH login to initramfs won't work!
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
update-initramfs: Generating /boot/initrd.img-5.10.0-11-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
dropbear: WARNING: Invalid authorized_keys file, SSH login to initramfs won't work!
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
root@debian11:/etc/default# 
```

##### cmdline.txt

```cmdline.txt``` is created by ```update-initramfs``` on Debian.

Review the current settings.

```
root@debian11:/boot/firmware# cat cmdline.txt 
console=tty0 console=ttyS1,115200 root=LABEL=RASPIROOT rw fsck.repair=yes net.ifnames=0 cma=64M rootwait 
root@debian11:/boot/firmware# 
```

You can update the settings in ```/etc/default/raspi-firmware```

```bash
root@debian11:/etc# vi /etc/default/raspi-firmware
root@debian11:/etc# 
```

Set the console.

```bash
CONSOLES="tty0"
```

Set the root partition.

```
# ROOTPART=LABEL=RASPIROOT
ROOTPART=/dev/mapper/cryptroot
```

##### Create new ramfs images

```
root@debian11:/etc/default# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-5.10.0-15-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
dropbear: WARNING: Invalid authorized_keys file, SSH login to initramfs won't work!
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
update-initramfs: Generating /boot/initrd.img-5.10.0-11-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
dropbear: WARNING: Invalid authorized_keys file, SSH login to initramfs won't work!
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
root@debian11:/etc/default# cat /boot/firmware/cmdline.txt 
 console=tty0 root=LABEL=RASPIROOT rw fsck.repair=yes net.ifnames=0 cma=64M rootwait 
root@debian11:/etc/default# nvi /etc/crypttab 
root@debian11:/etc/default#
``` 

### Remote unlock

#### Authorized keys

Copy ( or copy /paste ) your ssh public key to ```/etc/dropbear-initramfs/authorized_keys```.

```bash
root@debian11:/etc/default# cat > /etc/dropbear-initramfs/authorized_keys
root@debian11:/etc/default# chmod 0600 /etc/dropbear-initramfs/authorized_keys
root@debian11:/etc/default# 
```

#### Fixed Ip address

If you want to use a fixed ip address edit ```/etc/initramfs-tools/initramfs.conf```

```bash
root@debian11:/etc/default# vi /etc/initramfs-tools/initramfs.conf 
root@debian11:/etc/default# 
```

The syntax is ```IP=<ip_address>::<gateway>:<subnet>:<hostname>```

```bash
IP=192.168.66.2::192.168.66.1:255.255.255.0:mypi
```

#### Port

The SSHD server (dropbear) in the Initramfs has a different host-key as the system hos-keypair.

It's possible to convert the system (OpenSSH) host-key to an initramfs (Dropbear) host-keypair.

The system host-keypair has a private key and a public key. When they're on the initramfs image they are 
encrypted on the boot filesystem. For security reasons, it's probably better to use different key pairs.

But this will change the host-key depending if you are booting in boot initramfs or system.
We'd use a different IP address or use a different port.

To change the port edit ```/etc/dropbear-initramfs/config```.

```
root@debian11:/etc# vi /etc/dropbear-initramfs/config
```

```
DROPBEAR_OPTIONS="-I 180 -j -k -p 2222 -s"
```


#### Recreate boot iniramfs

```bash
root@debian11:/etc/default# update-initramfs -u -k all
update-initramfs: Generating /boot/initrd.img-5.10.0-15-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
update-initramfs: Generating /boot/initrd.img-5.10.0-11-arm64
cryptsetup: ERROR: cryptroot: Source mismatch
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
root@debian11:/etc/default# 
```

### Finish installation

#### Set the root password

```
root@debian11:/etc/default# passwd root
New password: 
Retype new password: 
passwd: password updated successfully
root@debian11:/etc/default# 
```

#### Install some useful tools

I use ansible to configure my systems. So I installed the ```sudo``` and ```python3``` package.

```
root@debian11:/etc/default# apt install sudo vim python3
```

#### Create user

```bash
root@debian11:/etc/default# adduser staf
Adding user `staf' ...
Adding new group `staf' (1000) ...
Adding new user `staf' (1000) with group `staf' ...
Creating home directory `/home/staf' ...
Copying files from `/etc/skel' ...
New password: 
Retype new password: 
passwd: password updated successfully
Changing the user information for staf
Enter the new value, or press ENTER for the default
	Full Name []: 
	Room Number []: 
	Work Phone []: 
	Home Phone []: 
	Other []: 
Is the information correct? [Y/n] 
root@debian11:/etc/default# 
```

#### sudo

Add the user to the sudo group.

```bash
root@debian11:/etc/default# usermod -a -G sudo staf
root@debian11:/etc/default# 
```

Verify that the use can execute commands as ```root```.

```
root@debian11:/etc/default# export EDITOR=vi
root@debian11:/etc/default# visudo 
```

```
<snip>
# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) ALL
<snip>
```

#### Enable the ssh server

```bash
root@debian11:/etc/default# systemctl enable ssh
Synchronizing state of ssh.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable ssh
root@debian11:/etc/default# 
```

### Clean up

#### Exit chroot

Exit the chroot.

```bash
root@debian11:/etc/default# exit
exit
root@debian11:~# uname -a
Linux debian11 5.10.0-15-amd64 #1 SMP Debian 5.10.120-1 (2022-06-09) x86_64 GNU/Linux
root@debian11:~# 
``` 

#### Umount the chroot filesystems

Verify the mounted chroot filesystems.

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# mount | grep -i chroot | awk '{print $3}'
/mnt/chroot
/mnt/chroot/boot/firmware
/mnt/chroot/proc
/mnt/chroot/sys
/mnt/chroot/dev
/mnt/chroot/dev/pts
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

I used the oneliner belong to umount them.

```
root@debian11:/home/staf/Downloads/iso/debian/raspi# mount | grep -i chroot | awk '{print $3}' | sort -r | xargs -n1 umount 
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

Close the luks volume…

```bash
root@debian11:/home/staf/Downloads/iso/debian/raspi# cryptsetup luksClose cryptroot
root@debian11:/home/staf/Downloads/iso/debian/raspi# 
```

# Boot

## Fingers crossed

Connect the usb disk to the raspberry pi and power it on. If you are lucky the PI will boot from the USB device and ask you to type the password to decrypt the root filesystem.

## remote-unlock

```bash
[staf@vicky ~]$ ssh root@minerva
The authenticity of host 'minerva (192.168.1.30)' can't be established.
ED25519 key fingerprint is SHA256:htnkR8sj1WlF6tDexGhvf5BEDeqEObKBYr/XZWJLdjE.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'minerva' (ED25519) to the list of known hosts.
To unlock root partition, and maybe others like swap, run `cryptroot-unlock`.


BusyBox v1.30.1 (Debian 1:1.30.1-6+b3) built-in shell (ash)
Enter 'help' for a list of built-in commands.

~ # 
```

```
~ # cryptroot-unlock
Please unlock disk cryptroot: 
Error: Timeout reached while waiting for PID 192.
~ # Connection to minerva closed by remote host.
Connection to minerva closed.
[staf@vicky ~]$ 
```

# Links

* [https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/)
* [https://www.kali.org/docs/arm/raspberry-pi-with-luks-full-disk-encryption/ ](https://www.kali.org/docs/arm/raspberry-pi-with-luks-full-disk-encryption/)
* [https://www.torstens-buecherecke.de/raspberry-pi-mit-ubuntu-20-04-lts-btrfs-und-luks-verschluesselung-des-root-verzeichnisses-remote-login-kommentar/]( https://www.torstens-buecherecke.de/raspberry-pi-mit-ubuntu-20-04-lts-btrfs-und-luks-verschluesselung-des-root-verzeichnisses-remote-login-kommentar/)
* [https://wiki.debian.org/RaspberryPi4#RPI_firmware_loads_u-boot.2C_which_loads_kernel.2Finitramfs](https://wiki.debian.org/RaspberryPi4#RPI_firmware_loads_u-boot.2C_which_loads_kernel.2Finitramfs)
* [https://codeberg.org/keks24/raspberry-pi-luks](https://codeberg.org/keks24/raspberry-pi-luks)
* [https://raspberrypi.stackexchange.com/questions/136595/debian-11-luks-mod-hang-freeze-when-init-is-supposed-to-start](https://raspberrypi.stackexchange.com/questions/136595/debian-11-luks-mod-hang-freeze-when-init-is-supposed-to-start)
* [https://www.dwarmstrong.org/remote-unlock-dropbear/](https://www.dwarmstrong.org/remote-unlock-dropbear/)
* [https://www.cyberciti.biz/security/how-to-unlock-luks-using-dropbear-ssh-keys-remotely-in-linux/](https://www.cyberciti.biz/security/how-to-unlock-luks-using-dropbear-ssh-keys-remotely-in-linux/)

***Have fun!***
