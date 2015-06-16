---
layout: post
title: "Using YubiKey Neo as gpg smartcard for SSH authentication"
date: 2015-06-16 10:32
comments: true
categories: [ gpg, yubikey, smartcard, security, ssh, fedora ] 
---

I purchased a <a href="https://www.yubico.com/products/yubikey-hardware/">Yubi NEO</a> I'll use it to hold my  <a href="https://en.wikipedia.org/wiki/Linux_Unified_Key_Setup">Luks</a> password and for ssh authentication instead of the password authentication that I still use.

You'll find  my journey to get the smartcard interface working with ssh on a fedora 22 system below;

## Install the yubiclient and smartcard software

### Install the ykclient

```
ykclient.x86_64 : Yubikey management library and client
[root@vicky ~]# dnf install ykclient
Last metadata expiration check performed 1:00:07 ago on Sun Jun 14 09:14:34 2015.
Dependencies resolved.
====================================================================================================================
 Package                    Arch                     Version                         Repository                Size
====================================================================================================================
Installing:
 ykclient                   x86_64                   2.13-1.fc22                     fedora                    35 k

Transaction Summary
====================================================================================================================
Install  1 Package

Total download size: 35 k
Installed size: 58 k
Is this ok [y/N]: y
Downloading Packages:
ykclient-2.13-1.fc22.x86_64.rpm                                                      48 kB/s |  35 kB     00:00    
--------------------------------------------------------------------------------------------------------------------
Total                                                                                11 kB/s |  35 kB     00:03     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : ykclient-2.13-1.fc22.x86_64                                                                     1/1 
  Verifying   : ykclient-2.13-1.fc22.x86_64                                                                     1/1 

Installed:
  ykclient.x86_64 2.13-1.fc22                                                                                       

Complete!
[root@vicky ~]# 
```

```
root@vicky ~]# ykinfo
bash: ykinfo: command not found...
Install package 'ykpers' to provide command 'ykinfo'? [N/y] ^C

[root@vicky ~]# dnf install ykpers
Last metadata expiration check performed 1:01:23 ago on Sun Jun 14 09:14:34 2015.
Dependencies resolved.
====================================================================================================================
 Package                     Arch                    Version                          Repository               Size
====================================================================================================================
Installing:
 libyubikey                  x86_64                  1.11-3.fc22                      fedora                   33 k
 ykpers                      x86_64                  1.17.1-1.fc22                    fedora                  101 k

Transaction Summary
====================================================================================================================
Install  2 Packages

Total download size: 135 k
Installed size: 372 k
Is this ok [y/N]: y
Downloading Packages:
(1/2): libyubikey-1.11-3.fc22.x86_64.rpm                                             13 kB/s |  33 kB     00:02    
(2/2): ykpers-1.17.1-1.fc22.x86_64.rpm                                               38 kB/s | 101 kB     00:02    
--------------------------------------------------------------------------------------------------------------------
Total                                                                                22 kB/s | 135 kB     00:06     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : libyubikey-1.11-3.fc22.x86_64                                                                   1/2 
  Installing  : ykpers-1.17.1-1.fc22.x86_64                                                                     2/2 
  Verifying   : ykpers-1.17.1-1.fc22.x86_64                                                                     1/2 
  Verifying   : libyubikey-1.11-3.fc22.x86_64                                                                   2/2 

Installed:
  libyubikey.x86_64 1.11-3.fc22                             ykpers.x86_64 1.17.1-1.fc22                            

Complete!

```

### Verify that you've access to the yubikey

"ykinfo -v" shows you the version on the yubikey.

```
[root@vicky ~]# ykinfo -v
version: 3.4.0
[root@vicky ~]# 

```

If you try with the user that you'll for the yubi authentication you might get a permission denied: 

```
staf@vicky ~]$ ykinfo -v
USB error: Access denied (insufficient permissions)
[staf@vicky ~]$ 
```

#### Update the udev permissions

##### Update rule file

On a fedora 22 system to udev rules for the yubi key are defined in "/usr/lib/udev/rules.d/69-yubikey.rules"

It is a good practice to only grant access to user that will use the yubikey.

```
[root@vicky ~]# cd /usr/lib/udev/rules.d/
[root@vicky rules.d]# vi 69-yubikey.rules 
```

```
ACTION!="add|change", GOTO="yubico_end"

# Udev rules for letting the console user access the Yubikey USB
# device node, needed for challenge/response to work correctly.

# Yubico Yubikey II
ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", OWNER="staf", MODE="0600"

LABEL="yubico_end"
```

##### Update udev rules

```
# udevadm control --reload
# udevadm trigger
```

##### Test it again

```
[staf@vicky ~]$ ykinfo -v
version: 3.4.0
[staf@vicky ~]$ 
```

### Enable the smartcard interface

```
staf@vicky yubi]$ ykpersonalize -m82
Firmware version 3.4.0 Touch level 1551 Program sequence 3

The USB mode will be set to: 0x82

Commit? (y/n) [n]: y
[staf@vicky yubi]$ 

```

Remove the yubi key from your system and plug it back to activate the new interface.


### Install the required smartcard software

```
[root@vicky ~]# dnf install pcsc-tools   
Last metadata expiration check performed 0:33:58 ago on Sun Jun 14 09:14:34 2015.
Dependencies resolved.                                       
====================================================================================================================
 Package                         Arch                  Version                          Repository             Size
====================================================================================================================
Installing:                                                 
 pcsc-lite                       x86_64                1.8.13-1.fc22                    fedora                101 k
 pcsc-lite-asekey                x86_64                3.7-1.fc22                       fedora                 34 k
 pcsc-perl                       x86_64                1.4.12-11.fc22                   fedora                 61 k
 pcsc-tools                      x86_64                1.4.23-1.fc22                    fedora                116 k
 perl-Cairo                      x86_64                1.105-1.fc22                     fedora                126 k
 perl-Glib                       x86_64                1.310-1.fc22                     fedora                362 k
 perl-Gtk2                       x86_64                1.2495-1.fc22                    fedora                1.8 M
 perl-HTML-Tree                  noarch                1:5.03-8.fc22                    fedora                223 k
 perl-Pango                      x86_64                1.226-3.fc22                     fedora                220 k
                                                           
Transaction Summary                                        
====================================================================================================================
Install  9 Packages                                        
                                                            
Total download size: 3.0 M                                  
Installed size: 8.4 M                                       
Is this ok [y/N]: y                                          
Downloading Packages:                                        
(1/9): pcsc-tools-1.4.23-1.fc22.x86_64.rpm                                           38 kB/s | 116 kB     00:03    
(2/9): pcsc-perl-1.4.12-11.fc22.x86_64.rpm                                           20 kB/s |  61 kB     00:03    
(3/9): pcsc-lite-1.8.13-1.fc22.x86_64.rpm                                            23 kB/s | 101 kB     00:04    
(4/9): perl-Glib-1.310-1.fc22.x86_64.rpm                                            159 kB/s | 362 kB     00:02    
(5/9): perl-Cairo-1.105-1.fc22.x86_64.rpm                                            56 kB/s | 126 kB     00:02    
(6/9): perl-HTML-Tree-5.03-8.fc22.noarch.rpm                                         99 kB/s | 223 kB     00:02    
(7/9): perl-Gtk2-1.2495-1.fc22.x86_64.rpm                                           342 kB/s | 1.8 MB     00:05    
(8/9): perl-Pango-1.226-3.fc22.x86_64.rpm                                            89 kB/s | 220 kB     00:02    
(9/9): pcsc-lite-asekey-3.7-1.fc22.x86_64.rpm                                        21 kB/s |  34 kB     00:01    
--------------------------------------------------------------------------------------------------------------------
Total                                                                               257 kB/s | 3.0 MB     00:11     
Running transaction check                                   
Transaction check succeeded.                                
Running transaction test                                     
Transaction test succeeded.                                   
Running transaction                                             
  Installing  : perl-Glib-1.310-1.fc22.x86_64                                                                   1/9 
  Installing  : pcsc-lite-asekey-3.7-1.fc22.x86_64                                                              2/9 
  Installing  : pcsc-lite-1.8.13-1.fc22.x86_64                                                                  3/9 
  Installing  : perl-Cairo-1.105-1.fc22.x86_64                                                                  4/9 
  Installing  : perl-Pango-1.226-3.fc22.x86_64                                                                  5/9 
  Installing  : perl-HTML-Tree-1:5.03-8.fc22.noarch                                                             6/9 
  Installing  : perl-Gtk2-1.2495-1.fc22.x86_64                                                                  7/9 
  Installing  : pcsc-perl-1.4.12-11.fc22.x86_64                                                                 8/9 
  Installing  : pcsc-tools-1.4.23-1.fc22.x86_64                                                                 9/9 
  Verifying   : pcsc-tools-1.4.23-1.fc22.x86_64                                                                 1/9 
  Verifying   : pcsc-lite-1.8.13-1.fc22.x86_64                                                                  2/9 
  Verifying   : pcsc-perl-1.4.12-11.fc22.x86_64                                                                 3/9 
  Verifying   : perl-Glib-1.310-1.fc22.x86_64                                                                   4/9 
  Verifying   : perl-Gtk2-1.2495-1.fc22.x86_64                                                                  5/9 
  Verifying   : perl-Cairo-1.105-1.fc22.x86_64                                                                  6/9 
  Verifying   : perl-HTML-Tree-1:5.03-8.fc22.noarch                                                             7/9 
  Verifying   : perl-Pango-1.226-3.fc22.x86_64                                                                  8/9 
  Verifying   : pcsc-lite-asekey-3.7-1.fc22.x86_64                                                              9/9 

Installed:
  pcsc-lite.x86_64 1.8.13-1.fc22       pcsc-lite-asekey.x86_64 3.7-1.fc22       pcsc-perl.x86_64 1.4.12-11.fc22     
  pcsc-tools.x86_64 1.4.23-1.fc22      perl-Cairo.x86_64 1.105-1.fc22           perl-Glib.x86_64 1.310-1.fc22       
  perl-Gtk2.x86_64 1.2495-1.fc22       perl-HTML-Tree.noarch 1:5.03-8.fc22      perl-Pango.x86_64 1.226-3.fc22      

Complete!
[root@vicky ~]# 

```

```
root@vicky ~]# dnf install opensc
Last metadata expiration check performed 0:37:38 ago on Sun Jun 14 09:14:34 2015.
Dependencies resolved.
====================================================================================================================
 Package                  Arch                     Version                           Repository                Size
====================================================================================================================
Installing:
 opensc                   x86_64                   0.14.0-2.fc22                     fedora                   976 k

Transaction Summary
====================================================================================================================
Install  1 Package

Total download size: 976 k
Installed size: 2.8 M
Is this ok [y/N]: y
Downloading Packages:
opensc-0.14.0-2.fc22.x86_64.rpm                                                     277 kB/s | 976 kB     00:03    
--------------------------------------------------------------------------------------------------------------------
Total                                                                               203 kB/s | 976 kB     00:04     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : opensc-0.14.0-2.fc22.x86_64                                                                     1/1 
  Verifying   : opensc-0.14.0-2.fc22.x86_64                                                                     1/1 

Installed:
  opensc.x86_64 0.14.0-2.fc22                                                                                       

Complete!
[root@vicky ~]# dnf search opensc
```

```
[root@vicky ~]# dnf search ccid
Last metadata expiration check performed 0:39:03 ago on Sun Jun 14 09:14:34 2015.
================================================ N/S Matched: ccid =================================================
pcsc-lite-ccid.x86_64 : Generic USB CCID smart card reader driver
libykneomgr.i686 : YubiKey NEO CCID Manager C Library
libykneomgr.x86_64 : YubiKey NEO CCID Manager C Library
[root@vicky ~]# dnf install pcsc-lite-ccid
Last metadata expiration check performed 0:39:34 ago on Sun Jun 14 09:14:34 2015.
Dependencies resolved.
====================================================================================================================
 Package                        Arch                   Version                         Repository              Size
====================================================================================================================
Installing:
 pcsc-lite-ccid                 x86_64                 1.4.18-1.fc22                   fedora                 177 k

Transaction Summary
====================================================================================================================
Install  1 Package

Total download size: 177 k
Installed size: 599 k
Is this ok [y/N]: y
Downloading Packages:
pcsc-lite-ccid-1.4.18-1.fc22.x86_64.rpm                                              47 kB/s | 177 kB     00:03    
--------------------------------------------------------------------------------------------------------------------
Total                                                                                27 kB/s | 177 kB     00:06     
Running transaction check
Transaction check succeeded.
Running transaction test
Transaction test succeeded.
Running transaction
  Installing  : pcsc-lite-ccid-1.4.18-1.fc22.x86_64                                                             1/1 
  Verifying   : pcsc-lite-ccid-1.4.18-1.fc22.x86_64                                                             1/1 

Installed:
  pcsc-lite-ccid.x86_64 1.4.18-1.fc22                                                                               

Complete!
[root@vicky ~]# 
```

#### Start the pcscd service

```
root@vicky ~]# systemctl list-unit-files -t service | grep pcscd
pcscd.service                               static  
[root@vicky ~]# systemctl start pcscd
[root@vicky ~]# systemctl enable pcscd
[root@vicky ~]# 
```

#### Verify that you are able to see the yubi smartcard

##### Run pcsc_scan

Execute "pcsc_scan" to verify that you see the smartcard

```
[staf@vicky ~]$ pcsc_scan 
PC/SC device scanner
V 1.4.23 (c) 2001-2011, Ludovic Rousseau <ludovic.rousseau@free.fr>
Compiled with PC/SC lite version: 1.8.13
Using reader plug'n play mechanism
Scanning present readers...
0: Gemalto Gemplus USB SmartCard Reader 433-Swap [CCID Interface] (1-0000:00:06.7-1) 00 00
1: Yubico Yubikey NEO OTP+CCID 01 00

Mon Jun 15 11:36:44 2015
Reader 0: Gemalto Gemplus USB SmartCard Reader 433-Swap [CCID Interface] (1-0000:00:06.7-1) 00 00
  Card state: Card removed, 
Reader 1: Yubico Yubikey NEO OTP+CCID 01 00
  Card state: Card inserted, 
  ATR: 3B FC 13 00 00 81 31 FE 15 59 75 62 69 6B 65 79 4E 45 4F 72 33 E1

defined(@array) is deprecated at /usr/lib64/perl5/vendor_perl/Chipcard/PCSC.pm line 69.
        (Maybe you should just omit the defined()?)
ATR: 3B FC 13 00 00 81 31 FE 15 59 75 62 69 6B 65 79 4E 45 4F 72 33 E1
+ TS = 3B --> Direct Convention
+ T0 = FC, Y(1): 1111, K: 12 (historical bytes)
  TA(1) = 13 --> Fi=372, Di=4, 93 cycles/ETU
    43010 bits/s at 4 MHz, fMax for Fi = 5 MHz => 53763 bits/s
  TB(1) = 00 --> VPP is not electrically connected
  TC(1) = 00 --> Extra guard time: 0
  TD(1) = 81 --> Y(i+1) = 1000, Protocol T = 1 
-----
  TD(2) = 31 --> Y(i+1) = 0011, Protocol T = 1 
-----
  TA(3) = FE --> IFSC: 254
  TB(3) = 15 --> Block Waiting Integer: 1 - Character Waiting Integer: 5
+ Historical bytes: 59 75 62 69 6B 65 79 4E 45 4F 72 33
  Category indicator byte: 59 (proprietary format)
+ TCK = E1 (correct checksum)

Possibly identified card (using /usr/share/pcsc/smartcard_list.txt):
3B FC 13 00 00 81 31 FE 15 59 75 62 69 6B 65 79 4E 45 4F 72 33 E1
        YubiKey NEO (PKI)
        http://www.yubico.com/

```

#### Remote smartcard access

By default only console logins have access to the smartcard if you want to grant access to remote logins (e.g. ssh)
create a polkit rule for the user that will use the smartcard.

```
[root@vicky ~]# cd /usr/share/polkit-1/rules.d/                                    
[root@vicky rules.d]# vi 30_smartcard_access.rules 
```

```
polkit.addRule(function(action, subject) {
    if (action.id == "org.debian.pcsc-lite.access_pcsc" &&
        subject.user == "staf") {
            return polkit.Result.YES;
    }
});

polkit.addRule(function(action, subject) {
    if (action.id == "org.debian.pcsc-lite.access_card" &&
        action.lookup("reader") == 'name_of_reader' &&
        subject.user == "staf") {
            return polkit.Result.YES;    }
});

```

### Reset smartcard PIN codes

The default user PIN code is "123456" the default admin PIN code is "12345678"

```
[staf@vicky ~]$ gpg --change-pin 
gpg: OpenPGP card no. D2760001240102000006035062250000 detected

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

#### Change user PIN

Your selection? 
```

```
Your selection? 1

Please enter the PIN
           
New PIN
               
New PIN
PIN changed.     

```

#### Change admin PIN

```
 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 3
gpg: 3 Admin PIN attempts remaining before card is permanently locked

Please enter the Admin PIN
                 
New Admin PIN
                     
New Admin PIN
PIN changed.     

1 - change PIN
2 - unblock PIN
3 - change Admin PIN
4 - set the Reset Code
Q - quit

Your selection? 

```

### Generate a new key pair

#### Execute "gpg --card-edit"

```
[staf@vicky ~]$ gpg --card-edit 

Application ID ...: D2760001240102000006035062250000
Version ..........: 2.0
Manufacturer .....: unknown
Serial number ....: 03506225
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: forced
Key attributes ...: 2048R 2048R 2048R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 3 3
Signature counter : 5
Signature key ....: 1E41 4C61 B1CE F02A F431  85BF 46B9 3657 54DF 802E
      created ....: 2015-06-15 11:47:23
Encryption key....: BB75 75F4 404A 2681 4331  4B46 34E7 EE51 4199 C702
      created ....: 2015-06-15 11:47:23
Authentication key: A7F8 A844 4762 C44D 20C7  A2AF E06D 602C 069D 7EFF
      created ....: 2015-06-15 11:47:23
General key info..: 
pub  2048R/54DF802E 2015-06-15 qwerty <qwert@qwert>
sec>  2048R/54DF802E  created: 2015-06-15  expires: never     
                      card-no: 0006 03506225
ssb>  2048R/069D7EFF  created: 2015-06-15  expires: never     
                      card-no: 0006 03506225
ssb>  2048R/4199C702  created: 2015-06-15  expires: never     
                      card-no: 0006 03506225

gpg/card> 
```

#### Enable admin commands

```
gpg/card> admin
Admin commands are allowed                                                      
                                                                                
gpg/card>                                                                        
```

#### Generate key

```
gpg/card> generate 
Make off-card backup of encryption key? (Y/n) n

gpg: NOTE: keys are already stored on the card!

Replace existing keys? (y/N) y

Please note that the factory settings of the PINs are
   PIN = `123456'     Admin PIN = `12345678'
You should change them using the command --change-pin


Please enter the PIN
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 
Key does not expire at all
Is this correct? (y/N) y

You need a user ID to identify your key; the software constructs the user ID
from the Real Name, Comment and Email Address in this form:
    "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

Real name: staf wagemakers
Email address: staf@wagemakers.be
Comment: 
You selected this USER-ID:
    "staf wagemakers <staf@wagemakers.be>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? O
gpg: existing key will be replaced
gpg: 3 Admin PIN attempts remaining before card is permanently locked

Please enter the Admin PIN
gpg: please wait while key is being generated ...
gpg: key generation completed (5 seconds)
gpg: signatures created so far: 0
gpg: existing key will be replaced
gpg: please wait while key is being generated ...
gpg: key generation completed (35 seconds)
gpg: signatures created so far: 1
gpg: signatures created so far: 2
gpg: existing key will be replaced
gpg: please wait while key is being generated ...
gpg: key generation completed (9 seconds)
gpg: signatures created so far: 3
gpg: signatures created so far: 4
gpg: key C15CE3D7 marked as ultimately trusted
public and secret key created and signed.

gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   2  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 2u
pub   2048R/C15CE3D7 2015-06-15
      Key fingerprint = B702 663D 833B DC19 0EEF  663A 54FA 0B1E C15C E3D7
uid                  staf wagemakers <staf@wagemakers.be>
sub   2048R/D2AEBBA3 2015-06-15
sub   2048R/6C2C699A 2015-06-15


gpg/card> 

```



### Extract the public key

#### Execute gpg --card-status

```
staf@vicky ~]$ gpg --card-status
Application ID ...: D2760001240102000006035062250000
Version ..........: 2.0
Manufacturer .....: unknown
Serial number ....: 03506225
Name of cardholder: [not set]
Language prefs ...: [not set]
Sex ..............: unspecified
URL of public key : [not set]
Login data .......: [not set]
Signature PIN ....: not forced
Key attributes ...: 2048R 2048R 2048R
Max. PIN lengths .: 127 127 127
PIN retry counter : 3 3 3
Signature counter : 5
Signature key ....: AED7 C79B 574D 45CC 7C1B  CC35 BDDE E66F 0C2C CF82
      created ....: 2015-06-16 06:32:02
Encryption key....: 6650 AB0A 5F31 059F 3221  3F29 C9F3 2031 01B3 1F53
      created ....: 2015-06-16 06:32:02
Authentication key: A387 A45A 446E DC9C D78E  F173 7C19 5D7D A1D9 9813
      created ....: 2015-06-16 06:32:02
General key info..: pub  2048R/0C2CCF82 2015-06-16 staf wagemakers <staf@wagemakers.be>
sec>  2048R/0C2CCF82  created: 2015-06-16  expires: never     
                      card-no: 0006 03506225
ssb>  2048R/A1D99813  created: 2015-06-16  expires: never     
                      card-no: 0006 03506225
ssb>  2048R/01B31F53  created: 2015-06-16  expires: never     
                      card-no: 0006 03506225
[staf@vicky ~]$ 
```

#### Run gpgkey2ssh on the authentication key

```
[staf@vicky ~]$ gpgkey2ssh A1D99813
ssh-rsa qwertyqwertyqwerty COMMENT
[staf@vicky ~]$ 
```

### Test ssh access

#### Configure the gpg agent

The gpg-agent can be use as a ssh-agent

##### Enable ssh support in your gpg-agent.conf

Create your gpg-agent.conf file

```
[staf@vicky ~]$ vi .gnupg/gpg-agent.conf
```

```
pinentry-program  /usr/bin/pinentry
enable-ssh-support
```

#### Start the gpg-agent

```
staf@vicky ~]$ gpg-agent --daemon --verbose
gpg-agent[1395]: listening on socket '/home/staf/.gnupg/S.gpg-agent'
gpg-agent[1395]: listening on socket '/home/staf/.gnupg/S.gpg-agent.ssh'
gpg-agent[1396]: gpg-agent (GnuPG) 2.1.4 started
SSH_AUTH_SOCK=/home/staf/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;
[staf@vicky ~]$ 
```

#### Export the SSH_AUTH_SOCK variable

```
SSH_AUTH_SOCK=/home/staf/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;

```

#### Verify the agent

Run ssh-add -L

```
[staf@vicky ~]$ ssh-add -L
error fetching identities for protocol 1: agent refused operation
ssh-rsa qwertyqwertyqwerty cardno:xxxx
```

The public key must be the same as extracted with "gpgkey2ssh"

#### Add the public key to the remote system

Add this public key to ~/.ssh/authorized_keys on the remote system.

#### Test

Try to logon to your remote system

```
staf@vicky ~]$ ssh -v xxx.xxx.xxx.xxx
```

You should get a window that asks for user PIN code.

```







               ┌──────────────────────────────────────────────┐
               │ Please enter the PIN                         │
               │                                              │
               │ PIN ________________________________________ │
               │                                              │
               │      <OK>                        <Cancel>    │
               └──────────────────────────────────────────────┘






```

```
FreeBSD 10.1-RELEASE-p10 (GENERIC) #0: Wed May 13 06:54:13 UTC 2015

Welcome to FreeBSD!

Release Notes, Errata: https://www.FreeBSD.org/releases/
Security Advisories:   https://www.FreeBSD.org/security/
FreeBSD Handbook:      https://www.FreeBSD.org/handbook/
FreeBSD FAQ:           https://www.FreeBSD.org/faq/
Questions List: https://lists.FreeBSD.org/mailman/listinfo/freebsd-questions/
FreeBSD Forums:        https://forums.FreeBSD.org/

Documents installed with the system are in the /usr/local/share/doc/freebsd/
directory, or can be installed later with:  pkg install en-freebsd-doc
For other languages, replace "en" with a language code like de or fr.

Show the version of FreeBSD installed:  freebsd-version ; uname -a
Please include that output and any error messages when posting questions.
Introduction to manual pages:  man man
FreeBSD directory layout:      man hier

Edit /etc/motd to change this login announcement.
Want to run the same command again?
In tcsh you can type "!!"
$ 

```

## CleanUp

### Start the gpg-daemon

Add

```
gpg-agent --daemon
SSH_AUTH_SOCK=/home/staf/.gnupg/S.gpg-agent.ssh; export SSH_AUTH_SOCK;
```

To your .bash_profile or setup a generic script for all users in /etc/profile.d/

### Disable password login in the /etc/ssh/sshd_config

*Have fun!* 





## Links

* <a href="https://www.yubico.com/2012/12/yubikey-neo-openpgp/">https://www.yubico.com/2012/12/yubikey-neo-openpgp/</a>
* <a href="https://blog.habets.se/2013/02/GPG-and-SSH-with-Yubikey-NEO">https://blog.habets.se/2013/02/GPG-and-SSH-with-Yubikey-NEO</a>
* <a href="http://25thandclement.com/~william/YubiKey_NEO.html">http://25thandclement.com/~william/YubiKey_NEO.html</a>
* <a href="http://forum.yubico.com/viewtopic.php?f=26&t=1171">http://forum.yubico.com/viewtopic.php?f=26&t=1171</a>
* <a href="https://developers.yubico.com/yubikey-personalization/Releases/">https://developers.yubico.com/yubikey-personalization/Releases/</a>
* <a href="http://www.incenp.org/notes/2014/gnupg-for-ssh-authentication.html">http://www.incenp.org/notes/2014/gnupg-for-ssh-authentication.html</a>
* <a href="http://www.programmierecke.net/howto/gpg-ssh.html">http://www.programmierecke.net/howto/gpg-ssh.html</a>
* <a href="http://www.bradfordembedded.com/2013/12/yubikey-smartcard/">http://www.bradfordembedded.com/2013/12/yubikey-smartcard/</a>
* <a href="http://www.incenp.org/notes/2014/gnupg-for-ssh-authentication.html">http://www.incenp.org/notes/2014/gnupg-for-ssh-authentication.html</a>
* <a href="https://github.com/herlo/ssh-gpg-smartcard-config/blob/master/YubiKey_NEO.rst">https://github.com/herlo/ssh-gpg-smartcard-config/blob/master/YubiKey_NEO.rst</a>
* <a href="https://www.esev.com/blog/post/2015-01-pgp-ssh-key-on-yubikey-neo/">https://www.esev.com/blog/post/2015-01-pgp-ssh-key-on-yubikey-neo/</a>
* <a href="https://wiki.archlinux.org/index.php/Common_Access_Card">https://wiki.archlinux.org/index.php/Common_Access_Card</a>
* <a href="https://wiki.archlinux.org/index.php/Udev">https://wiki.archlinux.org/index.php/Udev</a>
* <a href="https://securityblog.redhat.com/2014/07/30/controlling-access-to-smart-cards/">https://securityblog.redhat.com/2014/07/30/controlling-access-to-smart-cards/</a>
