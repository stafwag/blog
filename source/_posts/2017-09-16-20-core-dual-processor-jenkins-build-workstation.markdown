---
layout: post
title: "20 core Dual Processor jenkins build workstation"
date: 2017-09-16 14:29:51 +0200
comments: true
categories: [ Xeon, Jenkins,Linux, BSD, Solaris ] 
---

{% img left /images/201709_xeon_cpu_side.jpg 400 388 "Xeon CPU Side" %} 

<br />

My jenkins builds are taking too long mainly due the lack of memory. I mainly use jenkins to verify that my software work on different operation systems (GNU/Linux distributions / *BSD / Solaris).

Looking for a solution that is still affordable I ended up with building a dual Xeon workstation. CPU and memory comes from <a href="http://www.ebay.be">www.ebay.be</a>

<br />&nbsp;<br />
<br />

### Part list:

* **CPU:** 2 \* <a href=\"http://ark.intel.com/products/75272/Intel-Xeon-Processor-E5-2660-v2-25M-Cache-2_20-GHz\">Intel Xeon E5-2660v2</a> This CPU has 10 cores and 20 thread, so I get 40 threads.
* **Motherboard:** <a href="http://www.asrockrack.com/general/productdetail.asp?Model=EP2C602-4L/D16#Specifications">Asrock EP2C602-4L/D16</a> I choose this motherboard because it has a lot of DIMM slots so I can upgrade the memory in the further. Downside is that layout is SSI EEB that limits the case choose.
* **Memory:** 4 \* SAMSUNG M393B2G70BH0-CK0 16GB which gives me 64 GB <a href="https://en.wikipedia.org/wiki/ECC_memory">ECC memory</a> 
* **CPU Cooler** 2 \* <a href="http://www.thermaltake.com/products-model.aspx?id=C_00002470">Thermaltake Water 3.0 Performer C</a> For the first I used watercooling mainly because I wanted to make sure that the cooling will not block the access to the DIMM slots.
* **PSU:** <a href="https://seasonic.com/product/focus-plus-750-gold/">Seasonic FOCUS Plus 750 Gold</a> I needed a power supply with 2 \* 8 pins CPU connectors.
* **Case:** <a href="http://www.phanteks.com/Enthoo-Pro.html">Phanteks Enthoo Pro</a> This case supports SSI EEB and is not too expensive.

### Pictures

[![Xeon CPU side](/images/201709_xeon_cpu_side.jpg =300x291)](/images/201709_xeon_cpu_side.jpg)
[![Xeon CPU side](/images/201709_xeon_hd_side.jpg =317x291)](/images/201709_xeon_hd_side.jpg)
[![Xeon CPU side](/images/201709_xeon_front_side.jpg =151x291)](/images/201709_xeon_front_side.jpg)

***Still need to verify if jenkins works on this system :-) ***

