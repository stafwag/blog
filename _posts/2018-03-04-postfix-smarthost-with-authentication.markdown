---
layout: post
title: "Postfix smarthost with authentication"
date: 2018-03-04 08:05:29 +0100
comments: true
categories: [ mail, freebsd, postfix ] 
---

{% img right /blog/images/postfix.png 400 266 "postfix" %} 

I used the relay host of my internet provider but this was causing issues since my email was getting mark as <a href="https://en.wikipedia.org/wiki/Email_spam">SPAM</a> in <a href="https://en.wikipedia.org/wiki/Gmail">gmail</a>.
<br />&nbsp;<br />
It was already on my to-do list to move my outgoing mail to my mail provider also to make it easier to move to another <a href="https://en.wikipedia.org/wiki/Internet_service_provider">ISP</a> or to implement <a href="https://en.wikipedia.org/wiki/Sender_Policy_Framework">SPF</a> but was not on the top of my to-do list.
<br />&nbsp;<br />
My email provider requires authentication, so I needed to reconfigure postfix in my FreeBSD mail jail to use a relay host with authentication.

### Install postfix-sasl

To use authentication with postfix the postfix-sasl package is required.
If postfix is already installed it'll be replace by postfix-sasl.

```
root@stafmail:/root # pkg install postfix-sasl
```

### Configuration 

#### Update the relay host

#### main.cf

```
relayhost = [smtp.mailprovider.domain]:465
smtp_use_tls=yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:/usr/local/etc/postfix/relay_pass
smtp_sasl_security_options =
smtp_tls_wrappermode = yes
smtp_tls_security_level = encrypt
```

#### relay_pass

The credentials are in the relay_pass file the password is in the file as plain-text so we 
it with the correct file permissions.


```
root@stafmail:/usr/local/etc/postfix # touch relay_pass
root@stafmail:/usr/local/etc/postfix # chmod 600 relay_pass
root@stafmail:/usr/local/etc/postfix # vi relay_pass
```

```
[smtp.mailprovider.domain]:465 user:password
```

#### Create the hash file.

```
root@stafmail:/usr/local/etc/postfix # postmap relay_pass
```

#### Verify the file permissions.

```
root@stafmail:/usr/local/etc/postfix # ls -l relay_pass*
-rw-------  1 root  wheel      60 Feb 23 22:43 relay_pass
-rw-------  1 root  wheel  131072 Feb 23 22:43 relay_pass.db
root@stafmail:/usr/local/etc/postfix # 
```

#### Restart

We replaced postfix with postfix-sasl a restart is required.

```
root@stafmail:/usr/local/etc/postfix # /usr/local/etc/rc.d/postfix restart
```

*** Have fun ***

