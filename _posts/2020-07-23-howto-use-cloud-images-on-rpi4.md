---
layout: post
title: "Howto use cloud images on the Raspberry PI 4"
date: 2020-07-23 06:45:50 +0200
comments: true
categories: [ rpi4, manjaro, raspberrypi, cloud-init, cloud ] 
excerpt_separator: <!--more-->
---

I got a Raspberry PI 4 to play with and [installed Manjaro GNU/Linux on it](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/).

I wanted to verify how usable the latest PI is for desktop and home server usage.

- For desktop usage, it is "usable".

  For video playback in the browser, I recommend disabling 60fps ([https://greasyfork.org/en/scripts/23329-disable-youtube-60-fps-force-30-fps](https://greasyfork.org/en/scripts/23329-disable-youtube-60-fps-force-30-fps)) and keep the video playback to 720p. Please note that if you want to use it for Netflix you will need  [Widevine](https://en.wikipedia.org/wiki/Widevine) for the [DRM](https://en.wikipedia.org/wiki/Digital_rights_management) content. As far as I know, there isn't an [ARM64](https://en.wikipedia.org/wiki/AArch64) version available. An ARM32 version exists but I didn't try (yet).

- For (home) server usage [ARM64 or AArch64](https://en.wikipedia.org/wiki/AArch64) is getting more usable.

  Cloud providers are also offering ARM64 based systems. A container-based workload - like [Docker](https://en.wikipedia.org/wiki/Docker_(software)), [LXC](https://en.wikipedia.org/wiki/LXC), [FreeBSD jails](https://en.wikipedia.org/wiki/FreeBSD_jail) etc - is probably better suited for a small device like the Raspberry PI. Virtual machines are still important for server usage so let see how the PI4 can handle it. 

Most GNU/Linux distributions [RedHat]([https://www.redhat.com), [Centos](https://www.centos.org/), [Ubuntu](https://ubuntu.com/), [Debian](https://www.debian.org/) are offering cloud images for ARM64. To configure these images you'll need [cloud-init](https://cloud-init.io/).

I already wrote a blog post on howto cloud-init for KVM/libvirt on GNU/Linux: [Howto use centos cloud images with cloud-init on KVM/libvirtd](https://stafwag.github.io/blog/blog/2019/03/03/howto-use-centos-cloud-images-with-cloud-init/). Let see if we can get it working on ARM64.
<!--more-->

If you want to use an USB storage device (even with a SSD) I recommend using Y-USB powered cable or a powered storage enclosure. 

# ZFS

I always use [OpenZFS](https://en.wikipedia.org/wiki/OpenZFS) for my important data. On Archlinux, ZFS is available at the [AUR](https://aur.archlinux.org/) and [https://www.archzfs.com](https://www.archzfs.com]) The more or less default ZFS AUR packages - [zfs-dkms](https://aur.archlinux.org/packages/zfs-dkms/) and [zfs-utils](https://aur.archlinux.org/packages/zfs-utils/) - have a dependency  to x86_64 architecture. Lucky somebody already created packages that work fine on any platform - [zfs-dkms-any](https://aur.archlinux.org/packages/zfs-dkms-any/) & [zfs-utils-any](https://aur.archlinux.org/packages/zfs-utils-any/) -.

## Install yay

[Yay](https://github.com/Jguer/yay) is a nice tool to install AUR packages automatically. Let's make our life easier and install it.

Install the base development packages.

```
[staf@minerva ~]$ sudo pacman -Sy base-devel
```

Install yay.

Create a git directory.

```
[staf@minerva ~]$ mkdir github
[staf@minerva ~]$ cd github/
[staf@minerva github]$ 
```

Clone the git repo.

```
[staf@minerva github]$ git clone https://aur.archlinux.org/yay.git
```

Build and install the package.

```
[staf@minerva github]$ cd yay
[staf@minerva yay]$ makepkg -si
```

## Install OpenZFS

Install the zfs-dkms-any zfs-utils-any packages.

```
[staf@minerva ~]$ yay -S zfs-dkms-any zfs-utils-any
```

# Install libvirt/QEMU 

On an x86_64 we'd start with verifying that the CPU has virtualization enabled. By verifying ```/proc/cpuinfo``` or ```lscpu```, but I don't know if an ARM64 CPU has a flag for it. ```lscpu``` doesn't report virtualization support on the Raspberry PI.

Install the required packages.

```
[root@minerva ~]# pacman -S libvirt qemu lxc ebtables dnsmasq bridge-utils openbsd-netcat dmidecode virt-manager
```

Start and enable the libvirtd systemd service.

```
[root@minerva ~]# systemctl start libvirtd
[root@minerva ~]# systemctl enable libvirtd
```

Execute ```virt-host-validate``` to ensure that the virtualization works correctly.

```
[staf@minerva ~]$ virt-host-validate
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
  QEMU: Checking for cgroup 'cpu' controller support                         : PASS
  QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
  QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
  QEMU: Checking for cgroup 'memory' controller support                      : PASS
  QEMU: Checking for cgroup 'devices' controller support                     : PASS
  QEMU: Checking for cgroup 'blkio' controller support                       : PASS
WARN (Unknown if this platform has IOMMU support)
   LXC: Checking for Linux >= 2.6.26                                         : PASS
   LXC: Checking for namespace ipc                                           : PASS
   LXC: Checking for namespace mnt                                           : PASS
   LXC: Checking for namespace pid                                           : PASS
   LXC: Checking for namespace uts                                           : PASS
   LXC: Checking for namespace net                                           : PASS
   LXC: Checking for namespace user                                          : PASS
   LXC: Checking for cgroup 'cpu' controller support                         : PASS
   LXC: Checking for cgroup 'cpuacct' controller support                     : PASS
   LXC: Checking for cgroup 'cpuset' controller support                      : PASS
   LXC: Checking for cgroup 'memory' controller support                      : PASS
   LXC: Checking for cgroup 'devices' controller support                     : PASS
   LXC: Checking for cgroup 'freezer' controller support                     : PASS
   LXC: Checking for cgroup 'blkio' controller support                       : PASS
   LXC: Checking if device /sys/fs/fuse/connections exists                   : PASS
[staf@minerva ~]$ 
```

## Install UEFI aarch64

As a first, test I started virt-manager to install the Debian ARM64 installation iso but virt-manager reported that UEFI was missing.
[Tianocore](https://www.tianocore.org/) is an opensource implementation of the UEFI firmware that can be used with libvirtd.

It is not available in the standard Manjaro repo available. But there is an AUR package is available.

```
[staf@minerva ~]$ yay -Ss tianocore 
aur/edk2-avmf 20200201-1 (+2 0.42) (Installed)
    QEMU ARM/AARCH64 Virtual Machine Firmware (Tianocore UEFI firmware).
aur/ovmf-git 1:r25361.514c55c185-1 (+30 0.00) 
    Tianocore UEFI firmware for qemu.
aur/uefi-shell-git 26946.edk2.stable201903.1209.gf8dd7c7018-1 (+49 0.08) 
    UEFI Shell v2 - from Tianocore EDK2 - GIT Version
[staf@minerva ~]$ yay -Ss edk2-avmf
```

After the installation the test install with the Debian ARM64 iso image went fine just like on an x86_64 system.

# Cloud image

There are cloud images available for most popular GNU/Linux distributions for the ARM64 architecture. I'll use Ubuntu in the example below.

## Cloud-init

Cloud-init isn't available on Marjano, the cloud-utils package is available. It isn't required to have cloud-init on the libvirt 
host to install a cloud image. But it's useful to have it to check the syntax etc. You can do this on another system or try to 
install from source (see links below). 

Install the cloud-utils package.

```
[staf@minerva ~]$ pkgfile cloud-localds
[staf@minerva ~]$ sudo pacman -S cloud-utils
```

## Download the cloud image

### Download 

Download the Ubuntu cloud image from [https://cloud-images.ubuntu.com/](https://cloud-images.ubuntu.com/) and verify your download.

### Verify

#### Verify the checksum file

You can verify the list of GPG keys used by Ubuntu at [https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu](https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu).

```
staf@minerva ubuntu]$ gpg --keyid-format long  --verify SHA256SUMS.gpg SHA256SUMS
gpg: Signature made Tue 14 Jul 2020 23:29:05 CEST
gpg:                using RSA key 1A5D6C4C7DB87C81
gpg: Can't check signature: No public key
```

Import the GPG public key.

```
[staf@minerva ubuntu]$ gpg --keyid-format long --keyserver hkp://keyserver.ubuntu.com --recv-keys 1A5D6C4C7DB87C81
gpg: key 1A5D6C4C7DB87C81: public key "UEC Image Automatic Signing Key <cdimage@ubuntu.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1
[staf@minerva ubuntu]$ 
```

And verify again.

```
[staf@minerva ubuntu]$ gpg --keyid-format long  --verify SHA256SUMS.gpg SHA256SUMS
gpg: Signature made Tue 14 Jul 2020 23:29:05 CEST
gpg:                using RSA key 1A5D6C4C7DB87C81
gpg: Good signature from "UEC Image Automatic Signing Key <cdimage@ubuntu.com>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: D2EB 4462 6FDD C30B 513D  5BB7 1A5D 6C4C 7DB8 7C81
[staf@minerva ubuntu]$ 
```

The "Primary key fingerprint" has to match the fingerprint on [https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu](https://wiki.ubuntu.com/SecurityTeam/FAQ#GPG_Keys_used_by_Ubuntu).

### Verify the image

```
[staf@minerva ubuntu]$ sha256sum -c SHA256SUMS 2>&1 | grep OK
focal-server-cloudimg-arm64.img: OK
[staf@minerva ubuntu]$ 
```

# Image

## Info

The image is a normal qcow2 image file.

```
[staf@minerva ubuntu]$ file focal-server-cloudimg-arm64.img 
focal-server-cloudimg-arm64.img: QEMU QCOW2 Image (v2), 2361393152 bytes
[staf@minerva ubuntu]$ 
```

Use ```qemu-info``` to get more information about the image.

```
[staf@minerva ubuntu]$ qemu-img info focal-server-cloudimg-arm64.img 
image: focal-server-cloudimg-arm64.img
file format: qcow2
virtual size: 2.2 GiB (2361393152 bytes)
disk size: 493 MiB
cluster_size: 65536
Format specific information:
    compat: 0.10
    refcount bits: 16
[staf@minerva ubuntu]$ 
```

# Copy & resize

Copy the image to the final location.

```
[root@minerva ubuntu]# cp -v focal-server-cloudimg-arm64.img  /var/lib/libvirt/images/ubuntu/tst.qcow2
'focal-server-cloudimg-arm64.img' -> '/var/lib/libvirt/images/ubuntu/tst.qcow2'
[root@minerva ubuntu]# 
```

and resize the image.

```
[root@minerva ubuntu]# cd /var/lib/libvirt/images/ubuntu/
[root@minerva ubuntu]# qemu-img resize tst.qcow2 20G
```

# Cloud-init

## Upgrade and default user

A complete overview of cloud-init configuration directives is available at https://cloudinit.readthedocs.io/en/latest/.

We’ll create a cloud-init configuration file to update all the packages - which is always a good idea - and add a default user to the system.

A cloud-init configuration file has to start with #cloud-config, remember this is YAML so only use spaces…

We’ll create a password hash that we’ll put into your cloud-init configuration, it’s also possible to use a plain-text password in the configuration with chpasswd or to set the password for the default user. But it’s better to use a hash so nobody can see the password. Keep in mind that is still possible to brute-force the password hash.

Some (Debian based) GNU/Linux distributions have the mkpasswd utility this is not available on Manjaro. The mkpasswd utility part of the expect package is something else…

I used a python one-liner to generate the SHA512 password hash.

```
python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'
```

Execute the one-liner and type in your password.

Create config.yaml - replace ```<your_user>```, ```<your_hash>```, ```<your_ssh_pub_key>``` -  with your data:

```
#cloud-config
system_info:
  package_upgrade: true
  default_user:
    name: <your_user>
    groups: wheel
    lock_passwd: false
    passwd: <your_hash>
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh_authorized_keys:
      - ssh-rsa <your_ssh_pub_key>
```

You can validate the cloud-init file with ```cloud-init devel schema```, Manjaro doesn't have the cloud-init package. You can compile it from source or verify it a system that has cloud-init installed.

```
[root@minerva ubuntu]# cloud-init devel schema --config-file config.yaml
Valid cloud-config file config.yaml
[root@minerva ubuntu]# 
```

## network

Create a network config file.

```
version: 2
ethernets:
  enp1s0:
     addresses: [ 192.168.122.31/24 ]
     gateway4: 192.168.122.1
     nameservers:
       addresses: [ 192.168.122.1 ]
```

## create the config.iso

```
[root@minerva ubuntu]# cloud-localds config.iso config.yaml --network-config net_config.yaml 
[root@minerva ubuntu]# 
```

# Create the virtual system

Libvirt has predefined definitions for operating systems. You can query the predefined operation systems with the osinfo-query os command.

We use Ubuntu 20.04, we use osinfo-query os to find the correct definition.

```
[root@minerva ubuntu]# osinfo-query os | grep -i ubuntu | grep 20
 ubuntu20.04          | Ubuntu 20.04                                       | 20.04    | http://ubuntu.com/ubuntu/20.04          
[root@minerva ubuntu]# 
```

Create the virtual machine.

```
[root@minerva ubuntu]# cat install.sh 
virt-install \
  --memory 2048 \
  --vcpus 1 \
  --name tst \
  --disk /var/lib/libvirt/images/ubuntu/tst.qcow2,device=disk \
  --disk /var/lib/libvirt/images/ubuntu/config.iso,device=cdrom \
  --os-type Linux \
  --os-variant ubuntu20.04 \
  --virt-type kvm \
  --graphics none \
  --network network:default \
  --import
[root@minerva ubuntu]# 
```

The default escape key - to get out the console is ^] ( Ctrl + ] )

***Have fun!***


# Links

* [https://stackoverflow.com/questions/44444279/cloud-init-how-to-install-it-from-the-source-code](https://stackoverflow.com/questions/44444279/cloud-init-how-to-install-it-from-the-source-code)
* [https://www.ibm.com/support/knowledgecenter/en/SSB27U_6.4.0/com.ibm.zvm.v640.hcpo5/instsubuntu.htm](https://www.ibm.com/support/knowledgecenter/en/SSB27U_6.4.0/com.ibm.zvm.v640.hcpo5/instsubuntu.htm)
* [https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html](https://xnand.netlify.app/2019/10/03/armv8-qemu-efi-aarch64.html)
* [https://help.ubuntu.com/community/VerifyIsoHowto](https://help.ubuntu.com/community/VerifyIsoHowto)
* [https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/](https://fabianlee.org/2020/02/23/kvm-testing-cloud-init-locally-using-kvm-for-an-ubuntu-cloud-image/)
