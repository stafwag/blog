---
layout: post
title: "Manjaro on the RPI4 with full disk encryption and remote unlock"
date: 2021-08-08 19:45:50 +0200
comments: true
categories: [ manjaro, security, archlinux, raspberrypi, rpi4. k3s, kubernetes, ssh, dropbear ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/picluster/firstimage.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/picluster/firstimage.jpg' | remove_first:'/' | absolute_url }}" class="right" width="680" height="415" alt="pi cluster" /> </a>

Last year I got a raspberry pi 4 to play with and [installed Manjaro on it](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/).

The main reason I went with Manjaro was that the ArchLinux Arm image/tgz for the Raspberry Pi 4 was still 32 bits, or you needed to create-your-own kernel.

But started to like Manjaro Linux, it provided a stable base with regular updates. This year I upgraded my setup with 2 additional Raspberry Pi 4 to provide clustering for my k3s (Kubernetes) setup. I used virtual machines on the Raspberry Pi to host the k3s nodes. Also because want to the Pi for other tasks and virtual machines makes it easier to split the resources. It's also an "abstraction layer" if you want to combine the cluster with other ARM64 systems in the future.

I always (try to) to full disk encryption, when you have multiple nodes it’s important to be able to unlock the encryption remotely.

<!--more-->

# Install Manjaro on an encrypted filesystem

Manjaro will run an install script after the RPI is booted to complete the installion.

* We have two options boot the pi from the standard non-encrypted image and extract/move it to an encrypted filesystem.
* Extract the installation image and move the content to an encrypted filesystem.

You'll find my journey of the second option below.
The setup is mainly the same as I did last year, but with support to unlock the encryption with ssh.

The host system to extract/install the image is an x86_64 system running Archlinux.

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
[root@vicky chroot]# tar czvpf /home/staf/Downloads/isos/manjaro/Manjaro-ARM-xfce-rpi4-21.07.tgz .
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
[root@vicky tmp]# mkfs.vfat /dev/sdh1
mkfs.fat 4.2 (2021-01-31)
[root@vicky tmp]# 
```

### Create the root filesystem

#### Overwrite the root partition with random data

```
[root@vicky tmp]# dd if=/dev/urandom of=/dev/sdg2 bs=4096 status=progress
53644914688 bytes (54 GB, 50 GiB) copied, 682 s, 78.7 MB/s 
dd: error writing '/dev/sdg2': No space left on device
13107201+0 records in
13107200+0 records out
53687091200 bytes (54 GB, 50 GiB) copied, 687.409 s, 78.1 MB/s
[root@vicky tmp]# 
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
[root@vicky tmp]# mkfs.ext4 /dev/mapper/cryptroot
mke2fs 1.46.3 (27-Jul-2021)
Creating filesystem with 13103104 4k blocks and 3276800 inodes
Filesystem UUID: 65c19eb5-d650-4d8a-8335-ef792604009d
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (65536 blocks): done
Writing superblocks and filesystem accounting information: done   

[root@vicky tmp]# 
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
[root@vicky manjaro]# tar xpzvf Manjaro-ARM-xfce-rpi4-21.07.tgz -C /mnt/chroot/
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

For dns resolution to work you need to mount ```/run``` into the chroot, and start the 
systemd-resolved.service.

```
[root@vicky ~]# mount -t proc none /mnt/chroot/proc
[root@vicky ~]# mount -t sysfs none /mnt/chroot/sys
[root@vicky ~]# mount -o bind /dev /mnt/chroot/dev
[root@vicky ~]# mount -o bind /dev/pts /mnt/chroot/dev/pts
[root@vicky ~]# mount -o bind /run /mnt/chroot/run/
[root@vicky ~]# 
```

#### dns

Start the ```systemd-resolved.service``` on you host system.
This is required to have dns available in your chroot during the installation.

Alternativaly you can use a proxy during the installation.

```
[root@vicky ~]# systemctl start systemd-resolved.service 
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
Linux vicky 5.12.19-hardened1-1-hardened #1 SMP PREEMPT Tue, 20 Jul 2021 17:48:41 +0000 aarch64 GNU/Linux
[root@vicky /]# 
```

### Update and install vi

Update the public keyring


```
[root@vicky /]# pacman-key --init
gpg: /etc/pacman.d/gnupg/trustdb.gpg: trustdb created
gpg: no ultimately trusted keys found
gpg: starting migration from earlier GnuPG versions
gpg: porting secret keys from '/etc/pacman.d/gnupg/secring.gpg' to gpg-agent
gpg: migration succeeded
==> Generating pacman master key. This may take some time.
gpg: Generating pacman keyring master key...
gpg: key DC12547C06A24CDD marked as ultimately trusted
gpg: directory '/etc/pacman.d/gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/etc/pacman.d/gnupg/openpgp-revocs.d/55620B2ED4DE18F5923A2451DC12547C06A24CDD.rev'
gpg: Done
==> Updating trust database...
gpg: marginals needed: 3  completes needed: 1  trust model: pgp
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
[root@vicky /]# 
```

```
[root@vicky /]# pacman-key --refresh-keys
[root@vicky /]#
```

```
[root@vicky etc]# pacman -Qs keyring
local/archlinux-keyring 20210616-1
    Arch Linux PGP keyring
local/archlinuxarm-keyring 20140119-1
    Arch Linux ARM PGP keyring
local/manjaro-arm-keyring 20200210-1
    Manjaro-Arm PGP keyring
local/manjaro-keyring 20201216-1
    Manjaro PGP keyring
[root@vicky etc]# 
```

```
[root@vicky etc]# pacman-key --populate archlinux manjaro archlinuxarm manjaro-arm
```

Update all packages to the latest version.

```
[root@vicky etc]# pacman -Syyu
:: Synchronizing package databases...
 core                                   237.4 KiB   485 KiB/s 00:00 [#####################################] 100%
 extra                                    2.4 MiB  2.67 MiB/s 00:01 [#####################################] 100%
 community                                6.0 MiB  2.74 MiB/s 00:02 [#####################################] 100%
:: Some packages should be upgraded first...
resolving dependencies...
looking for conflicting packages...

Packages (4) archlinux-keyring-20210802-1  manjaro-arm-keyring-20210731-1  manjaro-keyring-20210622-1
             manjaro-system-20210716-1

Total Installed Size:  1.52 MiB
Net Upgrade Size:      0.01 MiB

:: Proceed with installation? [Y/n] 

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

### Unlock the encryption remotely

When you have multiple systems it's handy to be able to unlock the encryption remotely.

### Install the required mkinitcpio packages

```
[root@vicky /]# pacman -S mkinitcpio-utils mkinitcpio-netconf mkinitcpio-dropbear
```

### mkinitcpio

#### HOOKS

Add ```netconf dropbear encryptssh``` to ```HOOKS``` before ```filesystems``` in ```/etc/mkinitcpio.conf```.

Don't include the ```encrypt``` as this will cause the boot image to try the unlock the encryption twice and will
your system will fail to boot.

```
[root@vicky /]#  vi /etc/mkinitcpio.conf
```

```
HOOKS=(base udev plymouth autodetect modconf block netconf dropbear encryptssh filesystems keyboard fsck)
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
  -> -k 5.10.52-1-MANJARO-ARM -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
==> Starting build: 5.10.52-1-MANJARO-ARM
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [plymouth]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [netconf]
  -> Running build hook: [dropbear]
There is no root key in /etc/dropbear/root_key existent; exit
  -> Running build hook: [encryptssh]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> Image generation successful
[root@vicky /]# 
```

Don’t include the ```encrypt``` hooks, as this will cause the boot image to try the unlock the encryption twice and will your system will fail to boot.
We need to have ssh host created to continue with the configuration. We’ll continue with the unlock encryption configuration after the first boot of the Raspberry Pi.

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

Remove ```splash``` and add ```plymouth.enable=0```.
Set ```console=tty1```.

```
cryptdevice=/dev/disk/by-uuid/43c2d714-9af6-4d60-91d2-49d61e93bf3e:cryptroot root=/dev/mapper/cryptroot rw rootwait console=s
erial0,115200 console=tty1 selinux=0 plymouth.enable=0 quiet plymouth.ignore-serial-consoles smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 
kgdboc=serial0,115200 elevator=noop usbhid.mousepoll=8 snd-bcm2835.enable_compat_alsa=0 audit=0
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
[root@vicky etc]# 
exit
[root@vicky ~]# uname -a
Linux vicky 5.12.19-hardened1-1-hardened #1 SMP PREEMPT Tue, 20 Jul 2021 17:48:41 +0000 x86_64 GNU/Linux
[root@vicky ~]# 
```

Make sure that there are no processes still running from the chroot.

```
[root@vicky ~]# ps aux | grep -i qemu
root       29568  0.0  0.0 151256 15900 pts/4    Sl   08:42   0:00 /usr/bin/qemu-aarch64-static /bin/bash -i
root       46057  0.1  0.0 152940 13544 pts/4    Sl+  08:50   0:05 /usr/bin/qemu-aarch64-static /usr/bin/ping www.google.be
root      151414  0.0  0.0   7072  2336 pts/5    S+   09:52   0:00 grep -i qemu
```

Kill the processes from the chroot.

```
root@vicky ~]# kill 29568 46057
[root@vicky ~]# 
```

Umount the chroot filesystems.

```
[root@vicky ~]# umount -R /mnt/chroot
[root@vicky ~]# 
```

Close the luks volume...

```
[root@vicky ~]# cryptsetup luksClose cryptroot
[root@vicky ~]# sync
[root@vicky ~]# 
```

# Boot

Connect the usb disk to the raspberry pi and power it on. If you are lucky the PI will boot from the USB device and ask you to type the password to decrypt the root filesystem.

# Configure unlock with ssh

## Configure dropbear 

### Set the root key

Copy your public ssh key to ```/etc/dropbear/root_key```

```
[root@staf-pi002 dropbear]# cat > root_key
```

```
[root@staf-pi002 dropbear]# chmod 600 root_key 
[root@staf-pi002 dropbear]# 
```

### Convert the ssh rsa host key to pem

Dropbear can only handle the PEM format. We’ll need to convert the host key to the PEM format.

```
[root@staf-pi002 dropbear]# ssh-keygen -m PEM -p -f /etc/ssh/ssh_host_rsa_key
Key has comment 'root@stafwag-pi002'
Enter new passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved with the new passphrase.
[root@staf-pi002 dropbear]# 
```

Recreate the boot image.

```
[root@staf-pi002 dropbear]# mkinitcpio -p linux-rpi4
==> Building image from preset: /etc/mkinitcpio.d/linux-rpi4.preset: 'default'
  -> -k 5.10.52-1-MANJARO-ARM -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
==> Starting build: 5.10.52-1-MANJARO-ARM
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [plymouth]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [netconf]
  -> Running build hook: [dropbear]
Key is a ssh-rsa key
Wrote key to '/etc/dropbear/dropbear_rsa_host_key'
Error: Error parsing OpenSSH key
Error reading key from '/etc/ssh/ssh_host_dsa_key'
Error: Unsupported OpenSSH key type
Error reading key from '/etc/ssh/ssh_host_ecdsa_key'
dropbear_rsa_host_key : sha1!! 2a:a4:d5:a0:00:ce:1e:9f:88:84:72:f2:03:ce:ac:4a:27:11:da:09
  -> Running build hook: [encryptssh]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> Image generation successful
[root@staf-pi002 dropbear]# 
```

# Configure a static ip address

Update ```/boot/cmdline``` with your ip configuration.

```
cryptdevice=/dev/disk/by-uuid/43c2d714-9af6-4d60-91d2-49d61e93bf3e:cryptroot root=/dev/mapper /cryptroot rw rootwait console=serial0,115200 console=tty1 selinux=0 plymouth.enable=0 quiet plymouth.ignore-serial-consoles smsc95xx.turbo_mode=N dwc_otg.lpm_enable=0 kgdboc=serial0,115 200 elevator=noop usbhid.mousepoll=8 snd-bcm2835.enable_compat_alsa=0 audit=0 ip=xxx.xxx.xxx.xxx::yyy.yyy.yyy.254:255.255.255.0:staf-pi002:eth0:none
```

Reboot and test.


***Have fun!***

# Links

* [https://www.kali.org/docs/arm/raspberry-pi-full-encryption/](https://www.kali.org/docs/arm/raspberry-pi-full-encryption/)
* [https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/](https://jamesachambers.com/raspberry-pi-4-usb-boot-config-guide-for-ssd-flash-drives/)
* [https://archived.forum.manjaro.org/t/how-to-solve-keyring-issues-in-manjaro/4020](https://archived.forum.manjaro.org/t/how-to-solve-keyring-issues-in-manjaro/4020)
* [https://unix.stackexchange.com/questions/120827/recursive-umount-after-rbind-mount](https://unix.stackexchange.com/questions/120827/recursive-umount-after-rbind-mount)
* https://wiki.archlinux.org/title/Dm-crypt/Specialties#Remote_unlocking_(hooks:_netconf,_dropbear,_tinyssh,_ppp)
