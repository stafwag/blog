---
layout: post
title: "Keep zfs running on the Raspberry PI"
date: 2020-08-03 19:45:50 +0200
comments: true
categories: [ rpi4, manjaro, raspberrypi, zfs, openzfs, kernel, linux ] 
excerpt_separator: <!--more-->
---

I got a Raspberry PI 4 to play with and [installed Manjaro GNU/Linux on it](https://stafwag.github.io/blog/blog/2020/07/12/manjaro-on-rpi4-full-disk-encryption/).

I use [OpenZFS](https://openzfs.org) on my PI. The latest kernel update broken zfs on PI due to a License conflict, the solution is to disable ```PREEMPT``` in the kernel config. This BUG was already resolved with OpenZFS with the main Linux kernel tree at least on [X86_64/AMD64](https://en.wikipedia.org/wiki/X86-64#AMD64), not sure why the kernel on the raspberry pi is still affected.

I was looking for an excuse to build a custom for my Pi anyway :-). I cloned the default manjaro RPI4 kernel and disabled ```PREEMPT``` in the kernel ```config```.

The package is available at: [https://gitlab.com/stafwag/manjaro-linux-rpi4-nopreempt](https://gitlab.com/stafwag/manjaro-linux-rpi4-nopreempt). This package also  doesn’t update ```/boot/config.txt``` and ```/boot/cmdline.txt``` to not overwrite custom settings.

***Have fun!***
