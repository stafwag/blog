---
layout: post
title: "Manjaro on the RPI4 with full disk encryption"
date: 2020-07-12 19:45:50 +0200
comments: true
categories: [ manjaro, security, archlinux, raspberrypi, rpi4 ] 
excerpt_separator: <!--more-->
---

The [Raspberry PI](https://www.raspberrypi.org/) has become more and more powerful in the recent years, maybe too powerful to be a “maker board”. The higher CPU power and availability of more memory - up to 8GB - makes it more suitable for home server usage.

The latest firmware (EEPROM) enables booting from a USB device. To enable USB boot the EEPROM on the raspberry needs to be updated to the latest version and the bootloader that comes with the operating system - the start\*.elf, etc files on the boot filesystem - needs to support it.

I always try to use filesystem encryption. You'll find my journey to install GNU/Linux on an encrypted filesystem below. 

# 64 Bits operating systems

The Raspberry PI 4 has a 64 bits CPU, the default operating system - Raspberry Pi OS (previously called Raspbian) - for the Rasberry PI is still 32 bits to take full advantage of the 64bits CPU a 64 bits operating system is required.

You’ll find an overview GNU/Linux distributions for RPI4 below.

<!--more-->

* **Raspberry PI OS**

  [Raspberry PI OS](https://www.raspberrypi.org/downloads/raspberry-pi-os/) is the default operating system for the Raspberry Pi.
  The operating system is 32 bits.

  There is a beta version available with 64 bits support [available](https://www.raspberrypi.org/forums/viewtopic.php?t=275370).

* **Ubuntu**

  [Ubuntu for the raspberry pi](https://ubuntu.com/download/raspberry-pi) has 64 bits support. But boot process isn’t fully compatible with USB boot.
  The bootloader isn’t up-to-date enough to support it and the u-boot loader isn’t yet updated to support USB boot.

* **Kali Linux**

  [Kali Linux](https://www.kali.org/docs/arm/kali-linux-raspberry-pi/) is another 64 bits operation system for the Raspberry Pi. The bootloader isn’t updated enough to support USB boot.

* **Arch Linux ARM**

  [Arch Linux ARM](https://archlinuxarm.org/) has an install image for the Raspberry PI 4 the default install image is still 32 bits. Arch Linux ARM has 64 bits support so you could build you own image with the 64bits packages and a custom kernel.

* **Manjaro**

  [Manjaro](https://manjaro.org/download/#raspberry-pi-4) is based on Arch Linux and has 64 bits support for the raspberry pi. Manjaro is a rolling distribution the boot loader is up to date enough to support USB boot.

* **Other**

  The list above are the GNU/Linux distributions that I considered for my Raspberry Pi 4. There are - as always - other options. The distributions that don't support booting from a USB device will probably support it soon.

I was looking for a GNU/Linux distribution with 64 bits support and USB boot support and went with Manjaro.

The installation process to install Manjaro on an encrypted filesystem is similar to the installation on an x84_64 system running Archlinux. 
See my previous blog posts: [Install Arch on an encrypted btrfs partition](https://stafwag.github.io/blog/blog/2016/08/30/arch-on-an-encrypted-btrfs-partition/) and [Install Parabola GNU/Linux on an Encrypted btrfs logical volume](https://stafwag.github.io/blog/blog/2017/05/25/install-parabola-gnu-slash-linux-on-an-encrypted-btrfs-logical-volume/).


# USB boot

To enable the raspberry pi 4 to boot from USB, you need to update your firmware. The boot loader also needs to be updated to enable booting from a USB device.

## Get the latest firmware

Manjaro didn't include the latest stable firmware to enable USB boot, so I used the 64 bits beta Raspberry PI OS to update the firmware.


Update Raspberry PI OS to get the latest firmware.

```
pi@raspberrypi:~ $ sudo apt-get update
Hit:1 http://archive.raspberrypi.org/debian buster InRelease
Hit:2 http://deb.debian.org/debian buster InRelease
Hit:3 http://deb.debian.org/debian-security buster/updates InRelease
Hit:4 http://deb.debian.org/debian buster-updates InRelease
Reading package lists... Done
pi@raspberrypi:~ $ sudo apt-get full-upgrade
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Calculating upgrade... Done
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
pi@raspberrypi:~ $ 
```

Verify that the latest firmware is available.

The latest stable bootloader is located at ```/lib/firmware/raspberrypi/bootloader/stable```.

```
pi@raspberrypi:~ $ cd /lib/firmware/raspberrypi/
pi@raspberrypi:/lib/firmware/raspberrypi $ ls
bootloader
pi@raspberrypi:/lib/firmware/raspberrypi $ cd bootloader/stable/
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ 
```

Verify that the pieeprom > 2020-06-xx is available.

```
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ ls -l
total 1220
-rw-r--r-- 1 root root 524288 Apr 23 17:53 pieeprom-2020-04-16.bin
-rw-r--r-- 1 root root 524288 Jun 17 11:15 pieeprom-2020-06-15.bin
-rw-r--r-- 1 root root  98148 Jun 17 11:15 recovery.bin
-rw-r--r-- 1 root root  98904 Feb 28 15:41 vl805-000137ad.bin
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ 
```

## Get the current version

Execute ```vcgencmd bootloader_version``` to get the current firmware version.

*Please note that I already updated the firmware in the output below.*

```
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ vcgencmd bootloader_version
Jun 15 2020 14:36:19
version c302dea096cc79f102cec12aeeb51abf392bd781 (release)
timestamp 1592228179
```

## update

```
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ sudo rpi-eeprom-update -d -f  ./pieeprom-2020-06-15.bin
BCM2711 detected
VL805 firmware in bootloader EEPROM
BOOTFS /boot
*** INSTALLING ./pieeprom-2020-06-15.bin  ***
BOOTFS /boot
EEPROM update pending. Please reboot to apply the update.
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ 
```

Reboot. 

```
pi@raspberrypi:/lib/firmware/raspberrypi/bootloader/stable $ sudo reboot
```

Verify the version again.

```
pi@raspberrypi:~ $ vcgencmd bootloader_version
Jun 15 2020 14:36:19
version c302dea096cc79f102cec12aeeb51abf392bd781 (release)
timestamp 1592228179
pi@raspberrypi:~ $ 
```

The Raspberry PI is ready to boot from USB.


# Install Manjaro on an encrypted filesystem

Manjaro will run an install script after the RPI is booted to complete the installion.

* We have two options boot the pi from the standard non-encrypted image and extract/move it to an encrypted filesystem.
* Extract the installation image and move the content to an encrypted filesystem.

You'll find my journey of the second option below. The host system to extract/install the image is an x86_64 system running Archlinux.

## Download and copy

Download and verify the Manjaro image from: [https://www.manjaro.org/download/#raspberry-pi-4](https://www.manjaro.org/download/#raspberry-pi-4).

Copy the image to keep the original intact.

```
[root@vicky manjaro]# cp Manjaro-ARM-xfce-rpi4-20.06.img image
```

## Create tarball

### Verify the image

Verify the image layout with ```fdisk -l```. 

```
[root@vicky manjaro]# fdisk -l image
Disk image: 4.69 GiB, 5017436160 bytes, 9799680 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x090a113e

Device     Boot  Start     End Sectors   Size Id Type
image1           62500  500000  437501 213.6M  c W95 FAT32 (LBA)
image2          500001 9799679 9299679   4.4G 83 Linux
[root@vicky manjaro]# 
```

We'll use ```kpartx``` to map the partitions in the image so we can mount them.
kpartx is part of the ```multipath-tools```.

Map the partitions in the image with ```kpartx -ax```, the "-a" option add the image, "-v" makes it verbose so we can see where the partitions are mapped to. 

```
[root@vicky manjaro]# kpartx -av image
add map loop1p1 (254:10): 0 437501 linear 7:1 62500
add map loop1p2 (254:11): 0 9299679 linear 7:1 500001
[root@vicky manjaro]#
```

Create the destination directory.

```
[root@vicky manjaro]# mkdir /mnt/chroot
```

Mount the partitions.

```
[root@vicky manjaro]# mount /dev/mapper/loop1p2 /mnt/chroot
[root@vicky manjaro]# mount /dev/mapper/loop1p1 /mnt/chroot/boot
[root@vicky manjaro]#
```

Create the tarball.

```
[root@vicky manjaro]# cd /mnt/chroot/
[root@vicky chroot]# tar czvpf /home/staf/Downloads/isos/manjaro/Manjaro-ARM-xfce-rpi4-20.06.tgz .
```

Umount.

```
[root@vicky ~]# umount /mnt/chroot/boot 
[root@vicky ~]# umount /mnt/chroot
[root@vicky ~]# cd /home/staf/Downloads/isos/manjaro/
[root@vicky manjaro]# kpartx -d image
loop deleted : /dev/loop1
[root@vicky manjaro]# 
```

## Partition and create filesystems

### Partition

Partition your harddisk delete all partitions if there are partition on the harddisk.

I'll create 3 partitions on my harddisk 

* boot partitions of 500MB (Type c 'W95 FAT32 (LBA)'
* root partitions of 50G
* rest


```
[root@vicky ~]# fdisk /dev/sdh

Welcome to fdisk (util-linux 2.35.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x49887ce7.

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-976773167, default 2048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-976773167, default 976773167): +500M

Created a new partition 1 of type 'Linux' and of size 500 MiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 2
First sector (1026048-976773167, default 1026048): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (1026048-976773167, default 976773167): +50G

Created a new partition 2 of type 'Linux' and of size 50 GiB.

Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (3,4, default 3): 
First sector (105883648-976773167, default 105883648): 
Last sector, +/-sectors or +/-size{K,M,G,T,P} (105883648-976773167, default 976773167): 

Created a new partition 3 of type 'Linux' and of size 415.3 GiB.

Command (m for help): t
Partition number (1-3, default 3): 1
Hex code (type L to list all codes): c

Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.

w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
Command (m for help):  
```

### Create the boot file system

The raspberry pi uses a FAT filesystem for the boot partition.

```
[root@vicky ~]# mkfs.vfat /dev/sdh1
mkfs.fat 4.1 (2017-01-24)
[root@vicky ~]# 
```

### Create the root filesystem

#### Overwrite the root partition with random data

Because we are creating an encrypted filesystem it’s a good idea to overwrite it with random data.
We’ll use ```badblocks``` for this. Another method is to use “dd if=/dev/random of=/dev/xxx”, the “dd” method is probably the best method but is a lot slower.

```
[root@vicky ~]# badblocks -c 10240 -s -w -t random -v /dev/sdh2
Checking for bad blocks in read-write mode
From block 0 to 52428799
Testing with random pattern: done                                                 
Reading and comparing: done                                                 
Pass completed, 0 bad blocks found. (0/0/0 errors)
[root@vicky ~]# 
```

#### Encrypt the root filesystem
##### Benchmark

I booted the RPI4 from a sdcard to verify the encryption speed by executing the ```cryptsetup benchmark```.

```
[root@minerva ~]# cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       398395 iterations per second for 256-bit key
PBKDF2-sha256     641723 iterations per second for 256-bit key
PBKDF2-sha512     501231 iterations per second for 256-bit key
PBKDF2-ripemd160  330156 iterations per second for 256-bit key
PBKDF2-whirlpool  124356 iterations per second for 256-bit key
argon2i       4 iterations, 319214 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
argon2id      4 iterations, 321984 memory, 4 parallel threads (CPUs) for 256-bit key (requested 2000 ms time)
#     Algorithm |       Key |      Encryption |      Decryption
        aes-cbc        128b        23.8 MiB/s        77.7 MiB/s
    serpent-cbc        128b               N/A               N/A
    twofish-cbc        128b        55.8 MiB/s        56.2 MiB/s
        aes-cbc        256b        17.4 MiB/s        58.9 MiB/s
    serpent-cbc        256b               N/A               N/A
    twofish-cbc        256b        55.8 MiB/s        56.1 MiB/s
        aes-xts        256b        85.0 MiB/s        74.9 MiB/s
    serpent-xts        256b               N/A               N/A
    twofish-xts        256b        61.1 MiB/s        60.4 MiB/s
        aes-xts        512b        65.4 MiB/s        57.4 MiB/s
    serpent-xts        512b               N/A               N/A
    twofish-xts        512b        61.3 MiB/s        60.3 MiB/s
[root@minerva ~]# 
```

##### Create the Luks volume

The aes-xts cipher seems to have the best performance on the RPI4.

```
[root@vicky ~]# cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 256 --hash sha256 --use-random /dev/sdh2

WARNING!
========
This will overwrite data on /dev/sdh2 irrevocably.

Are you sure? (Type 'yes' in capital letters): YES
Enter passphrase for /dev/sdh2: 
Verify passphrase: 
WARNING: Locking directory /run/cryptsetup is missing!
[root@vicky ~]# 
```

##### Open the Luks volume

```
[root@vicky ~]# cryptsetup luksOpen /dev/sdh2 cryptroot
Enter passphrase for /dev/sdh2: 
[root@vicky ~]# 
```

#### Create the root filesystem

```
[root@vicky ~]# mkfs.ext4 /dev/mapper/cryptroot
mke2fs 1.45.6 (20-Mar-2020)
Creating filesystem with 13103104 4k blocks and 3276800 inodes
Filesystem UUID: 557677f1-9705-4beb-8c8b-e36c552730f3
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (65536 blocks): done
Writing superblocks and filesystem accounting information: done   

[root@vicky ~]# 
```

## Mount and extract

Mount the root filesystem.

```
[root@vicky ~]# mount /dev/mapper/cryptroot /mnt/chroot
[root@vicky ~]# mkdir -p /mnt/chroot/boot
[root@vicky ~]# mount /dev/sdh1 /mnt/chroot/boot
[root@vicky ~]# 
```

And extract the tarball.

```
[root@vicky manjaro]# cd /home/staf/Downloads/isos/manjaro/
[root@vicky manjaro]# tar xzvf Manjaro-ARM-xfce-rpi4-20.06.tgz -C /mnt/chroot/
[root@vicky manjaro]# sync
```

## chroot

To continue the setup we need to boot or chroot into the operating system.
It possible to run ARM64 code on a x86_64 system with qemu - qemu will emulate an arm64 CPU -.

#### Install qemu-arm-static 

Install the qemu-arm package. It not in the main Archlinux distribution but it's available as a AUR.

```
[staf@vicky ~]$ yay -S qemu-arm-static 
```

#### copy qemu-arm-static

Copy the ```qemu-arm-static``` into the chroot.

```
[root@vicky manjaro]# cp /usr/bin/qemu-arm-static /mnt/chroot/usr/bin/
[root@vicky manjaro]# 
```

####  mount proc & co

To be able to run programs in the chroot we need the ```proc```, ```sys``` and ```dev```
filesystems mapped into the chroot.

```
[root@vicky ~]# mount -t proc none /mnt/chroot/proc
[root@vicky ~]# mount -t sysfs none /mnt/chroot/sys
[root@vicky ~]# mount -o bind /dev /mnt/chroot/dev
[root@vicky ~]# mount -o bind /dev/pts /mnt/chroot/dev/pts
[root@vicky ~]# 
```

#### chroot

Chroot into ARM64 installation.

```
LANG=C chroot /mnt/chroot/
```

Set the PATH.

```
[root@vicky /]# export PATH=/sbin:/bin:/usr/sbin:/usr/bin
```

And verify that we are running aarch64.

```
[root@vicky /]# uname -a
Linux vicky 5.6.19.a-1-hardened #1 SMP PREEMPT Sat, 20 Jun 2020 15:16:50 +0000 aarch64 GNU/Linux
[root@vicky /]# 
```

### Update and install vi

Update all packages to the latest version.

```
[root@vicky /]# pacman -Syu
```

We need an editor.

```
root@vicky /]# pacman -S vi
resolving dependencies...
looking for conflicting packages...

Packages (1) vi-1:070224-4

Total Download Size:   0.15 MiB
Total Installed Size:  0.37 MiB

:: Proceed with installation? [Y/n] y
:: Retrieving packages...
 vi-1:070224-4-aarch64                         157.4 KiB  2.56 MiB/s 00:00 [##########################################] 100%
(1/1) checking keys in keyring                                             [##########################################] 100%
(1/1) checking package integrity                                           [##########################################] 100%
(1/1) loading package files                                                [##########################################] 100%
(1/1) checking for file conflicts                                          [##########################################] 100%
(1/1) checking available disk space                                        [##########################################] 100%
:: Processing package changes...
(1/1) installing vi                                                        [##########################################] 100%
Optional dependencies for vi
    s-nail: used by the preserve command for notification
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...
[root@vicky /]# 
```

### mkinitcpio

#### HOOKS

Add ```encrypt``` to ```HOOKS``` before ```filesystems``` in ```/etc/mkinitcpio.conf```.

```
[root@vicky /]#  vi /etc/mkinitcpio.conf
```

```
HOOKS=(base udev autodetect modconf block encrypt filesystems keyboard fsck)
```

#### Create the boot image

```
[root@vicky /]# ls -l /etc/mkinitcpio.d/
total 4
-rw-r--r-- 1 root root 246 Jun 11 11:06 linux-rpi4.preset
[root@vicky /]# 
```

```
[root@vicky /]# mkinitcpio -p linux-rpi4
==> Building image from preset: /etc/mkinitcpio.d/linux-rpi4.preset: 'default'
  -> -k 4.19.127-1-MANJARO-ARM -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
==> Starting build: 4.19.127-1-MANJARO-ARM
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [encrypt]
==> ERROR: module not found: `dm_integrity'
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> WARNING: errors were encountered during the build. The image may not be complete.
[root@vicky /]#
```

#### update boot settings...

Get the UUID for the boot and the root partition.

```
[root@vicky boot]# ls -l /dev/disk/by-uuid/ | grep -i sdh
lrwxrwxrwx 1 root root 12 Jul  8 11:42 xxxx-xxxx -> ../../sdh1
lrwxrwxrwx 1 root root 12 Jul  8 12:44 xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -> ../../sdh2
[root@vicky boot]# 
```

The Raspberry PI uses ```cmdline.txt``` to specify the boot options.

```
[root@vicky ~]# cd /boot
[root@vicky boot]# 
```

```
[root@vicky boot]# cp cmdline.txt cmdline.txt_org
[root@vicky boot]# 
```

```
cryptdevice=/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx1:cryptroot root=/dev/mapper/cryptroot rw rootwait console=ttyAMA0,115200 console=t
ty1 selinux=0 plymouth.enable=0 smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=ttyAMA0,115200 elevator=noop snd-bcm2835.enable_compat
_alsa=0
```

#### fstab

```
[root@vicky etc]# cp fstab fstab_org
[root@vicky etc]# vi fstab
[root@vicky etc]# 
```

```
# Static information about the filesystems.
# See fstab(5) for details.

# <file system> <dir> <type> <options> <dump> <pass>
UUID=xxxx-xxxx  /boot   vfat    defaults        0       0
```

#### Finish your setup

Set the root password.

```
[root@vicky etc]# passwd
```

Set the timezone.

```
[root@vicky etc]# ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime
```

Generate the required locales.

```
[root@vicky etc]# vi /etc/locale.gen 
[root@vicky etc]# locale-gen
```

Set the hostname.

```
[root@vicky etc]# vi /etc/hostname
```

#### clean up

Exit chroot

```
[root@vicky etc]# exit
exit
[root@vicky ~]# uname -a
Linux vicky 5.6.19.a-1-hardened #1 SMP PREEMPT Sat, 20 Jun 2020 15:16:50 +0000 x86_64 GNU/Linux
[root@vicky ~]# 
```

Make sure that there are no processes still running from the chroot.

```
[root@vicky ~]# ps aux | grep -i qemu
root      160666  0.0  0.1 323228 35468 ?        Ssl  16:50   0:00 /usr/bin/qemu-aarch64-static /usr/bin/gpg-agent --homedir /etc/pacman.d/gnupg --use-standard-socket --daemon
root      203274  0.0  0.0   6812  2188 pts/1    S+   17:14   0:00 grep -i qemu
[root@vicky ~]# 
```

Kill the processes from the chroot.

```
[root@vicky ~]# kill 160666
[root@vicky ~]# 
```

Umount the chroot filesystems.

```
[root@vicky manjaro]# mount | grep -i chroot | awk '{print $3}'
/mnt/chroot
/mnt/chroot/boot
/mnt/chroot/proc
/mnt/chroot/sys
/mnt/chroot/dev
/mnt/chroot/dev/pts
[root@vicky manjaro]# 
```

```
[root@vicky manjaro]#  mount | grep -i chroot | awk '{print $3}' | xargs -n1 umount 
umount: /mnt/chroot: target is busy.
umount: /mnt/chroot/dev: target is busy.
[root@vicky manjaro]#  mount | grep -i chroot | awk '{print $3}' | xargs -n1 umount 
umount: /mnt/chroot: target is busy.
[root@vicky manjaro]#  mount | grep -i chroot | awk '{print $3}' | xargs -n1 umount 
[root@vicky manjaro]# 
```

Close the luks volume...

```
[root@vicky ~]# cryptsetup luksClose cryptroot
[root@vicky ~]# sync
[root@vicky ~]# 
```

# Boot

Connect the usb disk to the raspberry pi and power it on. If you are lucky the PI will boot from the USB device and ask you to type the password to decrypt the root filesystem.


***Have fun!***

# Links

* [https://www.kali.org/docs/arm/raspberry-pi-full-encryption/](https://www.kali.org/docs/arm/raspberry-pi-full-encryption/)
* [https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/](https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/)


