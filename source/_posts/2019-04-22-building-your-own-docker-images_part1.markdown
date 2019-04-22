---
layout: post
title: "building your own docker base images (Part 1: Debian GNU/Linux & Co)"
date: 2019-04-22 09:36:01 +0100
comments: true
categories: [ "docker", "security", "debian", "ubuntu" ] 
---

I was using [docker on an Odroid U3](https://stafwag.github.io/blog/blog/2015/12/26/running-docker-on-arm/), but my Odroid stopped working. I switched to another system that is i386 only.

You'll find my journey to build docker images for i386 below.
# Reasons to build your own docker images

If you want to use [docker](https://www.docker.com/) you can start with docker images on the [docker registry](https://hub.docker.com/).
There are several reasons to build your own base images.

* ## Security

The first reason is security, docker images are not signed by default.

Anyone can upload docker images to the public docker hub with bugs or malicious code.

There are "official" docker images available at [https://docs.docker.com/docker-hub/official_images/](https://docs.docker.com/docker-hub/official_images/) when you execute a ```docker search```  the official docker images are tagged on the official column and are also signed by Docker. To only allow signed docker images you need to set the ```DOCKER_CONTENT_TRUST=1``` environment variable. - This should be the default IMHO -

There is one distinction, the "official" docker images are signed by the "Repo admin" of the Docker hub, not by the official GNU/Linux distribution project.
If you want to trust the official project instead of the Docker repo admin you can resolve this building your own images.

* ## Support other architectures

Docker images are generally built for [AMD64 architecture](https://en.wikipedia.org/wiki/X86-64). If you want to use other architectures - [ARM](https://en.wikipedia.org/wiki/ARM_architecture), [Power](https://en.wikipedia.org/wiki/Power.org#Power_Architecture), [SPARC](https://en.wikipedia.org/wiki/SPARC) or even [i386](https://en.wikipedia.org/wiki/Intel_80386) - you'll find some images on the Docker hub but these are usually not Official docker images.

* ## Control 

When you build your own images, you have more control over what goes or not goes into the image.

# Building your own docker base images

There are several ways to build your own docker images.

The [Mobyproject](https://mobyproject.org/) is Docker's development project - a bit like what Fedora is to RedHat -.
The Moby project has a few scripts that help you to create docker base images and is also a good start if you want to review how to build your own images.

# GNU/Linux distributions

I build the images on the same GNU/Linux distribution (e.g. The debian images are build on a Debian system) to get the correct gpg keys.

## Debian GNU/Linux & Co

Debian GNU/Linux makes it very easy to build your own Docker base images. Only debootstrap is required.
I'll use the moby script to the Debian base image and debootstrap to build an i386 docker Ubuntu 18.04 image.

Ubuntu doesn't support i386 officially but includes the i386 userland so it's possible to build i386 Docker images. 

### Clone moby

```
staf@whale:~/github$ git clone https://github.com/moby/moby
Cloning into 'moby'...
remote: Enumerating objects: 265639, done.
remote: Total 265639 (delta 0), reused 0 (delta 0), pack-reused 265640
Receiving objects: 99% (265640/265640), 137.75 MiB | 3.05 MiB/s, done.
Resolving deltas: 99% (179885/179885), done.
Checking out files: 99% (5508/5508), done.
staf@whale:~/github$ 
```

### Make sure that debootstrap is installed

```
staf@whale:~/github/moby/contrib$ sudo apt install debootstrap
[sudo] password for staf: 
Reading package lists... Done
Building dependency tree       
Reading state information... Done
debootstrap is already the newest version (1.0.114).
debootstrap set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
staf@whale:~/github/moby/contrib$ 
```

### The Moby way

#### Go to the contrib directory

```
staf@whale:~/github$ cd moby/contrib/
staf@whale:~/github/moby/contrib$ 
```

#### mkimage.sh

 ```mkimage.sh --help``` gives you more details howto use the script. 

```
staf@whale:~/github/moby/contrib$ ./mkimage.sh --help
usage: mkimage.sh [-d dir] [-t tag] [--compression algo| --no-compression] script [script-args]
   ie: mkimage.sh -t someuser/debian debootstrap --variant=minbase jessie
       mkimage.sh -t someuser/ubuntu debootstrap --include=ubuntu-minimal --components=main,universe trusty
       mkimage.sh -t someuser/busybox busybox-static
       mkimage.sh -t someuser/centos:5 rinse --distribution centos-5
       mkimage.sh -t someuser/mageia:4 mageia-urpmi --version=4
       mkimage.sh -t someuser/mageia:4 mageia-urpmi --version=4 --mirror=http://somemirror/
staf@whale:~/github/moby/contrib$ 
```

#### build the image

```
staf@whale:~/github/moby/contrib$ sudo ./mkimage.sh -t stafwag/debian_i386:stretch debootstrap --variant=minbase stretch
[sudo] password for staf: 
+ mkdir -p /var/tmp/docker-mkimage.dY9y9apEoK/rootfs
+ debootstrap --variant=minbase stretch /var/tmp/docker-mkimage.dY9y9apEoK/rootfs
I: Target architecture can be executed
I: Retrieving InRelease 
I: Retrieving Release 
I: Retrieving Release.gpg 
I: Checking Release signature
I: Valid Release signature (key id 067E3C456BAE240ACEE88F6FEF0F382A1A7B6500)
I: Retrieving Packages 
<snip>
```

#### Test

Verify that images is imported.

```
staf@whale:~/github/moby/contrib$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED              SIZE
stafwag/debian_i386   stretch             cb96d1663079        About a minute ago   97.6MB
staf@whale:~/github/moby/contrib$ 
```

Run a test docker instance

```
staf@whale:~/github/moby/contrib$ docker run -t -i --rm stafwag/debian_i386:stretch /bin/sh
# cat /etc/debian_version 
9.8
# 
```

### The debootstrap way

#### Make sure that debootstrap is installed

```
staf@ubuntu184:~/github/moby$ sudo apt install debootstrap
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  ubuntu-archive-keyring
The following NEW packages will be installed:
  debootstrap
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 35,7 kB of archives.
After this operation, 270 kB of additional disk space will be used.
Get:1 http://be.archive.ubuntu.com/ubuntu bionic-updates/main amd64 debootstrap all 1.0.95ubuntu0.3 [35,7 kB]
Fetched 35,7 kB in 0s (85,9 kB/s)    
Selecting previously unselected package debootstrap.
(Reading database ... 163561 files and directories currently installed.)
Preparing to unpack .../debootstrap_1.0.95ubuntu0.3_all.deb ...
Unpacking debootstrap (1.0.95ubuntu0.3) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
Setting up debootstrap (1.0.95ubuntu0.3) ...
staf@ubuntu184:~/github/moby$ 
```
#### bootsrap

Create a directory that will hold the chrooted operating system.

```
staf@ubuntu184:~$ mkdir -p dockerbuild/ubuntu
staf@ubuntu184:~/dockerbuild/ubuntu$ 
```

Bootstrap.

```
staf@ubuntu184:~/dockerbuild/ubuntu$ sudo debootstrap --verbose --include=iputils-ping --arch i386 bionic ./chroot-bionic http://ftp.ubuntu.com/ubuntu/
I: Retrieving InRelease 
I: Checking Release signature
I: Valid Release signature (key id 790BC7277767219C42C86F933B4FE6ACC0B21F32)
I: Validating Packages 
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Checking component main on http://ftp.ubuntu.com/ubuntu...
I: Retrieving adduser 3.116ubuntu1
I: Validating adduser 3.116ubuntu1
I: Retrieving apt 1.6.1
I: Validating apt 1.6.1
I: Retrieving apt-utils 1.6.1
I: Validating apt-utils 1.6.1
I: Retrieving base-files 10.1ubuntu2
<snip>
I: Configuring python3-yaml...
I: Configuring python3-dbus...
I: Configuring apt-utils...
I: Configuring netplan.io...
I: Configuring nplan...
I: Configuring networkd-dispatcher...
I: Configuring kbd...
I: Configuring console-setup-linux...
I: Configuring console-setup...
I: Configuring ubuntu-minimal...
I: Configuring libc-bin...
I: Configuring systemd...
I: Configuring ca-certificates...
I: Configuring initramfs-tools...
I: Base system installed successfully.
```

#### Customize

You can customize your installation before it goes into the image. One thing that you should customize is include update in the image.

Update ```/etc/resolve.conf```

```
staf@ubuntu184:~/dockerbuild/ubuntu$ sudo vi chroot-bionic/etc/resolv.conf
```

```
nameserver 9.9.9.9
```

Update ```/etc/apt/sources.list```

```
staf@ubuntu184:~/dockerbuild/ubuntu$ sudo vi chroot-bionic/etc/apt/sources.list
```

And include the updates

```
deb http://ftp.ubuntu.com/ubuntu bionic main
deb http://security.ubuntu.com/ubuntu bionic-security main
deb http://ftp.ubuntu.com/ubuntu/ bionic-updates main
```

Chroot into your installation and run ```apt-get update```

```
staf@ubuntu184:~/dockerbuild/ubuntu$ sudo chroot $PWD/chroot-bionic
root@ubuntu184:/# apt update
Hit:1 http://ftp.ubuntu.com/ubuntu bionic InRelease
Get:2 http://ftp.ubuntu.com/ubuntu bionic-updates InRelease [88.7 kB]   
Get:3 http://security.ubuntu.com/ubuntu bionic-security InRelease [88.7 kB]       
Get:4 http://ftp.ubuntu.com/ubuntu bionic/main Translation-en [516 kB]                  
Get:5 http://ftp.ubuntu.com/ubuntu bionic-updates/main i386 Packages [492 kB]           
Get:6 http://ftp.ubuntu.com/ubuntu bionic-updates/main Translation-en [214 kB]          
Get:7 http://security.ubuntu.com/ubuntu bionic-security/main i386 Packages [241 kB]     
Get:8 http://security.ubuntu.com/ubuntu bionic-security/main Translation-en [115 kB]
Fetched 1755 kB in 1s (1589 kB/s)      
Reading package lists... Done
Building dependency tree... Done
```

and ```apt-get upgrade```

```
root@ubuntu184:/# apt upgrade
Reading package lists... Done
Building dependency tree... Done
Calculating upgrade... Done
The following NEW packages will be installed:
  python3-netifaces
The following packages will be upgraded:
  apt apt-utils base-files bsdutils busybox-initramfs console-setup console-setup-linux
  distro-info-data dpkg e2fsprogs fdisk file gcc-8-base gpgv initramfs-tools
  initramfs-tools-bin initramfs-tools-core keyboard-configuration kmod libapparmor1
  libapt-inst2.0 libapt-pkg5.0 libblkid1 libcom-err2 libcryptsetup12 libdns-export1100
  libext2fs2 libfdisk1 libgcc1 libgcrypt20 libglib2.0-0 libglib2.0-data libidn11
  libisc-export169 libkmod2 libmagic-mgc libmagic1 libmount1 libncurses5 libncursesw5
  libnss-systemd libpam-modules libpam-modules-bin libpam-runtime libpam-systemd
  libpam0g libprocps6 libpython3-stdlib libpython3.6-minimal libpython3.6-stdlib
  libseccomp2 libsmartcols1 libss2 libssl1.1 libstdc++6 libsystemd0 libtinfo5 libudev1
  libunistring2 libuuid1 libxml2 mount ncurses-base ncurses-bin netcat-openbsd
  netplan.io networkd-dispatcher nplan openssl perl-base procps python3 python3-gi
  python3-minimal python3.6 python3.6-minimal systemd systemd-sysv tar tzdata
  ubuntu-keyring ubuntu-minimal udev util-linux
84 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 26.6 MB of archives.
After this operation, 450 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://security.ubuntu.com/ubuntu bionic-security/main i386 netplan.io i386 0.40.1~18.04.4 [64.6 kB]
Get:2 http://ftp.ubuntu.com/ubuntu bionic-updates/main i386 base-files i386 10.1ubuntu2.4 [60.3 kB]
Get:3 http://security.ubuntu.com/ubuntu bionic-security/main i386 libapparmor1 i386 2.12-4ubuntu5.1 [32.7 kB]
Get:4 http://security.ubuntu.com/ubuntu bionic-security/main i386 libgcrypt20 i386 1.8.1-
<snip>
running python rtupdate hooks for python3.6...
running python post-rtupdate hooks for python3.6...
Setting up initramfs-tools-core (0.130ubuntu3.7) ...
Setting up initramfs-tools (0.130ubuntu3.7) ...
update-initramfs: deferring update (trigger activated)
Setting up python3-gi (3.26.1-2ubuntu1) ...
Setting up file (1:5.32-2ubuntu0.2) ...
Setting up python3-netifaces (0.10.4-0.1build4) ...
Processing triggers for systemd (237-3ubuntu10.20) ...
Setting up networkd-dispatcher (1.7-0ubuntu3.3) ...
Installing new version of config file /etc/default/networkd-dispatcher ...
Setting up netplan.io (0.40.1~18.04.4) ...
Setting up nplan (0.40.1~18.04.4) ...
Setting up ubuntu-minimal (1.417.1) ...
Processing triggers for libc-bin (2.27-3ubuntu1) ...
Processing triggers for initramfs-tools (0.130ubuntu3.7) ...
root@ubuntu184:/# 
staf@ubuntu184:~/dockerbuild/ubuntu$ 
```

#### Import

Go to your chroot installation.

```
staf@ubuntu184:~/dockerbuild/ubuntu$ cd chroot-bionic/
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

and import the image.

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ sudo tar cpf - . | docker import - stafwag/ubuntu_i386:bionic
sha256:83560ef3c8d48b737983ab8ffa3ec3836b1239664f8998038bfe1b06772bb3c2
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

#### Test

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ docker images
REPOSITORY            TAG                 IMAGE ID            CREATED              SIZE
stafwag/ubuntu_i386   bionic              83560ef3c8d4        About a minute ago   315MB
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ docker run -it --rm stafwag/ubuntu_i386:bionic /bin/bash
root@665cec6ee24f:/# lsb_release -a
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 18.04.2 LTS
Release:        18.04
Codename:       bionic
root@665cec6ee24f:/# 
```

*** Have fun! ***

# Links

[https://docs.docker.com/docker-hub/official_images/](https://docs.docker.com/docker-hub/official_images/)
[https://docs.docker.com/engine/security/trust/content_trust/](https://docs.docker.com/engine/security/trust/content_trust/)
