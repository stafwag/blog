---
layout: post
title: "Bacula on FreeBSD (Part 3 storage setup)"
date: 2017-12-27 11:25:25 +0100
comments: true
categories: [ bacula, freebsd, backup ]
---

{% img right /images/bacula_setup.jpg 500 416 "bacula setup" %} 


I finally got the time to continue with my <a href="https://blog.bacula.org/">bacula</a> backup setup. See my previous posts about the start of my bacula setup.

* <a href="http://stafwag.github.io/blog/blog/2017/08/06/bacula-on-freebsd:w_part1/">bacula on freebsd_part 1</a>
* <a href="http://stafwag.github.io/blog/blog/2017/09/09/bacula-on-freebsd-part2/">bacula on freebsd part 2</a>

# Storage setup

I created a new zfs pool "bigpool" with some old harddisks I probably need to replace them with bigger harddisk in the further.

## zfs filesystem

First we create a zfs filesystem for our bacula storage.

```
root@rataplan:~ # zfs create bigpool/bacula
root@rataplan:~ # 
```

## delegate to jail

### jailed

We want to use the zfs dataset in the bacula jail so we need to delegate the control to the dataset into the bacula jail.

```
root@rataplan:~ # zfs set jailed=on bigpool/bacula
root@rataplan:~ # zfs jail stafbacula bigpool/bacula
```

### verify

When we logon to the jail we see that the zfs dateset is available.

```
root@rataplan:~ # ezjail-admin console stafbacula
Last login: Wed Dec 27 10:52:27 on pts/2
FreeBSD 11.1-RELEASE-p4 (GENERIC) #0: Tue Nov 14 06:12:40 UTC 2017

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

Edit /etc/motd to change this login announcement.
You have new mail.
root@stafbacula:~ # zfs list
NAME             USED  AVAIL  REFER  MOUNTPOINT
bigpool         1.14M   433G    23K  /bigpool
bigpool/bacula    23K   433G    23K  /bigpool/bacula
root@stafbacula:~ # 
```

When we restart the jail we see that the dataset isn't available anymore in the jail

```
root@stafbacula:~ # logout
root@rataplan:~ # /usr/local/etc/rc.d/ezjail restart stafbacula
Stopping jails: stafbacula.
Starting jails: stafbacula.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@rataplan:~ # ezjail-admin console stafbacula
Last login: Wed Dec 27 10:58:33 on pts/2
FreeBSD 11.1-RELEASE-p4 (GENERIC) #0: Tue Nov 14 06:12:40 UTC 2017

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

Edit /etc/motd to change this login announcement.
You have new mail.
root@stafbacula:~ # zfs list
no datasets available
root@stafbacula:~ # 
```

### make persistent

#### enable zfs in the jail

When the jail is booted it need to bring the zfs filesystem online. We need to add ```zfs_enable=YES``` to the jail rc.conf

```
root@rataplan:~ # vi /usr/jails/stafbacula/etc/rc.conf
```

```
bacula_dir="start"
bacula_dir_enable="yes"
zfs_enable="YES"
```

#### update the ezjail configuration

ezjail needs to jail the zfs dataset to the jail when it's start the jail.

```
root@rataplan:~ # vi /usr/local/etc/ezjail/stafbacula
```

We need to add the dataset to the jail's zfs_datasets. By default a jail isn't allowed to mount the zfs dataset so need to update jail's parmeters.

```
export jail_stafbacula_zfs_datasets="bigpool/bacula"
export jail_stafbacula_parameters="enforce_statfs=0 allow.mount=1 allow.mount.zfs=1 allow.mount.procfs=1 allow.mount.devfs=1"

```

Restart the jail and verify that the zfs filesystem is available inside the jail

```
root@rataplan:~ # ezjail-admin restart stafbacula
Stopping jails: stafbacula.
Starting jails: stafbacula.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@rataplan:~ # 
```

Verify that dataset is mounted

```
root@rataplan:~ # ezjail-admin console stafbacula
Last login: Wed Dec 27 11:36:04 on pts/2
FreeBSD 11.1-RELEASE-p4 (GENERIC) #0: Tue Nov 14 06:12:40 UTC 2017

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

Edit /etc/motd to change this login announcement.
You have new mail.
root@stafbacula:~ # zfs list
NAME             USED  AVAIL  REFER  MOUNTPOINT
bigpool         1.14M   433G    23K  /bigpool
bigpool/bacula    23K   433G    23K  /bigpool/bacula
root@stafbacula:~ # df -h /bigpool/bacula
Filesystem                    Size    Used   Avail Capacity  Mounted on
zroot/usr/jails/stafbacula    2.6T    618M    2.6T     0%    /usr/jails/stafbacula
root@stafbacula:~ # 
```

# Links

* <a href="http://www.allanjude.com/blog/2013-10-05_poudriere_jail">http://www.allanjude.com/blog/2013-10-05_poudriere_jail</a>
