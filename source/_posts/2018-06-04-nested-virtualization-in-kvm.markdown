---
layout: post
title: "Nested virtualization in KVM"
date: 2018-06-04 19:58:06 +0200
comments: true
categories: [linux,kvm, qemu] 
---

## KVM

<a href="https://www.linux-kvm.org">Kernel-based Virtual Machine (KVM)</a> has become the defacto hypervisor on GNU/Linux systems it works with great performance as it utilizes the CPU virtualization extensions <a href="https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_(VT-x)">Inetl VT-x</a> or <a href="https://en.wikipedia.org/wiki/X86_virtualization#AMD_virtualization_(AMD-V)">AMD-V</a>). KVM doesn't emulate hardware but uses <a href="https://www.qemu.org/">QEMU</a> for this.

## Nested Virtual guest

It's possible to use nested virtualization this make it possible to run a hypervisor inside a KVM virtual machine.


## Enabling nested virtualization in KVM

### Verify

To verify if nested virtualization is enabled on your system can check /sys/module/kvm_intel/parameters/nested on Intal systems or /sys/module/kvm_amd/parameters/nested 

```
[staf@frija ~]$ cat /sys/module/kvm_intel/parameters/nested
N
[staf@frija ~]$ 
```

### Enable

#### Shutdown all virtual machines

Make sure that there no virtual machines running.

```
[root@frija ~]# virsh 
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh # list
 Id    Name                           State
----------------------------------------------------

virsh # 
``` 

#### Unload KVM

Unload the KVM kernel module.

```
[root@frija ~]# modprobe -r kvm_intel
[root@frija ~]# 
```

#### Load KVM and activate nested

Reload the KVM with the nested feature enabled.

```
[root@frija ~]# modprobe kvm_intel nested=1
[root@frija ~]# 
```

Verify

```
[root@frija ~]# cat /sys/module/kvm_intel/parameters/nested
Y
[root@frija ~]# 
```

To enable the nested feature permanently create /etc/modprobe.d/kvm_intel.conf

```
[root@frija ~]# vi /etc/modprobe.d/kvm_intel.conf
```

and enable the nested option.

```
options kvm_intel nested=1
```

## Enabling nested virtialization in the virtual machine

When you logon to a virtual machine and verify the virtualization extensions on the cpu the flags aren't available.  

```
[staf@centos7 ~]$ cat /proc/cpuinfo | grep  -i -E "vmx|svm"
[staf@centos7 ~]$ 
```

To enable nested virtualization in a vritual machine you can 

* start ```virsh``` and and edit the the virtual machine and change the CPU line to ```<cpu mode='host-model' check='partial'/>```
* Open virt-manager and select __Copy host CPU configuration__ on the CPU configuration

```
root@frija ~]# virsh 
Welcome to virsh, the virtualization interactive terminal.

Type:  'help' for help with commands
       'quit' to quit

virsh # list
 Id    Name                           State
----------------------------------------------------
 1     centos7.0                      running

virsh # edit centos7.0 
```

Change the cpu settings

```
  <features>
    <acpi/>
    <apic/>
    <vmport state='off'/>
  </features>
  <cpu mode='host-model' check='partial'>
    <model fallback='allow'/>
  </cpu>

```

Shutdown the virtual machine

```
virsh # reboot centos7.0 
Domain centos7.0 is being rebooted

virsh # 

```

Start the virtual machine


```
virsh # start centos7.0  
Domain centos7.0 started
```

Verify that the ```feature policies``` on the cpu are updated.

```
virsh # dumpxml centos7.0 
```

```
 <cpu mode='custom' match='exact' check='full'>
    <model fallback='forbid'>Haswell-noTSX-IBRS</model>
    <vendor>Intel</vendor>
    <feature policy='require' name='vme'/>
    <feature policy='require' name='ss'/>
    <feature policy='require' name='f16c'/>
    <feature policy='require' name='rdrand'/>
    <feature policy='require' name='hypervisor'/>
    <feature policy='require' name='arat'/>
    <feature policy='require' name='tsc_adjust'/>
    <feature policy='require' name='xsaveopt'/>
    <feature policy='require' name='pdpe1gb'/>
    <feature policy='require' name='abm'/>
    <feature policy='require' name='ibpb'/>
 </cpu>
```

Logon to the virtual machine and verify the cpu flags;

```
[staf@centos7 ~]$ cat /proc/cpuinfo | grep -i vmx
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology eagerfpu pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs arat spec_ctrl
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology eagerfpu pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs arat spec_ctrl
[staf@centos7 ~]$ cat /proc/cpuinfo | grep  -i "vmx|svm"
[staf@centos7 ~]$ cat /proc/cpuinfo | grep  -i -E "vmx|svm"
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology eagerfpu pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs arat spec_ctrl
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ss syscall nx pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology eagerfpu pni pclmulqdq vmx ssse3 fma cx16 pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer aes xsave avx f16c rdrand hypervisor lahf_lm abm tpr_shadow vnmi flexpriority ept vpid fsgsbase tsc_adjust bmi1 avx2 smep bmi2 erms invpcid xsaveopt ibpb ibrs arat spec_ctrl
```

Execute the ```virt-host-validate```

```
[staf@centos7 ~]$ virt-host-validate
  QEMU: Checking for hardware virtualization                                 : PASS
  QEMU: Checking if device /dev/kvm exists                                   : PASS
  QEMU: Checking if device /dev/kvm is accessible                            : PASS
  QEMU: Checking if device /dev/vhost-net exists                             : PASS
  QEMU: Checking if device /dev/net/tun exists                               : PASS
  QEMU: Checking for cgroup 'memory' controller support                      : PASS
  QEMU: Checking for cgroup 'memory' controller mount-point                  : PASS
  QEMU: Checking for cgroup 'cpu' controller support                         : PASS
  QEMU: Checking for cgroup 'cpu' controller mount-point                     : PASS
  QEMU: Checking for cgroup 'cpuacct' controller support                     : PASS
  QEMU: Checking for cgroup 'cpuacct' controller mount-point                 : PASS
  QEMU: Checking for cgroup 'cpuset' controller support                      : PASS
  QEMU: Checking for cgroup 'cpuset' controller mount-point                  : PASS
  QEMU: Checking for cgroup 'devices' controller support                     : PASS
  QEMU: Checking for cgroup 'devices' controller mount-point                 : PASS
  QEMU: Checking for cgroup 'blkio' controller support                       : PASS
  QEMU: Checking for cgroup 'blkio' controller mount-point                   : PASS
  QEMU: Checking for device assignment IOMMU support                         : WARN (No ACPI DMAR table found, IOMMU either disabled in BIOS or not supported by this hardware platform)
   LXC: Checking for Linux >= 2.6.26                                         : PASS
   LXC: Checking for namespace ipc                                           : PASS
   LXC: Checking for namespace mnt                                           : PASS
   LXC: Checking for namespace pid                                           : PASS
   LXC: Checking for namespace uts                                           : PASS
   LXC: Checking for namespace net                                           : PASS
   LXC: Checking for namespace user                                          : PASS
   LXC: Checking for cgroup 'memory' controller support                      : PASS
   LXC: Checking for cgroup 'memory' controller mount-point                  : PASS
   LXC: Checking for cgroup 'cpu' controller support                         : PASS
   LXC: Checking for cgroup 'cpu' controller mount-point                     : PASS
   LXC: Checking for cgroup 'cpuacct' controller support                     : PASS
   LXC: Checking for cgroup 'cpuacct' controller mount-point                 : PASS
   LXC: Checking for cgroup 'cpuset' controller support                      : PASS
   LXC: Checking for cgroup 'cpuset' controller mount-point                  : PASS
   LXC: Checking for cgroup 'devices' controller support                     : PASS
   LXC: Checking for cgroup 'devices' controller mount-point                 : PASS
   LXC: Checking for cgroup 'blkio' controller support                       : PASS
   LXC: Checking for cgroup 'blkio' controller mount-point                   : PASS
   LXC: Checking if device /sys/fs/fuse/connections exists                   : FAIL (Load the 'fuse' module to enable /proc/ overrides)
[staf@centos7 ~]$ 
```

***Have fun***

## Links

* <a href="https://docs.fedoraproject.org/quick-docs/en-US/using-nested-virtualization-in-kvm.html">https://docs.fedoraproject.org/quick-docs/en-US/using-nested-virtualization-in-kvm.html</a>
* <a href="https://wiki.archlinux.org/index.php/KVM#Nested_virtualization">https://wiki.archlinux.org/index.php/KVM#Nested_virtualization</a>
* <a href="https://www.linux-kvm.org/page/Nested_Guests">https://www.linux-kvm.org/page/Nested_Guests</a>
