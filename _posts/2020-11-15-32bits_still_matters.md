---
layout: post
title: "32 bits (still) matters!"
date: 2020-11-15 07:52:00 +0200
comments: true
categories: [ freebsd, raspberrypi, 32bits, alix, pcengines, opnsense ] 
excerpt_separator: <!--more-->
---

*updated @ Mon Nov 16 08:16:30 PM CET 2020: Corrected the version when OPNsense dropped 32 bits support.*

<a href="{{ '/images/freebsd_on_alix/freebsd_on_alix_scalled.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd_on_alix/freebsd_on_alix_scalled.png' | remove_first:'/' | absolute_url }}" class="left" width="680" height="385" alt="FreeBSD on alix" /> </a>

I used [OPNsense](https://opnense.org/) on my [pcengines](https://pcengines.ch) [Alix 2d13](https://pcengines.ch/alix2d13.htm) firewall.

The [Alix 2d13 ](https://pcengines.ch/alix2d13.htm) is a nice motherboard with a 
[Geode CPU](https://en.wikipedia.org/wiki/Geode_(processor)) 32 bits [x86](https://en.wikipedia.org/wiki/X86) CPU.

I [migrated to OPNsense](https://stafwag.github.io/blog/blog/2018/05/11/32-bits-matters/) after  [pfSense](https://www.pfsense.org/)  dropped support for 32 bits. Unfortunately, OPNsense also dropped support  for 32 bits CPUs in the ~~[19.1.7 release](https://opnsense.org/opnsense-19-1-7-released/)~~ 20.7 release. I decided to install FreeBSD on my Alix to use it as my firewall.

To make it possible to reinstall my Alix firewall, I [installed FreeBSD on my Raspberry Pi 2](https://stafwag.github.io/blog/blog/2020/10/25/rpi2_freebsd_firewall/) to use it as my firewall during the installation of FreeBSD on my Alix.

You'll find my journey to install FreeBSD my an Alix firewall below.

<!--more-->

# Install FreeBSD on the Alix 2d13

All the step below are executed on a FreeBSD system.

## Partition

I plug the cf card of the Alix into a card reader of my FreeBSD laptop.
The easiest way to find the device name of the disk on FreeBSD is to use the [geom](https://www.freebsd.org/cgi/man.cgi?query=geom) utility. Use ```geom disk list``` to find the cf card.

```
root@snuffel:~ # geom disk list

<snip>

Geom name: da0
Providers:
1. Name: da0
   Mediasize: 4017807360 (3.7G)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic Compact Flash
   ident: 00000000000006
   rotationrate: unknown
   fwsectors: 63
   fwheads: 255

Geom name: da1
Providers:
1. Name: da1
   Mediasize: 0 (0B)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic SD/MMC
   ident: 00000000000006
   rotationrate: unknown
   fwsectors: 0
   fwheads: 0

Geom name: da2
Providers:
1. Name: da2
   Mediasize: 0 (0B)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic microSD
   ident: 00000000000006
   rotationrate: unknown
   fwsectors: 0
   fwheads: 0

Geom name: da3
Providers:
1. Name: da3
   Mediasize: 0 (0B)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic MS/MS-PRO
   ident: 00000000000006
   rotationrate: unknown
   fwsectors: 0
   fwheads: 0

Geom name: da4
Providers:
1. Name: da4
   Mediasize: 0 (0B)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic SM/xD-Picture
   ident: 00000000000006
   rotationrate: unknown
   fwsectors: 0
   fwheads: 0

root@snuffel:~ # 
```

I wanted to clear the partition on the cf card.

User ```dd``` to clear the partition table.

```
root@snuffel:~ # dd if=/dev/zero of=/dev/da0 bs=1k count=1
1+0 records in
1+0 records out
1024 bytes transferred in 0.035529 secs (28821 bytes/sec)
root@snuffel:~ #
```

As this is a dedicated FreeBSD system, I choose not to create a partition table.
But created a BSD slice with [bsdlabel](https://www.freebsd.org/cgi/man.cgi?query=bsdlabel&sektion=8) on the disk directly as described in the [FreeBSD handbook](https://www.freebsd.org/doc/handbook/index.html).

```
root@snuffel:~ # bsdlabel -B -w /dev/da0
root@snuffel:~ # gpart show
=>       40  224674048  ada0  GPT  (107G)
         40       1024     1  freebsd-boot  (512K)
       1064        984        - free -  (492K)
       2048    4194304     2  freebsd-swap  (2.0G)
    4196352  220477440     3  freebsd-zfs  (105G)
  224673792        296        - free -  (148K)

=>      0  7847280  da0  BSD  (3.7G)
        0       16       - free -  (8.0K)
       16  7847264    1  !0  (3.7G)

root@snuffel:~ # 
```

Create the UFS filesystem, I also use the ```-i 1``` option to create a filesystem with more inodes, because [I ran out of inodes on OPNsense](https://stafwag.github.io/blog/blog/2019/05/21/opnsense-out-of-inodes/).

```
root@snuffel:~ # newfs -i 1 /dev/da0a 
density increased from 1 to 4096
/dev/da0a: 3831.7MB (7847264 sectors) block size 32768, fragment size 4096
	using 8 cylinder groups of 479.00MB, 15328 blks, 122624 inodes.
super-block backups (for fsck_ffs -b #) at:
 192, 981184, 1962176, 2943168, 3924160, 4905152, 5886144, 6867136
root@snuffel:~ # 
```
Mount the slice to /mnt.

```
root@snuffel:~ # mount /dev/da0a /mnt
root@snuffel:~ # df -h
Filesystem                       Size    Used   Avail Capacity  Mounted on
zroot/ROOT/default                87G     21G     66G    24%    /
devfs                            1.0K    1.0K      0B   100%    /dev
procfs                           4.0K    4.0K      0B   100%    /proc
zroot/usr/home                    70G    4.1G     66G     6%    /usr/home
zroot/tmp                         66G    1.5M     66G     0%    /tmp
zroot                             66G     88K     66G     0%    /zroot
zroot/var/log                     66G    2.3M     66G     0%    /var/log
zroot/usr/src                     67G    733M     66G     1%    /usr/src
zroot/var/crash                   66G     88K     66G     0%    /var/crash
zroot/var/audit                   66G     88K     66G     0%    /var/audit
zroot/var/mail                    66G    112K     66G     0%    /var/mail
zroot/usr/ports                   67G    740M     66G     1%    /usr/ports
zroot/var/tmp                     66G     88K     66G     0%    /var/tmp
zroot/usr/home/backup             66G     88K     66G     0%    /usr/home/backup
zroot/usr/home/backup/snuffel     67G    1.1G     66G     2%    /usr/home/backup/snuffel
/dev/da0a                        3.5G    8.0K    3.2G     0%    /mnt
root@snuffel:~ # 
```

Label the slice, this will make it easier to mount the root filesystem.

```
root@snuffel:~ # tunefs -L freebsd /dev/da0a
```

## Install FreeBSD

### Download

Download the kernel and the base tarball.

```
[staf@snuffel ~/Downloads/freebsd/i386]$ wget https://download.freebsd.org/ftp/releases/i386/i386/12.2-RELEASE/kernel.txz
--2020-11-11 17:57:11--  https://download.freebsd.org/ftp/releases/i386/i386/12.2-RELEASE/kernel.txz
Resolving download.freebsd.org (download.freebsd.org)... 139.178.72.202, 139.178.72.202, 213.138.116.78, ...
Connecting to download.freebsd.org (download.freebsd.org)|139.178.72.202|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 36979076 (35M) [application/octet-stream]
Saving to: 'kernel.txz'

kernel.txz                     100%[===================================================>]  35.27M  2.00MB/s    in 15s     

2020-11-11 17:57:27 (2.31 MB/s) - 'kernel.txz' saved [36979076/36979076]

[staf@snuffel ~/Downloads/freebsd/i386]$ wget https://download.freebsd.org/ftp/releases/i386/i386/12.2-RELEASE/base.txz
--2020-11-11 17:57:56--  https://download.freebsd.org/ftp/releases/i386/i386/12.2-RELEASE/base.txz
Resolving download.freebsd.org (download.freebsd.org)... 213.138.116.78, 139.178.72.202, 139.178.72.202, ...
Connecting to download.freebsd.org (download.freebsd.org)|213.138.116.78|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 170520220 (163M) [application/octet-stream]
Saving to: 'base.txz'

base.txz                       100%[===================================================>] 162.62M  1.95MB/s    in 97s     

2020-11-11 17:59:34 (1.67 MB/s) - 'base.txz' saved [170520220/170520220]

[staf@snuffel ~/Downloads/freebsd/i386]$ ls -ltr
total 202789
-rw-r--r--  1 staf  staf   36979076 Oct 23 09:39 kernel.txz
-rw-r--r--  1 staf  staf  170520220 Oct 23 09:39 base.txz
[staf@snuffel ~/Downloads/freebsd/i386]$ 
```

## Extract

Extract the kernel to ```/mnt```.

```
root@snuffel:/mnt # tar -xzpvf /home/staf/Downloads/freebsd/i386/kernel.txz -C /mnt
```

Extract the base.

```
root@snuffel:/mnt # tar -xzpvf /home/staf/Downloads/freebsd/i386/base.txz -C /mnt
```

Sync...  

```
root@snuffel:~ # sync
root@snuffel:~ # 
```

## Chroot

Chroot into ```/mnt```.

```
root@snuffel:/mnt # uname -a
FreeBSD snuffel 12.2-RELEASE FreeBSD 12.2-RELEASE r366954 GENERIC  amd64
root@snuffel:/mnt # chroot /mnt
root@snuffel:/ # uname -a
FreeBSD snuffel 12.2-RELEASE FreeBSD 12.2-RELEASE r366954 GENERIC  i386
root@snuffel:/ # 
```

Set the root password.

```
root@snuffel:/ # passwd root
Changing local password for root
New Password:
Retype New Password:
```

Add a user to the system, make sure to add the user to the ```wheel``` group, you'll not be able to become root on BSD
unless the user is in the wheel group.

```
root@snuffel:/ # adduser
Username: staf
Full name: 
Uid (Leave empty for default): 
Login group [staf]: 
Login group is staf. Invite staf into other groups? []: wheel
Login class [default]: 
Shell (sh csh tcsh nologin) [sh]: 
Home directory [/home/staf]: 
Home directory permissions (Leave empty for default): 
Use password-based authentication? [yes]: 
Use an empty password? (yes/no) [no]: 
Use a random password? (yes/no) [no]: 
Enter password: 
Enter password again: 
Lock out the account after creation? [no]: 
Username   : staf
Password   : *****
Full Name  : 
Uid        : 1001
Class      : 
Groups     : staf wheel
Home       : /home/staf
Home Mode  : 
Shell      : /bin/sh
Locked     : no
OK? (yes/no): yes
adduser: INFO: Successfully added (staf) to the user database.
Add another user? (yes/no): no
Goodbye!
root@snuffel:/ # 
```

Create fstab with the root filesystem, the root filesystem is mounted with the label that we created before.

```
# Device                Mountpoint      FStype  Options         Dump    Pass#
/dev/ufs/freebsd       /               ufs     rw              1       1
root@snuffel:/etc # 
```

Set the console out to the serial port.

```
root@snuffel:/ # echo 'console="comconsole"' >> /boot/loader.conf
root@snuffel:/ # 
```

Umount the cf card.

```
root@snuffel:/ # sync
root@snuffel:/ # exit
root@snuffel:/mnt # 
root@snuffel:~ # umount /mnt
root@snuffel:~ # 
```

## First boot

Put the cf card into the Alix system.

Connect to the serial port with the [cu](https://www.freebsd.org/cgi/man.cgi?cu(1)) command.

```
[staf@snuffel /usr/home/staf]$ sudo cu -l /dev/ttyU0
```

Power the Alix system, and enjoy the boot screen.

```
\  ______               ____   _____ _____  
  |  ____|             |  _ \ / ____|  __ \ 
  | |___ _ __ ___  ___ | |_) | (___ | |  | |
  |  ___| '__/ _ \/ _ \|  _ < \___ \| |  | |
  | |   | | |  __/  __/| |_) |____) | |__| |
  | |   | | |    |    ||     |      |      |
  |_|   |_|  \___|\___||____/|_____/|_____/ 
                                                 ```                        `
 +-----------Welcome to FreeBSD------------+    s` `.....---.......--.```   -/
 |                                         |    +o   .--`         /y:`      +.
 |  1. Boot Multi user [Enter]             |     yo`:.            :o      `+-
 |  2. Boot Single user                    |      y/               -/`   -o/
 |  3. Escape to loader prompt             |     .-                  ::/sy+:.
 |  4. Reboot                              |     /                     `--  /
 |  5. Cons: Video                         |    `:                          :`
 |                                         |    `:                          :`
 |  Options:                               |     /                          /
 |  6. Kernel: default/kernel (1 of 1)     |     .-                        -.
 |  7. Boot Options                        |      --                      -.
 |                                         |       `:`                  `:`
 |                                         |         .--             `--.
 +-----------------------------------------+            .---.....----.
   Autoboot in 0 seconds, hit [Enter] to boot or any other key to stop  
```

***Have fun!***


# Links

* [https://phaq.phunsites.net/2016/02/14/quick-and-dirty-freebsd-on-alix-without-pxe-boot/](https://phaq.phunsites.net/2016/02/14/quick-and-dirty-freebsd-on-alix-without-pxe-boot/)
* [https://docs.freebsd.org/doc/6.1-RELEASE/usr/share/doc/handbook/disks-adding.html](https://docs.freebsd.org/doc/6.1-RELEASE/usr/share/doc/handbook/disks-adding.html)
