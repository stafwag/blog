---
layout: post
title: "Getting started with GitLab-CE. Part 2: User accounts, SSH access"
date: 2023-11-26 19:39:00 +0200
comments: true
categories: linux git gitlab homelab ci/cd
excerpt_separator: <!--more-->
---

In my previous blog post, we [installed GitLab-CE](https://stafwag.github.io/blog/blog/2023/11/15/getting_started_with_gitlab-ce/) and did some post configuration.
In this blog post, we'll continue to create user accounts and set up SSH to the git repository.

In the next blog posts will add code to GitLab and set up [GitLab runners](https://docs.gitlab.com/runner/) on different Operating systems.
<!--more-->

# Users

## Update root password

There was an initial root user with a password created during the installation, the initial root password is saved - or was saved as GitLab will delete the initial password after 24H - to ```/etc/gitlab/initial_root_password```.

To update the root password, log in to GitLab with your web browser click on your “avatar” icon and click on [ Edit profile ]

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/001_root_edit_profile.png "root edit profile")

Select [ Password ] to update the root password.

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/002_root_update_password.png "update root password")

You need to re-login after the password is updated.

## Creating users

In this section we’ll set up an additional administrator user, I usually try to have a backup admin account. It isn’t recommended to use an admin account directly so we’ll set up a regular user that we can use for your daily development tasks.

The full documentation about GitLab users is available at: [https://docs.gitlab.com/ee/user/profile/account/create_accounts.html#create-users-in-admin-area](https://docs.gitlab.com/ee/user/)

### Admin user

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/003_root_go_to_admin_area.png "go to admin area")

In the admin area select users on the left-hand side.

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/004_new_user.png "new user")

In the New user window, fill in the Account Name / Username and Email Address. Please note that you can’t use admin as this is a reversed user name in GitLab.
At the **Access level** select Administrator.

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/005_admin_user.png "admin user")

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/006_admin_user_done.png "admin user")

If everything goes well you or the user will receive an email to reset his or her password.

### Regular user

Repeat the same steps to create a normal user and keep the **Access level** to "Regular".

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/007_normal_user_done.png "admin user")

# GitLab SSH access

To access your git repositories using ssh you’ll need to upload your ssh public key.
I use hardware tokens ( [smartcard-hsm](https://www.smartcard-hsm.com/) ) to protect my private keys.

You can find more information on how to use SmartCard-HSM with ssh in a previous blog post: [https://stafwag.github.io/blog/blog/2015/12/05/protecting-your-ssh-keys-with-smartcard-hsm/](https://stafwag.github.io/blog/blog/2015/12/05/protecting-your-ssh-keys-with-smartcard-hsm/)


You can find information on how to generate a ssh key pair for GitLab at:[https://docs.gitlab.com/ee/user/ssh.html](https://docs.gitlab.com/ee/user/ssh.html)

If you don’t mind having your keypair on your filesystem you can use the steps below ( but I advise you to look at the better options ).

## Generate a ssh key pair

Execute ```ssh-keygen``` to generate a ssh key-pair.

I recommend using a passphrase so the private key is encrypted; this prevents an attacker from copying it as plain text from the filesystem. To prevent that you need to type in a passphrase during the development you can use a ssh-agent so you don’t need to type in your password each time you push a commit to your git repository (see below).

The unencrypted key is still stored in memory if you use an ssh-agent unless you store your private key on a hardware token (HSM).

Please note that we use a non-default ssh key location in the command below ```~/.ssh/testgitlab.key```, we update your ``ssh`` client config to use this private key.

```
[staf@vicky ~]$ ssh-keygen -f ~/.ssh/testgitlab.key -t ed25519 -C "test gitlab key"
Generating public/private ed25519 key pair.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/staf/.ssh/testgitlab.key
Your public key has been saved in /home/staf/.ssh/testgitlab.key.pub
The key fingerprint is:
SHA256:m4TpKmOjvwkoY2H3arG3tTLTOgYeA03BJoACD86Gkr0 test gitlab key
The key's randomart image is:
+--[ED25519 256]--+
|B ...            |
|** +             |
|=+B              |
|o. o   o         |
| oE.  o S        |
|o o=.. . o       |
|=.. *.o.o        |
|oo==.O...        |
|.+=*+oB.         |
+----[SHA256]-----+
[staf@vicky ~]$ 
```

## Upload the public key to GitLab

Edit your profile.

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/007_add_ssh_key_001.png "007_add_ssh_key_001.png")

Goto **SSH Keys** and select [ Add new key ].

```
[staf@vicky ~]$ cat ~/.ssh/testgitlab.key.pub 
ssh-ed25519 <snip> test gitlab key
[staf@vicky ~]$ 
```

Add the public key to GitLab. If you don't want to set an **Expiration date**, clear the field.

And click on [ Add key ]

![Alt text]( ../../../../../images/gitlab/explore_gitlab_ce/007_add_ssh_key_002.png "007_add_ssh_key_002.png")

When you upload your public key to the GitLab GUI, it will update ```~/.ssh/authorized_keys``` for the ```git``` user. The ```git``` user was created during the installation.

Let's quickly review it.

Log on to your GitLab server.

```
[staf@vicky ~]$ ssh staf@gitlab.stafnet.local 
Linux gitlab 6.1.0-13-arm64 #1 SMP Debian 6.1.55-1 (2023-09-29) aarch64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sat Nov 25 08:02:53 2023 from 192.168.1.10
staf@gitlab:~$ 
```

Get details about the ```git``` user.

```
staf@gitlab:~$ cat /etc/passwd | grep -i git
gitlab-www:x:999:996::/var/opt/gitlab/nginx:/bin/false
git:x:996:995::/var/opt/gitlab:/bin/sh
gitlab-redis:x:995:994::/var/opt/gitlab/redis:/bin/false
gitlab-psql:x:994:993::/var/opt/gitlab/postgresql:/bin/sh
gitlab-prometheus:x:993:992::/var/opt/gitlab/prometheus:/bin/sh
staf@gitlab:~$ 
```

Display the ```~/.ssh/authorized_keys``` contents.

```
staf@gitlab:~$ sudo cat /var/opt/gitlab/.ssh/authorized_keys
[sudo] password for staf: 
command="/opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell key-1",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty <snip>
command="/opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell key-2",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty <snip>
command="/opt/gitlab/embedded/service/gitlab-shell/bin/gitlab-shell key-3",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty <snip>
staf@gitlab:~$ 
```

## Test connection

Check the connection with the command below. Please note that we use the ```git``` user. GitLab will use the matching public key to determine (map to) the real GitLab user.

```
[staf@vicky ~]$ ssh -T git@gitlab.stafnet.local -i ~/.ssh/testgitlab.key 
Enter passphrase for key '/home/staf/.ssh/testgitlab.key': 
Welcome to GitLab, @stafwag!
[staf@vicky ~]$ 
```

The ```-T``` option disables pseudo-terminal allocation (```pty```). Without it you'll get a warning.

## Reconfigure your SSH client

We'll update the ssh config to use our private key.

Open your ssh config with your favourite editor.

```
[staf@vicky ~]$ vi ~/.ssh/config
```

Add a section for our GitLab host and set the  ```IdentityFile``` set to our private key.

```
Host gitlab.stafnet.local
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/testgitlab.key
```

Test the SSH access.

```
[staf@vicky ~]$ ssh -T git@gitlab.stafnet.local
Welcome to GitLab, @stafwag!
[staf@vicky ~]$ 
```

## Use a ssh-agent

We'll add our private key to the ```ssh-agent``` to avoid the need to type in our password each time we perform a git action. 

Most modern Unix desktop systems ( [GNOME](https://www.gnome.org/), [KDE](https://kde.org/), [Xfce](https://xfce.org/) ) will set up a ```ssh-agent``` automatically.

Some GNU/Linux distributions will even add to the key automatically when you use it.
My FreeBSD desktop (Xfce) only starts the ```ssh-agent```.

When your Unix desktop doesn't set up a ```ssh-agent``` you'll need to start it.

When a ssh-agent is configured the ```SSH_AGENT_PID``` and the ```SSH_AUTH_SOCK``` environment variables are set.

Check if there is already a ssh-agent configured.

```
staf@fedora39:~$ set | grep SSH
SSH_CLIENT='192.168.122.1 49618 22'
SSH_CONNECTION='192.168.122.1 49618 192.168.122.96 22'
SSH_TTY=/dev/pts/2
staf@fedora39:~$ 
```

The easiest way to start a ```ssh-agent``` and set up the environment variables is to execute the command ```eval $(ssh-agent)```.

```
staf@fedora39:~$ eval $(ssh-agent)
Agent pid 3542
staf@fedora39:~$ 
```

This starts the ```ssh-agent```, ```eval``` will execute the ssh-agent output and set the required environment variables.

```
staf@fedora39:~$ set | grep SSH
SSH_AGENT_PID=3542
SSH_AUTH_SOCK=/tmp/ssh-XXXXXXcQhGER/agent.3541
SSH_CLIENT='192.168.122.1 60044 22'
SSH_CONNECTION='192.168.122.1 60044 192.168.122.96 22'
SSH_TTY=/dev/pts/2
staf@fedora39:~$ 
```

Add the private key to the ```ssh-agent```.

```
staf@fedora39:~$ ssh-add /home/staf/.ssh/testgitlab.key
Enter passphrase for /home/staf/.ssh/testgitlab.key: 
Identity added: /home/staf/.ssh/testgitlab.key (test gitlab key)
staf@fedora39:~$ 
```

Test the connection.

```
staf@fedora39:~$ ssh -T git@gitlab.stafnet.local
Welcome to GitLab, @stafwag!
staf@fedora39:~$ 
```
With everything set up we’re ready to start to use GitLab. In a further blog post we will go start with adding code to GitLab, add runners and create artifacts.

***Have fun!***

# Links

* [https://docs.gitlab.com/ee/user/profile/account/create_accounts.html#create-users-in-admin-area](https://docs.gitlab.com/ee/user/profile/account/create_accounts.html#create-users-in-admin-area)
* [https://docs.gitlab.com/ee/user/](https://docs.gitlab.com/ee/user/)
* [https://docs.gitlab.com/ee/user/ssh.html](https://docs.gitlab.com/ee/user/ssh.html)

