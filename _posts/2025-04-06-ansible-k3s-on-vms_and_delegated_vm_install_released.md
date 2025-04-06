---
layout: post
title: "Ansible k3s on vms 1.2.0  and delegated_vm_install 2.0.3 released"
date: 2025-04-06 18:08 +0100
comments: true
categories: [ "freebsd", "linux", "libvirt", "kvm", "ansible", "cloudinit" ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/cloud-init/cloud-init-primary.svg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/cloud-init/cloud-init-primary.svg' | remove_first:'/' | absolute_url }}" class="right" width="600" height="121" alt="cloud-init" /> </a>

I prepared a few update releases of some ansible roles related to provisoin virtual machines with [libvirt](https://libvirt.org/) over the last weeks.

Mainly clean up releases and makes sure that everything works on 
different GNU/Linux distributions out of the box.

One "big" change is the removal of the dependency on the ```cloud-localds```
utility to provision virtual machines with [cloud-init](https://cloud-init.io/). This enables to us usage of the roles on Linux distributions that don't provide this utility.

---
# Ansible-k3s-on-vms v1.2.0

*An Ansible playbook to deploy virtual machines and deploy K3s.*

[https://github.com/stafwag/ansible-k3s-on-vms](https://github.com/stafwag/ansible-k3s-on-vms)

<!--more-->

## ChangeLog

### Added community.libvirt to requirements.yml

* Added community.libvirt to requirements.yml
* Added required Suse packages installation
* Documentation update
* This release removes the dependency on the cloud-locals utility. On the distributes that don't provide the cloud-localds utility GNU xorriso is used.

---
# stafwag.delegated_vm_install v2.0.3

*An Ansible role to install a virtual machine with ```virt-install``` and ```cloud-init``` (Delegated).*

[https://github.com/stafwag/ansible-role-delegated_vm_install](https://github.com/stafwag/ansible-role-delegated_vm_install)

## ChangeLog

### Gather facts on kvm hosts only once

* Gather facts on kvm hosts only once
* Corrected ansible-lint errors
* Remove the cloud-localds requirement in README 

---
# stafwag.virt_install_vm v1.1.1

*An Ansible role to install a libvirt virtual machine with virt-install and cloud-init. It “designed” to be flexible.*

[https://github.com/stafwag/ansible-role-virt_install_vm](https://github.com/stafwag/ansible-role-virt_install_vm)

## ChangeLog

### CleanUp Release

* Corrected ansible-lint errors
* Updated documentation
* Avoid ansible error during check vm status check

---
# stafwag.libvirt v2.0.0 

*An ansible role to install libvirt/KVM packages and enable the libvirtd service.*

[https://github.com/stafwag/ansible-role-libvirt](https://github.com/stafwag/ansible-role-libvirt)

## ChangeLog

### Use general vars instead of tasks

* Reorganized the role to use vars and package install install the packages
* This version works from the Ansible version that is included in Ubuntu 24.x
* Corrected ansible-lint errors

---
# stafwag.cloud_localds v3.0.2

*An ansible role to create cloud-init config disk images.*

[https://github.com/stafwag/ansible-role-cloud_localds](https://github.com/stafwag/ansible-role-cloud_localds)

## ChangeLog

### Execute installation tasks only once

* Added run_one: true to only execute the installation tasks only once.
* Move "name: Set OS related variables" to main, to have the provider settings when the install phase isn't executed e.g. With --skip-tags install.
* Added apply tags install to support --tags install 

---
# stafwag.qemu_img v2.3.2

*An ansible role create qemu images.*

[https://github.com/stafwag/ansible-role-qemu_img](https://github.com/stafwag/ansible-role-qemu_img)

## ChangeLog

### Enable run_once on installation tasks

* Execute installation tasks only once to allow parallel execution of roles on the same host e.g. With delegate_to

***Have fun!***
