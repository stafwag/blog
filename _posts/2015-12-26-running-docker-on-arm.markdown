---
layout: post
title: "Running Docker on ARM"
date: 2015-12-26 14:55:59 +0100
comments: true
categories: [ docker, arm, arch, odroid ] 
---
<img src="{{ '/images/odroid_2_euro.jpg'  | remove_first:'/' | absolute_url }}" class="right" width="500" height="256" alt="odroid"/>

I own an <a href="http://www.hardkernel.com/main/products/prdt_info.php?g_code=g138745696275">odroid u3</a> that I used for my media center with <a href="https://xbmc.org/">xbmc</a> while I like the performance of the <a href="https://en.wikipedia.org/wiki/Exynos">Exynos4412 CPU</a> but the drivers for the <a href="https://en.wikipedia.org/wiki/Mali_%28GPU%29">Mali GPU</a> aren't <a href="https://en.wikipedia.org/wiki/Open_source">opensource</a>.

I like <a href="https://en.wikipedia.org/wiki/ARM_architecture">ARM</a> but unfortunatelly a lot of the ARM <a href="https://en.wikipedia.org/wiki/System_on_a_chip">soc</a>'s  have no opensource drivers for the <a href="https://en.wikipedia.org/wiki/Graphics_processing_unit">GPU</a>

The manufacturer of the odroid u3 - <a href="http://www.hardkernel.com/">hardkernel</a> - provides <a href="http://com.odroid.com/sigong/nf_file_board/nfile_board.php?tag=ODROID-U3">ubuntu 14.04 images</a> with xbmc and mali support. It isn't possible to get the newer of version of xbmc - now <a href="http://www.kodi.org">kodi</a> - running, or I didn't succeed withit. I'll look for another solution for my media server needs this might be my <a href="https://www.raspberrypi.org/">raspberry pi</a> <a href="https://www.raspberrypi.org/products/model-b-plus/">1 model B+</a> that is laying around doing nothing running <a href="http://openelec.tv/">openelec</a><br /><br />
<img src="{{ '/images/odroid_u3_with_usbdisk.jpg'  | remove_first:'/' | absolute_url }}" class="left" width="500" height="352" alt="odroid"/>

Like I said I like the performance of the ordoid U3 that why I installed <a href="http://archlinuxarm.org/">archLinuxArm</a> to play with <a href="https://www.docker.com/">Docker</a>. I could have sticked with Ubuntu 14.04 but with Arch Linux I get more up-to-date software.

<a href="http://archlinuxarm.org/platforms/armv7/samsung/odroid-u3">The installion</a> was pretty straightforward even the <a href="https://wiki.archlinux.org/index.php/Docker">docker installation</a> was the same as on a <a href="https://en.wikipedia.org/wiki/X86">x86 platform</a>.<br /> 

Since we are using docker on arm we have to build our own docker base images instead of using the <a href="https://hub.docker.com/_/registry/">docker registery</a>. I have security concerns about installtion and using unsigned non-verified software anyway. If you build your own image it possible to audit/verify the build process.

## Creating your own docker base images

### Arch

To build a Arch Base Image download mkimage-arch.sh and mkimage-arch-pacman.conf from the Docker source <a href="https://github.com/docker/docker/blob/master/contrib/">https://github.com/docker/docker/blob/master/contrib/</a>

#### Download mkimage-arch.sh

```
staf@fanny arch]$ wget https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh
--2015-12-26 10:21:10--  https://raw.githubusercontent.com/docker/docker/master/contrib/mkimage-arch.sh
Resolving raw.githubusercontent.com (raw.githubusercontent.com)... 23.235.43.133
Connecting to raw.githubusercontent.com (raw.githubusercontent.com)|23.235.43.133|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 2351 (2.3K) [text/plain]
Saving to: 'mkimage-arch.sh'

mkimage-arch.sh                     100%[=====================================================================>]   2.30K  --.-KB/s   in 0s     

2015-12-26 10:21:10 (144 MB/s) - 'mkimage-arch.sh' saved [2351/2351]

[staf@fanny arch]$ chmod +x mkimage-arch.sh 
[staf@fanny arch]$ 
```

#### Increase the timeout

```
[staf@fanny arch]$ sed -i 's/timeout 60/timeout 120/' mkimage-arch.sh
[staf@fanny arch]$ 
```

#### Copy pacman.conf

```
[staf@fanny arch]$ cp /etc/pacman.conf mkimage-arch-pacman.conf
[staf@fanny arch]$ 
```

#### Install the arch keyring

```
[staf@fanny debian]$ sudo pacman -Ss keyring                                                                                                                                                                                                                                                                                                                                                                                             
core/archlinux-keyring 20151206-1                                                                                                                                                                                                                                                                                                                                                                                                        
    Arch Linux PGP keyring                                                                                                                                                                                                                                                                                                                                                                                                               
core/archlinuxarm-keyring 20140119-1                                                                                                                                                                                                                                                                                                                                                                                                     
    Arch Linux ARM PGP keyring                                                                                                                                                                                                                                                                                                                                                                                                           
extra/gnome-keyring 1:3.18.3-1 (gnome)                                                                                                                                                                                                                                                                                                                                                                                                   
    GNOME Password Management daemon                                                                                                                                                                                                                                                                                                                                                                                                     
extra/gnome-keyring-sharp 1.0.2-5                                                                                                                                                                                                                                                                                                                                                                                                        
    A fully managed implementation of libgnome-keyring                                                                                                                                                                                                                                                                                                                                                                                   
extra/libgnome-keyring 3.12.0-2                                                                                                                                                                                                                                                                                                                                                                                                          
    GNOME keyring client library                                                                                                                                                                                                                                                                                                                                                                                                         
extra/python2-gnomekeyring 2.32.0-15                                                                                                                                                                                                                                                                                                                                                                                                     
    Python bindings for libgnome-keyring                                                                                                                                                                                                                                                                                                                                                                                                 
community/python-keyring 5.7.1-1                                                                                                                                                                                                                                                                                                                                                                                                         
    Store and access your passwords safely.                                                                                                                                                                                                                                                                                                                                                                                              
community/python2-keyring 5.7.1-1                                                                                                                                                                                                                                                                                                                                                                                                        
    Store and access your passwords safely.                                                                                                                                                                                                                                                                                                                                                                                              
[staf@fanny debian]$ sudo pacman -S archlinuxarm-keyring                                                                                                                                                                                                                                                                                                                                                                                 
resolving dependencies...                                                                                                                                                                                                                                                                                                                                                                                                                
looking for conflicting packages...                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                         
Packages (1) archlinuxarm-keyring-20140119-1                                                                                                                                                                                                                                                                                                                                                                                             
                                                                                                                                                                                                                                                                                                                                                                                                                                         
Total Download Size:   0.01 MiB                                                                                                                                                                                                                                                                                                                                                                                                          
Total Installed Size:  0.03 MiB                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                         
:: Proceed with installation? [Y/n] y                                                                                                                                                                                                                                                                                                                                                                                                    
:: Retrieving packages ...                                                                                                                                                                                                                                                                                                                                                                                                               
 archlinuxarm-keyring-20140119-1-any                                                                                                                                                                                                    12.2 KiB  1218K/s 00:00 [##################################################################################################################################################################] 100%
(1/1) checking keys in keyring                                                                                                                                                                                                                                  [##################################################################################################################################################################] 100%
(1/1) checking package integrity                                                                                                                                                                                                                                [##################################################################################################################################################################] 100%
(1/1) loading package files                                                                                                                                                                                                                                     [##################################################################################################################################################################] 100%
(1/1) checking for file conflicts                                                                                                                                                                                                                               [##################################################################################################################################################################] 100%
(1/1) checking available disk space                                                                                                                                                                                                                             [##################################################################################################################################################################] 100%
(1/1) installing archlinuxarm-keyring                                                                                                                                                                                                                           [##################################################################################################################################################################] 100%
[staf@fanny debian]$ sudo pacman -S archlinux-keyring                                                                                                                                                                                                                                                                                                                                                                                    
resolving dependencies...                                                                                                                                                                                                                                                                                                                                                                                                                
looking for conflicting packages...                                                                                                                                                                                                                                                                                                                                                                                                      
                                                                                                                                                                                                                                                                                                                                                                                                                                         
Packages (1) archlinux-keyring-20151206-1                                                                                                                                                                                                                                                                                                                                                                                                
                                                                                                                                                                                                                                                                                                                                                                                                                                         
Total Download Size:   0.49 MiB                                                                                                                                                                                                                                                                                                                                                                                                          
Total Installed Size:  0.70 MiB                                                                                                                                                                                                                                                                                                                                                                                                          
                                                                                                                                                                                                                                                                                                                                                                                                                                         
:: Proceed with installation? [Y/n] y                                                                                                                                                                                                                                                                                                                                                                                                    
:: Retrieving packages ...                                                                                                                                                                                                                                                                                                                                                                                                               
 archlinux-keyring-20151206-1-any                                                                                                                                                                                                      505.5 KiB   231K/s 00:02 [##################################################################################################################################################################] 100%
(1/1) checking keys in keyring                                                                                                                                                                                                                                  [##################################################################################################################################################################] 100%
(1/1) checking package integrity                                                                                                                                                                                                                                [##################################################################################################################################################################] 100%
(1/1) loading package files                                                                                                                                                                                                                                     [##################################################################################################################################################################] 100%
(1/1) checking for file conflicts                                                                                                                                                                                                                               [##################################################################################################################################################################] 100%
(1/1) checking available disk space                                                                                                                                                                                                                             [##################################################################################################################################################################] 100%
(1/1) installing archlinux-keyring                                                                                                                                                                                                                              [##################################################################################################################################################################] 100%
[staf@fanny debian]$                                                                                                                                                                                                                                                                                                                                                                                                                     
```

#### Create the base Arch Image

```
[staf@fanny arch]$ sudo LC_ALL=C TMPDIR=`pwd`/tmp ./mkimage-arch.sh
spawn pacstrap -C ./mkimage-arch-pacman.conf -c -d -G -i /home/staf/docker/docker/base-images/arch/tmp/rootfs-archlinux-eYGavMPZLd base haveged --ignore cryptsetup,device-mapper,dhcpcd,iproute2,jfsutils,linux,lvm2,man-db,man-pages,mdadm,nano,netctl,openresolv,pciutils,pcmciautils,reiserfsprogs,s-nail,systemd-sysvcompat,usbutils,vi,xfsprogs
==> Creating install root at /home/staf/docker/docker/base-images/arch/tmp/rootfs-archlinux-eYGavMPZLd
==> Installing packages to /home/staf/docker/docker/base-images/arch/tmp/rootfs-archlinux-eYGavMPZLd
:: Synchronizing package databases...
 core                                                         210.4 KiB   288K/s 00:01 [##################################################] 100%
 extra                                                          2.3 MiB   409K/s 00:06 [##################################################] 100%
 community                                                      3.2 MiB   314K/s 00:10 [##################################################] 100%
 alarm                                                        105.4 KiB  77.8K/s 00:01 [##################################################] 100%
 aur                                                           31.2 KiB   164K/s 00:00 [##################################################] 100%
:: cryptsetup is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: device-mapper is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: dhcpcd is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: iproute2 is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: jfsutils is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: lvm2 is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: man-db is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: man-pages is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: mdadm is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: nano is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: netctl is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: pciutils is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: reiserfsprogs is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: s-nail is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: systemd-sysvcompat is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: usbutils is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: vi is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: xfsprogs is in IgnorePkg/IgnoreGroup. Install anyway? [Y/n] n
:: There are 31 members in group base:
:: Repository core
   1) bash  2) bzip2  3) coreutils  4) diffutils  5) e2fsprogs  6) file  7) filesystem  8) findutils  9) gawk  10) gcc-libs  11) gettext
   12) glibc  13) grep  14) gzip  15) inetutils  16) iputils  17) less  18) licenses  19) logrotate  20) pacman  21) pacman-mirrorlist
   22) perl  23) procps-ng  24) psmisc  25) sed  26) shadow  27) sysfsutils  28) tar  29) texinfo  30) util-linux  31) which

Enter a selection (default=all): 
resolving dependencies...
looking for conflicting packages...

Packages (86) acl-2.2.52-2  attr-2.4.47-1  ca-certificates-20150402-1  ca-certificates-cacert-20140824-2  ca-certificates-mozilla-3.20.1-1
              ca-certificates-utils-20150402-1  cracklib-2.9.4-1  curl-7.46.0-1  db-5.3.28-3  expat-2.1.0-4  gdbm-1.11-1  glib2-2.46.2-2
              gmp-6.1.0-2  gnupg-2.1.10-3  gnutls-3.4.7-2  gpgme-1.6.0-2  iana-etc-20151016-1  keyutils-1.5.9-1  krb5-1.13.2-1
              libarchive-3.1.2-8  libassuan-2.4.2-1  libcap-2.24-2  libffi-3.2.1-1  libgcrypt-1.6.4-1  libgpg-error-1.21-1  libidn-1.32-1
              libksba-1.3.3-1  libldap-2.4.42-2  libsasl-2.1.26-7  libssh2-1.6.0-1  libsystemd-228-3  libtasn1-4.7-1  libtirpc-1.0.1-2
              libunistring-0.9.6-1  libutil-linux-2.27.1-1  linux-api-headers-4.1.4-1  lz4-131-1  lzo-2.09-1  mpfr-3.1.3.p4-1  ncurses-6.0-4
              nettle-3.1.1-1  npth-1.2-1  openssl-1.0.2.e-1  p11-kit-0.23.1-3  pam-1.2.1-3  pambase-20130928-1  pcre-8.38-2  pinentry-0.9.7-1
              popt-1.16-7  readline-6.3.008-3  sqlite-3.9.2-1  tzdata-2015g-1  xz-5.2.2-1  zlib-1.2.8-4  bash-4.3.042-4  bzip2-1.0.6-5
              coreutils-8.24-1  diffutils-3.3-2  e2fsprogs-1.42.13-1  file-5.25-1  filesystem-2015.09-1  findutils-4.4.2-6  gawk-4.1.3-1
              gcc-libs-5.3.0-3  gettext-0.19.6-2  glibc-2.22-3  grep-2.22-1  gzip-1.6-1  haveged-1.9.1-2  inetutils-1.9.4-2.1
              iputils-20140519.fad11dc-1  less-481-2  licenses-20140629-1  logrotate-3.9.1-1  pacman-4.2.1-4  pacman-mirrorlist-20151217-1
              perl-5.22.1-1  procps-ng-3.3.11-2  psmisc-22.21-3  sed-4.2.2-3  shadow-4.2.1-3  sysfsutils-2.1.0-9  tar-1.28-1  texinfo-6.0-1
              util-linux-2.27.1-1  which-2.21-1

Total Installed Size:  272.82 MiB

:: Proceed with installation? [Y/n] y
(86/86) checking keys in keyring                                                       [##################################################] 100%
(86/86) checking package integrity                                                     [##################################################] 100%
(86/86) loading package files                                                          [##################################################] 100%
(86/86) checking for file conflicts                                                    [##################################################] 100%
(86/86) checking available disk space                                                  [##################################################] 100%
( 1/86) installing linux-api-headers                                                   [##################################################] 100%
( 2/86) installing tzdata                                                              [##################################################] 100%
( 3/86) installing iana-etc                                                            [##################################################] 100%
( 4/86) installing filesystem                                                          [##################################################] 100%
( 5/86) installing glibc                                                               [##################################################] 100%
( 6/86) installing gcc-libs                                                            [##################################################] 100%
( 7/86) installing ncurses                                                             [##################################################] 100%
( 8/86) installing readline                                                            [##################################################] 100%
( 9/86) installing bash                                                                [##################################################] 100%
Optional dependencies for bash
    bash-completion: for tab completion
(10/86) installing bzip2                                                               [##################################################] 100%
(11/86) installing attr                                                                [##################################################] 100%
(12/86) installing acl                                                                 [##################################################] 100%
(13/86) installing gmp                                                                 [##################################################] 100%
(14/86) installing libcap                                                              [##################################################] 100%
(15/86) installing zlib                                                                [##################################################] 100%
(16/86) installing gdbm                                                                [##################################################] 100%
(17/86) installing db                                                                  [##################################################] 100%
(18/86) installing perl                                                                [##################################################] 100%
(19/86) installing openssl                                                             [##################################################] 100%
Optional dependencies for openssl
    ca-certificates [pending]
(20/86) installing coreutils                                                           [##################################################] 100%
(21/86) installing diffutils                                                           [##################################################] 100%
(22/86) installing libutil-linux                                                       [##################################################] 100%
(23/86) installing e2fsprogs                                                           [##################################################] 100%
(24/86) installing file                                                                [##################################################] 100%
(25/86) installing findutils                                                           [##################################################] 100%
(26/86) installing mpfr                                                                [##################################################] 100%
(27/86) installing gawk                                                                [##################################################] 100%
(28/86) installing pcre                                                                [##################################################] 100%
(29/86) installing libffi                                                              [##################################################] 100%
(30/86) installing glib2                                                               [##################################################] 100%
Optional dependencies for glib2
    python2: for gdbus-codegen and gtester-report
    libelf: gresource inspection tool
(31/86) installing libunistring                                                        [##################################################] 100%
(32/86) installing gettext                                                             [##################################################] 100%
Optional dependencies for gettext
    git: for autopoint infrastructure updates
(33/86) installing grep                                                                [##################################################] 100%
(34/86) installing less                                                                [##################################################] 100%
(35/86) installing gzip                                                                [##################################################] 100%
(36/86) installing cracklib                                                            [##################################################] 100%
(37/86) installing libsasl                                                             [##################################################] 100%
(38/86) installing libldap                                                             [##################################################] 100%
(39/86) installing keyutils                                                            [##################################################] 100%
(40/86) installing krb5                                                                [##################################################] 100%
(41/86) installing libtirpc                                                            [##################################################] 100%
(42/86) installing pambase                                                             [##################################################] 100%
(43/86) installing pam                                                                 [##################################################] 100%
(44/86) installing inetutils                                                           [##################################################] 100%
(45/86) installing sysfsutils                                                          [##################################################] 100%
(46/86) installing iputils                                                             [##################################################] 100%
Optional dependencies for iputils
    xinetd: for tftpd
(47/86) installing licenses                                                            [##################################################] 100%
(48/86) installing popt                                                                [##################################################] 100%
(49/86) installing logrotate                                                           [##################################################] 100%
(50/86) installing expat                                                               [##################################################] 100%
(51/86) installing lzo                                                                 [##################################################] 100%
(52/86) installing xz                                                                  [##################################################] 100%
(53/86) installing libarchive                                                          [##################################################] 100%
(54/86) installing texinfo                                                             [##################################################] 100%
(55/86) installing libtasn1                                                            [##################################################] 100%
(56/86) installing p11-kit                                                             [##################################################] 100%
(57/86) installing ca-certificates-utils                                               [##################################################] 100%
(58/86) installing ca-certificates-mozilla                                             [##################################################] 100%
(59/86) installing ca-certificates-cacert                                              [##################################################] 100%
(60/86) installing ca-certificates                                                     [##################################################] 100%
(61/86) installing libidn                                                              [##################################################] 100%
(62/86) installing libssh2                                                             [##################################################] 100%
(63/86) installing curl                                                                [##################################################] 100%
(64/86) installing libgpg-error                                                        [##################################################] 100%
(65/86) installing npth                                                                [##################################################] 100%
(66/86) installing libgcrypt                                                           [##################################################] 100%
(67/86) installing libksba                                                             [##################################################] 100%
(68/86) installing libassuan                                                           [##################################################] 100%
(69/86) installing pinentry                                                            [##################################################] 100%
Optional dependencies for pinentry
    gtk2: gtk2 backend
    qt5-base: qt backend
    gcr: gnome3 backend
(70/86) installing nettle                                                              [##################################################] 100%
(71/86) installing gnutls                                                              [##################################################] 100%
Optional dependencies for gnutls
    guile: for use with Guile bindings
(72/86) installing sqlite                                                              [##################################################] 100%
(73/86) installing gnupg                                                               [##################################################] 100%
Optional dependencies for gnupg
    libldap: gpg2keys_ldap [installed]
    libusb-compat: scdaemon
(74/86) installing gpgme                                                               [##################################################] 100%
(75/86) installing pacman-mirrorlist                                                   [##################################################] 100%
(76/86) installing pacman                                                              [##################################################] 100%
Optional dependencies for pacman
    fakeroot: for makepkg usage as normal user
(77/86) installing lz4                                                                 [##################################################] 100%
(78/86) installing libsystemd                                                          [##################################################] 100%
(79/86) installing procps-ng                                                           [##################################################] 100%
(80/86) installing psmisc                                                              [##################################################] 100%
(81/86) installing sed                                                                 [##################################################] 100%
(82/86) installing shadow                                                              [##################################################] 100%
(83/86) installing tar                                                                 [##################################################] 100%
(84/86) installing util-linux                                                          [##################################################] 100%
Optional dependencies for util-linux
    python: python bindings to libmount
(85/86) installing which                                                               [##################################################] 100%
(86/86) installing haveged                                                             [##################################################] 100%
gpg: /etc/pacman.d/gnupg/trustdb.gpg: trustdb created
gpg: no ultimately trusted keys found
gpg: starting migration from earlier GnuPG versions
gpg: porting secret keys from '/etc/pacman.d/gnupg/secring.gpg' to gpg-agent
gpg: migration succeeded
gpg: Generating pacman keyring master key...
gpg: key 4C4DCB68 marked as ultimately trusted
gpg: directory '/etc/pacman.d/gnupg/openpgp-revocs.d' created
gpg: Done
==> Updating trust database...
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
checking dependencies...

Packages (1) haveged-1.9.1-2

Total Removed Size:  0.18 MiB

:: Do you want to remove these packages? [Y/n] 
(1/1) removing haveged                                                                 [##################################################] 100%
==> ERROR: The keyring file /usr/share/pacman/keyrings/archlinux.gpg does not exist.
Generating locales...
  en_US.UTF-8... done
Generation complete.
tar: ./etc/pacman.d/gnupg/S.gpg-agent: socket ignored
5de54cc959c36d2064ee4389c0cc50acdb2246b3eac4edeb5e83cac7f4d9b350
Success.
[staf@fanny arch]$
```

#### Try it

```
[staf@fanny arch]$ docker run -t -i --rm archlinux /bin/bash
[root@6c24a79778f9 /]# 
```


### Debian

To create a debian base images you need <a href="https://wiki.debian.org/Debootstrap">debootstrap</a>. There is a <a href="https://aur.archlinux.org/">aur</a> available.

#### Install yaort

<a href="https://wiki.archlinux.org/index.php/Yaourt">Yaourt</a> is a nice tool to install aur ports.

##### Install the base development tools

```
[staf@fanny ~]$ sudo pacman -Sy base-devel
:: Synchronizing package databases...
 core                                                                      210.4 KiB   198K/s 00:01 [##########################################################] 100%
 extra                                                                       2.3 MiB   385K/s 00:06 [##########################################################] 100%
 community                                                                   3.2 MiB   208K/s 00:16 [##########################################################] 100%
 alarm                                                                     105.4 KiB   335K/s 00:00 [##########################################################] 100%
 aur                                                                        31.2 KiB  49.1K/s 00:01 [##########################################################] 100%
:: There are 25 members in group base-devel:
:: Repository core
   1) autoconf  2) automake  3) binutils  4) bison  5) fakeroot  6) file  7) findutils  8) flex  9) gawk  10) gcc  11) gettext  12) grep  13) groff  14) gzip
   15) libtool  16) m4  17) make  18) pacman  19) patch  20) pkg-config  21) sed  22) sudo  23) texinfo  24) util-linux  25) which

Enter a selection (default=all): 
warning: autoconf-2.69-2 is up to date -- reinstalling
warning: automake-1.15-1 is up to date -- reinstalling
warning: binutils-2.25.1-3 is up to date -- reinstalling
warning: bison-3.0.4-1 is up to date -- reinstalling
warning: fakeroot-1.20.2-1 is up to date -- reinstalling
warning: file-5.25-1 is up to date -- reinstalling
warning: findutils-4.4.2-6 is up to date -- reinstalling
warning: flex-2.6.0-1 is up to date -- reinstalling
warning: gawk-4.1.3-1 is up to date -- reinstalling
warning: gcc-5.3.0-3 is up to date -- reinstalling
warning: gettext-0.19.6-2 is up to date -- reinstalling
warning: grep-2.22-1 is up to date -- reinstalling
warning: groff-1.22.3-5 is up to date -- reinstalling
warning: gzip-1.6-1 is up to date -- reinstalling
warning: libtool-2.4.6-4 is up to date -- reinstalling
warning: m4-1.4.17-1 is up to date -- reinstalling
warning: make-4.1-1 is up to date -- reinstalling
warning: pacman-4.2.1-4 is up to date -- reinstalling
warning: patch-2.7.5-1 is up to date -- reinstalling
warning: pkg-config-0.29-1 is up to date -- reinstalling
warning: sed-4.2.2-3 is up to date -- reinstalling
warning: sudo-1.8.15-1 is up to date -- reinstalling
warning: texinfo-6.0-1 is up to date -- reinstalling
warning: util-linux-2.27.1-1 is up to date -- reinstalling
warning: which-2.21-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (25) autoconf-2.69-2  automake-1.15-1  binutils-2.25.1-3  bison-3.0.4-1  fakeroot-1.20.2-1  file-5.25-1  findutils-4.4.2-6  flex-2.6.0-1  gawk-4.1.3-1
              gcc-5.3.0-3  gettext-0.19.6-2  grep-2.22-1  groff-1.22.3-5  gzip-1.6-1  libtool-2.4.6-4  m4-1.4.17-1  make-4.1-1  pacman-4.2.1-4  patch-2.7.5-1
              pkg-config-0.29-1  sed-4.2.2-3  sudo-1.8.15-1  texinfo-6.0-1  util-linux-2.27.1-1  which-2.21-1

Total Installed Size:  166.11 MiB
Net Upgrade Size:        0.00 MiB

:: Proceed with installation? [Y/n] y
(25/25) checking keys in keyring                                                                    [##########################################################] 100%
(25/25) checking package integrity                                                                  [##########################################################] 100%
(25/25) loading package files                                                                       [##########################################################] 100%
(25/25) checking for file conflicts                                                                 [##########################################################] 100%
(25/25) checking available disk space                                                               [##########################################################] 100%
( 1/25) reinstalling gawk                                                                           [##########################################################] 100%
( 2/25) reinstalling m4                                                                             [##########################################################] 100%
( 3/25) reinstalling autoconf                                                                       [##########################################################] 100%
( 4/25) reinstalling automake                                                                       [##########################################################] 100%
( 5/25) reinstalling binutils                                                                       [##########################################################] 100%
( 6/25) reinstalling bison                                                                          [##########################################################] 100%
( 7/25) reinstalling sed                                                                            [##########################################################] 100%
( 8/25) reinstalling util-linux                                                                     [##########################################################] 100%
( 9/25) reinstalling fakeroot                                                                       [##########################################################] 100%
(10/25) reinstalling file                                                                           [##########################################################] 100%
(11/25) reinstalling findutils                                                                      [##########################################################] 100%
(12/25) reinstalling flex                                                                           [##########################################################] 100%
(13/25) reinstalling gcc                                                                            [##########################################################] 100%
(14/25) reinstalling gettext                                                                        [##########################################################] 100%
(15/25) reinstalling grep                                                                           [##########################################################] 100%
(16/25) reinstalling groff                                                                          [##########################################################] 100%
(17/25) reinstalling gzip                                                                           [##########################################################] 100%
(18/25) reinstalling libtool                                                                        [##########################################################] 100%
(19/25) reinstalling texinfo                                                                        [##########################################################] 100%
(20/25) reinstalling make                                                                           [##########################################################] 100%
(21/25) reinstalling pacman                                                                         [##########################################################] 100%
(22/25) reinstalling patch                                                                          [##########################################################] 100%
(23/25) reinstalling pkg-config                                                                     [##########################################################] 100%
(24/25) reinstalling sudo                                                                           [##########################################################] 100%
(25/25) reinstalling which                                                                          [##########################################################] 100%
[staf@fanny ~]$ 
```

##### Install git

```
staf@fanny ~]$ sudo pacman -S git        
warning: git-2.6.4-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (1) git-2.6.4-1

Total Installed Size:  22.92 MiB
Net Upgrade Size:       0.00 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                                      [##########################################################] 100%
(1/1) checking package integrity                                                                    [##########################################################] 100%
(1/1) loading package files                                                                         [##########################################################] 100%
(1/1) checking for file conflicts                                                                   [##########################################################] 100%
(1/1) checking available disk space                                                                 [##########################################################] 100%
(1/1) reinstalling git                                                                              [##########################################################] 100%
[staf@fanny ~]$ 
```

##### Install package-query 

###### git clone

```
[staf@fanny aur]$ git clone https://aur.archlinux.org/package-query.git 
Cloning into 'package-query'...
remote: Counting objects: 16, done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 16 (delta 0), reused 16 (delta 0)
Unpacking objects: 100% (16/16), done.
Checking connectivity... done.
[staf@fanny aur]$ 
```

##### makepkg

```
[staf@fanny aur]$ cd package-query/
[staf@fanny package-query]$ makepkg -sri
==> Making package: package-query 1.7-1 (Fri Dec 25 14:33:39 UTC 2015)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading package-query-1.7.tar.gz...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  380k  100  380k    0     0   413k      0 --:--:-- --:--:-- --:--:--  413k
==> Validating source files with md5sums...
    package-query-1.7.tar.gz ... Passed
==> Extracting sources...
  -> Extracting package-query-1.7.tar.gz with bsdtar
==> Starting build()...
checking for a BSD-compatible install... /usr/bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /usr/bin/mkdir -p
checking for gawk... gawk
<snip>
config.status: executing depfiles commands
config.status: executing libtool commands
config.status: executing po-directories commands

package-query:

  Build information:
    source code location   : .
    prefix                 : /usr
    sysconfdir             : /etc
       conf file           : /etc/pacman.conf
    localstatedir          : /var
       database dir        : /var/lib/pacman/
    compiler               : gcc
    compiler flags         : -march=armv7-a -mfloat-abi=hard -mfpu=vfpv3-d16 -O2 -pipe -fstack-protector --param=ssp-buffer-size=4

    package-query version  : 1.7
    using git version      : no
       git ver             : 

  Variable information:
    root working directory : /
    aur base url           : https://aur.archlinux.org

make  all-recursive
make[1]: Entering directory '/home/staf/git/aur/package-query/src/package-query-1.7'
Making all in src
make[2]: Entering directory '/home/staf/git/aur/package-query/src/package-query-1.7/src'
gcc -DLOCALEDIR=\"/usr/share/locale\" -DCONFFILE=\"/etc/pacman.conf\" -DROOTDIR=\"/\" -DDBPATH=\"/var/lib/pacman/\" -DAUR_BASE_URL=\"https://aur.archlinux.org\" -DHAVE_CONFIG_H  -I. -I..   -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -march=armv7-a -mfloat-abi=hard -mfpu=vfpv3-d16 -O2 -pipe -fstack-protector --param=ssp-buffer-size=4 -MT aur.o -MD -MP -MF .deps/aur.Tpo -c -o aur.o aur.c
mv -f .deps/aur.Tpo .deps/aur.Po
gcc -DLOCALEDIR=\"/usr/share/locale\" -DCONFFILE=\"/etc/pacman.conf\" -DROOTDIR=\"/\" -DDBPATH=\"/var/lib/pacman/\" -DAUR_BASE_URL=\"https://aur.archlinux.org\" -DHAVE_CONFIG_H  -I. -I..   -D_FORTIFY_SOURCE=2 -D_GNU_SOURCE -march=armv7-a -mfloat-abi=hard -mfpu=vfpv3-d16 -O2 -pipe -fstack-protector --param=ssp-buffer-size=4 -MT alpm-query.o -MD -MP -MF .deps/alpm-query.Tpo -c -o alpm-query.o alpm-query.c
alpm-query.c: In function 'alpm_pkg_get_realsize':
 /usr/bin/mkdir -p '/home/staf/git/aur/package-query/pkg/package-query/usr/share/man/man8'
<snip>
 /usr/bin/install -c -m 644 package-query.8 '/home/staf/git/aur/package-query/pkg/package-query/usr/share/man/man8'
make[2]: Leaving directory '/home/staf/git/aur/package-query/src/package-query-1.7/doc'
make[1]: Leaving directory '/home/staf/git/aur/package-query/src/package-query-1.7/doc'
make[1]: Entering directory '/home/staf/git/aur/package-query/src/package-query-1.7'
make[2]: Entering directory '/home/staf/git/aur/package-query/src/package-query-1.7'
make[2]: Nothing to be done for 'install-exec-am'.
make[2]: Nothing to be done for 'install-data-am'.
make[2]: Leaving directory '/home/staf/git/aur/package-query/src/package-query-1.7'
make[1]: Leaving directory '/home/staf/git/aur/package-query/src/package-query-1.7'
==> Tidying install...
  -> Purging unwanted files...
  -> Removing libtool files...
  -> Removing static library files...
  -> Compressing man and info pages...
  -> Stripping unneeded symbols from binaries and libraries...
==> Creating package "package-query"...
  -> Generating .PKGINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: package-query 1.7-1 (Fri Dec 25 14:34:02 UTC 2015)
==> Installing package package-query with pacman -U...
[sudo] password for staf: 
loading packages...
warning: package-query-1.7-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (1) package-query-1.7-1

Total Installed Size:  0.07 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                                      [##########################################################] 100%
(1/1) checking package integrity                                                                    [##########################################################] 100%
(1/1) loading package files                                                                         [##########################################################] 100%
(1/1) checking for file conflicts                                                                   [##########################################################] 100%
(1/1) checking available disk space                                                                 [##########################################################] 100%
(1/1) reinstalling package-query                                                                    [##########################################################] 100%
[staf@fanny package-query]$ 
```

##### Install yaourt 

###### git clone

```
[staf@fanny package-query]$ cd ~/git/aur   
staf@fanny aur]$ git clone https://aur.archlinux.org/yaourt.git  
Cloning into 'yaourt'...
remote: Counting objects: 14, done.
remote: Compressing objects: 100% (11/11), done.
remote: Total 14 (delta 3), reused 14 (delta 3)
Unpacking objects: 100% (14/14), done.
Checking connectivity... done.
[staf@fanny aur]$ 
``` 

###### makepkg

```
[staf@fanny yaourt]$ makepkg -sri
==> Making package: yaourt 1.7-1 (Fri Dec 25 14:44:12 UTC 2015)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading yaourt-1.7.tar.gz...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  123k  100  123k    0     0   222k      0 --:--:-- --:--:-- --:--:--  222k
==> Validating source files with md5sums...
    yaourt-1.7.tar.gz ... Passed
==> Extracting sources...
  -> Extracting yaourt-1.7.tar.gz with bsdtar
==> Starting build()...
        GEN yaourt.sh
        GEN pacdiffviewer.sh
        GEN yaourtrc
        GEN lib/util.sh
        GEN lib/pkgbuild.sh
        GEN lib/pacman.sh
        GEN lib/abs.sh
==> Entering fakeroot environment...
==> Starting package()...
/usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/usr/bin
/usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/etc
/usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/bash-completion/completions
/usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/man/man{5,8}
# Scripts
/usr/bin/env install -m755 yaourt.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/bin/yaourt
/usr/bin/env install -m755 pacdiffviewer.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/bin/pacdiffviewer
# Configuration
/usr/bin/env install -m644 yaourtrc /home/staf/git/aur/yaourt/pkg/yaourt/etc/yaourtrc
/usr/bin/env install -m644 bashcompletion /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/bash-completion/completions/yaourt
# Libs
/usr/bin/env install -m644 lib/alpm_backup.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/alpm_query.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/alpm_stats.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/abs.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/aur.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/util.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/io.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/pacman.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/pkgbuild.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
/usr/bin/env install -m644 lib/misc.sh /home/staf/git/aur/yaourt/pkg/yaourt/usr/lib/yaourt
# Man
/usr/bin/env install -m644 man/*.5 /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/man/man5
/usr/bin/env install -m644 man/*.8 /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/man/man8
# Locales
test -x /usr/bin/msgfmt && for file in po/*/*.po; \
do \
  package=$(echo $file | /bin/sed -e 's#po/\([^/]\+\).*#\1#'); \
  lang=$(echo $file | /bin/sed -e 's#.*/\([^/]\+\).po#\1#'); \
  /usr/bin/env install -d /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/locale/$lang/LC_MESSAGES; \
  /usr/bin/msgfmt -o /home/staf/git/aur/yaourt/pkg/yaourt/usr/share/locale/$lang/LC_MESSAGES/$package.mo $file; \
done
==> Tidying install...
  -> Purging unwanted files...
  -> Removing libtool files...
  -> Removing static library files...
  -> Compressing man and info pages...
  -> Stripping unneeded symbols from binaries and libraries...
==> Creating package "yaourt"...
  -> Generating .PKGINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: yaourt 1.7-1 (Fri Dec 25 14:44:16 UTC 2015)
==> Installing package yaourt with pacman -U...
[sudo] password for staf: 
loading packages...
warning: yaourt-1.7-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (1) yaourt-1.7-1

Total Installed Size:  0.72 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                                      [##########################################################] 100%
(1/1) checking package integrity                                                                    [##########################################################] 100%
(1/1) loading package files                                                                         [##########################################################] 100%
(1/1) checking for file conflicts                                                                   [##########################################################] 100%
(1/1) checking available disk space                                                                 [##########################################################] 100%
(1/1) reinstalling yaourt                                                                           [##########################################################] 100%
[staf@fanny yaourt]$ 
```


#### Install debootstrap

```
[staf@fanny ~]$ yaourt debootstrap
1 aur/cdebootstrap-static 0.6.5-1 (10)
    Bootstrap a Debian system
2 aur/debootstrap 1.0.75-1 [installed] (224)
    A tool used to create a Debian base system from scratch, without requiring the availability of dpkg or apt
3 aur/rinse 3.0.2-2 (0)
    Bootstrap a rpm based distribution like debootstrap
==> Enter n° of packages to be installed (ex: 1 2 3 or 1-3)
==> --------------------------------------------------------
==> 2


==> Downloading debootstrap PKGBUILD from AUR...
x .SRCINFO
x .gitignore
x PKGBUILD
zeilenleser commented on 2015-07-29 10:49 
Thanks for maintaining this package.

just for your information, version 1.0.72 is out since 2015-07-28

Regards

zeilenleser commented on 2015-07-29 12:13 
I followed @Tigrouzens suggestion with this modification

DEF_MIRROR="http://mirrors.kernel.org/ubuntu"

Since only DEF_HTTPS_MIRROR is used in my case I don't know if this works. Testing with the browser was successful.

bricewge commented on 2015-12-07 16:58 (last edited on 2015-12-07 16:58 by bricewge) 
@Tigrouzens why don't you want to install ubuntu-keyring?

Your advice didn't work for me, I still had the error about GPG. But after installing gnupg1 and ubuntu-keyring, enrering the following command worked fine.
# debootstrap wily ubuntu https://mirrors.kernel.org/ubuntu

abeutot commented on 2015-12-08 11:57 
Seems like there is a missing dependency to binutils since ar is needed to extract deb packages.

JonnyJD commented on 2015-12-08 12:12 
binutils is in the "base-devel" group which is an implicit requirement before using the AUR altogether:
https://wiki.archlinux.org/index.php/Arch_User_Repository#Prerequisites

debootstrap 1.0.75-1  (2015-11-12 16:15)
( Unsupported package: Potentially dangerous ! )
==> Edit PKGBUILD ? [Y/n] ("A" to abort)
==> ------------------------------------
==> n

==> debootstrap dependencies:
 - wget (already installed)


==> Continue building debootstrap ? [Y/n]
==> -------------------------------------
==> 
==> Building and installing package
==> Making package: debootstrap 1.0.75-1 (Fri Dec 25 14:48:55 UTC 2015)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading debootstrap_1.0.75_all.deb...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 65978  100 65978    0     0   155k      0 --:--:-- --:--:-- --:--:--  155k
==> Validating source files with md5sums...
    debootstrap_1.0.75_all.deb ... Passed
==> Extracting sources...
  -> Extracting debootstrap_1.0.75_all.deb with bsdtar
==> Entering fakeroot environment...
==> Starting package()...
==> Tidying install...
  -> Purging unwanted files...
  -> Removing libtool files...
  -> Removing static library files...
  -> Compressing man and info pages...
  -> Stripping unneeded symbols from binaries and libraries...
==> Creating package "debootstrap"...
  -> Generating .PKGINFO file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: debootstrap 1.0.75-1 (Fri Dec 25 14:48:57 UTC 2015)

==> Continue installing debootstrap ? [Y/n]
==> [v]iew package contents [c]heck package with namcap
==> ---------------------------------------------------
==> y

loading packages...
warning: debootstrap-1.0.75-1 is up to date -- reinstalling
resolving dependencies...
looking for conflicting packages...

Packages (1) debootstrap-1.0.75-1

Total Installed Size:  0.19 MiB
Net Upgrade Size:      0.00 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                                      [##########################################################] 100%
(1/1) checking package integrity                                                                    [##########################################################] 100%
(1/1) loading package files                                                                         [##########################################################] 100%
(1/1) checking for file conflicts                                                                   [##########################################################] 100%
(1/1) checking available disk space                                                                 [##########################################################] 100%
(1/1) reinstalling debootstrap                                                                      [##########################################################] 100%
[staf@fanny ~]$ 
```

#### gpg keyring

debootrap needs gnupg1 there is an aur available <a href="https://aur.archlinux.org/packages/gnupg1/">https://aur.archlinux.org/packages/gnupg1/</a> but armv7h isn't include in the supported architectures so we'll need to add it.   

##### Install gnupg1

###### Git clone

```
[staf@fanny ~]$ cd ~/git/aur
staf@fanny aur]$ git clone https://aur.archlinux.org/gnupg1.git
Cloning into 'gnupg1'...
remote: Counting objects: 8, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 8 (delta 0), reused 8 (delta 0)
Unpacking objects: 100% (8/8), done.
Checking connectivity... done.
[staf@fanny aur]$ 
```

###### Update PKGBUILD

Edit PKGBUILD 

```
[staf@fanny gnupg1]$ vi PKGBUILD 
```

and add armv7h to the arch

```
pkgdesc="GNU Privacy Guard - a PGP replacement tool"
arch=('i686' 'x86_64' 'armv6h' 'armv7h')
license=('GPL3')
depends=('zlib' 'bzip2' 'libldap>=2.4.18' 'libusb-compat' 'curl>=7.16.2' 'readline>=6.0.00')
```

###### Update the keyring

```
[staf@fanny gnupg1]$ gpg --keyserver pgpkeys.mit.edu --recv-keys 2071B08A33BD3F06 
gpg: key 33BD3F06: "NIIBE Yutaka (GnuPG Release Key) <gniibe@fsij.org>" not changed
gpg: Total number processed: 1
gpg:              unchanged: 1
[staf@fanny gnupg1]$ 
```

###### makepkg

```
[staf@fanny gnupg1]$ makepkg -sri
<snip>
  -> Adding install file...
  -> Generating .MTREE file...
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: gnupg1 1.4.19-4 (Sat Dec 26 13:49:19 UTC 2015)
==> Installing package gnupg1 with pacman -U...
[sudo] password for staf: 
loading packages...
resolving dependencies...
looking for conflicting packages...

Packages (1) gnupg1-1.4.19-4

Total Installed Size:  4.97 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                         [##################################################] 100%
(1/1) checking package integrity                                                       [##################################################] 100%
(1/1) loading package files                                                            [##################################################] 100%
(1/1) checking for file conflicts                                                      [##################################################] 100%
(1/1) checking available disk space                                                    [##################################################] 100%
(1/1) installing gnupg1                                                                [##################################################] 100%
[staf@fanny gnupg1]$ 
```


##### Install the  debian-archive-keyring aur


```
[staf@fanny debian]$ yaourt debian-archive-keyring 
1 aur/debian-archive-keyring 2014.3-2 (59)
    GnuPG archive keys of the Debian archive
==> Enter n° of packages to be installed (ex: 1 2 3 or 1-3)
==> --------------------------------------------------------
==> 1


==> Downloading debian-archive-keyring PKGBUILD from AUR...
x .SRCINFO
x PKGBUILD
eworm commented on 2013-05-13 12:20 
Please use package() function, recent makepkg warns about that.

hcartiaux commented on 2013-05-15 08:00 
Fixed

ansys commented on 2014-10-24 11:31 
New url http://ftp.fr.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2014.1_all.deb

kozaki commented on 2014-12-11 14:58 
Update
url: http://ftp.fr.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2014.3_all.deb
md5: 02b6818bd7cada9ef9d24534290b559c

Thank you.

debian-archive-keyring 2014.3-2  (2015-06-08 20:20)
( Unsupported package: Potentially dangerous ! )
==> Edit PKGBUILD ? [Y/n] ("A" to abort)
==> ------------------------------------
==> n

==> debian-archive-keyring dependencies:
 - gnupg (already installed)


==> Continue building debian-archive-keyring ? [Y/n]
==> ------------------------------------------------
==> 
==> Building and installing package
==> Making package: debian-archive-keyring 2014.3-2 (Sat Dec 26 13:02:52 UTC 2015)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Downloading debian-archive-keyring_2014.3_all.deb...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 40060  100 40060    0     0   103k      0 --:--:-- --:--:-- --:--:--  103k
==> Validating source files with md5sums...
    debian-archive-keyring_2014.3_all.deb ... Passed
==> Extracting sources...
  -> Extracting debian-archive-keyring_2014.3_all.deb with bsdtar
==> Entering fakeroot environment...
==> Starting package()...
./
./usr/
./usr/share/
<snip>

==> Continue installing debian-archive-keyring ? [Y/n]
==> [v]iew package contents [c]heck package with namcap
==> ---------------------------------------------------
==> y

loading packages...
resolving dependencies...
looking for conflicting packages...

Packages (1) debian-archive-keyring-2014.3-2

Total Installed Size:  0.07 MiB

:: Proceed with installation? [Y/n] y
(1/1) checking keys in keyring                                                                                                                                                                                                                                  [##################################################################################################################################################################] 100%
(1/1) checking package integrity                                                                                                                                                                                                                                [##################################################################################################################################################################] 100%
(1/1) loading package files                                                                                                                                                                                                                                     [##################################################################################################################################################################] 100%
(1/1) checking for file conflicts                                                                                                                                                                                                                               [##################################################################################################################################################################] 100%
(1/1) checking available disk space                                                                                                                                                                                                                             [##################################################################################################################################################################] 100%
(1/1) installing debian-archive-keyring                                                                                                                                                                                                                         [##################################################################################################################################################################] 100%
[staf@fanny debian]$ 
```

#### debootstrap

```
[staf@fanny debian]$ sudo debootstrap --verbose --include=iproute,iputils-ping --arch armhf jessie ./jessie-chroot http://http.debian.net/debian/
[staf@fanny debian]$ sudo debootstrap --verbose --include=iproute,iputils-ping --arch armhf jessie ./jessie-chroot http://http.debian.net/debian/
[sudo] password for staf: 
I: Retrieving Release 
I: Retrieving Release.gpg 
I: Checking Release signature
I: Valid Release signature (key id 75DDC3C4A499F1A18CB5F3C8CBF8D6FD518E17E1)
<snip>
I: Configuring libgnutls-openssl27:armhf...
I: Configuring iputils-ping...
I: Configuring isc-dhcp-common...
I: Configuring isc-dhcp-client...
I: Configuring tasksel...
I: Configuring tasksel-data...
I: Configuring libc-bin...
I: Configuring systemd...
I: Base system installed successfully.

```

#### Import

```
staf@fanny jessie-chroot]$ sudo tar cpf - . | docker import - debian
[sudo] password for staf: 
1ec165fa2ccb264ab8196b8cd0c339b5d95e1b90879019cde0c633cca738277a
[staf@fanny jessie-chroot]$ 
```

#### Try it

```
staf@fanny jessie-chroot]$ docker run -t -i --rm debian /bin/bash
root@81afce29909f:/# cat /etc/debian_version 
8.2
root@81afce29909f:/# 
```


*** Have fun ... ***


#### Links

* <a href="http://archlinuxarm.org/">http://archlinuxarm.org/</a> 
* <a href="http://archlinuxarm.org/platforms/armv7/samsung/odroid-u3">http://archlinuxarm.org/platforms/armv7/samsung/odroid-u3</a>
* <a href="https://wiki.archlinux.org/index.php/Docker">https://wiki.archlinux.org/index.php/Docker</a>
* <a href="http://forum.odroid.com/viewtopic.php?f=98&t=6638">http://forum.odroid.com/viewtopic.php?f=98&t=6638">[Docker] lightweight virtualisation for your odroid host</a>




