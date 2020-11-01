---
layout: post
title: "Upgrade FreeBSD on a Raspberry Pi 2" 
date: 2020-11-01 06:41:50 +0200
comments: true
categories: [ freebsd, raspberrypi, rpi, ARM ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/freebsd-bike/bsdbike.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd-bike/bsdbike.jpg' | remove_first:'/' | absolute_url }}" class="right" width="300" height="347" alt="bsdbike" /> </a>

I recently [installed FreeBSD on my raspberry-pi 2 to use it as my firewall](
https://stafwag.github.io/blog/blog/2020/10/25/rpi2_freebsd_firewall/).

The FreeBSD version that I installed was a FreeBSD 12.2 Pre-Release. FreeBSD 12.2 has been 
[released](https://www.freebsd.org/releases/12.2R/announce.html) this week. 

ARM is a [Tier-2](https://www.freebsd.org/doc/en_US.ISO8859-1/articles/committers-guide/archs.html) on FreeBSD. This means that [freebsd-update](https://www.freebsd.org/cgi/man.cgi?freebsd-update(8)) doesn't work on a Raspberry Pi.

Freebsd-update wouldn't work on a Pre-Release anyway.
So I was looking for a way to update my Raspberry Pi to FreeBSD 12.2.

<!--more-->

Lucky I found this blog post on how to install/update FreeBSD on a Raspberry Pi from the source code.

* [https://solence.de/2017/03/15/installing-and-updating-freebsd-11-0-release-on-a-raspberry-pi/](https://solence.de/2017/03/15/installing-and-updating-freebsd-11-0-release-on-a-raspberry-pi/)

I never did the famous "make world" on FreeBSD, so this was a nice excuse to try it out. Compiling FreeBSD 12.2 on a Raspberry Pi 2 will probably take forever, so I'll
use an x86 system to cross-compile FreeBSD for the Raspberry Pi.

I decided to first update my test x86 FreeBSD test system to 12.2 from the source code. This system was outdated anyway still running FreeBSD 12.0.

If the upgrade went fine, I'd continue with the upgrade on my Raspberry Pi 2 using my FreeBSD test system to cross-compile FreeBSD.

# Prepare host

## Bootenv

It is always a good idea to create a new boot environnment before an upgrade if
you use OpenZFS as your filesystem on FreeBSD. 

Create a new boot environment.

```
root@freebsd:/usr/src # bectl create 12.0-RELEASE-p13
root@freebsd:/usr/src # 
```

List.

```
root@freebsd:/usr/src # bectl list
BE               Active Mountpoint Space Created
default          NR     /          2.94G 2019-05-07 19:53
12.0-RELEASE-p13 -      -          8K    2020-10-31 10:53
root@freebsd:/usr/src # 
```

### Upgrade /usr/src

To compile the FreeBSD source code ... you need the source.
FreeBSD uses subversion as the source code management system.

#### Try to update it...

My test system has "/usr/src" installed, but this didn't seem to be 
an svn repository.

```
root@freebsd:/usr/src # svnlite info /usr/src/
svn: E155007: '/usr/src' is not a working copy
root@freebsd:/usr/src # 
```

#### Snapshot and remove

So I decided to create a ZFS snapshot (just in case) and remove the directory.

```
root@freebsd:/usr # cd /usr/src/
root@freebsd:/usr/src # ls
.arcconfig		README.md		rescue
.arclint		UPDATING		sbin
.gitattributes		bin			secure
.gitignore		cddl			share
COPYRIGHT		contrib			stand
LOCKS			crypto			sys
MAINTAINERS		etc			targets
Makefile		gnu			tests
Makefile.inc1		include			tools
Makefile.libcompat	kerberos5		usr.bin
Makefile.sys.inc	lib			usr.sbin
ObsoleteFiles.inc	libexec
README			release
root@freebsd:/usr/src # rm -rf * .*
root@freebsd:/usr/src # ls -la
root@freebsd:/usr/src # 
```

#### Checkout

Checkout the FreeBSD version that you want to compile.

```
root@freebsd:/usr/src # svnlite checkout https://svn.freebsd.org/base/releng/12.2/ .
```

### Compile

#### make world

Run make world.

```
root@freebsd:/usr/src #  make -j4 buildworld buildkernel
```

### Install

Install the new kernel.

```
root@freebsd:/usr/src # make installkernel
```

Reboot your system.

```
root@freebsd:/usr/src # reboot
Connection to freebsd closed by remote host.
Connection to freebsd closed.
[staf@vicky ~]$ 
```

Install the new userland.

```
root@freebsd:/usr/src # make installworld
```

And reboot your system.

```
root@freebsd:/usr/src # reboot
Connection to freebsd closed by remote host.
Connection to freebsd closed.
[staf@vicky ~]$ 
```

## merge config

[Mergemaster](https://www.freebsd.org/cgi/man.cgi?mergemaster(8)) is a
tool to merge the configuration files on FreeBSD.

```
root@freebsd:/usr/src # mergemaster -Ui
```

The upgrade on the x86 system went fine, so let's continue to use it to
cross-compile FreeBSD for the Raspberry Pi.

# Raspberry pi 

## backup

I created a backup of the sd-card, before the upgraded.

```
[root@vicky pifire001]# dd if=/dev/sdg of=pifire001_16g_freebsd12_prelease.dd bs=1M  status=progress
15917383680 bytes (16 GB, 15 GiB) copied, 739 s, 21.5 MB/s 
15193+1 records in
15193+1 records out
15931539456 bytes (16 GB, 15 GiB) copied, 741.519 s, 21.5 MB/s
[root@vicky pifire001]# sync
[root@vicky pifire001]# 
```

## make world

### make clean

I already used "/usr/src" to compile FreeBSD for x86. For this reason,
a ```make cleanworld``` is probably a good idea.
 

```
root@freebsd:/usr/src # make cleanworld
rm -rf /usr/obj/usr/src/amd64.amd64/*
chflags -R 0 /usr/obj/usr/src/amd64.amd64/
rm -rf /usr/obj/usr/src/amd64.amd64/*
root@freebsd:/usr/src # 
```

### build world

We will cross-compile FreeBSD.

The Raspberry Pi 2 uses the armv7 32 bits architecture.

The ```UBLDR_LOADADDR=0x2000000```has to be setup, this is a requirement
for the U-boot bootloader on the Raspberry Pi.

```
root@freebsd:/usr/src # make -j4 TARGET_ARCH=armv7 UBLDR_LOADADDR=0x2000000 buildworld
```

### build kernel

```
root@freebsd:/usr/src # make -j4 TARGET_ARCH=armv7 KERNCONF=RPI2 buildkernel
```

## mount sdcard

### find

Plugin your sd-card and try to find it. 

```
root@freebsd:~ # geom disk list
Geom name: vtbd0
Providers:
1. Name: vtbd0
   Mediasize: 21474836480 (20G)
   Sectorsize: 512
   Mode: r2w2e3
   descr: (null)
   ident: (null)
   rotationrate: unknown
   fwsectors: 63
   fwheads: 16

Geom name: cd0
Providers:
1. Name: cd0
   Mediasize: 0 (0B)
   Sectorsize: 2048
   Mode: r0w0e0
   descr: QEMU QEMU DVD-ROM
   ident: (null)
   rotationrate: unknown
   fwsectors: 0
   fwheads: 0

Geom name: da0
Providers:
1. Name: da0
   Mediasize: 15931539456 (15G)
   Sectorsize: 512
   Mode: r0w0e0
   descr: Generic STORAGE DEVICE
   ident: (null)
   rotationrate: unknown
   fwsectors: 63
   fwheads: 255

root@freebsd:~ # 

```

### Mount

Mount the root slice to ```/mnt```.

```
root@freebsd:~ # mount /dev/da0s2a /mnt
root@freebsd:~ # 
```

### Install kernel

Install the kernel to the sd-card

```
root@freebsd:/usr/src # make -j4 TARGET_ARCH=armv7 KERNCONF=RPI2 DESTDIR=/mnt installkernel
```

Install the required configuration files, that are required for a make install.


```
root@freebsd:~ # mergemaster -p -A armv7 -D /mnt
```

### install world

```
root@freebsd:/usr/src # make -j4 TARGET_ARCH=armv7 DESTDIR=/mnt installworld
```

Install the new configuration file on sd-card ( -i will install the files that don't exit automatically, -F
will install the new file if only the FreeBSD header is different).

```
root@freebsd:~ # mergemaster -iF -A armv7 -D /mnt
```

### Umount and boot 

Umount the sd-card, and put it into your Raspberry Pi.

```
root@freebsd:~ # umount /mnt
```

Boot the Raspberry Pi and verify that it's running the correct FreeBSD version.

```
staf@pifire001:~ $ uname -a
FreeBSD pifire001 12.2-RELEASE FreeBSD 12.2-RELEASE r367195 RPI2  arm
staf@pifire001:~ $ freebsd-version
12.2-RELEASE
staf@pifire001:~ $ 
```


***Have fun!***

# Links


* [https://solence.de/2017/03/15/installing-and-updating-freebsd-11-0-release-on-a-raspberry-pi/](https://solence.de/2017/03/15/installing-and-updating-freebsd-11-0-release-on-a-raspberry-pi/)
* [https://www.freebsd.org/doc/handbook/makeworld.html](https://www.freebsd.org/doc/handbook/makeworld.html)
