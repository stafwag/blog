---
layout: post
title: "Update your CPU microcode on Arch Linux"
date: 2018-02-10 08:33:01 +0100
comments: true
categories: [ "security", "spectre", "meltdown", "linux", "arch linux", "microcode" ] 
---

# Meltdown & spectre

With Meldown <a href="https://nvd.nist.gov/vuln/detail/CVE-2017-5754">https://nvd.nist.gov/vuln/detail/CVE-2017-5754</a>, Spectre Variant 1 <a href="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5753">https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5753</a> and Spectre Variant 2 <a href="https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5753">https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-5753</a> out in the wild there is a lot of confusing going about updating microcode. 

There is a "Spectre & Meltdown Checker" available at <a href="https://github.com/speed47/spectre-meltdown-checker">https://github.com/speed47/spectre-meltdown-checker</a>

Usage is very easy just clone the git repository and run the script. 

# Microcode

Microcode isn't uploaded to the CPU but loaded during the boot strap of the CPU.
Normally the BIOS upload the microcode to the CPU but this can also be done by the by the bootloader, or the operating system kernel.

## Grub

Normally you get an updated bios for your motherboard or computer vendor to get new microcode for your CPU.

But when your vendor hasn't released a new Bios yet or when you are using old hardware you might not get a new BIOS with updated microcode.

Lucky microcode can also loaded by bootloader this way you can get new microcode without a BIOS update if the new microcode cuase issues you disable it in the bootloader.

The process for Arch Linux is describe at the Arch Wiki <a href="https://wiki.archlinux.org/index.php/Microcode">https://wiki.archlinux.org/index.php/Microcode</a>

You'll find journey how to update the microcode on my Arch GNU/Linux system below.

### Current microcode

```
[staf@frija ~]$ dmesg | grep -i microcode
[    2.102649] microcode: sig=0x40661, pf=0x20, revision=0xa
[    2.102981] microcode: Microcode Update Driver: v2.01 <tigran@aivazian.fsnet.co.uk>, Peter Oruba
[staf@frija ~]$ 
```

### Install intel-ucode

```
[root@vicky ~]# pacman -Syy intel-ucode
:: Synchronizing package databases...
 core                     126.8 KiB  12.4M/s 00:00 [######################] 100%
 extra                   1629.4 KiB  11.4M/s 00:00 [######################] 100%
 community                  4.1 MiB  11.0M/s 00:00 [######################] 100%
 multilib                 167.2 KiB  8.16M/s 00:00 [######################] 100%
resolving dependencies...
looking for conflicting packages...

Packages (1) intel-ucode-20180108-1

Total Download Size:   1.12 MiB
Total Installed Size:  1.55 MiB

:: Proceed with installation? [Y/n] y
:: Retrieving packages...
 intel-ucode-2018010...  1145.0 KiB   916K/s 00:01 [######################] 100%
(1/1) checking keys in keyring                     [######################] 100%
(1/1) checking package integrity                   [######################] 100%
(1/1) loading package files                        [######################] 100%
(1/1) checking for file conflicts                  [######################] 100%
(1/1) checking available disk space                [######################] 100%
:: Processing package changes...
(1/1) installing intel-ucode                       [######################] 100%
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...
[root@vicky ~]# 
```

### Verify the available microcode for your CPU

```
[staf@frija ~]$ yaourt  iucode-tool
1 aur/iucode-tool 2.2-1 (59) (4.87)
    Tool to manipulate Intel® IA-32/X86-64 microcode bundles
==> Enter n° of packages to be installed (e.g., 1 2 3 or 1-3)
==> ----------------------------------------------------------
==> 1


==> Downloading iucode-tool PKGBUILD from AUR...
x .SRCINFO
x PKGBUILD
oxe commented on 2017-10-01 17:50			 
issue with pgp key and have tried various times and not sure what I might be doing wrong but why do you have so many self-signed sigs?

gpg --keyserver hkps.pool.sks-keyservers.net  --recv-keys C467A717507BBAFED3C160920BD9E81139CB4807

uid  Henrique de Moraes Holschuh hmh@debian.org
sig!3        0BD9E81139CB4807 2012-06-26  [self-signature]
uid  Henrique de Moraes Holschuh hmh@hmh.eng.br
sig!3        0BD9E81139CB4807 2012-06-26  [self-signature]
sub  A4B9D9AFC03142CD
sig!         0BD9E81139CB4807 2012-06-26  [self-signature]
sub  981C05C79F47CF26
sig!         0BD9E81139CB4807 2012-06-26  [self-signature]
sub  9137FBD3DE6F0A93
sig!         0BD9E81139CB4807 2014-03-23  [self-signature]
sub  FFDB99C00EABDE2E
sig!         0BD9E81139CB4807 2014-03-23  [self-signature]
sub  FE11BFA68B158E98
sig!         0BD9E81139CB4807 2016-03-26  [self-signature]
sub  A4B1618F7F267286
sig!         0BD9E81139CB4807 2016-03-26  [self-signature]
key 0BD9E81139CB4807:
6 duplicate signatures removed
45 signatures not checked due to missing keys
gpg: key 0BD9E81139CB4807: "Henrique de Moraes Holschuh hmh@hmh.eng.br" not changed
gpg: Total number processed: 1
gpg:              unchanged: 1

please advise

progandy commented on 2017-10-01 18:19			 
@oxe: I am not Henrique, so I don't know what he did with his key that it looks this strange, but it doesn't affect the package. The build works, and the signature is properly validated.

Cbhihe commented on 2017-10-10 19:12			 
Hi:
During install with '$ makepkg -sric ' I got: a PGP signature error: 

A simplified output follows because I am typing (not copy/pasting) this on a different box than the one (4.13.4.-1-ARCH) where the install took place:

== making package: iucode-tool 2.2-1 (Tue Oct 10...2017)
== Checking runtime dependencies...
== Checking buildtime dependencies...
== Retrieving sources...
downloads ok [...]
== Validating source files with sha256sums...
passed [...]
== Verifying source files with gpg...
iucode-tool_2.2.tar.xz ... FAILED (unknown public key FE11BFA68B158E98)
== ERROR: One or more PGP signatures could not be verified !

Can you explain that unknown PGP public key error ? 
Is it a problem on my side ? 
Please advise. I will be waiting for your response before I actually execute that code. Cheers.

progandy commented on 2017-10-13 15:28			 
@Cbhihe: I did not have time and then forgot, sorry. Still, it should be obvious from the previous comments that you need to import the key in your gpg keyring with gpg, as described in the wiki for makepkg [1],[2]

gpg --recv-keys FE11BFA68B158E98
or
gpg --recv-keys C467A717507BBAFED3C160920BD9E81139CB4807
or
gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys C467A717507BBAFED3C160920BD9E81139CB4807

[1]: https://wiki.archlinux.org/index.php/Makepkg#Signature_checking
[2]: https://wiki.archlinux.org/index.php/GnuPG#Use_a_keyserver

Cbhihe commented on 2017-10-14 17:40			 
Thank you. Yes it WAS obvious and I had tried 
gpg --recv-keys FE11BFA68B158E98
already, but for some reason I do not get, either the keyring did not register correctly or I screwed up something, or both. 

I have reinstalled the Gnome keyring, re-imported my saved signatures and  
gpg --keyserver hkps.pool.sks-keyservers.net --recv-keys C467A717507BBAFED3C160920BD9E81139CB4807
worked this time. :-)
Cheers.

iucode-tool 2.2-1  (2017-09-13 07:49)
( Unsupported package: Potentially dangerous ! )
==> Edit PKGBUILD ? [Y/n] ("A" to abort)
==> ------------------------------------
==> n

==> iucode-tool dependencies:


==> Continue building iucode-tool ? [Y/n]
==> -------------------------------------
==> 

==> Building and installing package
==> Making package: iucode-tool 2.2-1 (Sun Jan 21 12:48:37 CET 2018)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading iucode-tool_2.2.tar.xz...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  146k  100  146k    0     0  74948      0  0:00:02  0:00:02 --:--:-- 63193
  -> Downloading iucode-tool_2.2.tar.xz.asc...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   833  100   833    0     0    833      0  0:00:01  0:00:01 --:--:--   478
==> Validating source files with sha256sums...
    iucode-tool_2.2.tar.xz ... Passed
    iucode-tool_2.2.tar.xz.asc ... Skipped
==> Verifying source file signatures with gpg...
    iucode-tool_2.2.tar.xz ... Passed
==> Extracting sources...
  -> Extracting iucode-tool_2.2.tar.xz with bsdtar
==> Starting build()...
checking build system type... x86_64-pc-linux-gnu
checking host system type... x86_64-pc-linux-gnu
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
checking whether make sets $(MAKE)... yes
checking whether make supports nested variables... yes
checking whether configure.ac should try to override CFLAGS... no
checking whether configure.ac should try to override LDFLAGS... no
checking for style of include used by make... GNU
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables... 
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes
checking whether gcc accepts -g... yes
checking for gcc option to accept ISO C89... none needed
checking whether gcc understands -c and -o together... yes
checking dependency style of gcc... gcc3
checking how to run the C preprocessor... gcc -E
checking for grep that handles long lines and -e... /usr/bin/grep
checking for egrep... /usr/bin/grep -E
checking for ANSI C header files... yes
checking for sys/types.h... yes
checking for sys/stat.h... yes
checking for stdlib.h... yes
checking for string.h... yes
checking for memory.h... yes
checking for strings.h... yes
checking for inttypes.h... yes
checking for stdint.h... yes
checking for unistd.h... yes
checking minix/config.h usability... no
checking minix/config.h presence... no
checking for minix/config.h... no
checking whether it is safe to define __EXTENSIONS__... yes
checking for gcc... (cached) gcc
checking whether we are using the GNU C compiler... (cached) yes
checking whether gcc accepts -g... (cached) yes
checking for gcc option to accept ISO C89... (cached) none needed
checking whether gcc understands -c and -o together... (cached) yes
checking dependency style of gcc... (cached) gcc3
checking for ANSI C header files... (cached) yes
checking fcntl.h usability... yes
checking fcntl.h presence... yes
checking for fcntl.h... yes
checking for stdint.h... (cached) yes
checking for stdlib.h... (cached) yes
checking for string.h... (cached) yes
checking for unistd.h... (cached) yes
checking time.h usability... yes
checking time.h presence... yes
checking for time.h... yes
checking cpuid.h usability... yes
checking cpuid.h presence... yes
checking for cpuid.h... yes
checking whether byte ordering is bigendian... no
checking for inline... inline
checking for int32_t... yes
checking for size_t... yes
checking for ssize_t... yes
checking for uint16_t... yes
checking for uint32_t... yes
checking for uint8_t... yes
checking for stdlib.h... (cached) yes
checking for GNU libc compatible malloc... yes
checking for stdlib.h... (cached) yes
checking for GNU libc compatible realloc... yes
checking whether lstat correctly handles trailing slash... yes
checking whether stat accepts an empty string... no
checking for memset... yes
checking for strcasecmp... yes
checking for strdup... yes
checking for strerror... yes
checking for strrchr... yes
checking for strtoul... yes
checking for timegm... yes
checking for library containing argp_parse... none required
checking for special C compiler options needed for large files... no
checking for _FILE_OFFSET_BITS value needed for large files... no
checking for flockfile... yes
checking for fgets_unlocked... yes
configure: project-wide base CPPFLAGS: -D_FORTIFY_SOURCE=2
configure: project-wide base CFLAGS:   -march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt
configure: project-wide base LDFLAGS:  -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now
checking that generated files are newer than configure... done
configure: creating ./config.status
config.status: creating Makefile
config.status: creating iucode_tool.8
config.status: creating iucode_tool_config.h
config.status: executing depfiles commands
make  all-am
make[1]: Entering directory '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/src/iucode-tool-2.2'
gcc -DHAVE_CONFIG_H -I.   -D_FORTIFY_SOURCE=2  -march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt -MT intel_microcode.o -MD -MP -MF .deps/intel_microcode.Tpo -c -o intel_microcode.o intel_microcode.c
gcc -DHAVE_CONFIG_H -I.   -D_FORTIFY_SOURCE=2  -march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt -MT iucode_tool.o -MD -MP -MF .deps/iucode_tool.Tpo -c -o iucode_tool.o iucode_tool.c
mv -f .deps/intel_microcode.Tpo .deps/intel_microcode.Po
mv -f .deps/iucode_tool.Tpo .deps/iucode_tool.Po
gcc  -march=x86-64 -mtune=generic -O2 -pipe -fstack-protector-strong -fno-plt  -Wl,-O1,--sort-common,--as-needed,-z,relro,-z,now -o iucode_tool intel_microcode.o iucode_tool.o  
make[1]: Leaving directory '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/src/iucode-tool-2.2'
==> Entering fakeroot environment...
==> Starting package()...
make[1]: Entering directory '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/src/iucode-tool-2.2'
 /usr/bin/mkdir -p '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/pkg/iucode-tool//usr/bin'
 /usr/bin/mkdir -p '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/pkg/iucode-tool//usr/share/man/man8'
  /usr/bin/install -c iucode_tool '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/pkg/iucode-tool//usr/bin'
 /usr/bin/install -c -m 644 iucode_tool.8 '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/pkg/iucode-tool//usr/share/man/man8'
make[1]: Leaving directory '/home/staf/tmp/yaourt-tmp-staf/aur-iucode-tool/src/iucode-tool-2.2'
==> Tidying install...
  -> Removing libtool files...
  -> Purging unwanted files...
  -> Removing static library files...
  -> Stripping unneeded symbols from binaries and libraries...
  -> Compressing man and info pages...
==> Checking for packaging issue...
==> Creating package "iucode-tool"...
  -> Generating .PKGINFO file...
  -> Generating .BUILDINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: iucode-tool 2.2-1 (Sun Jan 21 12:48:44 CET 2018)
==> Cleaning up...

==> Continue installing iucode-tool ? [Y/n]
==> [v]iew package contents [c]heck package with namcap
==> ---------------------------------------------------
==> y

loading packages...
resolving dependencies...
looking for conflicting packages...

Packages (1) iucode-tool-2.2-1

Total Installed Size:  0.06 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                   [####################################] 100%
(1/1) checking package integrity                                 [####################################] 100%
(1/1) loading package files                                      [####################################] 100%
(1/1) checking for file conflicts                                [####################################] 100%
(1/1) checking available disk space                              [####################################] 100%
:: Processing package changes...
(1/1) installing iucode-tool                                     [####################################] 100%
ldconfig: File /usr/lib/libmlt.so.6.4.0 is empty, not checked.
ldconfig: File /usr/lib/libmlt++.so.6.4.0 is empty, not checked.
ldconfig: File /usr/lib32/libmng.so.2 is empty, not checked.
ldconfig: File /usr/lib32/libmng.so is empty, not checked.
ldconfig: File /usr/lib32/libmng.so.2.0.2 is empty, not checked.
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...
[staf@frija ~]$ 
```

```
[root@frija ~]# bsdtar -Oxf /boot/intel-ucode.img | iucode_tool -tb -lS - 
iucode_tool: system has processor(s) with signature 0x00040661
microcode bundle 1: (stdin)
selected microcodes:
  001/143: sig 0x00040661, pf_mask 0x32, 2017-11-20, rev 0x0018, size 25600
[root@frija ~]# 
```

### Recreate grub.cfg

grub-mkconfig will detect the microcode and add it the grub configuration.

```
[root@vicky ~]# grub-mkconfig -o /boot/grub/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-linux-lts
Found initrd image(s) in /boot: intel-ucode.img initramfs-linux-lts.img
Found fallback initrd image(s) in /boot: intel-ucode.img initramfs-linux-lts-fallback.img
Found linux image: /boot/vmlinuz-linux-hardened
Found initrd image(s) in /boot: intel-ucode.img initramfs-linux-hardened.img
Found fallback initrd image(s) in /boot: intel-ucode.img initramfs-linux-hardened-fallback.img
Found linux image: /boot/vmlinuz-linux-ck
Found initrd image(s) in /boot: intel-ucode.img initramfs-linux-ck.img
Found fallback initrd image(s) in /boot: intel-ucode.img initramfs-linux-ck-fallback.img
Found linux image: /boot/vmlinuz-linux
Found initrd image(s) in /boot: intel-ucode.img initramfs-linux.img
Found fallback initrd image(s) in /boot: intel-ucode.img initramfs-linux-fallback.img
done
[root@vicky ~]# 
```
When take a look at the newly created grub.cfg you see that microcode image is added to the initrd image.
If you new micro code cause issue you can just remove the entry in grub configuration

```
[root@vicky ~]# cat /boot/grub/grub.cfg | grep initrd
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-lts.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-lts-fallback.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-hardened.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-hardened-fallback.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-ck.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-ck-fallback.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux.img
	initrd  /__active/rootvol/boot/intel-ucode.img /__active/rootvol/boot/initramfs-linux-fallback.img
[root@vicky ~]# 

```

## Reboot your system and verify

```
[staf@frija ~]$ dmesg | grep -i microcode
[    0.000000] microcode: microcode updated early to revision 0x18, date = 2017-11-20
[    1.852726] microcode: sig=0x40661, pf=0x20, revision=0x18
[    1.853029] microcode: Microcode Update Driver: v2.2.
[staf@frija ~]$ 
```
***Have fun***
