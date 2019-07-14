---
layout: post
title: "Howto use centos cloud images with cloud-init on KVM/libvirtd"
date: 2019-03-03 9:55:55 +0100
comments: true
categories: [ cloud-init, openstack, cloud, centos, debian, linux, ubuntu ] 
excerpt_separator: <!--more-->
---

# Images versus unattended setup

## Old-school
### Unattended setup

In a traditional environment, systems are installed from a CDROM. The configuration is executed by the system administrator through the installer. This soon becomes a borning and unpractical task when we need to set up a lot of systems also it is important  that systems are configured in same - and hopefully correct - way.

In a traditional environment, this can be automated by booting via BOOTP/PXE boot and configured is by a system that "feeds" the installer. Examples are:

* [Solaris Jumpstart](https://en.wikipedia.org/wiki/JumpStart_(Solaris)
* [Redhat Kickstart](https://en.wikipedia.org/wiki/Kickstart_(Linux))
* [DebianInstaller Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
* [Suse Autoyast](https://en.wikipedia.org/wiki/YaST#AutoYaST)
* ...

 <!--more-->
## Cloud & co

### Cloud-init

In a cloud environment, we use images to install systems. The system automation is generally done by [cloud-init](https://cloud-init.io/). Cloud-init was originally developed for Ubuntu GNU/Linux on the Amazon EC2 cloud. It has become the de facto installation configuration tool for most Unix like systems on most cloud environments.

Cloud-init uses a YAML file to configure the system.

### Images

Most GNU/Linux distributions provide images that can be used to provision a new system.
You can find the complete list on the OpenStack website

[https://docs.openstack.org/image-guide/obtain-images.html](https://docs.openstack.org/image-guide/obtain-images.html)

The OpenStack documentation also describes how you can create your own base images in the [OpenStack Virtual Machine Image Guide](https://docs.openstack.org/image-guide/)

# Use a centos cloud image with libvirtd

## Download the cloud image

### Download

Download the latest "GenericCloud" centos 7 cloud image and sha256sum.txt.asc sha256sum.txt from:

[https://cloud.centos.org/centos/7/images/](https://cloud.centos.org/centos/7/images/)

### Verify

You should verify your download - as always against a trusted signing key -

On a centos 7 system, the public gpg is already installed at ```/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7``` 

#### Verify the fingerprint

Execute 

```
staf@centos7 iso]$ gpg --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
pub  4096R/F4A80EB5 2014-06-23 CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>
      Key fingerprint = 6341 AB27 53D7 8A78 A7C2  7BB1 24C6 A8A7 F4A8 0EB5
[staf@centos7 iso]$ gpg --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```

and verify the fingerprint, the fingerprints that are used by centos are listed at:

[https://www.centos.org/keys/](https://www.centos.org/keys/)

#### Import key

Import the pub centos gpg key:

```
[staf@centos7 iso]$ gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
gpg: key F4A80EB5: public key "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
[staf@centos7 iso]$ 
```

List the trusted gpg key:

```
staf@centos7 iso]$ gpg --list-keys
/home/staf/.gnupg/pubring.gpg
-----------------------------
pub   4096R/F4A80EB5 2014-06-23
uid                  CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>

[staf@centos7 iso]$ gpg --list-keys

```

#### Verify the sha256sum file

```
[staf@centos7 iso]$ gpg --verify sha256sum.txt.asc
gpg: Signature made Thu 31 Jan 2019 04:28:30 PM CET using RSA key ID F4A80EB5
gpg: Good signature from "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: 6341 AB27 53D7 8A78 A7C2  7BB1 24C6 A8A7 F4A8 0EB5
[staf@centos7 iso]$ 
```

The key fingerprint must match the one of RPM-GPG-KEY-CentOS-7.

#### Verify the iso file 

```
[staf@centos7 iso]$ xz -d CentOS-7-x86_64-GenericCloud-1901.qcow2.xz
[staf@centos7 iso]$ sha256sum -c sha256sum.txt.asc 2>&1 | grep OK
CentOS-7-x86_64-GenericCloud-1901.qcow2: OK
[staf@centos7 iso]$ 
```

## Image

### info

The image we download is a normal qcow2 image, we can see the image information with ```qemu-info```

```
[root@centos7 iso]# qemu-img info CentOS-7-x86_64-GenericCloud-1901.qcow2
image: CentOS-7-x86_64-GenericCloud-1901.qcow2
file format: qcow2
virtual size: 8.0G (8589934592 bytes)
disk size: 895M
cluster_size: 65536
Format specific information:
    compat: 0.10
[root@centos7 iso]# 
```

### Copy & resize

The default image is small - 8GB - we might be using the image to provision other systems so it better to leave it untouched.

Copy the image to the location where we'll run the virtual system.

```
[root@centos7 iso]# cp -v CentOS-7-x86_64-GenericCloud-1901.qcow2 /var/lib/libvirt/images/tst/tst.qcow2
'CentOS-7-x86_64-GenericCloud-1901.qcow2' -> '/var/lib/libvirt/images/tst/tst.qcow2'
[root@centos7 iso]# 
```

and resize it to the required size:

```
[root@centos7 iso]# cd /var/lib/libvirt/images/tst
[root@centos7 tst]# qemu-img resize tst.qcow2 20G
Image resized.
[root@centos7 tst]# 
```

## cloud-init

We'll create a simple cloud-init configuration file and generate an iso image with ```cloud-localds```. This iso image holds the cloud-init configuration and will be used to setup the system during the bootstrap. 

### Install cloud-utils


<span style="color:red">** It's important to NOT install cloud-init on your KVM host machine. **</span> This creates a cloud-init service that runs during the boot and tries to reconfigure your host. Something that you probably don't want on your KVM hypervisor host.

The cloud-util package has all the tool we need to convert the cloud-init configuration files to an iso image.


```
[root@centos7 tst]# yum install -y cloud-utils
Loaded plugins: fastestmirror, langpacks
Loading mirror speeds from cached hostfile
 * base: centos.cu.be
 * extras: centos.cu.be
 * updates: centos.mirror.ate.info
Resolving Dependencies
--> Running transaction check
---> Package cloud-utils.x86_64 0:0.27-20.el7.centos will be installed
--> Processing Dependency: python-paramiko for package: cloud-utils-0.27-20.el7.centos.x86_64
--> Processing Dependency: euca2ools for package: cloud-utils-0.27-20.el7.centos.x86_64
--> Processing Dependency: cloud-utils-growpart for package: cloud-utils-0.27-20.el7.centos.x86_64
--> Running transaction check
---> Package cloud-utils-growpart.noarch 0:0.29-2.el7 will be installed
---> Package euca2ools.noarch 0:2.1.4-1.el7.centos will be installed
--> Processing Dependency: python-boto >= 2.13.3-1 for package: euca2ools-2.1.4-1.el7.centos.noarch
--> Processing Dependency: m2crypto for package: euca2ools-2.1.4-1.el7.centos.noarch
---> Package python-paramiko.noarch 0:2.1.1-9.el7 will be installed
--> Running transaction check
---> Package m2crypto.x86_64 0:0.21.1-17.el7 will be installed
---> Package python-boto.noarch 0:2.25.0-2.el7.centos will be installed
--> Finished Dependency Resolution

Dependencies Resolved

=======================================================================================
 Package                    Arch         Version                   Repository     Size
=======================================================================================
Installing:
 cloud-utils                x86_64       0.27-20.el7.centos        extras         43 k
Installing for dependencies:
 cloud-utils-growpart       noarch       0.29-2.el7                base           26 k
 euca2ools                  noarch       2.1.4-1.el7.centos        extras        319 k
 m2crypto                   x86_64       0.21.1-17.el7             base          429 k
 python-boto                noarch       2.25.0-2.el7.centos       extras        1.5 M
 python-paramiko            noarch       2.1.1-9.el7               updates       269 k

Transaction Summary
=======================================================================================
Install  1 Package (+5 Dependent packages)

Total download size: 2.5 M
Installed size: 12 M
Downloading packages:
(1/6): cloud-utils-growpart-0.29-2.el7.noarch.rpm               |  26 kB  00:00:01     
(2/6): cloud-utils-0.27-20.el7.centos.x86_64.rpm                |  43 kB  00:00:01     
(3/6): euca2ools-2.1.4-1.el7.centos.noarch.rpm                  | 319 kB  00:00:01     
(4/6): m2crypto-0.21.1-17.el7.x86_64.rpm                        | 429 kB  00:00:01     
(5/6): python-boto-2.25.0-2.el7.centos.noarch.rpm               | 1.5 MB  00:00:02     
(6/6): python-paramiko-2.1.1-9.el7.noarch.rpm                   | 269 kB  00:00:03     
---------------------------------------------------------------------------------------
Total                                                     495 kB/s | 2.5 MB  00:05     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : python-boto-2.25.0-2.el7.centos.noarch                              1/6 
  Installing : python-paramiko-2.1.1-9.el7.noarch                                  2/6 
  Installing : cloud-utils-growpart-0.29-2.el7.noarch                              3/6 
  Installing : m2crypto-0.21.1-17.el7.x86_64                                       4/6 
  Installing : euca2ools-2.1.4-1.el7.centos.noarch                                 5/6 
  Installing : cloud-utils-0.27-20.el7.centos.x86_64                               6/6 
  Verifying  : m2crypto-0.21.1-17.el7.x86_64                                       1/6 
  Verifying  : cloud-utils-growpart-0.29-2.el7.noarch                              2/6 
  Verifying  : python-paramiko-2.1.1-9.el7.noarch                                  3/6 
  Verifying  : python-boto-2.25.0-2.el7.centos.noarch                              4/6 
  Verifying  : euca2ools-2.1.4-1.el7.centos.noarch                                 5/6 
  Verifying  : cloud-utils-0.27-20.el7.centos.x86_64                               6/6 

Installed:
  cloud-utils.x86_64 0:0.27-20.el7.centos                                                                                                                                     

Dependency Installed:
  cloud-utils-growpart.noarch 0:0.29-2.el7      euca2ools.noarch 0:2.1.4-1.el7.centos      m2crypto.x86_64 0:0.21.1-17.el7      python-boto.noarch 0:2.25.0-2.el7.centos     
  python-paramiko.noarch 0:2.1.1-9.el7         

Complete!
[root@centos7 tst]# 
```

### Cloud-init configuration

A complete overview of cloud-init configuration directives is available at [https://cloudinit.readthedocs.io/en/latest/](https://cloudinit.readthedocs.io/en/latest/).

We'll create a cloud-init configuration file to update all the packages - which is always a good idea - and to add a user to the system. 

A cloud-init configuration file has to start with ```#cloud-config```, remember this is YAML so only use spaces...

We'll create a password hash that we'll put into your cloud-init configuration, it's also possible to use a plain-text password in the configuration with ```chpasswd``` or to set the password for the default user. But it's better to use a hash so nobody can see the password. Keep in mind that is still possible to brute-force the password hash.

Some GNU/Linux distributions have the ```mkpasswd``` utility this is not available on centos. The ```mkpasswd``` utility is part of the ```expect``` package and is something else...

I used a python one-liner to generate the SHA512 password hash

```
python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'
```
Execute the one-liner and type in your password: 

```
[staf@centos7 ~]$ python -c 'import crypt,getpass; print(crypt.crypt(getpass.getpass(), crypt.mksalt(crypt.METHOD_SHA512)))'
Password: 
<your hash>
[staf@centos7 ~]$ 
```

Create config.yaml - replace ```<your_user>```, ```<your_hash>```, ```<your_ssh_pub_key>``` -  with your data:

```
#cloud-config
package_upgrade: true
users:
  - name: <your_user>
    groups: wheel
    lock_passwd: false
    passwd: <your_passord_hash>
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - <your_public_ssh_key>
```
And generate the configuration iso image:

```
root@centos7 tst]# cloud-localds config.iso config.yaml
wrote config.iso with filesystem=iso9660 and diskformat=raw
[root@centos7 tst]# 
```

### Create the virtual system

Libvirt has predefined definitions for operating systems. You can query the predefined operation systems with the ```osinfo-query os``` command.

We use centos 7, we use ```osinfo-query os``` to find the correct definition. 

```
[root@centos7 tst]# osinfo-query  os | grep -i centos7
 centos7.0            | CentOS 7.0                                         | 7.0      | http://centos.org/centos/7.0            
[root@centos7 tst]# 
```

Create the virtual system:

```
virt-install \
  --memory 2048 \
  --vcpus 2 \
  --name tst \
  --disk /var/lib/libvirt/images/tst/tst.qcow2,device=disk \
  --disk /var/lib/libvirt/images/tst/config.iso,device=cdrom \
  --os-type Linux \
  --os-variant centos7.0 \
  --virt-type kvm \
  --graphics none \
  --network default \
  --import
```

The default escape key - to get out the console is ^[  ( Ctrl + [ ) 

*** Have fun! *** 

# Links

* [https://wiki.centos.org/Download/Verify](https://wiki.centos.org/Download/Verify)
* [https://www.theurbanpenguin.com/using-cloud-images-in-kvm/](https://www.theurbanpenguin.com/using-cloud-images-in-kvm/)
* [https://docs.openstack.org/image-guide/](https://docs.openstack.org/image-guide/)
* [https://unix.stackexchange.com/questions/52108/how-to-create-sha512-password-hashes-on-command-line#76337](https://unix.stackexchange.com/questions/52108/how-to-create-sha512-password-hashes-on-command-line#76337)
