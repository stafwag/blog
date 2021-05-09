---
layout: post
title: "Update your bootloader on FreeBSD 13 when you upgrade your zroot pool..."
date: 2021-05-09 09:04:00 +200
comments: true
categories: [ freebsd, openzfs ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/freebsd13_upgrade_zroot_pool/bootfailed.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd13_upgrade_zroot_pool/bootfailed.png' | remove_first:'/' | absolute_url }}" class="left" width="600" height="235" alt="boot failed" /> </a>

One of the nice new features of [FreeBSD](https://www.freebsd.org/) 13 is [OpenZFS](https://openzfs.org/) 2.0.
OpenZFS 2.0 comes with [zstd](https://en.wikipedia.org/wiki/Zstandard) compression support. Zstd compression can have compression ratios similar to ```gzip```
with less CPU usage.

For my backups, I copy the most import data - ```/etc/```, ```/home```, ... - first locally to a ZFS dataset. This data gets synced to a backup server.
This local ZFS dataset was compressed with gzip, after upgrading the zroot pool and setting zstd as the compress method. FreeBSD failed 
to boot with the error message:

```
ZFS: unsupported feature: org.freebsd:zstd
ZFS: pool zroot is not supported
gptzfsboot: failed to mount default pool zroot
```

As this might help people with the same issue, I decided to create a blog post about it. 


<!--more-->

# Update the boot loader

We need to update the boot loader with the newer version that has zstd compression support.

<a href="{{ '/images/freebsd13_upgrade_zroot_pool/live_cd.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd13_upgrade_zroot_pool/live_cd.png' | remove_first:'/' | absolute_url }}" class="right" width="600" height="235" alt="live CD" /> </a>

## Boot from cdrom

Boot your system from FreeBSD 13 installation cdrom/dvd or USB stick and choose ```<Live CD>```.
Log in as the root account, the root account doesn’t have a password on the “Live CD”.

## Enable ssh

I prefer to update the boot loader over ssh.

I followed this blog post to enable sshd on the live cd: [https://www.krisna.net/2018/09/ssh-access-to-freebsd-live-cd-manual.html](https://www.krisna.net/2018/09/ssh-access-to-freebsd-live-cd-manual.html)

```
# ifconfig
# ifconfig <net_interface> xxx.xxx.xxx.xxx up
#	mkdir /tmp/etc
#	mount_unionfs /tmp/etc/ /etc
#	passwd root
#	cd /etc/ssh/
#	vi sshd_config
#	/etc/rc.d/sshd onestart
```

Log on to the system remotely.

```
$ ssh root@xxx.xxx.xxx.xxx
```

## Update the bootloader

The commands to install the bootloader comes from the FreeBSD wiki.

[https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot](https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot)

The wiki page page above describes who install FreeBSD on ZFS root pool. This was very useful before 
the FreeBSD installer had native ZFS support.

List your partitions to get your boot device name and slice number. The example below is on FreeBSD virtual machine, the device name is ```vtb0``` and the slice number is ```1```. On a physical FreeBSD system, the device name is probably ```ada0```.

```
root@:~ # gpart show
=>       40  419430320  vtbd0  GPT  (200G)
         40       1024      1  freebsd-boot  (512K)
       1064        984         - free -  (492K)
       2048    8388608      2  freebsd-swap  (4.0G)
    8390656  411037696      3  freebsd-zfs  (196G)
  419428352       2008         - free -  (1.0M)

=>     33  2335913  cd0  MBR  (4.5G)
       33  2335913       - free -  (4.5G)

=>     33  2335913  iso9660/13_0_RELEASE_AMD64_DVD  MBR  (4.5G)
       33  2335913                                  - free -  (4.5G)

root@:~ # 
```

I use a legacy BIOS on my system. On a system with a legacy BIOS, you can use the following
command to update the bootloader.

```
root@:~ # gpart bootcode -b /boot/pmbr -p /boot/gptzfsboot -i 1 vtbd0
partcode written to vtbd0p1
bootcode written to vtbd0
root@:~ # 
```

To update the bootloader on a UEFI system.

```
# gpart bootcode -p /boot/boot1.efi -i1 ada0
``` 

Should to the trick.

Reboot your FreeBSD 13 system and enjoy ```zstd``` compression.

```
root@:~ # sync
root@:~ # reboot
```

***Have fun!***



# Links

* [https://www.krisna.net/2018/09/ssh-access-to-freebsd-live-cd-manual.html](https://www.krisna.net/2018/09/ssh-access-to-freebsd-live-cd-manual.html)
* [https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot](https://wiki.freebsd.org/RootOnZFS/GPTZFSBoot)

