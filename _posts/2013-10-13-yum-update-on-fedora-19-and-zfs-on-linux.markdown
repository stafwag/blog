---
layout: post
title: "yum update on fedora 19 and zfs on linux"
date: 2013-10-13 17:51
comments: true
categories: [ zfs, yum, fedora, linux ] 
---

<img src="http://zfsonlinux.org/images/zfs-linux.png" class="left" width="200" height="125" alt="zfs" />

I use  <a href="http://zfsonlinux.org/"> zfs on linux</a> on <a href="http://fedoraproject.org/">fedora</a> now.


<a href="http://zfsonlinux.org/fedora.html">The installation</a> was pretty straightforward but after the installation of <a href="http://open-zfs.org/">zfs</a> ```yum update``` failed.

<br />

```
[root@vicky etc]# yum update -y
Loaded plugins: langpacks, refresh-packagekit
Repository google-chrome is listed more than once in the configuration
fedora/19/x86_64/metalink                                                                                                                                                                   |  33 kB  00:00:00     
fedora                                                                                                                                                                                      | 4.2 kB  00:00:00     
fedora-chromium-stable                                                                                                                                                                      | 3.4 kB  00:00:00     
google-chrome                                                                                                                                                                               |  951 B  00:00:00     
rpmfusion-free                                                                                                                                                                              | 3.3 kB  00:00:00     
rpmfusion-free-updates                                                                                                                                                                      | 3.3 kB  00:00:00     
rpmfusion-nonfree                                                                                                                                                                           | 3.3 kB  00:00:00     
rpmfusion-nonfree-updates                                                                                                                                                                   | 3.3 kB  00:00:00     
updates/19/x86_64/metalink                                                                                                                                                                  |  30 kB  00:00:00     
updates                                                                                                                                                                                     | 4.4 kB  00:00:00     
zfs                                                                                                                                                                                         | 2.9 kB  00:00:00     
(1/6): fedora-chromium-stable/19/x86_64/primary_db                                                                                                                                          |  20 kB  00:00:00     
(2/6): zfs/19/x86_64/primary_db                                                                                                                                                             | 6.7 kB  00:00:00     
(3/6): updates/19/x86_64/group_gz                                                                                                                                                           | 385 kB  00:00:02     
(4/6): fedora/19/x86_64/group_gz                                                                                                                                                            | 384 kB  00:00:06     
(5/6): updates/19/x86_64/primary_db                                                                                                                                                         | 8.8 MB  00:01:53     
(6/6): fedora/19/x86_64/primary_db                                                                                                                                                          |  17 MB  00:03:34     
(1/10): google-chrome/primary                                                                                                                                                               | 1.9 kB  00:00:00     
(2/10): rpmfusion-free-updates/19/x86_64/primary_db                                                                                                                                         | 217 kB  00:00:01     
(3/10): rpmfusion-nonfree/19/x86_64/primary_db                                                                                                                                              | 149 kB  00:00:00     
(4/10): rpmfusion-free/19/x86_64/primary_db                                                                                                                                                 | 440 kB  00:00:03     
(5/10): rpmfusion-nonfree-updates/19/x86_64/primary_db                                                                              b                                                       |  97 kB  00:00:00     
(6/10): rpmfusion-nonfree-updates/19/x86_64/group_gz                                                                                                                                        |  990 B  00:00:05     
(7/10): rpmfusion-nonfree/19/x86_64/group_gz                                                                                                                                                |  993 B  00:00:07     
(8/10): rpmfusion-free/19/x86_64/group_gz                                                                                                                                                   | 1.6 kB  00:00:07     
(9/10): rpmfusion-free-updates/19/x86_64/group_gz                                                                                                                                           | 1.6 kB  00:00:07     
(10/10): updates/19/x86_64/updateinfo                                                                                                                                                       | 861 kB  00:00:09     
google-chrome                                                                                                                                                                                                  3/3
Resolving Dependencies
--> Running transaction check
---> Package dkms.noarch 0:2.2.0.3-14.zfs1.fc19 will be updated
--> Processing Dependency: dkms = 2.2.0.3-14.zfs1.fc19 for package: zfs-dkms-0.6.2-1.fc19.noarch
---> Package dkms.noarch 0:2.2.0.3-17.fc19 will be an update
--> Finished Dependency Resolution
Error: Package: zfs-dkms-0.6.2-1.fc19.noarch (@zfs)
           Requires: dkms = 2.2.0.3-14.zfs1.fc19
           Removing: dkms-2.2.0.3-14.zfs1.fc19.noarch (@zfs)
               dkms = 2.2.0.3-14.zfs1.fc19
           Updated By: dkms-2.2.0.3-17.fc19.noarch (updates)
               dkms = 2.2.0.3-17.fc19
           Available: dkms-2.2.0.3-5.fc19.noarch (fedora)
               dkms = 2.2.0.3-5.fc19
 You could try using --skip-broken to work around the problem
 You could try running: rpm -Va --nofiles --nodigest
[root@vicky etc]# 
```

On another fedora system ```yum update``` worked fine, after reviewing the differences in the yum configuration it seems that ```yum-plugin-priorities``` wasn't installed on my box. After installing ```yum-plugin-priorities``` 

```
[root@vicky etc]# yum install yum-plugin-priorities
Loaded plugins: langpacks, refresh-packagekit
Repository google-chrome is listed more than once in the configuration
Resolving Dependencies
--> Running transaction check
---> Package yum-plugin-priorities.noarch 0:1.1.31-18.fc19 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

===================================================================================================================================================================================================================
 Package                                                     Arch                                         Version                                              Repository                                     Size
===================================================================================================================================================================================================================
Installing:
 yum-plugin-priorities                                       noarch                                       1.1.31-18.fc19                                       updates                                        22 k

Transaction Summary
===================================================================================================================================================================================================================
Install  1 Package

Total download size: 22 k
Installed size: 28 k
Is this ok [y/d/N]: y
Downloading packages:
yum-plugin-priorities-1.1.31-18.fc19.noarch.rpm                                                                                                                                             |  22 kB  00:00:01     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : yum-plugin-priorities-1.1.31-18.fc19.noarch                                                                                                                                                     1/1 
  Verifying  : yum-plugin-priorities-1.1.31-18.fc19.noarch                                                                                                                                                     1/1 

Installed:
  yum-plugin-priorities.noarch 0:1.1.31-18.fc19                                                                                                                                                                    

Complete!
[root@vicky etc]# 
```

And make sure that the zfs has the priority

```
[root@localhost etc]# cat yum.repos.d/zfs.repo
[zfs]
name=ZFS of Linux for Fedora $releasever
baseurl=http://archive.zfsonlinux.org/fedora/$releasever/$basearch/
enabled=1
priority=1
metadata_expire=7d
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
Requires:       yum-plugin-priorities

[zfs-source]
name=ZFS of Linux for Fedora $releasever - Source
baseurl=http://archive.zfsonlinux.org/fedora/$releasever/SRPMS/
enabled=0
metadata_expire=7d
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
[root@vicky etc]# 
```

 ```yum update``` works again.


```
[root@vicky etc]# yum update -y
Loaded plugins: langpacks, priorities, refresh-packagekit
Repository google-chrome is listed more than once in the configuration
2 packages excluded due to repository priority protections
No packages marked for update
[root@vicky etc]# 
```

