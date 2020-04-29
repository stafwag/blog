---
layout: post
title: "Setup a certificate authority with SmartCardHSM"
date: 2020-04-29 19:48:50 +0100
comments: true
categories: [ security, ca, smartcard, hsm, smartcard-hsm ] 
excerpt_separator: <!--more-->
---


<a href="{{ '/images/security_related/create_hsm_key_on_kali.jpeg' | remove_first:'/' | absolute_url }}"><img src="{{ '/images/security_related/create_hsm_key_on_kali.jpeg' | remove_first:'/' | absolute_url }}" class="left" width="500" height="323" alt="SmartCardHSM on Kali" /> </a>
In this blog post, we will set up a CA authority with SmartCardHSM.


When you to create internal certificate authority for internal services it's important to protect the private key. When somebody with bad intentions gets access to the private key(s) of the signing certificate authorities, it can be used to issue new certificates. This would enable the man in the middle attacks.

<!--more-->

# Prepare

## Smardcards

I use 3 smartcards, these SmartCardHSM's were created with Device Key Encryption Key (DKEK) keys. This makes it possible to copy the private key to another smartcard securely. The backup and Device Key Encryption Keys are stored on an encrypted USB stick. This USB stick is copied 3 times.

See [ my previous blog post](https://stafwag.github.io/blog/blog/2015/11/21/starting-to-protect-my-private-keys-with-smartcard-hsm/)
on howto setup the SmartCard-Hsm cards with Device Key Encryption Keys.

## Air gapped system to generate the private key.

We create the private on air gapped system. I use kali Linux live as the operation system of this air gappedd system.
Kali Linux live is nice GNU/Linux distribution use for pentesting normally but it comes with required tools to generate the private key and copy this private to
backup smartcards (opensc, openssl).

## CA host

The CA authority will run Centos 8 GNU/Linux.

# Create the CA public/private key pair

## Create the key pair

```
kali@kali:~$ pkcs11-tool --module opensc-pkcs11.so --keypairgen --key-type rsa:2048 --label ca.intern.stafnet.local --login
Using slot 0 with a present token (0x0)
Key pair generated:
Private Key Object; RSA 
  label:      ca.intern.stafnet.local
  ID:         853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
  Usage:      decrypt, sign, unwrap
  Access:     none
Public Key Object; RSA 2048 bits
  label:      ca.intern.stafnet.local
  ID:         853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
  Usage:      encrypt, verify, wrap
  Access:     none
kali@kali:~$ 
```

### Verify

```
Using reader with a card: Cherry GmbH SmartTerminal ST-2xxx [Vendor Interface] (******) 00 00
PKCS#15 Card [SmartCard-HSM]:
        Version        : 0
        Serial number  : ******
        Manufacturer ID: www.CardContact.de
        Flags          : 
<snip>
Private RSA Key [ca.intern.stafnet.local]
        Object Flags   : [0x03], private, modifiable
        Usage          : [0x2E], decrypt, sign, signRecover, unwrap
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        ModLength      : 2048
        Key ref        : 6 (0x06)
        Native         : yes
        Auth ID        : 01
        ID             : 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
        MD:guid        : e6d4cec1-0f7e-5517-f08c-de2ff317a475
<snip>
Public RSA Key [ca.intern.stafnet.local]
        Object Flags   : [0x00]
        Usage          : [0x51], encrypt, wrap, verify
        Access Flags   : [0x02], extract
        ModLength      : 2048
        Key ref        : 0 (0x00)
        Native         : no
        ID             : 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
        DirectValue    : <present>
```

## Backup
### Mount the encrypted USB device

Find the encrypted USB devices to store the key backup.

```
root@kali:~# lsblk -o NAME,SIZE,VENDOR,SUBSYSTEMS | grep -i usb
sda    3.9G Imation  block:scsi:usb:pci
root@kali:~# 
```

Mount the device.

```
root@kali:~# lsblk -o NAME,SIZE,VENDOR,SUBSYSTEMS | grep -i usb
sda    3.9G Imation  block:scsi:usb:pci
root@kali:~# cryptsetup luksOpen /dev/sda boe
Enter passphrase for /dev/sda: 
root@kali:~# mount /dev/mapper/boe /mnt
root@kali:~# 
```

### Backup the key pair 

Always a good idea to not make the file world-readable. Therefore we set the ```umask``` to ```077```.

```
kali@kali:/mnt/hsm$ umask 077
```

```
kali@kali:/mnt/hsm$ sc-hsm-tool --wrap-key ca.intern.stafnet.local --key-reference 6
Using reader with a card: Cherry GmbH SmartTerminal ST-2xxx [Vendor Interface] (21121745111568) 00 00
Enter User PIN : 
```

### Store the key pair to the other smartcards

```
kali@kali:/mnt/hsm$ sc-hsm-tool --unwrap-key ca.intern.stafnet.local --key-reference 6
Using reader with a card: Cherry GmbH SmartTerminal ST-2xxx [Vendor Interface] (21121745111568) 00 00
Wrapped key contains:
  Key blob
  Private Key Description (PRKD)
  Certificate
Enter User PIN : 

Key successfully imported
```

### Verify

```
kali@kali:/mnt/hsm$ pkcs15-tool -D
Using reader with a card: Cherry GmbH SmartTerminal ST-2xxx [Vendor Interface] (*****) 00 00
PKCS#15 Card [SmartCard-HSM]:
        Version        : 0
        Serial number  : *****
        Manufacturer ID: www.CardContact.de
        Flags          : 
<snip>
Private RSA Key [ca.intern.stafnet.local]
        Object Flags   : [0x03], private, modifiable
        Usage          : [0x2E], decrypt, sign, signRecover, unwrap
        Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
        ModLength      : 2048
        Key ref        : 6 (0x06)
        Native         : yes
        Auth ID        : 01
        ID             : 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
<snip>
Public RSA Key [ca.intern.stafnet.local]
        Object Flags   : [0x00]
        Usage          : [0x51], encrypt, wrap, verify
        Access Flags   : [0x02], extract
        ModLength      : 2048
        Key ref        : 0 (0x00)
        Native         : no
        ID             : 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
        DirectValue    : <present>

kali@kali:/mnt/hsm$ 
```

# CA Authority

My CA Authority runs on a GNU/Linux Centos 8 host. Most public CA authority will have a “Root CA certificate” and an “intermediate CA certificate”
The Root CA certificate is only used the sign the intermediate certificates. The intermediate certificate is used to sign client certificates.
I’ll only use a single certificate setup. Some people will already find this overkill for a home setup :-)

## Create the CA directory

Create the base directory for our new ca.

```
bash-4.4$ mkdir -p ~/ca/ca.intern.stafnet.local
bash-4.4$ cd ~/ca/ca.intern.stafnet.local
```

Create the sub directories.

```
bash-4.4$ mkdir certs crl newcerts private csr
bash-4.4$ 
```

## Openssl.cnf

Copy the default openssl.cnf

```
-bash-4.4$ cp /etc/pki/tls/openssl.cnf .
-bash-4.4$ 
```

```
-bash-4.4$ vi openssl.cnf
```

### CA section

The ```[ ca ]``` section is the start point for the ```openssl ca```,
default_ca is set to ```[ CA_default ]```.

```
[ ca ]
default_ca  = CA_default    # The default ca section
```

#### CA_default

In the ```[ CA_default ]``` section update ```dir``` to the path
of your ca.

```x509_extensions``` is set to ```usr_cert```. This defines the attributes
that are applied when a new certificate is issued.

```
####################################################################
[ CA_default ]

dir   = /home/staf/ca/ca.intern.stafnet.local    # Where everything is kept
certs   = $dir/certs    # Where the issued certs are kept
crl_dir   = $dir/crl    # Where the issued crl are kept
database  = $dir/index.txt  # database index file.
#unique_subject = no      # Set to 'no' to allow creation of
          # several certs with same subject.
new_certs_dir = $dir/newcerts   # default place for new certs.

certificate = $dir/cacert.pem   # The CA certificate
serial    = $dir/serial     # The current serial number
crlnumber = $dir/crlnumber  # the current crl number
          # must be commented out to leave a V1 CRL
crl   = $dir/crl.pem    # The current CRL
private_key = $dir/private/cakey.pem# The private key

x509_extensions = usr_cert    # The extensions to add to the cert

# Comment out the following two lines for the "traditional"
# (and highly broken) format.
name_opt  = ca_default    # Subject Name options
cert_opt  = ca_default    # Certificate field options

# Extension copying option: use with caution.
# copy_extensions = copy

# Extensions to add to a CRL. Note: Netscape communicator chokes on V2 CRLs
# so this is commented out by default to leave a V1 CRL.
# crlnumber must also be commented out to leave a V1 CRL.
# crl_extensions  = crl_ext

default_days  = 365     # how long to certify for
default_crl_days= 30      # how long before next CRL
default_md  = sha256    # use SHA-256 by default
preserve  = no      # keep passed DN ordering

# A few difference way of specifying how similar the request should look
# For type CA, the listed attributes must be the same, and the optional
# and supplied fields are just that :-)
policy    = policy_match

# For the CA policy
[ policy_match ]
countryName   = match
stateOrProvinceName = match
organizationName  = match
organizationalUnitName  = optional
commonName    = supplied
emailAddress    = optional
```

#### usr_cert

```x509_extensions``` is set to ```usr_cert```. This defines the attributes
that are applied when a new certificate is issued. Update the attributes like 
the nsCaRevocationUrl if want to use a CRL.

```
[ usr_cert ]

# These extensions are added when 'ca' signs a request.

# This goes against PKIX guidelines but some CAs do it and some software
# requires this to avoid interpreting an end user certificate as a CA.

basicConstraints=CA:FALSE

# Here are some examples of the usage of nsCertType. If it is omitted
# the certificate can be used for anything *except* object signing.

# This is OK for an SSL server.
# nsCertType      = server

# For an object signing certificate this would be used.
# nsCertType = objsign

# For normal client use this is typical
# nsCertType = client, email

# and for everything including object signing:
# nsCertType = client, email, objsign

# This is typical in keyUsage for a client certificate.
# keyUsage = nonRepudiation, digitalSignature, keyEncipherment

# This will be displayed in Netscape's comment listbox.
nsComment     = "OpenSSL Generated Certificate"

# PKIX recommendations harmless if included in all certificates.
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid,issuer

# This stuff is for subjectAltName and issuerAltname.
# Import the email address.
# subjectAltName=email:copy
# An alternative to produce certificates that aren't
# deprecated according to PKIX.
# subjectAltName=email:move

# Copy subject details
# issuerAltName=issuer:copy

nsCaRevocationUrl   = http://ca.inter.stafnet.local/crl.pem
#nsBaseUrl
#nsRevocationUrl
#nsRenewalUrl
#nsCaPolicyUrl
#nsSslServerName

# This is required for TSA certificates.
# extendedKeyUsage = critical,timeStamping
```

### req section

The ```[ req ]``` section specifies the section for the ca signing requests.
Update the defaults_bits to rsa key size ```4096```.
```distinguished_name``` is set to  ```req_distinguished_name```.
This defines the default settings when you create a ca signing request.

```
[ req ]
default_bits    = 4096
default_md    = sha256
default_keyfile   = privkey.pem
distinguished_name  = req_distinguished_name
attributes    = req_attributes
x509_extensions = v3_ca # The extensions to add to the self signed cert

# Passwords for private keys if not present they will be prompted for
# input_password = secret
# output_password = secret

# This sets a mask for permitted string types. There are several options.
# default: PrintableString, T61String, BMPString.
# pkix   : PrintableString, BMPString (PKIX recommendation before 2004)
# utf8only: only UTF8Strings (PKIX recommendation after 2004).
# nombstr : PrintableString, T61String (no BMPStrings or UTF8Strings).
# MASK:XXXX a literal mask value.
# WARNING: ancient versions of Netscape crash on BMPStrings or UTF8Strings.
string_mask = utf8only

# req_extensions = v3_req # The extensions to add to a certificate request
```

### distinguished_name 

```[ distinguished_name ]``` defines the default settings for a 
ca request. Update the setting with you country, organization etc.

```
[ req_distinguished_name ]
countryName     = Country Name (2 letter code)
countryName_default   = BE
countryName_min     = 2
countryName_max     = 2

stateOrProvinceName   = State or Province Name (full name)
stateOrProvinceName_default = Antwerp

localityName      = Locality Name (eg, city)
localityName_default    = Antwerp

0.organizationName    = Organization Name (eg, company)
0.organizationName_default  = stafnet.local

# we can do this but it is not needed normally :-)
#1.organizationName   = Second Organization Name (eg, company)
#1.organizationName_default = World Wide Web Pty Ltd

organizationalUnitName    = Organizational Unit Name (eg, section)
organizationalUnitName_default  = intern.stafnet.local

commonName      = Common Name (eg, your name or your server\'s hostname)
commonName_max      = 64

emailAddress      = Email Address
emailAddress_max    = 64

# SET-ex3     = SET extension number 3

[ req_attributes ]
challengePassword   = A challenge password
challengePassword_min   = 4
challengePassword_max   = 20

unstructuredName    = An optional company name
```

## Create the CA certificate

### Get the keypair id

```
bash-4.4$ pkcs15-tool -D
<snip>
rivate RSA Key [ca.intern.stafnet.local]
	Object Flags   : [0x3], private, modifiable
	Usage          : [0x2E], decrypt, sign, signRecover, unwrap
	Access Flags   : [0x1D], sensitive, alwaysSensitive, neverExtract, local
	ModLength      : 2048
	Key ref        : 6 (0x6)
	Native         : yes
	Auth ID        : 01
	ID             : 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba
	MD:guid        : 03580e77-ebb8-48f3-cebb-bae4bc9ff34a
```

### Create the CA certificate

Use ```pkcs15-tool -D ``` to find the ```ID``` of the keypair. You'll find this ```ID``` 2 times as this is a public/privaye keypair.

```
-bash-4.4$ openssl req -config openssl.cnf -engine pkcs11 -new -x509 -days 1095 -keyform engine -key 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba -out cacert.pem
engine "pkcs11" set.
Enter PKCS#11 token PIN for UserPIN (SmartCard-HSM):
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [BE]:
State or Province Name (full name) [Antwerp]:
Locality Name (eg, city) [Antwerp]:
Organization Name (eg, company) [stafnet.local]:
Organizational Unit Name (eg, section) [intern.stafnet.local]:
Common Name (eg, your name or your server's hostname) []:ca.intern.stafnet.local
Email Address []:
-bash-4.4$ 
```

## Create a client certificate

### Create the private key

Create the private key for the client certificate. When you specify ```-aes256``` the key will get encrypted by a passphrase.

```
-bash-4.4$ openssl genrsa -aes256 -out private/client001.key 4096
Generating RSA private key, 4096 bit long modulus (2 primes)
...++++
..................................................................................................................................................................................................++++
e is 65537 (0x010001)
Enter pass phrase for private/client001.key:
Verifying - Enter pass phrase for private/client001.key:
-bash-4.4$ 
```

### Create the certificate signing request

```
bash-4.4$ openssl req -config ./openssl.cnf -key ca/private/client001.key -out csr/client001.csr -new -nodes
Enter pass phrase for ca/private/client001.key:
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [BE]:
State or Province Name (full name) [Antwerp]:
Locality Name (eg, city) [Antwerp]:
Organization Name (eg, company) [stafnet.local]:
Organizational Unit Name (eg, section) [intern.stafnet.local]:
Common Name (eg, your name or your server's hostname) []:testcert.intern.stafnet.local
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
bash-4.4$ 
```

### Create the ```index```, ```serial``` and crlnumber

Create the ```index``` file, this wil hold the list (table of contents) with the issued and revoked certificates.
```serial``` is the serial number for certificate, the number will increase when a certificate is issued.
```crtlnumber``` is serial number for the certificate revocation list, the number will increase when a certificate is revoked. 

```
-bash-4.4$ touch index.txt
-bash-4.4$ echo 01 > serial
-bash-4.4$ echo 01 > crlnumber
```

### Sign the test cert

```
-bash-4.4$ openssl ca -config ./openssl.cnf -engine pkcs11 -keyform engine -keyfile 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba -cert cacert.pem -out certs/client001.crt -infiles csr/client001.csr
engine "pkcs11" set.
Using configuration from ./openssl.cnf
Enter PKCS#11 token PIN for UserPIN (SmartCard-HSM):
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Apr 28 17:30:10 2020 GMT
            Not After : Apr 28 17:30:10 2021 GMT
        Subject:
            countryName               = BE
            stateOrProvinceName       = Antwerp
            organizationName          = stafnet.local
            organizationalUnitName    = intern.stafnet.local
            commonName                = testcert.intern.stafnet.local
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                4D:78:E3:F3:9B:F4:B3:B0:2B:C6:BF:E7:87:18:87:7B:A9:A2:50:6A
            X509v3 Authority Key Identifier: 
                keyid:67:3F:C1:1B:90:F5:78:E1:61:E5:00:19:5F:7D:43:B8:A6:66:E0:75

            Netscape CA Revocation Url: 
                http://ca.inter.stafnet.local/crl.pem
Certificate is to be certified until Apr 28 17:30:10 2021 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
-bash-4.4$ 
```

## Revoke

### CRL

#### Create the crl

```
-bash-4.4$ openssl ca -config openssl.cnf -engine pkcs11 -keyform engine -keyfile 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba -gencrl -out crl/ca.intern.stafnet.local.crl
engine "pkcs11" set.
Using configuration from openssl.cnf
Enter PKCS#11 token PIN for UserPIN (SmartCard-HSM):
-bash-4.4$ 
```

#### Review

```
-bash-4.4$ openssl crl -in crl/ca.intern.stafnet.local.crl -text -noout
Certificate Revocation List (CRL):
        Version 2 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = BE, ST = Antwerp, L = Antwerp, O = stafnet.local, OU = intern.stafnet.local, CN = ca.intern.stafnet.local
        Last Update: Apr 28 17:58:28 2020 GMT
        Next Update: May 28 17:58:28 2020 GMT
        CRL extensions:
            X509v3 CRL Number: 
                1
No Revoked Certificates.
    Signature Algorithm: sha256WithRSAEncryption
         ab:07:07:87:62:50:60:11:1a:1c:21:c9:f3:56:3c:b1:d5:3a:
         33:44:72:26:8d:09:96:a0:b6:ec:5b:09:8d:4e:25:e5:12:51:
         5f:c4:66:1e:71:a9:6b:82:be:1b:3f:ed:8e:65:bc:e9:b7:3f:
         cd:0c:40:68:13:3b:3f:6a:49:fb:0a:25:04:01:bf:0d:a3:5f:
         cb:4e:dd:78:6d:e0:12:51:b2:d7:e9:c4:74:28:6d:90:97:b9:
         84:01:38:64:3e:93:b5:21:24:28:9f:6e:b3:cf:ae:3d:de:cc:
         24:03:e7:41:3e:ec:5b:10:ef:4b:ff:e4:3d:b2:00:13:09:8f:
         0e:03:1f:c1:48:64:4a:ee:51:b4:cd:d4:2b:11:79:98:f1:06:
         03:1c:94:bf:fb:66:91:98:68:58:fa:46:86:96:d5:20:22:40:
         98:62:fd:32:bf:a7:0b:93:23:b8:06:03:c2:2e:ee:10:82:2f:
         e1:b2:2f:6e:e5:5c:44:12:43:b8:b6:d8:b9:29:ff:3f:81:01:
         c3:bb:5a:7b:19:75:a5:19:13:30:23:61:f0:92:b8:d6:06:88:
         3f:ce:27:71:1b:70:21:e0:0d:10:4d:49:9d:ee:1d:fc:2d:e5:
         db:e9:6c:50:48:1e:24:50:47:2c:00:17:02:50:d0:70:f0:02:
         9d:ca:43:c4
-bash-4.4$ 
```

### Revoke

```
-bash-4.4$ openssl ca -config openssl.cnf -engine pkcs11 -keyform engine -keyfile 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba -revoke certs/client001.crt
engine "pkcs11" set.
Using configuration from openssl.cnf
Enter PKCS#11 token PIN for UserPIN (SmartCard-HSM):
Revoking Certificate 01.
Data Base Updated
-bash-4.4$ 
```

#### Recreate the crl

```
-bash-4.4$ openssl ca -config openssl.cnf -engine pkcs11 -keyform engine -keyfile 853222fd3b35a4fdf0346d05d9bbc86baa9be6ba -gencrl -out crl/ca.intern.stafnet.local.crl
engine "pkcs11" set.
Using configuration from openssl.cnf
Enter PKCS#11 token PIN for UserPIN (SmartCard-HSM):
-bash-4.4$ 
```

#### Review

```
-bash-4.4$ openssl crl -in crl/ca.intern.stafnet.local.crl -text -noout
Certificate Revocation List (CRL):
        Version 2 (0x1)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: C = BE, ST = Antwerp, L = Antwerp, O = stafnet.local, OU = intern.stafnet.local, CN = ca.intern.stafnet.local
        Last Update: Apr 28 18:06:49 2020 GMT
        Next Update: May 28 18:06:49 2020 GMT
        CRL extensions:
            X509v3 CRL Number: 
                2
Revoked Certificates:
    Serial Number: 01
        Revocation Date: Apr 28 18:01:25 2020 GMT
    Signature Algorithm: sha256WithRSAEncryption
         6b:25:8e:1b:ef:87:6e:8e:08:8a:08:14:14:99:22:d3:be:d8:
         88:35:70:66:d4:da:01:6d:c1:4d:56:74:30:4d:b1:3f:02:fa:
         20:58:4f:12:26:fe:14:16:37:e6:aa:b2:aa:4a:c8:f5:ee:90:
         7b:e2:21:f0:25:d1:ea:52:8a:67:c5:af:38:32:2b:2c:97:74:
         1a:bd:51:2e:39:0a:c2:a8:13:20:11:52:55:ea:55:b1:bc:86:
         bf:08:2f:33:dc:23:f4:75:98:08:51:14:96:1d:5c:ba:30:0a:
         e2:00:db:40:ff:c4:f7:fb:d6:e5:85:5d:75:b7:ae:f6:7d:d6:
         17:aa:1c:84:27:49:6d:66:88:ff:60:4f:d4:19:ec:ca:d8:77:
         d4:47:26:4a:2b:e8:4b:59:64:85:8e:2b:6b:e8:b4:ab:c4:a8:
         50:11:3e:dc:8f:2d:bb:40:6a:7e:8c:94:51:c6:11:e6:b0:82:
         38:96:e9:40:4b:ab:62:ec:93:59:2a:ce:41:50:40:64:b8:f2:
         97:ea:75:7c:24:d8:da:4a:32:54:49:86:24:f1:a3:96:f0:68:
         5a:fa:22:f6:6b:92:41:37:a8:94:23:97:fe:d4:90:a2:2f:ca:
         f8:de:2c:00:bc:28:28:29:5b:79:18:1e:8c:fd:3b:ee:84:c2:
         2e:e7:2d:a0
-bash-4.4$ 
```

# Links

* [https://jamielinux.com/docs/openssl-certificate-authority/index.html](https://jamielinux.com/docs/openssl-certificate-authority/index.html)
* [https://framkant.org/2018/04/smartcard-hsm-backed-openssl-ca/](https://framkant.org/2018/04/smartcard-hsm-backed-openssl-ca/)
