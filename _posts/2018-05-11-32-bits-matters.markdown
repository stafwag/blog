---
layout: post
title: "32 bits matters!"
date: 2018-05-11 09:08:17 +0200
comments: true
categories: [ opnsense, pfsense, pcengines, duckdns ] 
excerpt_separator: <!--more-->
---

{% img right /blog/images/32bits_opnsense.jpg 500 411 "32bits_opnsense.jpg" %} 

### pfsense 2.3

My firewall is a <a href="https://pcengines.ch/">pcengines</a> <a href="https://pcengines.ch/alix2d13.htm">alix</a>.

It was running <a href="https://www.pfsense.org">pfsense</a> and was quite happy about it. Pfsense dropped support for 32 bits in their <a href="https://doc.pfsense.org/index.php/Does_pfSense_support_64_bit_systems">pfsense 2.4 release</a>.

This would left me with a unsupported firewall which was one of the reasons to use pfsense instead of a closed source commercial router.

I could have moved to a new firewall like the <a href="https://pcengines.ch/apu.htm">pcengines apu</a> but there is no reason to replace hardware that works fine.

The nice thing about opensource software is that we've options to choose from if software doesn't match your usecase we've other options to choose from. 

### OPNsense
<!--more-->

So I decided to give <a href="https://opnsense.org/">opnsense</a> a try. OPNsense is a fork of pfsense, both are a fork of <a href="https://m0n0.ch/wall/index.php">m0n0wall</a>.

{% img left /blog/images/opnsense_swapspace.png 500 584 "opnsense_swapspace.png" %}

#### swapspace

My firewall only has 256 MB of memory which is a bit low even for a firewall.

The OPNsense developers made it very easy to add swapspace from the GUI. To add swap space go to [ System ] > [ Miscellaneous ] and activate the [ Add a 2 GB swap file to the system ] checkbox.

I'm verify satisfied with the upgrade from pfsense to OPNsense, OPNsense has a new release very month which is nice to get the latest security updates and it's possible to audit the systems for security updates from the GUI.

{% img right /blog/images/duckdns_icon.png 150 150 "duckdns" %}

### DuckDns

I move my ADSL with a fixed ip address to a VDSL line with a dynamic ip address so I was looking a good free dynamic dns provider and settled with <a href="https://www.duckdns.org/">duckdns</a>.

*** Have fun ***


