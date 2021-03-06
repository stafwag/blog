---
layout: post
title: "Install Arch on an encrypted btrfs partition"
date: 2016-08-30 08:59
comments: true
categories: [ archlinux, btrfs, luks ] 
---

<img src="{{ '/images/Arch-linux-logo.png'  | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="Arch"/>

I'm preparing to move <a href="http://stafwag.github.io/blog/blog/2013/08/25/the-benefits-of-stopping-smoking-dot-dot-dot/">my workstation</a> to <a href="https://www.archlinux.org/">arch linux</a> Before I'll install it on my physical workstation I did the installation on a virtual machine. I'll use <a href="https://btrfs.wiki.kernel.org/index.php/Main_Page">btrfs</a> as the filesystem during the installation. btrfs is a nice filesystem but it had some serious dataloss issue with <a href="https://btrfs.wiki.kernel.org/index.php/RAID56">RAID5/RAID6</a> recently.

btrfs might not stable enough for a production environment but it has some nice features like snapshots, send/recieve, compression etc. I use <a href="http://www.open-zfs.org/wiki/Main_Page">zfs</a> for my important date anyway.  

## To encrypt or not to encrypt... 

It's possible to encrypt your boot partition <a href="https://www.gnu.org/software/grub/">grub</a> has support for <a href="https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup">luks</a> volumes. This cause grub to ask for a password during the system startup you'll need to type in your password a second time during the system startup when you Linux initrd image is booted. It's possible to avoid this by adding a keyfile to your crypttab - which migh be considered as a security risk -.  

In this howto we'll setup a single root partition to have full disk encryption. I'm not sure I go with an encrypted boot partition during my final installation. I might just create an empty partition of 1G so I can move switch between an encrypted and an non-encrypted boot filesystem. 

<img src="{{ '/images/arch-on-an-encrypted-btrfs-partition/00_boot.png'  | remove_first:'/' | absolute_url }}" class="left" width="440" height="" alt="00_boot.png" /> 

## Download the arch linux iso and boot it

After arch linux is booted verify that you have internet access if the network card is support and dchp is enabled on you network you should get a network address.

## Network access

To setup the system remotely we first need to setup network to our system.

### Verify the interface

```
root@archiso ~ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:69:d4:94 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.23/24 brd 192.168.122.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a7b:481f:2f70:e688/64 scope link 
       valid_lft forever preferred_lft forever
root@archiso ~ # 
```

### Verify internet access

```
root@archiso ~ # ping -c 3 8.8.8.8                                                                                      :(
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=49 time=49.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=49 time=45.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=49 time=46.8 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 45.896/47.329/49.201/1.406 ms
root@archiso ~ # nslookup www.google.be
Server:         192.168.122.1
Address:        192.168.122.1#53

Non-authoritative answer:
Name:   www.google.be
Address: 64.233.167.94

root@archiso ~ # ping www.google.be
PING www.google.be (64.233.167.94) 56(84) bytes of data.
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=1 ttl=46 time=58.7 ms
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=2 ttl=46 time=58.7 ms
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=3 ttl=46 time=58.4 ms
^C
--- www.google.be ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 58.479/58.645/58.742/0.230 ms
root@archiso ~ #                   

```

## ssh access

If you want to install arch linux over ssh you need to assign a root passwd and start the sshd service.

### root password

```
root@archiso ~ # passwd root       
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
root@archiso ~ # 
```

### start sshd

```
root@archiso ~ # systemctl list-unit-files -t service | grep ssh
sshd.service                               disabled
sshd@.service                              static  
sshdgenkeys.service                        static  
root@archiso ~ # systemctl start sshd                           
root@archiso ~ #

```

### Logon remotely

```
[staf@vicky ~]$ ssh -l root 192.168.122.23
root@192.168.122.23's password: 
Last login: Tue Jun 30 09:06:00 2015 from 192.168.122.1
root@archiso ~ # 
```

## Partition

### Find your harddisk device name

```
root@archiso ~ # cat /proc/partitions
major minor  #blocks  name

   8        0  268435456 sda
  11        0     759808 sr0
   7        0     328616 loop0
root@archiso ~ # 
```

### Overwrite it with random data

Because we are creating an ecrypted filesystem it's a good idea to overwrite it with random data.

We'll use badblocks for this another method is to use "dd if=/dev/random of=/dev/xxx" the "dd" method is probably the best method but is a lot slower.

```
root@archiso ~ # badblocks -c 10240 -s -w -t random -v /dev/sda
Checking for bad blocks in read-write mode
From block 0 to 268435455
Testing with random pattern: done                                                 
Reading and comparing: done                                                 
Pass completed, 0 bad blocks found. (0/0/0 errors)
badblocks -c 10240 -s -w -t random -v /dev/sda  49.22s user 21.72s system 3% cpu 33:48.40 total
root@archiso ~ # 
```

### Partition the harddisk

Create 3 partitions:

* 1G /boot (we'll not use this during the installation - see above - )
* 32G swap
* root btrfs partition

```
root@archiso ~ # fdisk /dev/sda                                

Welcome to fdisk (util-linux 2.28).                                                    
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x7ff944e5.

Command (m for help): p
Disk /dev/sda: 256 GiB, 274877906944 bytes, 536870912 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x7ff944e5

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-536870911, default 2048): +1G
Value out of range.
First sector (2048-536870911, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-536870911, default 536870911): 
Do you really want to quit? y
1 root@archiso ~ # fdisk /dev/sda                                                   :(

Welcome to fdisk (util-linux 2.28).                                                    
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0xa806e281.

Command (m for help): p
Disk /dev/sda: 256 GiB, 274877906944 bytes, 536870912 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xa806e281

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-536870911, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-536870911, default 536870911): +1G

Created a new partition 1 of type 'Linux' and of size 1 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (2099200-536870911, default 2099200): 
Last sector, +sectors or +size{K,M,G,T,P} (2099200-536870911, default 536870911): +32G

Created a new partition 2 of type 'Linux' and of size 32 GiB.

Command (m for help): n
Partition type
   p   primary (2 primary, 0 extended, 2 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (3,4, default 3): 
First sector (69208064-536870911, default 69208064): 
Last sector, +sectors or +size{K,M,G,T,P} (69208064-536870911, default 536870911): 

Created a new partition 3 of type 'Linux' and of size 223 GiB.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@archiso ~ # 
```

### Format the root partition

We'll continue with the root filesystem - we'll initialize the swapspace after the installation -

#### Create the root luks volume;

```
root@archiso ~ # cryptsetup luksFormat --cipher aes-xts-plain64 --key-size 256 --hash sha256 --use-random /dev/sda3

WARNING!
========
This will overwrite data on /dev/sda3 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase: 
Verify passphrase: 
5.01s user 0.04s system 21% cpu 23.750 total
root@archiso ~ # 
```

#### Open the root luks volume

```
root@archiso ~ # cryptsetup luksOpen /dev/sda3 cryptroot
Enter passphrase for /dev/sda3: 
root@archiso ~ # 
```

#### Format the root volume with btrfs

```
root@archiso ~ # mkfs.btrfs /dev/mapper/cryptroot
btrfs-progs v4.6.1
See http://btrfs.wiki.kernel.org for more information.

Label:              (null)
UUID:               cbfcc8d6-0cf9-4656-bcda-2525faeadfe6
Node size:          16384
Sector size:        4096
Filesystem size:    217.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         DUP               1.01GiB
  System:           DUP              12.00MiB
SSD detected:       no
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1   217.00GiB  /dev/mapper/cryptroot

root@archiso ~ # 
```

#### Mount the root filesystem

```
root@archiso ~ # mount -o noatime,compress=lzo,discard,ssd,defaults /dev/mapper/cryptroot /mnt
root@archiso ~ # 
```

#### Create the subvolumes

```
root@archiso ~ # cd /mnt
root@archiso /mnt # btrfs subvolume create __active
Create subvolume './__active'
root@archiso /mnt # btrfs subvolume create __active/rootvol
Create subvolume '__active/rootvol'
root@archiso /mnt # btrfs subvolume create __active/home
Create subvolume '__active/home'
root@archiso /mnt # btrfs subvolume create __active/var
Create subvolume '__active/var'
root@archiso /mnt # btrfs subvolume create __snapshots
Create subvolume './__snapshots'
root@archiso /mnt #
```

#### Mount the subvolumes

```
root@archiso /mnt # cd 
root@archiso ~ # umount /mnt
root@archiso ~ # mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/rootvol /dev/mapper/cryptroot /mnt
root@archiso ~ # mkdir /mnt/{home,var}
root@archiso ~ # mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/home /dev/mapper/cryptroot /mnt/home
root@archiso ~ # mount -o noatime,compress=lzo,discard,ssd,defaults,subvol=__active/var /dev/mapper/cryptroot /mnt/var
root@archiso ~ # sync
root@archiso ~ # 
```

## System installation

### bootstrap the system

```
root@archiso ~ # pacstrap /mnt base base-devel btrfs-progs
==> Creating install root at /mnt
==> Installing packages to /mnt
:: Synchronizing package databases...
 core                     119.9 KiB   652K/s 00:00 [######################] 100%
 extra                   1760.1 KiB   688K/s 00:03 [######################] 100%
 community                  3.6 MiB   906K/s 00:04 [######################] 100%
:: There are 50 members in group base:
:: Repository core
   1) bash  2) bzip2  3) coreutils  4) cryptsetup  5) device-mapper  6) dhcpcd
   7) diffutils  8) e2fsprogs  9) file  10) filesystem  11) findutils  12) gawk
   13) gcc-libs  14) gettext  15) glibc  16) grep  17) gzip  18) inetutils
   19) iproute2  20) iputils  21) jfsutils  22) less  23) licenses  24) linux
   25) logrotate  26) lvm2  27) man-db  28) man-pages  29) mdadm  30) nano
   31) netctl  32) pacman  33) pciutils  34) pcmciautils  35) perl
   36) procps-ng  37) psmisc  38) reiserfsprogs  39) s-nail  40) sed
   41) shadow  42) sysfsutils  43) systemd-sysvcompat  44) tar  45) texinfo
   46) usbutils  47) util-linux  48) vi  49) which  50) xfsprogs

Enter a selection (default=all): 
:: There are 25 members in group base-devel:
:: Repository core
   1) autoconf  2) automake  3) binutils  4) bison  5) fakeroot  6) file
   7) findutils  8) flex  9) gawk  10) gcc  11) gettext  12) grep  13) groff
   14) gzip  15) libtool  16) m4  17) make  18) pacman  19) patch
   20) pkg-config  21) sed  22) sudo  23) texinfo  24) util-linux  25) which

Enter a selection (default=all): 
warning: skipping target: file
warning: skipping target: findutils
warning: skipping target: gawk
warning: skipping target: gettext
warning: skipping target: grep
warning: skipping target: gzip
warning: skipping target: pacman
warning: skipping target: sed
warning: skipping target: texinfo
warning: skipping target: util-linux
warning: skipping target: which
resolving dependencies...
looking for conflicting packages...

Packages (144) acl-2.2.52-2  archlinux-keyring-20160812-1  attr-2.4.47-1
               ca-certificates-20160507-1  ca-certificates-cacert-20140824-3
               ca-certificates-mozilla-3.26-1  ca-certificates-utils-20160507-1
               cracklib-2.9.6-1  curl-7.50.1-1  db-5.3.28-3  dbus-1.10.8-1
               expat-2.2.0-2  gc-7.4.2-4  gdbm-1.12-2  glib2-2.48.1-1
<snip>
               procps-ng-3.3.12-1  psmisc-22.21-3  reiserfsprogs-3.6.25-1
               s-nail-14.8.10-1  sed-4.2.2-4  shadow-4.2.1-3  sudo-1.8.17.p1-1
               sysfsutils-2.1.0-9  systemd-sysvcompat-231-1  tar-1.29-1
               texinfo-6.1-4  usbutils-008-1  util-linux-2.28.1-1
               vi-1:070224-2  which-2.21-2  xfsprogs-4.7.0-1

Total Download Size:   231.85 MiB
Total Installed Size:  801.27 MiB

:: Proceed with installation? [Y/n] 
:: Retrieving packages...
 linux-api-headers-4...   810.7 KiB   891K/s 00:01 [######################] 100%
 tzdata-2016f-1-any       215.4 KiB   909K/s 00:00 [######################] 100%
 iana-etc-20160513-1-any  352.2 KiB   723K/s 00:00 [######################] 100%
 filesystem-2015.09-...     8.8 KiB   875K/s 00:00 [######################] 100%
 glibc-2.24-2-x86_64        8.1 MiB   918K/s 00:09 [######################] 100%
 gcc-libs-6.1.1-5-x86_64   14.9 MiB   899K/s 00:17 [######################] 100%
<snip>
(144/144) installing btrfs-progs                   [######################] 100%
:: Running post-transaction hooks...
(1/4) Updating manpage index...
mandb: can't set the locale; make sure $LC_* and $LANG are correct
(2/4) Updating the info directory file...
(3/4) Updating udev Hardware Database...
(4/4) Rebuilding certificate stores...
pacstrap /mnt base base-devel btrfs-progs  27.81s user 10.20s system 10% cpu 5:50.56 total
root@archiso ~ # 
```

### Generate /etc/fstab

```
root@archiso ~ # genfstab -p /mnt >> /mnt/etc/fstab
root@archiso ~ # vi /mnt/etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system> <dir>   <type>  <options>       <dump>  <pass>
# UUID=c8ca38de-4e58-4c7c-8f5b-c9c3f92f6a24
/dev/mapper/cryptroot   /               btrfs           rw,noatime,compress=lzo,ssd,dis
card,space_cache,subvolid=258,subvol=/__active/rootvol,subvol=__active/rootvol  0 0

# UUID=c8ca38de-4e58-4c7c-8f5b-c9c3f92f6a24
/dev/mapper/cryptroot   /home           btrfs           rw,noatime,compress=lzo,ssd,dis
card,space_cache,subvolid=259,subvol=/__active/home,subvol=__active/home        0 0

# UUID=c8ca38de-4e58-4c7c-8f5b-c9c3f92f6a24
/dev/mapper/cryptroot   /var            btrfs           rw,noatime,compress=lzo,ssd,dis
card,space_cache,subvolid=260,subvol=/__active/var,subvol=__active/var  0 0
```

### chroot

```
root@archiso ~ # arch-chroot /mnt
[root@archiso /]# 
```

### Set the timezone

Link for timezone to /etc/localtime

```
[root@archiso /]# ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime
[root@archiso /]# 
```

Set the hardwareclock to UTC

```
hwclock --systohc --utc
```

### Generate the required locales

```
[root@archiso /]# vi /etc/locale.gen 
[root@archiso /]# locale-gen
Generating locales...
  en_IE.UTF-8... done
  en_IE.ISO-8859-1... done
  en_IE.ISO-8859-15@euro... done
  en_US.UTF-8... done
  en_US.ISO-8859-1... done
  nl_BE.UTF-8... done
  nl_BE.ISO-8859-1... done
  nl_BE.ISO-8859-15@euro... done
Generation complete.
[root@archiso /]# 
```

### Hostname

```
[root@archiso /]# vi /etc/hostname
[root@archiso /]# 

```

```
[root@archiso /]# vi /etc/hosts
```

### mkinitcpio 

#### HOOKS

Add encrypt to HOOKS before filesystems in /etc/mkinitcpio.conf 

```
[root@archiso /]# vi /etc/mkinitcpio.conf 
```

```
HOOKS="base udev autodetect modconf block encrypt filesystems keyboard fsck"
```
#### Create boot image

```
[root@archiso /]# mkinitcpio -p linux
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
  -> -k /boot/vmlinuz-linux -c /etc/mkinitcpio.conf -g /boot/initramfs-linux.img
==> Starting build: 4.7.1-1-ARCH
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [encrypt]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux.img
==> Image generation successful
==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'fallback'
  -> -k /boot/vmlinuz-linux -c /etc/mkinitcpio.conf -g /boot/initramfs-linux-fallback.img -S autodetect
==> Starting build: 4.7.1-1-ARCH
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
==> WARNING: Possibly missing firmware for module: wd719x
==> WARNING: Possibly missing firmware for module: aic94xx
  -> Running build hook: [encrypt]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux-fallback.img
==> Image generation successful
[root@archiso /]#
```

### set the root password

```
[root@archiso /]# passwd root
New password: 
Retype new password: 
passwd: password updated successfully
[root@archiso /]# 
```

### GRUB

#### install Grub

```
[root@archiso /]# pacman -Sy grub
:: Synchronizing package databases...
 core is up to date
 extra                   1760.1 KiB   917K/s 00:02 [######################] 100%
 community                  3.6 MiB   896K/s 00:04 [######################] 100%
resolving dependencies...
looking for conflicting packages...

Packages (1) grub-1:2.02.beta3-3

Total Download Size:    5.83 MiB
Total Installed Size:  28.70 MiB

:: Proceed with installation? [Y/n] y
:: Retrieving packages...
 grub-1:2.02.beta3-3...     5.8 MiB   917K/s 00:07 [######################] 100%
(1/1) checking keys in keyring                     [######################] 100%
(1/1) checking package integrity                   [######################] 100%
(1/1) loading package files                        [######################] 100%
(1/1) checking for file conflicts                  [######################] 100%
(1/1) checking available disk space                [######################] 100%
:: Processing package changes...
(1/1) installing grub                              [######################] 100%
Generating grub.cfg.example config file...
This may fail on some machines running a custom kernel.
done.
Optional dependencies for grub
    freetype2: For grub-mkfont usage
    fuse: For grub-mount usage
    dosfstools: For grub-mkrescue FAT FS and EFI support
    efibootmgr: For grub-install EFI support
    libisoburn: Provides xorriso for generating grub rescue iso using
    grub-mkrescue
    os-prober: To detect other OSes when generating grub.cfg in BIOS systems
    mtools: For grub-mkrescue FAT FS support
:: Running post-transaction hooks...
(1/2) Updating manpage index...
(2/2) Updating the info directory file...
[root@archiso /]# 
```

#### Install grub to your boot disk

```
[root@archiso /]# grub-install --target=i386-pc /dev/sda
Installing for i386-pc platform.
grub-install: error: attempt to install to encrypted disk without cryptodisk enabled. Set `GRUB_ENABLE_CRYPTODISK=y' in file `/etc/default/grub'.
[root@archiso /]# 

```

#### Enable cryptodisk

Because we use an encrypted boot disk we need to enable cryptdisk support.

Add  GRUB_ENABLE_CRYPTODISK=y to /etc/default/grub


```
[root@archiso /]# vi /etc/default/grub
[root@archiso /]# 

```

```
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""
GRUB_ENABLE_CRYPTODISK=y
```

And run grub-install again

```
[root@archiso /]# grub-install --target=i386-pc /dev/sda
Installing for i386-pc platform.
Installation finished. No error reported.
[root@archiso /]# 
```

#### Create grub.cfg

Add your encrypted root partition to GRUB_CMDLINE_LINUX= in /etc/default/grub

```
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Arch"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX=""cryptdevice=/dev/sda3:cryptroot""
ENABLE_CRYPTODISK=y 

```

And generate grub.cfg

```
[root@archiso /]# grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-linux
Found initrd image(s) in /boot: initramfs-linux.img
Found fallback initrd image(s) in /boot: initramfs-linux-fallback.img
done
[root@archiso /]# 

```

## Reboot

```
[root@archiso /]# vi /boot/grub/grub.cfg
[root@archiso /]# sync
[root@archiso /]# reboot
Running in chroot, ignoring request.
[root@archiso /]# exit
arch-chroot /mnt  9.76s user 1.37s system 0% cpu 23:13.29 total
root@archiso ~ # reboot
```

## Finish the installation

### 1st boot

As mentioned before the GRUB will as for a passphrase to decrypt the boot partition.

<img src="{{ '/images/arch-on-an-encrypted-btrfs-partition/01_1st_boot.png'  | remove_first:'/' | absolute_url }}" class="center" width="700" height="274" alt="01_1st_boot.png" /> 
<img src="{{ '/images/arch-on-an-encrypted-btrfs-partition/02_1st_grub_menu.png'  | remove_first:'/' | absolute_url }}" class="center" width="700" height="484" alt="01_1st_boot.png" /> 

You'll need to type it the password a secod time during the loading of initrd.

<img src="{{ '/images/arch-on-an-encrypted-btrfs-partition/02_1st_decrypt_root.png'  | remove_first:'/' | absolute_url }}" class="center" width="700" height="165" alt="01_1st_boot.png" /> 


### Setup swap space

Update /etc/crypttab

```
swap         /dev/sda2                                    /dev/urandom            swap,
cipher=aes-cbc-essiv:sha256,size=256
```

reboot the system to verify that the encrypted swap partition is mapper correctly during the system startup

```
[root@vicky ~]# ls -l /dev/mapper/
total 0
crw------- 1 root root 10, 236 Aug 29 15:43 control
lrwxrwxrwx 1 root root       7 Aug 29 15:43 cryptroot -> ../dm-0
lrwxrwxrwx 1 root root       7 Aug 29 15:43 swap -> ../dm-1
[root@vicky ~]# 
```

Create swap

```
[root@vicky ~]# mkswap /dev/mapper/swap 
Setting up swapspace version 1, size = 32 GiB (34359734272 bytes)
no label, UUID=66ea5a08-0833-4e84-8b95-f1a9c2d772b2
[root@vicky ~]# 
```

Activate swap

```
[root@vicky ~]# swapon /dev/mapper/swap
[root@vicky ~]# free
              total        used        free      shared  buff/cache   available
Mem:        4051236       85932     3890708         440       74596     3807084
Swap:      33554428           0    33554428
[root@vicky ~]# 
```

Update /etc/fstab

```
/dev/mapper/swap swap                    swap    defaults,discard,pri=3        0 0 
```

<p style="font-style: italic;">
Have fun
</p>




## Links

* <a href="https://wiki.archlinux.org/index.php/Installation_guide">https://wiki.archlinux.org/index.php/Installation_guide</a> 
* <a href="http://www.brunoparmentier.be/blog/how-to-install-arch-linux-on-an-encrypted-btrfs-partition.html">http://www.brunoparmentier.be/blog/how-to-install-arch-linux-on-an-encrypted-btrfs-partition.html</a>
* <a href="http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html">http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html</a>

