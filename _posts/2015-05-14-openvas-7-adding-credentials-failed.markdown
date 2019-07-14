---
layout: post
title: "Openvas 7: adding credentials failed"
date: 2015-05-14 16:56
comments: true
categories: [ centos, kvm, security, openvas ]
---

I'm creating a new <a href="http://www.openvas.org">openvas 7</a> system running <a href="http://www.centos.org">centos 7</a> as a <a href="http://www.linux-kvm.org/">KVM</a> instance.

<a href="http://www.openvas.org/install-packages-v7.html">The installation</a> went fine but it was impossible to create new credentials.

I had a similar issue with my openvas 6 installation, this was resolved by creating the  ```/etc/openvas/gnupg``` directory and creating the key  ```openvasmd --create-credentials-encryption-key```

But on my openvas 7 installation a creation of the encryption key was slooooow.
As always Good Randomness is important for creating keys. So I decided to install haveged to get more randomness and hopefully this would speed up key creation.


```
[root@localhost ~]# yum install haveged

Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * atomic: www6.atomicorp.com
 * base: centos.cu.be
 * extras: centos.cu.be
 * updates: centos.cu.be
Package haveged-1.9.1-2.el7.art.x86_64 already installed and latest version
Nothing to do
[root@localhost ~]# 
[root@localhost ~]# systemct list-unit-files --type=service | grep haveged
-bash: systemct: command not found
[root@localhost ~]# systemctl list-unit-files --type=service | grep haveged
haveged.service                             disabled
[root@localhost ~]# systemctl enable haveged
ln -s '/usr/lib/systemd/system/haveged.service' '/etc/systemd/system/multi-user.target.wants/haveged.service'
[root@localhost ~]# systemctl start haveged
[root@localhost ~]# 
```

The key creation took a only sec.

```
[root@localhost ~]# openvasmd --create-credentials-encryption-key
Key creation succeeded.
[root@localhost ~]# 
```

Adding new credentials works like a charm now.

<p style="font-style: italic;">
Happy hacking!
</p>


 
