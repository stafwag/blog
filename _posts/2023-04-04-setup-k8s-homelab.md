---
layout: post
title: "Build a 3-node Kubernetes cluster home lab in 5 minutes (*)"
date: 2023-04-04 18:30:00 +0200
comments: true
categories: ansible k3s kubernetes raspberrypi cloudinit linux  
excerpt_separator: <!--more-->
---

<a href="{{ '/images/ansible-k3s-on-vms/tux-with-pis_s.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible-k3s-on-vms/tux-with-pis_s.jpg'' | remove_first:'/' | absolute_url }}" class="left" width="680" height="534" alt="Tux with pi's" /> </a>

I use the lightweight [Kubernetes](https://kubernetes.io/) [K3s](https://k3s.io/) on a 3-node [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) cluster. I wrote a few blog posts on how the Raspberry Pi's are installed.

I run K3s on virtual machines.

Why virtual machines?

Virtual makes it easier to redeploy or to bring a system down and up if your want to test something.

Another reason is that I also run [FreeBSD](https://www.freebsd.org/) virtual machines on the Raspberry Pis.

I use [Debian](https://www.debian.org/) GNU/Linux as the Operating system with [KVM](https://www.linux-kvm.org/)/[libvirt](https://libvirt.org/) as
the hypervisor.

I use [Ansible](https://www.ansible.com/) to set up the cluster in an automated way.
Got finality the time to clean up the code a bit and release it on Github: 
[https://github.com/stafwag/ansible-k3s-on-vms](https://github.com/stafwag/ansible-k3s-on-vms)

<!--more-->
The code can also - and will by default - be used on x86 systems.

The playbook is a wrapper around the roles:

* [https://github.com/stafwag/ansible-role-delegated_vm_install](https://github.com/stafwag/ansible-role-delegated_vm_install)

To set up the virtual machines.

* [https://github.com/PyratLabs/ansible-role-k3s](https://github.com/PyratLabs/ansible-role-k3s)

To install and configure K3s on the virtual machines.

* [https://github.com/stafwag/ansible-role-libvirt](https://github.com/stafwag/ansible-role-libvirt)

To enable libvirt on the ```vm_kvm_host```.

The sample inventory will install the virtual machines on localhost. It's possible to install the virtual machine on multiple lbvirt/KVM hypervisors.

This should enable you setup the virtual machine with k3s in ... 5 minutes

(*) if everything goes well the first time :-)

***Have fun***
