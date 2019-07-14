---
layout: post
title: "yum install lookat"
date: 2013-05-25 20:09
comments: true
categories: [ lookat, fedora ]
---

"yum install lookat" works on Fedora now  ;-)

Thanks <a href="http://cicku.me/">Christopher</a>!


```
[staf@vicky ~]$ sudo yum install lookat
[sudo] password for staf: 
Loaded plugins: langpacks, presto, refresh-packagekit, security
Repository google-chrome is listed more than once in the configuration
Resolving Dependencies
--> Running transaction check
---> Package lookat.x86_64 0:1.4.2-1.fc18 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

================================================================================================================================================================================
 Package                                 Arch                                    Version                                         Repository                                Size
================================================================================================================================================================================
Installing:
 lookat                                  x86_64                                  1.4.2-1.fc18                                    updates                                   55 k

Transaction Summary
================================================================================================================================================================================
Install  1 Package

Total download size: 55 k
Installed size: 118 k
Is this ok [y/N]: y
Downloading Packages:
lookat-1.4.2-1.fc18.x86_64.rpm                                                                                                                           |  55 kB  00:00:00     
Running Transaction Check
Running Transaction Test
Transaction Test Succeeded
Running Transaction
  Installing : lookat-1.4.2-1.fc18.x86_64                                                                                                                                   1/1 
  Verifying  : lookat-1.4.2-1.fc18.x86_64                                                                                                                                   1/1 

Installed:
  lookat.x86_64 0:1.4.2-1.fc18                                                                                                                                                  

Complete!
[staf@vicky ~]$ 
```
