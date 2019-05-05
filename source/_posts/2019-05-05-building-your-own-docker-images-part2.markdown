---
layout: post
title: "Building your own docker images (Part2: Arch GNU/Linux & Co)"
date: 2019-05-05 11:03:05 +0200
comments: true
categories: [ "docker", "containers", "archlinux", "parabola" ]
---

In [my previous post](https://stafwag.github.io/blog/blog/2019/04/22/building-your-own-docker-images_part1/), we started with creating [Debian](https://www.debian.org/) based docker images from scratch for the [i386 architecture](https://en.wikipedia.org/wiki/Intel_80386). 

In this blog post, we'll create Arch GNU/Linux based images.

# Arch GNU/Linux

[Arch Linux](https://www.archlinux.org/) stopped supporting i386 systems. When you want to run Archlinux on an i386 system there is a community maintained [Archlinux32](https://archlinux32.org/) project and the [Free software](https://en.wikipedia.org/wiki/Free_software) version [Parabola GNU/Linux-libre](https://www.parabola.nu/). 

For the [arm architecture](https://en.wikipedia.org/wiki/ARM_architecture), there is [Archlinux Arm](https://archlinuxarm.org/) project that I [used](https://stafwag.github.io/blog/blog/2015/12/26/running-docker-on-arm/).

## mkimage-arch.sh in moby

I used ```mkimage-arch.sh``` from the [Moby/Docker project](https://mobyproject.org/) in the past, but it failed when 
I tried it this time...

I created a small patch to fix it and created [a pull request](https://github.com/moby/moby/pull/39165).
Till the issue is resolved, you can use the version in my [cloned git repository](https://github.com/stafwag/moby/blob/). 

## Build the docker image

### Install the required packages

Make sure that your system is up-to-date.

```
staf@archlinux32 contrib]$ sudo pacman -Syu
```

Install the required packages.

```
[staf@archlinux32 contrib]$ sudo pacman -S arch-install-scripts expect wget
``` 
### Directory

Create a directory that will hold the image data.

```
[staf@archlinux32 ~]$ mkdir -p dockerbuild/archlinux32
[staf@archlinux32 ~]$ cd dockerbuild/archlinux32
[staf@archlinux32 archlinux32]$ 
```

### Get mkimage-arch.sh

```
[staf@archlinux32 archlinux32]$ wget https://raw.githubusercontent.com/stafwag/moby/master/contrib/mkimage-arch.sh
--2019-05-05 07:46:32--  https://raw.githubusercontent.com/stafwag/moby/master/contrib/mkimage-arch.sh
Loaded CA certificate '/etc/ssl/certs/ca-certificates.crt'
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 151.101.36.133
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|151.101.36.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 3841 (3.8K) [text/plain]
Saving to: 'mkimage-arch.sh'

mkimage-arch.sh                 100%[====================================================>]   3.75K  --.-KB/s    in 0s      

2019-05-05 07:46:33 (34.5 MB/s) - 'mkimage-arch.sh' saved [3841/3841]

[staf@archlinux32 archlinux32]$ 
```

Make it executable.

```
[staf@archlinux32 archlinux32]$ chmod +x mkimage-arch.sh
[staf@archlinux32 archlinux32]$ 
```

### Setup your pacman.conf

Copy your pacmnan.conf to the directory that holds ```mkimage-arch.sh```.

```
[staf@archlinux32 contrib]$ cp /etc/pacman.conf mkimage-arch-pacman.conf
[staf@archlinux32 contrib]$ 
```

### Build your image

```
[staf@archlinux32 archlinux32]$ TMPDIR=`pwd` sudo ./mkimage-arch.sh
spawn pacstrap -C ./mkimage-arch-pacman.conf -c -d -G -i /var/tmp/rootfs-archlinux-wqxW0uxy8X base bash haveged pacman pacman-mirrorlist --ignore dhcpcd,diffutils,file,inetutils,iproute2,iputils,jfsutils,licenses,linux,linux-firmware,lvm2,man-db,man-pages,mdadm,nano,netctl,openresolv,pciutils,pcmciautils,psmisc,reiserfsprogs,s-nail,sysfsutils,systemd-sysvcompat,usbutils,vi,which,xfsprogs
==> Creating install root at /var/tmp/rootfs-archlinux-wqxW0uxy8X
==> Installing packages to /var/tmp/rootfs-archlinux-wqxW0uxy8X
:: Synchronizing package databases...
 core                                              198.0 KiB   676K/s 00:00 [##########################################] 100%
 extra                                               2.4 MiB  1525K/s 00:02 [##########################################] 100%
 community                                           6.3 MiB   396K/s 00:16 [##########################################] 100%
:: dhcpcd is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: diffutils is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: file is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
<snip>
==> WARNING: /var/tmp/rootfs-archlinux-wqxW0uxy8X is not a mountpoint. This may have undesirable side effects.
Generating locales...
  en_US.UTF-8... done
Generation complete.
tar: ./etc/pacman.d/gnupg/S.gpg-agent.ssh: socket ignored
tar: ./etc/pacman.d/gnupg/S.gpg-agent.extra: socket ignored
tar: ./etc/pacman.d/gnupg/S.gpg-agent: socket ignored
tar: ./etc/pacman.d/gnupg/S.gpg-agent.browser: socket ignored
sha256:41cd9d9163a17e702384168733a9ca1ade0c6497d4e49a2c641b3eb34251bde1
Success.
[staf@archlinux32 archlinux32]$ 
```

### Rename

A new image is created with the name archlinux.

```
[staf@archlinux32 archlinux32]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
archlinux           latest              18e74c4d823c        About a minute ago   472MB
[staf@archlinux32 archlinux32]$ 
```

You might want to rename it. You can do this by retag the image and remove the old image name.

```
[staf@archlinux32 archlinux32]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
archlinux           latest              18e74c4d823c        About a minute ago   472MB
[staf@archlinux32 archlinux32]$ docker tag stafwag/archlinux:386 18e74c4d823c
Error response from daemon: No such image: stafwag/archlinux:386
[staf@archlinux32 archlinux32]$ docker tag 18e74c4d823c stafwag/archlinux:386             
[staf@archlinux32 archlinux32]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
archlinux           latest              18e74c4d823c        3 minutes ago       472MB
stafwag/archlinux   386                 18e74c4d823c        3 minutes ago       472MB
[staf@archlinux32 archlinux32]$ docker rmi archlinux
Untagged: archlinux:latest
[staf@archlinux32 archlinux32]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
stafwag/archlinux   386                 18e74c4d823c        3 minutes ago       472MB
[staf@archlinux32 archlinux32]$ 
```

### Test

```
[staf@archlinux32 archlinux32]$ docker run --rm -it stafwag/archlinux:386 /bin/sh
sh-5.0# pacman -Syu
:: Synchronizing package databases...
 core is up to date
 extra is up to date
 community is up to date
:: Starting full system upgrade...
 there is nothing to do
sh-5.0# 
```

*** Have fun! ***

