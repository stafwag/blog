---
layout: post
title: "zfs on Fedora 20"
date: 2014-01-14 08:03
comments: true
categories: [ zfs, fedora, linux ] 
---

With <a href="http://docs.fedoraproject.org/en-US/Fedora/20/html/Release_Notes/index.html">Fedora 20</a> being released a few weeks ago and no official zfsonlinux support for Fedora 20. It time to get zfs on linux working on Fedora 20.

Zfs on linux 2.6.2 required a custom DKMS package. Lucky the patches that were required for zfs on linux are already integrated into Fedora: <a href="http://negativo17.org/dkms-patches-for-zfs-on-linux-merged/">http://negativo17.org/dkms-patches-for-zfs-on-linux-merged/</a>

So lets try to build the rpm packages for Fedora 20 from the source.

#### Solaris Portability Layer (SPL)

##### clone the spl git repository

```
[root@vicky ]# cd /usr/src/zfsfed20
[root@vicky zfsfed20]# git clone https://github.com/zfsonlinux/spl.git
Cloning into 'spl'...
remote: Reusing existing pack: 6430, done.
remote: Total 6430 (delta 0), reused 0 (delta 0)
Receiving objects: 100% (6430/6430), 3.65 MiB | 60.00 KiB/s, done.
Resolving deltas: 100% (3750/3750), done.
Checking connectivity... done
[root@vicky zfsfed20]# 
```

##### create the configure script

```
[root@vicky spl]# autoreconf -i
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, `config'.
libtoolize: copying file `config/ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIR, `config'.
libtoolize: copying file `config/libtool.m4'
libtoolize: copying file `config/ltoptions.m4'
libtoolize: copying file `config/ltsugar.m4'
libtoolize: copying file `config/ltversion.m4'
libtoolize: copying file `config/lt~obsolete.m4'
configure.ac:35: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:35: http://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
configure.ac:32: installing 'config/config.guess'
configure.ac:32: installing 'config/config.sub'
configure.ac:35: installing 'config/install-sh'
configure.ac:35: installing 'config/missing'
cmd/Makefile.am: installing 'config/depcomp'
[root@vicky spl]# 
```

##### run configure

```
[root@vicky spl]# ./configure 
checking for gawk... gawk
checking metadata... git describe
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking target system type... x86_64-unknown-linux-gnu
checking whether to enable maintainer-specific portions of Makefiles... no
checking whether make supports nested variables... yes
checking for a BSD-compatible install... /bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /bin/mkdir -p
checking whether make sets $(MAKE)... yes
checking for gcc... gcc
checking whether the C compiler works... yes
config.status: executing depfiles commands

&lt; snip &gt;

config.status: executing libtool commands
[root@vicky spl]# 

```

##### build the packages

```
[root@vicky spl]# make rpm-utils rpm-dkms
make  pkg="spl" \
	def='--define "build_src_rpm 1" ' srpm-common
make[1]: Entering directory `/usr/src/zfsfed20/spl'
make  dist-gzip am__post_remove_distdir='@:'
make[2]: Entering directory `/usr/src/zfsfed20/spl'
if test -d "spl-0.6.2"; then find "spl-0.6.2" -type d ! -perm -200 -exec chmod u+w {} ';' && rm -rf "spl-0.6.2" || { sleep 5 && rm -rf "spl-0.6.2"; }; else :; fi
test -d "spl-0.6.2" || mkdir "spl-0.6.2"
 (cd include && make  top_distdir=../spl-0.6.2 distdir=../spl-0.6.2/include \
     am__remove_distdir=: am__skip_length_check=: am__skip_mode_fix=: distdir)
make[3]: Entering directory `/usr/src/zfsfed20/spl/include'
 (cd fs && make  top_distdir=../../spl-0.6.2 distdir=../../spl-0.6.2/include/fs \
     am__remove_distdir=: am__skip_length_check=: am__skip_mode_fix=: distdir)
make[4]: Entering directory `/usr/src/zfsfed20/spl/include/fs'
make[4]: Leaving directory `/usr/src/zfsfed20/spl/include/fs'

&lt; snip &gt;

+ umask 022
+ cd /tmp/spl-build-root-CJV0xR9u/BUILD
+ cd spl-0.6.2
+ '[' /tmp/spl-build-root-CJV0xR9u/BUILDROOT/spl-dkms-0.6.2-22_gd58a99a.fc20.x86_64 '!=' / ']'
+ rm -rf /tmp/spl-build-root-CJV0xR9u/BUILDROOT/spl-dkms-0.6.2-22_gd58a99a.fc20.x86_64
+ exit 0
Executing(--clean): /bin/sh -e /tmp/spl-build-root-CJV0xR9u/TMP/rpm-tmp.E1YvyO
+ umask 022
+ cd /tmp/spl-build-root-CJV0xR9u/BUILD
+ rm -rf spl-0.6.2
+ exit 0
make[1]: Leaving directory `/usr/src/zfsfed20/spl'
[root@vicky spl]# ls
aclocal.m4      config         copy-builtin  libtool      META             scripts                                spl_config.h.in                                  spl.release.in
AUTHORS         config.log     COPYING       Makefile     module           spl-0.6.2-22_gd58a99a.fc20.src.rpm     spl-debuginfo-0.6.2-22_gd58a99a.fc20.x86_64.rpm  stamp-h1
autogen.sh      config.status  DISCLAIMER    Makefile.am  patches          spl-0.6.2-22_gd58a99a.fc20.x86_64.rpm  spl-dkms-0.6.2-22_gd58a99a.fc20.noarch.rpm
autom4te.cache  configure      include       Makefile.in  README.markdown  spl-0.6.2.tar.gz                       spl-dkms-0.6.2-22_gd58a99a.fc20.src.rpm
cmd             configure.ac   lib           man          rpm              spl_config.h                           spl.release
[root@vicky spl]# 
```

##### install the packages
```
[root@vicky spl]# rpm -Uvh spl-0.6.2-22_gd58a99a.fc20.x86_64.rpm spl-dkms-0.6.2-22_gd58a99a.fc20.noarch.rpm
Preparing...                          ################################# [100%]
Updating / installing...
   1:spl-dkms-0.6.2-22_gd58a99a.fc20  ################################# [ 25%]
Removing old spl-0.6.2 DKMS files...

------------------------------
Deleting module version: 0.6.2
completely from the DKMS tree.
------------------------------
Done.
Loading new spl-0.6.2 DKMS files...
First Installation: checking all kernels...
Building only for 3.11.10-301.fc20.x86_64
Module build for the currently running kernel was skipped since the
kernel source for this kernel does not seem to be installed.
   2:spl-0.6.2-22_gd58a99a.fc20       ################################# [ 50%]
Cleaning up / removing...
   3:spl-0.6.2-1.el6                  ################################# [ 75%]

------------------------------
Deleting module version: 0.6.2
completely from the DKMS tree.
------------------------------
Done.
   4:spl-dkms-0.6.2-1.el6             ################################# [100%]
[root@vicky spl]# 

```
#### zfsonlinux

##### clone the zfs git repository

```
[root@vicky ]# cd /usr/src/zfsfed20
[root@vicky ~]# cd /usr/src/zfsfed20/
[root@vicky zfsfed20]# git clone https://github.com/zfsonlinux/zfs.git
Cloning into 'zfs'...
remote: Reusing existing pack: 80616, done.
remote: Counting objects: 47, done.
remote: Compressing objects: 100% (41/41), done.
remote: Total 80663 (delta 15), reused 20 (delta 6)
Receiving objects: 100% (80663/80663), 18.05 MiB | 105.00 KiB/s, done.
Resolving deltas: 100% (55857/55857), done.
Checking connectivity... done
[root@vicky zfsfed20]# 
```

##### create the configure script

```
[root@vicky zfs]# autoreconf -i
libtoolize: putting auxiliary files in AC_CONFIG_AUX_DIR, `config'.
libtoolize: copying file `config/ltmain.sh'
libtoolize: putting macros in AC_CONFIG_MACRO_DIR, `config'.
libtoolize: copying file `config/libtool.m4'
libtoolize: copying file `config/ltoptions.m4'
libtoolize: copying file `config/ltsugar.m4'
libtoolize: copying file `config/ltversion.m4'
libtoolize: copying file `config/lt~obsolete.m4'
configure.ac:41: warning: AM_INIT_AUTOMAKE: two- and three-arguments forms are deprecated.  For more info, see:
configure.ac:41: http://www.gnu.org/software/automake/manual/automake.html#Modernize-AM_005fINIT_005fAUTOMAKE-invocation
configure.ac:38: installing 'config/config.guess'
configure.ac:38: installing 'config/config.sub'
configure.ac:41: installing 'config/install-sh'
configure.ac:41: installing 'config/missing'
cmd/mount_zfs/Makefile.am: installing 'config/depcomp'
[root@vicky zfs]# 
```

##### run configure

```
[root@vicky zfs]# ./configure 
checking for gawk... gawk
checking metadata... git describe
checking build system type... x86_64-unknown-linux-gnu
checking host system type... x86_64-unknown-linux-gnu
checking target system type... x86_64-unknown-linux-gnu
checking whether to enable maintainer-specific portions of Makefiles... no
checking whether make supports nested variables... yes
checking for a BSD-compatible install... /bin/install -c
checking whether build environment is sane... yes
checking for a thread-safe mkdir -p... /bin/mkdir -p
checking whether make sets $(MAKE)... yes
checking for gcc... gcc
checking whether the C compiler works... yes
checking for C compiler default output file name... a.out
checking for suffix of executables... 
checking whether we are cross compiling... no
checking for suffix of object files... o
checking whether we are using the GNU C compiler... yes

&lt; snip &gt;

config.status: creating rpm/generic/zfs-kmod.spec
config.status: creating rpm/generic/zfs-dkms.spec
config.status: creating zfs-script-config.sh
config.status: creating zfs.release
config.status: creating zfs_config.h
config.status: executing depfiles commands
config.status: executing libtool commands
[root@vicky zfs]# 
```

##### build the packages

```
[root@vicky zfs]# make rpm-utils rpm-dkms
make  pkg="zfs" \
	def='--define "build_src_rpm 1" ' srpm-common
make[1]: Entering directory `/usr/src/zfsfed20/zfs'
make  dist-gzip am__post_remove_distdir='@:'
make[2]: Entering directory `/usr/src/zfsfed20/zfs'
if test -d "zfs-0.6.2"; then find "zfs-0.6.2" -type d ! -perm -200 -exec chmod u+w {} ';' && rm -rf "zfs-0.6.2" || { sleep 5 && rm -rf "zfs-0.6.2"; }; else :; fi
test -d "zfs-0.6.2" || mkdir "zfs-0.6.2"

&lt; snip &gt;

make[4]: Leaving directory `/usr/src/zfsfed20/zfs/udev/rules.d'
make[3]: Leaving directory `/usr/src/zfsfed20/zfs/udev'
+ exit 0
Executing(--clean): /bin/sh -e /tmp/zfs-build-root-pzSqKnEH/TMP/rpm-tmp.2uRZ1C
+ umask 022
+ cd /tmp/zfs-build-root-pzSqKnEH/BUILD
+ rm -rf zfs-0.6.2
+ exit 0
make[1]: Leaving directory `/usr/src/zfsfed20/zfs'
[root@vicky zfs]# 
```

##### install the packages

```
[root@vicky zfsfed20]# yum localinstall zfs-0.6.2-158_gcbe8e61.fc20.x86_64.rpm zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch.rpm zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64.rpm
Loaded plugins: langpacks, priorities, refresh-packagekit
Repository google-chrome is listed more than once in the configuration
Cannot open: zfs-0.6.2-158_gcbe8e61.fc20.x86_64.rpm. Skipping.
Cannot open: zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch.rpm. Skipping.
Cannot open: zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64.rpm. Skipping.
Nothing to do
[root@vicky zfsfed20]# cd zfs
[root@vicky zfs]# yum localinstall zfs-0.6.2-158_gcbe8e61.fc20.x86_64.rpm zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch.rpm zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64.rpm
Loaded plugins: langpacks, priorities, refresh-packagekit
Repository google-chrome is listed more than once in the configuration
Examining zfs-0.6.2-158_gcbe8e61.fc20.x86_64.rpm: zfs-0.6.2-158_gcbe8e61.fc20.x86_64
Marking zfs-0.6.2-158_gcbe8e61.fc20.x86_64.rpm to be installed
Examining zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch.rpm: zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch
Marking zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch.rpm to be installed
Examining zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64.rpm: zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64
Marking zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package zfs.x86_64 0:0.6.2-158_gcbe8e61.fc20 will be installed
---> Package zfs-dkms.noarch 0:0.6.2-158_gcbe8e61.fc20 will be installed
---> Package zfs-dracut.x86_64 0:0.6.2-158_gcbe8e61.fc20 will be installed
--> Finished Dependency Resolution
http://negativo17.org/repos/HandBrake/epel-20/x86_64/repodata/repomd.xml: [Errno 14] HTTP Error 404 - Not Found
Trying other mirror.

Dependencies Resolved

===================================================================================================================================
 Package             Arch            Version                             Repository                                           Size
===================================================================================================================================
Installing:
 zfs                 x86_64          0.6.2-158_gcbe8e61.fc20             /zfs-0.6.2-158_gcbe8e61.fc20.x86_64                 2.2 M
 zfs-dkms            noarch          0.6.2-158_gcbe8e61.fc20             /zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch             11 M
 zfs-dracut          x86_64          0.6.2-158_gcbe8e61.fc20             /zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64           13 k

Transaction Summary
===================================================================================================================================
Install  3 Packages

Total size: 13 M
Installed size: 13 M
Is this ok [y/d/N]: y
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
Warning: RPMDB altered outside of yum.
** Found 1 pre-existing rpmdb problem(s), 'yum check' output follows:
libvpx-1.2.0-2.git5e3439b.fc19.x86_64 is a duplicate with libvpx-1.2.0-2.fc20.i686
  Installing : zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch                                                                         1/3 
Loading new zfs-0.6.2 DKMS files...
First Installation: checking all kernels...
Building only for 3.12.7-300.fc20.x86_64
Building initial module for 3.12.7-300.fc20.x86_64
Done.

zavl:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/

znvpair.ko:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/

zunicode.ko:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/

zcommon.ko:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/

zfs.ko:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/

zpios.ko:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/3.12.7-300.fc20.x86_64/extra/
Adding any weak-modules

Running the post_install script:

depmod...

DKMS: install completed.
  Installing : zfs-0.6.2-158_gcbe8e61.fc20.x86_64                                                                              2/3 
  Installing : zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64                                                                       3/3 
  Verifying  : zfs-dracut-0.6.2-158_gcbe8e61.fc20.x86_64                                                                       1/3 
  Verifying  : zfs-0.6.2-158_gcbe8e61.fc20.x86_64                                                                              2/3 
  Verifying  : zfs-dkms-0.6.2-158_gcbe8e61.fc20.noarch                                                                         3/3 

Installed:
  zfs.x86_64 0:0.6.2-158_gcbe8e61.fc20   zfs-dkms.noarch 0:0.6.2-158_gcbe8e61.fc20   zfs-dracut.x86_64 0:0.6.2-158_gcbe8e61.fc20  

Complete!
[root@vicky zfs]# 

```
#### Enable zfs
```
[root@vicky zfs]# chkconfig zfs on
[root@vicky zfs]# systemctl zfs start
Unknown operation 'zfs'.
[root@vicky zfs]# systemctl start zfs
[root@vicky zfs]# 

```
<p style="font-style: italic;">
Have fun...
</p>
