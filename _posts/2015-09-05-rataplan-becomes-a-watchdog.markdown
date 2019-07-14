---
layout: post
title: "Rataplan becomes a watchdog"
date: 2015-09-05 14:47:54 +0200
comments: true
categories: freebsd  
---

<img src="{{ '/images/watchdog_rataplan.jpg'  | relative_url }}" class="left" />
<a href="http://stafwag.github.io/blog/blog/2012/12/16/running-freebsd-9.0-on-asus-c60m1-i-motherboard/">My NAS</a> runs on <a href="http://www.freebsd.org">FreeBSD</a> I'm quiet happy with it. It's named after the dog <a href="https://nl.wikipedia.org/wiki/Rataplan">rataplan</a> from the <a href="https://en.wikipedia.org/wiki/Lucky_Luke">Lucky Luke comic</a>

However transferring large data files to it causes the network to hang. The realtek network interface had issues with freebsd from the <a href="http://stafwag.github.io/blog/blog/2012/12/16/running-freebsd-9.0-on-asus-c60m1-i-motherboard/">beginning</a>. On the screen and in syslog the entry "re0: watchdog timeout" is printed.

Most FreeBSD people recommends to use Intel nics, I ordered <a href="http://www.dx.com/nl/p/winyao-wy574t-intel-wg82574l-chipset-pci-e-x1-server-gigabit-network-card-adapter-green-280966">a new Intel nic at dx.com</a>. After the installation of the new NIC the network seems to be stable again.


