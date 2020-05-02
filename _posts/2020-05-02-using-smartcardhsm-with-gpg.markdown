---
layout: post
title: "Using SmartCardHsm with GnuPG" 
date: 2020-05-02 09:48:50 +0100
comments: true
categories: [ security, gnupg, gpg, smartcard, hsm, smartcard-hsm ] 
excerpt_separator: <!--more-->
---


<a href="{{ '/images/security_related/logo-gnupg-white-bg2.png' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/security_related/logo-gnupg-white-bg2.png' | remove_first:'/' | absolute_url }}" class="right" width="376" height="150" alt="GnuPG" /> </a>

When you want to store your GnuPG private key(s) on a smartcard, you have a few options like the [Yubikey](https://www.yubico.com/products/), [NitroKey GPG compatible cards](https://www.nitrokey.com/#comparison),  or the [OpenPGP](https://www.g10code.com/p-card.html). The advantage of these cards is that they support GnuPG directly. The disadvantage is that they can only store 1 or a few keys.

Another option is [SmartCardHSM](https://www.smartcard-hsm.com/), [NitroKey HSM](https://shop.nitrokey.com/shop/product/nitrokey-hsm-2-7) is based on SmartCardHsm and should be compatible. The newer versions support 4k [RSA encryption keys](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) and can store up 19 RSA 4k keys. The older version is limited to 2k RSA keys. I still have the older version. The advantage is that you can store multiple keys on the card. To use it for GPG encryption you'll need to set up a gpg-agent with [gnupg-pkcs11-scd](https://github.com/alonbl/gnupg-pkcs11-scd).
 
<!--more-->

# Prepare

## Smardcards

I use 3 smartcards to store my keys, these SmartCardHSM's were created with Device Key Encryption Key (DKEK) keys.
See my previous blog posts on how to setup SmartCardHSM with Device Key Encryption Keys:

* [Starting to protect my private keys with SmartCard-Hsm ](https://stafwag.github.io/blog/blog/2015/11/21/starting-to-protect-my-private-keys-with-smartcard-hsm/)
* [Setup a certificate authority with SmartCardHSM](https://stafwag.github.io/blog/blog/2020/04/29/setup-an-ca-with-smartcard/)


I create the public / private key pair on an air gaped system running [Kal Linux live](https://www.kali.org) and copy the key to the other smartcards. See my previous blog posts on how to do this. I'll only show how to create the keypair in this blog post.

# Setup gpg
## Create the keypair.

```
kali@kali:~$ pkcs11-tool --module opensc-pkcs11.so --keypairgen --key-type rsa:2048 --label gpg.intern.stafnet.local --login
Using slot 0 with a present token (0x0)
Key pair generated:
Private Key Object; RSA 
  label:      gpg.intern.stafnet.local
  ID:         47490caa5589d5b95e2067c5bc49b03711b854da
  Usage:      decrypt, sign, unwrap
  Access:     none
Public Key Object; RSA 2048 bits
  label:      gpg.intern.stafnet.local
  ID:         47490caa5589d5b95e2067c5bc49b03711b854da
  Usage:      encrypt, verify, wrap
  Access:     none
kali@kali:~$ 
```

## Create and upload the certificate

### Create a self signed certificate

Create a self-signed certificate based on the key pair.

```
$ openssl req -x509 -engine pkcs11 -keyform engine -new -key 47490caa5589d5b95e2067c5bc49b03711b854da -sha256 -out cert.pem -subj "/CN=gpg.intern.stafnet.local"
``` 

### Convert to DER

The certificate is created in the PEM format, to be able to upload it to the smartcard we need it in the DER format (we'd have created the certificate directly in the DER format with ```-outform der```).

```
$ openssl x509 -outform der -in cert.pem -out cert.der
```

### Upload the certificate to the smartcard(s)

```
$ pkcs11-tool --module /usr/lib64/opensc-pkcs11.so -l --write-object cert.der --type cert --id 47490caa5589d5b95e2067c5bc49b03711b854da --label "gpg.intern.stafnet.local"
Using slot 0 with a present token (0x0)
Logging in to "UserPIN (SmartCard-HSM)".
Please enter User PIN: 
Created certificate:
Certificate Object; type = X.509 cert
  label:      gpg.intern.stafnet.local
  subject:    DN: CN=gpg.intern.stafnet.local
  ID:         47490caa5589d5b95e2067c5bc49b03711b854da
$ 
```

## Setup the gpg-agent

Install the ```gnupg-pkcs11-scd``` from GNU/Linux distribution package manager.

### Configure gnupg-agent

```
$ cat ~/.gnupg/gpg-agent.conf
scdaemon-program /usr/bin/gnupg-pkcs11-scd
pinentry-program /usr/bin/pinentry
$ 
```

```
$ cat ~/.gnupg/gnupg-pkcs11-scd.conf
providers smartcardhsm
provider-smartcardhsm-library /usr/lib64/opensc-pkcs11.so
$ 
```

### Reload the agent

```
gpg-agent --server gpg-connect-agent << EOF
RELOADAGENT
EOF
```

### Verify

```
$ gpg --card-status
Application ID ...: D2760001240111503131171B486F1111
Version ..........: 11.50
Manufacturer .....: unknown
Serial number ....: 171B486F
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: 1R 1R 1R
Max. PIN lengths .: 0 0 0
PIN retry counter : 0 0 0
Signature counter : 0
Signature key ....: [none]
Encryption key....: [none]
Authentication key: [none]
General key info..: [none]
$ 
```

### Get the GPG KEY-FRIEDNLY string

```
gpg-agent --server gpg-connect-agent << EOF
SCD LEARN
EOF
```

```
$ gpg-agent --server gpg-connect-agent << EOF
> SCD LEARN
> EOF
OK Pleased to meet you
gnupg-pkcs11-scd[26682.2406156096]: Listening to socket '/tmp/gnupg-pkcs11-scd.NeQexh/agent.S'
gnupg-pkcs11-scd[26682.2406156096]: accepting connection
gnupg-pkcs11-scd[26682]: chan_0 -> OK PKCS#11 smart-card server for GnuPG ready
gnupg-pkcs11-scd[26682.2406156096]: processing connection
gnupg-pkcs11-scd[26682]: chan_0 <- GETINFO socket_name
gnupg-pkcs11-scd[26682]: chan_0 -> D /tmp/gnupg-pkcs11-scd.NeQexh/agent.S
gnupg-pkcs11-scd[26682]: chan_0 -> OK
gnupg-pkcs11-scd[26682]: chan_0 <- LEARN
gnupg-pkcs11-scd[26682]: chan_0 -> S SERIALNO D2760001240111503131171B486F1111
gnupg-pkcs11-scd[26682]: chan_0 -> S APPTYPE PKCS11
S SERIALNO D2760001240111503131171B486F1111
S APPTYPE PKCS11
gnupg-pkcs11-scd[26682]: chan_0 -> S KEY-FRIEDNLY 5780C7B3D0186C21C8C4503DDA7641FC71FD9B54 /CN=gpg.intern.stafnet.local on UserPIN (SmartCard-HSM)
gnupg-pkcs11-scd[26682]: chan_0 -> S CERTINFO 101 www\x2ECardContact\x2Ede/PKCS\x2315\x20emulated/DECM0102330/UserPIN\x20\x28SmartCard\x2DHSM\x29/47490CAA5589D5B95E2067C5BC49B03711B854DA
gnupg-pkcs11-scd[26682]: chan_0 -> S KEYPAIRINFO 5780C7B3D0186C21C8C4503DDA7641FC71FD9B54 www\x2ECardContact\x2Ede/PKCS\x2315\x20emulated/DECM0102330/UserPIN\x20\x28SmartCard\x2DHSM\x29/47490CAA5589D5B95E2067C5BC49B03711B854DA
gnupg-pkcs11-scd[26682]: chan_0 -> OK
S KEY-FRIEDNLY 5780C7B3D0186C21C8C4503DDA7641FC71FD9B54 /CN=gpg.intern.stafnet.local on UserPIN (SmartCard-HSM)
S CERTINFO 101 www\x2ECardContact\x2Ede/PKCS\x2315\x20emulated/DECM0102330/UserPIN\x20\x28SmartCard\x2DHSM\x29/47490CAA5589D5B95E2067C5BC49B03711B854DA
S KEYPAIRINFO 5780C7B3D0186C21C8C4503DDA7641FC71FD9B54 www\x2ECardContact\x2Ede/PKCS\x2315\x20emulated/DECM0102330/UserPIN\x20\x28SmartCard\x2DHSM\x29/47490CAA5589D5B95E2067C5BC49B03711B854DA
OK
gnupg-pkcs11-scd[26682]: chan_0 <- RESTART
gnupg-pkcs11-scd[26682]: chan_0 -> OK
$ gnupg-pkcs11-scd[26682]: chan_0 <- [eof]
gnupg-pkcs11-scd[26682.2406156096]: post-processing connection
gnupg-pkcs11-scd[26682.2406156096]: accepting connection
gnupg-pkcs11-scd[26682.2406156096]: cleanup connection
gnupg-pkcs11-scd[26682.2406156096]: Terminating
gnupg-pkcs11-scd[26682.2369189632]: Thread command terminate
gnupg-pkcs11-scd[26682.2369189632]: Cleaning up threads
^C
$ 
```

### Import the key into GPG

```
$ gpg --expert --full-generate-key
gpg (GnuPG) 2.2.19; Copyright (C) 2019 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
   (7) DSA (set your own capabilities)
   (8) RSA (set your own capabilities)
   (9) ECC and ECC
  (10) ECC (sign only)
  (11) ECC (set your own capabilities)
  (13) Existing key
  (14) Existing key from card
Your selection? 13
```

Use the ```KEY-FRIEDNLY``` string as the grip.

### Test

#### List your key

```
$ gpg --list-keys
/home/staf/.gnupg/pubring.kbx
-----------------------------
pub   rsa2048 2020-05-02 [SCE]
      XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
uid           [ultimate] gpg.intern.stafnet.local (signing key) <staf@wagemakers.be>

```

#### Sign

Create a test file.

```
$ echo "I'm boe." > /tmp/boe
```

Sign

```
$gpg --sign --default-key  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX /tmp/boe

```

Enter your pin code.


```
┌──────────────────────────────────────────────────────────────────────────────────┐
│ Please enter the PIN (PIN required for token 'SmartCard-HSM (UserPIN)' (try 0))  │
│ to unlock the card                                                               │
│                                                                                  │
│ PIN ____________________________________________________________________________ │
│                                                                                  │
│            <OK>                                                <Cancel>          │   
└──────────────────────────────────────────────────────────────────────────────────┘
```

#### Verify

```
$ gpg --verify /tmp/boe.gpg
gpg: Signature made Sat 02 May 2020 12:16:48 PM CEST
gpg:                using RSA key XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
gpg: Good signature from "gpg.intern.stafnet.local (signing key) <staf@wagemakers.be>" [ultimate]
```

***Have fun...***

# Links

* [https://blogs.gnome.org/danni/2017/07/07/using-the-nitrokey-hsm-with-gpg-in-macos/](https://blogs.gnome.org/danni/2017/07/07/using-the-nitrokey-hsm-with-gpg-in-macos/)
