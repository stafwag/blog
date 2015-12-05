---
layout: post
title: "Protecting your SSH keys with SmartCard-HSM"
date: 2015-12-05 09:37:41 +0100
comments: true"http://www.smartcard-hsm.com">
categories: [ hsm, security ] 
---

I <a href="http://stafwag.github.io/blog/blog/2015/06/16/using-yubikey-neo-as-gpg-smartcard-for-ssh-authentication/">use</a> a  <a href="https://www.yubico.com/products/yubikey-hardware/yubikey-neo/">yubi key</a> for my ssh authentication. But I've other ssh keys for my remote services so wanted something that allows my to a backup of my keys see <a href="http://stafwag.github.io/blog/blog/2015/11/21/starting-to-protect-my-private-keys-with-smartcard-hsm/">this post</a> for more information on to backup/restore a <a href="http://www.smartcard-hsm.com">SmartCard-HSM</a>

## Create your first ssh keypair

### Verify your smartcard connection

Insert you smartcard and verify the connection, see <a href="http://stafwag.github.io/blog/blog/2015/11/21/starting-to-protect-my-private-keys-with-smartcard-hsm/">my previous post</a> if  you need more information about the smartcard initialization

```
[staf@vicky ~]$ pkcs11-tool -L
Available slots:
Slot 0 (0xffffffffffffffff): Virtual hotplug slot
  (empty)
Slot 1 (0x1): Generic Smart Card Reader Interface [Smart Card Reader Interface
  token label        : SmartCard-HSM (UserPIN)
  token manufacturer : www.CardContact.de
  token model        : PKCS#15 emulated
  token flags        : rng, login required, PIN initialized, token initialized
  hardware version   : 24.13
  firmware version   : 1.2
  serial num         : DECM0102331
[staf@vicky ~]$ 
```

### Create your keypair

Create your ssh key pair and give the a meaningful label

```
[staf@vicky ~]$ pkcs11-tool --slot 1 --keypairgen --key-type rsa:2048 --label my_ssh_key --login
Logging in to "SmartCard-HSM (UserPIN)".
Please enter User PIN: 
Key pair generated:
Private Key Object; RSA 
  label:      my_ssh_key
  ID:         fca6240eeef8d3156f0c4dfc591b2d938d6104cb
  Usage:      decrypt, sign, unwrap
Public Key Object; RSA 2048 bits
  label:      my_ssh_key
  ID:         fca6240eeef8d3156f0c4dfc591b2d938d6104cb
  Usage:      encrypt, verify, wrap
[staf@vicky ~]$ 
```

### Extract your public key

We used <a href="https://en.wikipedia.org/wiki/PKCS_11">PKCS11</a> to generate the keypair, <a href="https://en.wikipedia.org/wiki/PKCS">PKCS15</a> is designed identify users to applications.

#### Dump the token content

Dump the token content to get the id of your ssh keypair.

```
[staf@vicky ~]$ pkcs15-tool -D
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
PKCS#15 Card [SmartCard-HSM]:
        Version        : 0
        Serial number  : DECM0102331
        Manufacturer ID: www.CardContact.de
        Flags          : 

PIN [UserPIN]
        Object Flags   : [0x3], private, modifiable
        ID             : 01
        Flags          : [0x81A], local, unblock-disabled, initialized, exchangeRefData
        Length         : min_len:6, max_len:15, stored_len:0
        Pad char       : 0x00
        Reference      : 129 (0x81)
        Type           : ascii-numeric
        Tries left     : 3

PIN [SOPIN]
        Object Flags   : [0x1], private
        ID             : 02
        Flags          : [0x9E], local, change-disabled, unblock-disabled, initialized, soPin
        Length         : min_len:16, max_len:16, stored_len:0
        Pad char       : 0x00
        Reference      : 136 (0x88)
        Type           : bcd
        Tries left     : 3

Private EC Key [myfirst_keypair]
        Object Flags   : [0x3], private, modifiable
        Usage          : [0x10C], sign, signRecover, derive
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        FieldLength    : 256
        Key ref        : 1 (0x1)
        Native         : yes
        Path           : e82b0601040181c31f0201::
        Auth ID        : 01
        ID             : ae79417e809ed19b9a69d4c14f444462ad0bd66c
        MD:guid        : {efac9b29-2289-658c-98d1-af5af965d484}
          :cmap flags  : 0x0
          :sign        : 0
          :key-exchange: 0

Private RSA Key [my_ssh_key]
        Object Flags   : [0x3], private, modifiable
        Usage          : [0x2E], decrypt, sign, signRecover, unwrap
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        ModLength      : 2048
        Key ref        : 2 (0x2)
        Native         : yes
        Path           : e82b0601040181c31f0201::
        Auth ID        : 01
        ID             : fca6240eeef8d3156f0c4dfc591b2d938d6104cb
        MD:guid        : {a272b2ad-ff6f-606c-801a-4153be498018}
          :cmap flags  : 0x0
          :sign        : 0
          :key-exchange: 0

Public EC Key [myfirst_keypair]
        Object Flags   : [0x0]
        Usage          : [0x0]
        Access Flags   : [0x2], extract
        FieldLength    : 256
        Key ref        : 0 (0x0)
        Native         : no
        ID             : ae79417e809ed19b9a69d4c14f444462ad0bd66c
        DirectValue    : <present>

Public RSA Key [my_ssh_key]
        Object Flags   : [0x0]
        Usage          : [0x0]
        Access Flags   : [0x2], extract
        ModLength      : 2048
        Key ref        : 0 (0x0)
        Native         : no
        ID             : fca6240eeef8d3156f0c4dfc591b2d938d6104cb
        DirectValue    : <present>

[staf@vicky ~]$ 
```

#### Get the public key

```
[staf@vicky ~]$ pkcs15-tool --read-ssh-key fca6240eeef8d3156f0c4dfc591b2d938d6104cb
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCWShfPjqh+pU8lCoIhXIXh+cGpSem1iNFH6TuluQQLPiqPIeObCTfqC8q9TjR/2FYzG+3ECdiRr0fiywE9OnzUgJI5oOjXfMwY3xE1PbYBrSvYERofhkEv2ejlyRifN3sbLGSU0V7pX+BNOuiJCquCehPMV9+ehkjbk9hPRFUzL1GywsOkmWUoIzrdjH0dlhPX3TUCdoizWAIdUqg+RX4DCEc52RvaGdX4Tn2THxeffXqFJ/gKkParZSLmOND1iRhtJeJ8CmgAqfD8ReshbcSs231h/QvUl3JaThcrLbPrSQFzVUH+rN+pGlSl722NWyPNPWlwwE+SreTLbQRoWayN my_ssh_key
[staf@vicky ~]$ 
```

### Configure the remote host

Add the key to the remote host

```
staf@vicky .ssh]$ vi authorized_keys 
[staf@vicky .ssh]$ 

```

### Test the connection

Test you ssh connection with the PKCS11 interface:

```
[staf@vicky ~]$ ssh localhost
Permission denied (publickey,gssapi-keyex,gssapi-with-mic).
```

With the PKCS11 interface enabled:

```
[staf@vicky ~]$ ssh -o "PKCS11Provider opensc-pkcs11.so" localhost
C_GetAttributeValue failed: 18
Enter PIN for 'SmartCard-HSM (UserPIN)': 
Last login: Thu Dec  3 09:55:23 2015 from ::1
gpg-agent[17327]: enabled debug flags: command cache ipc
gpg-agent: a gpg-agent is already running - not starting a new one
gpg-agent: secmem usage: 0/32768 bytes in 0 blocks
[staf@vicky ~]$ 
```

### Update your ssh_config

Add PKCS11Provider opensc-pkcs11.so to your ~/.ssh/config or your global ssh_config

```
staf@vicky ~]$ cd .ssh/
[staf@vicky .ssh]$ vim config
PKCS11Provider opensc-pkcs11.so
[staf@vicky .ssh]$ 
``` 

*** Have fun ... ***

