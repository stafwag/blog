---
layout: post
title: "DNS Privacy with Stubby (Part 2 FreeBSD)"
date: 2018-09-09 09:06:05 +0200
comments: true
categories: [security, privacy, freebsd, dns] 
---

# FreeBSD

In my previous blog article we install on GNU/Linux which is my main desktop operation system. [My NAS](https://stafwag.github.io/blog/blog/2012/12/16/running-freebsd-9.0-on-asus-c60m1-i-motherboard/) and the services that are required to be always on runs [FreeBSD](https://www.freebsd.org).

In this arcticle we will set Stubby - the DNS Privacy Daemon - on FreeBSD.


## Install stubby

Stubby available in the [FreeBSD Ports](https://www.freebsd.org/ports/) in the getdns package, ...but it isn't installed when you install the binary package. To install stubby we need to it from source.

### Update your ports tree

#### Physical system

On physical FreeBSD system execute ```portsnap fetch``` and ```portsnap extract```

```
root@rataplan:~ # portsnap fetch
Looking up portsnap.FreeBSD.org mirrors... 6 mirrors found.
Fetching snapshot tag from ec2-eu-west-1.portsnap.freebsd.org... done.
Fetching snapshot metadata... done.
Updating from Sat Sep  8 09:31:35 CEST 2018 to Sun Sep  9 09:51:49 CEST 2018.
Fetching 4 metadata patches... done.
Applying metadata patches... done.
Fetching 0 metadata files... done.
Fetching 44 patches. 
(44/44) 100.00%  done.                                
done.
Applying patches... 
done.
Fetching 2 new ports or files... done.
root@rataplan:~ # 
```

```
root@rataplan:~ # portsnap extract
/usr/ports/.arcconfig
/usr/ports/.gitattributes
/usr/ports/.gitauthors
/usr/ports/.gitignore
/usr/ports/.gitmessage
/usr/ports/CHANGES
/usr/ports/CONTRIBUTING.md
/usr/ports/COPYRIGHT
/usr/ports/GIDs
/usr/ports/Keywords/desktop-file-utils.ucl
/usr/ports/Keywords/fc.ucl
/usr/ports/Keywords/fcfontsdir.ucl

<snip>

/usr/ports/x11/xzoom/
/usr/ports/x11/yad/
/usr/ports/x11/yakuake-kde4/
/usr/ports/x11/yakuake/
/usr/ports/x11/yalias/
/usr/ports/x11/yeahconsole/
/usr/ports/x11/yelp/
/usr/ports/x11/zenity/
Building new INDEX files... done.
```

#### Jail

I use [ezjail](https://erdgeist.org/arts/software/ezjail/) to manage my [FreeBSD jails](https://www.freebsd.org/doc/handbook/jails.html).

```
root@rataplan:~ # ezjail-admin update -P
Looking up portsnap.FreeBSD.org mirrors... 6 mirrors found.
Fetching snapshot tag from ec2-eu-west-1.portsnap.freebsd.org... done.
Ports tree hasn't changed since last snapshot.
No updates needed.
Removing old files and directories... done.
Extracting new files:
/usr/jails/basejail/usr/ports/archivers/py-lz4/
/usr/jails/basejail/usr/ports/astro/wmsolar/
/usr/jails/basejail/usr/ports/audio/musicpd/
/usr/jails/basejail/usr/ports/biology/seaview/
/usr/jails/basejail/usr/ports/deskutils/gsimplecal/
/usr/jails/basejail/usr/ports/deskutils/xfce4-tumbler/
/usr/jails/basejail/usr/ports/devel/eric6/
/usr/jails/basejail/usr/ports/devel/es-eric6/
/usr/jails/basejail/usr/ports/devel/ioncube/
/usr/jails/basejail/usr/ports/devel/liblouis/
/usr/jails/basejail/usr/ports/devel/monodevelop/
/usr/jails/basejail/usr/ports/devel/rudeconfig/
/usr/jails/basejail/usr/ports/emulators/ppsspp-qt5/
/usr/jails/basejail/usr/ports/emulators/ppsspp/
/usr/jails/basejail/usr/ports/german/eric6/
/usr/jails/basejail/usr/ports/java/linux-oracle-jdk10/
/usr/jails/basejail/usr/ports/java/linux-oracle-jre10/
/usr/jails/basejail/usr/ports/java/openjdk8/
/usr/jails/basejail/usr/ports/lang/gcc6-devel/
/usr/jails/basejail/usr/ports/lang/gcc7-devel/
/usr/jails/basejail/usr/ports/lang/gcc8-devel/
/usr/jails/basejail/usr/ports/lang/gcc9-devel/
/usr/jails/basejail/usr/ports/misc/ree/
/usr/jails/basejail/usr/ports/net-im/psi/
/usr/jails/basejail/usr/ports/net-mgmt/p5-Net-SNMP/
/usr/jails/basejail/usr/ports/net/Makefile
/usr/jails/basejail/usr/ports/net/charm/
/usr/jails/basejail/usr/ports/net/linknx/
/usr/jails/basejail/usr/ports/net/py-maxminddb/
/usr/jails/basejail/usr/ports/net/py-shodan/
/usr/jails/basejail/usr/ports/net/tcpreen/
/usr/jails/basejail/usr/ports/ports-mgmt/pkg-devel/
/usr/jails/basejail/usr/ports/print/ghostscript9-agpl-base/
/usr/jails/basejail/usr/ports/russian/eric6/
/usr/jails/basejail/usr/ports/science/Makefile
/usr/jails/basejail/usr/ports/science/metaphysicl/
/usr/jails/basejail/usr/ports/science/namd/
/usr/jails/basejail/usr/ports/security/sancp/
/usr/jails/basejail/usr/ports/security/testssl.sh/
/usr/jails/basejail/usr/ports/textproc/scim-bridge/
/usr/jails/basejail/usr/ports/www/orangehrm/
/usr/jails/basejail/usr/ports/www/smarty3/
/usr/jails/basejail/usr/ports/www/tinytinyhttpd/
/usr/jails/basejail/usr/ports/x11-wm/spectrwm/
/usr/jails/basejail/usr/ports/x11/plasma5-plasma-workspace/
/usr/jails/basejail/usr/ports/x11/sddm/
Building new INDEX files... done.
root@rataplan:~ # 
```

### Update your ports tree

Go to the getdns ports directory

```
root@stafproxy:/root # cd /usr/ports/dns/getdns/
root@stafproxy:/usr/ports/dns/getdns # 
```
and run ```make config``` select ```[ ] STUBBY    Build with Stubby DNS/TLS resolver```

```
???????????????????????????????? getdns-1.4.2 ??????????????????????????????????
? ???????????????????????????????????????????????????????????????????????????? ?
? ?+[x] DOCS      Build and/or install documentation                         ? ?
? ?+[ ] LIBEV     Build with libev extension                                 ? ?
? ?+[ ] LIBEVENT  Build with libevent extension                              ? ?
? ?+[ ] LIBUV     Build with libuv extension                                 ? ?
? ?+[x] STUBBY    Build with Stubby DNS/TLS resolver                         ? ?
? ???????????????????????????????????????????????????????????????????????????? ?
????????????????????????????????????????????????????????????????????????????????
?                       <  OK  >            <Cancel>                           ?
????????????????????????????????????????????????????????????????????????????????
```

run make and accept the defaults.

```
root@stafproxy:/usr/ports/dns/getdns # make
===>  License BSD3CLAUSE accepted by the user
===>   getdns-1.4.2 depends on file: /usr/local/sbin/pkg - found
=> getdns-1.4.2.tar.gz doesn't seem to exist in /var/ports/distfiles/.
=> Attempting to fetch https://getdnsapi.net/dist/getdns-1.4.2.tar.gz
getdns-1.4.2.tar.gz                           100% of 1034 kB 1092 kBps 00m01s
===> Fetching all distfiles required by getdns-1.4.2 for building
===>  Extracting for getdns-1.4.2
=> SHA256 Checksum OK for getdns-1.4.2.tar.gz.

<snip>

/usr/bin/install -c -m 644 getdns_service_sync.3 /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/man/man3
/usr/bin/install -c -m 644 getdns_validate_dnssec.3 /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/man/man3
/usr/bin/strip /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/lib/libgetdns*.so.*
/usr/bin/strip /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/bin/getdns_*
/usr/bin/strip /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/bin/stubby
/bin/mv /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/etc/stubby/stubby.yml  /var/ports/basejail/usr/ports/dns/getdns/work/stage/usr/local/etc/stubby/stubby.yml.sample
====> Compressing man pages (compress-man)
===> Staging rc.d startup script(s)
```

make install

```
root@stafproxy:/usr/ports/dns/getdns # make install
===>  Installing for getdns-1.4.2
===>  Checking if getdns already installed
===>   Registering installation for getdns-1.4.2
[stafproxy] Installing getdns-1.4.2...
***
***  !!! IMPORTANT !!!!  libgetdns needs a DNSSEC trust anchor!
***
***  For the library to be able to perform DNSSEC, the root
***  trust anchor needs to be present in presentation format
***  in the file:
***     /usr/local/etc/unbound/root.key
***
***  We recomend using unbound-anchor to retrieve and install
***  the root trust anchor like this:
***     su -m unbound -c /usr/local/sbin/unbound-anchor
***

===> SECURITY REPORT: 
      This port has installed the following files which may act as network
      servers and may therefore pose a remote security risk to the system.
/usr/local/lib/libgetdns.a(stub.o)
/usr/local/lib/libgetdns.so.10.0.2
/usr/local/lib/libgetdns.a(server.o)

      This port has installed the following startup scripts which may cause
      these network services to be started at boot time.
/usr/local/etc/rc.d/stubby

      If there are vulnerabilities in these programs there may be a security
      risk to the system. FreeBSD makes no guarantee about the security of
      ports included in the Ports Collection. Please type 'make deinstall'
      to deinstall the port if this is a concern.

      For more information, and contact details about the security
      status of this software, see the following webpage: 
https://getdnsapi.net/
root@stafproxy:/usr/ports/dns/getdns # 
```


