---
layout: post
title: "DNS Privacy with Stubby (Part 2 FreeBSD)"
date: 2018-10-07 09:06:05 +0200
comments: true
categories: [security, privacy, freebsd, dns] 
---

# FreeBSD

[In my previous blog article](https://stafwag.github.io/blog/blog/2018/09/09/dns-privacy-with-stubby-part1-gnulinux/) we install on GNU/Linux which is my main desktop operation system. [My NAS](https://stafwag.github.io/blog/blog/2012/12/16/running-freebsd-9.0-on-asus-c60m1-i-motherboard/) and the services that are required to be always running are on [FreeBSD](https://www.freebsd.org).

In this arcticle we will setup Stubby - the DNS Privacy Daemon - on FreeBSD.

## Jails

FreeBSD jails are verify nice to keep services separated in a secure way.

### ezjail

[ezjail](https://erdgeist.org/arts/software/ezjail/) is a very nice tool for managing FreeBSD jails. 

```
root@rataplan:~ # pkg install ezjail
```

### To loopback or not to loopback....

The loopback ip address is mapped to the jail ip address on FreeBSD by default.
There are two options

* use the jail ip address, make sure that you setup a firewall rule if you want disable traffic from external.
* use a cloned loopback interface; keep in mind that with a cloned interface this interface is shared between your jails.

We'll use the jail ip address.

#### create the jail

We create a new jail and we assign the cloned loop interface with a loopback ip address - this loopback ip address must be unique for each for each jail - and outside interface and ip address.

```
root@rataplan:~ # ezjail-admin create stafdns 're0|192.168.1.53'
```

#### start the jail

```
root@rataplan:/usr/local/etc/ezjail # ezjail-admin start stafdns
Starting jails: stafdns.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@rataplan:/usr/local/etc/ezjail #
```

#### console login and install pkg

Logon to the jail and install pkg we might need to configure a dns server or use a proxy sever to install pkg. 

```
root@rataplan:/usr/local/etc/ezjail # ezjail-admin console stafdns
root@stafdns:~ # echo "nameserver 9.9.9.9" > /etc/resolv.conf
root@stafdns:~ # pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
Bootstrapping pkg from pkg+http://pkg.FreeBSD.org/FreeBSD:11:amd64/quarterly, please wait...
Verifying signature with trusted certificate pkg.freebsd.org.2013102301... done
[stafdns] Installing pkg-1.10.5_1...
[stafdns] Extracting pkg-1.10.5_1: 100%
pkg: not enough arguments
Usage: pkg [-v] [-d] [-l] [-N] [-j <jail name or id>|-c <chroot path>|-r <rootdir>] [-C <configuration file>] [-R <repo config dir>] [-o var=value] [-4|-6] <command> [<args>]

For more information on available commands and options see 'pkg help'.
root@stafdns:~ #

```

## Install stubby

Stubby available in the [FreeBSD Ports](https://www.freebsd.org/ports/) in the getdns package, ...but it isn't installed when you install the binary package. To install stubby we need to it from source.

### dig

To debug dns issues dig a handy tool to have.... 

```
root@rataplan:/usr/ports/dns/getdns # pkg install bind-tools
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Updating database digests format: 100%
The following 4 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        bind-tools: 9.12.2P1
        idnkit: 1.0_7
        py27-ply: 3.11
        json-c: 0.13

Number of packages to be installed: 4

The process will require 42 MiB more space.
4 MiB to be downloaded.

Proceed with this action? [y/N]: y
```

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

I use [ezjail](https://erdgeist.org/arts/software/ezjail/) to manage my [FreeBSD jails](https://www.freebsd.org/doc/handbook/jails.html). Execute the ```ezjail-admin update -P``` to update the ports tree inside your jails.


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

### Install stubby

Go to the getdns ports directory

```
root@stafproxy:/root # cd /usr/ports/dns/getdns/
root@stafproxy:/usr/ports/dns/getdns # make config
```
and run ```make config``` select ```[ ] STUBBY    Build with Stubby DNS/TLS resolver```

```
┌─────────────────────────────── getdns-1.4.2 ─────────────────────────────────┐
│ ┌──────────────────────────────────────────────────────────────────────────┐ │
│ │+[x] DOCS      Build and/or install documentation                         │ │
│ │+[ ] LIBEV     Build with libev extension                                 │ │
│ │+[ ] LIBEVENT  Build with libevent extension                              │ │
│ │+[ ] LIBUV     Build with libuv extension                                 │ │
│ │+[x] STUBBY    Build with Stubby DNS/TLS resolver                         │ │
│ └──────────────────────────────────────────────────────────────────────────┘ │
├──────────────────────────────────────────────────────────────────────────────┤
│                       <  OK  >            <Cancel>                           │
└──────────────────────────────────────────────────────────────────────────────┘
```

run ```make``` and accept the defaults.

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

Lock the package to avoid that the package gets replaced by a getdns package without stubby.

```
root@stafproxy:/usr/ports/dns/getdns # pkg lock getdns
getdns-1.4.2: lock this package? [y/N]: y
Locking getdns-1.4.2
root@stafproxy:/usr/ports/dns/getdns # 
```
## Configure stubby


### Enable the stubby service

Use ```sysrc``` to enable the stubby service...

```
root@stafproxy:/usr/local/etc # service stubby start
Cannot 'start' stubby. Set stubby_enable to YES in /etc/rc.conf or use 'onestart' instead of 'start'.
root@stafproxy:/usr/local/etc # service stubby rcvar
# stubby
#
stubby_enable="NO"
#   (default: "")

root@stafproxy:/usr/local/etc # sysrc stubby_enable="YES"
stubby_enable:  -> YES
root@stafproxy:/usr/local/etc # 
```

### choose your upstream dns provider

Edit the stubby.yml file and uncomment the upstream dns server that you want the use. Stubby will loadbalance the dns traffic to all configured upstream dns servers by default. This is configured with the round_robin_upstreams directive, if set to 1 the traffic is loadbalanced, if set 0 stubby will use the first configured dns server.

```
root@rataplan:/usr/local/etc # vi stubby/stubby.yml
```

### Change the port

We'll setup dnsmasq to cache our dns requests modify the ```listen_addresses``` directive and set the port 53000

```
listen_addresses:
  - 127.0.0.1@53000
  - 0::1@53000
```

### Start it

```
root@stafproxy:/usr/local/etc # service stubby start
Starting stubby.
[07:51:37.865826] STUBBY: Read config from file /usr/local/etc/stubby/stubby.yml
root@stafproxy:/usr/local/etc # 
```

### test it

```
root@stafproxy:/root # dig @<ip_of_the_jail> -p 53000 www.wagemakers.be

; <<>> DiG 9.8.3-P4 <<>> @127.0.0.53 -p 53000 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 56970
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      85181   IN      CNAME   wagemakers.be.
wagemakers.be.          85181   IN      A       95.215.185.144

;; Query time: 110 msec
;; SERVER: 127.0.0.53#53000(127.0.0.53)
;; WHEN: Sat Sep 22 13:16:11 2018
;; MSG SIZE  rcvd: 119

```

### dnsmasq

#### Install dnsmasq.

```
root@stafproxy:/root # pkg install dnsmasq
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        dnsmasq: 2.79,1

Number of packages to be installed: 1

329 KiB to be downloaded.

Proceed with this action? [y/N]: y
[stafproxy] [1/1] Fetching dnsmasq-2.79,1.txz: 100%  329 KiB 336.4kB/s    00:01
Checking integrity... done (0 conflicting)
[stafproxy] [1/1] Installing dnsmasq-2.79,1...
[stafproxy] [1/1] Extracting dnsmasq-2.79,1: 100%
Message from dnsmasq-2.79,1:

*** To enable dnsmasq, edit /usr/local/etc/dnsmasq.conf and
*** set dnsmasq_enable="YES" in /etc/rc.conf[.local]
***
*** Further options and actions are documented inside
*** /usr/local/etc/rc.d/dnsmasq
root@stafproxy:/root #
```

#### Enable dnsmasq.

Usae ```sysrc``` to enable the dnsmasq service.

```
root@stafproxy:/root # sysrc dnsmasq_enable="YES"
dnsmasq_enable:  -> YES
root@stafproxy:/root #
```

#### Configure dnsmasq

```
root@stafproxy:/usr/local/etc # mv dnsmasq.conf dnsmasq.conf_org
root@stafproxy:/usr/local/etc # vi dnsmasq.conf
```

```
server=<ip_address_of_the_jail>#53000
listen-address=<ip_address_of_the_jail>
interface=<netork_interface_of_the_jail>
bind-interfaces
```

#### start dnsmasq

```
root@stafproxy:/usr/local/etc # service dnsmasq start
Starting dnsmasq.
root@stafproxy:/usr/local/etc #
```

#### test it

```
root@stafproxy:/usr/local/etc # dig @192.168.1.45 www.wagemakers.be

; <<>> DiG 9.8.3-P4 <<>> @192.168.1.45 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 32987
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      86000   IN      CNAME   wagemakers.be.
wagemakers.be.          86000   IN      A       95.215.185.144

;; Query time: 308 msec
;; SERVER: 192.168.1.45#53(192.168.1.45)
;; WHEN: Sun Oct  7 09:16:51 2018
;; MSG SIZE  rcvd: 119

root@stafproxy:/usr/local/etc #

```

#### Update /etc/resolv.conf

Update your ```/etc/resolv.conf```

```
root@stafproxy:/usr/local/etc # vi /etc/resolv.conf
```

```
nameserver <ip_address_of_the_jail>
```

and test it;

```
root@stafproxy:/usr/local/etc # dig www.wagemakers.be

; <<>> DiG 9.8.3-P4 <<>> www.wagemakers.be
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27629
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 0

;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      85702   IN      CNAME   wagemakers.be.
wagemakers.be.          85702   IN      A       95.215.185.144

;; Query time: 1 msec
;; SERVER: 192.168.1.45#53(192.168.1.45)
;; WHEN: Sun Oct  7 09:21:49 2018
;; MSG SIZE  rcvd: 78

root@stafproxy:/usr/local/etc #
```

*** Have fun! ***










# Links

* [https://stafwag.github.io/blog/blog/2018/09/09/dns-privacy-with-stubby-part1-gnulinux/](https://stafwag.github.io/blog/blog/2018/09/09/dns-privacy-with-stubby-part1-gnulinux/)
* [https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/jails-ezjail.html](https://www.freebsd.org/doc/en_US.ISO8859-1/books/handbook/jails-ezjail.html)
