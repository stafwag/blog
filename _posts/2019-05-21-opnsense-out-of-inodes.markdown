---
layout: post
title: "OPNsense upgrade failed: Out of inodes"
date: 2019-05-21 19:20:37 +0200
comments: true
categories: [ "opnsense", "freebsd" ] 
excerpt_separator: <!--more-->
---

<a href="/blog/images/opnsense_out_of_inodes.jpg"><img src="/blog/images/opnsense_out_of_inodes.jpg" class="left" width="500" height="382" alt="opnsense with no inodes" /></a>

I use [OPNsense](https://opnsense.org/) as [my firewall](http://stafwag.github.io/blog/blog/2018/05/11/32-bits-matters/) on a [Pcengines](https://pcengines.ch/) [Alix](https://pcengines.ch/alix2d13.htm).

The primary reason is to have a firewall that will be always up-to-update, unlike most commercial customer grade firewalls that are only supported for a few years. Having a firewall that runs opensource software - it's based on [FreeBSD](https://www.freebsd.org) - also make it easier to review and to verify that there are no [back doors](https://en.wikipedia.org/wiki/Backdoor_\(computing\)).

When I tried to upgrade it to the latest release - 19.1.7 - the upgrade failed because the filesystem ran out of inodes. There is already [a topic](https://forum.opnsense.org/index.php?topic=12639.15) about this at the [OPNsense forum](https://forum.opnsense.org/index.php?topic=12639.15) and [a fix available](https://github.com/opnsense/tools/commit/0657a0ae479b4) for the upcoming nano OPNsense images.

 <!--more-->
But this will only resolve the issue when a new image becomes available and would require a reinstallation of the firewall.

Unlike [ext2/3/4](https://en.wikipedia.org/wiki/Ext2) or [Sgi](https://en.wikipedia.org/wiki/Silicon_Graphics)'s [XFS](https://en.wikipedia.org/wiki/XFS) on [GNU](https://www.gnu.org/)/[Linux](https://www.kernel.org/), it isn't possible to increase the number of inodes on a [UFS filesystem](https://en.wikipedia.org/wiki/Unix_File_System) on [FreeBSD](https://www.freebsd.org/).

To resolve the upgrade issue I created a backup of the existing filesystem, created a new filesystem with enough inodes, and restored the backup.

You'll find my journey of fixing the out of inodes issue below all commands are executed on a FreeBSD system. Hopefully this useful for someone.

# Fixing the out of inodes

I connected the OPNsense [CF disk ](https://en.wikipedia.org/wiki/CompactFlash) to a USB cardreader on a FreeBSD virtual system.

## Find the disk

Find the CF disk I use ```gpart show``` as this will also display the disk labels etc.

```
root@freebsd:~ # gpart show
=>      40  41942960  vtbd0  GPT  (20G)
        40      1024      1  freebsd-boot  (512K)
      1064       984         - free -  (492K)
      2048   4194304      2  freebsd-swap  (2.0G)
   4196352  37744640      3  freebsd-zfs  (18G)
  41940992      2008         - free -  (1.0M)

=>      0  7847280  da0  BSD  (3.7G)
        0  7847280    1  freebsd-ufs  (3.7G)

=>      0  7847280  ufsid/5a6b137a11c4f909  BSD  (3.7G)
        0  7847280                       1  freebsd-ufs  (3.7G)

=>      0  7847280  ufs/OPNsense_Nano  BSD  (3.7G)
        0  7847280                  1  freebsd-ufs  (3.7G)

root@freebsd:~ # 
```

## Backup

Create a backup with the old-school ```dd```, just in case.

```
root@freebsd:~ # dd if=/dev/da0 of=/home/staf/opnsense.dd bs=4M status=progress
  4013948928 bytes (4014 MB, 3828 MiB) transferred 415.226s, 9667 kB/s
957+1 records in
957+1 records out
4017807360 bytes transferred in 415.634273 secs (9666689 bytes/sec)
root@freebsd:~ # 
```

### mount

Verify that we can mount the filesystem.

```
root@freebsd:/ # mount /dev/da0a /mnt
root@freebsd:/ # cd /mnt
root@freebsd:/mnt # ls
.cshrc                          dev                             net
.probe.for.install.media        entropy                         proc
.profile                        etc                             rescue
.rnd                            home                            root
COPYRIGHT                       lib                             sbin
bin                             libexec                         sys
boot                            lost+found                      tmp
boot.config                     media                           usr
conf                            mnt                             var
root@freebsd:/mnt # cd ..
root@freebsd:/ #  df -i /mnt
Filesystem 1K-blocks    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/da0a    3916903 1237690 2365861    34%   38203  6595   85%   /mnt
root@freebsd:/ # 
```

### umount

```
root@freebsd:/ # umount /mnt
```

### dump 

We'll a create a backup with ```dump```, we'll use this backup to restore it again after we created a new filesystem with enough inodes.

```
root@freebsd:/ # dump 0uaf /home/staf/opensense.dump /dev/da0a
  DUMP: Date of this level 0 dump: Sun May 19 10:43:56 2019
  DUMP: Date of last level 0 dump: the epoch
  DUMP: Dumping /dev/da0a to /home/staf/opensense.dump
  DUMP: mapping (Pass I) [regular files]
  DUMP: mapping (Pass II) [directories]
  DUMP: estimated 1264181 tape blocks.
  DUMP: dumping (Pass III) [directories]
  DUMP: dumping (Pass IV) [regular files]
  DUMP: 16.21% done, finished in 0:25 at Sun May 19 11:14:51 2019
  DUMP: 33.27% done, finished in 0:20 at Sun May 19 11:14:03 2019
  DUMP: 49.65% done, finished in 0:15 at Sun May 19 11:14:12 2019
  DUMP: 66.75% done, finished in 0:09 at Sun May 19 11:13:57 2019
  DUMP: 84.20% done, finished in 0:04 at Sun May 19 11:13:41 2019
  DUMP: 99.99% done, finished soon
  DUMP: DUMP: 1267205 tape blocks on 1 volume
  DUMP: finished in 1800 seconds, throughput 704 KBytes/sec
  DUMP: level 0 dump on Sun May 19 10:43:56 2019
  DUMP: Closing /home/staf/opensense.dump
  DUMP: DUMP IS DONE
root@freebsd:/ # 
```

## newfs

According to the [newfs manpage](https://www.freebsd.org/cgi/man.cgi?newfs\(8\)):
We can specify the inode density with the ```-i``` option. A lower number will give use more inodes.

```
root@freebsd:/ # newfs -i 1 /dev/da0a
density increased from 1 to 4096
/dev/da0a: 3831.7MB (7847280 sectors) block size 32768, fragment size 4096
        using 8 cylinder groups of 479.00MB, 15328 blks, 122624 inodes.
super-block backups (for fsck_ffs -b #) at:
 192, 981184, 1962176, 2943168, 3924160, 4905152, 5886144, 6867136
root@freebsd:/ # 
```

## mount and verify

```
root@freebsd:/ # mount /dev/da0a /mnt
root@freebsd:/ # df -i
Filesystem         1K-blocks    Used    Avail Capacity iused    ifree %iused  Mounted on
zroot/ROOT/default  14562784 1819988 12742796    12%   29294 25485592    0%   /
devfs                      1       1        0   100%       0        0  100%   /dev
zroot/tmp           12742884      88 12742796     0%      11 25485592    0%   /tmp
zroot/usr/home      14522868 1780072 12742796    12%      17 25485592    0%   /usr/home
zroot/usr/ports     13473616  730820 12742796     5%  178143 25485592    1%   /usr/ports
zroot/usr/src       13442804  700008 12742796     5%   84122 25485592    0%   /usr/src
zroot/var/audit     12742884      88 12742796     0%       9 25485592    0%   /var/audit
zroot/var/crash     12742884      88 12742796     0%       8 25485592    0%   /var/crash
zroot/var/log       12742932     136 12742796     0%      21 25485592    0%   /var/log
zroot/var/mail      12742884      88 12742796     0%       8 25485592    0%   /var/mail
zroot/var/tmp       12742884      88 12742796     0%       8 25485592    0%   /var/tmp
zroot               12742884      88 12742796     0%       7 25485592    0%   /zroot
/dev/da0a            3677780       8  3383552     0%       2   980988    0%   /mnt
root@freebsd:/ # 
```

## restore

```
root@freebsd:/mnt # restore rf /home/staf/opensense.dump
root@freebsd:/mnt # 
```

## verify

```
root@freebsd:/mnt # df -ih /mnt
Filesystem    Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/da0a     3.5G    1.2G    2.0G    39%     38k  943k    4%   /mnt
root@freebsd:/mnt # 
```

## Label

The installation had a ```OPNsense_Nano``` label, underscores are not allowed anymore in label name on FreeBSD 12.
So I used OPNsense instead, we'll update ```/etc/fstab``` with the new label name.

```
root@freebsd:~ # tunefs -L OPNsense /dev/da0a
root@freebsd:~ # gpart show
=>      40  41942960  vtbd0  GPT  (20G)
        40      1024      1  freebsd-boot  (512K)
      1064       984         - free -  (492K)
      2048   4194304      2  freebsd-swap  (2.0G)
   4196352  37744640      3  freebsd-zfs  (18G)
  41940992      2008         - free -  (1.0M)

=>      0  7847280  da0  BSD  (3.7G)
        0  7847280    1  freebsd-ufs  (3.7G)

=>      0  7847280  ufsid/5ce123f5836f7018  BSD  (3.7G)
        0  7847280                       1  freebsd-ufs  (3.7G)

=>      0  7847280  ufs/OPNsense  BSD  (3.7G)
        0  7847280             1  freebsd-ufs  (3.7G)

root@freebsd:~ # 
```

## update /etc/fstab

```
root@freebsd:~ # mount /dev/da0a /mnt
root@freebsd:~ # cd /mnt
root@freebsd:/mnt # cd etc
root@freebsd:/mnt/etc # vi fstab 
```

```
# Device                Mountpoint      FStype  Options         Dump    Pass#
/dev/ufs/OPNsense       /               ufs     rw              1       1
```

## umount

```
root@freebsd:/mnt/etc # cd
root@freebsd:~ # umount /mnt
root@freebsd:~ # 
```

## test

```
                  ______  _____  _____                         
                 /  __  |/ ___ |/ __  |                        
                 | |  | | |__/ | |  | |___  ___ _ __  ___  ___ 
                 | |  | |  ___/| |  | / __|/ _ \ '_ \/ __|/ _ \
                 | |__| | |    | |  | \__ \  __/ | | \__ \  __/
                 |_____/|_|    |_| /__|___/\___|_| |_|___/\___|

 +=========================================+     @@@@@@@@@@@@@@@@@@@@@@@@@@@@
 |                                         |   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 |  1. Boot Multi User [Enter]             |   @@@@@                    @@@@@
 |  2. Boot [S]ingle User                  |       @@@@@            @@@@@    
 |  3. [Esc]ape to loader prompt           |    @@@@@@@@@@@       @@@@@@@@@@@
 |  4. Reboot                              |         \\\\\         /////     
 |                                         |   ))))))))))))       (((((((((((
 |  Options:                               |         /////         \\\\\     
 |  5. [K]ernel: kernel (1 of 2)           |    @@@@@@@@@@@       @@@@@@@@@@@
 |  6. Configure Boot [O]ptions...         |       @@@@@            @@@@@    
 |                                         |   @@@@@                    @@@@@
 |                                         |   @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 |                                         |   @@@@@@@@@@@@@@@@@@@@@@@@@@@@  
 +=========================================+                                  
                                                 19.1  ``Inspiring Iguana''   

/boot/kernel/kernel text=0x1406faf data=0xf2af4+0x2abeec syms=[0x4+0xf9f50+0x4+0x1910f5]
/boot/entropy size=0x1000
/boot/kernel/carp.ko text=0x7f90 data=0x374+0x74 syms=[0x4+0xeb0+0x4+0xf40]
/boot/kernel/if_bridge.ko text=0x7b74 data=0x364+0x3c syms=[0x4+0x1020+0x4+0x125f]
loading required module 'bridgestp'
/boot/kernel/bridgestp.ko text=0x4878 data=0xe0+0x18 syms=[0x4+0x6c0+0x4+0x65c]
/boot/kernel/if_enc.ko text=0x1198 data=0x2b8+0x8 syms=[0x4+0x690+0x4+0x813]
/boot/kernel/if_gre.ko text=0x31d8 data=0x278+0x30 syms=[0x4+0xa30+0x4+0xab8]
<snip>
Root file system: /dev/ufs/OPNsense
Sun May 19 10:28:00 UTC 2019

*** OPNsense.stafnet: OPNsense 19.1.6 (i386/OpenSSL) ***
<snip>

 HTTPS: SHA256 E8 9F B2 8B BE F9 D7 2D 00 AD D3 D5 60 E3 77 53
               3D AC AB 81 38 E4 D2 75 9E 04 F9 33 FF 76 92 28
 SSH:   SHA256 FbjqnefrisCXn8odvUSsM8HtzNNs+9xR/mGFMqHXjfs (ECDSA)
 SSH:   SHA256 B6R7GRL/ucRL3JKbHL1OGsdpHRDyotYukc77jgmIJjQ (ED25519)
 SSH:   SHA256 8BOmgp8lSFF4okrOUmL4YK60hk7LTg2N08Hifgvlq04 (RSA)

FreeBSD/i386 (OPNsense.stafnet) (ttyu0)

login: 
```

```
root@OPNsense:~ # df -ih
Filesystem           Size    Used   Avail Capacity iused ifree %iused  Mounted on
/dev/ufs/OPNsense    3.5G    1.2G    2.0G    39%     38k  943k    4%   /
devfs                1.0K    1.0K      0B   100%       0     0  100%   /dev
tmpfs                307M     15M    292M     5%     203  2.1G    0%   /var
tmpfs                292M     88K    292M     0%      27  2.1G    0%   /tmp
devfs                1.0K    1.0K      0B   100%       0     0  100%   /var/unbound/dev
devfs                1.0K    1.0K      0B   100%       0     0  100%   /var/dhcpd/dev
root@OPNsense:~ # 
CTRL-A Z for help | 115200 8N1 | NOR | Minicom 2.7.1 | VT102 | Offline | ttyUSB0                                    
```

## update

```
login: root
Password:
----------------------------------------------
|      Hello, this is OPNsense 19.1          |         @@@@@@@@@@@@@@@
|                                            |        @@@@         @@@@
| Website:      https://opnsense.org/        |         @@@\\\   ///@@@
| Handbook:     https://docs.opnsense.org/   |       ))))))))   ((((((((
| Forums:       https://forum.opnsense.org/  |         @@@///   \\\@@@
| Lists:        https://lists.opnsense.org/  |        @@@@         @@@@
| Code:         https://github.com/opnsense  |         @@@@@@@@@@@@@@@
----------------------------------------------

*** OPNsense.stafnet: OPNsense 19.1.6 (i386/OpenSSL) ***
<snip>

 HTTPS: SHA256 E8 9F B2 8B BE F9 D7 2D 00 AD D3 D5 60 E3 77 53
               3D AC AB 81 38 E4 D2 75 9E 04 F9 33 FF 76 92 28
 SSH:   SHA256 FbjqnefrisCXn8odvUSsM8HtzNNs+9xR/mGFMqHXjfs (ECDSA)
 SSH:   SHA256 B6R7GRL/ucRL3JKbHL1OGsdpHRDyotYukc77jgmIJjQ (ED25519)
 SSH:   SHA256 8BOmgp8lSFF4okrOUmL4YK60hk7LTg2N08Hifgvlq04 (RSA)

  0) Logout                              7) Ping host
  1) Assign interfaces                   8) Shell
  2) Set interface IP address            9) pfTop
  3) Reset the root password            10) Firewall log
  4) Reset to factory defaults          11) Reload all services
  5) Power off system                   12) Update from console
  6) Reboot system                      13) Restore a backup

Enter an option: 12

Fetching change log information, please wait... done

This will automatically fetch all available updates, apply them,
and reboot if necessary.

This update requires a reboot.

Proceed with this action? [y/N]: y 

```

*** Have fun! ***

# Links

* [https://forum.opnsense.org/index.php?topic=12639.15](https://forum.opnsense.org/index.php?topic=12639.15)
* [https://forums.freebsd.org/threads/ufs-backup.185/](https://forums.freebsd.org/threads/ufs-backup.185/)
* [https://www.freebsd.org/doc/handbook/geom-glabel.html](https://www.freebsd.org/doc/handbook/geom-glabel.html)
