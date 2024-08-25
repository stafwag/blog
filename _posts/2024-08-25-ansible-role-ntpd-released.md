---
layout: post
title: "New release Ansible role stafwag.ntpd, and clean up Ansible roles"
date: 2024-08-25 08:01:00 +0200
comments: true
categories: ansible linux ntpd chrony systemd linux freebsd openbsd netbsd
excerpt_separator: <!--more-->
---

I made some time to give some love to my own projects and spent some time rewriting the Ansible role [stafwag.ntpd](https://galaxy.ansible.com/ui/standalone/roles/stafwag/ntpd/) and cleaning up some other Ansible roles.

There is some work ongoing for some other Ansible roles/projects,
but this might be a topic for some other blog post(s) ;-)

<a href="{{ '/images/ansible/ansible-collaborative-hero-img.svg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible/ansible-collaborative-hero-img.svg' | remove_first:'/' | absolute_url }}" class="left" width="458" height="274" alt="freebsd with smartcard" /> </a>

# stafwag.ntpd

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to configure ntpd/chrony/systemd-timesyncd.*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

This might be controversial, but I decided to add support for [chrony](https://chrony-project.org/) and [systemd-timesyncd](https://www.freedesktop.org/software/systemd/man/latest/systemd-timesyncd.service.html).  Ntpd is still supported and the default on the BSDs ( [FreeBSD](https://www.freebsd.org), [NetBSD](https://www.netbsd.org), [OpenBSD](https://www.openbsd.org)).

It's possible to switch from the ntp implementation by using the ```ntpd.provider``` directive.

The Ansible role stafwag.ntpd v2.0.0 is available at:

* [https://github.com/stafwag/ansible-role-ntpd](https://github.com/stafwag/ansible-role-ntpd)
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/ntpd/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/ntpd/)

## Release notes
### V2.0.0

* **Added support for chrony and systemd-timesyncd on GNU/Linux**
    * systemd-timesynced is the default on Debian GNU/Linux 12+ and Archlinux
    * ntpd is the default on all operating systems (BSDs, Solaris) and Debian GNU/Linux 10 and 11
    * chrony is the default on all other GNU/Linux distributes
    * For ntpd hash as the input for the role.
    * Updated README
    * CleanUp

<!--more-->
<hr style="border-top: 1px solid black; padding-top: 10px; padding-bottom: 30px;" />

# stafwag.ntpdate

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to activate the ntpdate service on FreeBSD and NetBSD.*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

The ```ntpdate``` service is used on FreeBSD and NetBSD to sync the time during the system boot-up. On most Linux distributions this is handled by ```chronyd``` or ```systemd-timesyncd``` now. The OpenBSD ntpd implementation [OpenNTPD](https://www.openntpd.org/) also has support to sync the time during the system boot-up.

The role is available at:

* [https://github.com/stafwag/ansible-role-ntpdate](https://github.com/stafwag/ansible-role-ntpdate)
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/ntpdate/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/ntpdate/)

## Release notes
### V1.0.0
* **Initial release on Ansible Galaxy**
    * Added support for NetBSD

<hr style="border-top: 1px solid black; padding-top: 10px; padding-bottom: 30px;" />

# stafwag.libvirt

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to install libvirt/KVM packages and enable the libvirtd service.*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

The role is available at:

* [https://github.com/stafwag/ansible-role-libvirt](https://github.com/stafwag/ansible-role-libvirt) 
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/libvirt/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/libvirt/)

## Release notes
### V1.1.3
* **Force ```bash``` for shell execution on Ubuntu.**
    * Force ```bash``` for shell execution on Ubuntu. As the default ```dash``` shell doesn't support ```pipefail```.

### V1.1.2
* **CleanUp**
    * Corrected ansible-lint errors
    * Removed install task "install/{{ ansible_os_family | replace ("/","") | replace(" ","") }}.yml'";
        * This was introduced to support Kali Linux, Kali Linux is reported as "Debian" now.
        * It isn't used in this role
    * Removed invalid CentOS-8.yml softlink
        * Removed invalid soft link, Centos 8 should be catched by
        * RedHat-yum.yml

<hr style="border-top: 1px solid black; padding-top: 10px; padding-bottom: 20px;" />

# stafwag.cloud_localds

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to create cloud-init config disk images. This role is a wrapper around the cloud-localds command.*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

It's still planned to add support for distributions that don't have ```cloud-localds``` as part of their official package repositories like RedHat 8+.

See the GitHub issue: [https://github.com/stafwag/ansible-role-cloud_localds/issues/7](https://github.com/stafwag/ansible-role-cloud_localds/issues/7)

The role is available at:

* [https://github.com/stafwag/ansible-role-cloud_localds/](https://github.com/stafwag/ansible-role-cloud_localds/)
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/cloud_localds/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/cloud_localds/)

## Release notes
### V2.1.3
* **CleanUp**
    * Switched to vars and package to install the required packages
    * Corrected ansible-lint errors
    * Added more examples

<hr style="border-top: 1px solid black; padding-top: 10px; padding-bottom: 30px;" />

# stafwag.qemu_img

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to create QEMU disk images.*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

The role is available at:

* [https://github.com/stafwag/ansible-role-qemu_img](https://github.com/stafwag/ansible-role-qemu_img)
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/qemu_img/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/qemu_img/)

## Release notes
### V2.3.0
* **CleanUp Release**
    * Added doc/examples
    * Updated meta data
    * Switched to vars and package to install the required packages
    * Corrected ansible-lint errors

<hr style="border-top: 1px solid black; padding-top: 10px; padding-bottom: 30px;" />

# stafwag.virt_install_import

<hr style="background-color: #eee; border-top: 1px solid #ddd;" />
*An ansible role to import virtual machine with the virt-install import command*
<hr style="background-color: #eee; border-top: 1px solid #ddd;" />

The role is available at:

* [https://github.com/stafwag/ansible-role-virt_install_import](https://github.com/stafwag/ansible-role-virt_install_import)
* [https://galaxy.ansible.com/ui/standalone/roles/stafwag/virt_install_import/](https://galaxy.ansible.com/ui/standalone/roles/stafwag/virt_install_import/)

## Release notes

* **Use var and package to install pkgs**
  * v1.2.1 wasn't merged correctly. The release should fix it...
  *  Switched to var and package to install the required packages
  *  Updated meta data
  *  Updated documentation and include examples
  *  Corrected ansible-lint errors

<br />
<br />
***Have fun!***
