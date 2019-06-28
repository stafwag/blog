---
layout: post
title: "Thunderbird: Importing s/mime certificate failed"
date: 2016-01-17 09:03:53 +0100
comments: true
categories: [ security, thunderbird ] 
---

{% img left /blog/images/thunderbird_import_smime_failed.png 1000 835 "thunderbird smime failed" %} 

On <a href="http://kb.mozillazine.org/Getting_an_SMIME_certificate">http://kb.mozillazine.org/Getting_an_SMIME_certificate</a>
you get a list of free <a href="https://en.wikipedia.org/wiki/S/MIME">s/mime</a> certificate.

I ordered a free 30 days certificate at <a href="globalsign">globalsign</a>: <a href="https://www.globalsign.com/en/personalsign/trial/">https://www.globalsign.com/en/personalsign/trial/</a>

The import of the <a href="https://en.wikipedia.org/wiki/PKCS_12">pkcs12</a> failed in Thunderbird with the message: "The PKCS #12 operation failed for unknown reasons."

Searching the internet didn't provide a solution. To debug this issue I started to extract the private / certificate from the pkcs12 file provided by globalsign and creating a new one.

To execute this command I use an encrypted <a href="https://gitlab.com/cryptsetup/cryptsetup/blob/master/README.md">luks</a> volume. 

# Create a new pkcs12 file

## verifying the pkx file

### password too long?

The first issue was that the password of my pkx was too long by default the openssl pkcs12 command seems to have a limit of 32 characters. 

```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -in staf.pkx 
Enter Import Password:
Can't read Password
[staf@vicky staf@wagemakers.be]$ 
```

Use the "-passin pass", "-passin stdin" or "-passin file" argument resolves this issue. The "-passin pass" argument will show the password on the screen and in shell history, the "-passin stdin" will show your password on the screen, the "-passin file" will leave your password on the (hopefully encrypted) filesystem  so I went with the "-pass file" option.

### Created password file

Create the file that holds your password with the corrected file permissions, you must be the only one that is able to read this file:

```
[staf@vicky staf@wagemakers.be]$ touch pass
[staf@vicky staf@wagemakers.be]$ chmod 600 pass
[staf@vicky staf@wagemakers.be]$ vi pass
```

### Try again

With the "-passin file" argument we are able to the pkcs12 file.

```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -in staf.pkx -passin file:pass
MAC verified OK
Bag Attributes
    localKeyID: 9B B7 F3 7A 96 46 1F 08 28 A2 BC 2B 87 0E 53 92 29 B4 7D 7D 
Key Attributes: <No Attributes>
Enter PEM pass phrase:
Bag Attributes
    localKeyID: 9B B7 F3 7A 96 46 1F 08 28 A2 BC 2B 87 0E 53 92 29 B4 7D 7D 
subject=/CN=staf@wagemakers.be/emailAddress=staf@wagemakers.be
issuer=/C=BE/O=GlobalSign nv-sa/CN=GlobalSign PersonalSign 1 CA - SHA256 - G2
-----BEGIN CERTIFICATE-----
<snip>
```

## Extract

We'll extract the private key and the certificates and build a new pkcs12 file and import this pkcs12 file into thunderbird.

### Extract the private key

The private key is encrypted with the "bag" so need to type it or copy/pass it...  

```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -in staf.pkx -nocerts -out key.pem -passin file:pass 
MAC verified OK
Enter PEM pass phrase:
Verifying - Enter PEM pass phrase:
```

### Extract the client certificate


The client certificate isn't encrypted so you can leave the pem password empty.

```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -in staf.pkx -clcerts -out staf.pem -passin file:pass 
MAC verified OK

Enter PEM pass phrase:
[staf@vicky staf@wagemakers.be]$ 
```

### Verify the key and certificate

To verify that the certificate and the private belongs together we need to verify the modulus of the key and the certificate the sha1sum should match. 

```
staf@vicky staf@wagemakers.be]$ openssl rsa -in key.pem -modulus -noout | sha1sum
Enter pass phrase for key.pem:
1234567890123456789012345678901234567890  -
[staf@vicky staf@wagemakers.be]$ 
```

```
[staf@vicky staf@wagemakers.be]$ openssl x509 -in staf.pem -modulus -noout | sha1sum
1234567890123456789012345678901234567890  -
[staf@vicky staf@wagemakers.be]$ 
```

### Extract the signing certificate(s) 

The following command extracts the ca certificates.


```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -in staf.pkx -cacerts -out cacerts.pem -passin file:pass
MAC verified OK
Enter PEM pass phrase:
```

## Create a new pkcs12 file

This time we use a 32 characters password.

```
[staf@vicky staf@wagemakers.be]$ openssl pkcs12 -export -in staf.pem -inkey key.pem -certfile cacerts.pem -out staf_new.p12
Enter pass phrase for key.pem:
Enter Export Password:
Verifying - Enter Export Password:
```

# Import the the new pkcs12 file

{% img right /blog/images/thunderbird_import_smime_ok.png 598 152 "thunderbird smime import ok" %} 
Not sure what the issue was with original pkcs12 but the import works now....
 - it might have been the 32 characters password -.   After I was able to use the signing and encryption part in thunderbird.

*** Have fun ***



