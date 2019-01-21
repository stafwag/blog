---
layout: post
title: "Setting up OpenStack-Ansible All-In-One on a Centos 7 system"
date: 2019-01-21 19:51:32 +0100
comments: true
categories: ['openstack','ansible','centos','linux',"lxc"] 
---

{% img right /images/openstack-logo.png 150 150 "openstack-logo" %} 

[Openstack](https://www.openstack.org/) is nice platform to deploy [an Infrastructure as a service](https://en.wikipedia.org/wiki/Cloud_computing#Infrastructure_as_a_service_.28IaaS.29) and is a [collection of projects](https://governance.openstack.org/tc/reference/projects/index.html) but it can be a bit difficult to setup. [The documentation](https://docs.openstack.org) is really great if you want to setup openstack by hand and there are a few openstack distributions that makes it easier to install it.

[Ansible](https://www.ansible.org) is a very nice tool for system automatisation and is one that's easier to learn.

{% img left /images/ansible-logo-red-t.png 150 150 "ansible-logo-red" %} 

Wouldn't be nice if we could make the openstack installation easier with ansible? That's exactly what [Openstack-Ansible](https://github.com/openstack/openstack-ansible)
 does.

In this blog post we'll setup ["an all-in-one" openstack installation](https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html) on [Centos 7](https://www.centos.org). The installer will install openstack into [lxc containers](
https://linuxcontainers.org/) and it's nice way to learn how openstack works and how to operate it.

# Preparation

## System requirements

I use a Centos 7 virtual system running as a [KVM](https://www.linux-kvm.org) instance with [nested KVM virtualasation enabled](http://stafwag.github.io/blog/blog/2018/06/04/nested-virtualization-in-kvm/). The system requiremensts 
The minimun requiremenst are:

* 8 CPU cores
* 50 GB of free diskspace
* 8GB RAM

## update ....

Make sure that your system is up-to-update

```
[staf@openstack ~]$ sudo yum update -y

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for staf: 
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: distrib-coffee.ipsl.jussieu.fr
 * extras: mirror.in2p3.fr
 * updates: centos.mirror.fr.planethoster.net
base                                                                                                                                    | 3.6 kB  00:00:00     
extras                                                                                                                                  | 3.4 kB  00:00:00     
updates                                                                                                                                 | 3.4 kB  00:00:00     
No packages marked for update
[staf@openstack ~]$ 
```

## Install git

We'll need git to install the ansible playbooks and the Openstack-Ansible installation scripts.

```
[staf@openstack ~]$ yum install git
Loaded plugins: fastestmirror
You need to be root to perform this command.
[staf@openstack ~]$ sudo yum install git
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.in2p3.fr
 * extras: mirror.in2p3.fr
 * updates: centos.mirror.fr.planethoster.net
Package git-1.8.3.1-20.el7.x86_64 already installed and latest version
Nothing to do
[staf@openstack ~]$ 
```

## Ansible....

This is a bit of a pitfail... The Openstack-Ansible bootstrap script will download and install his own version of ansible and create a link to ```/usr/local/bin```. So ```/usr/local/bin``` must be in your $PATH.  Ansible shouldn't be installed on your system or if it is installed  it shouln't be executed instead of the ansible version that is builded with Openstack-Ansible.

On most GNU/Linux distributions have ```/usr/local/bin``` and ```/usr/local/sbin```  is in the $PATH but not on centos, so we'll need to add it.

### Make sure that ansible insn't installed

```
[staf@openstack ~]$ sudo rpm -qa | grep -i ansible
[sudo] password for staf: 
[staf@openstack ~]$ 
```

### Update your $PATH

```
[root@openstack ~]# export PATH=/usr/local/bin:$PATH
```
If you want to have ```/usr/local/bin``` in your $PATH  update ```/etc/profile```  or ```$HOME/.profile```

## ssh password authentication

The ansibe playbooks will disable ```PasswordAuthentication```, make sure that you login with a ssh key. - Password authentication is obsolete anyway -

## firewalld

Firewall is enabled on Centos by default, the default iptables rules prevent communication between the openstack containers.

### stop and disable firewalld

```
[root@openstack ~]# systemctl stop firewalld
[root@openstack ~]# systemctl disable firewalld
Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service.
Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service.
```

### verify

```
root@openstack ~]# iptables -L
Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
[root@openstack ~]# 
```

## selinux

There is a BUG in the selinux playbooks - [https://bugs.launchpad.net/openstack-ansible/+bug/1792050](https://bugs.launchpad.net/openstack-ansible/+bug/1792050) - I didn't check it in detail. We'll disable the selinux playbooks for now to avoid this BUG. To disable the selinux playbooks we need to set the ```security_audit_mac_changes: no``` ansible user variabele - during the installation. [https://docs.openstack.org/openstack-ansible-security/latest/auto_controls-all.html](https://docs.openstack.org/openstack-ansible-security/latest/auto_controls-all.html)

### set selinux to permissive mode

Edit /etc/selinux/config 

```
root@openstack selinux]# vi /etc/selinux/config 
[root@openstack selinux]# 
```

and change the mode to permissive mode.

```
# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
#     enforcing - SELinux security policy is enforced.
#     permissive - SELinux prints warnings instead of enforcing.
#     disabled - No SELinux policy is loaded.
SELINUX=permissive
# SELINUXTYPE= can take one of three values:
#     targeted - Targeted processes are protected,
#     minimum - Modification of targeted policy. Only selected processes are protected.
#     mls - Multi Level Security protection.
SELINUXTYPE=targeted
```

Reboot your system to change your system to permissive mode.

# Openstack installation

The installation will take some time therefor it's recommended to use an session manager like [tmux](https://github.com/tmux/tmux/) or [GNU screen](https://www.gnu.org/software/screen/)

## Bootstrap

### git clone

clone the [openstack-ansible git repo](https://git.openstack.org/openstack/openstack-ansible)

```
[root@openstack ~]# git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
Cloning into '/opt/openstack-ansible'...
remote: Counting objects: 67055, done.
remote: Compressing objects: 100% (32165/32165), done.
remote: Total 67055 (delta 45474), reused 52564 (delta 32073)
Receiving objects: 100% (67055/67055), 14.60 MiB | 720.00 KiB/s, done.
Resolving deltas: 100% (45474/45474), done.
[root@openstack ~]# 
```

```
[root@openstack ~]# cd /opt/openstack-ansible
[root@openstack openstack-ansible]# 
```

### choose you Openstack releases

Openstack has release shedule about every 6 months the current stable release is [Rocky](https://releases.openstack.org/rocky/index.html). Every Openstack release has his own branch in the git repo. Each Openstack-Ansible release is tagged in the git repo. So either you'll need checkout Openstack-Ansible release tag or the bracnh. We'll checkout the Rocky branch.

#### get the list of branches

```
[root@openstack openstack-ansible]# git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/master
  remotes/origin/stable/ocata
  remotes/origin/stable/pike
  remotes/origin/stable/queens
  remotes/origin/stable/rocky
[root@openstack openstack-ansible]# 
```

##### checkout the branch

```
[root@openstack openstack-ansible]# git checkout stable/rocky
Branch stable/rocky set up to track remote branch stable/rocky from origin.
Switched to a new branch 'stable/rocky'
[root@openstack openstack-ansible]# 

```

### Bootstrap ansible

Execute ```scripts/bootstrap-ansible.sh``` this will install the required packages and ansible playbooks.

```
[root@openstack openstack-ansible]# scripts/bootstrap-ansible.sh
+ export HTTP_PROXY=
+ HTTP_PROXY=
+ export HTTPS_PROXY=
+ HTTPS_PROXY=
+ export ANSIBLE_PACKAGE=ansible==2.5.14
+ ANSIBLE_PACKAGE=ansible==2.5.14
+ export ANSIBLE_ROLE_FILE=ansible-role-requirements.yml
+ ANSIBLE_ROLE_FILE=ansible-role-requirements.yml
+ export SSH_DIR=/root/.ssh
+ SSH_DIR=/root/.ssh
+ export DEBIAN_FRONTEND=noninteractive
+ DEBIAN_FRONTEND=noninteractive
<SNIP>
+ unset ANSIBLE_LIBRARY
+ unset ANSIBLE_LOOKUP_PLUGINS
+ unset ANSIBLE_FILTER_PLUGINS
+ unset ANSIBLE_ACTION_PLUGINS
+ unset ANSIBLE_CALLBACK_PLUGINS
+ unset ANSIBLE_CALLBACK_WHITELIST
+ unset ANSIBLE_TEST_PLUGINS
+ unset ANSIBLE_VARS_PLUGINS
+ unset ANSIBLE_STRATEGY_PLUGINS
+ unset ANSIBLE_CONFIG
+ '[' false == true ']'
+ echo 'System is bootstrapped and ready for use.'
System is bootstrapped and ready for use.
[root@openstack openstack-ansible]# 
```

#### Verify

 ```scripts/bootstrap-ansible``` created ```/opt/ansible-runtime``` and create amd updated ```//usr/local/bin``` with a few links.

```
[root@openstack openstack-ansible]# ls -ld /opt/*
drwxr-xr-x.  5 root root   56 Jan 12 11:42 /opt/ansible-runtime
drwxr-xr-x. 14 root root 4096 Jan 12 11:43 /opt/openstack-ansible
[root@openstack openstack-ansible]# ls -ltr /usr/local/bin/
total 8
lrwxrwxrwx. 1 root root   32 Jan 12 11:43 ansible -> /usr/local/bin/openstack-ansible
lrwxrwxrwx. 1 root root   39 Jan 12 11:43 ansible-config -> /opt/ansible-runtime/bin/ansible-config
lrwxrwxrwx. 1 root root   43 Jan 12 11:43 ansible-connection -> /opt/ansible-runtime/bin/ansible-connection
lrwxrwxrwx. 1 root root   40 Jan 12 11:43 ansible-console -> /opt/ansible-runtime/bin/ansible-console
lrwxrwxrwx. 1 root root   39 Jan 12 11:43 ansible-galaxy -> /opt/ansible-runtime/bin/ansible-galaxy
lrwxrwxrwx. 1 root root   36 Jan 12 11:43 ansible-doc -> /opt/ansible-runtime/bin/ansible-doc
lrwxrwxrwx. 1 root root   42 Jan 12 11:43 ansible-inventory -> /opt/ansible-runtime/bin/ansible-inventory
lrwxrwxrwx. 1 root root   32 Jan 12 11:43 ansible-playbook -> /usr/local/bin/openstack-ansible
lrwxrwxrwx. 1 root root   37 Jan 12 11:43 ansible-pull -> /opt/ansible-runtime/bin/ansible-pull
lrwxrwxrwx. 1 root root   38 Jan 12 11:43 ansible-vault -> /opt/ansible-runtime/bin/ansible-vault
-rw-r--r--. 1 root root 3169 Jan 12 11:43 openstack-ansible.rc
-rwxr-xr-x. 1 root root 2638 Jan 12 11:43 openstack-ansible
```

Verify that ansible command is one that's installed bu the Openstack-Ansible bootstrap script.

```
[root@openstack openstack-ansible]# which ansible
/usr/local/bin/ansible
```

### Bootstrap AIO

```
[root@openstack openstack-ansible]# scripts/bootstrap-aio.sh
+ export BOOTSTRAP_OPTS=
+ BOOTSTRAP_OPTS=
+++ dirname scripts/bootstrap-aio.sh
++ readlink -f scripts/..
+ export OSA_CLONE_DIR=/opt/openstack-ansible
TASK [Gathering Facts] *****************************************************************************************************
ok: [localhost]

TASK [sshd : Set OS dependent variables] ***********************************************************************************
ok: [localhost] => (item=/etc/ansible/roles/sshd/vars/RedHat_7.yml)

TASK [sshd : OS is supported] **********************************************************************************************
ok: [localhost] => {
    "changed": false, 
    "msg": "All assertions passed"
}

TASK [sshd : Install ssh packages] 
<SNIP>
EXIT NOTICE [Playbook execution success] **************************************
===============================================================================
+ popd
/opt/openstack-ansible
+ unset ANSIBLE_INVENTORY
+ unset ANSIBLE_VARS_PLUGINS
+ unset HOST_VARS_PATH
+ unset GROUP_VARS_PATH
[root@openstack openstack-ansible]# 
```

### Updated the ansible user variables

The ```bootstrap-aio.sh``` creates ```/etc/openstack_deploy``` directory that holds settings that'll be use by ansible to deploy our openstack platform.

#### disable the selinux playbooks

Edit /etc/openstack_deploy/user_variables.yml

```
[root@aio1 ~]# vi /etc/openstack_deploy/user_variables.yml
```

and add

```
security_audit_mac_changes: no
```

to the end of the file.

### Run the playbooks

We'll to run a few playbooks to setup the containers and our Openstack environment.

Move to the openstack-ansible playbook directory.

```
[root@aio1 ~]# cd /opt/openstack-ansible/playbooks/
[root@aio1 playbooks]# pwd
/opt/openstack-ansible/playbooks
[root@aio1 playbooks]# 
```

and exexcute the playbooks.

```
[root@openstack playbooks]# openstack-ansible setup-hosts.yml
[root@openstack playbooks]# openstack-ansible setup-infrastructure.yml
[root@aio1 playbooks]# openstack-ansible setup-openstack.yml
```

If all goes well your openstack installation is completed.

You can verify the openstack containers with ```lxc-ls```

```
[root@aio1 playbooks]# lxc-ls --fancy
NAME                                   STATE   AUTOSTART GROUPS            IPV4                                           IPV6 
aio1_cinder_api_container-c211b759     RUNNING 1         onboot, openstack 10.255.255.43, 172.29.237.244, 172.29.244.190  -    
aio1_galera_container-9a90cbd9         RUNNING 1         onboot, openstack 10.255.255.50, 172.29.239.126                  -    
aio1_glance_container-c05aab79         RUNNING 1         onboot, openstack 10.255.255.218, 172.29.236.160, 172.29.247.238 -    
aio1_horizon_container-81943ba2        RUNNING 1         onboot, openstack 10.255.255.160, 172.29.237.37                  -    
aio1_keystone_container-a5859104       RUNNING 1         onboot, openstack 10.255.255.40, 172.29.236.95                   -    
aio1_memcached_container-ab998d0e      RUNNING 1         onboot, openstack 10.255.255.175, 172.29.239.49                  -    
aio1_neutron_server_container-439aeb90 RUNNING 1         onboot, openstack 10.255.255.137, 172.29.239.13                  -    
aio1_nova_api_container-c83e5ef0       RUNNING 1         onboot, openstack 10.255.255.216, 172.29.236.52                  -    
aio1_rabbit_mq_container-4fd792fb      RUNNING 1         onboot, openstack 10.255.255.2, 172.29.239.62                    -    
aio1_repo_container-b39d88a1           RUNNING 1         onboot, openstack 10.255.255.227, 172.29.237.146                 -    
aio1_utility_container-fff0b6df        RUNNING 1         onboot, openstack 10.255.255.117, 172.29.237.82                  -    
[root@aio1 playbooks]# 
```


### Find the correct ip address

You should see horizon running with netstat

```
[root@aio1 ~]# netstat -pan | grep -i 443
tcp        0      0 172.29.236.100:443      0.0.0.0:*               LISTEN      12908/haproxy       
tcp        0      0 192.168.122.23:443      0.0.0.0:*               LISTEN      12908/haproxy       
unix  3      [ ]         STREAM     CONNECTED     73443    31134/tmux           
unix  2      [ ]         DGRAM                    1244303  23435/rsyslogd       
[root@aio1 ~]# 
```


## Logon to the openstack GUI (Horizon)

### Password...

```
[root@aio1 ~]# grep keystone_auth_admin_password /etc/openstack_deploy/user_secrets.yml
```

{% img center /images/openstack-ansible-aio-login.png 782 723 "openstack-ansible-aio-login.png" %} 

*** Have fun ***




# Links

* [https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html](https://docs.openstack.org/openstack-ansible/latest/user/aio/quickstart.html)
* [https://docs.openstack.org/project-deploy-guide/openstack-ansible/queens/deploymenthost.html](https://docs.openstack.org/project-deploy-guide/openstack-ansible/queens/deploymenthost.html)
* [https://bugs.launchpad.net/openstack-ansible/+bug/1792050](https://bugs.launchpad.net/openstack-ansible/+bug/1792050)
* [https://docs.openstack.org/openstack-ansible-security/latest/auto_controls-all.html](https://docs.openstack.org/openstack-ansible-security/latest/auto_controls-all.html)
* [https://blog.christophersmart.com/2016/08/09/setting-up-openstack-ansible-all-in-one-behind-a-proxy/](https://blog.christophersmart.com/2016/08/09/setting-up-openstack-ansible-all-in-one-behind-a-proxy/)
