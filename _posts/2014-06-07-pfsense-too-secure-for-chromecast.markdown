---
layout: post
title: "pfsense: too secure for chromecast"
date: 2014-06-07 21:05
comments: true
categories: [ chromecast, pfsense ] 
---
<img src="{{ '/images/too_secure2cast.png'  | relative_url }}" class="right" width="800" height="424" alt="toosecure2cast" /> 

My internet firewall is a <a href="http://www.pcengines.ch/">pcengines</a> <a href="http://www.pcengines.ch/alix.htm">alix system</a> powered by <a href="https://www.pfsense.org/">pfsense</a>.

I purchased a <a href="http://www.google.be/intl/en/chrome/devices/chromecast/">chromecast</a> at <a href="http://www.amazon.de">amazon.de</a>. The installation didn't work, after debugging the issue it seems that "Allow intra-BSS communication" needs to be enabled for chromecast.

