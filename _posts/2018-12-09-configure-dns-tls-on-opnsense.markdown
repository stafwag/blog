---
layout: post
title: "How to configure DNS-over-TLS on OPNsense"
date: 2018-12-09 09:11:38 +0200
comments: true
categories: [ freebsd, opnsense, security, dns, unbound, stubby, dnsmasq ] 
---

# DNS-over-TLS

In my [previous blog posts](https://stafwag.github.io/blog/blog/2018/09/09/dns-privacy-with-stubby-part1-gnulinux/) we configured [Stubby ](https://dnsprivacy.org/wiki/display/DP/DNS+Privacy+Daemon+-+Stubby) on GNU/Linux and FreeBSD.

<img src="{{ '/images/Logo_OPNsense.jpg'  | absolute_url }}" class="right" width="300" height="85" alt="Logo_OPNsense.jpg" /> 

In this blog article we'll configure [DNS-over-TLS](https://en.wikipedia.org/wiki/DNS_over_TLS) with [Unbound](https://nlnetlabs.nl/projects/unbound/about/) on [OPNsense](https://opnsense.org/). Both [Stubby](https://nlnetlabs.nl/projects/getdns/) and [Unbound](https://nlnetlabs.nl/projects/unbound/about/) are written by [NLnet](https://nlnet.nl/).

## DNS resolvers

Stubby is a small dns resolver to encrypt your dns traffic, which makes it perfect to increase end-user privacy. Stubby can be integrated into existing dns setups.

[DNSmasq](http://http://www.thekelleys.org.uk/dnsmasq/doc.html) is small dns resolver that can cache dns queries and forward dns traffic to other dns servers.

Unbound is fast validating, caching DNS resolver that supports DNS-over-TLS.
Unbound or dnsmaq are not full feature dns servers like [BIND](https://www.isc.org/downloads/bind/).

The main difference beteen Unbound and DNSmasq is that Unbound can talk the the [root servers](https://www.iana.org/domains/root/servers) directly while dnsmasq always needs to forward your dns queries to another dns server - your ISP dns server or a public dns servicve like ([Quad9](https://www.quad9.net/), [cloudfare](https://1.1.1.1/), [google](https://developers.google.com/speed/public-dns/), ...) -

Unbound has build-in support for DNS-over-TLS. DNSmasq needs an external DNS-over-TLS resolver like Stubby.

## Which one to use? 

It depends - as always -, Stubby can integrating easily in existing dns setups like dnsmasq. Unbound is one package that does it all and is more feature rich compared to DNSmasq.

# OPNsense

I use [OPNsense](https://opnsense.org/) as my firewall. Unbound is the default dns resolver on OPNsense so it makes (OPN)sense to use Unbound. 

## Choose your upstream DNS service


There're a few public DNS providers that supports DNS-over-tls the best known are [Quad9](https://www.quad9.net/), [cloudfare](https://1.1.1.1/). Quad9 will block malicious domains on the default dns servers 9.9.9.9/149.112.112.10 while 9.9.9.10 has no security blocklist. 

In this article we'll use Quad9 but you could also with cloudfare or another dns provider that you trust and has support for DNS-over-tls.


## Enable DNS-over-TLS

<a href="{{ '/images/opnsense_enable_dns_tls.png' | absolute_url }}"><img src="{{ '/images/opnsense_enable_dns_tls.png' | relative_url }}" class="left" width="300" height="458" alt="opnsense_enable_dns_tls.png" /> </a>

You need to configure your firewall to use your upstream dns provider. You also want to make sure your isp dns servers aren't used.

### Sniffing

 If you snif the DNS traffic on your firewall ```tcpdump -i wan_interface udp port 53``` you'll see that the DNS traffic is unencrypted.

### Configuration

To enable DNS-over-TLS we'll need to reconfigure unbound.

Go to ** [ Services ] -> [Unbound DNS ] -> [General] **
And copy/paste the setting below  


```
server:
forward-zone:
name: "."
forward-ssl-upstream: yes
forward-addr: 9.9.9.9@853
forward-addr: 149.112.112.112@853
```

to ** Custom options ** these settings will reconfigure Unbound to forward the dns for the upstream dns servers Quad9 over ssl.

### Verify

If you snif the udp  traffic on you firewall  with ```tcpdump -i wan_interface udp port 53``` you'll not see any unencrypted traffic anymore - unless not all your clients are configured to use your firewall as the dns server -.

If your snif TCP PORT 853 ```tcpdump -i vr1 tcp port 853``` we'll see your encrypted dns-over-tls traffic.

## General DNS settings

You also want to make sure that your firewall isn't configure to use an unecrypted DNS server.

<a href="{{ '/images/opnsense_set_dns.png' | absolute_url }}"><img src="{{ '/images/opnsense_set_dns.png' | relative_url }}" class="right" width="300" height="693" alt="opnsense_set_dns.png" /> </a>

### Configuration

Go to **[ system ] -> [ settings ] -> [ general ]** and set the dns servers also make sure that ** [ ] Allow DNS server list to be overridden by DHCP/PPP on WAN ** is unchecked. 

### Verify

You can verify the configuration by logging on to your firewall over ssh and reviewing the contents of /etc/resolv.conf.


*** Have fun! ***

# Links

* [https://nlnetlabs.nl/projects/unbound/](https://nlnetlabs.nl/projects/unbound/)
* [https://forum.opnsense.org/index.php?topic=7814.0](https://forum.opnsense.org/index.php?topic=7814.0)
* [https://news.ycombinator.com/item?id=17944423](https://news.ycombinator.com/item?id=17944423)
* [https://forum.opnsense.org/index.php?topic=9197.msg41265#msg41265](https://forum.opnsense.org/index.php?topic=9197.msg41265#msg41265
* [https://www.netgate.com/blog/dns-over-tls-with-pfsense.html](https://www.netgate.com/blog/dns-over-tls-with-pfsense.html)
* [https://forum.opnsense.org/index.php?topic=9197.msg41265#msg41265](https://forum.opnsense.org/index.php?topic=9197.msg41265#msg41265)
* [https://www.quad9.net/faq/](https://www.quad9.net/faq/)
