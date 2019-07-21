---
layout: post
title: "Migrate a windows vmware virtual machine to Linux KVM"
date: 2018-07-01 10:49:41 +0200
comments: true
categories: [linux,kvm,vmware] 
---

<a href="https://www.linux-kvm.org">Linux KVM</a> is getting more and more useable for desktop virtualization thanks to the the [virtio](https://www.linux-kvm.org/page/Virtio) and [QXL/SPICE](https://www.linux-kvm.org/page/SPICE) drivers.

Most Linux distributes have the virtio & QXL drivers you might need to install the spice-vdagent.

On Windows you can download and install the virtio and QXL drivers.

Using the virtio drivers will improve your guest system performance and your virtualization experience. 

## Convert the disk image
### merge the vmware disk images...

If you use split disk images on vmware ( or vmware player ) migrate them to a single disk images with the vmware-vdiskmanager command.
  
```
$ vmware-vdiskmanager -r mywin.vmdk -t 0 /tmp/mywin._combined.vmdk
Creating disk '/var/lib/libvirt/images/tmp/mywin._combined.vmdk'
  Convert: 100% done.
Virtual disk conversion successful.
$
```

### convert the vmdk  image to qcow2

Convert the VMDK disk image to qcow2

```
[staf@vicky vboxes]$ qemu-img convert -f vmdk -O qcow2 mywin._combined.vmdk mywin.qcow2
```

### mv

```
[staf@vicky vboxes]$ sudo mv mywin_combined.qcow2 /var/lib/libvirt/images/
[sudo] password for staf: 

```
## Import the disk image to KVM

We'll inport the disk image with ```virt-install``` it's also posible to import the images with ```virt-manager``` if you prefer a graphical interface or or just being lazy :-)

## Available os options

To list the supported operation system you can use the ```osinfo-query os``` command

```
[staf@vicky ~]$ osinfo-query os | head
 Short ID             | Name                                               | Version  | ID                                      
----------------------+----------------------------------------------------+----------+-----------------------------------------
 alpinelinux3.5       | Alpine Linux 3.5                                   | 3.5      | http://alpinelinux.org/alpinelinux/3.5  
 alpinelinux3.6       | Alpine Linux 3.6                                   | 3.6      | http://alpinelinux.org/alpinelinux/3.6  
 alpinelinux3.7       | Alpine Linux 3.7                                   | 3.7      | http://alpinelinux.org/alpinelinux/3.7  
 altlinux1.0          | Mandrake RE Spring 2001                            | 1.0      | http://altlinux.org/altlinux/1.0        
 altlinux2.0          | ALT Linux 2.0                                      | 2.0      | http://altlinux.org/altlinux/2.0        
 altlinux2.2          | ALT Linux 2.2                                      | 2.2      | http://altlinux.org/altlinux/2.2        
 altlinux2.4          | ALT Linux 2.4                                      | 2.4      | http://altlinux.org/altlinux/2.4        
 altlinux3.0          | ALT Linux 3.0                                      | 3.0      | http://altlinux.org/altlinux/3.0        
```

```
[staf@vicky ~]$ osinfo-query os |  grep -i windows
 win1.0               | Microsoft Windows 1.0                              | 1.0      | http://microsoft.com/win/1.0            
 win10                | Microsoft Windows 10                               | 10.0     | http://microsoft.com/win/10             
 win2.0               | Microsoft Windows 2.0                              | 2.0      | http://microsoft.com/win/2.0            
 win2.1               | Microsoft Windows 2.1                              | 2.1      | http://microsoft.com/win/2.1            
 win2k                | Microsoft Windows 2000                             | 5.0      | http://microsoft.com/win/2k             
 win2k12              | Microsoft Windows Server 2012                      | 6.3      | http://microsoft.com/win/2k12           
 win2k12r2            | Microsoft Windows Server 2012 R2                   | 6.3      | http://microsoft.com/win/2k12r2         
 win2k16              | Microsoft Windows Server 2016                      | 10.0     | http://microsoft.com/win/2k16           
 win2k3               | Microsoft Windows Server 2003                      | 5.2      | http://microsoft.com/win/2k3            
 win2k3r2             | Microsoft Windows Server 2003 R2                   | 5.2      | http://microsoft.com/win/2k3r2          
 win2k8               | Microsoft Windows Server 2008                      | 6.0      | http://microsoft.com/win/2k8            
 win2k8r2             | Microsoft Windows Server 2008 R2                   | 6.1      | http://microsoft.com/win/2k8r2          
 win3.1               | Microsoft Windows 3.1                              | 3.1      | http://microsoft.com/win/3.1            
 win7                 | Microsoft Windows 7                                | 6.1      | http://microsoft.com/win/7              
 win8                 | Microsoft Windows 8                                | 6.2      | http://microsoft.com/win/8              
 win8.1               | Microsoft Windows 8.1                              | 6.3      | http://microsoft.com/win/8.1            
 win95                | Microsoft Windows 95                               | 4.0      | http://microsoft.com/win/95             
 win98                | Microsoft Windows 98                               | 4.1      | http://microsoft.com/win/98             
 winme                | Microsoft Windows Millennium Edition               | 4.9      | http://microsoft.com/win/me             
 winnt3.1             | Microsoft Windows NT Server 3.1                    | 3.1      | http://microsoft.com/winnt/3.1          
 winnt3.5             | Microsoft Windows NT Server 3.5                    | 3.5      | http://microsoft.com/winnt/3.5          
 winnt3.51            | Microsoft Windows NT Server 3.51                   | 3.51     | http://microsoft.com/winnt/3.51         
 winnt4.0             | Microsoft Windows NT Server 4.0                    | 4.0      | http://microsoft.com/winnt/4.0          
 winvista             | Microsoft Windows Vista                            | 6.0      | http://microsoft.com/win/vista          
 winxp                | Microsoft Windows XP                               | 5.1      | http://microsoft.com/win/xp             
[staf@vicky ~]$ 
```

### import

We need to import the disk image as IDE device since we don't have the virtio driver in our windows disk image (yet).

```
[root@vicky ~]# virt-install --name "mywin" --ram 8192 --cpu host --os-variant win10 --vcpu 8 --disk /var/lib/libvirt/images/mywin_combined.qcow2,bus=ide --network bridge=virbr0 --import

Starting install...

(virt-viewer:3361): GSpice-WARNING **: 16:49:26.546: Warning no automount-inhibiting implementation available

```

## Install the virtio drivers and QXL graphics drivers

### Get them...

#### Type of virtio drivers

The following virtio windows drivers are available.

* block (disk drivers)
* network
* baloon ((dynamic memory management)

The fedoraproject provides pre compiled iso images containig all the virtio drivers and installation images for
windows XP.

#### ISO contents

* NetKVM/ - Virtio network driver
* viostor/ - Virtio block driver
* vioscsi/ - Virtio Small Computer System Interface (SCSI) driver
* viorng/ - Virtio RNG driver
* vioser/ - Virtio serial driver
* Balloon/ - Virtio memory balloon driver
* qxl/ - QXL graphics driver for Windows 7 and earlier. (build virtio-win-0.1.103-1 and later)
* qxldod/ - QXL graphics driver for Windows 8 and later. (build virtio-win-0.1.103-2 and later)
* pvpanic/ - QEMU pvpanic device driver (build virtio-win-0.1.103-2 and later)
* guest-agent/ - QEMU Guest Agent 32bit and 64bit MSI installers
* qemupciserial/ - QEMU PCI serial device driver
* \*.vfd VFD floppy images for using during install of Windows XP

#### Download

The virtio windows driver images are available from
[https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html](https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html)

I use arch linux and download virtio-win AUR package with pacaur. You can download the images directly or use the installation packages for your Linux distribution.

```
[staf@vicky ~]$ pacaur -S virtio-win
:: Package virtio-win not found in repositories, trying AUR...
:: resolving dependencies...
:: looking for inter-conflicts...

AUR Packages  (1) virtio-win-0.1.149.2-1  

:: Proceed with installation? [Y/n] 
<snip>
  -> Compressing package...
==> Leaving fakeroot environment.
==> Finished making: virtio-win 0.1.149.2-1 (Sat Jun 16 20:00:22 2018)
==> Cleaning up...
:: Installing virtio-win package(s)...
loading packages...
resolving dependencies...
looking for conflicting packages...

Packages (1) virtio-win-0.1.149.2-1

Total Installed Size:  314.84 MiB

:: Proceed with installation? [Y/n] 
(1/1) checking keys in keyring                                         [#######################################] 100%
(1/1) checking package integrity                                       [#######################################] 100%
(1/1) loading package files                                            [#######################################] 100%
(1/1) checking for file conflicts                                      [#######################################] 100%
(1/1) checking available disk space                                    [#######################################] 100%
:: Processing package changes...
(1/1) installing virtio-win                                            [#######################################] 100%
Optional dependencies for virtio-win
    qemu [installed]
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...
[staf@vicky ~]$ ls -l /var/li
```

This install virtio images to ```/usr/share/virtio/```

```
[staf@vicky ~]$  ls -l /usr/share/virtio/
total 321308
-rw-r--r-- 1 root root 324233216 Jun 16 19:58 virtio-win.iso
-rw-r--r-- 1 root root   2949120 Jun 16 19:58 virtio-win_x86_32.vfd
-rw-r--r-- 1 root root   2949120 Jun 16 19:58 virtio-win_x86_64.vfd
[staf@vicky ~]$ 
```

```virtio-win.iso``` is the ISO cdrom image containing all the drivers.

## Installation

### mount the iso image

<img src="{{ '/images/virto_windows_install/mount_cdrom_000.png' | absolute_url }}" width="816" height="689" alt="mount_cdrom_000.png" /> 

Make sure that the cdrom is mounted in windows.

<img src="{{ '/images/virto_windows_install/cdrom_mounted_000.png' | absolute_url }}" width="798" height="605" alt="mount_cdrom_000.png" /> 


### Install

#### Open Device Manager

Open device Manager in the control panel or type ```devmgmt.msc``` on the command prompt.

<img src="{{ '/images/virto_windows_install/devmgmt_msc_000.png' | absolute_url }}" width="835" height="728" alt="mount_cdrom_000.png" /> 

#### Update the drivers

* balloon, the balloon driver affects the PCI device
* vioserial, affects the PCI simple communication controler
* NetKVM, the network driver affects the Network adapters.
* viostor, the block driver affects the Disk drives.

##### Update the PCI drivers

In windows 10 the **PCI device** and the **PCI Simple Communications Controller** have the missing driver icon.
Right click on the **PCI device** and select **update driver** -> click on **Browse my computer for driver software**
Specify the cdrom as the search location and click **Next**, this will install the Balloon driver.

Do the same for the **PCI Simple Communications Controller** this will install the "VirtIO Serial Driver"


<img src="{{ '/images/virto_windows_install/update_pci_000.png' | absolute_url }}" width="790" height="586" alt="update_pci_000.png" /> 
<img src="{{ '/images/virto_windows_install/update_pci_001.png' | absolute_url }}" width="792" height="594" alt="update_pci_001.png" /> 
<img src="{{ '/images/virto_windows_install/update_pci_002.png' | absolute_url }}" width="792" height="577" alt="update_pci_002.png" /> 
<img src="{{ '/images/virto_windows_install/update_pci_003.png' | absolute_url }}" width="788" height="578" alt="update_pci_003.png" /> 


##### install the VioStor driver

Add a temporary disk to the virtual machine and use **VirtIO** as the **Bus Type**
In the **Device Manager** you'll get a new device **SCSI Controller** right click it and update the driver.
This will install the **Red Hat VirtIO SCSI controller**


<img src="{{ '/images/virto_windows_install/install_viostor_000.png' | absolute_url }}" width="552" height="567" alt="install_viostor_000.png" /> 
<img src="{{ '/images/virto_windows_install/install_viostor_001.png' | absolute_url }}" width="786" height="576" alt="install_viostor_001.png" /> 
<img src="{{ '/images/virto_windows_install/install_viostor_002.png' | absolute_url }}" width="622" height="461" alt="install_viostor_002.png" /> 

Go to the device settings of your virtual machine and change the **Disk bus** to **VirtIO**
and shutdown you virtual machine.

<img src="{{ '/images/virto_windows_install/install_viostor_003.png' | absolute_url }}" width="705" height="689" alt="install_viostor_003.png" /> 

You can remove the temporary disk now or leave it if you can find some use for it...

Make sure that you disk is selected as the bootable device.

<img src="{{ '/images/virto_windows_install/install_viostor_004.png' | absolute_url }}" width="885" height="689" alt="install_viostor_004.png" /> 

Start the virtual machine and make sure that the system is bootable.

###### install the netKVM driver

Update the **Device model** to **virtio**.

<img src="{{ '/images/virto_windows_install/use_virtio_net_000.png' | absolute_url }}" width="699" height="689" alt="use_virtio_net_000.png" /> 

Start ```devmgmt.msc``` and update the driver as we did before....

<img src="{{ '/images/virto_windows_install/install_netkvm_000.png' | absolute_url }}" width="809" height="737" alt="install_netkvm_000.png" /> 
<img src="{{ '/images/virto_windows_install/install_netkvm_001.png' | absolute_url }}" width="788" height="586" alt="install_netkvm_001.png" /> 

And verify that you network card works correctly.

<img src="{{ '/images/virto_windows_install/install_netkvm_002.png' | absolute_url }}" width="902" height="645" alt="install_netkvm_002.png" /> 

###### install the QXL graphical driver

Update the **Microsoft Basic Display Adapter**

<img src="{{ '/images/virto_windows_install/install_qxl_000.png' | absolute_url }}" width="792" height="581" alt="install_qxl_000.png" /> 
<img src="{{ '/images/virto_windows_install/install_qxl_001.png' | absolute_url }}" width="788" height="582" alt="install_qxl_001.png" /> 
<img src="{{ '/images/virto_windows_install/install_qxl_002.png' | absolute_url }}" width="863" height="597" alt="install_qxl_002.png" /> 

After the installation you can change the the display resolution.

<img src="{{ '/images/virto_windows_install/install_qxl_003.png' | absolute_url }}" width="812" height="651" alt="install_qxl_003.png" /> 

If you want to use higher screen resolutions you need to <a href="https://stafwag.github.io/blog/blog/2018/04/22/high-screen-resolution-on-a-kvm-virtual-machine-with-qxl/">increase the video ram</a>    


***Have fun!***






## Links

* [https://raymii.org/s/articles/virt-install_introduction_and_copy_paste_distro_install_commands.html](https://raymii.org/s/articles/virt-install_introduction_and_copy_paste_distro_install_commands.html)
* [http://bart.vanhauwaert.org/hints/installing-win10-on-KVM.html](http://bart.vanhauwaert.org/hints/installing-win10-on-KVM.html)
* [https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html](https://docs.fedoraproject.org/quick-docs/en-US/creating-windows-virtual-machines-using-virtio-drivers.html)
* [https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers](https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers)
* [https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/form-virtualization_host_configuration_and_guest_installation_guide-para_virtualized_drivers-mounting_the_image_with_virt_manager](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/virtualization_host_configuration_and_guest_installation_guide/form-virtualization_host_configuration_and_guest_installation_guide-para_virtualized_drivers-mounting_the_image_with_virt_manager)
