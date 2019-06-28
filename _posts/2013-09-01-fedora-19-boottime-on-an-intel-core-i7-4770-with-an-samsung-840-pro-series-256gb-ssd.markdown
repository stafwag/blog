---
layout: post
title: "fedora 19 boottime on an intel core i7 4770 with a Samsung 840 Pro Series 256GB ssd"
date: 2013-09-01 12:21
comments: true
categories: [debian, fedora, intel i7, ssd, boottime, ovirt] 
---

I installed <a href="http://fedoraproject.org/">fedora 19</a> on <a href="http://stafwag.github.io/blog/blog/2013/08/25/the-benefits-of-stopping-smoking-dot-dot-dot/">my new pc</a> mainly to play with <a href="http://www.ovirt.org/">ovirt</a> which seems to be easier to install on  <a href="http://fedoraproject.org/">fedora</a> than on <a href="http://www.debian.org">Debian</a>.


Don't worry I still have a debian system at hand...

The boot time on a ssd is fast:


{% youtube V99FyD1qmzg %}


##### Sun Sep  8 15:30:18 CEST 2013 update;

 
I did some tweaking to get a better bootime;

disabled plymouth;

```
# systemctl mask plymouth-.
# dracut -f -H -o plymouth
```
replaced firewalld by "static" iptables;
```
# yum install iptables-services
# systemctl mask firewalld.service
# systemctl enable iptables.service
# systemctl enable ip6tables.service
```

My /home was still on a regular harddisk I move it to the ssd.

```

$ systemd-analyze 
Startup finished in 687ms (kernel) + 705ms (initrd) + 1.328s (userspace) = 2.721s
$ systemd-analyze blame
           546ms postfix.service
           537ms NetworkManager.service
           508ms accounts-daemon.service
           102ms nfs-lock.service
            62ms proc-fs-nfsd.mount
            59ms polkit.service
            55ms lvm2-monitor.service
            54ms NetworkManager-dispatcher.service
            54ms abrt-ccpp.service
            54ms jexec.service
            53ms udisks2.service
            52ms autofs.service
            49ms var-lib-nfs-rpc_pipefs.mount
            45ms avahi-daemon.service
            43ms colord.service
            41ms systemd-logind.service
            41ms rtkit-daemon.service
            40ms gdm.service
            37ms systemd-fsck-root.service
            33ms systemd-vconsole-setup.service
            32ms fedora-loadmodules.service
            28ms chronyd.service
            28ms systemd-udev-trigger.service
            26ms dev-hugepages.mount
            26ms dev-mqueue.mount
            26ms sys-kernel-debug.mount
            25ms lm_sensors.service
            24ms systemd-fsck@dev-disk-by\x2duuid-16608012\x2d1711\x2d42d7\x2d8652\x2d900e2d22ed40.service
            23ms tmp.mount
            22ms sys-kernel-config.mount
            19ms systemd-user-sessions.service
            16ms systemd-journal-flush.service
            16ms mcelog.service
            15ms proc-sys-fs-binfmt_misc.mount
            14ms bluetooth.service
            12ms systemd-sysctl.service
            12ms systemd-tmpfiles-setup-dev.service
            12ms rpcbind.service
            12ms xinetd.service
             8ms systemd-udevd.service
             7ms fedora-readonly.service
             7ms lvm2-lvmetad.service
             6ms sshd.service
             5ms systemd-readahead-collect.service
             5ms boot.mount
             5ms upower.service
             4ms dev-mapper-fedora_vicky\x2dswap.swap
             4ms systemd-remount-fs.service
             3ms systemd-tmpfiles-setup.service
             3ms systemd-update-utmp-runlevel.service
             2ms auditd.service
             1ms systemd-random-seed-load.service
             1ms systemd-readahead-done.service
             1ms sys-fs-fuse-connections.mount

```

Result:
{% youtube gp96Tt349DM %}
