---
layout: post
title: "Migrate from ezjail to BastilleBSD part 2: Migrate the Jails"
date: 2023-09-17 08:30:00 +0200
comments: true
categories: freebsd jail raspberrypi BastilleBSD ezjail
excerpt_separator: <!--more-->
---

# How to migrate Jails from ezjail to BastilleBSD

<a href="{{ '/images/daemon_hammer.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/daemon_hammer.jpg' | remove_first:'/' | absolute_url }}" class="right" width="300" height="355" alt="daemon_hammer" /> </a>

In my [previous blog post](https://stafwag.github.io/blog/blog/2023/09/10/migrate-from-ezjail-to-bastille-part1-introduction-to-bastillebsd/), I reviewed BastilleBSD. In this post, we go through the required steps to migrate the Jails from [ezjail](https://erdgeist.org/arts/software/ezjail/) to [BastilleBSD](https://bastillebsd.org/).

## ezjail test Jail

To test the Jail migration, we'll first create a test Jail with ezjail.
This test Jail will migrate to a BastilleBSD Jail.

### Create the test ezjail Jail

We use the ```ezjail-admin create staftestje001 'vtnet0|<ip>'``` command to create the test Jail.

<!--more-->

```
root@pi-rataplan:~ # ezjail-admin create staftestje001 'vtnet0|<ip>'
Warning: Some services already seem to be listening on all IP, (including 192.168.1.51)
  This may cause some confusion, here they are:
root     nfsd       93987 5  tcp4   *:2049                *:*
root     nfsd       93987 6  tcp6   *:2049                *:*
root     mountd     92576 6  udp6   *:1014                *:*
root     mountd     92576 7  tcp6   *:1014                *:*
root     mountd     92576 8  udp4   *:1014                *:*
root     mountd     92576 9  tcp4   *:1014                *:*
root     ntpd       88967 20 udp6   *:123                 *:*
root     ntpd       88967 21 udp4   *:123                 *:*
root     rpc.statd  86127 4  udp6   *:654                 *:*
root     rpc.statd  86127 5  tcp6   *:654                 *:*
root     rpc.statd  86127 6  udp4   *:654                 *:*
root     rpc.statd  86127 7  tcp4   *:654                 *:*
root     rpcbind    85696 6  udp6   *:111                 *:*
root     rpcbind    85696 7  udp6   *:702                 *:*
root     rpcbind    85696 8  tcp6   *:111                 *:*
root     rpcbind    85696 9  udp4   *:111                 *:*
root     rpcbind    85696 10 udp4   *:996                 *:*
root     rpcbind    85696 11 tcp4   *:111                 *:*
root@pi-rataplan:~ # 
```
Review the created Jail.

```
root@pi-rataplan:~ # ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZS  N/A  192.168.1.51    staftestje001                  /usr/jails/staftestje001
root@pi-rataplan:~ #
```

Start the Jail with ```ezjail-admin start staftst1```

```
root@pi-rataplan:~ # ezjail-admin start staftst1 
Starting jails: staftst1.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@pi-rataplan:~ # 
```

Access the console with ```ezjail-admin console```

```
root@pi-rataplan:~ # ezjail-admin console staftestje001
FreeBSD 13.2-RELEASE-p2 GENERIC

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List:        https://www.FreeBSD.org/lists/questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

To change this login announcement, see motd(5).
root@staftestje001:~ # 
```

Add a user.

```
root@staftestje001:~ # adduser 
Username: staf
Full name: staf
Uid (Leave empty for default): 
Login group [staf]: 
Login group is staf. Invite staf into other groups? []: wheel
Login class [default]: 
Shell (sh csh tcsh nologin) [sh]: 
Home directory [/home/staf]: 
Home directory permissions (Leave empty for default): 
Use password-based authentication? [yes]: 
Use an empty password? (yes/no) [no]: 
Use a random password? (yes/no) [no]: 
Enter password: 
Enter password again: 
Lock out the account after creation? [no]: no
Username   : staf
Password   : *****
Full Name  : staf
Uid        : 1001
Class      : 
Groups     : staf wheel
Home       : /home/staf
Home Mode  : 
Shell      : /bin/sh
Locked     : no
OK? (yes/no): yes
adduser: INFO: Successfully added (staf) to the user database.
Add another user? (yes/no): no
Goodbye!
```

Become the user test user and create some files.

```
root@staftestje001:~ # su - staf
You can use aliases to decrease the amount of typing you need to do to get
commands you commonly use.  Examples of fairly popular aliases include (in
Bourne shell style, as in /bin/sh, bash, ksh, and zsh):

	alias lf="ls -FA"
	alias ll="ls -lA"
	alias su="su -m"

In csh or tcsh, these would be

	alias lf ls -FA
	alias ll ls -lA
	alias su su -m

To remove an alias, you can usually use 'unalias aliasname'.  To list all
aliases, you can usually type just 'alias'.
staf@staftestje001:~ $ 
```

```
staf@staftestje001:~ $ vi testfile
```


<a href="{{ '/images/bastille-icon.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/bastille-icon.png' | remove_first:'/' | absolute_url }}" class="left" width="200" height="200" alt="bastille-icon.png" /> </a>

## Migrate the ezjail Jail to BastilleBSD
### Stop the ezjail jail

Execute ```ezjail-admin stop``` to stop the Jail.

```
root@pi-rataplan:~ # ezjail-admin stop staftestje001
Stopping jails: staftestje001.
root@pi-rataplan:~ # 
```

### Archive

Use ```ezjail-admin archive``` to create a tar dump of the Jail.

```
root@pi-rataplan:~ # ezjail-admin archive staftestje001
pax: Access/modification time set failed on: ./var/empty <Operation not permitted>
Warning: Archiving jail staftestje001 was not completely successful.\n  Please refer to the output above for problems the archiving tool encountered.\n  You may ignore reports concerning setting access and modification times.\n  You might want to check and remove /usr/jails/ezjail_archives/staftestje001-202308161229.21.tar.gz.Warning: Archiving jail staftestje001 was not completely successful. For a running jail this is not unusual.
root@pi-rataplan:~ # 
```

The tar file is created at ```/usr/jails/ezjail_archives```

```
root@pi-rataplan:~ # ls -l  /usr/jails/ezjail_archives
total 267233
-rw-r--r--  1 root  wheel  136712524 Aug 16 12:29 staftestje001-202308161229.21.tar.gz
root@pi-rataplan:~ # 
```

### Import

It's possible to import the ezjail archive with ```bastille import```.

```
[root@pi-rataplan ~]# bastille import /usr/jails/ezjail_archives/staftestje001-202308161229.21.tar.gz 
Importing 'staftestje001' from foreign compressed .tar.gz archive.
Preparing ZFS environment...
Extracting files from 'staftestje001-202308161229.21.tar.gz' archive...
tar: Removing leading '/' from member names
Generating jail.conf...
Updating symlinks...
Container 'staftestje001' imported successfully.
[root@pi-rataplan ~]# 
```

List the Jails.

```
[root@pi-rataplan ~]# bastille list -a
 JID              State  IP Address           Published Ports  Hostname         Release          Path
 bastille-tst001  Up     192.168.1.50         -                bastille-tst001  13.2-RELEASE-p2  /usr/local/bastille/jails/bastille-tst001/root
 staftestje001    Down   vtnet0|192.168.1.51  -                staftestje001    13.2-RELEASE-p2  /usr/local/bastille/jails/staftestje001/root
[root@pi-rataplan ~]# 
```

### Correct the IP Address

Our archived test Jail is imported.

We defined the interface as part of the ```ezjail-admin create``` command. But this ended up in the ```IP Address``` configuration.

Let's see how this is defined in our Jail configuration.

Go to the Jail dataset.

```
root@pi-rataplan:~ # cd /usr/local/bastille/jails/staftestje001/
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # 
```

List the configuration files.

```
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # ls
fstab
fstab.ezjail
jail.conf
prop.ezjail-staftestje001-202309032022.27-pi_rataplan-13.2_RELEASE_p2-aarch64
root
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 #
```

Edit the ```jail.conf```

```
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # vi jail.conf
```

```
staftestje001 {
  devfs_ruleset = 4;
  enforce_statfs = 2;
  exec.clean;
  exec.consolelog = /var/log/bastille/staftestje001_console.log;
  exec.start = '/bin/sh /etc/rc';
  exec.stop = '/bin/sh /etc/rc.shutdown';
  host.hostname = staftestje001;
  mount.devfs;
  mount.fstab = /usr/local/bastille/jails/staftestje001/fstab;
  path = /usr/local/bastille/jails/staftestje001/root;
  securelevel = 2;

  interface = vtnet0;
  ip4.addr = vtnet0|192.168.1.51;
  ip6 = disable;
}

```

The interface is defined in the interface config and the ```ip4.addr```.
Remove the interface from the ```ip4.addr```.

```
  ip4.addr = 192.168.1.51;
```

Execute ```bastille list -a``` to verify.

```
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # bastille list -a
 JID              State  IP Address           Published Ports  Hostname         Release          Path
 bastille-tst001  Down   192.168.1.50         -                bastille-tst001  13.2-RELEASE-p2  /usr/local/bastille/jails/bastille-tst001/root
 staftestje001    Down   192.168.1.51   
```
### Verify

Start the Jail with ```bastille start```

```
root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # bastille start staftestje001
[staftestje001]:
staftestje001: created

root@pi-rataplan:/usr/local/bastille/jails/staftestje001 # 
``` 

Test that the test user and files are imported correctly.

```
[staftestje001]:
Last login: Sun Sep  3 18:02:03 on pts/2
FreeBSD 13.2-RELEASE-p2 GENERIC

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List:        https://www.FreeBSD.org/lists/questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

To change this login announcement, see motd(5).
root@staftestje001:~ # su - staf
Need to quickly return to your home directory? Type "cd".
		-- Dru <genesis@istar.ca>
staf@staftestje001:~ $ ls
testfile
staf@staftestje001:~ $ 
```

## Delete the ezjail Jail

The last step is to remove the "old" ezjail.

```
[root@pi-rataplan ~]# ezjail-admin list
STA JID  IP              Hostname                       Root Directory
--- ---- --------------- ------------------------------ ------------------------
ZS  N/A  192.168.1.51    staftestje001                  /usr/jails/staftestje001
ZR  2    192.168.1.49    stafscm                        /usr/jails/stafscm
ZR  3    192.168.1.45    stafproxy                      /usr/jails/stafproxy
ZR  4    192.168.1.47    stafmail                       /usr/jails/stafmail
ZR  5    192.168.1.41    staffs                         /usr/jails/staffs
ZR  6    192.168.1.85    stafdns                        /usr/jails/stafdns
[root@pi-rataplan ~]# ezjail-admin delete staftestje001
[root@pi-rataplan ~]# 
```

```ezjail delete``` only removes the Jail configuration. The storage is still there. Might be useful if you want to restore the Jail. And we still have a backup in ```/usr/local/jails/archives``` if for some reason we need to restore the old ezjail.

```
[root@pi-rataplan ~]# zfs list | grep -i testje001
zroot/bastille/jails/staftestje001             219M   153G      144K  /usr/local/bastille/jails/staftestje001
zroot/bastille/jails/staftestje001/root        219M   153G      219M  /usr/local/bastille/jails/staftestje001/root
zroot/usr/jails/staftestje001                  219M   153G      219M  /usr/jails/staftestje001
[root@pi-rataplan ~]# 
```

As the procedure seems to work, I'll continue with migration with the ezjail Jails to BastilleBSD :-)



# Links

* [https://github.com/BastilleBSD/bastille/issues/360](https://github.com/BastilleBSD/bastille/issues/360)
* [https://dan.langille.org/2013/07/26/ezjail-admin-moving-a-jail-between-hosts-with-archive/](https://dan.langille.org/2013/07/26/ezjail-admin-moving-a-jail-between-hosts-with-archive/)
* [https://forums.freebsd.org/threads/strange-behavior-with-devfs_ruleset.80919/](https://forums.freebsd.org/threads/strange-behavior-with-devfs_ruleset.80919/)
* [https://lists.freebsd.org/pipermail/freebsd-ports/2017-December/112085.html](https://lists.freebsd.org/pipermail/freebsd-ports/2017-December/112085.html)
