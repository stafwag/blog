---
layout: post
title: "High screen resolution on a KVM virtual machine with QXL"
date: 2018-04-22 10:04:46 +0200
comments: true
categories: [ qxl, linux, kvm. qemu ] 
---

When you create an new virtual KVM virtual system the video ram is limited to 16MB by default to use a higer screen resolution you need
to increase the video ram. The available resolution reported by the virtual screen may also not include the resolution that you want to 
utilize.

You'll find my journey to enable higher screen resoltions in my KVM (qemu) virtual systems below.

## Ubuntu 16.04 

There is an issue with Ubuntu 16.04 and the latest HWE kernel <a href="https://wiki.ubuntu.com/Kernel/LTSEnablementStack">https://wiki.ubuntu.com/Kernel/LTSEnablementStack</a>. Even a full HD resultion (1920 x 1080 ) if you have the latest HWE kernel on your system.

To resolve this issue your can uninstall the latest kernel or install the LTS kernel.

#### Install the LTS Kernel

```
staf@ubuntu:~$ sudo apt-get install linux-generic-lts-xenial
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  linux-generic linux-headers-4.4.0-119 linux-headers-4.4.0-119-generic linux-headers-generic
  linux-image-4.4.0-119-generic linux-image-extra-4.4.0-119-generic linux-image-generic
Suggested packages:
  fdutils linux-doc-4.4.0 | linux-source-4.4.0 linux-tools
The following NEW packages will be installed:
  linux-generic linux-generic-lts-xenial linux-headers-4.4.0-119 linux-headers-4.4.0-119-generic
  linux-headers-generic linux-image-4.4.0-119-generic linux-image-extra-4.4.0-119-generic linux-image-generic
0 upgraded, 8 newly installed, 0 to remove and 0 not upgraded.
Need to get 69,3 MB of archives.
After this operation, 301 MB of additional disk space will be used.
Do you want to continue? [Y/n] 
<snip>
Setting up linux-image-generic (4.4.0.119.125) ...
Setting up linux-headers-4.4.0-119 (4.4.0-119.143) ...
Setting up linux-headers-4.4.0-119-generic (4.4.0-119.143) ...
Setting up linux-headers-generic (4.4.0.119.125) ...
Setting up linux-generic (4.4.0.119.125) ...
Setting up linux-generic-lts-xenial (4.4.0.119.125) ...
staf@ubuntu:~$ 
```

#### Remove the HWE kernel

```
staf@ubuntu:~$ sudo apt-get purge linux-image-4.13*
Reading package lists... Done
Building dependency tree       
Reading state information... Done
<snip>
done
The link /vmlinuz.old is a damaged link
Removing symbolic link vmlinuz.old 
 you may need to re-run your boot loader[grub]
The link /initrd.img.old is a damaged link
Removing symbolic link initrd.img.old 
 you may need to re-run your boot loader[grub]
Purging configuration files for linux-image-4.13.0-38-generic (4.13.0-38.43~16.04.1) ...
Examining /etc/kernel/postrm.d .
run-parts: executing /etc/kernel/postrm.d/initramfs-tools 4.13.0-38-generic /boot/vmlinuz-4.13.0-38-generic
run-parts: executing /etc/kernel/postrm.d/zz-update-grub 4.13.0-38-generic /boot/vmlinuz-4.13.0-38-generic
```

#### Cleanup

```
staf@ubuntu:~$ sudo apt autoremove
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be REMOVED:
  linux-headers-4.13.0-36 linux-headers-4.13.0-36-generic linux-headers-generic-hwe-16.04
0 upgraded, 0 newly installed, 3 to remove and 0 not upgraded.
After this operation, 83,1 MB disk space will be freed.
Do you want to continue? [Y/n] 
(Reading database ... 234149 files and directories currently installed.)
Removing linux-headers-4.13.0-36-generic (4.13.0-36.40~16.04.1) ...
Removing linux-headers-4.13.0-36 (4.13.0-36.40~16.04.1) ...
Removing linux-headers-generic-hwe-16.04 (4.13.0.38.57) ...
staf@ubuntu:~$ 
```

#### Reboot

After a reboot higher resoltions are possible on ubuntu 16.04

# Increase the video RAM

## Required video ram

When you create a new KVM virtual machine it has 16MB of video RAM.
Below you'll the calculation for the required video RAM for a 4k resoltion ( 3840 x 2160 ).

3840 x 2160 = 8294400 <br/>
8294400 x 32 = 265420800 <br/ >
265420800 / 8 = 33177600 <br />
33177600 / (1024*1024) = 31.640625 MB

So 32 MB video ram is enough for a 4k resolution, to take some overhead into account we'll increase the video ram to 64 MB.

##  list the domains

```
[swagemakers@staflaptop ~]$ sudo virsh
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh # list --all
 Id    Name                           State
----------------------------------------------------
 -     centos7.0                      shut off
 -     debian                         shut off
 -     fedora27                       shut off

virsh # 
```

#### edit the domain settings

```
virsh # edit --domain debian
```

##### update the memory settings

```
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <redirdev bus='usb' type='spicevmc'>

```

to

```
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='65536' heads='1' primary='yes'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
```

#### xrandr

Even with the additional RAM higer resolution aren't possible (yet), the virtual screen doesn't report the higer screen resolution. It's possible to add the higher screen resolution with xrandr.

##### display current settings

```
staf@debian:~$ xrandr 
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 8192 x 8192
Virtual-0 connected primary 1920x1080+0+0 0mm x 0mm
   1024x768      59.95 +
   1920x1200     59.95  
   1920x1080     60.00* 
   1600x1200     59.95  
   1680x1050     60.00  
   1400x1050     60.00  
   1280x1024     59.95  
   1440x900      59.99  
   1280x960      59.99  
   1280x854      59.95  
   1280x800      59.96  
   1280x720      59.97  
   1152x768      59.95  
   800x600       59.96  
   848x480       59.94  
   720x480       59.94  
   640x480       59.94  
Virtual-1 disconnected
Virtual-2 disconnected
Virtual-3 disconnected
staf@debian:~$ 
```

###### get the modeline

```
staf@debian:~$ cvt 2560 1440 
# 2560x1440 59.96 Hz (CVT 3.69M9) hsync: 89.52 kHz; pclk: 312.25 MHz
Modeline "2560x1440_60.00"  312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
staf@debian:~$ 
```

####### create the new mode line

```
staf@debian:~$ xrandr --newmode "2560x1440_60.00"  312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
staf@debian:~$ 
```

####### add the mode to your screen

```
staf@debian:~$ xrandr --addmode Virtual-0 2560x1440_60.00
staf@debian:~$ 
```
####### use the new mode

```
staf@debian:~$ xrandr --output Virtual-0 --mode 2560x1440_60.00
staf@debian:~$ 
```

######## 4k

To use a 4k resolution you can use the commands

```
staf@debian:~$  cvt 3840 2160
# 3840x2160 59.98 Hz (CVT 8.29M9) hsync: 134.18 kHz; pclk: 712.75 MHz
Modeline "3840x2160_60.00"  712.75  3840 4160 4576 5312  2160 2163 2168 2237 -hsync +vsync
staf@mydevolo:~$ xrandr --newmode "3840x2160_60.00"  712.75  3840 4160 4576 5312  2160 2163 2168 2237 -hsync +vsync
staf@mydevolo:~$ xrandr --addmode Virtual-0 3840x2160_60.00
staf@mydevolo:~$ xrandr --output Virtual-0 --mode 3840x2160_60.00
staf@mydevolo:~$ 
```

## Add the new screen resolution permanently

### Debian & Co

Create a monitor configuration file in /usr/share/X11/xorg.conf.d

```
root@mydevolo:/usr/share/X11/xorg.conf.d# vi 10-monitor.conf
```

And add the modeline fgor your screen resolution. 
With the Option "PreferredMode" you can set the prferred resolution. 


```
section "Monitor"
    Identifier "Virtual-0 "
    Modeline "2560x1440_60.00"  312.25  2560 2752 3024 3488  1440 1443 1448 1493 -hsync +vsync
    Modeline "3840x2160_60.00"  712.75  3840 4160 4576 5312  2160 2163 2168 2237 -hsync +vsync
    Option "PreferredMode" "2560x1440_60.00"
EndSection
```

### Other GNU/Linux distros

Most other GNU/Linux distribution use /etc/X11/xorg.conf.d/

*** Have fun ***

# Links

* <a href="https://wiki.archlinux.org/index.php/xrandr">https://wiki.archlinux.org/index.php/xrandr</a>
* <a href="https://askubuntu.com/questions/994449/ubuntu-16-04-kvm-qxl-guest-cant-change-resolution">https://askubuntu.com/questions/994449/ubuntu-16-04-kvm-qxl-guest-cant-change-resolution</a>


