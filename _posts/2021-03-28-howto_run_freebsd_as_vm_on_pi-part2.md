---
layout: post
title: "How to run a FreeBSD Virtual Machine on the RPI4 with QEMU. Part 2: Network, Install from cdrom, startup"
date: 2021-03-28 09:04:00 +200
comments: true
categories: [ raspberrypi, rpi, rpi4, freebsd, qemu, arm, arm64 ] 
excerpt_separator: <!--more-->
---

<a href="{{ '/images/freebsd_vm_on_pi/rpi4_with_disk.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd_vm_on_pi/rpi4_with_disk.jpg' | remove_first:'/' | absolute_url }}" class="left" width="600" height="359" alt="rpi4 with disk" /> </a>

In my last blog post, we set up a FreeBSD virtual machine with QEMU. I switched from the EDK2 (UEFI) firmware to U-boot, the EDK2 firmware had issues with multiple CPU’s in the virtual machines.

In this blog post, we’ll continue with the Network setup, install the virtual machine from a CDROM image and how to start the virtual machine during the PI start-up.

<!--more-->

# Network Setup

## Bridge

### Bridge setup

The network interface on my Raspberry PI is configured in a bridge. I used this bridge setup already for a virtual machine setup with libvirtd.

The bridge is configured with network-manager. I don’t recall how I created it. It was probably created with ```nmtui``` or ```nmcli```.

Creating a bridge with ```nmtui``` is straight-forward, I’ll not cover it in this how-to.

I use Manjaro on my Raspberry Pi. Manjaro is based on Arch Linux. The [ArchLinux wiki](https://wiki.archlinux.org/) has a nice article on how to set up a bridge.

[https://wiki.archlinux.org/index.php/Network_bridge](https://wiki.archlinux.org/index.php/Network_bridge).

### QEMU

Create a ```bridge.conf``` file in ```/etc/qemu/``` to allow the bridge in QEMU.

```
# cat /etc/qemu/bridge.conf 
allow eth0-bridge
```

### Firewall

When you use a firewall that drops all packages by default - as you should - you probably want to set up a firewall rule that allows all traffic on the physical interface on the bridge.

```
iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
```

I use a simple firewall script that was based on the Debian firewall wiki: 

[https://wiki.debian.org/DebianFirewall](https://wiki.debian.org/DebianFirewall)

As always with a firewall make sure that you log the dropped packages.
It’ll make your life easier to debug.

You’ll find my iptables firewall rules below.

```
iptables -F

# Default policy to drop 'everything' but our output to internet
iptables -P FORWARD DROP
iptables -P INPUT   DROP
iptables -P OUTPUT  ACCEPT

# Allow established connections (the responses to our outgoing traffic)
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow local programs that use loopback (Unix sockets)
iptables -A INPUT -s 127.0.0.0/8 -d 127.0.0.0/8 -i lo -j ACCEPT

# Uncomment this line to allow incoming SSH/SCP conections to this machine,
# for traffic from 10.20.0.2 (you can use also use a network definition as
# source like 10.20.0.0/22).

iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j ACCEPT
iptables -A INPUT -p icmp -j ACCEPT

iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT

iptables -N LOGGING_INPUT
iptables -N LOGGING_FORWARD
iptables -N LOGGING_OUTPUT

iptables -A LOGGING_INPUT -m limit --limit 2/min -j LOG --log-prefix "IPTables-Input-Dropped: " --log-level 4
iptables -A LOGGING_INPUT -j DROP

iptables -A LOGGING_FORWARD -m limit --limit 2/min -j LOG --log-prefix "IPTables-Forward-Dropped: " --log-level 4
iptables -A LOGGING_FORWARD -j DROP

iptables -A LOGGING_OUTPUT -m limit --limit 2/min -j LOG --log-prefix "IPTables-Output-Dropped: " --log-level 4
iptables -A LOGGING_OUTPUT -j DROP

iptables -A INPUT -j LOGGING_INPUT
```

### QEMU

To boot the virtual machine with networking enabled, you can add ```-net nic`-net bridge,br=<your-bridge>``` to
 the ```qemu-system-aarch64``` command.  My bridge is called ```eth0-bridge```.

As a test, I booted the virtual machine with the FreeBSD virtual machine image.

```
qemu-system-aarch64 -M virt -m 4096M -cpu host,pmu=off --enable-kvm \
 	-smp 2 -nographic -bios /usr/local/u-boot/u-boot.bin \
 	-hda /home/staf/Downloads/freebsd/FreeBSD-13.0-RC2-arm64-aarch64.qcow2 \
	-boot order=d -net nic -net bridge,br=eth0-bridge
```

This creates a tap interface that is assigned to the virtual machine.
The FreeBSD virtual image is configured to get an ip-address with DHCP. 

# Install FreeBSD from a cdrom image

Download the FreeBSD ARM64 "Installer Image" from FreeBSD website: [https://www.freebsd.org/where/](https://www.freebsd.org/where/)

Create a disk image for the virtual machine.

```
$ qemu-img create -f qcow2 myfreebsd.qcow2 50G
Formatting 'myfreebsd.qcow2', fmt=qcow2 cluster_size=65536 extended_l2=off compression_type=zlib size=53687091200 lazy_refcounts=off refcount_bits=16
$ 
```

Boot the virtual machine with the "Installer Image" and the created qcow2 image.

```
$ qemu-system-aarch64 -M virt -m 4096M -cpu host,pmu=on --enable-kvm \
        -smp 2 -nographic -bios /usr/local/u-boot/u-boot.bin \
        -cdrom /home/staf/Downloads/freebsd/iso/FreeBSD-13.0-RC3-arm64-aarch64-dvd1.iso \
        -boot order=c \
        -hda myfreebsd.qcow2 \
        -net nic -net bridge,br=eth0-bridge
```

The installation continues as "a normal" FreeBSD install.

```
|  ______               ____   _____ _____  
  |  ____|             |  _ \ / ____|  __ \ 
  | |___ _ __ ___  ___ | |_) | (___ | |  | |
  |  ___| '__/ _ \/ _ \|  _ < \___ \| |  | |
  | |   | | |  __/  __/| |_) |____) | |__| |
  | |   | | |    |    ||     |      |      |
  |_|   |_|  \___|\___||____/|_____/|_____/      ```                        `
                                                s` `.....---.......--.```   -/
 +-----------Welcome to FreeBSD------------+    +o   .--`         /y:`      +.
 |                                         |     yo`:.            :o      `+-
 |  1. Boot Multi user [Enter]             |      y/               -/`   -o/
 |  2. Boot Single user                    |     .-                  ::/sy+:.
 |  3. Escape to loader prompt             |     /                     `--  /
 |  4. Reboot                              |    `:                          :`
 |  5. Cons: Video                         |    `:                          :`
 |                                         |     /                          /
 |  Options:                               |     .-                        -.
 |  6. Kernel: default/kernel (1 of 1)     |      --                      -.
 |  7. Boot Options                        |       `:`                  `:`
 |                                         |         .--             `--.
 |                                         |            .---.....----.
 +-----------------------------------------+
   Autoboot in 5 seconds, hit [Enter] to boot or any other key to stop   
```

Choose your terminal type, I used xterm. Tip: if your screen gets mixed up during the installation, you can use [CRTL][L] to redraw
it.

```
Starting local daemons:
Welcome to FreeBSD!

Please choose the appropriate terminal type for your system.
Common console types are:
   ansi     Standard ANSI terminal
   vt100    VT100 or compatible terminal
   xterm    xterm terminal emulator (or compatible)
   cons25w  cons25w terminal

Console type [vt100]: 
```

Continue with the FreeBSD installation...

When you reboot your freshly installed FreeBSD system interrupt the boot process with the
[CRTL][a] [x] key combination. To see the other options use [CRTL][a] [h].  

```
qemu-system-aarch64 -M virt -m 4096M -cpu host --enable-kvm \
        -smp 2 -nographic -bios /usr/local/u-boot/u-boot.bin \
        -boot order=c \
        -hda myfreebsd.qcow2 \
        -net nic -net bridge,br=eth0-bridge
```

The first boot will fail. We are using U-Boot as the BIOS. The EFI boot filesystem doesn’t exist.

Logon to the system.

```
Automatic file system check failed; help!
ERROR: ABORTING BOOT (sending SIGTERM to parent)!
1970-01-01T01:00:02.912420+01:00 - init 1 - - /bin/sh on /etc/rc terminated abnormally, going to single user mode
Enter root password, or ^D to go multi-user
Password:
Enter full pathname of shell or RETURN for /bin/sh: 
root@:/ # 
```

Verify the filesystem that failed to mount.

```
root@:/ # mount -a
mount_msdosfs: /dev/vtbd1p1: No such file or directory
root@:/ # 
```

The root filesystem is read-only. Remount it in read-write mode with ```mount -u /```

```
root@:/ # mount -u /
root@:/ #
```

Edit ```/etc/fstab```

```
root@:/ # vi /etc/fstab
```

And add a ```#``` before the ```/boot/efi``` mount point.
I'd not remove it, it might be useful to be able to re-enable it when you want to switch to a UEFI bios.

```
# Device                Mountpoint      FStype  Options         Dump    Pass#
# /dev/vtbd1p1          /boot/efi       msdosfs rw              2       2
/dev/mirror/swap                none    swap    sw              0       0
```

And reboot you system.

```
root@:/ # sync
root@:/ # reboot
```

# Auto-start

To implement the auto-start of the QEMU virtual machine, I mainly followed the [ArchLinux wiki QEMU wiki](https://wiki.archlinux.org/index.php/QEMU)

## Systemd service

Create the systemd service.

```
# vi /etc/systemd/system/qemu@.service
```

```
Description=QEMU virtual machine

Unit]
Description=QEMU virtual machine
Wants=network-online.target
After=network-online.target

[Service]
Environment="haltcmd=kill -INT $MAINPID"
EnvironmentFile=/etc/conf.d/qemu.d/%i
ExecStart=/usr/bin/qemu-system-aarch64 -M virt -name %i --enable-kvm -cpu host -nographic $args
ExecStop=/usr/bin/bash -c ${haltcmd}
ExecStop=/usr/bin/bash -c 'while nc localhost 7100; do sleep 1; done'

[Install]
WantedBy=multi-user.target
```

## Create QEMU config

Create the ```qemu.d``` config directory.

```
# mkdir -p /etc/conf.d/qemu.d/
```

Create the definition for the virtual machine.

```
# vi /etc/conf.d/qemu.d/myfreebsd
# 
```

```
vmport=7001
args="-bios=/usr/local/u-boot/u-boot.bin -hda /var/lib/qemu/images/rataplan/myfreebsd.qcow2 -boot order=c -net nic -net bridge,br=eth0-bridge -serial telnet:localhost:$vmport,server,nowait,nodelay"
haltcmd="ssh powermanager@myfreebsd sudo poweroff"
```

```
[root@minerva ~]# systemctl daemon-reload
[root@minerva ~]# 
```

```
[root@minerva ~]# systemctl start qemu@myfreebsd
[root@minerva ~]# 
```

## Shutdown

<a href="{{ '/images/freebsd_vm_on_pi/freebsd_on_rpi_screen.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/freebsd_vm_on_pi/freebsd_on_rpi_screen.jpg' | remove_first:'/' | absolute_url }}" class="right" width="600" height="435" alt="FreeBSD on pi screen" /> </a>

We have two options to execute a poweroff. The first one is by ACPI. QEMU has a "monitor" interface that allows to execute a "system_poweroff" command. This will execute a poweroff by ACPI.

Your client operating system needs to support it. FreeBSD has good ACPI support build-in to the kernel. But I don’t know the state and how stable it is on ARM64. We’re also using U-boot.

The other option is to execute the poweroff command with ssh and sudo. Since I didn’t get ACPI working, I configured it with ssh.

### Setup ssh

### Generate a ssh key

I normally [store my ssh keys on a smartcard-hsm](https://stafwag.github.io/blog/blog/2015/11/21/starting-to-protect-my-private-keys-with-smartcard-hsm/) and use a ssh-agent. As a test, I will just use a ssh-key on the host filesystem.

I’ll migrate it when I move my raspberry-pi into my home production environment. :-)

Generate an ssh key on the QEMU host system.


```
# ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa
Your public key has been saved in /root/.ssh/id_rsa.pub
The key fingerprint is:
<snip>
The key's randomart image is:
<snip>
```

#### Install sudo

Install sudo on the FreeBSD client system. The FreeBSD package manager ```pkg``` will be installed the 
first time you execute it.

To execute the poweroff command we'll use sudo, so let's install it...

```
# pkg install -y sudo
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
	sudo: 1.9.5p2

Number of packages to be installed: 1

The process will require 4 MiB more space.
890 KiB to be downloaded.
[1/1] Fetching sudo-1.9.5p2.txz: 100%  890 KiB 911.0kB/s    00:01    
Checking integrity... done (0 conflicting)
[1/1] Installing sudo-1.9.5p2...
[1/1] Extracting sudo-1.9.5p2: 100%
# 
```

### Create the powermanager user

Create the powermanager user with the ```adduser``` command.

```
# adduser
Username: powermanager
Full name: powermanager
Uid (Leave empty for default): 
Login group [powermanager]: 
Login group is powermanager. Invite powermanager into other groups? []: 
Login class [default]: 
Shell (sh csh tcsh bash rbash nologin) [sh]: 
Home directory [/home/powermanager]: 
Home directory permissions (Leave empty for default): 
Use password-based authentication? [yes]: no
Lock out the account after creation? [no]: 
Username   : powermanager
Password   : <disabled>
Full Name  : powermanager
Uid        : 1002
Class      : 
Groups     : powermanager 
Home       : /home/powermanager
Home Mode  : 
Shell      : /bin/sh
Locked     : no
OK? (yes/no): yes
adduser: INFO: Successfully added (powermanager) to the user database.
Add another user? (yes/no): no
Goodbye!
root@rataplan:~ # 
```

#### Configure sudo

Create ```/usr/local/etc/sudoers.d/powermanager```

```
# visudo -f /usr/local/etc/sudoers.d/powermanager
```

with the permission to execute the ```poweroff``` command with out a password.

```
powermanager ALL=(ALL) NOPASSWD:/sbin/poweroff
```

#### authorized_keys 

Create the ```authorized_keys``` file for the powermanager user.

Create the ```.ssh``` directory in homedir of the powermanager.

```
# cd /home/powermanager/
# umask 027
# mkdir .ssh
# 
```

Create the authorized_keys file, it's less known that you can also restrict the access in the
authorized_keys file. We'll restrict the access to the ip address of the Linux hypervisor system. 

```
from="xxx.xxx.xxx.xxx",no-X11-forwarding ssh-rsa <snip>
```

```
root@rataplan:/home/powermanager # chown -R root:powermanager .ssh
root@rataplan:/home/powermanager # 
```

#### Test

Logon to the FreeBSD virtual machine with the create ssh key and try to execute the ``poweroff``
command.

```
# ssh powermanager@myfreebsd
The authenticity of host 'myfreebsd (192.168.1.103)' can't be established.
ED25519 key fingerprint is SHA256:R7tmX7In9D21H3hj2JiwJJVwcoQvoIR5BgJjuKgY3CI.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'myfreebsd' (ED25519) to the list of known hosts.
FreeBSD 13.0-RC3 (GENERIC) #0 releng/13.0-n244696-8f731a397ad: Fri Mar 19 03:36:50 UTC 2021

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

To change this login announcement, see motd(5).
Nice bash prompt: PS1='(\[$(tput md)\]\t <\w>\[$(tput me)\]) $(echo $?) \$ '
		-- Mathieu <mathieu@hal.interactionvirtuelle.com>
powermanager@rataplan:~ $ 
```

```
$ sudo poweroff
Shutdown NOW!
poweroff: [pid 43082]
powermanager@rataplan:~ $                                                                                
*** FINAL System shutdown message from powermanager@rataplan ***             

System going down IMMEDIATELY                                                  

                                                                               

System shutdown time has arrived
Connection to myfreebsd closed by remote host.
Connection to myfreebsd closed.
[root@minerva ~]# 
```

# Final Test

Make sure that your client system is running and configured to be start at the system startup.

```
[root@minerva ~]# systemctl enable qemu@myfreebsd
Created symlink /etc/systemd/system/multi-user.target.wants/qemu@myfreebsd.service → /etc/systemd/system/qemu@.service.
[root@minerva ~]# systemctl start qemu@myfreebsd
[root@minerva ~]# 
```

Verify that the system is running with ```systemctl status```.

```
[root@minerva ~]# systemctl status qemu@myfreebsd
● qemu@myfreebsd.service - QEMU virtual machine
     Loaded: loaded (/etc/systemd/system/qemu@.service; enabled; vendor preset: disabled)
     Active: active (running) since Sun 2021-03-21 20:24:10 CET; 2min 39s ago
   Main PID: 43360 (qemu-system-aar)
      Tasks: 5 (limit: 8536)
     CGroup: /system.slice/system-qemu.slice/qemu@myfreebsd.service
             └─43360 /usr/bin/qemu-system-aarch64 -M virt -name myfreebsd --enable-kvm -cpu host -nographic -m 4096 -smp 2 -bios /usr/local/u-boot/u-b>

Mar 21 20:24:10 minerva systemd[1]: Started QEMU virtual machine.
Mar 21 20:24:10 minerva qemu-system-aarch64[43360]: QEMU 5.2.0 monitor - type 'help' for more information
```

On one window logon to your FreeBSD client console with ```telnet```.

```
$ telnet 127.0.0.1 7001
```

On the QEMU Linux system execute 

```
# systemctl stop qemu@myfreebsd
```

The FreeBSD client should be power-down...

***Have fun!***

# Links

* [https://wiki.archlinux.org/index.php/Network_bridge](https://wiki.archlinux.org/index.php/Network_bridge)
* [https://wiki.debian.org/DebianFirewall](https://wiki.debian.org/DebianFirewall)
* [https://wiki.archlinux.org/index.php/QEMU](https://wiki.archlinux.org/index.php/QEMU)
