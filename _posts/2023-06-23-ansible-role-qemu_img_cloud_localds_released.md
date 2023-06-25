---
layout: post
title: "Ansible roles: qemu_img 2.2.0 & cloud_localds 2.1.1 Released"
date: 2023-06-25 05:32:00 +0200
comments: true
categories: [ ansible ]
excerpt_separator: <!--more-->
---

Time again to make some releases of 2 the ansible roles I maintain.

This time none of the commits are created by me :-)

Thanks to [https://github.com/fazlerabbi37](https://github.com/fazlerabbi37) for your contributions!

***Have fun!***

# qemu_img 2.2.0 

**stafwag.qemu_img 2.2.0** is available at: [https://github.com/stafwag/ansible-role-qemu_img](https://github.com/stafwag/ansible-role-qemu_img)

<a href="{{ '/images/ansible-role-qemu_img/playbook2.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible-role-qemu_img/playbook2.png' | remove_first:'/' | absolute_url }}" class="right" width="680" height="385" alt="playbook" /> </a>
## Changelog

* **remote_src directive**
    * remote_src added this allows copying the source image from a remote host. Thanks to [https://github.com/fazlerabbi37](https://github.com/fazlerabbi37)

<!--more-->

# cloud_localds 2.1.1

* **cloud_localds 2.1.1** is available at: [https://github.com/stafwag/ansible-role-cloud_localds](https://github.com/stafwag/ansible-role-cloud_localds)

<a href="{{ '/images/ansible-role-cloud_localds/playbook2.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/ansible-role-cloud_localds/playbook2.png' | remove_first:'/' | absolute_url }}" class="left" width="680" height="385" alt="playbook" /> </a>
## Changelog

* **network config templating**
    * bugfix. This release implements network config templating. The previous release copied the template instead of
      using templating. Thanks to [https://github.com/fazlerabbi37](https://github.com/fazlerabbi37)
