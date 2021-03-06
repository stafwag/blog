---
layout: post
title: "Starting to protect my private keys with SmartCard-Hsm"
date: 2015-11-21 10:32:06 +0100
comments: true
categories: [ hsm, security ] 
---

I still have too many private keys on a local filesystem, I started to use the <a href="https://www.yubico.com/products/yubikey-hardware/yubikey-neo/">yubikey neo</a> for <a href="http://stafwag.github.io/blog/blog/2015/06/16/using-yubikey-neo-as-gpg-smartcard-for-ssh-authentication/">my ssh authentication</a>. Mainly because the nice formfactor of the yubikey. 

For my other private keys/data I was looking for something cheeper since I need to have a backup of my secured data so I bought a few <a href="http://www.smartcard-hsm.com">Smartcard-HSM smartcards</a> they cost 16 &euro; each while a yubi-key neo cost 54 &euro; at amazon.de

## Preparing Backup and Restore 

The Smartcard-HSM has a backup/restore functionality this needs to be enabled before any keys are generated on the HSM.

To store our Device Key Encryption Key (DKEK) securely we need a safe place, we'll use an ecrypted usb stick.

It'is possible to configure multiple DKEK shares e.g. you will need multiple keys to perform a backup restore you might want to store these DKEK shares over multiple (encrypted) USB sticks/people.

If you want to create a backup of your DKEK shares we need to store at least two encrypted USB sticks. 

For the convenience we'll store all DKEK shares on 1 encrypted USB stick in the example below you should executed it on an secured computer.

### Install opensc

```
staf@vicky ~]$ sudo dnf install opensc
Last metadata expiration check performed 0:23:14 ago on Wed Nov 11 14:47:21 2015.
Package opensc-0.15.0-2.fc23.x86_64 is already installed, skipping.
Dependencies resolved.
Nothing to do.
Complete!
[staf@vicky ~]$ 
```

### Create an encrypted USB key stick


#### Write random data to the USB stick

```
[staf@vicky ~]$ sudo dd if=/dev/urandom of=/dev/sdn bs=1024
[sudo] password for staf:                                                                                      
dd: error writing ‘/dev/sdn’: No space left on device                                                          
4029441+0 records in                                                                                           
4029440+0 records out                                                                                          
4126146560 bytes (4.1 GB) copied, 1280.14 s, 3.2 MB/s                                                          
[staf@vicky ~]$ 
```

#### luksFormat

```
[staf@vicky ~]$ sudo cryptsetup luksFormat --cipher serpent-cbc-essiv:sha256 --key-size 256 /dev/sdn

WARNING!
========
This will overwrite data on /dev/sdn irrevocably.

Are you sure? (Type uppercase yes): YES
Enter passphrase: 
Verify passphrase: 
[staf@vicky ~]$ sudo cry
cryptoflex-tool  cryptsetup       crywrap          
[staf@vicky ~]$ sudo cryptsetup luksOpen /dev/sdn myprivatedata
Enter passphrase for /dev/sdn: 
[staf@vicky ~]$ 
```

#### luksOpen

```
[staf@vicky ~]$ sudo cryptsetup luksOpen /dev/sdn myprivatedata
Enter passphrase for /dev/sdn: 
[staf@vicky ~]$ 
```

#### mkfs

```
[staf@vicky ~]$ sudo mkfs.ext4 /dev/mapper/myprivatedata
mke2fs 1.42.13 (17-May-2015)
Creating filesystem with 1007360 4k blocks and 251968 inodes
Filesystem UUID: 49390936-49e3-4606-abf2-567c3f5b50e1
Superblock backups stored on blocks: 
        32768, 98304, 163840, 229376, 294912, 819200, 884736

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (16384 blocks): done
Writing superblocks and filesystem accounting information: done 

[staf@vicky ~]$ 
```

### Verify the encrypted USB stick

To verify that the USB stick is encrypted and we can't mount without typing our passphrase we'll close the luks device and mount it.

#### luksClose

```
[staf@vicky ~]$ sudo cryptsetup luksClose myprivatedata
[sudo] password for staf: 
[staf@vicky ~]$ 
```

#### Try to mount it without luksOpen

```
[staf@vicky ~]$ sudo mount /dev/sdn /mnt
mount: unknown filesystem type 'crypto_LUKS'
[staf@vicky ~]$ 
```

#### Mount it with luksOpen / mount

```
[staf@vicky ~]$ sudo cryptsetup luksOpen /dev/sdn myhsm_dkek
Enter passphrase for /dev/sdn: 
[staf@vicky ~]$ sudo mount /dev/mapper/myhsm_dkek /mnt
[staf@vicky ~]$ 
```

#### update the ownership

Update the usb stick ownership

```
[staf@vicky mnt]$ sudo chown staf:staf .
[sudo] password for staf: 
[staf@vicky mnt]$ 
```

## SmartCard initialization

### pcsc_scan

#### start the pcscd service

Start/enable the pcscd service if didn't enable it before

```
root@vicky ~]# systemctl list-unit-files -t service | grep pcscd
pcscd.service                               static  
[root@vicky ~]# systemctl start pcscd
[root@vicky ~]# systemctl enable pcscd
[root@vicky ~]# 
```

#### run pcsc_scan

Insert the smartcard into the read, run pcsc_scan to verify that you see the smartcard  

```
[staf@vicky mnt]$ pcsc_scan                    
PC/SC device scanner
V 1.4.23 (c) 2001-2011, Ludovic Rousseau <ludovic.rousseau@free.fr>
Compiled with PC/SC lite version: 1.8.13
Using reader plug'n play mechanism
Scanning present readers...
0: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00

Wed Nov 11 10:58:59 2015
Reader 0: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
  Card state: Card inserted, 
  ATR: 3B FE 18 00 00 81 31 FE 45 80 31 81 54 48 53 4D 31 73 80 21 40 81 07 FA

ATR: 3B FE 18 00 00 81 31 FE 45 80 31 81 54 48 53 4D 31 73 80 21 40 81 07 FA
+ TS = 3B --> Direct Convention
+ T0 = FE, Y(1): 1111, K: 14 (historical bytes)
  TA(1) = 18 --> Fi=372, Di=12, 31 cycles/ETU
    129032 bits/s at 4 MHz, fMax for Fi = 5 MHz => 161290 bits/s                                                     
  TB(1) = 00 --> VPP is not electrically connected
  TC(1) = 00 --> Extra guard time: 0
  TD(1) = 81 --> Y(i+1) = 1000, Protocol T = 1 
-----
  TD(2) = 31 --> Y(i+1) = 0011, Protocol T = 1 
-----
  TA(3) = FE --> IFSC: 254
  TB(3) = 45 --> Block Waiting Integer: 4 - Character Waiting Integer: 5
+ Historical bytes: 80 31 81 54 48 53 4D 31 73 80 21 40 81 07
  Category indicator byte: 80 (compact TLV data object)
    Tag: 3, len: 1 (card service data byte)
      Card service data byte: 81
        - Application selection: by full DF name
        - EF.DIR and EF.ATR access services: by GET RECORD(s) command
        - Card without MF
    Tag: 5, len: 4 (card issuer's data)
      Card issuer data: 48 53 4D 31
    Tag: 7, len: 3 (card capabilities)
      Selection methods: 80
        - DF selection by full DF name
      Data coding byte: 21
        - Behaviour of write functions: proprietary
        - Value 'FF' for the first byte of BER-TLV tag fields: invalid
        - Data unit in quartets: 2
      Command chaining, length fields and logical channels: 40
        - Extended Lc and Le fields
        - Logical channel number assignment: No logical channel
        - Maximum number of logical channels: 1
    Tag: 8, len: 1 (status indicator)
      LCS (life card cycle): 07
+ TCK = FA (correct checksum)

Possibly identified card (using /usr/share/pcsc/smartcard_list.txt):
3B FE 18 00 00 81 31 FE 45 80 31 81 54 48 53 4D 31 73 80 21 40 81 07 FA
        Smartcard-HSM
        http://www.cardcontact.de/products/sc-hsm.html

```

### Initialize the first smartcard

#### Create two DKEK shares

* 1st share;

```
[staf@vicky mnt]$ sc-hsm-tool --create-dkek-share dkek-share-1.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00

The DKEK share will be enciphered using a key derived from a user supplied password.
The security of the DKEK share relies on a well chosen and sufficiently long password.
The recommended length is more than 10 characters, which are mixed letters, numbers and
symbols.

Please keep the generated DKEK share file in a safe location. We also recommend to keep a
paper printout, in case the electronic version becomes unavailable. A printable version
of the file can be generated using "openssl base64 -in <filename>".
Enter password to encrypt DKEK share : 

Please retype password to confirm : 

Passwords do not match. Please retry.
Enter password to encrypt DKEK share : 
[staf@vicky mnt]$ sc-hsm-tool --create-dkek-share dkek-share-1.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00

The DKEK share will be enciphered using a key derived from a user supplied password.
The security of the DKEK share relies on a well chosen and sufficiently long password.
The recommended length is more than 10 characters, which are mixed letters, numbers and
symbols.

Please keep the generated DKEK share file in a safe location. We also recommend to keep a
paper printout, in case the electronic version becomes unavailable. A printable version
of the file can be generated using "openssl base64 -in <filename>".
Enter password to encrypt DKEK share : 

Please retype password to confirm : 

Enciphering DKEK share, please wait...
DKEK share created and saved to dkek-share-1.pbe
[staf@vicky mnt]$ 
```

* 2nd share;

```
[staf@vicky mnt]$ sc-hsm-tool --create-dkek-share dkek-share-2.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00

The DKEK share will be enciphered using a key derived from a user supplied password.
The security of the DKEK share relies on a well chosen and sufficiently long password.
The recommended length is more than 10 characters, which are mixed letters, numbers and
symbols.

Please keep the generated DKEK share file in a safe location. We also recommend to keep a
paper printout, in case the electronic version becomes unavailable. A printable version
of the file can be generated using "openssl base64 -in <filename>".
Enter password to encrypt DKEK share : 

Please retype password to confirm : 
[staf@vicky mnt]$ sc-hsm-tool --create-dkek-share dkek-share-2.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00

The DKEK share will be enciphered using a key derived from a user supplied password.
The security of the DKEK share relies on a well chosen and sufficiently long password.
The recommended length is more than 10 characters, which are mixed letters, numbers and
symbols.

Please keep the generated DKEK share file in a safe location. We also recommend to keep a
paper printout, in case the electronic version becomes unavailable. A printable version
of the file can be generated using "openssl base64 -in <filename>".
Enter password to encrypt DKEK share : 

Please retype password to confirm : 

Enciphering DKEK share, please wait...
DKEK share created and saved to dkek-share-2.pbe
[staf@vicky mnt]$ 
```

If you want a backup of DKEK shares copy them to another (encrypted) USB stick(s).

#### Initialize the SmartCard

* Initialize

Use sc-hsm-tool to Intialize the smartcard and specify the number DKEK shares that you'll use. You'll need to pick a PIN code for the "security officer" and the "user".

If you forget the so-pin you can not reinitialize the smartcard again so be sure that you pick so-pin that you can remember or write it down and store it on secure location. The so-pin has to be 16 digits long.

<strong>
The sc-hsm-tool only asks for the PIN code ones so be sure that you know what you have typed. If you don't know it you smartcard becomes trash...
</strong>

It possible to specify the pin code with "--so-pin" and "--pin" argument but this leaves the pin code in your shell history or in the process list...

```
[staf@vicky mnt]$ sc-hsm-tool --initialize --dkek-shares 2
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter SO-PIN (16 hexadecimal characters) : 

Enter initial User-PIN (6 - 16 characters) : 

[staf@vicky mnt]$ 

```

If you execute the sc-hsm-tool command you'll see that the DKEK shares are still missing;

```
[staf@vicky mnt]$ sc-hsm-tool 
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Version              : 1.2
User PIN tries left  : 3
DKEK shares          : 2
DKEK import pending, 2 share(s) still missing
[staf@vicky mnt]$ 
```

* import the dkek shares

```
[staf@vicky mnt]$ sc-hsm-tool --import-dkek-share dkek-share-1.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter password to decrypt DKEK share : 

Deciphering DKEK share, please wait...
DKEK share imported
DKEK shares          : 2
DKEK import pending, 1 share(s) still missing
[staf@vicky mnt]$ sc-hsm-tool --import-dkek-share dkek-share-2.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter password to decrypt DKEK share : 

Deciphering DKEK share, please wait...
DKEK share imported
DKEK shares          : 2
DKEK key check value : 2C63E9E5D6FE0B8C
[staf@vicky mnt]$ 
```

#### test the user and so pin

list the pkcs#11 slots

```
[staf@vicky mnt]$ pkcs11-tool --module opensc-pkcs11.so -L
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
  serial num         : DECM0102332
[staf@vicky mnt]$ 
```

test the user pin;

```
staf@vicky mnt]$ pkcs11-tool --module opensc-pkcs11.so --slot 1 --login --test
Logging in to "SmartCard-HSM (UserPIN)".
Please enter User PIN: 
C_SeedRandom() and C_GenerateRandom():
  seeding (C_SeedRandom) not supported
  seems to be OK
Digests:
  all 4 digest functions seem to work
  MD5: OK
  SHA-1: OK
  RIPEMD160: OK
Signatures (currently only RSA signatures)
Signatures: no private key found in this slot
Verify (currently only for RSA):
  No private key found for testing
Unwrap: not implemented
Decryption (RSA)
No errors
[staf@vicky mnt]$ 
```

test the so pin

```
[staf@vicky mnt]$ pkcs11-tool --module opensc-pkcs11.so --slot 1 --login --test --login-type so
Logging in to "SmartCard-HSM (UserPIN)".
Please enter SO PIN: 
C_SeedRandom() and C_GenerateRandom():
  seeding (C_SeedRandom) not supported
  seems to be OK
Digests:
  all 4 digest functions seem to work
  MD5: OK
  SHA-1: OK
  RIPEMD160: OK
Signatures: not logged in, skipping signature tests
Verify: not logged in, skipping verify tests
Key unwrap: not a R/W session, skipping key unwrap tests
Decryption: not logged in, skipping decryption tests
No errors
[staf@vicky mnt]$ 
```

### Create your first keypair

#### create key pair

The command below an <a href="https://en.wikipedia.org/wiki/Elliptic_curve_cryptography">Elliptic Curve Cryptography (ECC)</a> key pair. 

```
[staf@vicky mnt]$ pkcs11-tool --module opensc-pkcs11.so --keypairgen --key-type EC:prime256v1 --label myfirst_keypair --login
Using slot 1 with a present token (0x1)
Logging in to "SmartCard-HSM (UserPIN)".
Please enter User PIN: 
Key pair generated:
Private Key Object; EC
  label:      myfirst_keypair
  ID:         ae79417e809ed19b9a69d4c14f444462ad0bd66c
  Usage:      sign, derive
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104f8ead77d1411e016196141d9d1f747a481aec4be40d1f8822d26d407fee05902082e18843ee58db4f5575b19ff243a735b66b2c91adbec1a59aeacc7c1ae8b52
  EC_PARAMS:  06082a8648ce3d030107
  label:      myfirst_keypair
  ID:         ae79417e809ed19b9a69d4c14f444462ad0bd66c
  Usage:      verify
[staf@vicky mnt]$ 
```

#### list objects

list the objects to verif that your keypair in on the smartcard

```
staf@vicky mnt]$ pkcs11-tool --module opensc-pkcs11.so --list-objects
Using slot 1 with a present token (0x1)
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104f8ead77d1411e016196141d9d1f747a481aec4be40d1f8822d26d407fee05902082e18843ee58db4f5575b19ff243a735b66b2c91adbec1a59aeacc7c1ae8b52
  EC_PARAMS:  06082a8648ce3d030107
  label:      myfirst_keypair
  ID:         ae79417e809ed19b9a69d4c14f444462ad0bd66c
  Usage:      none
[staf@vicky mnt]$ 
```

## Copy objects to another smartcard

### Backup

To create a backup of our keys or data we need to extract it from the smartcard and copy it to another. 
To store the object temporary we can use an encrypted filesystem or even a ram disk on a secured computer.

For security reasons you might want to separate your DKEK share from you key backups,
For the convenience we'll store everything on an encrypted USB stick.

#### get the object reference

First we need to find the object reference

```
[staf@vicky mnt]$ pkcs15-tool -D
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
PKCS#15 Card [SmartCard-HSM]:
        Version        : 0
        Serial number  : DECM0102332
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
        MD:guid        : {3a03d245-ea49-1da1-d8cd-f2ced0526400}
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

[staf@vicky mnt]$ pkcs15-tool -D
``` 

#### extract the object(s)

```
[staf@vicky mnt]$ sc-hsm-tool --wrap-key private_myfirst_keypair --key-reference 1 
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter User PIN : 

[staf@vicky mnt]$ ls -l
total 28
-rw-r--r-- 1 swagemakers backup    64 Nov 11 13:42 dkek-share-1.pbe
-rw-r--r-- 1 swagemakers backup    64 Nov 11 13:42 dkek-share-2.pbe
drwx------ 2 root        root   16384 Nov 11 13:37 lost+found
-rw-rw-r-- 1 staf        staf     926 Nov 11 14:05 private_myfirst_keypair
[staf@vicky mnt]$ 
```

Please not that we only need to copy the private key, the backup object also contains the public keypair.


### Initialize a second smartcard

```
[staf@vicky mnt]$ sc-hsm-tool --initialize --dkek-shares 2
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter SO-PIN (16 hexadecimal characters) : 

Enter initial User-PIN (6 - 16 characters) : 

[staf@vicky mnt]$ sc-hsm-tool 
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Version              : 1.2
User PIN tries left  : 3
DKEK shares          : 2
DKEK import pending, 2 share(s) still missing
[staf@vicky mnt]$ sc-hsm-tool --import-dkek-share dkek-share-1.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter password to decrypt DKEK share : 

Deciphering DKEK share, please wait...
DKEK share imported
DKEK shares          : 2
DKEK import pending, 1 share(s) still missing
[staf@vicky mnt]$ sc-hsm-tool --import-dkek-share dkek-share-2.pbe
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Enter password to decrypt DKEK share : 

Deciphering DKEK share, please wait...
DKEK share imported
DKEK shares          : 2
DKEK key check value : 2C63E9E5D6FE0B8C
[staf@vicky mnt]$ 
```

### Store the key pair

It's possible to write the private object to another smartcard with the same DKEK shares.

```
[staf@vicky mnt]$ sc-hsm-tool --unwrap-key private_myfirst_keypair --key-reference 1
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
Wrapped key contains:
  Key blob
  Private Key Description (PRKD)
  Certificate
Enter User PIN : 

Key successfully imported
[staf@vicky mnt]$ pkcs11-tool --list-objects 
Using slot 1 with a present token (0x1)
Public Key Object; EC  EC_POINT 256 bits
  EC_POINT:   044104f8ead77d1411e016196141d9d1f747a481aec4be40d1f8822d26d407fee05902082e18843ee58db4f5575b19ff243a735b66b2c91adbec1a59aeacc7c1ae8b52
  EC_PARAMS:  06082a8648ce3d030107
  label:      myfirst_keypair
  ID:         ae79417e809ed19b9a69d4c14f444462ad0bd66c
  Usage:      none
[staf@vicky mnt]$ pkcs15-tool -D
Using reader with a card: Generic Smart Card Reader Interface [Smart Card Reader Interface] (20070818000000000) 00 00
PKCS#15 Card [SmartCard-HSM]:
        Version        : 0
        Serial number  : DECM0102330
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
        MD:guid        : {8e96ad75-4f6c-eb5e-6bb3-4a637bbcda50}
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

[staf@vicky mnt]$ 
```

### Done...

We have a backup to our second smartcard and an ecrypted backup of the key on the usb, umount the backup and store it to a safe location.

```
[staf@vicky ~]$ mount | grep mnt
/dev/mapper/my on /mnt type ext4 (rw,relatime,data=ordered)
[staf@vicky ~]$ umount /mnt
umount: /mnt: umount failed: Operation not permitted
[staf@vicky ~]$ sudo umount /mnt
[sudo] password for staf: 
[staf@vicky ~]$ sudo cryptsetup luksClose my
[staf@vicky ~]$ 
```

*** I might publish some smartcard-hsm usage examples in the further.... ***

### Links

https://github.com/OpenSC/OpenSC/wiki/SmartCardHSM
