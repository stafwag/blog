---
layout: post
title: "Ide is still alive..."
date: 2013-08-10 14:26
comments: true
categories: [sun, sun blade 1500, solaris, ide, sata, solaris, opensxce] 
---
<img src="{{ '/images/sta2ide_0.jpg'  | relative_url }}" class="right" width="195" height="192" alt="sta2ide" /> 
<p>
The dvd drive in my <a href="http://en.wikipedia.org/wiki/Sun_Blade_(workstation)">sun blade 1500 workstation</a> broke down. I use this system acausally for some development, it's always handy to have a <a href="http://en.wikipedia.org/wiki/Endianness">big endian</a> system at hand.<br /><br />
</p>
The dvd drive was still handy to load another operating system on it.<br />The dvd drive has an <a href="http://en.wikipedia.org/wiki/Integrated_Drive_Electronics">ide interface</a> which are hard to get these days...<br /><br />
<img src="{{ '/images/sata_dvd_0.jpg'  | relative_url }}" class="left" width="326" height="245" alt="dvd"/>
<p>
I found a <a href="http://www.conrad.be/ce/nl/product/974497/IDE-naar-SATA-converter/SHOP_AREA_37572">ide to sata convertor</a> and a <a href="http://www.conrad.be/ce/nl/product/417054/Samsung-DVD-ROM-SATA-SH-118ABBEBE-bulk/SHOP_AREA_17682">new dvd drive</a> with a <a href="http://en.wikipedia.org/wiki/Serial_ATA">sata interface</a> at <a href="http://www.conrad.be">conrad</a>. This should convert the sata interface to an ide interface without any driver and works with any operating system.<br /><br />Well let's put this to a test on a <a href="http://en.wikipedia.org/wiki/SPARC">sparc</a> system with <a href="http://en.wikipedia.org/wiki/Solaris_%28operating_system">solaris</a> :-)<br /><br />
</p>
<img src="{{ '/images/sata2dvdondvd_0.jpg'  | relative_url }}" class="right" width="196" height="87" alt="on"/>
<p>
The installation was pretty straightforward, luckily the dvd rom drive has a plastic back since the converter touches the back of the dvd rom drive.<br /><br />  
</p>
<img src="{{ '/images/sun1500_alive_0.jpg'  | relative_url }}" class="right" width="326" height="244" alt="sun"/>
<p>
After a quick test it seems to work like a charm. I might install <a href="http://www.opensxce.org">opensxce</a> on it.<br /><br />It seems to be the only option to run an <a href="http://en.wikipedia.org/wiki/OpenSolaris">opensolaris</a> ancestor on sparc hardware.</p>
