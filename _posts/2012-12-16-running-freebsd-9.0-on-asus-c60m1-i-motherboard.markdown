---
layout: post
title: "Running Freebsd 9.0 on Asus C60M1-i motherboard"
date: 2012-12-16 12:06
comments: true
categories: freebsd
---

<img src="{{ '/images/P_500.jpg'  | remove_first:'/' | absolute_url }}" class="left" width="250" height="250" alt="RIP"/>

As my file and backup system pluto <a href="http://stafwag.github.io/blog/blog/2012/12/11/rip-pluto/">died</a> i'm building a new one.

This system will run <a href="http://www.freebsd.org">Freebsd</a> mainly for the <a href="http://en.wikipedia.org/wiki/ZFS">ZFS</a> filesystem.

The motherbord will be a <a href="http://www.asus.com/Motherboards/AMD_CPU_on_Board/C60M1I/">Asus C60M1-I</a>. The cpu may not have not enough horsepower for deplucation at full speed but it has 6 sata ports which is not common on a mini ITX motherbord. I will reuse my old harddrives and add or replace them when I need more storage.

The freebsd 9.0 installation with <a href="http://wiki.freebsd.org/RootOnZFS/GPTZFSBoot/9.0-RELEASE">ZFS root</a> went well but the network adapter a Realtek 8111F isn't supported by Freebsd 9.0. After checking google I found <a href="http://markmail.org/message/2w67d2nnx65bprqc#query:+page:1+mid:4h3efjpkq6bzxoyo+state:results">this</a> on the freebsd-net mailinglist.

The realtek f8111F is supported in the latest driver code, after rebuilding my kernel the network adapter works fine. Very useful on a NAS ;-)




