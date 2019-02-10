---
layout: post
title: "How to install libreboot on a ThinkPad W500"
date: 2019-01-26 12:17:46 +0100
comments: true
categories: [ "thinkpad", "libreboot", "raspberry-pi", "bios", "w500", "flashrom" ]
---


{% img right /images/libreboot_w500_with_pi.jpg 500 333 "libreboot_w500_with_pi.jpg" %} 

I got a [Lenovo Thinkpad W500](https://en.wikipedia.org/wiki/ThinkPad_W_series#W500) from [www.2dehands.be](http://www.2dehands.be) for a nice price.

Actually, I got it a couple of months back but I didn't have time to play with it and it took some time to get some parts from [Aliexpress](https://www.aliexpress.com).

 The Thinkpad W500 is probably one the most powerful systems that's compatible with [Libreboot](https://www.libreboot.org), it has a nice high-resolution display with a 1920 x 1200 resolution which is even a higher screen resolution than the [Full HD resolution](https://en.wikipedia.org/wiki/1080p) used on most new laptops today.

# Security

Keep in mind that the [core duo CPU](https://en.wikipedia.org/wiki/Intel_Core#Core_2_Duo) does not get [microcode updates from Intel](https://www.extremetech.com/computing/266884-intel-wont-patch-older-cpus-to-resolve-spectre-flaws) for [spectre and meltdown](https://en.wikipedia.org/wiki/Meltdown_(security_vulnerability). There is no solution (currently) for [spectre 3a - Rogue   System Register Read - CVE-2018-3640](https://nvd.nist.gov/vuln/detail/CVE-2018-3640) and [ Spectre 4 - Speculative Store Bypass CVE-2018-3639](https://nvd.nist.gov/vuln/detail/CVE-2018-3639) without a microcode update.

[Binary blobs](https://en.wikipedia.org/wiki/Binary_blob) are bad. Having a closed source binary-only piece of software on your system is not only unacceptable for [Free Software activists](https://en.wikipedia.org/wiki/Free_software_movement) it also makes it more difficult to review what it really does and makes it more difficult to review it for security concerns.

Having your system vulnerable is also a bad thing of course. Can't wait to get a computer systems with an open CPU architecture like [RISC-V](https://en.wikipedia.org/wiki/RISC-V).

# EC update

It's recommented to update your current BIOS to get the lastest [EC firmware](https://libreboot.org/faq.html#ec-embedded-controller-firmware). My system had a cdrom and I updated the BIOS with the CDROM drive.

# Prepare the Raspberry-pi

It isn't possible to flash the BIOS with software only on the Lenovo W500/T500, it's required to put a clip on your BIOS chip and flash the new BIOS with [flashrom](https://www.flashrom.org/). I used a [Raspberry Pi 1 model B](https://www.raspberrypi.org/products/raspberry-pi-1-model-b-plus/) with [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) to flash Libreboot .

## Enable the SPI port

The [SPI port](https://en.wikipedia.org/wiki/Serial_Peripheral_Interface) isn't enabled by default on Raspbian, so we'll need to enable it. 

Open /boot/config.txt with your favortite text editor.

```
root@raspberrypi:~# cd /boot/
root@raspberrypi:/boot# ls
bcm2708-rpi-0-w.dtb     bcm2710-rpi-3-b.dtb       config.txt     fixup_x.dat       LICENSE.oracle  start_x.elf
bcm2708-rpi-b.dtb       bcm2710-rpi-3-b-plus.dtb  COPYING.linux  issue.txt         overlays
bcm2708-rpi-b-plus.dtb  bcm2710-rpi-cm3.dtb       fixup_cd.dat   kernel7.img       start_cd.elf
bcm2708-rpi-cm.dtb      bootcode.bin              fixup.dat      kernel.img        start_db.elf
bcm2709-rpi-2-b.dtb     cmdline.txt               fixup_db.dat   LICENCE.broadcom  start.elf
root@raspberrypi:/boot# vi config.txt 
```

and uncomment ```dtparam=spi=on```

```
# Uncomment some or all of these to enable the optional hardware interfaces
#dtparam=i2c_arm=on
#dtparam=i2s=on
dtparam=spi=on
```

and reboot. And the reboot the SPI interface ```/dev/spidev*``` will be available.


```
root@raspberrypi:~# ls -l /dev/spidev*
crw-rw---- 1 root spi 153, 0 Jan 26 20:08 /dev/spidev0.0
crw-rw---- 1 root spi 153, 1 Jan 26 20:08 /dev/spidev0.1
root@raspberrypi:~# 
```
## Install the required software
### flashrom

```
root@raspberrypi:~# sudo apt-get install build-essential pciutils usbutils libpci-dev libusb-dev libftdi1 libftdi-dev zlib1g-dev subversion libusb-1.0-0-dev
Reading package lists... Done
Building dependency tree       
Reading state information... Done
build-essential is already the newest version (12.3).
usbutils is already the newest version (1:007-4).
zlib1g-dev is already the newest version (1:1.2.8.dfsg-5).
zlib1g-dev set to manually installed.
The following additional packages will be installed:
  libapr1 libaprutil1 libserf-1-1 libsvn1 libudev-dev libusb-1.0-doc
Suggested packages:
  db5.3-util subversion-tools
The following NEW packages will be installed:
  libapr1 libaprutil1 libftdi-dev libftdi1 libpci-dev libserf-1-1 libsvn1 libudev-dev libusb-1.0-0-dev
  libusb-1.0-doc libusb-dev pciutils subversion
0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
Need to get 3,203 kB of archives.
After this operation, 14.5 MB of additional disk space will be used.
Do you want to continue? [Y/n] 
Get:1 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf libudev-dev armhf 232-25+deb9u8 [91.7 kB]
<snip>
Setting up libapr1:armhf (1.5.2-5) ...
Setting up libusb-1.0-doc (2:1.0.21-1) ...
Setting up libftdi1:armhf (0.20-4) ...
Setting up libusb-dev (2:0.1.12-30) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Setting up libftdi-dev (0.20-4) ...
Setting up libaprutil1:armhf (1.5.4-3) ...
Setting up libusb-1.0-0-dev:armhf (2:1.0.21-1) ...
Setting up pciutils (1:3.5.2-1) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up libudev-dev:armhf (232-25+deb9u8) ...
Setting up libserf-1-1:armhf (1.3.9-3+deb9u1) ...
Setting up libsvn1:armhf (1.9.5-1+deb9u3) ...
Setting up libpci-dev (1:3.5.2-1) ...
Setting up subversion (1.9.5-1+deb9u3) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
root@raspberrypi:~# 
```

### git

```
pi@raspberrypi:~ $ sudo apt install git
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  git-man liberror-perl
Suggested packages:
  git-daemon-run | git-daemon-sysvinit git-doc git-el git-email git-gui gitk gitweb git-arch git-cvs
  git-mediawiki git-svn
The following NEW packages will be installed:
  git git-man liberror-perl
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 4,849 kB of archives.
After this operation, 26.4 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf liberror-perl all 0.17024-1 [26.9 kB]
Get:2 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf git-man all 1:2.11.0-3+deb9u4 [1,433 kB]
Get:3 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf git armhf 1:2.11.0-3+deb9u4 [3,390 kB]
Fetched 4,849 kB in 3s (1,517 kB/s)
Selecting previously unselected package liberror-perl.
(Reading database ... 35178 files and directories currently installed.)
Preparing to unpack .../liberror-perl_0.17024-1_all.deb ...
Unpacking liberror-perl (0.17024-1) ...
Selecting previously unselected package git-man.
Preparing to unpack .../git-man_1%3a2.11.0-3+deb9u4_all.deb ...
Unpacking git-man (1:2.11.0-3+deb9u4) ...
Selecting previously unselected package git.
Preparing to unpack .../git_1%3a2.11.0-3+deb9u4_armhf.deb ...
Unpacking git (1:2.11.0-3+deb9u4) ...
Setting up git-man (1:2.11.0-3+deb9u4) ...
Setting up liberror-perl (0.17024-1) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up git (1:2.11.0-3+deb9u4) ...
pi@raspberrypi:~ $ 
```
### make

```
pi@raspberrypi:~/flashrom $ make
Replacing all version templates with p1.0-144-gd82be7b.
Checking for a C compiler... found.
Target arch is arm
Target OS is Linux
Checking for libpci headers... found.
Checking version of pci_get_dev... new version (including PCI domain parameter).
Checking if libpci is present and sufficient... yes.
Checking for libusb-0.1/libusb-compat headers... found.
Checking if libusb-0.1 is usable... yes.
Checking for libusb-1.0 headers... found.
Checking if libusb-1.0 is usable... yes.
Checking for FTDI support... found.
Checking for FT232H support in libftdi... found.
Checking if Linux MTD headers are present... yes.
Checking if Linux SPI headers are present... yes.
<snip>
```

### flashrom

```
root@raspberrypi:~# apt install flashrom
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  libftdi1-2 libpci3
The following NEW packages will be installed:
  flashrom libftdi1-2 libpci3
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 454 kB of archives.
After this operation, 843 kB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf libpci3 armhf 1:3.5.2-1 [50.9 kB]
Get:2 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf libftdi1-2 armhf 1.3-2 [26.8 kB]
Get:3 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf flashrom armhf 0.9.9+r1954-1 [377 kB]
Fetched 454 kB in 4s (108 kB/s)   
Selecting previously unselected package libpci3:armhf.
(Reading database ... 34656 files and directories currently installed.)
Preparing to unpack .../libpci3_1%3a3.5.2-1_armhf.deb ...
Unpacking libpci3:armhf (1:3.5.2-1) ...
Selecting previously unselected package libftdi1-2:armhf.
Preparing to unpack .../libftdi1-2_1.3-2_armhf.deb ...
Unpacking libftdi1-2:armhf (1.3-2) ...
Selecting previously unselected package flashrom.
Preparing to unpack .../flashrom_0.9.9+r1954-1_armhf.deb ...
Unpacking flashrom (0.9.9+r1954-1) ...
Setting up libftdi1-2:armhf (1.3-2) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up libpci3:armhf (1:3.5.2-1) ...
Setting up flashrom (0.9.9+r1954-1) ...
Processing triggers for libc-bin (2.24-11+deb9u3) ...
root@raspberrypi:~# 
```

{% img left /images/w500_flashchip.jpg 500 354 "w500_flashchip.jpg" %} 

## Wiring

### poweroff

```
root@raspberrypi:~# poweroff
Connection to pi2 closed by remote host.
Connection to pi2 closed.
[staf@vicky ~]$ 
```

## flashing

### test

```
root@raspberrypi:~# flashrom -p linux_spi:dev=/dev/spidev0.0,spispeed=512 
flashrom v0.9.9-r1954 on Linux 4.14.79+ (armv6l)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6405" (8192 kB, SPI) on linux_spi.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) on linux_spi.
Found Macronix flash chip "MX25L6406E/MX25L6408E" (8192 kB, SPI) on linux_spi.
Found Macronix flash chip "MX25L6436E/MX25L6445E/MX25L6465E/MX25L6473E" (8192 kB, SPI) on linux_spi.
Multiple flash chip definitions match the detected chip(s): "MX25L6405", "MX25L6405D", "MX25L6406E/MX25L6408E", "MX25L6436E/MX25L6445E/MX25L6465E/MX25L6473E"
Please specify which chip definition to use with the -c <chipname> option.
root@raspberrypi:~# 
```

### read old bios

#### read

```
pi@raspberrypi:~ $ sudo flashrom -c "MX25L6405D" -p linux_spi:dev=/dev/spidev0.0,spispeed=512 -r w500bios.rom
flashrom v0.9.9-r1954 on Linux 4.14.79+ (armv6l)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) on linux_spi.
Reading flash... done.
pi@raspberrypi:~ $ ls
flashrom  test.rom  w500bios.rom
pi@raspberrypi:~ $ sudo flashrom -c "MX25L6405D" -p linux_spi:dev=/dev/spidev0.0,spispeed=512 -r w500bios2.rom
flashrom v0.9.9-r1954 on Linux 4.14.79+ (armv6l)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) on linux_spi.
Reading flash... done.
pi@raspberrypi:~ $ 
```

#### compare

```
pi@raspberrypi:~ $ sha1sum w500bios*.rom
d23effea7312dbc0f2aabe1ca1387e1d047d7334  w500bios2.rom
d23effea7312dbc0f2aabe1ca1387e1d047d7334  w500bios.rom
pi@raspberrypi:~ $ 
```

### Flash libreboot

#### Download
##### Download

Download the libreboot version that matches your laptop with SHA512SUMS and SHA512SUMS.sig.

[https://libreboot.org/download.html](https://libreboot.org/download.html)

##### Verify

```
pi@raspberrypi:~ $ gpg --recv-keys 0x969A979505E8C5B2
gpg: failed to start the dirmngr '/usr/bin/dirmngr': No such file or directory
gpg: connecting dirmngr at '/run/user/1000/gnupg/S.dirmngr' failed: No such file or directory
gpg: keyserver receive failed: No dirmngr
```

```
pi@raspberrypi:~ $ sudo apt-get install dirmngr
Reading package lists... Done
Building dependency tree       
Reading state information... Done
Suggested packages:
  dbus-user-session pinentry-gnome3 tor
The following NEW packages will be installed:
  dirmngr
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 547 kB of archives.
After this operation, 963 kB of additional disk space will be used.
Get:1 http://mirror.nl.leaseweb.net/raspbian/raspbian stretch/main armhf dirmngr armhf 2.1.18-8~deb9u3 [547 kB]
Fetched 547 kB in 9s (58.3 kB/s)         
Selecting previously unselected package dirmngr.
(Reading database ... 36051 files and directories currently installed.)
Preparing to unpack .../dirmngr_2.1.18-8~deb9u3_armhf.deb ...
Unpacking dirmngr (2.1.18-8~deb9u3) ...
Processing triggers for man-db (2.7.6.1-2) ...
Setting up dirmngr (2.1.18-8~deb9u3) ...
pi@raspberrypi:~ $ 
```

```
pi@raspberrypi:~ $ gpg --recv-keys 0x969A979505E8C5B2
key 969A979505E8C5B2:
1 signature not checked due to a missing key
gpg: /home/pi/.gnupg/trustdb.gpg: trustdb created
gpg: key 969A979505E8C5B2: public key "Leah Rowe (Libreboot signing key) <info@minifree.org>" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 1
gpg:               imported: 1
pi@raspberrypi:~ $ 

```

```
pi@raspberrypi:~ $ gpg --verify SHA512SUMS.sig 
gpg: assuming signed data in 'SHA512SUMS'
gpg: Signature made Wed 07 Sep 2016 23:15:17 BST
gpg:                using RSA key 969A979505E8C5B2
gpg: Good signature from "Leah Rowe (Libreboot signing key) <info@minifree.org>" [unknown]
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: CDC9 CAE3 2CB4 B7FC 84FD  C804 969A 9795 05E8 C5B2
pi@raspberrypi:~ $ 

```

```
pi@raspberrypi:~/libreboot $ sha512sum libreboot_r20160907_grub_t500_8mb.tar.xz 
5325aef526ab6ca359d6613609a4a2345eee47c6d194094553b53996c413431bccdc345838299b347f47bcba8896dd0a6ed3f9b4c88606ead61c3725b580983b  libreboot_r20160907_grub_t500_8mb.tar.xz
pi@raspberrypi:~/libreboot $ grep sha512sum 5325aef526ab6ca359d6613609a4a2345eee47c6d194094553b53996c413431bccdc345838299b347f47bcba8896dd0a6ed3f9b4c88606ead61c3725b580983b
grep: 5325aef526ab6ca359d6613609a4a2345eee47c6d194094553b53996c413431bccdc345838299b347f47bcba8896dd0a6ed3f9b4c88606ead61c3725b580983b: No such file or directory
pi@raspberrypi:~/libreboot $ grep 5325aef526ab6ca359d6613609a4a2345eee47c6d194094553b53996c413431bccdc345838299b347f47bcba8896dd0a6ed3f9b4c88606ead61c3725b580983b SHA512SUMS
5325aef526ab6ca359d6613609a4a2345eee47c6d194094553b53996c413431bccdc345838299b347f47bcba8896dd0a6ed3f9b4c88606ead61c3725b580983b  ./rom/grub/libreboot_r20160907_grub_t500_8mb.tar.xz
pi@raspberrypi:~/libreboot $ 
```

##### extract

```
pi@raspberrypi:~/libreboot $ tar xvf libreboot_r20160907_grub_t500_8mb.tar.xz
libreboot_r20160907_grub_t500_8mb/
libreboot_r20160907_grub_t500_8mb/t500_8mb_deqwertz_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_esqwerty_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_frazerty_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_frdvbepo_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_itqwerty_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_svenska_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_ukdvorak_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_ukqwerty_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_usdvorak_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_usqwerty_txtmode.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_deqwertz_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_esqwerty_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_frazerty_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_frdvbepo_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_itqwerty_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_svenska_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_ukdvorak_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_ukqwerty_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_usdvorak_vesafb.rom
libreboot_r20160907_grub_t500_8mb/t500_8mb_usqwerty_vesafb.rom
libreboot_r20160907_grub_t500_8mb/ChangeLog
libreboot_r20160907_grub_t500_8mb/NEWS
libreboot_r20160907_grub_t500_8mb/version
libreboot_r20160907_grub_t500_8mb/versiondate
pi@raspberrypi:~/libreboot $ 
```

##### copy the image that you plan to use

```
pi@raspberrypi:~/libreboot $ cp libreboot_r20160907_grub_t500_8mb/t500_8mb_usqwerty_vesafb.rom libreboot.rom
pi@raspberrypi:~/libreboot $ 
```

#### Change MAC

##### Download the libreboot util

###### Download

```
pi@raspberrypi:~/libreboot $ wget https://www.mirrorservice.org/sites/libreboot.org/release/stable/20160907/libreboot_r20160907_util.tar.xz
--2019-01-27 08:46:32--  https://www.mirrorservice.org/sites/libreboot.org/release/stable/20160907/libreboot_r20160907_util.tar.xz
Resolving www.mirrorservice.org (www.mirrorservice.org)... 212.219.56.184, 2001:630:341:12::184
Connecting to www.mirrorservice.org (www.mirrorservice.org)|212.219.56.184|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2458736 (2.3M) [application/x-tar]
Saving to: libreboot_r20160907_util.tar.xz

libreboot_r20160907_util.tar 100%[===========================================>]   2.34M  1.65MB/s    in 1.4s    

2019-01-27 08:46:34 (1.65 MB/s) - libreboot_r20160907_util.tar.xz saved [2458736/2458736]

pi@raspberrypi:~/libreboot $ 
```

###### Verify 

```
pi@raspberrypi:~/libreboot $ sha512sum libreboot_r20160907_util.tar.xz
c5bfa5a06d55c61e5451e70cd8da3f430b5e06686f9a74c5a2e9fe0e9d155505867b0ca3428d85a983741146c4e024a6b0447638923423000431c98d048bd473  libreboot_r20160907_util.tar.xz
pi@raspberrypi:~/libreboot $ grep c5bfa5a06d55c61e5451e70cd8da3f430b5e06686f9a74c5a2e9fe0e9d155505867b0ca3428d85a983741146c4e024a6b0447638923423000431c98d048bd473 SHA512SUMS
c5bfa5a06d55c61e5451e70cd8da3f430b5e06686f9a74c5a2e9fe0e9d155505867b0ca3428d85a983741146c4e024a6b0447638923423000431c98d048bd473  ./libreboot_r20160907_util.tar.xz
pi@raspberrypi:~/libreboot $ 
```

###### Extract

```
pi@raspberrypi:~/libreboot $ tar xvf libreboot_r20160907_util.tar.xz 
libreboot_r20160907_util/
libreboot_r20160907_util/bucts/
libreboot_r20160907_util/bucts/x86_64/
libreboot_r20160907_util/bucts/x86_64/bucts
libreboot_r20160907_util/bucts/i686/
libreboot_r20160907_util/bucts/i686/bucts
libreboot_r20160907_util/flashrom/
libreboot_r20160907_util/flashrom/x86_64/
libreboot_r20160907_util/flashrom/x86_64/flashrom
libreboot_r20160907_util/flashrom/x86_64/flashrom_lenovobios_sst
libreboot_r20160907_util/flashrom/x86_64/flashrom_lenovobios_macronix
libreboot_r20160907_util/flashrom/armv7l/
libreboot_r20160907_util/flashrom/armv7l/flashrom
libreboot_r20160907_util/flashrom/i686/
libreboot_r20160907_util/flashrom/i686/flashrom
libreboot_r20160907_util/flashrom/i686/flashrom_lenovobios_macronix
libreboot_r20160907_util/flashrom/i686/flashrom_lenovobios_sst
libreboot_r20160907_util/cbfstool/
libreboot_r20160907_util/cbfstool/x86_64/
libreboot_r20160907_util/cbfstool/x86_64/cbfstool
libreboot_r20160907_util/cbfstool/i686/
libreboot_r20160907_util/cbfstool/i686/cbfstool
libreboot_r20160907_util/cbfstool/armv7l/
libreboot_r20160907_util/cbfstool/armv7l/cbfstool
libreboot_r20160907_util/ich9deblob/
libreboot_r20160907_util/ich9deblob/x86_64/
libreboot_r20160907_util/ich9deblob/x86_64/ich9deblob
libreboot_r20160907_util/ich9deblob/x86_64/ich9gen
libreboot_r20160907_util/ich9deblob/x86_64/demefactory
libreboot_r20160907_util/ich9deblob/i686/
libreboot_r20160907_util/ich9deblob/i686/ich9deblob
libreboot_r20160907_util/ich9deblob/i686/ich9gen
libreboot_r20160907_util/ich9deblob/i686/demefactory
libreboot_r20160907_util/ich9deblob/armv7l/
libreboot_r20160907_util/ich9deblob/armv7l/ich9deblob
libreboot_r20160907_util/ich9deblob/armv7l/ich9gen
libreboot_r20160907_util/ich9deblob/armv7l/demefactory
libreboot_r20160907_util/nvramtool/
libreboot_r20160907_util/nvramtool/x86_64/
libreboot_r20160907_util/nvramtool/x86_64/nvramtool
libreboot_r20160907_util/nvramtool/i686/
libreboot_r20160907_util/nvramtool/i686/nvramtool
libreboot_r20160907_util/flash
libreboot_r20160907_util/powertop.trisquel7
libreboot_r20160907_util/ChangeLog
libreboot_r20160907_util/NEWS
libreboot_r20160907_util/version
libreboot_r20160907_util/versiondate
pi@raspberrypi:~/libreboot $ 
```

######## find the ich9gen utility for architecture

find ./libreboot_r20160907_util | grep -i ich9gen

To make our live easier we will copy ich9gen binary to the directory thats hold our libreboot images.

```
pi@raspberrypi:~/libreboot $ find ./libreboot_r20160907_util | grep -i ich9gen
./libreboot_r20160907_util/ich9deblob/i686/ich9gen
./libreboot_r20160907_util/ich9deblob/armv7l/ich9gen
./libreboot_r20160907_util/ich9deblob/x86_64/ich9gen
pi@raspberrypi:~/libreboot $ cp ./libreboot_r20160907_util/ich9deblob/armv7l/ich9gen .
```

######## burn the MAC address into the rom

```
pi@raspberrypi:~/libreboot $ ./ich9gen --macaddress XX:XX:XX:XX:XX:XX
You selected to change the MAC address in the Gbe section. This has been done.

The modified gbe region has also been dumped as src files: mkgbe.c, mkgbe.h
To use these in ich9gen, place them in src/ich9gen/ and re-build ich9gen.

descriptor and gbe successfully written to the file: ich9fdgbe_4m.bin
Now do: dd if=ich9fdgbe_4m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor and gbe successfully written to the file: ich9fdgbe_8m.bin
Now do: dd if=ich9fdgbe_8m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor and gbe successfully written to the file: ich9fdgbe_16m.bin
Now do: dd if=ich9fdgbe_16m.bin of=libreboot.rom bs=1 count=12k conv=notrunc
(in other words, add the modified descriptor+gbe to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_4m.bin
Now do: dd if=ich9fdnogbe_4m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_8m.bin
Now do: dd if=ich9fdnogbe_8m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)

descriptor successfully written to the file: ich9fdnogbe_16m.bin
Now do: dd if=ich9fdnogbe_16m.bin of=yourrom.rom bs=1 count=4k conv=notrunc
(in other words, add the modified descriptor to your ROM image)
```

Insert the mac into your rom


```
pi@raspberrypi:~/libreboot $ dd if=ich9fdgbe_8m.bin of=libreboot.rom bs=12k count=1 conv=notrunc
1+0 records in
1+0 records out
12288 bytes (12 kB, 12 KiB) copied, 0.00883476 s, 1.4 MB/s
pi@raspberrypi:~/libreboot $ ls -lh libreboot.rom
-rw-r--r-- 1 pi pi 8.0M Jan 27 09:38 libreboot.rom
pi@raspberrypi:~/libreboot $ 

```

######## flash

```
pi@raspberrypi:~/libreboot $ sudo flashrom -c "MX25L6405D" -p linux_spi:dev=/dev/spidev0.0,spispeed=512 -w libreboot.rom 
flashrom v0.9.9-r1954 on Linux 4.14.79+ (armv6l)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) on linux_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... FAILED at 0x000c9f01! Expected=0x6b, Found=0xe9, failed byte count from 0x00000000-0x007fffff: 0x2
Your flash chip is in an unknown state.
Please report this on IRC at chat.freenode.net (channel #flashrom) or
mail flashrom@flashrom.org, thanks!
pi@raspberrypi:~/libreboot $ 
pi@raspberrypi:~/libreboot $ sudo flashrom -c "MX25L6405D" -p linux_spi:dev=/dev/spidev0.0,spispeed=512 -w libreboot.rom 
flashrom v0.9.9-r1954 on Linux 4.14.79+ (armv6l)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found Macronix flash chip "MX25L6405D" (8192 kB, SPI) on linux_spi.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.
pi@raspberrypi:~/libreboot $ 
```


# Links

* [https://libreboot.org/](https://libreboot.org/)
* [https://libreboot.org/docs/install/rpi_setup.html](https://libreboot.org/docs/install/rpi_setup.html)
* [https://libreboot.org/docs/install/t500_external.html](https://libreboot.org/docs/install/t500_external.html)
* [https://p1trson.blogspot.com/2016/](https://p1trson.blogspot.com/2016/)
* [https://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto](https://www.raspberrypi-spy.co.uk/2012/06/simple-guide-to-the-rpi-gpio-header-and-pins/#prettyPhoto)
* [https://forums.lenovo.com/t5/ThinkPad-T400-T500-and-newer-T/t500-bios-chip-lifted-pad-issue/td-p/4205719](https://forums.lenovo.com/t5/ThinkPad-T400-T500-and-newer-T/t500-bios-chip-lifted-pad-issue/td-p/4205719)
* [https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md](https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md)
* [https://linuxhint.com/libreboot-t400-tutorial/](https://linuxhint.com/libreboot-t400-tutorial/)
* [https://www.enisa.europa.eu/publications/info-notes/security-vs-performance-discussion-with-the-return-of-201cspectrum201d-vulnerability](https://www.enisa.europa.eu/publications/info-notes/security-vs-performance-discussion-with-the-return-of-201cspectrum201d-vulnerability)
