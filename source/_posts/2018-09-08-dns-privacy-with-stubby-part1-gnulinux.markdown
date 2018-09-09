---
layout: post
title: "DNS Privacy with Stubby (Part 1 GNU/Linux)"
date: 2018-09-08 12:30:03 +0200
comments: true
categories: [security, privacy, linux, dns]  
---

*** Installing and configuring an encrypted dns server is straightforward, there is no reason to use an unencrypted dns service. ***

## DNS is not secure or private

DNS traffic is insecure and runs over [UDP](https://nl.wikipedia.org/wiki/User_Datagram_Protocol) port 53 ([TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) for [zone transfers](https://en.wikipedia.org/wiki/DNS_zone_transfer) ) unecrypted by default.

This make your encrypted DNS traffic a **privacy risk** and a **security risk**: 

* anyone that is able to sniff your network traffic can collect a lot information from your leaking DNS traffic.
* with a DNS spoofing attack an attacker can trick you let go to malicious website or try to intercept your email traffic.


## Encrypt your dns traffic

Encrypting your network traffic is always a good idea for privacy and security reasons - *** we encrypt, because we can! *** -  .
More information about dns privacy can be found at [https://dnsprivacy.org/](https://dnsprivacy.org/)

On this site you'll find also the [DNS Privacy Daemon - Stubby](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby) that let's you send your DNS request over TLS to an alternative DNS provider. You should use a DNS provider that you trust and has a no logging policy.  [quad9](https://www.quad9.net/), [cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) and google dns are well-known alternative dns providers. At [https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers) you can find a few other options.

You'll find my journey to setup Stubby on a few operation systems I use (or I'm force to use) below ...

## GNU/Linux

### Arch Linux

I use [Arch Linux](https://www.archlinux.org/) on my main workstation. Stubby is already in the Arch repositories this make installation straightforward.

#### Install stubby 

```
[root@vicky ~]# pacman -S stubby
resolving dependencies...
looking for conflicting packages...

Packages (5) fstrm-0.4.0-1  getdns-1.4.2-1  protobuf-c-1.3.0-3  unbound-1.7.3-4
             stubby-0.2.3-1

Total Download Size:   1.09 MiB
Total Installed Size:  5.68 MiB

:: Proceed with installation? [Y/n] 
:: Retrieving packages...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 88476  100 88476    0     0   403k      0 --:--:-- --:--:-- --:--:--  403k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 62480  100 62480    0     0  1271k      0 --:--:-- --:--:-- --:--:-- 1271k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  632k  100  632k    0     0   750k      0 --:--:-- --:--:-- --:--:--  749k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  302k  100  302k    0     0  1615k      0 --:--:-- --:--:-- --:--:-- 1606k
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 34052  100 34052    0     0   831k      0 --:--:-- --:--:-- --:--:--  831k
(5/5) checking keys in keyring                       [###########################] 100%
(5/5) checking package integrity                     [###########################] 100%
(5/5) loading package files                          [###########################] 100%
(5/5) checking for file conflicts                    [###########################] 100%
(5/5) checking available disk space                  [###########################] 100%
:: Processing package changes...
(1/5) installing fstrm                               [###########################] 100%
(2/5) installing protobuf-c                          [###########################] 100%
(3/5) installing unbound                             [###########################] 100%
Optional dependencies for unbound
    expat: unbound-anchor [installed]
(4/5) installing getdns                              [###########################] 100%
(5/5) installing stubby                              [###########################] 100%
:: Running post-transaction hooks...
(1/4) Reloading system manager configuration...
(2/4) Creating system user accounts...
(3/4) Creating temporary files...
(4/4) Arming ConditionNeedsUpdate...
[root@vicky ~]# 
```

##### choose your upstream dns provider

Edit the stubby.yml file and uncomment the upstream dns server that you want the use.
Stubby will loadbalance the dns traffic to all configured upstream dns servers by default.
This is configured with the ```round_robin_upstreams``` directive, if set to ```1``` the traffic is loadbalanced, if set ```0``` stubby will use the first configured dns server.

```
[staf@vicky ~]$ sudo vi /etc/stubby/stubby.yml
```

##### enable and start stubby

```
[root@vicky ~]# systemctl enable stubby
Created symlink /etc/systemd/system/multi-user.target.wants/stubby.service -> /usr/lib/systemd/system/stubby.service.
[root@vicky ~]# systemctl start stubby
[root@vicky ~]# 
```

##### test

```
[root@vicky ~]# dig @127.0.0.1 www.wagemakers.be

; <<>> DiG 9.13.2 <<>> @127.0.0.1 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 18226
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
; COOKIE: fe9d3618b821614f174436385b7acb64a4f4cc6657e14626 (good)
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      86000   IN      CNAME   wagemakers.be.
wagemakers.be.          86000   IN      A       95.215.185.144

;; Query time: 128 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Aug 20 16:08:36 CEST 2018
;; MSG SIZE  rcvd: 147

[root@vicky ~]# 
```

#### Local dns cache with dnsmasq

##### Change the stubby port.

Edit /etc/stubby/stubby.yml

```
[root@vicky ~]# vi /etc/stubby/stubby.yml
```

And change the port by modifing the ```listen_addresses``` directive

```
listen_addresses:
  - 127.0.0.1@53000
  - 0::1@53000
```

restart stubby

```
[root@vicky ~]# systemctl restart stubby.service
```

and verify that the dns on 127.0.0.1:53 doesn't work anymore.

```
[root@vicky ~]# dig @127.0.0.1 www.wagemakers.be

; <<>> DiG 9.13.2 <<>> @127.0.0.1 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; connection timed out; no servers could be reached
[root@vicky ~]# 
```

ensure that stubby does work on port 53000

```
[root@frija etc]# dig @127.0.0.1 -p 53000 www.wagemakers.be

; <<>> DiG 9.13.2 <<>> @127.0.0.1 -p 53000 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 27173
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 65535
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      43200   IN      CNAME   wagemakers.be.
wagemakers.be.          43200   IN      A       95.215.185.144

;; Query time: 250 msec
;; SERVER: 127.0.0.1#53000(127.0.0.1)
;; WHEN: Tue Aug 21 13:26:37 CEST 2018
;; MSG SIZE  rcvd: 119

[root@frija etc]# 
```

##### Install dnsmasq

```
[root@vicky ~]# pacman -S dnsmasq
warning: dnsmasq-2.79-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (1) dnsmasq-2.79-1

Total Installed Size:  0.70 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                       [###########################] 100%
(1/1) checking package integrity                     [###########################] 100%
(1/1) loading package files                          [###########################] 100%
(1/1) checking for file conflicts                    [###########################] 100%
(1/1) checking available disk space                  [###########################] 100%
:: Processing package changes...
(1/1) reinstalling dnsmasq                           [###########################] 100%
:: Running post-transaction hooks...
(1/3) Reloading system manager configuration...
(2/3) Creating system user accounts...
(3/3) Arming ConditionNeedsUpdate...
[root@vicky ~]# 
```

##### Configure dnsmasq

```
[root@vicky etc]# cd /etc
[root@vicky etc]# mv /etc/dnsmasq.conf /etc/dnsmasq.conf_org
[root@vicky etc]# vi dnsmasq.conf
```

It is import to configure stubby to listen the localhost interface only.
If you use Linux KVM you probably have a dns serivce running on your bridge interfaces for your virtual machines.

```
server=127.0.0.1#53000
listen-address=127.0.0.1
interface=lo
bind-interfaces
```

#### Start and enable dnsmasq

```
[root@vicky ~]# systemctl start dnsmasq
[root@vicky ~]# systemctl enable dnsmasq
Created symlink /etc/systemd/system/multi-user.target.wants/dnsmasq.service -> /usr/lib/systemd/system/dnsmasq.service.
[root@vicky ~]# 
```

#### Reconfigure your system

reconfigure your system to use dnsmasq as the dns service.

I use [netctl](https://wiki.archlinux.org/index.php/Netctl) on my system. You can update the network configuration with ```netctl```

```
[root@vicky netctl]# netctl edit <network_name>
[root@vicky netctl]# netctl restart  <network_name>
```

If you networkmanager you can use ```nmcli```, ```nmtui``` or the GUI network configuration in your desktop environment.

### GNU/Linux is GNU/Linux

The configuration on other GNU/Linux distributions is the same as on Arch apart from the installation process.
The same method can be use if your (favorite) Linux distribution doesn't have a stubby package, the installation method of the required package will be different of course.

### Debian
 
#### Current testing release Debian "buster"

```
$ sudo apt install stubby dnsmasq
```

#### Current stable Debian 9 "strech"

Stubby in the ```getdns-utils``` in Debian stretch, it's an older version. 
Therefor I ended up with building stubby from the source code.

##### Install the required packages

Install the required packages to build stubby.

```
staf@stretch:~/github$ sudo apt install build-essential git libtool autoconf libssl-dev libyaml-dev
```

##### git clone

The getdns git repo;

```
staf@stretch:~/github$ git clone https://github.com/getdnsapi/getdns.git
Cloning into 'getdns'...
remote: Counting objects: 16154, done.
remote: Total 16154 (delta 0), reused 0 (delta 0), pack-reused 16154
Receiving objects: 100% (16154/16154), 9.72 MiB | 1.13 MiB/s, done.
Resolving deltas: 100% (12413/12413), done.
staf@stretch:~/github$ 
```

##### checkout the latest stable release

Verify the lastest release tag. The current stable release 1.4.2

```
staf@stretch:~/github/getdns$ git tag
TNW2015
list
v0.1.0
v0.1.1
v0.1.2
<snip>
v1.4.0
v1.4.0-rc1
v1.4.1
v1.4.1-rc1
v1.4.2
v1.4.2-rc1
staf@stretch:~/github/getdns$ 
```

checkout the latest stable release.

```
staf@stretch:~/github/getdns$ git checkout v1.4.2
Note: checking out 'v1.4.2'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch-name>

HEAD is now at e481273... Last minute update
staf@stretch:~/github/getdns$ 
```

##### build it...

```
staf@stretch:~/github/getdns$ git submodule update --init
staf@stretch:~/github/getdns$ libtoolize -ci
staf@stretch:~/github/getdns$ autoreconf -fi
staf@stretch:~/github/getdns$ mkdir build
staf@stretch:~/github/getdns$ cd build/
staf@stretch:~/github/getdns/build$ ../configure --prefix=/usr/local --without-libidn --without-libidn2 --enable-stub-only --with-stubby
staf@stretch:~/github/getdns/build$ make
```

##### make install

```
staf@stretch:~/github/getdns/build$ sudo make install
[sudo] password for staf: 
cd src && make install
make[1]: Entering directory '/home/staf/github/getdns/build/src'
<snip>
make[1]: Leaving directory '/home/staf/github/getdns/build/doc'
***
***  !!! IMPORTANT !!!!
***
***  From release 1.2.0, getdns comes with built-in DNSSEC
***  trust anchor management.  External trust anchor management,
***  for example with unbound-anchor, is no longer necessary
***  and no longer recommended.
***
***  Previously installed trust anchors, in the default location -
***
***        /usr/local/etc/unbound/getdns-root.key
***
***  - will be preferred and used for DNSSEC validation, however
***  getdns will fallback to trust-anchors obtained via built-in
***  trust anchor management when the anchors from the default
***  location fail to validate the root DNSKEY rrset.
***
***  To prevent expired DNSSEC trust anchors to be used for
***  validation, we strongly recommend removing the trust anchors
***  on the default location when there is no active external
***  trust anchor management keeping it up-to-date.
***
staf@stretch:~/github/getdns/build$ sudo make install
```

##### systemd service

Stubby comes with a systemd service definition. Copy it to the correct location.

```
staf@stretch:~/github/getdns/build$ cd ..
staf@stretch:~/github/getdns$ cd stubby/systemd/
staf@stretch:~/github/getdns/stubby/systemd$ sudo cp stubby.service /lib/systemd/system/
```

Update the path to /usr/local

```
staf@stretch:~/github/getdns/stubby/systemd$ sudo vi /lib/systemd/system/stubby.service
```

```
[Unit]
Description=stubby DNS resolver

[Service]
User=stubby
DynamicUser=yes
CacheDirectory=stubby
WorkingDirectory=/var/cache/stubby
ExecStart=/usr/local/bin/stubby
AmbientCapabilities=CAP_NET_BIND_SERVICE
CapabilityBoundingSet=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
```

And create the stubby working directory

```
root@stretch:~# mkdir /var/cache/stubby
```

#### ldconfig

update your library cache

```
staf@stretch:~/github/getdns/stubby/systemd$ sudo ldconfig -v
```

#### Update the configuration

Edit the stubby.yml configuration file.

```
staf@stretch:~/github/getdns/stubby/systemd$ sudo nvi /usr/local/etc/stubby/stubby.yml
```

Update the port where stubby will listen to and select the upstream dns service you want to use.

```
listen_addresses:
  - 127.0.0.1@53000
  - 0::1@53000
```

#### start and test 

Start stubby....

```
staf@stretch:~/github/getdns/stubby/systemd$ sudo systemctl list-unit-files | grep -i stubby
stubby.service                              disabled
staf@stretch:~/github/getdns/stubby/systemd$ sudo systemctl enable stubby
Created symlink /etc/systemd/system/multi-user.target.wants/stubby.service /lib/systemd/system/stubby.service.
staf@stretch:~/github/getdns/stubby/systemd$ sudo systemctl start stubby
staf@stretch:~/github/getdns/stubby/systemd$ 
```

and test it

```
root@stretch:~# dig @127.0.0.1 -p 53000 www.wagemakers.be

; <<>> DiG 9.10.3-P4-Debian <<>> @127.0.0.1 -p 53000 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 17510
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      49704   IN      CNAME   wagemakers.be.
wagemakers.be.          81815   IN      A       95.215.185.144

;; Query time: 72 msec
;; SERVER: 127.0.0.1#53000(127.0.0.1)
;; WHEN: Sun Sep 02 10:33:53 CEST 2018
;; MSG SIZE  rcvd: 119

root@stretch:~# 
```

#### dnsmasq

Install dnsmasq

```
root@stretch:/etc# apt-get install dnsmasq
```

Configure dnsmasq

```
root@stretch:/etc# mv dnsmasq.conf dnsmasq.conf_org
root@stretch:/etc# vi dnsmasq.conf
```

```
server=127.0.0.1#53000
listen-address=127.0.0.1
interface=lo
bind-interfaces
```

Enable and start it...

```
root@stretch:/etc# systemctl enable dnsmasq
Synchronizing state of dnsmasq.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable dnsmasq
root@stretch:/etc# systemctl restart dnsmasq
```

Verify

```
root@stretch:/etc# dig @127.0.0.1 www.wagemakers.be

; <<>> DiG 9.10.3-P4-Debian <<>> @127.0.0.1 www.wagemakers.be
; (1 server found)
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 57295
;; flags: qr rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 0, ADDITIONAL: 1

;; OPT PSEUDOSECTION:
; EDNS: version: 0, flags:; udp: 4096
;; QUESTION SECTION:
;www.wagemakers.be.             IN      A

;; ANSWER SECTION:
www.wagemakers.be.      48645   IN      CNAME   wagemakers.be.
wagemakers.be.          80756   IN      A       95.215.185.144

;; Query time: 72 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Sun Sep 02 10:51:32 CEST 2018
;; MSG SIZE  rcvd: 119

root@stretch:/etc# 
```

reconfigure you system to use dnsmasq....

```
root@stretch:/etc# nvi resolv.conf
```

```
nameserver 127.0.0.1
```

***Have fun!***

## Links

* [https://dnsprivacy.org](https://dnsprivacy.org)
* [https://wiki.archlinux.org/index.php/Stubby](https://wiki.archlinux.org/index.php/Stubby)
