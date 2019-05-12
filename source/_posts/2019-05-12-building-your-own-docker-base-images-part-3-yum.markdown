---
layout: post
title: "Building Your Own Docker Base Images (Part 3: Yum)"
date: 2019-05-12 10:06:11 +0200
comments: true
categories: [ "docker", "containers", "yum", "centos", "fedora" ]
---

{% img right /images/fedora_logo_small.png 140 140 "fedora_logo_small.png" %}

In my previous two posts ([1](https://stafwag.github.io/blog/blog/2019/04/22/building-your-own-docker-images_part1/),
[2](https://stafwag.github.io/blog/blog/2019/04/22/building-your-own-docker-images_part1/) ), we created Docker [Debian](https://www.debian.org/) and
 [Arch](https://www.archlinux.org/)-based images from scratch for the [i386 architecture](https://en.wikipedia.org/wiki/Intel_80386). 

In this blog post - last one in this series - we'll do the same for [yum](https://en.wikipedia.org/wiki/Yum_\(software\)) based distributions like [CentOS](https://www.centos.org/) and [Fedora](https://getfedora.org/).

Building your own Docker base images isn't difficult and let you trust your distribution Gpg signing keys instead of the [docker hub](https://hub.docker.com/). As explained in [the first blog post](http://stafwag.github.io/blog/blog/2019/04/22/building-your-own-docker-images_part1/). The mkimage scripts in the contrib directory of the [Moby project](https://mobyproject.org/) git repository is a good place to start if you want to build own docker images.

{% img left /images/centos_logo_small.png 267 79 "centos_logo_small.png" %}

Fedora is one of the GNU/Linux distributions that supports 32 bits systems. Centos has a [Special Interest Groups](https://wiki.centos.org/SpecialInterestGroup)
 to support [alternative architectures](https://wiki.centos.org/SpecialInterestGroup/AltArch).
 [The Alternative Architecture SIG](https://wiki.centos.org/SpecialInterestGroup/AltArch) create installation images for power, i386, armhfp (arm v732 bits)
 and aarch64 (arm v8 64-bit).

# Centos

In this blog post, we will create centos based docker images. The procedure to create Fedora images is the same.

## Clone moby

```
staf@centos386 github]$ git clone https://github.com/moby/moby
Cloning into 'moby'...
remote: Enumerating objects: 7, done.
remote: Counting objects: 100% (7/7), done.
remote: Compressing objects: 100% (7/7), done.
remote: Total 269517 (delta 0), reused 1 (delta 0), pack-reused 269510
Receiving objects: 100% (269517/269517), 139.16 MiB | 3.07 MiB/s, done.
Resolving deltas: 100% (182765/182765), done.
[staf@centos386 github]$ 
```

## Go to the contrib directory

```
[staf@centos386 github]$ cd moby/contrib/
[staf@centos386 contrib]$ 
```

## mkimage-yum.sh

When you run ```mkimage-yum.sh``` you get the usage message.

```
[staf@centos386 contrib]$ ./mkimage-yum.sh 
mkimage-yum.sh [OPTIONS] <name>
OPTIONS:
  -p "<packages>"  The list of packages to install in the container.
                   The default is blank. Can use multiple times.
  -g "<groups>"    The groups of packages to install in the container.
                   The default is "Core". Can use multiple times.
  -y <yumconf>     The path to the yum config to install packages from. The
                   default is /etc/yum.conf for Centos/RHEL and /etc/dnf/dnf.conf for Fedora
  -t <tag>         Specify Tag information.
                   default is reffered at /etc/{redhat,system}-release
[staf@centos386 contrib]$
```

## build the image

The ```mkimage-yum.sh``` script will use /etc/yum.conf or /etc/dnf.conf to build the image. ```mkimage-yum.sh <name>``` will create the image with name. 

```
[staf@centos386 contrib]$ sudo ./mkimage-yum.sh centos
[sudo] password for staf: 
+ mkdir -m 755 /tmp/mkimage-yum.sh.LeZQNh/dev
+ mknod -m 600 /tmp/mkimage-yum.sh.LeZQNh/dev/console c 5 1
+ mknod -m 600 /tmp/mkimage-yum.sh.LeZQNh/dev/initctl p
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/full c 1 7
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/null c 1 3
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/ptmx c 5 2
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/random c 1 8
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/tty c 5 0
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/tty0 c 4 0
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/urandom c 1 9
+ mknod -m 666 /tmp/mkimage-yum.sh.LeZQNh/dev/zero c 1 5
+ '[' -d /etc/yum/vars ']'
+ mkdir -p -m 755 /tmp/mkimage-yum.sh.LeZQNh/etc/yum
+ cp -a /etc/yum/vars /tmp/mkimage-yum.sh.LeZQNh/etc/yum/
+ [[ -n Core ]]
+ yum -c /etc/yum.conf --installroot=/tmp/mkimage-yum.sh.LeZQNh --releasever=/ --setopt=tsflags=nodocs --setopt=group_package_types=mandatory -y groupinstall Core
Loaded plugins: fastestmirror, langpacks
There is no installed groups file.
Maybe run: yum groups mark convert (see man yum)
<snip>
+ tar --numeric-owner -c -C /tmp/mkimage-yum.sh.LeZQNh .
+ docker import - centos:7.6.1810
sha256:7cdb02046bff4c5065de670604fb3252b1221c4853cb4a905ca04488f44f52a8
+ docker run -i -t --rm centos:7.6.1810 /bin/bash -c 'echo success'
success
+ rm -rf /tmp/mkimage-yum.sh.LeZQNh
[staf@centos386 contrib]$
```

## Rename

A new image is created with the name centos.

```
[staf@centos386 contrib]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7.6.1810            7cdb02046bff        3 minutes ago       281 MB
[staf@centos386 contrib]$ 
```

You might want to rename to include your name or project name. You can do this by retag the image and remove the old image name.

```
[staf@centos386 contrib]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7.6.1810            7cdb02046bff        20 seconds ago      281 MB
[staf@centos386 contrib]$ docker rmi centos
Error response from daemon: No such image: centos:latest
[staf@centos386 contrib]$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
centos              7.6.1810            7cdb02046bff        3 minutes ago       281 MB
[staf@centos386 contrib]$ docker tag 7cdb02046bff stafwag/centos_386:7.6.1810 
[staf@centos386 contrib]$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
centos               7.6.1810            7cdb02046bff        7 minutes ago       281 MB
stafwag/centos_386   7.6.1810            7cdb02046bff        7 minutes ago       281 MB
[staf@centos386 contrib]$ docker rmi centos:7.6.1810
Untagged: centos:7.6.1810
[staf@centos386 contrib]$ docker images
REPOSITORY           TAG                 IMAGE ID            CREATED             SIZE
stafwag/centos_386   7.6.1810            7cdb02046bff        8 minutes ago       281 MB
[staf@centos386 contrib]$ 
```

## Test

```
[staf@centos386 contrib]$ docker run -it --rm stafwag/centos_386:7.6.1810 /bin/sh
sh-4.2# yum update -y
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.usenet.farm
 * extras: mirror.usenet.farm
 * updates: mirror.usenet.farm
base                                                                                                                   | 3.6 kB  00:00:00     
extras                                                                                                                 | 2.9 kB  00:00:00     
updates                                                                                                                | 2.9 kB  00:00:00     
(1/4): updates/7/i386/primary_db                                                                                       | 2.5 MB  00:00:00     
(2/4): extras/7/i386/primary_db                                                                                        | 157 kB  00:00:01     
(3/4): base/7/i386/group_gz                                                                                            | 166 kB  00:00:01     
(4/4): base/7/i386/primary_db                                                                                          | 4.6 MB  00:00:02     
No packages marked for update
sh-4.2# 
```

*** Have fun! ***
