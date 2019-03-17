---
layout: post
title: "building your own docker images"
date: 2019-03-03 12:36:01 +0100
comments: true
categories: [ "docker", "security", "debian" ] 
---

# Creating your own docker base images
## Debian GNU/Linux

### clone moby

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

### bootstrap 

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

### import 

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

### test

```
staf@whale:~/dockerbuild/debian/stretch-chroot$ docker run -t -i --rm staf_debian:stretch /bin/bash
root@1fc29522e2eb:/# cat /etc/debian_version 
9.8
root@1fc29522e2eb:/# 
```

