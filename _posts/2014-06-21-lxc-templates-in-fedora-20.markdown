---
layout: post
title: "lxc templates in Fedora 20"
date: 2014-06-09 14:28
comments: true
categories: [ linux, containers, lxc, solaris, freebsd, docker, debian, fedora ] 
---

I'm a big fan of containers and used them a lot on <a href="http://en.wikipedia.org/wiki/Solaris_%28operating_system%29">Solaris</a> and <a href="http://www.freebsd.org/doc/handbook/jails.html">jails on Freebsd</a>. Containers/jails are the fastest way to spinup an new system and the easiest way to isolate services.

As always with virtualization you've to careful with sharing systems or containers that doesn't below to the same customer or service on the same physical machine since you're never sure which traces are left behind in the memory etc.

<a href="https://linuxcontainers.org/">Linux containers</a> are getting more popular since the release of <a href="http://www.docker.com/">docker</a>

When I tried to create a few containers on Fedora 20, the first attempt (a debian container) wasn't an success.

On a newly create debian container networking didn't work.

### First debian container

#### Creating the container 

```
[root@vicky ~]# lxc-create -n mydebian -t debian

lxc-create: No config file specified, using the default config /etc/lxc/default.conf
debootstrap is /sbin/debootstrap
Checking cache download in /var/cache/lxc/debian/rootfs-squeeze-i386 ... 
Copying rootfs to /var/lib/lxc/mydebian/rootfs...Generating locales (this might 
&lt; snip &gt;
'debian' template installed
'mydebian' created
```

#### Booting

```
[root@vicky ~]# lxc-start -n mydebian
INIT: version 2.88 booting
Using makefile-style concurrent boot in runlevel S.
Cleaning up ifupdown....
Setting up networking....
Activating lvm and md swap...done.
Checking file systems...fsck from util-linux-ng 2.17.2
done.
Mounting local filesystems...done.
Activating swapfile swap...done.
Cleaning up temporary files....
Configuring network interfaces...ifup: failed to open statefile /etc/network/run/ifstate: No such file or directory
failed.
Setting kernel variables ...done.
Cleaning up temporary files....
INIT: Entering runlevel: 3
Using makefile-style concurrent boot in runlevel 3.
Starting OpenBSD Secure Shell server: sshd.

Debian GNU/Linux 6.0 mydebian console

mydebian login: root
Password: 
Last login: Tue Jun 21 08:05:41 UTC 2014 on console
Linux mydebian 3.14.5-200.fc20.i686 #1 SMP Mon Jun 21 08:13:19 UTC 2014 i686
```

### Network isn't working...

```
The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
root@mydebian:~# ifconfig -a
eth0      Link encap:Ethernet  HWaddr c2:71:98:d8:8f:c3  
          inet6 addr: fe80::c071:98ff:fed8:8fc3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:13 errors:0 dropped:0 overruns:0 frame:0
          TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:908 (908.0 B)  TX bytes:738 (738.0 B)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

root@mydebian:~# ifup eth0
ifup: failed to open statefile /etc/network/run/ifstate: No such file or directory
root@mydebian:~# 
root@mydebian:~# cat /etc/network/interfaces 
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
root@mydebian:~# 
```

### Fedora container

A Fedora container worked better.

#### Creating the fedora container

```
root@vicky ~]# lxc-create -n myfedora -t fedora

lxc-create: No config file specified, using the default config /etc/lxc/default.conf
Host CPE ID from /etc/os-release: cpe:/o:fedoraproject:fedora:20
Checking cache download in /var/cache/lxc/fedora/i686/20/rootfs ... 
Downloading fedora minimal ...
Fetching rpm name from http://be.mirror.eurid.eu/fedora/linux/releases/20/Everything/i386/os//Packages/f...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   290  100   290    0     0    904      0 --:--:-- --:--:-- --:--:--   903
  0     0    0  145k    0     0  47212      0 --:--:--  0:00:03 --:--:-- 58525

<snip>
Updated:
  fedora-release.noarch 0:20-3                                                  

Complete!
Download complete.
Copy /var/cache/lxc/fedora/i686/20/rootfs to /var/lib/lxc/myfedora/rootfs ... 
Copying rootfs to /var/lib/lxc/myfedora/rootfs ...setting root passwd to root
installing fedora-release package
Package fedora-release-20-3.noarch already installed and latest version
Nothing to do
unlink: cannot unlink ‘/var/lib/lxc/myfedora/rootfs/etc/systemd/system/default.target’: No such file or directory
container rootfs and config created
'fedora' template installed
'myfedora' created
[root@vicky ~]# 
```

#### Booting

```
[root@vicky ~]# lxc-start -n myfedora
systemd 208 running in system mode. (+PAM +LIBWRAP +AUDIT +SELINUX +IMA +SYSVINIT +LIBCRYPTSETUP +GCRYPT +ACL +XZ)
Detected virtualization 'lxc'.

Welcome to Fedora 20 (Heisenbug)!

Set hostname to <myfedora>.
[  OK  ] Reached target Remote File Systems.
[  OK  ] Listening on Delayed Shutdown Socket.
[  OK  ] Created slice Root Slice.
[  OK  ] Created slice User and Session Slice.
[  OK  ] Started Login Service.
&lt; snip &gt;
[  OK  ] Reached target Multi-User System.

Fedora release 20 (Heisenbug)
Kernel 3.14.5-200.fc20.i686 on an i686 (console)

myfedora login: root
Password: 
Last login: Wed Jun 21 09:12:42 on console
```

#### Networking

```
[root@myfedora ~]# ping 8.8.8.8
connect: Network is unreachable
[root@myfedora ~]# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
16: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether 5a:89:44:04:99:2b brd ff:ff:ff:ff:ff:ff
    inet6 fe80::5889:44ff:fe04:992b/64 scope link 
       valid_lft forever preferred_lft forever
[root@myfedora ~]# ifup eth0

Determining IP information for eth0... done.
[root@myfedora ~]# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=49 time=113 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=49 time=123 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=49 time=123 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 113.751/120.096/123.408/4.488 ms
[root@myfedora ~]# 
```

### New templates

Since I wanted a Debian container I clone the lxc git on github and copied the templates.

#### Getting the templates

```
[staf@vicky github]$ git clone https://github.com/lxc/lxc 
Cloning into 'lxc'...
remote: Reusing existing pack: 17997, done.
remote: Counting objects: 17, done.
remote: Compressing objects: 100% (17/17), done.
remote: Total 18014 (delta 9), reused 0 (delta 0)
Receiving objects: 100% (18014/18014), 9.14 MiB | 77.00 KiB/s, done.
Resolving deltas: 100% (11555/11555), done.
Checking connectivity... done.
[staf@vicky github]$ 
```

#### Configure

Create the configure script and it dependencies

```
[staf@vicky lxc]$ autoreconf -i
configure.ac:31: installing 'config/compile'
configure.ac:30: installing 'config/config.guess'
configure.ac:30: installing 'config/config.sub'
configure.ac:29: installing 'config/install-sh'
configure.ac:29: installing 'config/missing'
src/lua-lxc/Makefile.am: installing 'config/depcomp'
[staf@vicky lxc]$ 
```

Run configure

```
[staf@vicky lxc]$ ./configure 
checking for pkg-config... /usr/bin/pkg-config
checking pkg-config is at least version 0.9.0... yes
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking build system type... i686-pc-linux-gnu
checking host system type... i686-pc-linux-gnu
checking for style of include used by make... GNU
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
<snip>
Documentation:
 - examples: yes
 - API documentation: no
 - user documentation: no

Debugging:
 - tests: no
 - mutex debugging: no

Paths:
 - Logs in configpath: no
[staf@vicky lxc]$ 
```

#### Copy the templates

Copy the newly created templates
```
[staf@vicky templates]$ shopt -s extglob
[staf@vicky templates]$ 
[staf@vicky templates]$ ls !(*\.in|Makefile*)
lxc-alpine     lxc-centos    lxc-fedora        lxc-oracle  lxc-ubuntu-cloud
lxc-altlinux   lxc-cirros    lxc-gentoo        lxc-plamo
lxc-archlinux  lxc-debian    lxc-openmandriva  lxc-sshd
lxc-busybox    lxc-download  lxc-opensuse      lxc-ubuntu
[staf@vicky templates]$ sudo cp !(*\.in|Makefile*)  /usr/share/lxc/templates[sudo] password for staf: 
[staf@vicky templates]$ 
```

### Debian container second try...

And tried to create the debian container again.

```
[root@vicky ~]# lxc-ls --fancy
NAME      STATE    IPV4  IPV6  
-----------------------------
mydebian  STOPPED  -     -     
myfedora  STOPPED  -     -     
[root@vicky ~]# lxc-destroy -n mydebian
[root@vicky ~]# lxc-ls --fancy
NAME      STATE    IPV4  IPV6  
-----------------------------
myfedora  STOPPED  -     -     
[root@vicky ~]# 
```

#### Creating the container

```
[root@vicky ~]# lxc-create -n mydebian -t debian

lxc-create: No config file specified, using the default config /etc/lxc/default.conf
debootstrap is /sbin/debootstrap
Checking cache download in /usr/local/var/cache/lxc/debian/rootfs-wheezy-i386 ... 
Downloading debian minimal ...
W: Cannot check Release signature; keyring file not available /usr/share/keyrings/debian-archive-keyring.gpg
I: Retrieving Release 
I: Validating Packages 
I: Resolving dependencies of required packages...
I: Resolving dependencies of base packages...
I: Found additional required dependencies: insserv libbz2-1.0 libdb5.1 libsemanage-common libsemanage1 libslang2 libustr-1.0-1 
I: Found additional base dependencies: adduser debian-archive-keyring gnupg gpgv isc-dhcp-common libapt-pkg4.12 libbsd0 libclass-isa-perl libedit2 libgdbm3 libgssapi-krb5-2 libk5crypto3 libkeyutils1 libkrb5-3 libkrb5support0 libncursesw5 libprocps0 libreadline6 libssl1.0.0 libstdc++6 libswitch-perl libusb-0.1-4 libwrap0 openssh-client perl perl-modules procps readline-common 
I: Checking component main on http://cdn.debian.net/debian...
I: Validating libacl1 2.2.51-8
I: Validating adduser 3.113+nmu3
<snip>
I: Unpacking debconf...
I: Unpacking debconf-i18n...
I: Unpacking debianutils...
I: Unpacking diffutils...
I: Unpacking dpkg...
I: Unpacking e2fslibs:i386...
<snip>
I: Configuring apt...
I: Configuring openssh-client...
I: Configuring openssh-server...
I: Configuring perl-modules...
I: Configuring libswitch-perl...
I: Configuring perl...
I: Configuring libui-dialog-perl...
I: Base system installed successfully.
Download complete.
Copying rootfs to /var/lib/lxc/mydebian/rootfs...Generating locales (this might take a while)...
  en_US.UTF-8... done
Generation complete.
update-rc.d: using dependency based boot sequencing
update-rc.d: using dependency based boot sequencing
update-rc.d: using dependency based boot sequencing
update-rc.d: using dependency based boot sequencing
Creating SSH2 RSA key; this may take some time ...
Creating SSH2 DSA key; this may take some time ...
Creating SSH2 ECDSA key; this may take some time ...
invoke-rc.d: policy-rc.d denied execution of restart.
Timezone in container is not configured. Adjust it manually.
Root password is 'root', please change !
'debian' template installed
'mydebian' created
[root@vicky ~]# 
```

#### Booting

```
[root@vicky ~]# lxc-start -n mydebian
INIT: version 2.88 booting
Using makefile-style concurrent boot in runlevel S.
Cleaning up temporary files... /tmp /run /run/lock /run/shm.
Mount point '/dev/mqueue' does not exist. Skipping mount. ... (warning).
Mount point '/dev/hugepages' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/systemd' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/cpuset' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/cpu,cpuacct' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/memory' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/devices' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/freezer' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/net_cls' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/blkio' does not exist. Skipping mount. ... (warning).
Mount point '/sys/fs/cgroup/perf_event' does not exist. Skipping mount. ... (warning).
Filesystem type 'fuse.gvfsd-fuse' is not supported. Skipping mount. ... (warning).
Mount point '/run/media/staf/VBOXADDITIONS_4.3.12_93733' does not exist. Skipping mount. ... (warning).
Mount point '/var/lib/nfs/rpc_pipefs' does not exist. Skipping mount. ... (warning).
Mount point '/usr/lib/lxc/rootfs' does not exist. Skipping mount. ... (warning).
Mount point '/usr/lib/lxc/rootfs' does not exist. Skipping mount. ... (warning).
Mount point '/dev/console' does not exist. Skipping mount. ... (warning).
Activating lvm and md swap...done.
Checking file systems...fsck from util-linux 2.20.1
done.
Mounting local filesystems...done.

Debian GNU/Linux 7 mydebian console

mydebian login: root
Password: 
Linux mydebian 3.14.8-200.fc20.i686 #1 SMP Mon Jun 21 09:36:56 UTC 2014 i686

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

#### Networking....


```
root@mydebian:~# ifconfig eth0
eth0      Link encap:Ethernet  HWaddr 00:16:3e:34:d3:02  
          inet addr:192.168.122.198  Bcast:192.168.122.255  Mask:255.255.255.0
          inet6 addr: fe80::216:3eff:fe34:d302/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:32 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3312 (3.2 KiB)  TX bytes:1806 (1.7 KiB)

root@mydebian:~# ping 8.8.8.8
-bash: ping: command not found
root@mydebian:~# apt-cache search ping | grep util
2ping - Ping utility to determine directional packet loss
galax-extra - XQuery implementation with static typing - utilities
inetutils-ping - ICMP echo tool
iputils-arping - Tool to send ICMP echo requests to an ARP address
iputils-ping - Tools to test the reachability of network hosts
libescape-ruby - HTML/URI/shell escaping utilities for Ruby
mapnik-utils - C++/Python toolkit for developing GIS applications (utilities)
ruby-escape-utils - Faster string escaping routines for your web apps
root@mydebian:~# apt-get install inetutils-ping
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  inetutils-ping
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 169 kB of archives.
After this operation, 273 kB of additional disk space will be used.
WARNING: The following packages cannot be authenticated!
  inetutils-ping
Install these packages without verification [y/N]? y
Get:1 http://cdn.debian.net/debian/ wheezy/main inetutils-ping i386 2:1.9-2 [169 kB]
Fetched 169 kB in 6s (26.4 kB/s)                                               
debconf: delaying package configuration, since apt-utils is not installed
Selecting previously unselected package inetutils-ping.
(Reading database ... 9387 files and directories currently installed.)
Unpacking inetutils-ping (from .../inetutils-ping_2%3a1.9-2_i386.deb) ...
Setting up inetutils-ping (2:1.9-2) ...
root@mydebian:~# ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8): 56 data bytes
64 bytes from 8.8.8.8: icmp_seq=0 ttl=49 time=172.105 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=49 time=111.011 ms
^C--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max/stddev = 111.011/141.558/172.105/30.547 ms
root@mydebian:~# 
```
