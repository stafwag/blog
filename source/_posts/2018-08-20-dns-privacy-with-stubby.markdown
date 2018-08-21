---
layout: post
title: "DNS Privacy with Stubby"
date: 2018-08-20 12:30:03 +0200
comments: true
categories: [security, privacy, linux, freebsd, dns]  
---

*** Installing and configuring an encrypted dns server is straightforward and there is no reason to use an unencrypted dns service. ***

## DNS is not secure or private

DNS traffic is insecure and runs over [UDP](https://nl.wikipedia.org/wiki/User_Datagram_Protocol) port 53 ([TCP](https://en.wikipedia.org/wiki/Transmission_Control_Protocol) for [zone transfers](https://en.wikipedia.org/wiki/DNS_zone_transfer) ) unecrypted by default.

This make your encrypted DNS traffic a **privacy risk** and a **security risk**: 

* anyone that is able to sniff your network traffic can collect a lot information from your leaking DNS information.
* with a DNS spoofing attack an attacker can trick you let go to malicious website or try to intercept your email traffic.


## Encrypt your dns traffic

Encrypting your network traffic is always a good idea for privacy and security reasons - *** we encrypt, because we can! *** -  .
More information about dns privacy can be found at [https://dnsprivacy.org/](https://dnsprivacy.org/)

On this site you'll find also the [DNS Privacy Daemon - Stubby](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby) that let's you send your DNS request over TLS to an alternative DNS provider. You should use a DNS provider that you trust and has a no logging policy.  [quad9](https://www.quad9.net/), [cloudflare](https://www.cloudflare.com/learning/dns/what-is-1.1.1.1/) and google dns are well-known alternative dns providers. At [https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Test+Servers) you can find a few other options.

You'll find my journey to setup Stubby on a few operation systems I use (or I'm force to use) ...

## Linux

### Arch Linux

I use Arch Linux on my main workstation. Stubby is already in the Arch repositories this make installation straightforward.

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
no-resolv
proxy-dnssec
server=127.0.0.1#53000
listen-address=127.0.0.1
```

#### Configure your system

reconfigure your system to use dnsmasq as the dns service.



## Links

* [https://wiki.archlinux.org/index.php/Stubby](https://wiki.archlinux.org/index.php/Stubby)

