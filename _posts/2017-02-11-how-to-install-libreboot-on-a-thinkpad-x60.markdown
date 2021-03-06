---
layout: post
title: "How to install libreboot on a ThinkPad X60"
date: 2017-02-11 16:09:11 +0100
comments: true
categories: [ libreboot, trisquel, debian, parabola ,thinkpad, x60 ] 
---


<br />&nbsp;<br />
I got a <a href="https://en.wikipedia.org/wiki/ThinkPad_X_Series#X60_Tablet">ThinkPad x60 (tablet version)</a> from <a href="http://ebay.be">ebay.be</a> to install <a href="https://libreboot.org/">libreboot</a> on it.
<br />&nbsp;<br />
I tried to compile libreboot on <a href="http://www.debian">Debian</a> and <a href="https://www.parabola.nu/">Parabola</a> GNU/Linux but both failed, compling Libreboot on <a href="https://trisquel.info/">Trisquel 7</a> works fine so I'll use Trisquel to replace the BIOS with libreboot.
<br />&nbsp;<br />
I'm not sure that I'll use Trisquel 7 as my daily driver since it is a bit outdated...
I might go with <a href="http://https://wiki.debian.org/DebianStretch">Debian Strech</a> without the non-free repositories to get a fully <a href="https://en.wikipedia.org/wiki/Free_software">Free Software</a> Laptop/tablet. I'll need to replace the Intel wifi adapter since this requires non-free firmware.
<br />&nbsp;<br />
You'll find a small howto install libreboot on a Thinkpad X60 below.
<br />&nbsp;<br />

<img src="{{ '/images/x60_open.jpg'  | remove_first:'/' | absolute_url }}" class="centre" width="750" height="1050" alt="Thinkpad"/>

# Build Libreboot

The latest version of libreboot isn't available via a binary distribution so I decided to build it from source.

## Download the Libreboot source

Download the latest libreboot image from <a href="https://libreboot.org/download/">https://libreboot.org/download/</a>

### Download the source tarball

```
staf@petronella:~/libreboot$ wget https://libreboot.org/release/stable/20160907/libreboot_r20160907_src.tar.xz
--2017-02-11 10:24:41--  https://libreboot.org/release/stable/20160907/libreboot_r20160907_src.tar.xz
Resolving libreboot.org (libreboot.org)... 149.56.232.100
Connecting to libreboot.org (libreboot.org)|149.56.232.100|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 438622508 (418M) [application/x-xz]
Saving to: libreboot_r20160907_src.tar.xz

100%[==========================================================>] 438.622.508  541KB/s   in 18m 35s


2017-02-11 10:43:17 (384 KB/s) - libreboot_r20160907_src.tar.xz saved [438622508/438622508]

staf@petronella:~/libreboot$ 
```


### Verify

As always verify the checksums and the gpg signature, the gpg public key is available at:
<a href="https://libreboot.org/gpg/"</a>https://libreboot.org/gpg/</a>

#### Download the  SHA512SUMS and SHA512SUMS.sig

```
staf@petronella:~/libreboot$ wget https://libreboot.org/release/stable/20160907/SHA512SUMS                                                      
--2017-02-11 10:52:23--  https://libreboot.org/release/stable/20160907/SHA512SUMS                                                                          
Resolving libreboot.org (libreboot.org)... 149.56.232.100                                                                                                            
Connecting to libreboot.org (libreboot.org)|149.56.232.100|:443... connected.                                                                                                  
HTTP request sent, awaiting response... 200 OK                                                                                                                                 
Length: 5112 (5,0K) [application/octet-stream]                                                                                                                                        
Saving to: 'SHA512SUMS'                                                                                                                                                                          
                                                                                                                                                                                                         
100%[=====================================================================================================================================================================================================>] 5.112       --.-K/s   in 0,006s  
                                                                                                                                                                                                                          
2017-02-11 10:52:24 (852 KB/s) - 'SHA512SUMS' saved [5112/5112]                                                                                                                                                                      
                                                                                                                                                                                                                                             
staf@petronella:~/libreboot$ wget https://libreboot.org/release/stable/20160907/SHA512SUMS.sig
--2017-02-11 10:52:39--  https://libreboot.org/release/stable/20160907/SHA512SUMS.sig
Resolving libreboot.org (libreboot.org)... 149.56.232.100
Connecting to libreboot.org (libreboot.org)|149.56.232.100|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 543 [application/pgp-signature]
Saving to: 'SHA512SUMS.sig'

100%[=====================================================================================================================================================================================================>] 543         --.-K/s   in 0s      

2017-02-11 10:52:39 (11,4 MB/s) - 'SHA512SUMS.sig' saved [543/543]

staf@petronella:~/libreboot$ 
```

#### Import the public gpg key 

```
staf@petronella:~/libreboot$ gpg --recv-keys 0x05E8C5B2
gpg: directory `/home/staf/.gnupg' created
gpg: new configuration file `/home/staf/.gnupg/gpg.conf' created
gpg: WARNING: options in `/home/staf/.gnupg/gpg.conf' are not yet active during this run
gpg: keyring `/home/staf/.gnupg/secring.gpg' created
gpg: keyring `/home/staf/.gnupg/pubring.gpg' created
gpg: no keyserver known (use option --keyserver)
gpg: keyserver receive failed: bad URI
staf@petronella:~/libreboot$ gpg --recv-keys 0x05E8C5B2
gpg: requesting key 05E8C5B2 from hkp server keys.gnupg.net
gpg: /home/staf/.gnupg/trustdb.gpg: trustdb created
gpg: key 05E8C5B2: public key "Leah Rowe (Libreboot signing key) <info@minifree.org>" imported
gpg: key 05E8C5B2: public key "Leah Rowe (Libreboot signing key) <info@minifree.org>" imported
gpg: no ultimately trusted keys found
gpg: Total number processed: 2
gpg:               imported: 2  (RSA: 2)
staf@petronella:~/libreboot$ 
```

#### Verify the checksum file


```
staf@petronella:~/libreboot$ gpg --verify SHA512SUMS.sig SHA512SUMS
gpg: Signature made Don 08 Sep 2016 00:15:17 CEST using RSA key ID 05E8C5B2
gpg: Good signature from "Leah Rowe (Libreboot signing key) <info@minifree.org>"
gpg: WARNING: This key is not certified with a trusted signature!
gpg:          There is no indication that the signature belongs to the owner.
Primary key fingerprint: CDC9 CAE3 2CB4 B7FC 84FD  C804 969A 9795 05E8 C5B2
staf@petronella:~/libreboot$ 
```

#### Verify the checksum

```
staf@petronella:~/libreboot$ sha512sum -c SHA512SUMS | head -2
sha512sum: ./libreboot_r20160907_util.tar.xz: No such file or directory
sha512sum: ./rom/depthcharge/libreboot_r20160907_depthcharge_veyron_speedy.tar.xz: No such file or directory
sha512sum: ./rom/grub/libreboot_r20160907_grub_d510mo.tar.xz: No such file or directory
sha512sum: ./libreboot_r20160907_src.tar.xz: OK
./rom/grub/libreboot_r20160907_grub_ga-g41m-es2l.tar.xz./libreboot_r20160907_util.tar.xz: FAILED open or read
: No such file or directory
staf@petronella:~/libreboot$ 
``` 

## Build the modules

### Git

It's required to have git installed and to set the user email & name if you don't do this the complilation will fail.

Install git

```
staf@petronella:~/libreboot$ sudo apt-get install git
[sudo] password for staf: 
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following extra packages will be installed:
  git-man liberror-perl
Suggested packages:
  git-daemon-run git-daemon-sysvinit git-doc git-el git-email git-gui gitk
  gitweb git-arch git-bzr git-cvs git-mediawiki git-svn
The following NEW packages will be installed:
  git git-man liberror-perl
0 upgraded, 3 newly installed, 0 to remove and 0 not upgraded.
Need to get 3.306 kB of archives.
After this operation, 21,9 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://fr.archive.trisquel.info/trisquel/ belenos/main liberror-perl all 0.17-1.1 [21,1 kB]
Get:2 http://fr.archive.trisquel.info/trisquel/ belenos-security/main git-man all 1:1.9.1-1ubuntu0.3 [699 kB]
Get:3 http://fr.archive.trisquel.info/trisquel/ belenos-security/main git amd64 1:1.9.1-1ubuntu0.3 [2.586 kB]
Fetched 3.306 kB in 4s (723 kB/s)
Selecting previously unselected package liberror-perl.
(Reading database ... 206214 files and directories currently installed.)
Preparing to unpack .../liberror-perl_0.17-1.1_all.deb ...
Unpacking liberror-perl (0.17-1.1) ...
Selecting previously unselected package git-man.
Preparing to unpack .../git-man_1%3a1.9.1-1ubuntu0.3_all.deb ...
Unpacking git-man (1:1.9.1-1ubuntu0.3) ...
Selecting previously unselected package git.
Preparing to unpack .../git_1%3a1.9.1-1ubuntu0.3_amd64.deb ...
Unpacking git (1:1.9.1-1ubuntu0.3) ...
Processing triggers for man-db (2.6.7.1-1ubuntu1) ...
Setting up liberror-perl (0.17-1.1) ...
Setting up git-man (1:1.9.1-1ubuntu0.3) ...
Setting up git (1:1.9.1-1ubuntu0.3) ...
staf@petronella:~/libreboot$ 
```

Set the git username and password.

```
staf@petronella:~/libreboot$ git config --global user.email "staf@wagemakers.be"
staf@petronella:~/libreboot$ git config --global user.name "staf wagemakers"
staf@petronella:~/libreboot$ 
``` 

### Extract the source

```
staf@petronella:~/libreboot$ tar xf libreboot_r20160907_src.tar.xz 
staf@petronella:~/libreboot$ 
```

### Install the dependencies 

cd into the extracted directory

```
staf@petronella:~/libreboot$ ls
SHA512SUMS  SHA512SUMS.sig  libreboot_r20160907_src  libreboot_r20160907_src.tar.xz
staf@petronella:~/libreboot$ cd libreboot_r20160907_src
```

run dependencies trisquel7 to install the software dependencies.

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./build dependencies trisquel7
Reading package lists... Done
Building dependency tree       
Reading state information... Done
wget is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
git is already the newest version.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following extra packages will be installed:
  fonts-lmodern fonts-texgyre latex-beamer latex-xcolor libintl-perl
  liblua5.1-0 libpaper-utils libptexenc1 libruby1.9.1 libtext-unidecode-perl
  libxml-libxml-perl libxml-namespacesupport-perl libxml-sax-base-perl
  libxml-sax-expat-perl libxml-sax-perl libyaml-0-2 lmodern luatex pandoc-data
  pgf prosper ps2eps ruby ruby1.9.1 tcl tcl8.6 tex-common tex-gyre
  texlive-base texlive-binaries texlive-extra-utils texlive-font-utils
```

&lt; snip &gt;

```
(Reading database ... 236394 files and directories currently installed.)
Preparing to unpack .../lib32z1_1%3a1.2.8.dfsg-1ubuntu1_amd64.deb ...
Unpacking lib32z1 (1:1.2.8.dfsg-1ubuntu1) ...
Selecting previously unselected package lib32z1-dev.
Preparing to unpack .../lib32z1-dev_1%3a1.2.8.dfsg-1ubuntu1_amd64.deb ...
Unpacking lib32z1-dev (1:1.2.8.dfsg-1ubuntu1) ...
Setting up lib32z1 (1:1.2.8.dfsg-1ubuntu1) ...
Setting up lib32z1-dev (1:1.2.8.dfsg-1ubuntu1) ...
Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

### Build module all

Build the modules by excuting build module all

```
staf@petronella:~/libreboot/libreboot/libreboot_r20160907_src$ ./build module all
Building bucts
rm -f bucts bucts.o
gcc  -DVERSION='"withoutgit"' -c bucts.c
gcc -o bucts bucts.o  -lpci


Building the utilities in coreboot
make: Entering directory `/home/staf/libreboot/libreboot_r20160907_src/coreboot/15fca66bf08db45937ce88b950491963654805b9/15fca66bf08db45937ce88b950491963654805b9/util/cbfstool'
    HOSTCC     cbfstool/cbfstool.o
    HOSTCC     cbfstool/common.o
    HOSTCC     cbfstool/compress.o
    HOSTCC     cbfstool/cbfs_hash.o
    HOSTCC     cbfstool/cbfs_image.o
    HOSTCC     cbfstool/cbfs-mkstage.o
    HOSTCC     cbfstool/cbfs-mkpayload.o
    HOSTCC     cbfstool/elfheaders.o
    HOSTCC     cbfstool/rmodule.o
    HOSTCC     cbfstool/xdr.o
    HOSTCC     cbfstool/fit.o
    HOSTCC     cbfstool/partitioned_file.o
```

&lt; snip &gt;

```
  Compile checking out/vgasrc/stdvgamodes.o
  Compile checking out/vgasrc/stdvgaio.o
  Compile checking out/vgasrc/clext.o
  Compile checking out/vgasrc/bochsvga.o
  Compile checking out/vgasrc/geodevga.o
  Compile checking out/vgasrc/cbvga.o
  Compiling whole program out/vgaccode16.raw.s
  Fixup VGA rom assembler
  Compiling (16bit) out/vgaentry.o
  Precompiling out/vgasrc/vgalayout.lds
  Linking out/vgarom.o
Version: ?-20170211_123929-petronella
  Extracting binary out/vgabios.bin.raw
  Finalizing rom out/vgabios.bin
staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

## Build the ROMS

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ ./build roms withgrub
Building ROM images with the GRUB payload
Creating GRUB ELF executable for configuration 'txtmode'


Creating GRUB ELF executable for configuration 'vesafb'


GRUB Helper script: build ROM images for 'd510mo'
M       3rdparty/vboot
Switched to branch 'grub_d510mo'
Switched to branch 'grub_d510mo'
No submodule mapping found in .gitmodules for path '3rdparty/vboot'
No submodule mapping found in .gitmodules for path '3rdparty/vboot'
```

&lt; snip &gt;

```
12288 bytes (12 kB) copied, 0,026113 s, 471 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0259776 s, 473 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0261767 s, 469 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0261144 s, 471 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0282761 s, 435 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0271539 s, 453 kB/s
12288+0 records in
12288+0 records out
12288 bytes (12 kB) copied, 0,0295147 s, 416 kB/s


staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

The rom build command creates a bin directory, verify that required roms are available.

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ cd bin/
staf@petronella:~/libreboot/libreboot_r20160907_src/bin$ ls -l
total 4
drwxrwxr-x 23 staf staf 4096 Feb  11 15:58 grub
staf@petronella:~/libreboot/libreboot_r20160907_src/bin$ cd grub/
staf@petronella:~/libreboot/libreboot_r20160907_src/bin/grub$ ls -l
total 84
drwxrwxr-x 2 staf staf 4096 Feb  11 15:28 d510mo
drwxrwxr-x 2 staf staf 4096 Feb  11 15:29 ga-g41m-es2l
drwxrwxr-x 2 staf staf 4096 Feb  11 15:30 kcma-d8
drwxrwxr-x 2 staf staf 4096 Feb  11 15:31 kgpe-d16
drwxrwxr-x 2 staf staf 4096 Feb  11 15:32 macbook21
drwxrwxr-x 2 staf staf 4096 Feb  11 15:33 qemu_i440fx_piix4
drwxrwxr-x 2 staf staf 4096 Feb  11 15:34 qemu_q35_ich9
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 r400_16mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 r400_4mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 r400_8mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t400_16mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t400_4mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t400_8mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t500_16mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t500_4mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 t500_8mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:58 t60
drwxrwxr-x 2 staf staf 4096 Feb  11 15:59 x200_16mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:58 x200_4mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:58 x200_8mb
drwxrwxr-x 2 staf staf 4096 Feb  11 15:58 x60
staf@petronella:~/libreboot/libreboot_r20160907_src/bin/grub$ 
```

```
staf@petronella:~/libreboot/libreboot_r20160907_src/bin/grub$ cd x60
staf@petronella:~/libreboot/libreboot_r20160907_src/bin/grub/x60$ ls -l
total 40960
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_deqwertz_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_deqwertz_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_esqwerty_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_esqwerty_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_frazerty_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_frazerty_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_frdvbepo_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_frdvbepo_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_itqwerty_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_itqwerty_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_svenska_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_svenska_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_ukdvorak_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_ukdvorak_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_ukqwerty_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_ukqwerty_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_usdvorak_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_usdvorak_vesafb.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_usqwerty_txtmode.rom
-rw-rw-r-- 1 staf staf 2097152 Feb  11 15:58 x60_usqwerty_vesafb.rom
```


# Libreboot Installation

## Backup

Backups are important. We'll first backup the orginal proprietary <a href="https://en.wikipedia.org/wiki/BIOS">BIOS</a> before we free the laptop and install a <a href="https://en.wikipedia.org/wiki/Free_software">Free Software firmware</a>

The documentation that I found (see Links below) describes that the backup has 2 step flashrom_lenovobios_sst &amp; flashrom_lenovobios_macronix.

The flashrom_lenovobios_macronix command fails on my Laptop/Table but I decided to continue with the installation since I didn't pay a lot for the laptop on ebay.be.

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo flashrom/flashrom_lenovobios_sst -p internal -r factory.bin
[sudo] password for staf: 
flashrom v0.9.9-unknown on Linux 3.13.0-108-lowlatency (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found chipset "Intel ICH7M".
Enabling flash write... WARNING: SPI Configuration Lockdown activated.
OK.
Found SST flash chip "SST25VF016B" (2048 kB, SPI) mapped at physical address 0x00000000ffe00000.
Reading flash... done.
staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

```
staf@petronella:~/libreboot/libreboot_r20160907_src/flashrom$ sudo ./flashrom_lenovobios_macronix -p internal -r factory.bin
flashrom v0.9.9-unknown on Linux 3.13.0-108-lowlatency (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found chipset "Intel ICH7M".
Enabling flash write... WARNING: SPI Configuration Lockdown activated.
OK.
No EEPROM/flash device found.
Note: flashrom can never write if the flash chip isn't found automatically.
staf@petronella:~/libreboot/libreboot_r20160907_src/flashrom$ 
```

## Install the rom

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./flash i945lenovo_firstflash bin/grub/x
x200_16mb/ x200_4mb/  x200_8mb/  x60/       
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./flash i945lenovo_firstflash bin/grub/x60/x60_
x60_deqwertz_txtmode.rom  x60_frazerty_txtmode.rom  x60_itqwerty_txtmode.rom  x60_ukdvorak_txtmode.rom  x60_usdvorak_txtmode.rom
x60_deqwertz_vesafb.rom   x60_frazerty_vesafb.rom   x60_itqwerty_vesafb.rom   x60_ukdvorak_vesafb.rom   x60_usdvorak_vesafb.rom
x60_esqwerty_txtmode.rom  x60_frdvbepo_txtmode.rom  x60_svenska_txtmode.rom   x60_ukqwerty_txtmode.rom  x60_usqwerty_txtmode.rom
x60_esqwerty_vesafb.rom   x60_frdvbepo_vesafb.rom   x60_svenska_vesafb.rom    x60_ukqwerty_vesafb.rom   x60_usqwerty_vesafb.rom
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./flash i945lenovo_firstflash bin/grub/x60/x60_us
x60_usdvorak_txtmode.rom  x60_usdvorak_vesafb.rom   x60_usqwerty_txtmode.rom  x60_usqwerty_vesafb.rom   
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./flash i945lenovo_firstflash bin/grub/x60/x60_usqwerty_vesafb.rom 
[sudo] password for staf: 
Mode selected: i945lenovo_firstflash
bucts utility version 'withoutgit'
Using LPC bridge 8086:27b9 at 0000:1f.00
Current BUC.TS=0 - 128kb address range 0xFFFE0000-0xFFFFFFFF is untranslated
Updated BUC.TS=1 - 64kb address ranges at 0xFFFE0000 and 0xFFFF0000 are swapped
flashrom v0.9.9-unknown on Linux 3.13.0-108-lowlatency (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found chipset "Intel ICH7M".
Enabling flash write... WARNING: SPI Configuration Lockdown activated.
OK.
Found SST flash chip "SST25VF016B" (2048 kB, SPI) mapped at physical address 0x00000000ffe00000.
Reading old flash chip contents... done.
Erasing and writing flash chip... spi_block_erase_20 failed during command execution at address 0x0
Reading current flash chip contents... done. Looking for another erase function.
spi_block_erase_52 failed during command execution at address 0x0
Reading current flash chip contents... done. Looking for another erase function.
Transaction error!
spi_block_erase_d8 failed during command execution at address 0x1f0000
Reading current flash chip contents... done. Looking for another erase function.
spi_chip_erase_60 failed during command execution
Reading current flash chip contents... done. Looking for another erase function.
spi_chip_erase_c7 failed during command execution
Looking for another erase function.
No usable erase functions left.
FAILED!
Uh oh. Erase/write failed. Checking if anything has changed.
Reading current flash chip contents... done.
Apparently at least some data has changed.
Your flash chip is in an unknown state.
Get help on IRC at chat.freenode.net (channel #flashrom) or
mail flashrom@flashrom.org with the subject "FAILED: <your board name>"!
-------------------------------------------------------------------------------
DO NOT REBOOT OR POWEROFF!
flashrom v0.9.9-unknown on Linux 3.13.0-108-lowlatency (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
Found chipset "Intel ICH7M".
Enabling flash write... WARNING: SPI Configuration Lockdown activated.
OK.
No EEPROM/flash device found.
Note: flashrom can never write if the flash chip isn't found automatically.
staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

Power down your system

```
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo poweroff

Broadcast message from staf@petronella
        (/dev/pts/7) at 16:11 ...

The system is going down for power off NOW!
staf@petronella:~/libreboot/libreboot_r20160907_src$ Connection to petronella closed by remote host.
Connection to petronella closed.
[staf@vicky ~]$ 
```

Wait 2 minutes and boot the system again. If you're lucky the system will boot with the Free Libreboot firmware.
Logon the system again and continue with the secondflash phase

```
[staf@vicky ~]$ ssh petronella 
C_GetAttributeValue failed: 18
no such identity: /home/staf/.ssh/id_rsa: No such file or directory
no such identity: /home/staf/.ssh/id_dsa: No such file or directory
no such identity: /home/staf/.ssh/id_ecdsa: No such file or directory
no such identity: /home/staf/.ssh/id_ed25519: No such file or directory
staf@petronella's password: 
Welcome to Trisquel GNU/Linux 7.0, Belenos (GNU/Linux 3.13.0-108-lowlatency x86_64)
   ___        ___               ___        ___       ___        ___        ___
  /\  \      /\  \      ___    /\  \      /\  \     /\__\      /\  \      /\__\
  \ \  \    /  \  \    /\  \  /  \  \    /  \  \   / /  /     /  \  \    / /  /
   \ \  \  / /\ \  \   \ \  \/ /\ \  \  / /\ \  \ / /  /     / /\ \  \  / /  /
   /  \  \/  \ \ \  \  /  \__\ \ \ \  \/ /  \ \  \ /  /  ___/  \ \ \  \/ /  /
  / /\ \__\/\ \ \ \__\/ /\/__/\ \ \ \__\/__/ \ \__\__/  /\__\/\ \ \ \__\/__/
 / /  \/__/_|  \/ /  / /  /\ \ \ \ \/__/\  \ / /  /  \ / /  /\ \ \ \/__/\  \
/ /  /      | |  /  / /__/  \ \ \ \__\ \ \/\/ /  / \  / /  /\ \ \ \__\ \ \  \
\/__/       | |\/__/\ \__\   \ \/ /  /  \    /  / \ \/ /  /  \ \ \/__/  \ \  \
            | |  |   \/__/    \  /  /    \  /  /   \  /  /    \ \__\     \ \__\
             \|__|             \/__/      \/__/     \/__/      \/__/      \/__/

Welcome to Trisquel GNU/Linux
Documentation: http://trisquel.info/wiki/

Last login: Sat Feb 11 15:43:11 2017 from 192.168.1.10
staf@petronella:~$ cd libreboot/libreboot
libreboot/               libreboot_r20160907_src/ 
staf@petronella:~$ cd libreboot/libreboot_r20160907_src/
staf@petronella:~/libreboot/libreboot_r20160907_src$  ./flash i945lenovo_secondflash bin/grub/x60/x60_usqwerty_vesafb.rom 
This script must be run as root
staf@petronella:~/libreboot/libreboot_r20160907_src$ ^C libreboot/libreboot_r20160907_src/
staf@petronella:~/libreboot/libreboot_r20160907_src$ sudo ./flash i945lenovo_secondflash bin/grub/x60/x60_usqwerty_vesafb.rom
[sudo] password for staf: 
Mode selected: i945lenovo_secondflash
flashrom v0.9.9-unknown on Linux 3.13.0-108-lowlatency (x86_64)
flashrom is free software, get the source code at https://flashrom.org

Calibrating delay loop... OK.
coreboot table found at 0xcbe9f000.
Found chipset "Intel ICH7M".
Enabling flash write... OK.
Found SST flash chip "SST25VF016B" (2048 kB, SPI) mapped at physical address 0x00000000ffe00000.
Reading old flash chip contents... done.
Erasing and writing flash chip... Erase/write done.
Verifying flash... VERIFIED.
bucts utility version 'withoutgit'
Using LPC bridge 8086:27b9 at 0000:1f.00
Current BUC.TS=1 - 64kb address ranges at 0xFFFE0000 and 0xFFFF0000 are swapped
Updated BUC.TS=0 - 128kb address range 0xFFFE0000-0xFFFFFFFF is untranslated
staf@petronella:~/libreboot/libreboot_r20160907_src$ 
```

The installation is completed! Reboot our system and enjoy your Free As In Freedom Laptop.

<img src="{{ '/images/x60_free.jpg'  | remove_first:'/' | absolute_url }}" class="centre" width="750" height="853" alt="Thinkpad"/>

<p style="font-style: italic;">
Have fun
</p>

# Links

* <a href="https://www.libreboot.org">https://www.libreboot.org</a>
* <a href="https://libreboot.org/docs/install/#rom">https://libreboot.org/docs/install/#rom</a>
* <a href="https://www.coreboot.org/Board:lenovo/x60/Installation">https://www.coreboot.org/Board:lenovo/x60/Installation</a>
* <a href="http://www.linuxjournal.com/content/libreboot-x60-part-ii-installation">http://www.linuxjournal.com/content/libreboot-x60-part-ii-installation</a>
