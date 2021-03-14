---
layout: post
title: "How to run a FreeBSD Virtual Machine on the RPI4 with QEMU. Part 1: QEMU setup"
date: 2021-03-14 19:46:00 +0200
comments: true
categories: [ raspberrypi , rpi , rrpi4, freebsd, qemu ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/Qemu_logo.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/Qemu_logo.png' | remove_first:'/' | absolute_url }}" class="right" width="600" height="191" alt="OpenVAS" /> </a>

I [got a Raspberry PI 4](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/) a couple of months back and started
 it use it to run [virtual machines](https://stafwag.github.io/blog/blog/2020/07/23/howto-use-cloud-images-on-rpi4/). 

This works great for GNU/Linux distributions but FreeBSD as a virtual machine didn't work for me. When I tried to install FreeBSD or import a virtual machine image, 
FreeBSD wasn't able to mount the root filesystem and ended with an "error 19".

On the [FreeBSD wiki](https://wiki.freebsd.org/), there are a few articles on how to use [ARM64]( https://en.wikipedia.org/wiki/AArch64) FreeBSD with [QEMU](https://www.qemu.org/) directly.

You find my journey of getting a FreeBSD Virtual Machine below.

I use [Manjaro](https://manjaro.org/) on my Raspberry PI, but the same setup will work with other GNU/Linux distributions.

<!--more-->

# Import VM image

## Download the VM image

FreeBSD cloud images are available at [https://download.freebsd.org/ftp/releases/VM-IMAGES/](https://download.freebsd.org/ftp/releases/VM-IMAGES/) for
the aarch64 (ARM64) and x86 ( AMD64, i386) architectures. 

Download the latest VM image of FreeBSD you'd like to use.

## Firmware

To be able to boot the image we need a firmware image (BIOS), there two options [EDK](https://github.com/tianocore/tianocore.github.io/wiki/EDK-II) (UEFI) or [u-boot](https://en.wikipedia.org/wiki/Das_U-Boot). The QEMU source comes with UEFI firmware images, for some reason Arch Linux doesn't include them in the standard QEMU package. The [edk2-avmf AUR package](https://aur.archlinux.org/packages/edk2-avmf/) provides the required 
firmware to virtual systems on ARM64.

## UEFI

### Boot the virtual machine with UEFI

As a test, I booted the release candidate of the upcoming FreeBSD 13 release. This worked fine with a single CPU.

```
$ qemu-system-aarch64 -M virt -m 4096M -cpu host,pmu=off --enable-kvm \
 	-nographic -bios /usr/share/edk2/aarch64/QEMU_EFI.fd \
 	-hda  /home/staf/Downloads/freebsd/FreeBSD-13.0-RC2-arm64-aarch64.qcow2 \
        -boot order=c
```

### SMP

When I tried to enable more than 1 CPU with ```-smp 2``` or ```-smp cores=2,sockets=1``` the system hangs during the startup...

```
qemu-system-aarch64 -M virt -m 4096M -cpu host,pmu=off --enable-kvm -smp cores=2,sockets=1 \
        -nographic -bios /usr/share/edk2/aarch64/QEMU_EFI.fd \
        -hda  /home/staf/Downloads/freebsd/FreeBSD-13.0-RC2-arm64-aarch64.qcow2 \
        -boot order=d
```

I want to use more than 1 CPU core for my FreeBSD virtual system to run [FreeBSD jail](https://en.wikipedia.org/wiki/FreeBSD_jail)s.

## U-boot to the rescue

The other firmware that we can use is U-boot, U-boot is a common used BIOS on ARM64 by a lot of single-board computers...

I didn't find a U-boot package for Manjaro/ArchLinux for QEMU.

### Compile u-boot

Clone the git repo.

```
$ git clone https://source.denx.de/u-boot/u-boot
Cloning into 'u-boot'...
warning: redirecting to https://source.denx.de/u-boot/u-boot.git/
remote: Enumerating objects: 767065, done.
remote: Counting objects: 100% (767065/767065), done.
remote: Compressing objects: 100% (117586/117586), done.
remote: Total 767065 (delta 639963), reused 766651 (delta 639562), pack-reused 0
Receiving objects: 100% (767065/767065), 150.47 MiB | 1.94 MiB/s, done.
Resolving deltas: 100% (639963/639963), done.
Updating files: 100% (17747/17747), done.
```

Goto into the u-boot directory.

```
$ cd u-boot/
[staf@minerva u-boot]$ 
```

Configure u-boot for QEMU on ARM64.

```
$ make qemu_arm64_defconfig
#
# configuration written to .config
#
[staf@minerva u-boot]$ 
```

Compile

```
$ make
scripts/kconfig/conf  --syncconfig Kconfig
  UPD     include/config.h
  CFG     u-boot.cfg
  GEN     include/autoconf.mk
  GEN     include/autoconf.mk.dep
<snip>
  CC      examples/standalone/hello_world.o
  CC      examples/standalone/stubs.o
  LD      examples/standalone/libstubs.o
  LD      examples/standalone/hello_world
  OBJCOPY examples/standalone/hello_world.srec
  OBJCOPY examples/standalone/hello_world.bin
  LDS     u-boot.lds
  LD      u-boot
  OBJCOPY u-boot.srec
  OBJCOPY u-boot-nodtb.bin
  RELOC   u-boot-nodtb.bin
  COPY    u-boot.bin
  SYM     u-boot.sym
  CFGCHK  u-boot.cfg
```

Copy the ```u-boot.bin``` to ```/usr/local```.

Create ```/usr/local/u-boot```.

```
$ sudo mkdir /usr/local/u-boot
```

Copy ```u-boot.bin``` to ```/usr/local/u-boot/```.

```
$ ls -l /usr/local/u-boot/
total 732
-rw-r--r-- 1 root root 749072 Mar 14 14:43 u-boot.bin
```

### Boot FreeBSD with U-boot

FreeBSD boot fine now with 2 CPU's.

```
qemu-system-aarch64 -M virt -m 4096M -cpu host,pmu=off --enable-kvm \
        -smp 2 -nographic -bios /usr/local/u-boot/u-boot.bin \
        -hda /home/staf/Downloads/freebsd/FreeBSD-13.0-RC2-arm64-aarch64.qcow2
```

In an upcoming blog post, I’ll go over the network setup and how to install FreeBSD from CDROM image.

***Have fun!***

# Links

* [https://mightynotes.wordpress.com/2020/08/04/how-to-run-freebsd-arm64-in-a-vm-on-an-arm-linux-server/](https://mightynotes.wordpress.com/2020/08/04/how-to-run-freebsd-arm64-in-a-vm-on-an-arm-linux-server/)
* [https://wiki.freebsd.org/arm64/QEMU](https://wiki.freebsd.org/arm64/QEMU)
* [https://wiki.freebsd.org/QemuRecipes](https://wiki.freebsd.org/QemuRecipes)
* [https://wiki.archlinux.org/index.php/QEMU](https://wiki.archlinux.org/index.php/QEMU)
