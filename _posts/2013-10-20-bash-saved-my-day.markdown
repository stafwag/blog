---
layout: post
title: "bash saved my day"
date: 2013-10-20 10:04
comments: true
categories: [ bash, squid, puppet, git ] 
---

I was creating an ugly quick-and-dirty script to setup the <a href="http://www.squid-cache.org/">squid</a> cache_dir automatically with <a href="http://puppetlabs.com/">puppet</a> based on the diskspace and memory available.


When you are developing you sometimes forget to create backups and push it to git, and mistakes are around the corner.

Lucky <a href="http://www.gnu.org/software/bash/">bash</a> saved my day!


```
$ ./create_cache_entries.sh  > create_cache_entries.sh 
-bash: ./create_cache_entries.sh: /bin/bash: bad interpreter: Text file busy
$ vi create_cache_entries.sh 
```
