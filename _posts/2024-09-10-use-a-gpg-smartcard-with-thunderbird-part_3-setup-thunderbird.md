---
layout: post
title: "Use a GPG smartcard with Thunderbird. Part 3: Setup Thunderbird"
date: 2024-09-10 17:05:00 +0200
comments: true
categories: linux security thunderbird gpg pgp email debian freebsd hsm smartcard
excerpt_separator: <!--more-->
---


In previous blog posts, we discussed setting up a GPG smartcard on [GNU](https://www.gnu.org)/[Linux](https://www.kernel.org) and [FreeBSD](https://www.freebsd.org).

In this blog post, we will configure [Thunderbird](https://www.thunderbird.net) to work with an external smartcard reader and our [GPG](https://gnupg.org/)-compatible smartcard.

<a href="{{ '/images/gpg/thunderbird/beastie_gnu_tux.jpg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/beastie_gnu_tux_s.jpg' | remove_first:'/' | absolute_url }}" class="left" width="400" height="267" alt="beastie gnu tux" /> </a>

Before Thunderbird 78, if you wanted to use OpenPGP email encryption, you had to use a third-party add-on such as [https://enigmail.net/](Enigmail).

Thunderbird's recent versions natively support OpenPGP.  The Enigmail addon for Thunderbird has been discontinued.
See: [https://enigmail.net/index.php/en/home/news](https://enigmail.net/index.php/en/home/news).

I didn't find good documentation on how to set up Thunderbird with a GnuPG smartcard when I moved to a new [coreboot](https://www.coreboot.org/) laptop, so this was the reason I created this blog post series.

<!--more-->

# GnuPG configuration

We'll not go into too much detail on how to set up GnuPG. This was already explained in the previous blog posts.

* [Use a GPG smartcard with Thunderbird. Part 1: setup GnuPG](https://stafwag.github.io/blog/blog/2024/04/21/use-a-gpg-smartcard-with-thunderbird-part_1-setup-gpg/)
* [Use a GPG smart card with Thunderbird. Part 2: setup GnuPG on FreeBSD](https://stafwag.github.io/blog/blog/2024/07/28/use-a-gpg-smartcard-with-thunderbird-part_2-setup-gpg-on-freebsd/)

If you want to use a [HSM](https://en.wikipedia.org/wiki/Hardware_security_module) with GnuPG you can use the ```gnupg-pkcs11-scd``` agent [https://github.com/alonbl/gnupg-pkcs11-scd](https://github.com/alonbl/gnupg-pkcs11-scd) that translates the ```pkcs11``` interface to GnuPG. A previous blog post describes how this can be configured with [SmartCard-HSM](https://www.smartcard-hsm.com/). 

* [https://stafwag.github.io/blog/blog/2020/05/02/using-smartcardhsm-with-gpg/](https://stafwag.github.io/blog/blog/2020/05/02/using-smartcardhsm-with-gpg/)

We'll go over some steps to make sure that the GnuPG is set up correctly before we continue with the Thunderbird configuration. The ```pinentry``` command must be
 configured with graphical support to type our pin code in the Graphical user environment.
 
## Import Public Key

Make sure that your public key - or the public key of the reciever(s) - is/are imported.

```
[staf@snuffel ~]$ gpg --list-keys
[staf@snuffel ~]$ 
```

```
[staf@snuffel ~]$ gpg --import <snip>.asc
gpg: key XXXXXXXXXXXXXXXX: public key "XXXX XXXXXXXXXX <XXX@XXXXXX>" imported
gpg: Total number processed: 1
gpg:               imported: 1
[staf@snuffel ~]$ 
```

```
[staf@snuffel ~]$  gpg --list-keys
/home/staf/.gnupg/pubring.kbx
-----------------------------
pub   xxxxxxx YYYYY-MM-DD [SC]
      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
uid           [ xxxxxxx] xxxx xxxxxxxxxx <xxxx@xxxxxxxxxx.xx>
sub   xxxxxxx xxxx-xx-xx [A]
sub   xxxxxxx xxxx-xx-xx [E]

[staf@snuffel ~]$ 
```

## Pinentry

Thunderbird will not ask for your smartcard’s pin code.

This must be done on your smartcard reader if it has a pin pad or an external ```pinentry``` program.

The ```pinentry``` is configured in the ```gpg-agent.conf``` configuration file. As we're using Thunderbird is a graphical environment we'll configure it to use a graphical version.

### Installation

I'm testing KDE plasma 6 on FreeBSD, so I installed the Qt version of pinentry.

On GNU/Linux you can check the documentation of your favourite Linux distribution to install a graphical ```pinentry```. If you use a Graphical user environment there is probably already a graphical-enabled ```pinentry``` installed.

```
[staf@snuffel ~]$ sudo pkg install -y pinentry-qt6
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 1 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        pinentry-qt6: 1.3.0

Number of packages to be installed: 1

76 KiB to be downloaded.
[1/1] Fetching pinentry-qt6-1.3.0.pkg: 100%   76 KiB  78.0kB/s    00:01    
Checking integrity... done (0 conflicting)
[1/1] Installing pinentry-qt6-1.3.0...
[1/1] Extracting pinentry-qt6-1.3.0: 100%
==> Running trigger: desktop-file-utils.ucl
Building cache database of MIME types
[staf@snuffel ~]$ 
```

### Configuration

The ```gpg-agent``` is responsible for starting the ```pinentry``` program. Let's reconfigure it to start the ```pinentry``` that we like to use.

```
[staf@snuffel ~]$ cd .gnupg/
[staf@snuffel ~/.gnupg]$ 
```

```
[staf@snuffel ~/.gnupg]$ vi gpg-agent.conf
```

The ```pinentry``` is configured in the  ```pinentry-program``` directive. You'll find the complete ```gpg-agent.conf``` that I'm using below.

```
debug-level expert
verbose
verbose
log-file /home/staf/logs/gpg-agent.log
pinentry-program /usr/local/bin/pinentry-qt
```

Reload the ```sdaemon``` and ```gpg-agent``` configuration.

```
staf@freebsd-gpg3:~/.gnupg $ gpgconf --reload scdaemon
staf@freebsd-gpg3:~/.gnupg $ gpgconf --reload gpg-agent
staf@freebsd-gpg3:~/.gnupg $ 
```

## Test

To verify that ```gpg``` works correctly and that the ```pinentry``` program works in our graphical environment we sign a file.

Create a new file.


```
$ cd /tmp
[staf@snuffel /tmp]$ 
```

```
[staf@snuffel /tmp]$ echo "foobar" > foobar
[staf@snuffel /tmp]$ 
```

Try to sign it.

```
[staf@snuffel /tmp]$ gpg --sign foobar
[staf@snuffel /tmp]$ 
```

If everything works fine, the ```pinentry``` program will ask for the pincode to sign it.

![image info]({{ '/images/gpg/thunderbird/pin-entry_a.png' | remove_first:'/' | absolute_url }})


# Thunderbird

In this section we'll (finally) configure Thunderbird to use GPG with a smartcard reader.

## Allow external smartcard reader

<div style="clear: both;">

<a href="{{ '/images/gpg/thunderbird/tb0000.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0000.png' | remove_first:'/' | absolute_url }}" class="right" width="100" height="157" alt="open settings" /> </a>

<p>
Open the global settings, click on the "Hamburger" icon and select <b>settings</b>.
</p>

<p>
Or press <b>[F10]</b> to bring-up the "Menu bar" in Thunderbird and select <b>[Edit]</b> and <b>Settings</b>.
</p>

</div>

<div style="clear: both;padding-top: 20px;">
<a href="{{ '/images/gpg/thunderbird/tb0001.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0001.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="open settings" /> </a>

<p>

In the settings window click on <b>[Config Editor]</b>.

</p>

<p>This will open the <i>Advanced Preferences</i> window.</p>

</div>

<div style="clear: both;padding-top: 20px;">
<a href="{{ '/images/gpg/thunderbird/tb0002.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0002.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="allow external gpg" /> </a>

<p>
In the <i>Advanced Preferences</i> window search for "external_gnupg" settings and set <b><i>mail.indenity.allow_external_gnupg</i></b> to <b><i>true</i></b>.
</p>
</div>

<div style="clear: both;">
<br />&nbsp;<br />
</div>

## Setup End-To-End Encryption

The next step is to configure the GPG keypair that we'll use for our user account.

<div style="clear: both;padding-top: 20px;">

<a href="{{ '/images/gpg/thunderbird/tb0003.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0003.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="open settings" /> </a>

<p>
Open the account setting by pressing on the "Hamburger" icon and select <b>Account Settings</b> or press <b>[F10]</b> to open the menu bar and select <b>Edit</b>, <b>Account Settings</b>.
</p>

<p>
Select <b>End-to-End Encryption</b> at <b>OpenPG</b> section select <b>[ Add Key ]</b>.
</p>

</div>

<div style="clear: both;padding-top: 20px;">
<a href="{{ '/images/gpg/thunderbird/tb0004.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0004.png' | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="open settings" /> </a>
<p>
Select the <b>( * ) Use your external key though GnuPG (e.g. from a smartcard)</b>
</p>
<p>
And click on <b>[Continue]</b>
</p>
<p>
The next window will ask you for the <i>Secret Key ID</i>.
</p>
</div>
<div style="clear: both;padding-top: 20px;">
<a href="{{ '/images/gpg/thunderbird/tb0004b.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0004b.png' | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="open settings" /> </a>

<p>
Execute <code>gpg --list-keys</code> to get your secret key id.
</p>
<p>
Copy/paste your key id and click on <b>[ Save key ID ]</b>.
</p>
</div>

<div style="clear: both;padding-top: 20px;">
<p>
I found that it is sometimes required to restart Thunderbird to reload the configuration when a new key id is added.
So restart Thunderbird or restart it fails to find your key id  in the keyring.
</p>
</div>

## Test

<div style="clear: both;">

<a href="{{ '/images/gpg/thunderbird/tb0005.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0005.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="open settings" /> </a>

<p>
As a test we send an email to our own email address.
</p>

<p>
Open a new message window and enter your email address into the <b>To:</b> field.
</p>
<p>
Click on <b>[OpenPGP]</b> and <b>Encrypt</b>.
</p>

</div>

<div style="clear: both;padding-top: 20px; ">

<a href="{{ '/images/gpg/thunderbird/tb0006.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0006.png' | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="open settings" /> </a>

<p>
Thunderbird will show a warning message that it doesn't know the public key to set up the encryption.
</p>

<p>
Click on <b>[Resolve]</b>. 
</p>

</div>

<div style="clear: both;padding-top: 20px; ">
<a href="{{ '/images/gpg/thunderbird/tb0007.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0007.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="discover keys" /> </a>

In the next window Thunderbird will ask to <i>Discover Public Keys online</i> or to import the <i>Public Keys From File</i>, we'll import our public key from a file.

</div>

<div style="clear: both;padding-top: 20px; ">
<a href="{{ '/images/gpg/thunderbird/tb0008.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0008.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="open key file" /> </a>

In the <i>Import OpenPGP key File</i> window select your public key file, and click on <b>[ Open ]</b>.

</div>

<div style="clear: both;padding-top: 20px; ">
<a href="{{ '/images/gpg/thunderbird/tb0009.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0009.png' | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="open settings" /> </a>

<p>
Thunderbird will show a window with the key fingerprint. Select <i>( * ) Accepted</i>.
</p>

<p>
Click on <b>[ Import ]</b> to import the public key.
</p>
</div>

<div style="clear: both;padding-top: 20px; ">

<a href="{{ '/images/gpg/thunderbird/tb0010.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0010.png' | remove_first:'/' | absolute_url }}" class="right" width="300" height="225" alt="open settings" /> </a>

<p>
With our public key imported, the warning about the <i>End-to-end encryption requires resolving key</i> issue should be resolved.
</p>

<p>
Click on the <b>[ Send ]</b> button to send the email.
</p>

</div>

<div style="clear: both;padding-top: 20px; ">

<a href="{{ '/images/gpg/thunderbird/tb0011.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/gpg/thunderbird/tb0011.png' | remove_first:'/' | absolute_url }}" class="left" width="300" height="225" alt="open settings" /> </a>

<p>
To encrypt the message, Thunderbird will start a <code>gpg</code> session that invokes the <code>pinentry</code> command type in your pincode. gpg will encrypt the message file and if everything works fine the email is sent.
</p>

</div>
<div style="clear: both;padding-top: 20px; ">
&nbsp;
</div>
***Have fun!***

# Links

* [https://wiki.mozilla.org/Thunderbird:OpenPGP](https://wiki.mozilla.org/Thunderbird:OpenPGP)
* [https://wiki.mozilla.org/Thunderbird:OpenPGP:Smartcards](https://wiki.mozilla.org/Thunderbird:OpenPGP:Smartcards)
* [https://support.mozilla.org/en-US/kb/openpgp-thunderbird-howto-and-faq](https://support.mozilla.org/en-US/kb/openpgp-thunderbird-howto-and-faq)
* [https://addons.thunderbird.net/nl/thunderbird/addon/enigmail/](https://addons.thunderbird.net/nl/thunderbird/addon/enigmail/)
* [https://wiki.debian.org/Smartcards/OpenPGP](https://wiki.debian.org/Smartcards/OpenPGP)
* [https://www.floss-shop.de/en/security-privacy/smartcards/13/openpgp-smart-card-v3.4?c=11](https://www.floss-shop.de/en/security-privacy/smartcards/13/openpgp-smart-card-v3.4?c=11)
* [https://www.gnupg.org/howtos/card-howto/en/smartcard-howto-single.html](https://www.gnupg.org/howtos/card-howto/en/smartcard-howto-single.html)
* [https://support.nitrokey.com/t/nk3-mini-gpg-selecting-card-failed-no-such-device-gpg-card-setup/5057/7](https://support.nitrokey.com/t/nk3-mini-gpg-selecting-card-failed-no-such-device-gpg-card-setup/5057/7)
* [https://security.stackexchange.com/questions/233916/gnupg-connecting-to-specific-card-reader-when-multiple-reader-available#233918](https://security.stackexchange.com/questions/233916/gnupg-connecting-to-specific-card-reader-when-multiple-reader-available#233918)
* [https://www.fsij.org/doc-gnuk/stop-scdaemon.html](https://www.fsij.org/doc-gnuk/stop-scdaemon.html)
* [https://wiki.debian.org/Smartcards](https://wiki.debian.org/Smartcards)
* [https://github.com/OpenSC/OpenSC/wiki/Overview/c70c57c1811f54fe3b3989d01708b45b86fafe11](https://github.com/OpenSC/OpenSC/wiki/Overview/c70c57c1811f54fe3b3989d01708b45b86fafe11)
* [https://superuser.com/questions/1693289/gpg-warning-not-using-as-default-key-no-secret-key](https://superuser.com/questions/1693289/gpg-warning-not-using-as-default-key-no-secret-key)
* [https://stackoverflow.com/questions/46689885/how-to-get-public-key-from-an-openpgp-smart-card-without-using-key-servers](https://stackoverflow.com/questions/46689885/how-to-get-public-key-from-an-openpgp-smart-card-without-using-key-servers)
