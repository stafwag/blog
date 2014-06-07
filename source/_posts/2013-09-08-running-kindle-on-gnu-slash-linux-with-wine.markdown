---
layout: post
title: "Running kindle on GNU/Linux with wine"
date: 2013-09-08 11:57
comments: true
categories: [ kndle, wine, linux, fedora ] 
---

{% img left /images/i7_desktop.jpg 400 300 "desktop" %} 

I enjoy reading <a href="http://en.wikipedia.org/wiki/E-book">ebooks</a> during my train trip to work on <a href="http://en.wikipedia.org/wiki/Nexus_7_(2012_version)">my nexus 7</a>.

At home I prefer to read on my monitor since this is bigger.

Most of the time I use <a href="http://en.wikipedia.org/wiki/EPUB">epub</a> or <a href="http://en.wikipedia.org/wiki/Pdf">pdf</a> for reading, I bought a <a href="https://kindle.amazon.com/">kindle</a> version of a book from <a href="http://www.amazon.com">amazon</a> assuming that I could read with <a href="https://read.amazon.com/">amazon cloud reader</a> at home.

Unfortunately this books is not compatible with cloud reader. 

<strong>
<a href="http://en.wikipedia.org/wiki/Proprietary_format">Proprietary_formats</a> should be avoid, lesson learned (again). 
</strong>

To read my book at home I decided to give <a href="http://www.amazon.com/gp/feature.html/ref=kcp_pc_ln_ar?docId=1000426311"</a> the windows version of kindle</a> on <a href="http://www.winehq.org/">wine</a> a try

The installation was pretty straightforward on <a href="http://fedoraproject.org/">Fedora 19</a>.


* Install wine

```
[root@vicky ~]# yum install wine
Loaded plugins: langpacks, refresh-packagekit

```

* Download Kindle for Window xp

Download it from: <a href="http://www.amazon.com/gp/feature.html/ref=kcp_pc_ln_ar?docId=1000426311">http://www.amazon.com/gp/feature.html/ref=kcp_pc_ln_ar?docId=1000426311</a>


* Run the installer

```
[swagemakers@vicky ~]$ wine ~/Downloads/KindleForPC-installer.exe 
```

* Create kindle startup script 

```
wine $HOME/.wine/drive_c/Program\ Files\ \(x86\)/Amazon/Kindle/Kindle.exe &
```

>
> Happy reading
>
> but

<strong>
It's better to only read ebooks in an <a href="http://en.wikipedia.org/wiki/Open_format">open format</a>
</strong>
