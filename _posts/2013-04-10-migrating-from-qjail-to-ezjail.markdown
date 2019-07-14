---
layout: post
title: "Migrating from Qjail to ezjail"
date: 2013-04-10 12:36
comments: true
categories: [ "freebsd", "jails", "qjail", "ezjail" ]
---

I was using <a href="http://qjail.sourceforge.net/">qjail</a> on <a href="http://stafwag.github.io/blog/blog/2012/12/16/running-freebsd-9.0-on-asus-c60m1-i-motherboard/">my freebsd system</a> but I'm migrating to <a href="http://erdgeist.org/arts/software/ezjail/">ezjail</a>.

The reason for this is that the <a href="http://www.freshports.org/sysutils/qjail">port</a> is marked as RESTRICTED.
Since it seems to be a fork from <a href="http://erdgeist.org/arts/software/ezjail/">ezjail</a> without respecting the copyright and license <a href="https://lists.freebsd.org/pipermail/freebsd-jail/2013-March/002149.html">https://lists.freebsd.org/pipermail/freebsd-jail/2013-March/002149.html</a>.

### Backup

#### Move the existing jails to old\_jails 

Move the existing jails zfs filesystem aside just in case we need to migrate back 

```
root@rataplan:/usr/ports/sysutils/ezjail # zfs set mountpoint=/usr/old_jails zroot/usr/jails
root@rataplan:/usr/ports/sysutils/ezjail # zfs set mountpoint=/usr/old_jails/staffs zroot/usr/jails/staffs
root@rataplan:/usr/ports/sysutils/ezjail # zfs set mountpoint=/usr/old_jails/stafmail zroot/usr/jails/stafmail
root@rataplan:/usr/ports/sysutils/ezjail # zfs set mountpoint=/usr/old_jails/stafdb zroot/usr/jails/stafdb
root@rataplan:/usr/ports/sysutils/ezjail # zfs rename zroot/usr/jails zroot/usr/old_jails
```

#### Stop the running jails

Stop the jails that are still running.

```
root@rataplan:/usr/local/etc # qjail stop
Jail stopped successfully. stafmail
Jail stopped successfully. staffs
Jail already stopped.      stafdb
```
### _ezjail_ setup

#### Installing ezjail

The installation of _ezjail_ is pretty straightforward...


```
root@rataplan:/root # cd /usr/ports/sysutils/ezjail/
root@rataplan:/usr/ports/sysutils/ezjail # make install clean
===>  Installing for ezjail-3.2.3
===>   Generating temporary packing list
===>  Checking if sysutils/ezjail already installed
mkdir -p /usr/local/etc/ezjail/ /usr/local/man/man1/ /usr/local/man/man5/ /usr/local/man/man7 /usr/local/man/man8 /usr/local/etc/rc.d/ /usr/local/bin/ /usr/local/share/examples/ezjail /usr/local/share/zsh/site-functions
cp -p ezjail.conf.sample /usr/local/etc/
cp -R -p examples/example /usr/local/share/examples/ezjail/
cp -R -p examples/nullmailer-example /usr/local/share/examples/ezjail/
cp -R -p share/zsh/site-functions/ /usr/local/share/zsh/site-functions/
sed s:EZJAIL_PREFIX:/usr/local: ezjail.sh > /usr/local/etc/rc.d/ezjail
sed s:EZJAIL_PREFIX:/usr/local: ezjail-admin > /usr/local/bin/ezjail-admin
sed s:EZJAIL_PREFIX:/usr/local: man8/ezjail-admin.8 > /usr/local/man/man8/ezjail-admin.8
sed s:EZJAIL_PREFIX:/usr/local: man5/ezjail.conf.5 > /usr/local/man/man5/ezjail.conf.5
sed s:EZJAIL_PREFIX:/usr/local: man7/ezjail.7 > /usr/local/man/man7/ezjail.7
chmod 755 /usr/local/etc/rc.d/ezjail /usr/local/bin/ezjail-admin
chown -R root:wheel /usr/local/man/man8/ezjail-admin.8 /usr/local/man/man5/ezjail.conf.5 /usr/local/man/man7/ezjail.7 /usr/local/share/examples/ezjail/
chmod 0440 /usr/local/share/examples/ezjail/example/usr/local/etc/sudoers
[ -f /usr/local/etc/ezjail.conf ] ||  /bin/cp -p /usr/local/etc/ezjail.conf.sample  /usr/local/etc/ezjail.conf
===>   Compressing manual pages for ezjail-3.2.3
===>   Registering installation for ezjail-3.2.3
===>  Cleaning for ezjail-3.2.3
root@rataplan:/usr/ports/sysutils/ezjail # 
```

#### Create /usr/jails

```
root@rataplan:/root # zfs create zroot/usr/jails
root@rataplan:/root # 
```

#### Copy the sample config

```
root@rataplan:/root # cd /usr/local/etc/
root@rataplan:/usr/local/etc # cp ezjail.conf.sample ezjail.conf
```

#### Update ezjail.conf to use zfs

This will create a zfs filesystem for each jail automatically. Cool ;-)

```
# Setting this to YES will start to manage the basejail and newjail in ZFS
ezjail_use_zfs="YES"
# Setting this to YES will manage ALL new jails in their own zfs
ezjail_use_zfs_for_jails="YES"
# The name of the ZFS ezjail should create jails on, it will be mounted at the ezjail_jaildir
ezjail_jailzfs="zroot/usr/jails"
```


#### Installing the base jail without a make world

Most ezjail howto's that I found assume that you already ran a "make world". I want to setup the base jail without a "make world" because this takes too much time on my system.
Lucky you can install the basejail without a "make world".

```
root@rataplan:/usr/local/etc # ezjail-admin install
Trying 193.162.146.4:21 ...
Connected to ftp.freebsd.org.
220 beastie.tdk.net FTP server (Version 6.00LS) ready.
331 Guest login ok, send your email address as password.
230 Guest login ok, access restrictions apply.
Remote system type is UNIX.
Using binary mode to transfer files.
200 Type set to I.
250 CWD command successful.
local: base.txz remote: base.txz
229 Entering Extended Passive Mode (|||65080|)
150 Opening BINARY mode data connection for 'base.txz' (59854248 bytes).
100% |***********************************************************************************************************************************| 58451 KiB  451.20 KiB/s    00:00 ETA
226 Transfer complete.
59854248 bytes received in 02:09 (451.20 KiB/s)
221 Goodbye.
Trying 193.162.146.4:21 ...
Connected to ftp.freebsd.org.
220 beastie.tdk.net FTP server (Version 6.00LS) ready.
331 Guest login ok, send your email address as password.
230 Guest login ok, access restrictions apply.
Remote system type is UNIX.
Using binary mode to transfer files.
200 Type set to I.
250 CWD command successful.
local: lib32.txz remote: lib32.txz
229 Entering Extended Passive Mode (|||55936|)
150 Opening BINARY mode data connection for 'lib32.txz' (9743636 bytes).
 37% |************************************************                                                                                   |  3576 KiB  447.04 KiB/s    00:13 ETA
```
&lt;snip&gt;
```
/usr/jails/basejail/usr/lib32/libbsnmp.so.6
/usr/jails/basejail/usr/lib32/libcam.a
/usr/jails/basejail/usr/lib32/libsupc++.a
/usr/jails/basejail/usr/lib32/libarchive.a
/usr/jails/basejail/usr/lib32/libpcap.so.8
/usr/jails/basejail/usr/lib32/libbsdxml.so.4
108748 blocks
Note: a non-standard /etc/make.conf was copied to the template jail in order to get the ports collection running inside jails.
root@rataplan:/usr/local/etc # 
```
```
root@rataplan:/usr/local/etc # cd /usr/jails/
root@rataplan:/usr/jails # ls
basejail	flavours	newjail
root@rataplan:/usr/jails # 
```

#### Add the jails ip addresses to the system.

This is different from qjail, by ezjail it's required to setup the ip addresses for each jail.

Open /etc/rc.conf and create interface aliases for each jail. 

```
ifconfig_re0="inet 192.168.1.40/24"
ifconfig_re0_alias0="inet 192.168.1.41/32"
ifconfig_re0_alias1="inet 192.168.1.42/32"
ifconfig_re0_alias2="inet 192.168.1.43/32"
ifconfig_re0_alias3="inet 192.168.1.44/32"
```

And create them by running netif restart

```
root@rataplan:/etc/rc.d # ./netif restart
Stopping Network: lo0 re0.
lo0: flags=8048<LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
	options=600003<RXCSUM,TXCSUM,RXCSUM_IPV6,TXCSUM_IPV6>
	nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
re0: flags=8802<BROADCAST,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=8209b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,WOL_MAGIC,LINKSTATE>
	ether 30:85:a9:40:58:ba
	inet6 fe80::3285:a9ff:fe40:58ba%re0 prefixlen 64 scopeid 0x6 
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect (1000baseT <full-duplex>)
	status: active
Starting Network: lo0 re0.
lo0: flags=8049<UP,LOOPBACK,RUNNING,MULTICAST> metric 0 mtu 16384
	options=600003<RXCSUM,TXCSUM,RXCSUM_IPV6,TXCSUM_IPV6>
	inet6 ::1 prefixlen 128 
	inet6 fe80::1%lo0 prefixlen 64 scopeid 0x9 
	inet 127.0.0.1 netmask 0xff000000 
	nd6 options=21<PERFORMNUD,AUTO_LINKLOCAL>
re0: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> metric 0 mtu 1500
	options=8209b<RXCSUM,TXCSUM,VLAN_MTU,VLAN_HWTAGGING,VLAN_HWCSUM,WOL_MAGIC,LINKSTATE>
	ether 30:85:a9:40:58:ba
	inet6 fe80::3285:a9ff:fe40:58ba%re0 prefixlen 64 scopeid 0x6 
	inet 192.168.1.40 netmask 0xffffff00 broadcast 192.168.1.255
	inet 192.168.1.41 netmask 0xffffffff broadcast 192.168.1.41
	inet 192.168.1.42 netmask 0xffffffff broadcast 192.168.1.42
	inet 192.168.1.43 netmask 0xffffffff broadcast 192.168.1.43
	inet 192.168.1.44 netmask 0xffffffff broadcast 192.168.1.44
	nd6 options=29<PERFORMNUD,IFDISABLED,AUTO_LINKLOCAL>
	media: Ethernet autoselect (none)
	status: no carrier
root@rataplan:/etc/rc.d # 

```

#### Creating the first jail

```
root@rataplan:/etc/rc.d # ezjail-admin create stafpuppet 192.168.1.44
Warning: Some services already seem to be listening on IP 192.168.1.44
  This may cause some confusion, here they are:
root     ntpd       29764 31 udp4   192.168.1.44:123      *:*
Warning: Some services already seem to be listening on all IP, (including 192.168.1.44)
  This may cause some confusion, here they are:
root     ntpd       29764 20 udp4   *:123                 *:*
root     ntpd       29764 21 udp6   *:123                 *:*
root     rpc.statd  1161  4  udp6   *:1021                *:*
root     rpc.statd  1161  5  tcp6   *:1021                *:*
root     rpc.statd  1161  6  udp4   *:1021                *:*
root     rpc.statd  1161  7  tcp4   *:1021                *:*
root     nfsd       1157  5  tcp4   *:2049                *:*
root     nfsd       1157  6  tcp6   *:2049                *:*
root     mountd     1151  6  udp6   *:942                 *:*
root     mountd     1151  7  tcp6   *:942                 *:*
root     mountd     1151  8  udp4   *:942                 *:*
root     mountd     1151  9  tcp4   *:942                 *:*
root     rpcbind    1120  6  udp6   *:111                 *:*
root     rpcbind    1120  7  udp6   *:960                 *:*
root     rpcbind    1120  8  tcp6   *:111                 *:*
root     rpcbind    1120  9  udp4   *:111                 *:*
root     rpcbind    1120  10 udp4   *:777                 *:*
root     rpcbind    1120  11 tcp4   *:111                 *:*
root     syslogd    1099  6  udp6   *:514                 *:*
root     syslogd    1099  7  udp4   *:514                 *:*
root@rataplan:/etc/rc.d # 
```

#### Starting the jail

```
root@rataplan:/etc/rc.d # /usr/local/etc/rc.d/ezjail 
Usage: /usr/local/etc/rc.d/ezjail [fast|force|one|quiet](start|stop|restart|rcvar|startcrypto|stopcrypto)
root@rataplan:/etc/rc.d # /usr/local/etc/rc.d/ezjail start
 ezjailConfiguring jails:.
Starting jails: stafpuppet.
```

#### Listing the jail

```
root@rataplan:/etc/rc.d # jls
   JID  IP Address      Hostname                      Path
     3  192.168.1.44    stafpuppet                    /usr/jails/stafpuppet
root@rataplan:/etc/rc.d # ping 192.168.1.44
PING 192.168.1.44 (192.168.1.44): 56 data bytes
64 bytes from 192.168.1.44: icmp_seq=0 ttl=64 time=0.053 ms
^C
--- 192.168.1.44 ping statistics ---
1 packets transmitted, 1 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 0.053/0.053/0.053/0.000 ms
root@rataplan:/etc/rc.d # 

```

#### Console access

```
root@rataplan:/etc/rc.d # jexec 3 csh
root@stafpuppet:/ # 

```

#### Install the freebsd ports into the base jail

```
[root@rataplan ~]# ezjail-admin update -P   
Looking up portsnap.FreeBSD.org mirrors... 6 mirrors found.
Fetching snapshot tag from ec2-eu-west-1.portsnap.freebsd.org... done.
Fetching snapshot metadata... done.
Updating from Wed Apr 10 14:55:36 CEST 2013 to Thu Apr 11 14:00:20 CEST 2013.
Fetching 3 metadata patches.. done.
Applying metadata patches... done.
Fetching 0 metadata files... done.
Fetching 17 patches.....10... done.
Applying patches... done.
Fetching 0 new ports or files... done.
/usr/jails/basejail/usr/ports/CHANGES
/usr/jails/basejail/usr/ports/COPYRIGHT
/usr/jails/basejail/usr/ports/GIDs
/usr/jails/basejail/usr/ports/KNOBS
/usr/jails/basejail/usr/ports/Keywords/info.yaml
/usr/jails/basejail/usr/ports/LEGAL
/usr/jails/basejail/usr/ports/MOVED
/usr/jails/basejail/usr/ports/Makefile
/usr/jails/basejail/usr/ports/Mk/Uses/
/usr/jails/basejail/usr/ports/Mk/bsd.apache.mk
/usr/jails/basejail/usr/ports/Mk/bsd.autotools.mk

```
&lt;snip&gt;
```
/usr/jails/basejail/usr/ports/x11/xzoom/
/usr/jails/basejail/usr/ports/x11/yad/
/usr/jails/basejail/usr/ports/x11/yakuake-kde4/
/usr/jails/basejail/usr/ports/x11/yakuake/
/usr/jails/basejail/usr/ports/x11/yalias/
/usr/jails/basejail/usr/ports/x11/yeahconsole/
/usr/jails/basejail/usr/ports/x11/yelp/
/usr/jails/basejail/usr/ports/x11/zenity/
Building new INDEX files... done.
[root@rataplan ~]# 

```

Verify

```
[root@rataplan ~]# jls 
   JID  IP Address      Hostname                      Path
     3  192.168.1.44    stafpuppet                    /usr/jails/stafpuppet
[root@rataplan ~]# jexec 3 csh
root@stafpuppet:/ # cd /usr/ports/
root@stafpuppet:/usr/ports # ls
.portsnap.INDEX	KNOBS		Templates	astro		converters	finance		hungarian	math		news		science		www		x11-themes
CHANGES		Keywords	Tools		audio		databases	french		irc		misc		palm		security	x11		x11-toolkits
COPYRIGHT	LEGAL		UIDs		benchmarks	deskutils	ftp		japanese	multimedia	polish		shells		x11-clocks	x11-wm
GIDs		MOVED		UPDATING	biology		devel		games		java		net		ports-mgmt	sysutils	x11-drivers
INDEX-7		Makefile	accessibility	cad		dns		german		korean		net-im		portuguese	textproc	x11-fm
INDEX-8		Mk		arabic		chinese		editors		graphics	lang		net-mgmt	print		ukrainian	x11-fonts
INDEX-9		README		archivers	comms		emulators	hebrew		mail		net-p2p		russian		vietnamese	x11-servers
root@stafpuppet:/usr/ports # 

```

#### Update the base jail

```
[root@rataplan /usr]# ezjail-admin update -u
Looking up update.FreeBSD.org mirrors... 3 mirrors found.
Fetching metadata signature for 9.1-RELEASE from update4.freebsd.org... done.
Fetching metadata index... done.
Inspecting system... 
```

#### update /etc/rc.conf

```
#
# ezjails
#

ezjail_enable="YES"
```

### Migrate the jails to _ezjail_

#### Recreate the jail

```
[root@rataplan /etc]# ezjail-admin create staffs 192.168.1.41
Warning: Some services already seem to be listening on IP 192.168.1.41
  This may cause some confusion, here they are:
root     ntpd       29764 24 udp4   192.168.1.41:123      *:*
Warning: Some services already seem to be listening on all IP, (including 192.168.1.41)
  This may cause some confusion, here they are:
root     ntpd       29764 20 udp4   *:123                 *:*
root     ntpd       29764 21 udp6   *:123                 *:*
root     rpc.statd  1161  4  udp6   *:1021                *:*
root     rpc.statd  1161  5  tcp6   *:1021                *:*
root     rpc.statd  1161  6  udp4   *:1021                *:*
root     rpc.statd  1161  7  tcp4   *:1021                *:*
root     nfsd       1157  5  tcp4   *:2049                *:*
root     nfsd       1157  6  tcp6   *:2049                *:*
root     mountd     1151  6  udp6   *:942                 *:*
root     mountd     1151  7  tcp6   *:942                 *:*
root     mountd     1151  8  udp4   *:942                 *:*
root     mountd     1151  9  tcp4   *:942                 *:*
root     rpcbind    1120  6  udp6   *:111                 *:*
root     rpcbind    1120  7  udp6   *:960                 *:*
root     rpcbind    1120  8  tcp6   *:111                 *:*
root     rpcbind    1120  9  udp4   *:111                 *:*
root     rpcbind    1120  10 udp4   *:777                 *:*
root     rpcbind    1120  11 tcp4   *:111                 *:*
root     syslogd    1099  6  udp6   *:514                 *:*
root     syslogd    1099  7  udp4   *:514                 *:*
[root@rataplan /etc]# 

```

#### Clone the zfs filesystem

```
[root@rataplan /etc]# zfs destroy zroot/usr/jails/staffs
[root@rataplan /etc]# zfs snapshot zroot/usr/old_jails/staffs@org
[root@rataplan /etc]# zfs clone zroot/usr/old_jails/staffs@org zroot/usr/jails/staffs

```

#### Start the jail

```
[root@rataplan /etc]# /usr/local/etc/rc.d/ezjail start staffs
Configuring jails:.
Starting jails: staffs.
[root@rataplan /etc]# 

```





