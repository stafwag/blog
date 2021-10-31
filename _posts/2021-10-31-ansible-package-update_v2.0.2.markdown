---
layout: post
title: "Ansible role: package_update v2.0.2"
date: 2021-10-31 08:33:01 +0100
comments: true
categories: [ ansible, linux, bsd, freebsd, openbsd, netbsd ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/ansible-role-pkg_update/playbook.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible-role-pkg_update/playbook.png' | remove_first:'/' | absolute_url }}" class="right" width="680" height="385" alt="ansible-role-pkg_update" /> </a>

Keeping your software up-to-date is an important task in System Administration. Not only for security reasons but also to roll out bug fixes to your systems.

As always we should try to automate this process as much as possible.

[Ansible](https://www.ansible.com/) has a [package module](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_module.html) to install packages in a generic way. It supports most Un\*x platforms (GNU/Linux, BSD, ...). But it doesn't allow you to update all packages.

For this reason, I created an [Ansible role: package update](https://github.com/stafwag/ansible-role-package_update).

Package update enables you to update all packages on most Linux distributions and the [BSD operating systems](https://www.bsd.org/).  It can also update the running [jails](https://docs.freebsd.org/en/books/handbook/jails/) on [FreeBSD](https://www.freebsd.org/).

Version 2.0.2 is available at

* Github:  [https://github.com/stafwag/ansible-role-package_update](https://github.com/stafwag/ansible-role-package_update).
* Ansible galaxy: [https://galaxy.ansible.com/stafwag/package_update](https://galaxy.ansible.com/stafwag/package_update)

# Version 2.0.2:

## Changelog:

* Always update the apt cache on Debian based distributions.

***Have fun!***

<!--more-->
# Ansible Role: package_update

An ansible role to update all packages (multiplatform)

## Requirements

### Supported platforms

* Archlinux
* Debian
* FreeBSD
* NetBSD
* OpenBSD
* RedHat
* Suse
* Kali GNU/Linux

## Role Variables
### OS related variables

The following variables are set by the role.

* **freebsd_running_jails**: List with the running FreeBSD jails.

### Playbook related variables

* **package_update**: "name space"
  * **freebsd**: "freebsd config" 
    * **get_running_jails**: no | yes (default) set the freebsd_running_jails variable.
    * **host**: no | yes (default) update the host system
    * **jails**: Array of jails to update, **freebsd_running_jails** by default.
    

## Dependencies

None

## Example Playbooks

### Upgrade

```
---
- name: update packages
  hosts: all
  become: true
  roles:
    - stafwag.package_update
```

### Update only the FreeBSD host systems. 

```
---
- name: update packages
  hosts: all
  become: true
  roles:
    - role: stafwag.package_update
      vars:
        package_update:
          freebsd:
            get_running_jails: no
            jails: []
```

### Update only the running jails on FreeBSD systems.

```
---
- name: update packages
  hosts: all
  become: true
  roles:
    - role: stafwag.package_update
      vars:
        package_update:
          freebsd:
            host: no
```

### Update a jail on a  FreeBSD system.

```
---
- name: update packages
  hosts: rataplan
  become: true
  roles:
    - role: stafwag.package_update
      vars:
        package_update:
          freebsd:
            host: no
            jails:
              - stafmail

```


## License

MIT/BSD

## Author Information

Created by Staf Wagemakers, email: staf@wagemakers.be, website: http://www.wagemakers.be
