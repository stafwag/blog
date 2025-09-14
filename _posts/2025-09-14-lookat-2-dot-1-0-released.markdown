---
layout: post
title: "Lookat 2.1.0 released"
date: 2025-09-14 19:04:00 +0100
comments: true
categories: [ lookat, linux, bsd, freebsd, netbsd, openbsd, ncurses, manpage ]
excerpt_separator: <!--more-->
---

<a href="{{ '/images/lookat/lookat_2_1_0.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/lookat/lookat_2_1_0.png' | remove_first:'/' | absolute_url }}" class="right" width="600" height="320" alt="lookat 2.1.0" /> </a>

Lookat 2.1.0 is the latest stable release of Lookat/Bekijk, a user-friendly Unix file browser/viewer that supports colored man pages.

The focus of the 2.1.0 release is to add ANSI Color support.

<br />&nbsp;<br />

## News

### **14 Sep 2025** Lookat 2.1.0 Released

Lookat / Bekijk 2.1.0rc2 has been released as Lookat / Bekijk 2.1.0

### **3 Aug 2025** Lookat 2.1.0rc2 Released

Lookat 2.1.0rc2 is the second release candicate of Lookat 2.1.0

#### ChangeLog

##### Lookat / Bekijk 2.1.0rc2

 * Corrected italic color
 * Don't reset the search offset when cursor mode is enabled
 * Renamed strsize to charsize ( ansi_strsize -> ansi_charsize, utf8_strsize -> utf8_charsize) to be less confusing
 * Support for multiple ansi streams in ansi_utf8_strlen()
 * Update default color theme to green for this release
 * Update manpages & documentation
 * Reorganized contrib directory
   * Moved ci/cd related file from contrib/* to contrib/cicd
   * Moved debian dir to contrib/dist
   * Moved support script to contrib/scripts

<!--more-->

#### Lookat 2.1.0 is available at:

* [https://www.wagemakers.be/english/programs/lookat/](https://www.wagemakers.be/english/programs/lookat/)
* Download it directly from [https://download-mirror.savannah.gnu.org/releases/lookat/](https://download-mirror.savannah.gnu.org/releases/lookat/)
* Or at the Git repository at GNU savannah [https://git.savannah.gnu.org/cgit/lookat.git/](https://cgit.git.savannah.gnu.org/cgit/lookat.git/)

***Have fun!***
