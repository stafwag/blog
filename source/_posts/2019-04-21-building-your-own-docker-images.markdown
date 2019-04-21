---
layout: post
title: "building your own docker base images"
date: 2019-04-21 10:36:01 +0100
comments: true
categories: [ "docker", "security", "debian" ] 
---

## Reasons to build your own docker images

If you want to use [docker](https://www.docker.com/) you can start with docker images on the [docker registry](https://hub.docker.com/).
There are however several reasons to build your own base images.

* ### Security

The first reason is security, docker images are not signed by default.

Anyone can upload docker images to the public docker hub with bugs or malicious code.

There are "official" docker images available at [https://docs.docker.com/docker-hub/official_images/](https://docs.docker.com/docker-hub/official_images/) when you execute a ```docker search```  the official docker images are tagged on the official column and are also signed by Docker. To only allow signed docker images you need to set the ```DOCKER_CONTENT_TRUST=1``` environment variable. - This should be the default IMHO -

There is one distinction, the "official" docker images are signed by the "Repo admin" of the Docker hub, not by the official GNU/Linux distribution project.
If you want to trust the official project instead of the Docker repo admin you can resolve this building your own images.

* ### Support other architecture

Docker images are generally built for [AMD64 architecture](https://en.wikipedia.org/wiki/X86-64), if want to use other architectures like [ARM](https://en.wikipedia.org/wiki/ARM_architecture), [Power](https://en.wikipedia.org/wiki/Power.org#Power_Architecture), [SPARC](https://en.wikipedia.org/wiki/SPARC) or even [i386](https://en.wikipedia.org/wiki/Intel_80386) you'll find some images on the Docker hub but these are usually not Official docker images.

* ### Control 

If you build your own images have more control over what goes or not goes into the image.


### set DOCKER_CONTENT_TRUST=1

```
staf@ubuntu184:~$ export DOCKER_CONTENT_TRUST=1
staf@ubuntu184:~$ 
```

### docker search.

```
staf@ubuntu184:~$ docker search "debian"
NAME                                 DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
ubuntu                               Ubuntu is a Debian-based Linux operating sys   9412                [OK]                
debian                               Debian is a Linux distribution that's compos   3047                [OK]                
google/debian                                                                        54                                      [OK]
arm32v7/debian                       Debian is a Linux distribution that's compos   54                                      
itscaro/debian-ssh                   debian:jessie                                   25                                      [OK]
```   

### docker pull offical image

Docker pull of an official docker image will succeed.

```
staf@ubuntu184:~$ docker pull debian
Using default tag: latest
Pull (1 of 1): debian:latest@sha256:72e996751fe42b2a0c1e6355730dc2751ccda50564fec929f76804a6365ef5ef
sha256:72e996751fe42b2a0c1e6355730dc2751ccda50564fec929f76804a6365ef5ef: Pulling from library/debian
22dbe790f715: Pull complete 
Digest: sha256:72e996751fe42b2a0c1e6355730dc2751ccda50564fec929f76804a6365ef5ef
Status: Downloaded newer image for debian@sha256:72e996751fe42b2a0c1e6355730dc2751ccda50564fec929f76804a6365ef5ef
Tagging debian@sha256:72e996751fe42b2a0c1e6355730dc2751ccda50564fec929f76804a6365ef5ef as debian:latest
staf@ubuntu184:~$ 
```

### docker pull non official image

Docker pull of an official docker image will fail.

```
staf@ubuntu184:~$ docker pull i386/debian
Using default tag: latest
Error: remote trust data does not exist for docker.io/i386/debian: notary.docker.io does not have trust data for docker.io/i386/debian
staf@ubuntu184:~$ 
```  

# Creating your own docker base images
## Clone moby

```
staf@whale:~/github$ git clone https://github.com/moby/moby
Cloning into 'moby'...
remote: Enumerating objects: 265640, done.
remote: Total 265640 (delta 0), reused 0 (delta 0), pack-reused 265640
Receiving objects: 100% (265640/265640), 137.75 MiB | 3.05 MiB/s, done.
Resolving deltas: 100% (179885/179885), done.
Checking out files: 100% (5508/5508), done.
staf@whale:~/github$ 
```

## GNU/Linux distributions
### Debian GNU/Linux
#### Make sure that debootstrap is installed

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

#### bootstrap 

```
staf@whale:~$ mkdir -p dockerbuild/debian
staf@whale:~$ cd dockerbuild/debian/
staf@whale:~/dockerbuild/debian$ 
```

```
staf@whale:~/dockerbuild/debian$ sudo debootstrap --verbose --include=iproute,iputils-ping --arch i386 stretch ./stretch-chroot http://http.debian.net/debian/  
I: Target architecture can be executed
I: Retrieving InRelease 
I: Retrieving Release 
I: Retrieving Release.gpg 
I: Checking Release signature
I: Valid Release signature (key id 067E3C456BAE240ACEE88F6FEF0F382A1A7B6500)
I: Retrieving Packages 
<snip>
I: Configuring ifupdown...
I: Configuring apt-utils...
I: Configuring debconf-i18n...
I: Configuring iproute...
I: Configuring whiptail...
I: Configuring gnupg...
I: Configuring libgnutls30:i386...
I: Configuring wget...
I: Configuring tasksel...
I: Configuring tasksel-data...
I: Configuring libc-bin...
I: Configuring systemd...
I: Base system installed successfully.
```

#### update

```
staf@whale:~/dockerbuild/debian/stretch-chroot$ cd etc/apt/
staf@whale:~/dockerbuild/debian/stretch-chroot/etc/apt$ ls
apt.conf.d  preferences.d  sources.list  sources.list.d  trusted.gpg.d
staf@whale:~/dockerbuild/debian/stretch-chroot/etc/apt$ sudo vi sources.list
```

```
deb http://http.debian.net/debian stretch main contrib
deb http://security.debian.org/debian-security stretch/updates main contrib
```

#### import 

```
staf@whale:~/dockerbuild/debian/stretch-chroot$ sudo tar cpf - . | docker import - staf_debian:stretch
sha256:d7e4c5eb0f29846a86c9a8308927d4275ff86b946ae2b51e7a24c6fb098dc4e0
staf@whale:~/dockerbuild/debian/stretch-chroot$ 
```

```
staf@whale:~/dockerbuild/debian/stretch-chroot$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
staf_debian         stretch             d7e4c5eb0f29        35 seconds ago      262MB
staf@whale:~/dockerbuild/debian/stretch-chroot$ 
```

#### test

```
staf@whale:~/dockerbuild/debian/stretch-chroot$ docker run -t -i --rm staf_debian:stretch /bin/bash
root@1fc29522e2eb:/# cat /etc/debian_version 
9.8
root@1fc29522e2eb:/# 
```
### Ubuntu

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

```
staf@ubuntu184:~$ mkdir -p dockerbuild/ubuntu
staf@ubuntu184:~/dockerbuild/ubuntu$ 
```

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

#### Import

```
staf@ubuntu184:~/dockerbuild/ubuntu$ cd chroot-bionic/
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ sudo tar cpf - . | docker import - staf_ubuntu:bionic
sha256:e03864ab96373da178226f7b1629b504f047f9d69e5d59864d52a468032ae9c4
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

#### Test

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED              SIZE
staf_ubuntu         bionic              e03864ab9637        About a minute ago   292MB
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ 
```

```
staf@ubuntu184:~/dockerbuild/ubuntu/chroot-bionic$ docker run -t -i --rm staf_ubuntu:bionic /bin/bash
root@fb740dc016e3:/# cat /etc/de
debconf.conf    debian_version  default/        deluser.conf    depmod.d/       
root@fb740dc016e3:/# cat /etc/debian_version 
buster/sid
```

### Arch / Parabola 

#### Clone moby

```
[staf@parabola386 github]$ git clone https://github.com/moby/moby
Cloning into 'moby'...
remote: Enumerating objects: 267557, done.
remote: Total 267557 (delta 0), reused 0 (delta 0), pack-reused 267557
Receiving objects: 100% (267557/267557), 138.27 MiB | 2.37 MiB/s, done.
Resolving deltas: 100% (181348/181348), done.
[staf@parabola386 github]$ git clone https://github.com/moby/moby
```


# Links

[https://docs.docker.com/docker-hub/official_images/](https://docs.docker.com/docker-hub/official_images/)
[https://docs.docker.com/engine/security/trust/content_trust/](https://docs.docker.com/engine/security/trust/content_trust/)
