---
layout: post
title: "Using squid to cache FreeBSD packages"
date: 2015-06-23 08:43
comments: true
categories: [ "squid" , "freebsd" , "pkgng" , "jails" ]  
excerpt_separator: <!--more-->
---

## PKGNG config

I manage a few <a href="https://www.freebsd.org/doc/handbook/jails.html">FreeBSD jails</a> behind a <a href="http://www.squid-cache.org/">squid proxy</a>. <a href="https://wiki.freebsd.org/pkgng">pkgng</a> is configured to use the proxy:

<!--more-->
```
root@rataplan:/root # cat /etc/pkg/FreeBSD.conf 
# $FreeBSD: releng/10.1/etc/pkg/FreeBSD.conf 263938 2014-03-30 15:29:54Z bdrewery $
#
# To disable this repository, instead of modifying or removing this file,
# create a /usr/local/etc/pkg/repos/FreeBSD.conf file:
#
#   mkdir -p /usr/local/etc/pkg/repos
#   echo "FreeBSD: { enabled: no }" > /usr/local/etc/pkg/repos/FreeBSD.conf
#

pkg_env: {

        http_proxy: "http://xxx.xxx.xxx.xxx:3128"

}

FreeBSD: {
  url: "pkg+http://pkg.FreeBSD.org/${ABI}/latest",
  mirror_type: "srv",
  signature_type: "fingerprints",
  fingerprints: "/usr/share/keys/pkg",
  enabled: yes
}
root@rataplan:/root # 

```

## SQUID config

### Recompile

The squid proxy doesn't cache to the FreeBSD packages. The squid pkgng package  is compiled with
"LAX_HTTP  Do not enforce strict HTTP compliance" option disabled. which doesn't allow you to override the cache headers sent by the remote site.

In order to cache the FreeBSD packages we need to recompile squid with "LAX_HTTPD" enabled.

#### Updating the ports

##### Physical system

If you use a physical FreeBSD system as your proxy run the "portsnap fetch" command.

```
[root@rataplan ~]# portsnap fetch
Looking up portsnap.FreeBSD.org mirrors... 7 mirrors found.
Fetching snapshot tag from ec2-eu-west-1.portsnap.freebsd.org... done.
Fetching snapshot metadata... done.
Updating from Mon Jun 22 14:30:21 CEST 2015 to Tue Jun 23 08:39:41 CEST 2015.
Fetching 4 metadata patches... done.
Applying metadata patches... done.
Fetching 0 metadata files... done.
Fetching 417 patches. 
(417/417) 100.00%  done.                                       
done.
Applying patches... 
done.
Fetching 3 new ports or files... done.
[root@rataplan ~]# 
``` 

```
[root@rataplan ~]# portsnap extract
/usr/ports/.arcconfig
/usr/ports/.gitignore
/usr/ports/CHANGES
/usr/ports/CONTRIBUTING.md
/usr/ports/COPYRIGHT
/usr/ports/GIDs

<snip>

/usr/ports/x11/zenity/
Building new INDEX files... done.
[root@rataplan ~]# 


```

##### Jail

If you use an <a href="http://erdgeist.org/arts/software/ezjail/">ezjail</a> as your proxy run the "ezjail-admin update -P" command.

#### Build

##### Stop SQUID

```
root@stafproxy:/usr/ports/www/squid # /usr/local/etc/rc.d/squid stop
squid not running? (check /var/run/squid/squid.pid).
root@stafproxy:/usr/ports/www/squid # 
```

##### Make config

```
root@stafproxy:/usr/ports/www/squid # cd
root@stafproxy:/root # cd /usr/ports/www/squid
root@stafproxy:/usr/ports/www/squid # make config
```

```

       ┌─────────────────────────────── squid-3.5.5 ──────────────────────────────────┐
       │ ┌──────────────────────────────────────────────────────────────────────────┐ │  
       │ │ [ ] ARP_ACL         ARP/MAC/EUI based authentification                   │ │  
       │ │ [ ] AUTH_LDAP       Install LDAP authentication helpers                  │ │  
       │ │ [x] AUTH_NIS        Install NIS/YP authentication helpers                │ │  
       │ │ [ ] AUTH_SASL       Install SASL authentication helpers                  │ │  
       │ │ [ ] AUTH_SMB        Install SMB auth. helpers (req. Samba)               │ │  
       │ │ [ ] AUTH_SQL        Install SQL based auth (uses MySQL)                  │ │  
       │ │ [ ] CACHE_DIGESTS   Use cache digests                                    │ │  
       │ │ [ ] DEBUG           Build with extended debugging support                │ │  
       │ │ [ ] DELAY_POOLS     Delay pools (bandwidth limiting)                     │ │  
       │ │ [x] DOCS            Build and/or install documentation                   │ │  
       │ │ [ ] ECAP            Loadable content adaptation modules                  │ │  
       │ │ [ ] ESI             ESI support                                          │ │  
       │ │ [x] EXAMPLES        Build and/or install examples                        │ │  
       │ │ [ ] FOLLOW_XFF      Support for the X-Following-For header               │ │  
       │ │ [x] FS_AUFS         AUFS (threaded-io) support                           │ │  
       │ │ [x] FS_DISKD        DISKD storage engine controlled by separate service  │ │  
       │ │ [ ] FS_ROCK         ROCK storage engine                                  │ │  
       │ │ [x] HTCP            HTCP support                                         │ │  
       │ │ [ ] ICAP            the ICAP client                                      │ │  
       │ │ [ ] ICMP            ICMP pinging and network measurement                 │ │  
       │ │ [x] IDENT           Ident lookups (RFC 931)                              │ │  
       │ │ [x] IPV6            IPv6 protocol support                                │ │  
       │ │ [x] KQUEUE          Kqueue(2) support                                    │ │  
       │ │ [ ] LARGEFILE       Support large (>2GB) cache and log files             │ │  
       │ │ [x] LAX_HTTP        Do not enforce strict HTTP compliance                │ │  
       │ │ [ ] NETTLE          Nettle MD5 algorithm support                         │ │  
       │ │ [x] SNMP            SNMP support                                         │ │  
       │ │ [ ] SSL             SSL gatewaying support                               │ │  
       │ │ [ ] SSL_CRTD        Use ssl_crtd to handle SSL cert requests             │ │  
       │ │ [ ] STACKTRACES     Enable automatic backtraces on fatal errors          │ │  
       │ │ [ ] TP_IPF          Transparent proxying with IPFilter                   │ │  
       │ │ [ ] TP_IPFW         Transparent proxying with IPFW                       │ │  
       │ │ [ ] TP_PF           Transparent proxying with PF                         │ │  
       │ │ [ ] VIA_DB          Forward/Via database                                 │ │  
       │ └─────v(+)─────────────────────────────────────────────────────────82%─────┘ │  
       ├──────────────────────────────────────────────────────────────────────────────┤  
       │                       <  OK  >            <Cancel>                           │  
       └──────────────────────────────────────────────────────────────────────────────┘  
                                                                                         

```

##### Make install

```
root@stafproxy:/usr/ports/www/squid # make
===>  License GPLv2 accepted by the user
===>  Found saved configuration for squid-3.5.5
===>   squid-3.5.5 depends on file: /usr/local/sbin/pkg - found
===> Fetching all distfiles required by squid-3.5.5 for building
===>  Extracting for squid-3.5.5
=> SHA256 Checksum OK for squid3.5/squid-3.5.5.tar.xz.

<snip>

Making install in test-suite
install  -m 0644 /var/ports/basejail/usr/ports/www/squid/work/squid-3.5.5/helpers/basic_auth/DB/passwd.sql  /var/ports/basejail/usr/ports/www/squid/work/stage/usr/local/share/examples/squid
(cd /var/ports/basejail/usr/ports/www/squid/work/squid-3.5.5 && install  -m 0644 QUICKSTART README RELEASENOTES.html doc/debug-sections.txt /var/ports/basejail/usr/ports/www/squid/work/stage/usr/local/share/doc/squid)
/bin/mkdir -p /var/ports/basejail/usr/ports/www/squid/work/stage/var/squid/logs
/bin/rmdir /var/ports/basejail/usr/ports/www/squid/work/stage/var/run/squid
====> Compressing man pages (compress-man)
===> Staging rc.d startup script(s)
```

```
root@stafproxy:/usr/ports/www/squid # make install clean
===>  Installing for squid-3.5.5                                                                                                                                                                                                             
===>   squid-3.5.5 depends on file: /usr/local/bin/perl5.20.2 - found                                                                                                                                                                        
===>  Checking if squid already installed                                                                                                                                                                                                    
===>   Registering installation for squid-3.5.5                                                                                                                                                                                              

<snip>

===> SECURITY REPORT: 
      This port has installed the following files which may act as network
      servers and may therefore pose a remote security risk to the system.
/usr/local/libexec/squid/basic_radius_auth
/usr/local/sbin/squid

      This port has installed the following startup scripts which may cause
      these network services to be started at boot time.
/usr/local/etc/rc.d/squid

      If there are vulnerabilities in these programs there may be a security
      risk to the system. FreeBSD makes no guarantee about the security of
      ports included in the Ports Collection. Please type 'make deinstall'
      to deinstall the port if this is a concern.

      For more information, and contact details about the security
      status of this software, see the following webpage: 
http://www.squid-cache.org/

```


##### pkg lock

Lock the squid package to prevent the upgrade from pkgng tree.

```
root@stafproxy:/usr/ports/www/squid # pkg lock squid
squid-3.5.5: lock this package? [y/N]: y
Locking squid-3.5.5
root@stafproxy:/usr/ports/www/squid #

```

View the locked pkgng packages

```
root@stafproxy:/usr/ports/www/squid # pkg lock -l
Currently locked packages:
squid-3.5.5
root@stafproxy:/usr/ports/www/squid # 
```

### SQUID config 

#### Update squid.conf

Edit the squid config:

```
root@stafproxy:/usr/ports/www/squid # cd /usr/local/etc/squid/
root@stafproxy:/usr/local/etc/squid # vi squid.conf

```

Add a "refresh_pattern" for "pkgmir.pkg.freebsd.org":

```
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^http://pkgmir.pkg.freebsd.org/.*\.txz          1440    100%    10080 ignore-private ignore-must-revalidate override-expire ignore-no-cache
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
```

#### Start squid

```
root@stafproxy:/usr/local/etc/squid # ../rc.d/squid start
Starting squid.
root@stafproxy:/usr/local/etc/squid # 

```

#### rc.conf

Make sure that the system is configured to start squid during the system startup.
 

```
root@stafproxy:/usr/local/etc/squid # cat /etc/rc.conf 
#
# squid
#

squid_enable="YES"

root@stafproxy:/usr/local/etc/squid # 
```

SQUID should cache the pkgng downloads now.

*Have fun*

