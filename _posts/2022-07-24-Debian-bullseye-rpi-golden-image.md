---
layout: post
title: "Debian bullseye on the RPI 4: golden image"
date: 2022-07-24 8:02:01 +0200
comments: true
categories: [  "raspberry-pi", "rpi" , "linux", "debian", "arm64", "openzfs" ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/pi/migrate_to_debian/golden_image.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/pi/migrate_to_debian/golden_image.jpg' | remove_first:'/' | absolute_url }}" class="right" width="500" height="333" alt="migrate_to_debian" /> </a>

In my last blog post, we [set up Debian bullseye with full disk encryption on a Raspberry PI 4](https://stafwag.github.io/blog/blog/2022/07/03/Debian-bullseye-rpi4-full-disk-encryption/).

I use 3 three Raspberry PI's to run  [K3s](https://k3s.io) and a few [FreeBSD]( https://www.freebsd.org/) virtual machines. For the FreeBSD virtual machines I still use QEMU: [https://stafwag.github.io/blog/blog/2021/03/14/howto_run_freebsd_as_vm_on_pi/](https://stafwag.github.io/blog/blog/2021/03/14/howto_run_freebsd_as_vm_on_pi/), I still need to test if we can use KVM/libvirt with the UEFI improvements in FreeBSD 13.1. But that might be another blog post :-)

As need I the same installation at least three times, I decided to create a "golden image" with the most important tools.

<!--more-->

# chroot

The chroot actions are executed a Debian bullseye virtual machine. ```/dev/sda``` is a USB harddisk that is attached 
to this virtual machine.

The installation continue from my previous blog post: [https://stafwag.github.io/blog/blog/2022/07/03/Debian-bullseye-rpi4-full-disk-encryption/](https://stafwag.github.io/blog/blog/2022/07/03/Debian-bullseye-rpi4-full-disk-encryption/)

## mount filesystems

Open the root luks encryption partition.

```
root@debian11:~# cryptsetup luksOpen /dev/sda2 cryptroot
Enter passphrase for /dev/sda2: 
root@debian11:~#
```

Mount the root filesystem.

```
root@debian11:~# mount /dev/mapper/cryptroot /mnt/chroot/
```

Mount the boot filesystem. This is ```/boot/firmware``` on a Raspberry PI with Debian GNU/Linux.

## mount proc & co

```
root@debian11:~# mount -t proc none /mnt/chroot/proc
root@debian11:~# mount -t sysfs none /mnt/chroot/sys
root@debian11:~# mount -o bind /dev /mnt/chroot/dev
root@debian11:~# mount -o bind /dev /mnt/chroot/dev
root@debian11:~# mount -o bind /dev/pts /mnt/chroot/dev/pts
root@debian11:~# 
```

## chroot

```chroot``` into the ARM64 installation.

```
root@debian11:~# chroot /mnt/chroot/
```

Verify that we're running ```aarch64```.

```
root@debian11:/# uname -a
Linux debian11 5.10.0-16-amd64 #1 SMP Debian 5.10.127-1 (2022-06-30) aarch64 GNU/Linux
root@debian11:/# 
```

Set the ```$PATH```

```
root@debian11:/# export PATH=/sbin:/bin:/usr/sbin:/usr/bin
root@debian11:/# 
```

# Install OpenZFS

I always try to use [OpenZFS](https://openzfs.org/wiki/Main_Page) for my important data.

Debian has [OpenZFS](https://openzfs.org/wiki/Main_Page) included in the official repositories.
More recent versions are available in the backports repository.

## Enable bullseye backports

Run ```apt update```.

```
root@debian11:/#  apt update
Get:1 http://security.debian.org/debian-security bullseye-security InRelease [44.1 kB]
Hit:2 http://deb.debian.org/debian bullseye InRelease                          
Fetched 44.1 kB in 5s (9626 B/s)                        
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
root@debian11:/#     
```

Go to ```/etc/apt/sources.list.d/```.

```
root@debian11:/# cd /etc/apt/sources.list.d/
root@debian11:/etc/apt/sources.list.d# 
```

Create ```bullseye-backports.list```.

```
root@debian11:/etc/apt/sources.list.d# vi bullseye-backports.list
root@debian11:/etc/apt/sources.list.d# 
```

```
deb http://deb.debian.org/debian bullseye-backports main contrib
deb-src http://deb.debian.org/debian bullseye-backports main contrib
```

Create ```/etc/apt/preferences.d/90_zfs```

```
Package: src:zfs-linux
Pin: release n=bullseye-backports
Pin-Priority: 990
```

## Install OpenZFS

Run ```apt update``` to get the backports repository data.

```
root@debian11:/etc/apt/sources.list.d# apt update
Hit:1 http://deb.debian.org/debian bullseye InRelease
Get:2 http://deb.debian.org/debian bullseye-backports InRelease [44.2 kB]
Hit:3 http://security.debian.org/debian-security bullseye-security InRelease
Get:4 http://deb.debian.org/debian bullseye-backports/contrib Sources [2584 B]
Get:5 http://deb.debian.org/debian bullseye-backports/main Sources [297 kB]
Get:6 http://deb.debian.org/debian bullseye-backports/main arm64 Packages [311 kB]
Get:7 http://deb.debian.org/debian bullseye-backports/main Translation-en [242 kB]
Get:8 http://deb.debian.org/debian bullseye-backports/contrib arm64 Packages [4144 B]
Get:9 http://deb.debian.org/debian bullseye-backports/contrib Translation-en [4196 B]
Fetched 906 kB in 5s (173 kB/s)                               
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
root@debian11:/etc/apt/sources.list.d# 
```

Due the potential license issues we need to compile OpenZFS from source.

Install the required development packages.

```
root@debian11:/etc/apt/sources.list.d# apt install dpkg-dev linux-headers-arm64      
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  binutils binutils-aarch64-linux-gnu binutils-common build-essential bzip2 cpp cpp-10 dirmngr
  linux-headers-5.10.0-16-arm64 linux-headers-5.10.0-16-common linux-kbuild-5.10 linux-libc-dev
<snip>
  make manpages manpages-dev patch perl perl-modules-5.32 pinentry-curses xz-utils
Suggested packages:
  binutils-doc bzip2-doc cpp-doc gcc-10-locales dbus-user-session pinentry-gnome3 tor
  debian-keyring gcc-10-doc gcc-multilib autoconf automake libtool flex bison gdb gcc-doc
  parcimonie xloadimage scdaemon glibc-doc git bzr libgd-tools gdbm-l10n
  libsasl2-modules-gssapi-mit | libsasl2-modules-gssapi-heimdal libsasl2-modules-ldap
  libsasl2-modules-otp libsasl2-modules-sql libstdc++-10-doc make-doc man-browser ed
  diffutils-doc perl-doc libterm-readline-gnu-perl | libterm-readline-perl-perl
  libtap-harness-archive-perl pinentry-doc
The following NEW packages will be installed:
  binutils binutils-aarch64-linux-gnu binutils-common build-essential bzip2 cpp cpp-10 dirmngr
  dpkg-dev fakeroot fontconfig-config fonts-dejavu-core g++ g++-10 gcc gcc-10 gnupg gnupg-l10n
<snip>
0 upgraded, 88 newly installed, 0 to remove and 0 not upgraded.
Need to get 89.4 MB of archives.
After this operation, 348 MB of additional disk space will be used.
Do you want to continue? [Y/n] 
<snip>
Setting up gpg-wks-client (2.2.27-2+deb11u2) ...
Setting up gcc (4:10.2.1-1) ...
Setting up perl (5.32.1-4+deb11u2) ...
Setting up libgd3:arm64 (2.3.0-2) ...
Setting up libdpkg-perl (1.20.11) ...
Setting up g++ (4:10.2.1-1) ...
update-alternatives: using /usr/bin/g++ to provide /usr/bin/c++ (c++) in auto mode
Setting up gnupg (2.2.27-2+deb11u2) ...
Setting up libc-devtools (2.31-13+deb11u3) ...
Setting up libfile-fcntllock-perl (0.22-3+b7) ...
Setting up libalgorithm-diff-perl (1.201-1) ...
Setting up dpkg-dev (1.20.11) ...
Setting up build-essential (12.9) ...
Setting up libalgorithm-diff-xs-perl (0.04-6+b1) ...
Setting up libalgorithm-merge-perl (0.08-3) ...
Processing triggers for libc-bin (2.31-13+deb11u3) ...
root@debian11:/etc/apt/sources.list.d#
```

Install the OpenZFS packages.

```
root@debian11:/etc/apt/sources.list.d# apt install zfs-dkms zfsutils-linux
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  dctrl-tools distro-info-data dkms file libcurl4 libmagic-mgc libmagic1 libnghttp2-14
  libnvpair3linux libpsl5 librtmp1 libssh2-1 libuutil3linux libzfs4linux libzpool5linux
  lsb-release publicsuffix python3-distutils python3-lib2to3 zfs-zed
Suggested packages:
  debtags menu debhelper nfs-kernel-server samba-common-bin zfs-initramfs | zfs-dracut
The following NEW packages will be installed:
  dctrl-tools distro-info-data dkms file libcurl4 libmagic-mgc libmagic1 libnghttp2-14
  libnvpair3linux libpsl5 librtmp1 libssh2-1 libuutil3linux libzfs4linux libzpool5linux
  lsb-release publicsuffix python3-distutils python3-lib2to3 zfs-dkms zfs-zed zfsutils-linux
0 upgraded, 22 newly installed, 0 to remove and 0 not upgraded.
Need to get 5994 kB of archives.
After this operation, 35.3 MB of additional disk space will be used.
Do you want to continue? [Y/n] 
<snip>
Created symlink /etc/systemd/system/zfs-volumes.target.wants/zfs-volume-wait.service → /lib/syste
md/system/zfs-volume-wait.service.
Created symlink /etc/systemd/system/zfs.target.wants/zfs-volumes.target → /lib/systemd/system/zfs
-volumes.target.
Created symlink /etc/systemd/system/multi-user.target.wants/zfs.target → /lib/systemd/system/zfs.
target.
Processing triggers for initramfs-tools (0.140) ...
update-initramfs: Generating /boot/initrd.img-5.10.0-16-arm64
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
Processing triggers for libc-bin (2.31-13+deb11u3) ...
Setting up zfs-zed (2.1.5-1~bpo11+1) ...
Running in chroot, ignoring request.
Created symlink /etc/systemd/system/zed.service → /lib/systemd/system/zfs-zed.service.
Created symlink /etc/systemd/system/zfs.target.wants/zfs-zed.service → /lib/systemd/system/zfs-ze
d.service.
root@debian11:/etc/apt/sources.list.d# 
```

## OpenZFS native encryption 

I'll use OpenZFS native encryption. We can load the encryption keys with  a systemd unit.
The OpenZFS installation doesn't seem to include a unit for this action.

So we need to create one.

This unit file come from the archlinux wiki, but the path is diffirent on a Debian GNU/Linux system

Create ```/etc/systemd/system/zfs-load-key.service```

```
# cd /etc/systemd/system
# vi zfs-load-key.service
```

```
[Unit]
Description=Load encryption keys
DefaultDependencies=no
After=zfs-import.target
Before=zfs-mount.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/sbin/zfs load-key -a
StandardInput=tty-force

[Install]
WantedBy=zfs-mount.service
```

And enable the systemd unit.

```
# systemctl enable zfs-load-key.service
```

# Network setup

## Disable eth0

The default setup of Debian GNU/Linux will use eth0 as a DHCP client.
I'll use the Raspberry PI to run virtual machines, for this reason we need to setup a bridge. 

Goto the  ```/etc/network/interfaces.d``` directory.

```
# cd /etc/network/interfaces.d/
# 
```

Add disable it.

```
root@debian11:/etc/network/interfaces.d# vi eth0-bridge 
```

```
# auto eth0
# iface eth0 inet dhcp
# iface eth0 inet6 auto
```

## Create bridge config

Create a config file for the bridge

```
root@debian11:/etc/network/interfaces.d# vi eth0-bridge 
```

```
auto eth0-bridge
iface eth0 inet manual
# Bridge setup
iface eth0-bridge inet static
    bridge_ports eth0
        address xxx.xxx.xxx.xxx
        broadcast xxx.xxx.xxx.xxx
        netmask xxx.xxx.xxx.xxx
        gateway xxx.xxx.xxx.xxx
```

## Install bridge-utils

To setup a bridge we need the ```bridge-utils``` package.

```
root@rpi4-20220121:/etc/network/interfaces.d#  apt-get install bridge-utils
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following NEW packages will be installed:
  bridge-utils
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 37.6 kB of archives.
After this operation, 116 kB of additional disk space will be used.
Get:1 http://deb.debian.org/debian bullseye/main arm64 bridge-utils arm64 1.7-1 [37.6 kB]
Fetched 37.6 kB in 1s (41.5 kB/s)          
Selecting previously unselected package bridge-utils.
(Reading database ... 53650 files and directories currently installed.)
Preparing to unpack .../bridge-utils_1.7-1_arm64.deb ...
Unpacking bridge-utils (1.7-1) ...
Setting up bridge-utils (1.7-1) ...
root@rpi4-20220121:/etc/network/interfaces.d# ifup br0
interface eth1 does not exist!
RTNETLINK answers: File exists
ifup: failed to bring up br0
root@rpi4-20220121:/etc/network/interfaces.d#
```

# Exit chroot

## Exit

```
# exit
exit
```

## Umount the chroot filesystemsPermalink

Verify the mounted chroot filesystems.

```
# mount | grep -i chroot | awk '{print $3}'
/mnt/chroot
/mnt/chroot/boot/firmware
/mnt/chroot/proc
/mnt/chroot/sys
/mnt/chroot/dev
/mnt/chroot/dev/pts
# 
```

I used the oneliner belong to umount them.

```
# mount | grep -i chroot | awk '{print $3}' | sort -r | xargs -n1 umount 
```

Close the luks volume…

```
# cryptsetup luksClose cryptroot
```

# Resize partitions

I resized the root partition with [gparted](https://gparted.org/) to make it as small as possible.

And create 2 partition dumps with ```dd```.

This partitions were "copied" to the destation partition of each disk that will be used on the Raspberry PI.

After this the partition were resize again with ```gparted```.

# Configurations to reset

## MachineID

It's important to a unique systemid for each system, it is also used to generate a unique MAC address for a bridge for exmaple.

Delete the ```machine-id```

```
root@rpi4-20220121:~# ls -l /etc/machine-id
-r--r--r-- 1 root root 33 Jul 17  2022 /etc/machine-id
root@rpi4-20220121:~# rm -f /etc/machine-id /var/lib/dbus/machine-id
root@rpi4-20220121:~# 
```

And create a new ```machine-id```

```
root@rpi4-20220121:~# dbus-uuidgen --ensure=/etc/machine-id
root@rpi4-20220121:~# dbus-uuidgen --ensure
```
## Network config

### Network bridge config.

For each configuration we need to update the ip in the bridge config

```
/etc/network/interfaces.d/eth0-bridge
```

### initramfs

Update the initramfs to update the Ip address.

```
root@debian11:/etc/network/interfaces.d# nvi /etc/initramfs-tools/initramfs.conf 
root@debian11:/etc/network/interfaces.d# 
```

```
IP=<ip_address>::<gateway_ip_address>:<subnet_mask>:<hostname>
```

# Recreate host keypair's

## OpenSSHD

```
root@debian11:/# cd /etc/ssh
root@debian11:/etc/ssh# 
```

```
root@debian11:/etc/ssh# ls -l
total 608
-rw-r--r-- 1 root root 577771 Mar 13  2021 moduli
-rw-r--r-- 1 root root   1650 Mar 13  2021 ssh_config
drwxr-xr-x 2 root root   4096 Mar 13  2021 ssh_config.d
-rw------- 1 root root    505 Jul 18 18:35 ssh_host_ecdsa_key
-rw-r--r-- 1 root root    175 Jul 18 18:35 ssh_host_ecdsa_key.pub
-rw------- 1 root root    399 Jul 18 18:35 ssh_host_ed25519_key
-rw-r--r-- 1 root root     95 Jul 18 18:35 ssh_host_ed25519_key.pub
-rw------- 1 root root   2602 Jul 18 18:35 ssh_host_rsa_key
-rw-r--r-- 1 root root    567 Jul 18 18:35 ssh_host_rsa_key.pub
-rw-r--r-- 1 root root   3289 Mar 13  2021 sshd_config
drwxr-xr-x 2 root root   4096 Mar 13  2021 sshd_config.d
root@debian11:/etc/ssh# 
```

```
root@debian11:/etc/ssh# rm ssh_host_*
root@debian11:/etc/ssh# 
```

```
root@debian11:/etc/ssh# dpkg-reconfigure openssh-server
Creating SSH2 RSA key; this may take some time ...
3072 SHA256:IQYrb/FmVToatDXslWL8pbH6/kNZp0x4d7hOhipmvgU root@debian11 (RSA)
Creating SSH2 ECDSA key; this may take some time ...
256 SHA256:xEX25qsHfaAXbwkqBNbBQx503UO4bURFFj8eR27A0g8 root@debian11 (ECDSA)
Creating SSH2 ED25519 key; this may take some time ...
256 SHA256:Gg3AZPzO4yJTjhuLS2IKOj/Bzf0xgBjA9s4BqMyvCCs root@debian11 (ED25519)
Running in chroot, ignoring request.
root@debian11:/etc/ssh# 
```

## DropBear (initramfs)

```
root@debian11:/etc/ssh# cd /etc/dropbear-initramfs/
root@debian11:/etc/dropbear-initramfs# ls
authorized_keys  config  dropbear_ecdsa_host_key  dropbear_ed25519_host_key  dropbear_rsa_host_key
root@debian11:/etc/dropbear-initramfs# rm dropbear_*
root@debian11:/etc/dropbear-initramfs# 
```

```
root@debian11:/etc/dropbear-initramfs# dpkg-reconfigure dropbear-initramfs
Generating Dropbear RSA host key.  Please wait.
Generating 2048 bit rsa key, this may take a while...
2048 SHA256:6QqnCJE5Y/vTdvyawq77bXYUlktpB3osao510Bt+pjw /etc/dropbear-initramfs/dropbear_rsa_host_key (RSA)
+---[RSA 2048]----+
|                 |
|         .       |
|      . o +      |
| o   . = @ .     |
|*.    + S +      |
|.+.  + = =       |
|..  O = *        |
| ..+ X.E..       |
|  .+Oo*+=.       |
+----[SHA256]-----+
Generating Dropbear ECDSA host key.  Please wait.
Generating 256 bit ecdsa key, this may take a while...
256 SHA256:GLCF8+mY/d5gopEoL99C1nwQ/Rsp2NRwyteMAtFcnHE /etc/dropbear-initramfs/dropbear_ecdsa_host_key (ECDSA)
+---[ECDSA 256]---+
|    +*o=+oE      |
|    +*=o+=       |
|    .B=oo.o      |
|    o ==+        |
|   o *..So       |
|  o.=.+ .        |
|.o. o...o        |
|.o.. o o.o       |
| oo.o  .. .      |
+----[SHA256]-----+
Generating Dropbear ED25519 host key.  Please wait.
Generating 256 bit ed25519 key, this may take a while...
256 SHA256:Qonq3ccg8hYlawi7FrHujkFeR9vedyyIr+916/dGV2E /etc/dropbear-initramfs/dropbear_ed25519_host_key (ED25519)
+--[ED25519 256]--+
|                 |
|     . .       E |
|..  o.+       . .|
| ooo.=o         .|
|.++.=oo.S       .|
|+oo=.+.+o . .   o|
|o+. + .ooo + + ..|
|+. .   .. o + ...|
|oo     .++  .o..o|
+----[SHA256]-----+
update-initramfs: deferring update (trigger activated)
Dropbear has been added to the initramfs. Don't forget to check
your "ip=" kernel bootparameter to match your desired initramfs
ip configuration.

Processing triggers for initramfs-tools (0.140) ...
update-initramfs: Generating /boot/initrd.img-5.10.0-16-arm64
cryptsetup: WARNING: target 'vda5_crypt' not found in /etc/crypttab
grep: /sys/firmware/devicetree/base/model: No such file or directory
grep: /proc/device-tree/model: No such file or directory
root@debian11:/etc/dropbear-initramfs# 
```


***Have fun!***
