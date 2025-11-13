---
layout: post
title: "ansible-k3s-on-vms updated to Debian 13 (Trixie)"
date: 2025-11-13 06:30:00 +0200
comments: true
categories: ansible debian k3s kubernetes cloudinit linux
excerpt_separator: <!--more-->
---
I use the lightweight [Kubernetes](https://kubernetes.io/) [K3s](https://k3s.io/) on a 3-node [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) cluster.

And created a few ansible roles to provision the virtual machines with cloud image with cloud-init and deploy k3s on it.

I updated the roles below to be compatible with the latest Debian release: Debian 13 Trixie.

With this release comes a new movie ;-)

[![Deploy k3s on ips](https://stafwag.github.io/blog/images/ansible-k3s-on-vms/ansible-k3s-pi-deployment_1440.jpg)](https://www.youtube.com/watch?v=4K6D_wzETpQ "Deploy k3s on ips")

<!--more-->

The latest version 1.3.0 is available at: [https://github.com/stafwag/ansible-k3s-on-vms](https://github.com/stafwag/ansible-k3s-on-vms)

<br />

***Have fun!***

# delegated_vm_install 2.1.1

stafwag.delegated_vm_install  is available at:
[https://github.com/stafwag/ansible-role-delegated_vm_install](https://github.com/stafwag/ansible-role-delegated_vm_install)

### 2.1.1
#### Changelog

* Added stafwag.libvirt to requirements
* Added stafwag.package_update to requirements

### 2.1.0
#### Changelog

* Added Debian 13 template
* Added Debian 13 single node examples
* Updated 3 node example to Debian 13

<br />

# virt_install_vm 1.2.0

stafwag.virt_install_vm 1.1.0 is available at: [https://github.com/stafwag/ansible-role-virt_install_vm](https://github.com/stafwag/ansible-role-virt_install_vm)

### 1.2.0
#### Changelog

* Added Debian 13 template and example
* Set graphics to VNC

<br />

# qemu_img

stafwag.qemu_img 2.3.3 available at: [https://github.com/stafwag/ansible-role-qemu_img](https://github.com/stafwag/ansible-role-qemu_img)

### 1.2.0
#### Changelog

* Corrected ansible lint errors
*  Updated convert to array
   * Updated conversion to array to be compatible with the latest ansible versions
   * Added debugging
