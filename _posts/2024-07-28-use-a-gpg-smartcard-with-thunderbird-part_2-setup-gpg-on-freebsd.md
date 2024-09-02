---
layout: post
title: "Use a GPG smart card with Thunderbird. Part 2: setup GnuPG on FreeBSD"
date: 2024-07-28 11:09:00 +0200
comments: true
categories: security thunderbird gpg pgp email linux freebsd
excerpt_separator: <!--more-->
---

---

*Updated @ Mon Sep  2 07:55:20 PM CEST 2024: Added devfs section*

---

I use [FreeBSD](https://www.freebsd.org) and [GNU](https://www.gnu.org)/[Linux](https://www.kernel.org).
<a href="{{ '/images/gpg/freebsd_with_smartcard.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/freebsd_with_smartcard_s.jpg' | remove_first:'/' | absolute_url }}" class="left" width="500" height="333" alt="freebsd with smartcard" /> </a>


In a [previous blog post](https://stafwag.github.io/blog/blog/2024/04/21/use-a-gpg-smartcard-with-thunderbird-part_1-setup-gpg/), we set up [GnuPG](https://gnupg.org/) with [smartcard](https://en.wikipedia.org/wiki/Smart_card) support on [Debian](https://www.debian.org) [GNU](https://www.gnu.org)/[Linux](https://www.kernel.org).

In this blog post, we'll install and configure GnuPG with smartcard support on [FreeBSD](https://www.freebsd.org).

The [GNU/Linux blog post](https://stafwag.github.io/blog/blog/2024/04/21/use-a-gpg-smartcard-with-thunderbird-part_1-setup-gpg/) provides more details about GnuPG, so it might be useful for the FreeBSD users to read it first.

Likewise, Linux users are welcome to read this blog post if they’re interested in how it's done on FreeBSD ;-)

<!--more-->

# Install the required packages

To begin, we need to install the required packages on FreeBSD. 

## Update the package database

Execute ```pkg update``` to update the package database.

## Thunderbird

```
[staf@monty ~]$ sudo pkg install -y thunderbird
Password:
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
[staf@monty ~]$ 
```

## lsusb

You can verify the USB devices on FreeBSD using the [usbconfig](https://man.freebsd.org/cgi/man.cgi?usbconfig) command or [lsusb](https://www.man7.org/linux/man-pages/man8/lsusb.8.html) which is also available on FreeBSD as part of the ```usbutils``` package.

```
[staf@monty ~/git/stafnet/blog]$ sudo pkg install usbutils
Password:
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 3 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
	usbhid-dump: 1.4
	usbids: 20240318
	usbutils: 0.91

Number of packages to be installed: 3

301 KiB to be downloaded.

Proceed with this action? [y/N]: y
[1/3] Fetching usbutils-0.91.pkg: 100%   54 KiB  55.2kB/s    00:01    
[2/3] Fetching usbhid-dump-1.4.pkg: 100%   32 KiB  32.5kB/s    00:01    
[3/3] Fetching usbids-20240318.pkg: 100%  215 KiB 220.5kB/s    00:01    
Checking integrity... done (0 conflicting)
[1/3] Installing usbhid-dump-1.4...
[1/3] Extracting usbhid-dump-1.4: 100%
[2/3] Installing usbids-20240318...
[2/3] Extracting usbids-20240318: 100%
[3/3] Installing usbutils-0.91...
[3/3] Extracting usbutils-0.91: 100%
[staf@monty ~/git/stafnet/blog]$
```

## GnuPG

We'll need GnuPG ( of course ), so ensure that it is installed.

```
[staf@monty ~]$ sudo pkg install gnupg
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
[staf@monty ~]$ 
```

## Smartcard packages

To enable smartcard support on FreeBSD, we'll need to install the smartcard packages. The same software as on GNU/Linux - [opensc](https://github.com/OpenSC/OpenSC/wiki) - is available on FreeBSD.

### pkg provides

It’s handy to be able to check which packages provide certain files. On FreeBSD this is provided by the ```provides``` plugin. This plugin is not enabled by default in the [pkg](https://man.freebsd.org/cgi/man.cgi?pkg) command.

To install in the ```provides``` plugin install the ```pkg-provides``` package.

```
[staf@monty ~]$ sudo pkg install pkg-provides
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        pkg-provides: 0.7.3_3

Number of packages to be installed: 1

12 KiB to be downloaded.

Proceed with this action? [y/N]: y
[1/1] Fetching pkg-provides-0.7.3_3.pkg: 100%   12 KiB  12.5kB/s    00:01    
Checking integrity... done (0 conflicting)
[1/1] Installing pkg-provides-0.7.3_3...
[1/1] Extracting pkg-provides-0.7.3_3: 100%
=====
Message from pkg-provides-0.7.3_3:

--
In order to use the pkg-provides plugin you need to enable plugins in pkg.
To do this, uncomment the following lines in /usr/local/etc/pkg.conf file
and add pkg-provides to the supported plugin list:

PKG_PLUGINS_DIR = "/usr/local/lib/pkg/";
PKG_ENABLE_PLUGINS = true;
PLUGINS [ provides ];

After that run `pkg plugins' to see the plugins handled by pkg.
[staf@monty ~]$ 
```
Edit the pkg configuration to enable the provides plug-in.

```
staf@freebsd-gpg:~ $ sudo vi /usr/local/etc/pkg.conf
```

```
PKG_PLUGINS_DIR = "/usr/local/lib/pkg/";
PKG_ENABLE_PLUGINS = true;
PLUGINS [ provides ];
```

Verify that the plugin is enabled.

```
staf@freebsd-gpg:~ $ sudo pkg plugins
NAME       DESC                                          VERSION   
provides   A plugin for querying which package provides a particular file 0.7.3     
staf@freebsd-gpg:~ $ 
```

Update the ```pkg-provides``` database.

```
staf@freebsd-gpg:~ $ sudo pkg provides -u
Fetching provides database: 100%   18 MiB   9.6MB/s    00:02    
Extracting database....success
staf@freebsd-gpg:~ $
```

### Install the required packages

Let's check which packages provide the tools to set up the smartcard reader on FreeBSD.
And install the required packages.

```
staf@freebsd-gpg:~ $ pkg provides "pkcs15-tool"
Name    : opensc-0.25.1
Comment : Libraries and utilities to access smart cards
Repo    : FreeBSD
Filename: usr/local/share/man/man1/pkcs15-tool.1.gz
          usr/local/etc/bash_completion.d/pkcs15-tool
          usr/local/bin/pkcs15-tool
staf@freebsd-gpg:~ $ 
```

```
staf@freebsd-gpg:~ $ pkg provides "bin/pcsc"
Name    : pcsc-lite-2.2.2,2
Comment : Middleware library to access a smart card using SCard API (PC/SC)
Repo    : FreeBSD
Filename: usr/local/sbin/pcscd
          usr/local/bin/pcsc-spy
staf@freebsd-gpg:~ $ 
```

```
[staf@monty ~]$ sudo pkg install opensc pcsc-lite
Password:
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
[staf@monty ~]$ 
```

```
staf@freebsd-gpg:~ $ sudo pkg install -y pcsc-tools
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
staf@freebsd-gpg:~ $ 
```

```
staf@freebsd-gpg:~ $ sudo pkg install -y ccid
Password:
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
staf@freebsd-gpg:~ $ 
```

# USB

To use the smartcard reader we will need access to the USB devices as the user we use for our desktop environment. (No, this shouldn't be the ```root``` user :-) )

## permissions

### verify

Execute the ```usbconfig``` command to verify that you can access the USB devices.

```
[staf@snuffel ~]$ usbconfig
No device match or lack of permissions.
[staf@snuffel ~]$ 
```

If you don't have access, verify the permissions of the USB devices.

```
[staf@snuffel ~]$ ls -l /dev/usbctl
crw-r--r--  1 root operator 0x5b Sep  2 19:17 /dev/usbctl
```

```
[staf@snuffel ~]$  ls -l /dev/usb/
total 0
crw-------  1 root operator 0x34 Sep  2 19:17 0.1.0
crw-------  1 root operator 0x4f Sep  2 19:17 0.1.1
crw-------  1 root operator 0x36 Sep  2 19:17 1.1.0
crw-------  1 root operator 0x53 Sep  2 19:17 1.1.1
crw-------  1 root operator 0x7e Sep  2 19:17 1.2.0
crw-------  1 root operator 0x82 Sep  2 19:17 1.2.1
crw-------  1 root operator 0x83 Sep  2 19:17 1.2.2
crw-------  1 root operator 0x76 Sep  2 19:17 1.3.0
crw-------  1 root operator 0x8a Sep  2 19:17 1.3.1
crw-------  1 root operator 0x8b Sep  2 19:17 1.3.2
crw-------  1 root operator 0x8c Sep  2 19:17 1.3.3
crw-------  1 root operator 0x8d Sep  2 19:17 1.3.4
crw-------  1 root operator 0x38 Sep  2 19:17 2.1.0
crw-------  1 root operator 0x56 Sep  2 19:17 2.1.1
crw-------  1 root operator 0x3a Sep  2 19:17 3.1.0
crw-------  1 root operator 0x51 Sep  2 19:17 3.1.1
crw-------  1 root operator 0x3c Sep  2 19:17 4.1.0
crw-------  1 root operator 0x55 Sep  2 19:17 4.1.1
crw-------  1 root operator 0x3e Sep  2 19:17 5.1.0
crw-------  1 root operator 0x54 Sep  2 19:17 5.1.1
crw-------  1 root operator 0x80 Sep  2 19:17 5.2.0
crw-------  1 root operator 0x85 Sep  2 19:17 5.2.1
crw-------  1 root operator 0x86 Sep  2 19:17 5.2.2
crw-------  1 root operator 0x87 Sep  2 19:17 5.2.3
crw-------  1 root operator 0x40 Sep  2 19:17 6.1.0
crw-------  1 root operator 0x52 Sep  2 19:17 6.1.1
crw-------  1 root operator 0x42 Sep  2 19:17 7.1.0
crw-------  1 root operator 0x50 Sep  2 19:17 7.1.1
```

### devfs

When the ```/dev/usb*``` are only accessible by the ```root``` user. You probably want to create ```devfs.rules``` that to grant permissions to the ```operator``` or another group.

See [https://man.freebsd.org/cgi/man.cgi?devfs.rules](https://man.freebsd.org/cgi/man.cgi?devfs.rules) for more details.

#### ```/etc/rc.conf```

Update the ```/etc/rc.conf``` to apply custom ```devfs``` permissions.

```
[staf@snuffel /etc]$ sudo vi rc.conf
```
```
devfs_system_ruleset="localrules"
```

#### ```/etc/devfs.rules```

Create or update the ```/dev/devfs.rules``` with the update permissions to grant read/write access to the ```operator``` group.

```
[staf@snuffel /etc]$ sudo vi devfs.rules
```

```
[localrules=10]
add path 'usbctl*' mode 0660 group operator
add path 'usb/*' mode 0660 group operator
```

Restart the ```devfs``` service to apply the custom ```devfs``` ruleset.

```
[staf@snuffel /etc]$ sudo -i
root@snuffel:~ #
```
```
root@snuffel:~ # service devfs restart
```

The operator group should have read/write permissions now.

```
root@snuffel:~ # ls -l /dev/usb/
total 0
crw-rw----  1 root operator 0x34 Sep  2 19:17 0.1.0
crw-rw----  1 root operator 0x4f Sep  2 19:17 0.1.1
crw-rw----  1 root operator 0x36 Sep  2 19:17 1.1.0
crw-rw----  1 root operator 0x53 Sep  2 19:17 1.1.1
crw-rw----  1 root operator 0x7e Sep  2 19:17 1.2.0
crw-rw----  1 root operator 0x82 Sep  2 19:17 1.2.1
crw-rw----  1 root operator 0x83 Sep  2 19:17 1.2.2
crw-rw----  1 root operator 0x76 Sep  2 19:17 1.3.0
crw-rw----  1 root operator 0x8a Sep  2 19:17 1.3.1
crw-rw----  1 root operator 0x8b Sep  2 19:17 1.3.2
crw-rw----  1 root operator 0x8c Sep  2 19:17 1.3.3
crw-rw----  1 root operator 0x8d Sep  2 19:17 1.3.4
crw-rw----  1 root operator 0x38 Sep  2 19:17 2.1.0
crw-rw----  1 root operator 0x56 Sep  2 19:17 2.1.1
crw-rw----  1 root operator 0x3a Sep  2 19:17 3.1.0
crw-rw----  1 root operator 0x51 Sep  2 19:17 3.1.1
crw-rw----  1 root operator 0x3c Sep  2 19:17 4.1.0
crw-rw----  1 root operator 0x55 Sep  2 19:17 4.1.1
crw-rw----  1 root operator 0x3e Sep  2 19:17 5.1.0
crw-rw----  1 root operator 0x54 Sep  2 19:17 5.1.1
crw-rw----  1 root operator 0x80 Sep  2 19:17 5.2.0
crw-rw----  1 root operator 0x85 Sep  2 19:17 5.2.1
crw-rw----  1 root operator 0x86 Sep  2 19:17 5.2.2
crw-rw----  1 root operator 0x87 Sep  2 19:17 5.2.3
crw-rw----  1 root operator 0x40 Sep  2 19:17 6.1.0
crw-rw----  1 root operator 0x52 Sep  2 19:17 6.1.1
crw-rw----  1 root operator 0x42 Sep  2 19:17 7.1.0
crw-rw----  1 root operator 0x50 Sep  2 19:17 7.1.1
root@snuffel:~ # 
```

### Make sure that you're part of the operator group

```
staf@freebsd-gpg:~ $ ls -l /dev/usbctl 
crw-rw----  1 root operator 0x5a Jul 13 17:32 /dev/usbctl
staf@freebsd-gpg:~ $ ls -l /dev/usb/
total 0
crw-rw----  1 root operator 0x31 Jul 13 17:32 0.1.0
crw-rw----  1 root operator 0x53 Jul 13 17:32 0.1.1
crw-rw----  1 root operator 0x33 Jul 13 17:32 1.1.0
crw-rw----  1 root operator 0x51 Jul 13 17:32 1.1.1
crw-rw----  1 root operator 0x35 Jul 13 17:32 2.1.0
crw-rw----  1 root operator 0x52 Jul 13 17:32 2.1.1
crw-rw----  1 root operator 0x37 Jul 13 17:32 3.1.0
crw-rw----  1 root operator 0x54 Jul 13 17:32 3.1.1
crw-rw----  1 root operator 0x73 Jul 13 17:32 3.2.0
crw-rw----  1 root operator 0x75 Jul 13 17:32 3.2.1
crw-rw----  1 root operator 0x76 Jul 13 17:32 3.3.0
crw-rw----  1 root operator 0x78 Jul 13 17:32 3.3.1
staf@freebsd-gpg:~ $ 
```

You’ll need to be part of the ```operator``` group to access the USB devices.

Execute the [vigr](https://man.freebsd.org/cgi/man.cgi?query=vigr) command and add the user to the operator group.

```
staf@freebsd-gpg:~ $ sudo vigr
```

```
operator:*:5:root,staf
```

Relogin and check that you are in the operator group.

```
staf@freebsd-gpg:~ $ id
uid=1001(staf) gid=1001(staf) groups=1001(staf),0(wheel),5(operator)
staf@freebsd-gpg:~ $ 
```

The ```usbconfig``` command should work now.

```
staf@freebsd-gpg:~ $ usbconfig
ugen1.1: <Intel UHCI root HUB> at usbus1, cfg=0 md=HOST spd=FULL (12Mbps) pwr=SAVE (0mA)
ugen2.1: <Intel UHCI root HUB> at usbus2, cfg=0 md=HOST spd=FULL (12Mbps) pwr=SAVE (0mA)
ugen0.1: <Intel UHCI root HUB> at usbus0, cfg=0 md=HOST spd=FULL (12Mbps) pwr=SAVE (0mA)
ugen3.1: <Intel EHCI root HUB> at usbus3, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen3.2: <QEMU Tablet Adomax Technology Co., Ltd> at usbus3, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=ON (100mA)
ugen3.3: <QEMU Tablet Adomax Technology Co., Ltd> at usbus3, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=ON (100mA)
staf@freebsd-gpg:~ $ 
```


# SmartCard configuration

## Verify the USB connection

The first step is to ensure your smartcard reader is detected on a USB level. Execute ```usbconfig``` and ```lsusb``` and make sure your smartcard reader is listed.

### usbconfig

List the USB devices.

```
[staf@monty ~/git]$ usbconfig
ugen1.1: <Intel EHCI root HUB> at usbus1, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen0.1: <Intel XHCI root HUB> at usbus0, cfg=0 md=HOST spd=SUPER (5.0Gbps) pwr=SAVE (0mA)
ugen2.1: <Intel EHCI root HUB> at usbus2, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen2.2: <Integrated Rate Matching Hub Intel Corp.> at usbus2, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen1.2: <Integrated Rate Matching Hub Intel Corp.> at usbus1, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=SAVE (0mA)
ugen0.2: <AU9540 Smartcard Reader Alcor Micro Corp.> at usbus0, cfg=0 md=HOST spd=FULL (12Mbps) pwr=ON (50mA)
ugen0.3: <VFS 5011 fingerprint sensor Validity Sensors, Inc.> at usbus0, cfg=0 md=HOST spd=FULL (12Mbps) pwr=ON (100mA)
ugen0.4: <Centrino Bluetooth Wireless Transceiver Intel Corp.> at usbus0, cfg=0 md=HOST spd=FULL (12Mbps) pwr=ON (0mA)
ugen0.5: <SunplusIT INC. Integrated Camera> at usbus0, cfg=0 md=HOST spd=HIGH (480Mbps) pwr=ON (500mA)
ugen0.6: <X-Rite Pantone Color Sensor X-Rite, Inc.> at usbus0, cfg=0 md=HOST spd=LOW (1.5Mbps) pwr=ON (100mA)
ugen0.7: <GemPC Key SmartCard Reader Gemalto (was Gemplus)> at usbus0, cfg=0 md=HOST spd=FULL (12Mbps) pwr=ON (50mA)
[staf@monty ~/git]$ 
```

### lsusb

```
[staf@monty ~/git/stafnet/blog]$ lsusb
Bus /dev/usb Device /dev/ugen0.7: ID 08e6:3438 Gemalto (was Gemplus) GemPC Key SmartCard Reader
Bus /dev/usb Device /dev/ugen0.6: ID 0765:5010 X-Rite, Inc. X-Rite Pantone Color Sensor
Bus /dev/usb Device /dev/ugen0.5: ID 04f2:b39a Chicony Electronics Co., Ltd 
Bus /dev/usb Device /dev/ugen0.4: ID 8087:07da Intel Corp. Centrino Bluetooth Wireless Transceiver
Bus /dev/usb Device /dev/ugen0.3: ID 138a:0017 Validity Sensors, Inc. VFS 5011 fingerprint sensor
Bus /dev/usb Device /dev/ugen0.2: ID 058f:9540 Alcor Micro Corp. AU9540 Smartcard Reader
Bus /dev/usb Device /dev/ugen1.2: ID 8087:8008 Intel Corp. Integrated Rate Matching Hub
Bus /dev/usb Device /dev/ugen2.2: ID 8087:8000 Intel Corp. Integrated Rate Matching Hub
Bus /dev/usb Device /dev/ugen2.1: ID 0000:0000  
Bus /dev/usb Device /dev/ugen0.1: ID 0000:0000  
Bus /dev/usb Device /dev/ugen1.1: ID 0000:0000  
[staf@monty ~/git/stafnet/blog]$ 
```

## Check the GnuPG smartcard status

Let’s check if we get access to our smart card with ```gpg```.

This might work if you have a native-supported GnuPG smartcard.

```
[staf@monty ~]$ gpg --card-status
gpg: selecting card failed: Operation not supported by device
gpg: OpenPGP card not available: Operation not supported by device
[staf@monty ~]$ 
```

In my case, it doesn’t work. I prefer the OpenSC interface, this might be useful if you want to use your smartcard for other usages.

## opensc

### Enable pcscd

FreeBSD has a handy tool [sysrc](https://man.freebsd.org/cgi/man.cgi?query=sysrc&sektion=8&format=html) to manage [rc.conf](https://man.freebsd.org/cgi/man.cgi?query=rc.conf)

Enable the ```pcscd``` service.

```
[staf@monty ~]$ sudo sysrc pcscd_enable=YES
Password:
pcscd_enable: NO -> YES
[staf@monty ~]$ 
```

Start the ```pcscd``` service.

```
[staf@monty ~]$ sudo /usr/local/etc/rc.d/pcscd start
Password:
Starting pcscd.
[staf@monty ~]$ 
```

### Verify smartcard access

#### pcsc_scan

The ```opensc-tools``` package provides a tool - ```pcsc_scan``` to verify the smartcard readers.

Execute ```pcsc_scan``` to verify that your smartcard is detected.

```
[staf@monty ~]$ pcsc_scan 
PC/SC device scanner
V 1.7.1 (c) 2001-2022, Ludovic Rousseau <ludovic.rousseau@free.fr>
Using reader plug'n play mechanism
Scanning present readers...
0: Gemalto USB Shell Token V2 (284C3E93) 00 00
1: Alcor Micro AU9540 01 00
 
Thu Jul 25 18:42:34 2024
 Reader 0: Gemalto USB Shell Token V2 (<snip>) 00 00
  Event number: 0
  Card state: Card inserted, 
  ATR: <snip>

ATR: <snip>
+ TS = 3B --> Direct Convention
+ T0 = DA, Y(1): 1101, K: 10 (historical bytes)
  TA(1) = 18 --> Fi=372, Di=12, 31 cycles/ETU
    129032 bits/s at 4 MHz, fMax for Fi = 5 MHz => 161290 bits/s
  TC(1) = FF --> Extra guard time: 255 (special value)
  TD(1) = 81 --> Y(i+1) = 1000, Protocol T = 1 
-----
  TD(2) = B1 --> Y(i+1) = 1011, Protocol T = 1 
-----
  TA(3) = FE --> IFSC: 254
  TB(3) = 75 --> Block Waiting Integer: 7 - Character Waiting Integer: 5
  TD(3) = 1F --> Y(i+1) = 0001, Protocol T = 15 - Global interface bytes following 
-----
  TA(4) = 03 --> Clock stop: not supported - Class accepted by the card: (3G) A 5V B 3V 
+ Historical bytes: 00 31 C5 73 C0 01 40 00 90 00
  Category indicator byte: 00 (compact TLV data object)
    Tag: 3, len: 1 (card service data byte)
      Card service data byte: C5
        - Application selection: by full DF name
        - Application selection: by partial DF name
        - EF.DIR and EF.ATR access services: by GET DATA command
        - Card without MF
    Tag: 7, len: 3 (card capabilities)
      Selection methods: C0
        - DF selection by full DF name
        - DF selection by partial DF name
      Data coding byte: 01
        - Behaviour of write functions: one-time write
        - Value 'FF' for the first byte of BER-TLV tag fields: invalid
        - Data unit in quartets: 2
      Command chaining, length fields and logical channels: 40
        - Extended Lc and Le fields
        - Logical channel number assignment: No logical channel
        - Maximum number of logical channels: 1
    Mandatory status indicator (3 last bytes)
      LCS (life card cycle): 00 (No information given)
      SW: 9000 (Normal processing.)
+ TCK = 0C (correct checksum)

Possibly identified card (using /usr/local/share/pcsc/smartcard_list.txt):
<snip>
        OpenPGP Card V2

 Reader 1: Alcor Micro AU9540 01 00
  Event number: 0
  Card state
```

#### pkcs15

pkcs15 is the ```application``` interface for hardware tokens while pkcs11 is the low-level interface.

You can use ```pkcs15-tool -D``` to verify that your smartcard is detected.

```
staf@monty ~]$ pkcs15-tool -D
Using reader with a card: Gemalto USB Shell Token V2 (<snip>) 00 00
PKCS#15 Card [OpenPGP card]:
        Version        : 0
        Serial number  : <snip>
        Manufacturer ID: ZeitControl
        Language       : nl
        Flags          : PRN generation, EID compliant


PIN [User PIN]
        Object Flags   : [0x03], private, modifiable
        Auth ID        : 03
        ID             : 02
        Flags          : [0x13], case-sensitive, local, initialized
        Length         : min_len:6, max_len:32, stored_len:32
        Pad char       : 0x00
        Reference      : 2 (0x02)
        Type           : UTF-8
        Path           : 3f00
        Tries left     : 3

PIN [User PIN (sig)]
        Object Flags   : [0x03], private, modifiable
        Auth ID        : 03
        ID             : 01
        Flags          : [0x13], case-sensitive, local, initialized
        Length         : min_len:6, max_len:32, stored_len:32
        Pad char       : 0x00
        Reference      : 1 (0x01)
        Type           : UTF-8
        Path           : 3f00
        Tries left     : 0

PIN [Admin PIN]
        Object Flags   : [0x03], private, modifiable
        ID             : 03
        Flags          : [0x9B], case-sensitive, local, unblock-disabled, initialized, soPin
        Length         : min_len:8, max_len:32, stored_len:32
        Pad char       : 0x00
        Reference      : 3 (0x03)
        Type           : UTF-8
        Path           : 3f00
        Tries left     : 0

Private RSA Key [Signature key]
        Object Flags   : [0x03], private, modifiable
        Usage          : [0x20C], sign, signRecover, nonRepudiation
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        Algo_refs      : 0
        ModLength      : 3072
        Key ref        : 0 (0x00)
        Native         : yes
        Auth ID        : 01
        ID             : 01
        MD:guid        : <snip>

Private RSA Key [Encryption key]
        Object Flags   : [0x03], private, modifiable
        Usage          : [0x22], decrypt, unwrap
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        Algo_refs      : 0
        ModLength      : 3072
        Key ref        : 1 (0x01)
        Native         : yes
        Auth ID        : 02
        ID             : 02
        MD:guid        : <snip>

Private RSA Key [Authentication key]
        Object Flags   : [0x03], private, modifiable
        Usage          : [0x200], nonRepudiation
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        Algo_refs      : 0
        ModLength      : 3072
        Key ref        : 2 (0x02)
        Native         : yes
        Auth ID        : 02
        ID             : 03
        MD:guid        : <snip>

Public RSA Key [Signature key]
        Object Flags   : [0x02], modifiable
        Usage          : [0xC0], verify, verifyRecover
        Access Flags   : [0x02], extract
        ModLength      : 3072
        Key ref        : 0 (0x00)
        Native         : no
        Path           : b601
        ID             : 01

Public RSA Key [Encryption key]
        Object Flags   : [0x02], modifiable
        Usage          : [0x11], encrypt, wrap
        Access Flags   : [0x02], extract
        ModLength      : 3072
        Key ref        : 0 (0x00)
        Native         : no
        Path           : b801
        ID             : 02

Public RSA Key [Authentication key]
        Object Flags   : [0x02], modifiable
        Usage          : [0x40], verify
        Access Flags   : [0x02], extract
        ModLength      : 3072
        Key ref        : 0 (0x00)
        Native         : no
        Path           : a401
        ID             : 03

[staf@monty ~]$ 
```

## GnuPG configuration

### First test

Stop (kill) the ```scdaemon```, to ensure that the ```scdaemon``` tries to use the ```opensc``` interface.

```
[staf@monty ~]$ gpgconf --kill scdaemon
[staf@monty ~]$ 
```

```
[staf@monty ~]$ ps aux | grep -i scdaemon
staf  9236  0.0  0.0   12808   2496  3  S+   20:42   0:00.00 grep -i scdaemon
[staf@monty ~]$ 
```

Try to read the card status again.

```
[staf@monty ~]$ gpg --card-status
gpg: selecting card failed: Operation not supported by device
gpg: OpenPGP card not available: Operation not supported by device
[staf@monty ~]$ 
```

### Reconfigure GnuPG

Go to the ```.gnupg``` directory in your ```$HOME``` directory.

```
[staf@monty ~]$ cd .gnupg/
[staf@monty ~/.gnupg]$ 
```

#### scdaemon

Reconfigure ```scdaemon``` to disable the internal ```ccid``` and enable logging - always useful to verify why something isn't working...

```
[staf@monty ~/.gnupg]$ vi scdaemon.conf
```

```
disable-ccid

verbose
debug-level expert
debug-all
log-file    /home/staf/logs/scdaemon.log
```

#### gpg-agent

Enable debug logging for the ```gpg-agent```.

```
[staf@monty ~/.gnupg]$ vi gpg-agent.conf
```

```
verbose
debug-level expert
debug-level expert
verbose
verbose
log-file /home/staf/logs/gpg-agent.log
```

#### Verify

Stop the ```scdaemon```.

```
[staf@monty ~/.gnupg]$ gpgconf --kill scdaemon
[staf@monty ~/.gnupg]$ 
```

If everything goes well ```gpg``` will detect the smartcard.

If not, you have some logging to do some debugging ;-)

```
[staf@monty ~/.gnupg]$ gpg --card-status
Reader ...........: Gemalto USB Shell Token V2 (<snip>) 00 00
Application ID ...: <snip>
Application type .: OpenPGP
Version ..........: 2.1
Manufacturer .....: ZeitControl
Serial number ....: 000046F1
Name of cardholder: <snip>
Language prefs ...: nl
Salutation .......: Mr.
URL of public key : <snip>
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: xxxxxxx xxxxxxx xxxxxxx
Max. PIN lengths .: 32 32 32
PIN retry counter : 3 0 3
Signature counter : 80
Signature key ....: <snip>
      created ....: <snip>
Encryption key....: <snip>
      created ....: <snip>
Authentication key: <snip>
      created ....: <snip>
General key info..: [none]
[staf@monty ~/.gnupg]$ 
```

# Test

## shadow private keys

After you executed ```gpg --card-status```, GnuPG created "shadow private keys". These keys just contain references on which hardware tokens the private keys are stored.

```
[staf@monty ~/.gnupg]$ ls -l private-keys-v1.d/
total 14
-rw-------  1 staf staf 976 Mar 24 11:35 0585C7A36806D0BA8F5AA0F397917E3E7FD3D41A.key
-rw-------  1 staf staf 976 Mar 24 11:35 506CDB58B562D27CFD719CE98653964BE7366E1D.key
-rw-------  1 staf staf 976 Mar 24 11:35 C9897DFB8BF416CFD0D812828B06D82AFF2E1701.key
[staf@monty ~/.gnupg]$ 
```

You can list the (shadow) private keys with the ```gpg --list-secret-keys``` command.

## Pinentry

To be able to type in your PIN code, you'll need a ```pinentry``` application unless your smartcard reader has a pinpad.

You can use ```pkg provides``` to verify which ```pinentry``` applications are available.

For the integration with Thunderbird, you probably want to have a graphical-enabled version. But this is the topic for a next blog post ;-)

We'll stick with the (n)curses version for now.

Install a ```pinentry``` program.

```
[staf@monty ~/.gnupg]$ pkg provides pinentry | grep -i curses
Name    : pinentry-curses-1.3.1
Comment : Curses version of the GnuPG password dialog
Filename: usr/local/bin/pinentry-curses
[staf@monty ~/.gnupg]$ 
```

```
[staf@monty ~/.gnupg]$ sudo pkg install pinentry-curses
Password:
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Checking integrity... done (0 conflicting)
The most recent versions of packages are already installed
[staf@monty ~/.gnupg]$ 
```

A soft link is created for the pinentry binary.
On FreeBSD, the ```pinentry``` soft link is managed by the [pinentry package](https://www.freshports.org/security/pinentry).

You can verify this with the ```pkg which``` command.

```
[staf@monty ~]$ pkg which /usr/local/bin/pinentry
/usr/local/bin/pinentry was installed by package pinentry-1.3.1
[staf@monty ~]$ 
```

The curses version is the default.

If you want to use another pinentry version in the ```gpg-agent``` configuration ( ```$HOME/.gnupg/gpg-agent.conf```).

```
pinentry-program <PATH>
```

## Import your public key

Import your public key.

```
[staf@monty /tmp]$ gpg --import <snip>.asc
gpg: key <snip>: public key "<snip>" imported
gpg: Total number processed: 1
gpg:               imported: 1
[staf@monty /tmp]$ 
```

List the public keys.

```
[staf@monty /tmp]$ gpg --list-keys
/home/staf/.gnupg/pubring.kbx
-----------------------------
pub   XXXXXXX XXXX-XX-XX [SC]
      <snip>
uid           [ unknown] <snip>
sub   XXXXXXX XXXX-XX-XX [A]
sub   XXXXXXX XXXX-XX-XX [E]

[staf@monty /tmp]$ 
```

As a test, we try to sign something with the private key on our GnuPG smartcard.

Create a test file.

```
[staf@monty /tmp]$ echo "foobar" > foobar
[staf@monty /tmp]$ 
```

```
[staf@monty /tmp]$ gpg --sign foobar
```

If your smartcard isn’t inserted GnuPG will ask to insert it.

GnuPG asks for the smartcard with the serial in the shadow private key.


```

                ┌────────────────────────────────────────────┐
                │ Please insert the card with serial number: │
                │                                            │
                │ XXXX XXXXXXXX                              │
                │                                            │
                │                                            │
                │      <OK>                      <Cancel>    │
                └────────────────────────────────────────────┘


```

Type in your PIN code.

```


               ┌──────────────────────────────────────────────┐
               │ Please unlock the card                       │
               │                                              │
               │ Number: XXXX XXXXXXXX                        │
               │ Holder: XXXX XXXXXXXXXX                      │
               │ Counter: XX                                  │
               │                                              │
               │ PIN ________________________________________ │
               │                                              │
               │      <OK>                        <Cancel>    │
               └──────────────────────────────────────────────┘


```

```
[staf@monty /tmp]$ ls -l foobar*
-rw-r-----  1 staf wheel   7 Jul 27 11:11 foobar
-rw-r-----  1 staf wheel 481 Jul 27 11:17 foobar.gpg
[staf@monty /tmp]$ 
```

In a next blog post in this series, we’ll configure Thunderbird to use the smartcard for OpenPG email encryption.

***Have fun!***

# Links

* [https://vermaden.wordpress.com/2019/01/17/less-known-pkg8-features/](https://vermaden.wordpress.com/2019/01/17/less-known-pkg8-features/)
* [https://www.floss-shop.de/en/security-privacy/smartcards/13/openpgp-smart-card-v3.4?c=11](https://www.floss-shop.de/en/security-privacy/smartcards/13/openpgp-smart-card-v3.4?c=11)
* [https://www.gnupg.org/howtos/card-howto/en/smartcard-howto-single.html](https://www.gnupg.org/howtos/card-howto/en/smartcard-howto-single.html)
* [https://support.nitrokey.com/t/nk3-mini-gpg-selecting-card-failed-no-such-device-gpg-card-setup/5057/7](https://support.nitrokey.com/t/nk3-mini-gpg-selecting-card-failed-no-such-device-gpg-card-setup/5057/7)
* [https://security.stackexchange.com/questions/233916/gnupg-connecting-to-specific-card-reader-when-multiple-reader-available#233918](https://security.stackexchange.com/questions/233916/gnupg-connecting-to-specific-card-reader-when-multiple-reader-available#233918)
* [https://www.fsij.org/doc-gnuk/stop-scdaemon.html](https://www.fsij.org/doc-gnuk/stop-scdaemon.html)
* [https://wiki.debian.org/Smartcards](https://wiki.debian.org/Smartcards)
* [https://github.com/OpenSC/OpenSC/wiki/Overview/c70c57c1811f54fe3b3989d01708b45b86fafe11](https://github.com/OpenSC/OpenSC/wiki/Overview/c70c57c1811f54fe3b3989d01708b45b86fafe11)
* [https://superuser.com/questions/1693289/gpg-warning-not-using-as-default-key-no-secret-key](https://superuser.com/questions/1693289/gpg-warning-not-using-as-default-key-no-secret-key)
* [https://stackoverflow.com/questions/46689885/how-to-get-public-key-from-an-openpgp-smart-card-without-using-key-servers](https://stackoverflow.com/questions/46689885/how-to-get-public-key-from-an-openpgp-smart-card-without-using-key-servers)
