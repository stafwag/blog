---
layout: post
title: "Create a custom ArchLinux boot image with linux-lts and OpenZFS support"
date: 2022-12-21 19:03:00 +0200
comments: true
categories: [ linux, zfs, openzfs, archlinux ]
excerpt_separator: <!--more-->
---

<a href="{{ '/images/openzfs/openzfs_logo_2.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/openzfs/openzfs_logo_2.png' | remove_first:'/' | absolute_url }}" class="left" width="431" height="331" alt="OpenZFS" /> </a>

I use [ArchLinux](https://archlinux.org/) on my desktop workstation.
For the root filesystem, I use [btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) with [luks](https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup) disk encryption and wrote a blog post about it.

[https://stafwag.github.io/blog/blog/2016/08/30/arch-on-an-encrypted-btrfs-partition/](https://stafwag.github.io/blog/blog/2016/08/30/arch-on-an-encrypted-btrfs-partition/).

My important data is on [OpenZFS](https://openzfs.org/).

I'll migrate my desktop to ArchLinux with OpenZFS in [RAIDZ](https://openzfs.github.io/openzfs-docs/Basic%20Concepts/RAIDZ.html) configuration as the root filesystem.

To make installation easier I decide to create a custom ArchLinux boot image with linux-lts and OpenZFS support.

You'll find my journey to create the boot iso below. All action are execute on a ArchLinux host system (already using OpenZFS)

<!--more-->

# Preparation

## Create a work directory

I created a separate ZFS dataset for the installation on the host system.

```
[staf@frija archlinux_raidz]$ sudo zfs create <your_zfs_pool>/<data_set>/home/staf/iso
```

```
[staf@frija archlinux_raidz]$ sudo chown staf:staf /home/staf/iso/
[staf@frija archlinux_raidz]$ 
```

```
[staf@frija archlinux_raidz]$ cd /home/staf/iso/
[staf@frija iso]$ 
```

## Install archiso

Install the ```archiso``` package.

```
[staf@frija archlinux_raidz]$ sudo pacman -Sy archiso
```

## Import the ArchZFS GPG public key

The ```archiso``` script uses the GPG public key from the "host" system.
If you aren't using the [archzfs.com](archzfs.com) on your host, you need import the GPG public key.

```
curl -L https://archzfs.com/archzfs.gpg |  pacman-key -a -
pacman-key --lsign-key $(curl -L https://git.io/JsfVS)
curl -L https://git.io/Jsfw2 > /etc/pacman.d/mirrorlist-archzfs
```

# Create iso image
## Copy the config

Copy the default configuration.

```
[staf@frija iso]$ cp -r /usr/share/archiso/configs/releng/* ~/iso
[staf@frija iso]$ 
```

## Update the packages file

```
[staf@frija iso]$ vi packages.x86_64 
```

We'll use [dkms](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support) to build the OpenZFS module.
Add the required packages to build the module.

```
linux-lts
linux-lts-headers
archzfs-dkms
zfs-utils
```

## Update pacman.conf

Update the ```pacman.conf``` in the work directory  (```~/iso```) to include the [archzfs.com](archzfs.com) repository.

```
[staf@frija iso]$ vi pacman.conf
```

```
[archzfs]
Server = https://archzfs.com/$repo/$arch
```

## Update boot configuration
## grub

Update grub config and add the ```linux-lts``` entries.

```
[staf@frija iso]$ cd grub/
[staf@frija grub]$ ls
grub.cfg
[staf@frija grub]$ vi grub.cfg 
```

```
menuentry "Arch Linux LTS install medium (x86_64, UEFI)" --class arch --class gnu-linux --class gnu --class os --id 'archlinux' {
    set gfxpayload=keep
    search --no-floppy --set=root --label %ARCHISO_LABEL%
    linux /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-lts archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL%
    initrd /%INSTALL_DIR%/boot/intel-ucode.img /%INSTALL_DIR%/boot/amd-ucode.img /%INSTALL_DIR%/boot/x86_64/initramfs-linux-lts.img
}

menuentry "Arch Linux install LTS medium with speakup screen reader (x86_64, UEFI)" --hotkey s --class arch --class gnu-linux --class gnu --class os --id 'archlinux-accessibility' {
    set gfxpayload=keep
    search --no-floppy --set=root --label %ARCHISO_LABEL%
    linux-lts /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-lts archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL% accessibility=on
    initrd /%INSTALL_DIR%/boot/intel-ucode.img /%INSTALL_DIR%/boot/amd-ucode.img /%INSTALL_DIR%/boot/x86_64/initramfs-linux-lts.img
```

## UEFI

In practice grub will be used. But for some reasom I ended up to update the uefi configuration :-)

Copy the default efi boot entry.

```
[staf@frija iso]$ cp ./efiboot/loader/entries/01-archiso-x86_64-linux.conf ./efiboot/loader/entries/03-archiso-x86_64-linux-lts.conf
[staf@frija iso]$ 
```

```
title    Arch Linux LTS install medium (x86_64, UEFI)
sort-key 03
linux    /%INSTALL_DIR%/boot/x86_64/vmlinuz-linux-lts
initrd   /%INSTALL_DIR%/boot/intel-ucode.img
initrd   /%INSTALL_DIR%/boot/amd-ucode.img
initrd   /%INSTALL_DIR%/boot/x86_64/initramfs-linux-lts.img
options  archisobasedir=%INSTALL_DIR% archisolabel=%ARCHISO_LABEL%
```

## Build the iso image

```
staf@frija iso]$  mkarchiso -v -o out .
[mkarchiso] ERROR: mkarchiso must be run as root.
[staf@frija iso]$ sudo  mkarchiso -v -o out .
[sudo] password for staf: 
[mkarchiso] INFO: Validating options...
[mkarchiso] INFO: Done!
[mkarchiso] INFO: mkarchiso configuration settings
[mkarchiso] INFO:              Architecture:   x86_64
[mkarchiso] INFO:         Working directory:   /home/staf/iso/work
[mkarchiso] INFO:    Installation directory:   arch
[mkarchiso] INFO:                Build date:   2022-12-14T20:24+0100
[mkarchiso] INFO:          Output directory:   /home/staf/iso/out
[mkarchiso] INFO:        Current build mode:   iso
[mkarchiso] INFO:               Build modes:   iso
[mkarchiso] INFO:                   GPG key:   None
[mkarchiso] INFO:                GPG signer:   None
[mkarchiso] INFO: Code signing certificates:   None
[mkarchiso] INFO:                   Profile:   /home/staf/iso
[mkarchiso] INFO: Pacman configuration file:   /home/staf/iso/pacman.conf
[mkarchiso] INFO:           Image file name:   archlinux-2022.12.14-x86_64.iso
<snip>
```

***Have fun!***

# Links


* [https://szorfein.github.io/zfs/make-your-own-archiso-with-ZFS/](https://szorfein.github.io/zfs/make-your-own-archiso-with-ZFS/)
* [https://blog.timo.page/installing-arch-linux-on-zfs](https://blog.timo.page/installing-arch-linux-on-zfs)
* [https://bbs.archlinux.org/viewtopic.php?id=266385](https://bbs.archlinux.org/viewtopic.php?id=266385)
* [https://wiki.archlinux.org/title/Archiso](https://wiki.archlinux.org/title/Archiso)
