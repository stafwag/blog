---
layout: post
title: "Install Parabola GNU/Linux on an Encrypted btrfs logical volume"
date: 2017-05-25 08:05:38 +0100
comments: true
categories: [libreboot, parabola, btrfs, luks] 
excerpt_separator: <!--more-->
---

<img src="{{ '/images/413px-Gnu10-mascot-logo_100ppi.png'  | absolute_url }}" class="left" width="200" height="291" alt="413px-Gnu10-mascot-logo_100ppi.png" /> 

I finally found time to complete the installation of my <a href="http://stafwag.github.io/blog/blog/2017/02/11/how-to-install-libreboot-on-a-thinkpad-x60/">Libreboot laptop</a>

I decided to give <a href="https://www.parabola.nu/">Parabola GNU/Linux</a> a try as my daily driver to get a fully <a href="https://en.wikipedia.org/wiki/Free_software">Free Software</a> Laptop/tablet.

## Download the Parabola GNU/Linux iso and boot it

After Parabola GNU/Linux is booted verify that you have internet access if the network card is support and dhcp is enabled on you network you should get a network address.

<!--more-->
## Network access

To setup the system remotely we first need to setup network to our system.

### Verify the interface

```
1 root@parabolaiso ~ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: enp1s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:16:d3:b7:3a:96 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global enp1s0
       valid_lft forever preferred_lft forever
    inet6 fe80::e5db:c85f:4478:1f44/64 scope link 
       valid_lft forever preferred_lft forever
3: wlp2s0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether 00:1b:77:4d:5a:57 brd ff:ff:ff:ff:ff:ff
root@parabolaiso ~ # 
```

### Verify internet access

```
root@parabolaiso ~ # ping -c 3 www.google.be
PING www.google.be (172.217.17.67) 56(84) bytes of data.
64 bytes from ams16s30-in-f3.1e100.net (172.217.17.67): icmp_seq=1 ttl=56 time=91.3 ms
64 bytes from ams16s30-in-f3.1e100.net (172.217.17.67): icmp_seq=2 ttl=56 time=48.7 ms
64 bytes from ams16s30-in-f3.1e100.net (172.217.17.67): icmp_seq=3 ttl=56 time=47.9 ms

--- www.google.be ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 47.998/62.714/91.366/20.264 ms
root@parabolaiso ~ # 
```

## ssh access

If you want to install Parabola GNU/Linux over ssh you need to assign a root passwd and start the sshd service.

### root password

```
root@parabolaiso ~ # passwd root
New password: 
Retype new password: 
passwd: password updated successfully
root@parabolaiso ~ # 
```

### create a user account

Parabola doesn't allow remote ssh root logons. Create a new account to access the system remotely.

```
root@parabolaiso ~ # useradd install
root@parabolaiso ~ # passwd install
New password: 
Retype new password: 
passwd: password updated successfully
root@parabolaiso ~ # 
```

### start sshd

```
root@parabolaiso ~ # systemctl start sshd
root@parabolaiso ~ # 
```

### Logon remotely

```
[staf@vicky ~]$ ssh install@petronella 
install@petronella's password: 

===============================================================================
                                                                          
         Parabola live media 2016.11.03                                
                                                                          
    To install Parabola, the system must be connected to the internet.    
    For instructions, enter this command:                                 
      lynx network.html                                           
                                                                          
    Press the number keys while holding Alt to switch virtual terminals.  
    This allows entering commands without closing lynx.                   
                                                                          
===============================================================================

Could not chdir to home directory /home/install: No such file or directory
[install@parabolaiso /]$ su -
Password: 
root@parabolaiso ~ # 
```

## Partition your harddisk

### Find your harddisk device name

```
root@parabolaiso ~ # lsblk -o NAME,VENDOR,MODEL,TYPE,SIZE 
NAME                  VENDOR   MODEL            TYPE   SIZE
loop1                                           loop   1.9G
`-parabola_root-image                           dm     1.9G
sdb                   ATA      OCZ-VERTEX2      disk 107.1G
`-sdb1                                          part 107.1G
loop2                                           loop   1.9G
`-parabola_root-image                           dm     1.9G
loop0                                           loop 269.7M
sda                   Kingston DataTraveler 2.0 disk   7.2G
|-sda2                                          part    31M
`-sda1                                          part   613M
root@parabolaiso ~ # 
```

### Overwrite it with random data

Because we are creating an ecrypted filesystem it's a good idea to overwrite it with random data.

We'll use badblocks for this another method is to use "dd if=/dev/random of=/dev/xxx" the "dd" method is probably the best method but is a lot slower.


```
root@parabolaiso ~ # badblocks -c 10240 -s -w -t random -v /dev/sdb


Checking for bad blocks in read-write mode
From block 0 to 112337063
Testing with random pattern: done                                                 
Reading and comparing: done                                                 
Pass completed, 0 bad blocks found. (0/0/0 errors)
badblocks -c 10240 -s -w -t random -v /dev/sdb  82.82s user 20.08s system 3% cpu 48:12.29 total
root@parabolaiso ~ # 
```

### Partition the harddisk

We'll use lvm is this setup, while it should be possible to  boot from an encrypted partition with Libreboot partition I create a small unencrypted boot partition.


```
root@parabolaiso ~ # fdisk /dev/sdb

Welcome to fdisk (util-linux 2.28.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table.
Created a new DOS disklabel with disk identifier 0x2640923c.

Command (m for help): p
Disk /dev/sdb: 107.1 GiB, 115033153536 bytes, 224674128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2640923c

Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (1-4, default 1): 
First sector (2048-224674127, default 2048): 
Last sector, +sectors or +size{K,M,G,T,P} (2048-224674127, default 224674127): +1G

Created a new partition 1 of type 'Linux' and of size 1 GiB.

Command (m for help): n
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p
Partition number (2-4, default 2): 
First sector (2099200-224674127, default 2099200): 
Last sector, +sectors or +size{K,M,G,T,P} (2099200-224674127, default 224674127): 

Created a new partition 2 of type 'Linux' and of size 106.1 GiB.

Command (m for help): p
Disk /dev/sdb: 107.1 GiB, 115033153536 bytes, 224674128 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x2640923c

Device     Boot   Start       End   Sectors   Size Id Type
/dev/sdb1          2048   2099199   2097152     1G 83 Linux
/dev/sdb2       2099200 224674127 222574928 106.1G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@parabolaiso ~ # 
```

### Encrypt the LVM physical volume

#### Benchmark

We bechmark the encryption to decide which encryption we'll use.

```
root@parabolaiso ~ # cryptsetup benchmark
# Tests are approximate using memory only (no storage IO).
PBKDF2-sha1       382134 iterations per second for 256-bit key
PBKDF2-sha256     479239 iterations per second for 256-bit key
PBKDF2-sha512     347671 iterations per second for 256-bit key
PBKDF2-ripemd160  319687 iterations per second for 256-bit key
PBKDF2-whirlpool  221032 iterations per second for 256-bit key
#  Algorithm | Key |  Encryption |  Decryption
     aes-cbc   128b    79.1 MiB/s    93.9 MiB/s
 serpent-cbc   128b    30.0 MiB/s   112.0 MiB/s
 twofish-cbc   128b    77.5 MiB/s   102.5 MiB/s
     aes-cbc   256b    62.7 MiB/s    71.0 MiB/s
 serpent-cbc   256b    30.0 MiB/s   111.9 MiB/s
 twofish-cbc   256b    77.5 MiB/s   102.4 MiB/s
     aes-xts   256b    93.0 MiB/s    93.3 MiB/s
 serpent-xts   256b   100.3 MiB/s   104.5 MiB/s
 twofish-xts   256b    93.8 MiB/s    95.0 MiB/s
     aes-xts   512b    70.5 MiB/s    70.7 MiB/s
 serpent-xts   512b   100.3 MiB/s   104.4 MiB/s
 twofish-xts   512b    93.9 MiB/s    94.9 MiB/s
cryptsetup benchmark  3.91s user 24.02s system 99% cpu 28.093 total
root@parabolaiso ~ # 
```

#### Create Luks volume

The serpent xts with a 512 bits keys seems to give a pretty good performance while sha256 hashing gives the best performance. 

```
root@parabolaiso ~ # cryptsetup luksFormat --cipher serpent-xts-plain64 --key-size 512 --hash sha256 --use-random /dev/sdb2 

WARNING!
========
This will overwrite data on /dev/sdb2 irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase: 
Verify passphrase: 
root@parabolaiso ~ # 
```

## LVM setup

### Create the volumes

#### Open the LUKS volume

```
root@parabolaiso ~ #  cryptsetup luksOpen /dev/sdb2 pv
Enter passphrase for /dev/sdb2: 
root@parabolaiso ~ # 
```

This create /dev/mapper/pv

#### Create the physical volume

```
root@parabolaiso ~ # pvcreate /dev/mapper/pv                 
  Physical volume "/dev/mapper/pv" successfully created.
root@parabolaiso ~ # 
```

Show the pv

```
root@parabolaiso ~ # pvs
  PV             VG Fmt  Attr PSize   PFree  
  /dev/mapper/pv    lvm2 ---  106.13g 106.13g
root@parabolaiso ~ # 
```

#### Create the volume group

```
root@parabolaiso ~ # vgcreate vg /dev/mapper/pv
  Volume group "vg" successfully created
root@parabolaiso ~ # 
```

Show the created volume group

```
root@parabolaiso ~ # vgs
  VG #PV #LV #SN Attr   VSize   VFree  
  vg   1   0   0 wz--n- 106.13g 106.13g
root@parabolaiso ~ # 
```

#### Create the swap logical volume

```
root@parabolaiso ~ # lvcreate -L 4G vg -n lv_swap 
  Logical volume "lv_swap" created.
root@parabolaiso ~ # 
```

#### Create the root logical volume

```
root@parabolaiso ~ # lvcreate -L 20G vg -n lv_root   
  Logical volume "lv_root" created.
root@parabolaiso ~ # 
```

#### Display the create logical volumes

```
root@parabolaiso ~ # lvs
  LV      VG Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv_root vg -wi-a----- 20.00g                                                    
  lv_swap vg -wi-a-----  4.00g                                                    
root@parabolaiso ~ # 
```

### Format the logical volumes

#### Create the swapspace

```
root@parabolaiso ~ # mkswap /dev/mapper/vg-lv_swap       
Setting up swapspace version 1, size = 4 GiB (4294963200 bytes)
no label, UUID=32f6e5d4-67a3-42e3-8a90-6ee3ae0fdaa3
root@parabolaiso ~ # 
```

And activate it;

```
root@parabolaiso ~ # swapon /dev/mapper/vg-lv_swap       
root@parabolaiso ~ # 
```

#### Create the root filesystem

```
root@parabolaiso ~ # mkfs.btrfs /dev/mapper/vg-lv_root       
btrfs-progs v4.8.2
See http://btrfs.wiki.kernel.org for more information.

Detected a SSD, turning off metadata duplication.  Mkfs with -m dup if you want to force metadata duplication.
Label:              (null)
UUID:               
Node size:          16384
Sector size:        4096
Filesystem size:    20.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         single            8.00MiB
  System:           single            4.00MiB
SSD detected:       yes
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1    20.00GiB  /dev/mapper/vg-lv_root

root@parabolaiso ~ # 
```
#### Create the boot filesystem

```
root@parabolaiso ~ # mkfs.ext2 /dev/sdb1 
mke2fs 1.43.3 (04-Sep-2016)
Discarding device blocks: done                            
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: e3fd741d-d0e0-483f-a9cd-3fbd3f9d66d1
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376

Allocating group tables: done                            
Writing inode tables: done                            
Writing superblocks and filesystem accounting information: done

root@parabolaiso ~ # 
```

#### Mount the filesystems

Mount the root filesystem;

```
root@parabolaiso ~ # 
root@parabolaiso ~ # mount -o noatime,compress=lzo,discard,ssd,defaults /dev/mapper/vg-lv_root /mnt
root@parabolaiso ~ # 

```

Create the /home and /boot directories

```
root@parabolaiso ~ # mkdir -p /mnt/{boot,home}
```

Mount the boot filesystem

```
root@parabolaiso ~ # mount /dev/sdb1 /mnt/boot
root@parabolaiso ~ # 
```

Show;

```
root@parabolaiso ~ # df -h
Filesystem                       Size  Used Avail Use% Mounted on
dev                              1.6G     0  1.6G   0% /dev
run                              1.6G   26M  1.6G   2% /run
/dev/sda1                        613M  613M     0 100% /run/parabolaiso/bootmnt
cowspace                         2.4G  8.9M  2.4G   1% /run/parabolaiso/cowspace
/dev/loop0                       270M  270M     0 100% /run/parabolaiso/sfs/root-image
/dev/mapper/parabola_root-image  1.9G  885M 1003M  47% /
tmpfs                            1.6G     0  1.6G   0% /dev/shm
tmpfs                            1.6G     0  1.6G   0% /sys/fs/cgroup
tmpfs                            1.6G     0  1.6G   0% /tmp
tmpfs                            1.6G  1.6M  1.6G   1% /etc/pacman.d/gnupg
tmpfs                            320M     0  320M   0% /run/user/0
tmpfs                            320M     0  320M   0% /run/user/1001
/dev/mapper/vg-lv_root            20G   17M   20G   1% /mnt
/dev/sdb1                       1008M  1.3M  956M   1% /mnt/boot
root@parabolaiso ~ # 
```


## System installation

### boostrap the system

```
root@parabolaiso ~ # pacstrap /mnt base base-devel btrfs-progs
==> Creating install root at /mnt
==> Installing packages to /mnt
:: Synchronizing package databases...
 libre                                              437.7 KiB   228K/s 00:02 [############################################] 100%
 core                                               111.1 KiB   280K/s 00:00 [############################################] 100%
 extra                                             1535.4 KiB   544K/s 00:03 [############################################] 100%
 community                                            3.6 MiB   615K/s 00:06 [############################################] 100%
 pcr                                                620.0 KiB   662K/s 00:01 [############################################] 100%
:: There are 52 members in group base:
:: Repository libre
   1) filesystem  2) licenses  3) linux-libre  4) pacman  5) pacman-mirrorlist  6) systemd-sysvcompat  7) your-freedom
:: Repository core
   8) bash  9) bzip2  10) coreutils  11) cryptsetup  12) device-mapper  13) dhcpcd  14) diffutils  15) e2fsprogs  16) file
   17) findutils  18) gawk  19) gcc-libs  20) gettext  21) glibc  22) grep  23) gzip  24) inetutils  25) iproute2  26) iputils
   27) jfsutils  28) less  29) logrotate  30) lvm2  31) man-db  32) man-pages  33) mdadm  34) nano  35) netctl  36) pciutils
   37) pcmciautils  38) perl  39) procps-ng  40) psmisc  41) reiserfsprogs  42) s-nail  43) sed  44) shadow  45) sysfsutils
   46) tar  47) texinfo  48) usbutils  49) util-linux  50) vi  51) which  52) xfsprogs

Enter a selection (default=all): 
```

&lt; snip &gt;

```
(2/7) Updating udev hardware database...
(3/7) Updating system user accounts...
(4/7) Creating temporary files...
(5/7) Arming ConditionNeedsUpdate...
(6/7) Updating the info directory file...
(7/7) Rebuilding certificate stores...
pacstrap /mnt base base-devel btrfs-progs  62.07s user 14.31s system 1% cpu 1:13:22.44 total
root@parabolaiso ~ # 
```

### Generate /etc/fstab


```
root@parabolaiso ~ #
root@parabolaiso ~ # genfstab -U -p /mnt  >> /mnt/etc/fstab
root@parabolaiso ~ # 
```

review 

```
root@parabolaiso ~ # cat /mnt/etc/fstab
# 
# /etc/fstab: static file system information
#
# <file system> <dir>   <type>  <options>       <dump>  <pass>
# UUID=3731a69b-7240-4618-8e5e-4684d7e719e3
# /dev/mapper/vg-lv_root
UUID=3731a69b-7240-4618-8e5e-4684d7e719e3       /               btrfs           rw,relatime,ssd,space_cache,subvolid=5,subvol=/0 0

# /dev/sdb1
UUID=e3fd741d-d0e0-483f-a9cd-3fbd3f9d66d1       /boot           ext2            rw,relatime,block_validity,barrier,user_xattr,acl       0 2

# /dev/mapper/vg-lv_swap
UUID=32f6e5d4-67a3-42e3-8a90-6ee3ae0fdaa3       none            swap            defaults        0 0

root@parabolaiso ~ # 
```

### chroot

```
root@parabolaiso ~ # arch-chroot /mnt
[root@parabolaiso /]# 
```

### Set the timezone

Set the link for the correct timezone

```
[root@parabolaiso /]# ln -sf /usr/share/zoneinfo/Europe/Brussels /etc/localtime
[root@parabolaiso /]# 
```

Set the hardwareclock to UTC

```
[root@parabolaiso /]# hwclock --systohc --utc
[root@parabolaiso /]# 
```

### Generate the required locales

```
[root@parabolaiso /]# vi /etc/locale.gen 
[root@parabolaiso /]# local 
local       locale      locale-gen  localectl   localedef   
[root@parabolaiso /]# locale-gen
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
[root@parabolaiso /]# 
```

### Hostname

```
[root@parabolaiso /]# vi /etc/hostname
[root@parabolaiso /]# 
```

### mkinitcpio 

#### HOOKS


Add "encrypt lvm2" to HOOKS before filesystems in /etc/mkinitcpio.conf

```
[root@parabolaiso /]# vi /etc/mkinitcpio.conf
```

```
HOOKS="base udev autodetect modconf block encrypt lvm2 filesystems keyboard fsck"
```

#### Create boot image

```
[root@parabolaiso /]#  mkinitcpio -p linux-libre
==> Building image from preset: /etc/mkinitcpio.d/linux-libre.preset: 'default'
  -> -k /boot/vmlinuz-linux-libre -c /etc/mkinitcpio.conf -g /boot/initramfs-linux-libre.img
==> Starting build: 4.10.6-gnu-1
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [autodetect]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
  -> Running build hook: [sd-encrypt]
/usr/lib/initcpio/install/sd-encrypt: line 21: add_systemd_unit: command not found
/usr/lib/initcpio/install/sd-encrypt: line 25: add_systemd_unit: command not found
/usr/lib/initcpio/install/sd-encrypt: line 26: add_systemd_unit: command not found
  -> Running build hook: [lvm2]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux-libre.img
==> Image generation successful
==> Building image from preset: /etc/mkinitcpio.d/linux-libre.preset: 'fallback'
  -> -k /boot/vmlinuz-linux-libre -c /etc/mkinitcpio.conf -g /boot/initramfs-linux-libre-fallback.img -S autodetect
==> Starting build: 4.10.6-gnu-1
  -> Running build hook: [base]
  -> Running build hook: [udev]
  -> Running build hook: [modconf]
  -> Running build hook: [block]
==> WARNING: Possibly missing firmware for module: isci
  -> Running build hook: [sd-encrypt]
/usr/lib/initcpio/install/sd-encrypt: line 21: add_systemd_unit: command not found
/usr/lib/initcpio/install/sd-encrypt: line 25: add_systemd_unit: command not found
/usr/lib/initcpio/install/sd-encrypt: line 26: add_systemd_unit: command not found
  -> Running build hook: [lvm2]
  -> Running build hook: [filesystems]
  -> Running build hook: [keyboard]
  -> Running build hook: [fsck]
==> Generating module dependencies
==> Creating gzip-compressed initcpio image: /boot/initramfs-linux-libre-fallback.img
==> Image generation successful
[root@parabolaiso /]# 
```

### set the root password

```
[root@parabolaiso /]# passwd root
New password: 
Retype new password: 
passwd: password updated successfully
[root@parabolaiso /]# 
```

### GRUB

#### install Grub

```
[root@parabolaiso /]#  pacman -Sy grub
:: Synchronizing package databases...
 libre is up to date
 core is up to date
 extra is up to date
 community is up to date
 pcr is up to date
resolving dependencies...
looking for conflicting packages...

Packages (1) grub-1:2.02.rc2-1.parabola1

Total Download Size:    6.04 MiB
Total Installed Size:  35.87 MiB

:: Proceed with installation? [Y/n] 
:: Retrieving packages...
 grub-1:2.02.rc2-1.parabola1-x86_64                   6.0 MiB   128K/s 00:48 [############################################] 100%
(1/1) checking keys in keyring                                               [############################################] 100%
(1/1) checking package integrity                                             [############################################] 100%
(1/1) loading package files                                                  [############################################] 100%
(1/1) checking for file conflicts                                            [############################################] 100%
(1/1) checking available disk space                                          [############################################] 100%
:: Processing package changes...
(1/1) installing grub                                                        [############################################] 100%
Generating grub.cfg.example config file...
This may fail on some machines running a custom kernel.
done.
Optional dependencies for grub
    freetype2: For grub-mkfont usage
    fuse: For grub-mount usage
    dosfstools: For grub-mkrescue FAT FS and EFI support
    efibootmgr: For grub-install EFI support
    libisoburn: Provides xorriso for generating grub rescue iso using grub-mkrescue
    os-prober: To detect other OSes when generating grub.cfg in BIOS systems
    mtools: For grub-mkrescue FAT FS support
:: Running post-transaction hooks...
(1/2) Arming ConditionNeedsUpdate...
(2/2) Updating the info directory file...
[root@parabolaiso /]# 
```

#### Install grub to your boot disk

```
[root@parabolaiso /]# grub-install --target=i386-pc /dev/sdb
Installing for i386-pc platform.
Installation finished. No error reported.
[root@parabolaiso /]# 
```

#### Create grub.cfg

We'll use the uuid for the crypted device.

##### Get the UUID for the encrypted physical volume

```
[root@parabolaiso /]# ls -l /dev/disk/by-uuid/
total 0
lrwxrwxrwx 1 root root 10 Apr  3 10:07 2016-11-03-15-52-21-00 -> ../../sda1
lrwxrwxrwx 1 root root 10 Apr  3 10:09 32f6e5d4-67a3-42e3-8a90-6ee3ae0fdaa3 -> ../../dm-2
lrwxrwxrwx 1 root root 10 Apr  3 10:09 3731a69b-7240-4618-8e5e-4684d7e719e3 -> ../../dm-3
lrwxrwxrwx 1 root root 10 Apr  3 10:07 BD3C-9D8E -> ../../sda2
lrwxrwxrwx 1 root root 10 Apr  3 10:07 e3fd741d-d0e0-483f-a9cd-3fbd3f9d66d1 -> ../../sdb1
lrwxrwxrwx 1 root root 10 Apr  3 10:09 eb600d4a-a2fd-4698-8847-14e6dc1b5e6c -> ../../sdb2
lrwxrwxrwx 1 root root 10 Apr  3 10:07 f6312bc5-7593-4b6d-8427-0cf92d9de40b -> ../../dm-0
[root@parabolaiso /]# 
```

##### Update /etc/default/grub

```
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Parabola"
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="cryptdevice=/dev/disk/by-uuid/eb600d4a-a2fd-4698-8847-14e6dc1b5e6c:pv"
```

##### Generate grub.cfg

```
[root@parabolaiso /]# grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file ...
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
Found linux image: /boot/vmlinuz-linux-libre
Found initrd image: /boot/initramfs-linux-libre.img
Found fallback initramfs image: /boot/initramfs-linux-libre-fallback.img
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
  WARNING: Failed to connect to lvmetad. Falling back to device scanning.
done
[root@parabolaiso /]# 
```


## Reboot

```
[root@parabolaiso /]# exit
root@parabolaiso ~ # umount /mnt/boot
root@parabolaiso ~ # umount /mnt/    
root@parabolaiso ~ # lvchange -an /dev/vg/lv_root  
root@parabolaiso ~ # swapoff /dev/vg/lv_swap
root@parabolaiso ~ # lvchange -an /dev/vg/lv_swap
root@parabolaiso ~ # cryptsetup luksClose  /dev/mapper/pv
root@parabolaiso ~ # reboot
Connection to petronella closed by remote host.
Connection to petronella closed.
[staf@vicky octopress]$ 
```

## First boot

If everything goes well GNU/Linux get booted, ... if not. You'll have some fun to resolve the boot issues :-)

<p style="font-style: italic;">
Have fun!
</p>


# Links

* https://libreboot.org/docs/gnulinux/encrypted_parabola.html
* http://stafwag.github.io/blog/blog/2016/08/30/arch-on-an-encrypted-btrfs-partition/
* http://www.brunoparmentier.be/blog/how-to-install-arch-linux-on-an-encrypted-btrfs-partition.html
* http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html


