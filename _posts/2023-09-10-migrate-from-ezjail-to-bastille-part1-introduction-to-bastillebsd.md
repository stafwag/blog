---
layout: post
title: "Migrate from ezjail to BastilleBSD part 1: BastilleBSD exploration"
date: 2023-09-10 06:30:00 +0200
comments: true
categories: freebsd jail raspberrypi BastilleBSD ezjail solaris linux zones containers zfs openzfs homelab security
excerpt_separator: <!--more-->
---

# Introduction to BastilleBSD

## What are "containers"?
### Chroot, Jails, containers, zones, LXC, Docker

I use FreeBSD on my home network to serve services like email, git, fileserver, etc.
For some other services, I use [k3s](https://k3s.io/) with GNU/Linux application containers.

The FreeBSD services run as [Jails](https://en.wikipedia.org/wiki/FreeBSD_jail).
For those who aren’t familiar with FreeBSD Jails. Jails started the whole concept of “containers”.

FreeBSD Jails inspired [Sun Microsystems](https://en.wikipedia.org/wiki/Sun_Microsystems) to create [Solaris zones](https://en.wikipedia.org/wiki/Solaris_Containers).

If you want to know more about the history of FreeBSD Jails, Solaris zones and containers on Un!x systems in general and the challenges to run containers securely I recommend the video;

**"Papers We Love: Jails and Solaris Zones by Bryan Cantrill"**

[![Papers We Love: Jails and Solaris Zones by Bryan Cantrill](https://img.youtube.com/vi/hgN8pCMLI2U/0.jpg)](https://www.youtube.com/watch?v=hgN8pCMLI2U "Papers We Love: Jails and Solaris Zones by Bryan Cantrill")

Sun took containers to the next level with
[Solaris zones](https://en.wikipedia.org/wiki/Solaris_Containers)
, allowing a fine-grade CPU and memory allocation.

On GNU/Linux [LXC](https://linuxcontainers.org/) was the most popular container framework. ...Till [Docker]( https://www.docker.com/) came along.

### Application vs system containers

<!--more-->

To the credit of Docker, Docker made the concept of application containers popular.

System containers run the complete operating system and can be used like virtual machines without the overhead.

Application containers run a single application binary inside a container that holds all the dependencies for this application.

### FreeBSD Jails

FreeBSD Jails can be used for both “application” containers and “system” containers.
FreeBSD Jails is a framework that separates the host and the Jails with security in mind.

### My home network setup

To make the management of Jails easier we have management tools. I started to use [ezjail in 2013](https://stafwag.github.io/blog/blog/2013/04/10/migrating-from-qjail-to-ezjail/) after my [OpenSolaris system died](https://stafwag.github.io/blog/blog/2012/12/11/rip-pluto/) and Oracle killed OpenSolaris.

[ezjail](https://erdgeist.org/arts/software/ezjail/) isn’t developed that actively.

[BastilleBSD](https://bastillebsd.org/) is the most the popular Jail management tool for FreeBSD Jails. It supports both application and system containers.

I migrated all the services to Raspberry Pi’s to save electricity. But continued to use ezjail, just to stick to something that I knew and was stable. Migrating to BastileBSD was still on my to-do list and I finally found the time to do it.

My blog posts are mostly my installation notes that I publish in the hope that they are useful to somebody else.

In this blog post, you'll find my journey to explore BastileBSD, in a next blog post, I'll go through the migration from ezjail to BastilleBSD. 

If you are interested in the concepts behind BastilleBSD, I recommend the video:

**FreeBSD Fridays: Introduction to BastilleBSD**

[![FreeBSD Fridays: Introduction to BastilleBSD](https://img.youtube.com/vi/IOUr7Is5FSU/0.jpg)](https://www.youtube.com/watch?v=IOUr7Is5FSU "FreeBSD Fridays: Introduction to BastilleBSD")

## BastilleBSD exploration
### Start

We'll execute all actions on a virtual machine running FreeBSD on a Raspberry PI. The Raspberry PI is running Debian GNU/Linux with the KVM/libvirt hypervisor.

The virtual machine is running FreeBSD 13.2.

```
root@pi-rataplan:~ # freebsd-version 
13.2-RELEASE-p2
root@pi-rataplan:~ # 
```

```
root@pi-rataplan:~ # uname -a
FreeBSD pi-rataplan 13.2-RELEASE-p2 FreeBSD 13.2-RELEASE-p2 GENERIC arm64
root@pi-rataplan:~ # 
```
### Install BastilleBSD
#### Install

The first step is to install ```bastille```.

```
root@pi-rataplan:~ # pkg install -y bastille
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
	bastille: 0.9.20220714

Number of packages to be installed: 1

38 KiB to be downloaded.
[1/1] Fetching bastille-0.9.20220714.pkg: 100%   38 KiB  38.8kB/s    00:01    
Checking integrity... done (0 conflicting)
[1/1] Installing bastille-0.9.20220714...
[1/1] Extracting bastille-0.9.20220714: 100%
root@pi-rataplan:~ # 
```
#### Enable BastilleBSD

BastilleBSD is not a daemon that runs in the background, but starts the containers when the ```bastille_enable``` system configuration [rc.conf](https://man.freebsd.org/cgi/man.cgi?rc.conf) variable is set to ```YES```.

FreeBSD has a nice tool to set the system configuration variables; [sysrc](https://man.freebsd.org/cgi/man.cgi?sysrc).

```
root@pi-rataplan:~ # sysrc bastille_enable=YES
bastille_enable:  -> YES
root@pi-rataplan:~ # 
```

It's possible to specify a list of containers in the ```bastille_list```, the containers are started in the order of the list.

### Configuration
#### Update config to use ZFS

BastilleBSD can use [OpenZFS](https://openzfs.org), but this isn't enabled by default.
When ZFS support is enabled a new ZFS dataset is created when a container is created.

```
root@pi-rataplan:/usr/local/etc/bastille # cd /usr/local/etc/bastille/
root@pi-rataplan:/usr/local/etc/bastille # 
```
```
root@pi-rataplan:/usr/local/etc/bastille # vi bastille.conf
```

To enable OpenZFS support you need to set ```bastille_zfs_enable``` to ```YES``` and specify the zpool to be used.
Please note that ```YES``` need to be in upper case.

```
## ZFS options
bastille_zfs_enable="YES"                                                ## default: ""
bastille_zfs_zpool="zroot"                                                 ## default: ""
bastille_zfs_prefix="bastille"                                        ## default: "${bastille_zfs_zpool}/bast
ille"
bastille_zfs_options="-o compress=lz4 -o atime=off"                   ## default: "-o compress=lz4 -o atime=o
ff"
```

### Bootstrap
#### Bootstrap a release

In order to start a container you need to ```bootstrap``` a FreeBSD release first.

```
root@pi-rataplan:/usr/local/share/bastille # freebsd-version 
13.2-RELEASE-p2
```

A FreeBSD release is without the patch level.

The command below will bootstrap the ```13.2-RELEASE``` on bastilleBSD. The ```update``` option will also include the latest patches.

```
root@pi-rataplan:/usr/local/share/bastille # bastille bootstrap 13.2-RELEASE update
<snip>
Installing updates...
Restarting sshd after upgrade
Performing sanity check on sshd configuration.
Stopping sshd.
Waiting for PIDS: 93019.
Performing sanity check on sshd configuration.
Starting sshd.
Scanning /usr/local/bastille/releases/13.2-RELEASE/usr/share/certs/blacklisted for certificates...
Scanning /usr/local/bastille/releases/13.2-RELEASE/usr/share/certs/trusted for certificates...
 done.
root@pi-rataplan:/usr/local/share/bastille # 
```

#### List

You can use the ```bastille list release``` command to list the bootstrapped releases.

```
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # bastille list release
13.1-RELEASE
13.2-RELEASE
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # 
```

The releases are stored in the bastilleBSD dataset ```/usr/local/bastille/releases``` in our case.

```
root@pi-rataplan:/usr/local/bastille # cd releases/
root@pi-rataplan:/usr/local/bastille/releases # ls
13.1-RELEASE	13.2-RELEASE
root@pi-rataplan:/usr/local/bastille/releases # 
```

The downloaded tar archive are stored in the ```cache``` ZFS dataset.

```
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # zfs list | grep -i bastille | grep -i cache
zroot/bastille/cache                           334M  93.6G      104K  /usr/local/bastille/cache
zroot/bastille/cache/13.1-RELEASE              165M  93.6G      165M  /usr/local/bastille/cache/13.1-RELEASE
zroot/bastille/cache/13.2-RELEASE              169M  93.6G      169M  /usr/local/bastille/cache/13.2-RELEASE
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # 
```

```
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # ls -l /usr/local/bastille/cache/13.2-RELEASE
total 345866
-rw-r--r--  1 root  wheel        782 Apr  7 07:01 MANIFEST
-rw-r--r--  1 root  wheel  176939748 Apr  7 07:01 base.txz
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # 
```

#### Verify a release

With ```bastille verify``` you can verify a release to be sure that no files are altered.

```
root@pi-rataplan:/usr/local/bastille/releases #  bastille verify 13.2-RELEASE
src component not installed, skipped
Looking up update.FreeBSD.org mirrors... 2 mirrors found.
Fetching metadata signature for 13.2-RELEASE from update2.freebsd.org... done.
Fetching metadata index... done.
Inspecting system... done.
root@pi-rataplan:/usr/local/bastille/releases # 
```
### Create your first container
#### "Thin" vs "thick" Jails.

"Thin" Jails are created by default. With a "thin" Jail the operating system is "shared" with the release. This saves a lot of disk space.
It's possible to convert a container to a "thick" Jail after a Jail is created.

#### Network

BastilleBSD has a lot of network options, it can also create dynamic firewall rules to expose services.

See **[https://docs.bastillebsd.org/en/latest/chapters/networking.html](https://docs.bastillebsd.org/en/latest/chapters/networking.html)** for more information.

In this example we'll use a "shared" network interface ```vtnet0``` with the host system.

```
root@pi-rataplan:/usr/local/bastille/releases # bastille create bastille-tst001 13.2-RELEASE <ip_address> vtnet0
Valid: (<ip_address>).
Valid: (vtnet0).

Creating a thinjail...

[bastille-tst001]:
bastille-tst001: created

[bastille-tst001]:
Applying template: default/thin...
[bastille-tst001]:
Applying template: default/base...
[bastille-tst001]:
[bastille-tst001]: 0

[bastille-tst001]:
syslogd_flags: -s -> -ss

[bastille-tst001]:
sendmail_enable: NO -> NO

[bastille-tst001]:
sendmail_submit_enable: YES -> NO

[bastille-tst001]:
sendmail_outbound_enable: YES -> NO

[bastille-tst001]:
sendmail_msp_queue_enable: YES -> NO

[bastille-tst001]:
cron_flags:  -> -J 60

[bastille-tst001]:
/etc/resolv.conf -> /usr/local/bastille/jails/bastille-tst001/root/etc/resolv.conf

Template applied: default/base

Template applied: default/thin

rdr-anchor not found in pf.conf
[bastille-tst001]:
bastille-tst001: removed

[bastille-tst001]:
bastille-tst001: created

root@pi-rataplan:/usr/local/bastille/releases # 
```

A new ZFS dataset is created for the Jail.

```
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # zfs list | grep -i tst001
zroot/bastille/jails/bastille-tst001          5.61M  93.6G      116K  /usr/local/bastille/jails/bastille-tst001
zroot/bastille/jails/bastille-tst001/root     5.50M  93.6G     5.50M  /usr/local/bastille/jails/bastille-tst001/root
root@pi-rataplan:/usr/local/bastille/releases/13.1-RELEASE # 
```

The mounted Jail dataset holds the Jail configuration file and ```fstab``` that is used by the Jail.

```
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # cd /usr/local/bastille/jails/bastille-tst001
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # ls
fstab		jail.conf	root
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # 
```

jail.conf:

```
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # cat jail.conf 
bastille-tst001 {
  devfs_ruleset = 4;
  enforce_statfs = 2;
  exec.clean;
  exec.consolelog = /var/log/bastille/bastille-tst001_console.log;
  exec.start = '/bin/sh /etc/rc';
  exec.stop = '/bin/sh /etc/rc.shutdown';
  host.hostname = bastille-tst001;
  mount.devfs;
  mount.fstab = /usr/local/bastille/jails/bastille-tst001/fstab;
  path = /usr/local/bastille/jails/bastille-tst001/root;
  securelevel = 2;

  interface = vtnet0;
  ip4.addr = <ip_address>;
  ip6 = disable;
}
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001
```

fstab:

```
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # cat /usr/local/bastille/jails/bastille-tst001/fstab
/usr/local/bastille/releases/13.2-RELEASE /usr/local/bastille/jails/bastille-tst001/root/.bastille nullfs ro 0 0
root@pi-rataplan:/usr/local/bastille/jails/bastille-tst001 # 
```

### Interact with containers
#### list

With ```bastille list``` we can list the containers. When no option is given it'll list the running containers only.
To list all containers (stopped and running) you can use the ```-a``` option.

Note that ```bastille list``` is a wrapper around the [jls](https://man.freebsd.org/cgi/man.cgi?jls) command and also lists the running ezjail containers.

```
root@pi-rataplan:/usr/jails/stafproxy/basejail # bastille list
 JID             IP Address      Hostname                      Path
 stafscm         <ip>            stafscm                       /usr/jails/stafscm
 stafproxy       <ip>            stafproxy                     /usr/jails/stafproxy
 stafmail        <ip>            stafmail                      /usr/jails/stafmail
 staffs          <ip>            staffs                        /usr/jails/staffs
 stafdns         <ip>            stafdns                       /usr/jails/stafdns
 bastille-tst001 <ip>            bastille-tst001               /usr/local/bastille/jails/bastille-tst001/root
root@pi-rataplan:/usr/jails/stafproxy/basejail # 
```

#### console access

To gain console access you use the ```bastille console``` command.

```
root@pi-rataplan:/usr/jails/stafproxy/basejail # bastille console bastille-tst001
[bastille-tst001]:
root@bastille-tst001:~ # 
```

Verify the disk space. We're using a "thin" Jail only, ```5.5M``` of disk space is used.

```
root@bastille-tst001:~ # df -h .
Filesystem                                   Size    Used   Avail Capacity  Mounted on
zroot/bastille/jails/bastille-tst001/root    154G    5.5M    154G     0%    /
root@bastille-tst001:~ # 
```

#### Readonly file system

We're using "thin" Jails. The system binaries are read-only.

```
[root@bastille-tst001 ~]# ls -l /bin
lrwxr-xr-x  1 root  wheel  14 Aug 16 10:25 /bin -> /.bastille/bin
[root@bastille-tst001 ~]# 
```

```
[root@bastille-tst001 ~]# touch /bin/ls
touch: /bin/ls: Read-only file system
[root@bastille-tst001 ~]# 
```

#### freebsd-version

```
[root@bastille-tst001 ~]# freebsd-version 
13.2-RELEASE-p2
[root@bastille-tst001 ~]# uname -a
FreeBSD bastille-tst001 13.2-RELEASE-p2 FreeBSD 13.2-RELEASE-p2 GENERIC arm64
[root@bastille-tst001 ~]# 
```

#### Install FreeBSD packages 

Bootstrap the ```pkg``` command to install packages.

```
root@bastille-tst001:~ # pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
Bootstrapping pkg from pkg+http://pkg.FreeBSD.org/FreeBSD:13:aarch64/quarterly, please wait...
Verifying signature with trusted certificate pkg.freebsd.org.2013102301... done
[bastille-tst001] Installing pkg-1.19.2...
[bastille-tst001] Extracting pkg-1.19.2: 100%
pkg: not enough arguments
Usage: pkg [-v] [-d] [-l] [-N] [-j <jail name or id>|-c <chroot path>|-r <rootdir>] [-C <configuration file>] [-R <repo config dir>] [-o var=value] [-4|-6] <command> [<args>]

For more information on available commands and options see 'pkg help'.
root@bastille-tst001:~ #
```

I use ansible to manage my homelab ```python3``` and ```sudo``` are required for this, so these are usually the first packages I install.

```
root@bastille-tst001:~ # pkg install -y sudo python3 bash
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 9 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
	bash: 5.2.15
	gettext-runtime: 0.21.1
	indexinfo: 0.3.1
	libffi: 3.4.4
	mpdecimal: 2.5.1
	python3: 3_3
	python39: 3.9.17
	readline: 8.2.1
	sudo: 1.9.14p3

Number of packages to be installed: 9

The process will require 140 MiB more space.
21 MiB to be downloaded.
[bastille-tst001] [1/9] Fetching indexinfo-0.3.1.pkg: 100%    5 KiB   5.5kB/s    00:01    
[bastille-tst001] [2/9] Fetching mpdecimal-2.5.1.pkg: 100%  292 KiB 299.4kB/s    00:01    
[bastille-tst001] [3/9] Fetching python39-3.9.17.pkg: 100%   17 MiB   2.6MB/s    00:07    
[bastille-tst001] [4/9] Fetching libffi-3.4.4.pkg: 100%   36 KiB  36.6kB/s    00:01    
[bastille-tst001] [5/9] Fetching readline-8.2.1.pkg: 100%  345 KiB 353.1kB/s    00:01    
[bastille-tst001] [6/9] Fetching sudo-1.9.14p3.pkg: 100%    2 MiB   1.6MB/s    00:01    
[bastille-tst001] [7/9] Fetching python3-3_3.pkg: 100%    1 KiB   1.1kB/s    00:01    
[bastille-tst001] [8/9] Fetching bash-5.2.15.pkg: 100%    2 MiB   1.6MB/s    00:01    
[bastille-tst001] [9/9] Fetching gettext-runtime-0.21.1.pkg: 100%  160 KiB 164.0kB/s    00:01    
Checking integrity... done (0 conflicting)
[bastille-tst001] [1/9] Installing indexinfo-0.3.1...
[bastille-tst001] [1/9] Extracting indexinfo-0.3.1: 100%
[bastille-tst001] [2/9] Installing mpdecimal-2.5.1...
[bastille-tst001] [2/9] Extracting mpdecimal-2.5.1: 100%
[bastille-tst001] [3/9] Installing libffi-3.4.4...
[bastille-tst001] [3/9] Extracting libffi-3.4.4: 100%
[bastille-tst001] [4/9] Installing readline-8.2.1...
[bastille-tst001] [4/9] Extracting readline-8.2.1: 100%
[bastille-tst001] [5/9] Installing gettext-runtime-0.21.1...
[bastille-tst001] [5/9] Extracting gettext-runtime-0.21.1: 100%
[bastille-tst001] [6/9] Installing python39-3.9.17...
[bastille-tst001] [6/9] Extracting python39-3.9.17: 100%
[bastille-tst001] [7/9] Installing sudo-1.9.14p3...
[bastille-tst001] [7/9] Extracting sudo-1.9.14p3: 100%
[bastille-tst001] [8/9] Installing python3-3_3...
[bastille-tst001] [8/9] Extracting python3-3_3: 100%
[bastille-tst001] [9/9] Installing bash-5.2.15...
[bastille-tst001] [9/9] Extracting bash-5.2.15: 100%
=====
Message from python39-3.9.17:

--
Note that some standard Python modules are provided as separate ports
as they require additional dependencies. They are available as:

py39-gdbm       databases/py-gdbm@py39
py39-sqlite3    databases/py-sqlite3@py39
py39-tkinter    x11-toolkits/
```
Let's install neofetch.

```
[root@bastille-tst001 ~]# pkg install -y neofetch
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
	neofetch: 7.1.0_1

Number of packages to be installed: 1

79 KiB to be downloaded.
[bastille-tst001] [1/1] Fetching neofetch-7.1.0_1.pkg: 100%   79 KiB  81.0kB/s    00:01    
Checking integrity... done (0 conflicting)
[bastille-tst001] [1/1] Installing neofetch-7.1.0_1...
[bastille-tst001] [1/1] Extracting neofetch-7.1.0_1: 100%
[root@bastille-tst001 ~]# 
```

```
[root@bastille-tst001 ~]# neofetch 
  ` `.....---.......--.```   -/    -------------------- 
  +o   .--`         /y:`      +.   OS: FreeBSD 13.2-RELEASE-p2 aarch64 
   yo`:.            :o      `+-    Uptime: 3 days, 14 hours, 13 mins 
    y/               -/`   -o/     Packages: 11 (pkg) 
   .-                  ::/sy+:.    Shell: csh tcsh 6.22.04 
   /                     `--  /    Terminal: /dev/pts/1 
  `:                          :`   CPU: ARM Cortex-A72 r0p3 (4) 
  `:                          :`   Memory: 2193MiB / 3039MiB 
   /                          /
   .-                        -.                            
    --                      -.                             
     `:`                  `:`
       .--             `--.
          .---.....----.

[root@bastille-tst001 ~]# 
```

### Logout

```
[root@bastille-tst001 ~]# 
exit
root@bastille-tst001:~ # logout
```

## update containers

List the releases.

```
root@pi-rataplan:~ # bastille list release
13.1-RELEASE
13.2-RELEASE
root@pi-rataplan:~ # 
```

Update a release to the latest patch level.

```
root@pi-rataplan:/usr/jails/stafproxy/basejail # bastille update 13.2-RELEASE
src component not installed, skipped
Looking up update.FreeBSD.org mirrors... 2 mirrors found.
Fetching metadata signature for 13.2-RELEASE from update2.freebsd.org... done.
Fetching metadata index... done.
Inspecting system... done.
Preparing to download files... done.

No updates needed to update system to 13.2-RELEASE-p2.
No updates are available to install.
```
## Execute commands inside a container.

You can use ```bastille cmd``` to execute a command inside a container which is a wrapper around the [jexec](https://man.freebsd.org/cgi/man.cgi?query=jexec&sektion=8&format=html).

### List running processes.

The syntax is 

```bastille cmd <container|ALL> <command string>```

```
root@pi-rataplan:~ # bastille cmd ALL ps aux
[bastille-tst001]:
grep: /usr/local/bastille/jails/ALL/fstab: No such file or directory
USER   PID %CPU %MEM   VSZ  RSS TT  STAT STARTED    TIME COMMAND
root 35869  0.0  0.1 12876 2496  -  IJ   10:55   0:00.00 cron: running job (cron)
root 46730  0.0  0.1 12704 2696  -  SsJ  10:25   0:00.01 /usr/sbin/syslogd -ss
root 55608  0.0  0.1 12876 2496  -  IJ   10:55   0:00.00 cron: running job (cron)
root 69222  0.0  0.1 12876 2512  -  IsJ  10:25   0:00.01 /usr/sbin/cron -J 60 -s
root 67674  0.0  0.1 13440 2960  1  R+J  10:55   0:00.00 ps aux
[bastille-tst001]: 0

root@pi-rataplan:~ # 
```
### audit packages

FreeBSD has implemented the vulnerability management in the correct way. The vulnerability database is outside of the packages management database as it should be.

Unfortunately the FreeBSD vulnerability database isn’t compatible with the [OVAL](https://oval.mitre.org/) standard.

This makes auditing the installed FreeBSD packages with the pkg audit command in a way comparable with a security audit with OpenSCAP on a GNU/Linux system.

But this might be a topic for another blog post :-)

```
root@pi-rataplan:~ # bastille pkg ALL audit -F
[bastille-tst001]:
[bastille-tst001] Fetching vuln.xml.xz: 100%    1 MiB 349.2kB/s    00:03    
0 problem(s) in 0 installed package(s) found.

root@pi-rataplan:~ # 
```

***Have fun!***

# Links

* [https://bastillebsd.org/getting-started/](https://bastillebsd.org/getting-started/)
* [https://bastille.readthedocs.io/en/latest/chapters/networking.html#shared-interface-on-home-or-small-office-network](https://bastille.readthedocs.io/en/latest/chapters/networking.html#shared-interface-on-home-or-small-office-network)
* [https://www.youtube.com/watch?v=IOUr7Is5FSU](https://www.youtube.com/watch?v=IOUr7Is5FSU)
* [https://forums.freebsd.org/threads/bastille-jail-console-nest-display-building-testing-builds.82155/](https://forums.freebsd.org/threads/bastille-jail-console-nest-display-building-testing-builds.82155/)
* [https://github.com/BastilleBSD/bastille/issues/360](https://github.com/BastilleBSD/bastille/issues/360)
* [https://forums.freebsd.org/threads/freebsd-13-high-cpu-usage-rand_harvestq.80475/](https://forums.freebsd.org/threads/freebsd-13-high-cpu-usage-rand_harvestq.80475/)
