---
layout: post
title: "Install Arch on an encrypted btrfs partition"
date: 2015-06-30 10:59
comments: true
categories: [ arch linux, btrfs, luks ] 
---

## Download the arch linux iso and boot it

After arch linux is booted verify that you have internet access if the network card is support and dchp is enabled on you network you should get a network address.

### Verify the interface

```
root@archiso ~ # ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 52:54:00:69:d4:94 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.23/24 brd 192.168.122.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a7b:481f:2f70:e688/64 scope link 
       valid_lft forever preferred_lft forever
root@archiso ~ # 
```

### Verify internet access

```
root@archiso ~ # ping -c 3 8.8.8.8                                                                                      :(
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=49 time=49.2 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=49 time=45.8 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=49 time=46.8 ms

--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 45.896/47.329/49.201/1.406 ms
root@archiso ~ # nslookup www.google.be
Server:         192.168.122.1
Address:        192.168.122.1#53

Non-authoritative answer:
Name:   www.google.be
Address: 64.233.167.94

root@archiso ~ # ping www.google.be
PING www.google.be (64.233.167.94) 56(84) bytes of data.
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=1 ttl=46 time=58.7 ms
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=2 ttl=46 time=58.7 ms
64 bytes from wl-in-f94.1e100.net (64.233.167.94): icmp_seq=3 ttl=46 time=58.4 ms
^C
--- www.google.be ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 58.479/58.645/58.742/0.230 ms
root@archiso ~ #                   

```

## ssh access

If you want to install arch linux over ssh you need to assign a root passwd and start the sshd service.

### root password

```
root@archiso ~ # passwd root       
Enter new UNIX password: 
Retype new UNIX password: 
passwd: password updated successfully
root@archiso ~ # 
```

### start sshd

```
root@archiso ~ # systemctl list-unit-files -t service | grep ssh
sshd.service                               disabled
sshd@.service                              static  
sshdgenkeys.service                        static  
root@archiso ~ # systemctl start sshd                           
root@archiso ~ #

```

### Logon remotely

```
[staf@vicky ~]$ ssh -l root 192.168.122.23
root@192.168.122.23's password: 
Last login: Tue Jun 30 09:06:00 2015 from 192.168.122.1
root@archiso ~ # 
```

## Partition

### Find your harddisk device name

```
root@archiso ~ # cat /proc/partitions 
major minor  #blocks  name

 254        0  104857600 vda
  11        0     652288 sr0
   7        0     284880 loop0
   7        1   33554432 loop1
   7        2     262144 loop2
 253        0   33554432 dm-0
root@archiso ~ # lsblk
NAME            MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sr0              11:0    1   637M  0 rom  /run/archiso/bootmnt
vda             254:0    0   100G  0 disk 
loop0             7:0    0 278.2M  1 loop /run/archiso/sfs/airootfs
loop1             7:1    0    32G  1 loop 
└─arch_airootfs 253:0    0    32G  0 dm   /
loop2             7:2    0   256M  0 loop 
└─arch_airootfs 253:0    0    32G  0 dm   /
root@archiso ~ #
```

### Overwrite it with random data

Because we are creating an ecrypted filesystem it's a good idea to overwrite it with random data.

We'll use badblocks for this another method is to use "dd if=/dev/random of=/dev/xxx" the "dd" method is probably the best method but is a lot slower.

```
root@archiso ~ # badblocks -c 10240 -s -w -t random -v /dev/vda
Checking for bad blocks in read-write mode
From block 0 to 104857599
Testing with random pattern: done                                                 
Reading and comparing: done                                                 
Pass completed, 0 bad blocks found. (0/0/0 errors)
badblocks -c 10240 -s -w -t random -v /dev/vda  29.02s user 22.75s system 2% cpu 40:37.83 total
root@archiso ~ # 
```




## Links

* <a href="https://wiki.archlinux.org/index.php/Installation_guide">https://wiki.archlinux.org/index.php/Installation_guide</a> 
* <a href="http://www.brunoparmentier.be/blog/how-to-install-arch-linux-on-an-encrypted-btrfs-partition.html">http://www.brunoparmentier.be/blog/how-to-install-arch-linux-on-an-encrypted-btrfs-partition.html</a>
* <a href="http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html">http://blog.fabio.mancinelli.me/2012/12/28/Arch_Linux_on_BTRFS.html</a>

