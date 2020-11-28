---
layout: post
title: "Bacula on FreeBSD (part 2 Bacula Catalog over SSL )"
date: 2017-09-09 10:27:03 +0200
comments: true
categories:  [ bacula, freebsd, backup, postgresql, ssl ]
---
<img src="{{ '/images/postgressl.png'  | remove_first:'/' | absolute_url }}" class="right" width="300" height="300" alt="PostgreSSL" /> 

In my previous <a href="http://stafwag.github.io/blog/blog/2017/08/06/bacula-on-freebsd-w_part1/">post</a>, I setup on my <a href="https://www.postgresql.org/">PostgresSQL</a> <a href="https://en.wikipedia.org/wiki/FreeBSD_jail">FreeBSD jail</a>, In this post we continue with the bacaula server.

In this post we will continue with the database connection (Catalog) we'll go the extra ~~mile~~ 1,609344 km and encrypt the catalog connection with ssl. Why? ***We encrypt.. because we can!***

# Bacula Components

* **Bacula Director** <br />
The Bacula Director is daemon that runs in the backgroud that control all backup operations.

* **Bacula Console** <br />
The Bacula console is an administrator program that allows an system administrator to control the Bacula director. 

* **Bacula File** <br />
The Bacula File is a backup client install on the backup client. 

* **Bacula Storage** <br />
The backup media.

* **Catalog** <br /> 
The Catalog is the index of the backups. Bacula supports three types of index databases mySQL ( <a href="https://mariadb.org/">mariaDB</a>), <a href="https://www.postgresql.org/">PostgreSQL</a> and <a href="https://sqlite.org/">SQLite</a> 

* **Bacula monitor** <br />
A Bacula monitor service is a program that allows the system administrator to cerify the status of the bacula Directors, Bacula File Daemons and Bacula Storage Daemons.



# Bacula Server

## Jail

### Create the Bacula Server Jail

```
root@rataplan:~ # ezjail-admin create stafbacula "em0|192.168.1.52"
Warning: Some services already seem to be listening on all IP, (including 192.168.1.52)
  This may cause some confusion, here they are:
root     ntpd       754   20 udp6   *:123                 *:*
root     ntpd       754   21 udp4   *:123                 *:*
root     rpc.statd  717   4  udp6   *:846                 *:*
root     rpc.statd  717   5  tcp6   *:846                 *:*
root     rpc.statd  717   6  udp4   *:846                 *:*
root     rpc.statd  717   7  tcp4   *:846                 *:*
root     nfsd       713   5  tcp4   *:2049                *:*
root     nfsd       713   6  tcp6   *:2049                *:*
root     mountd     707   5  udp6   *:823                 *:*
root     mountd     707   6  tcp6   *:823                 *:*
root     mountd     707   7  udp4   *:823                 *:*
root     mountd     707   8  tcp4   *:823                 *:*
root     rpcbind    676   6  udp6   *:111                 *:*
root     rpcbind    676   7  udp6   *:779                 *:*
root     rpcbind    676   8  tcp6   *:111                 *:*
root     rpcbind    676   9  udp4   *:111                 *:*
root     rpcbind    676   10 udp4   *:768                 *:*
root     rpcbind    676   11 tcp4   *:111                 *:*
root     syslogd    656   6  udp6   *:514                 *:*
root     syslogd    656   7  udp4   *:514                 *:*
root@rataplan:~ # 
```

### Start the jail

```
root@rataplan:~ # ezjail-admin start stafbacula
Starting jails: stafbacula.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@rataplan:~ # 
```

### Open the console

```
root@rataplan:~ # ezjail-admin console stafbacula
FreeBSD 11.1-RELEASE-p1 (GENERIC) #0: Wed Sep  9 11:55:48 UTC 2017

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
root@stafbacula:~ # 
```

## Bacula installation

### Install pkg

Set up dns

```
root@stafbacula:~ # vi /etc/resolv.conf
```

```
nameserver 192.168.1.1
```

Bootstrap pkg

```
root@stafbacula:~ # pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
Bootstrapping pkg from pkg+http://pkg.FreeBSD.org/FreeBSD:11:amd64/quarterly, please wait...
Verifying signature with trusted certificate pkg.freebsd.org.2013102301... done
[stafbacula] Installing pkg-1.10.1...
[stafbacula] Extracting pkg-1.10.1: 100%
pkg: not enough arguments
Usage: pkg [-v] [-d] [-l] [-N] [-j <jail name or id>|-c <chroot path>|-r <rootdir>] [-C <configuration file>] [-R <repo config dir>] [-o var=value] [-4|-6] <command> [<args>]

For more information on available commands and options see 'pkg help'.
root@stafbacula:~ # 
```

Install the bacula server package

```
root@stafbacula:~ # pkg install bacula-server
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
Updating database digests format: 100%
The following 8 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        bacula-server: 7.4.7_1
        bacula-client: 7.4.7_1
        readline: 7.0.3
        indexinfo: 0.2.6
        gettext-runtime: 0.19.8.1_1
        lzo2: 2.10_1
        postgresql95-client: 9.5.7_1
        perl5: 5.24.1_1

Number of packages to be installed: 8

The process will require 69 MiB more space.
17 MiB to be downloaded.

Proceed with this action? [y/N]: y
[stafbacula] [1/8] Fetching bacula-server-7.4.7_1.txz: 100%  678 KiB 694.6kB/s    00:01    
[stafbacula] [2/8] Fetching bacula-client-7.4.7_1.txz: 100%  286 KiB 292.8kB/s    00:01    
[stafbacula] [3/8] Fetching readline-7.0.3.txz: 100%  334 KiB 342.4kB/s    00:01    
[stafbacula] [4/8] Fetching indexinfo-0.2.6.txz: 100%    5 KiB   5.3kB/s    00:01    
[stafbacula] [5/8] Fetching gettext-runtime-0.19.8.1_1.txz: 100%  148 KiB 151.1kB/s    00:01    
[stafbacula] [6/8] Fetching lzo2-2.10_1.txz: 100%  113 KiB 115.4kB/s    00:01    
[stafbacula] [7/8] Fetching postgresql95-client-9.5.7_1.txz: 100%    2 MiB 772.9kB/s    00:03    
[stafbacula] [8/8] Fetching perl5-5.24.1_1.txz: 100%   13 MiB 874.0kB/s    00:16    
Checking integrity... done (0 conflicting)
[stafbacula] [1/8] Installing indexinfo-0.2.6...
[stafbacula] [1/8] Extracting indexinfo-0.2.6: 100%
[stafbacula] [2/8] Installing readline-7.0.3...
[stafbacula] [2/8] Extracting readline-7.0.3: 100%
[stafbacula] [3/8] Installing gettext-runtime-0.19.8.1_1...
[stafbacula] [3/8] Extracting gettext-runtime-0.19.8.1_1: 100%
[stafbacula] [4/8] Installing lzo2-2.10_1...
[stafbacula] [4/8] Extracting lzo2-2.10_1: 100%
[stafbacula] [5/8] Installing perl5-5.24.1_1...
[stafbacula] [5/8] Extracting perl5-5.24.1_1: 100%
[stafbacula] [6/8] Installing bacula-client-7.4.7_1...
===> Creating groups.
Creating group 'bacula' with gid '910'.
===> Creating users
Creating user 'bacula' with uid '910'.
[stafbacula] [6/8] Extracting bacula-client-7.4.7_1: 100%
[stafbacula] [7/8] Installing postgresql95-client-9.5.7_1...
[stafbacula] [7/8] Extracting postgresql95-client-9.5.7_1: 100%
[stafbacula] [8/8] Installing bacula-server-7.4.7_1...
===> Creating groups.
Using existing group 'bacula'.
===> Creating users
Using existing user 'bacula'.
[stafbacula] Extracting bacula-server-7.4.7_1: 100%
Message from perl5-5.24.1_1:
The /usr/bin/perl symlink has been removed starting with Perl 5.20.
For shebangs, you should either use:

#!/usr/local/bin/perl

or

#!/usr/bin/env perl

The first one will only work if you have a /usr/local/bin/perl,
the second will work as long as perl is in PATH.
Message from bacula-client-7.4.7_1:
################################################################################

NOTE:
Sample files are installed in /usr/local/etc/bacula:

  bconsole.conf.sample, bacula-fd.conf.sample

################################################################################
Message from postgresql95-client-9.5.7_1:
The PostgreSQL port has a collection of "side orders":

postgresql-docs
  For all of the html documentation

p5-Pg
  A perl5 API for client access to PostgreSQL databases.

postgresql-tcltk
  If you want tcl/tk client support.

postgresql-jdbc
  For Java JDBC support.

postgresql-odbc
  For client access from unix applications using ODBC as access
  method. Not needed to access unix PostgreSQL servers from Win32
  using ODBC. See below.

ruby-postgres, py-PyGreSQL
  For client access to PostgreSQL databases using the ruby & python
  languages.

postgresql-plperl, postgresql-pltcl & postgresql-plruby
  For using perl5, tcl & ruby as procedural languages.

postgresql-contrib
  Lots of contributed utilities, postgresql functions and
  datatypes. There you find pg_standby, pgcrypto and many other cool
  things.

etc...
Message from bacula-server-7.4.7_1:
###############################################################################

bacula server was installed

An auto-changer manipulation script based on FreeBSDs
chio command is included and installed at

  /usr/local/sbin/chio-bacula

Please have a look at it if you want to use an
autochanger. You have to configure the usage in

  /usr/local/etc/bacula/bacula-dir.conf

Take care of correct permissions for changer and
tape device (e.g. /dev/ch0 and /dev/n[r]sa0) i.e.
they must be accessible by user bacula.

Due to lack of some features in the FreeBSD tape driver
implementation you MUST add some OS dependent options to
the bacula-sd.conf file:

  Hardware End of Medium = no;
  Backward Space Record  = no;
  Backward Space File    = no;

With 2 filemarks at EOT (see man mt):
  Fast Forward Space File = no;
  BSF at EOM = yes;
  TWO EOF    = yes;

With 1 filemarks at EOT (see man mt):
  Fast Forward Space File = yes;
  BSF at EOM = no;
  TWO EOF   = no;

NOTE: YOU CAN SWITCH EOT model ONLY when starting
      from scratch with EMPTY tapes.

It is also important that all the scripts accessed
by RunBeforeJob and RunAfterJob will be executed by
the user bacula.  Check your permissions.

For USB support read the bacula manual. It could be necessary
to configure/compile a new kernel.

Look at /usr/local/share/bacula/update_bacula_tables for
database update procedure. Details can be found in the
ReleaseNotes

If you are using sqlite you need to run the make_sqlite_tables script as
the bacula user. Do this using 'sudo su -m bacula'.

################################################################################
root@stafbacula:~ # 
```

# Initialize the bacula catalog

We'll have a postgreSQL server running in a FreeBSD jail as our catalog (see <a href="http://stafwag.github.io/blog/blog/2017/08/06/bacula-on-freebsd:w_part1/">http://stafwag.github.io/blog/blog/2017/08/06/bacula-on-freebsd:w_part1/</a> howto install PostgreSQL into a FreeBSD jail).

## PostgreSQL setup

The setup below describes howto configure the PostgreSQL catalog with certificate and username/password authentication. This might be overkill the bacula server runs on the same physical host so no data is going out on the network. But I wanted to setup the database conneection as secure as possible and will reuse this setup for my other database connection. We'll setup a "self signed" root ca for now, but I replace this with my own CA in further.

### PostgreSQL authentication methods

PostgreSQL support a lot of authentication methods you'll find a description of the supported of the support authentication methods below (without too much details):

* **Trust Authentication** <br />
With trust authentication the postgreSQL trust the connection from the remote host, this is the default for localhost host connection and "socket" connections.
<br />&nbsp;<br />
* **Password Authentication** <br />
Authentication with login/password
<br />&nbsp;<br />
* **GSSAPI Authentication** <br />
Authentication with the <a href="https://en.wikipedia.org/wiki/Generic_Security_Services_Application_Program_Interface">Generic Security Services Application Program Interface</a>
<br />&nbsp;<br />
* **SSPI Authentication** <br />
Authentication with the <a href="https://en.wikipedia.org/wiki/Security_Support_Provider_Interface"">Security Support Provider Interface</a> - SSPI is a proprietary variant of GSSAPI with extensions and very Windows-specific data types -
<br />&nbsp;<br />
* **Kerberos Authentication** <br />
Authentication using the <a href="https://en.wikipedia.org/wiki/Kerberos_(protocol)">Kerberos protocol</a>
<br />&nbsp;<br />
* **Ident Authentication** <br />
Authentication using the <a href="https://en.wikipedia.org/wiki/Ident_protocol">ident protocol</a>
<br />&nbsp;<br />
* **Peer Authentication** <br />
Authentication using the <a href="https://www.freebsd.org/cgi/man.cgi?query=getpeereid">getpeereid()</a> kernel function, only supported for local connection on BSD, MacOS and GNU/Linux.
<br />&nbsp;<br />
* **LDAP Authentication** <br />
<a href="https://en.wikipedia.org/wiki/Lightweight_Directory_Access_Protocol">LDAP</a> authentication.</a>
<br />&nbsp;<br />
* **RADIUS Authentication** <br />
<a href="https://en.wikipedia.org/wiki/RADIUS">Radius</a> authentication.
<br />&nbsp;<br />
* **Certificate Authentication** <br />
Authentication with a <a href="https://en.wikipedia.org/wiki/Public_key_infrastructure">PKI certificate</a>.
<br />&nbsp;<br />
* **PAM Authentication** <br />
<a href="https://en.wikipedia.org/wiki/Pluggable_authentication_module">PAM</a> based authentication</a>
<br />&nbsp;<br />
<br />&nbsp;<br />
I wanted to use password authentication over ssl with a client certificate.
The bacula documents isn't very clear on howto configure it. After a quick lot at the bacula source code it should be supported, so let's give it a try...


### Configure the PostgreSQL jail

#### Allow network connections

Logon the postgreSQL server jail move to the postgreSQL data directory and edit postgresql.conf to allow TCP/IP connections.

```
root@stafdb:/var/db/postgres/data96 # pwd
/var/db/postgres/data96
root@stafdb:/var/db/postgres/data96 # vim postgresql.conf
```

```
# - Connection Settings -

listen_addresses = '192.168.1.51'               # what IP address(es) to listen on;
# listen_addresses = 'localhost'                # what IP address(es) to listen on;
                                        # comma-separated list of addresses;
                                        # defaults to 'localhost'; use '*' for all
                                        # (change requires restart)
#port = 5432                            # (change requires restart)

```

#### SSL encryption

It's always a good idea to encrypt your connections.

##### SSL Server setup

###### Umask

set the umask to prevent somebody can read you private key.

```
root@stafdb:/var/db/postgres/data96 # su - postgres
$ umask 077 
$ 
```

###### Create a private key

Create a private key without encrypting it.

```
openssl genrsa -out server.key 4096
Generating RSA private key, 4096 bit long modulus
........................................................................................................................................................................................................................++
......++
e is 65537 (0x10001)
$ 
```

###### Create a self-signed certificate

```
$ openssl req -new -key server.key -days 3650 -out server.crt -x509 -subj '/C=BE/ST=Flanders/L=Antwerp/O=stafnet/CN=stafdb'
$ ls -ltr                                                                                               total 23
-rw-------   1 postgres  postgres  3247 Sep  9 11:47 server.key
-rw-------   1 postgres  postgres  1964 Sep  9 11:52 server.crt
$ 
```

###### Root ca

We created a self signed certificate so the server certificate is our trusted ca root.

```
$ ln -s server.crt root.crt
$ ls -ltr
total 24
-rw-------   1 postgres  postgres  3247 Sep  9 11:47 server.key
-rw-------   1 postgres  postgres  1964 Sep  9 11:52 server.crt
lrwx------   1 postgres  postgres    10 Sep  9 11:53 root.crt -> server.crt
$ 
```

###### Enable ssl

Edit postgresql.conf and  update the ssl setting


```
$ vi postgresql.conf

```

By default ssl_ca_file is not set but this directive is required so don't forget to set it.
We disable the 3DES ciphers they're obsolete... We don't speficy a crl for now.

```
#authentication_timeout = 1min          # 1s-600s
ssl = on                                # (change requires restart)
ssl_ciphers = 'HIGH:MEDIUM:!3DES:!aNULL' # allowed SSL ciphers
                                        # (change requires restart)
ssl_prefer_server_ciphers = on          # (change requires restart)
#ssl_ecdh_curve = 'prime256v1'          # (change requires restart)
ssl_cert_file = 'server.crt'            # (change requires restart)
ssl_key_file = 'server.key'             # (change requires restart)
ssl_ca_file = 'root.crt'                        # (change requires restart)
#ssl_crl_file = ''                      # (change requires restart)
#password_encryption = on
```

##### SSL Client setup

###### Become bacula

Logon to the bacula jail and become the bacula user. We use "su -m ..." to logon to the locked daemon account, this will take over the root environment.

```
root@rataplan:~ # ezjail-admin console stafbacula
Last login: Wed Sep  9 09:33:16 on pts/0
FreeBSD 11.1-RELEASE-p1 (GENERIC) #0: Wed Sep  9 11:55:48 UTC 2017

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
You have new mail.
root@stafbacula:~ # su -m bacula -c "/bin/sh"
$ id
uid=910(bacula) gid=910(bacula) groups=910(bacula)
$ 
```

###### umask

Set the umask to prevent somebody can read you private key.

```
$ umask 077
$ 
```

###### move to the bacula home directory

```
$ cat /etc/passwd | grep bacula
bacula:*:910:910:Bacula Daemon:/var/db/bacula:/usr/sbin/nologin
$ cd /var/db/bacula
```

###### create the .postges directory

```
$ mkdir .postgres
$ ls -la
total 12
drwxrwx---   3 bacula  bacula   3 Sep  9 09:41 .
drwxr-xr-x  14 root    wheel   18 Sep  9 14:41 ..
drwx------   2 bacula  bacula   2 Sep  9 09:41 .postgres
$ cd .postgres/
$ 
```

###### Create a private key

We took over the root evironment therefor we need to set the RANDFILE variable to randfile in the bacula home directory.

```
$ pwd
/var/db/bacula/.postgres
$ export RANDFILE=/var/db/bacula/.rnd
$ 
```

Create the private key.

```
$ openssl genrsa -out `hostname`.key 4096
Generating RSA private key, 4096 bit long modulus
..........++
.......................................................++
e is 65537 (0x10001)
$ 
```

###### Create the client csr

```
$ openssl req -new -key stafbacula.key -out stafbacula.csr -subj '/C=BE/ST=Flanders/L=Antwerp/O=stafnet/CN=stafbacula'
$ 
```

###### Create the client certifocate

Logon to the postgreSQL jail as postgres and sign the client csr.

```
[postgres@stafdb ~/data96]$ openssl x509 -req -in stafbacula.csr -CAcreateserial -CA root.crt -CAkey server.key -out stafbacula.crt 
Signature ok
subject=/C=BE/ST=Flanders/L=Antwerp/O=stafnet/CN=stafbacula
Getting CA Private Key
[postgres@stafdb ~/data96]$ 

```

##### Copy the client certificate and the trusted root certificate to bacula jail

```
$ uname -a
FreeBSD stafbacula 11.1-RELEASE-p1 FreeBSD 11.1-RELEASE-p1 #0: Wed Sep  9 11:55:48 UTC 2017     root@amd64-builder.daemonology.net:/usr/obj/usr/src/sys/GENERIC  amd64
$ pwd
/var/db/bacula/.postgres
$ ls -ltr
total 24
-rw-------  1 bacula  bacula  3243 Sep  9 09:47 stafbacula.key
-rw-------  1 bacula  bacula  1679 Sep  9 09:54 stafbacula.csr
-rw-------  1 bacula  bacula  1964 Sep  9 10:04 root.crt
-rw-------  1 bacula  bacula  1850 Sep  9 10:06 stafbacula.crt
$ 
```

#### Host file on the bacula jail

The hostname of the posgresql jail has to match with the CN of the server certificate. So we'll add the hostname to /etc/hosts

```
root@stafbacula:~ # vi /etc/hosts
```

```
192.168.1.51    stafdb
```

## Setup the bacula database

#### Create the bacula database user  

```
[postgres@stafdb ~/data96]$ id
uid=770(postgres) gid=770(postgres) groups=770(postgres)
[postgres@stafdb ~/data96]$ psql postgres
psql (9.6.3)
Type "help" for help.

postgres=# create user bacula WITH PASSWORD 'xxxxxx';
CREATE ROLE
postgres=# 
```

To update the user password;

```
postgres=# alter user bacula PASSWORD 'yyyyyyy';
ALTER ROLE
postgres=# 
```

You can view the new permissions in the pg_user table or by execute the \du (describe user shortcut), by default the user has minimal permissions.

```
postgres=# select * from pg_user where usename = 'bacula';
 usename | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig 
---------+----------+-------------+----------+---------+--------------+----------+----------+-----------
 bacula  |    16386 | f           | f        | f       | f            | ******** |          | 
(1 row)

postgres=# 

```

```
postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of 
-----------+------------------------------------------------------------+-----------
 bacula    |                                                            | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

postgres=# 
```
### Allow the bacula user to create databases

The bacula database script will try to create the bacula catalog database.
We'll allow the bacula user to create databases, 

```
postgres=# alter user bacula CREATEDB;
ALTER ROLE
postgres=# select * from pg_user where usename = 'bacula';
 usename | usesysid | usecreatedb | usesuper | userepl | usebypassrls |  passwd  | valuntil | useconfig 
---------+----------+-------------+----------+---------+--------------+----------+----------+-----------
 bacula  |    16386 | t           | f        | f       | f            | ******** |          | 
(1 row)

postgres=# \du
                                   List of roles
 Role name |                         Attributes                         | Member of 
-----------+------------------------------------------------------------+-----------
 bacula    | Create DB                                                  | {}
 postgres  | Superuser, Create role, Create DB, Replication, Bypass RLS | {}

postgres=# 
```

### Create the bacula database

We'll create a bacula database so we can verify the database connection from the bacula user to the bacula database.

Create a new bacula database

```
postgres=# create database bacula;
CREATE DATABASE
postgres=# 
```

Grant all permissions to the bacula user

```
postgres=# grant ALL on DATABASE bacula to bacula;
GRANT
postgres=# 
```

## Update pg_hba

The pg_hba.conf configuration controls the **H**ost **B**ased **A**ccess to your postgreSQL database(s).

```
[postgres@stafdb ~/data96]$ pwd
/var/db/postgres/data96
[postgres@stafdb ~/data96]$ id
uid=770(postgres) gid=770(postgres) groups=770(postgres)
[postgres@stafdb ~/data96]$ vi pg_hba.conf 
```

And add the next lines;

```
# TYPE  DATABASE        USER            ADDRESS                 METHOD
hostssl bacula          bacula          192.168.1.52/32         md5 clientcert=1
hostssl template0       bacula          192.168.1.52/32         md5 clientcert=1
hostssl template1       bacula          192.168.1.52/32         md5 clientcert=1
hostssl postgres        bacula          192.168.1.52/32         md5 clientcert=1
```

Our bacula jail ***192.168.1.52*** only needs to have to the ***bacula*** database with the ***bacula*** user over ssl ***hostssl*** passwords will be send as a ***md5*** hash and a client certificate is required ***clientcert=1***.

We could also used the ***cert*** method and ***map*** the client certificate to postgresql user so we could authenticate with the client certificate only...

We allow access to the template\* and the postgres database because it's required for the bacula database xcreate script. We can remove them ( only allow access to the bacula database ) after the catalog database is created.


## Restart postgresql 

```
root@stafdb:/var/db/postgres/data96 # service postgresql restart
DEBUG:  postgres: PostmasterMain: initial environment dump:
DEBUG:  -----------------------------------------
DEBUG:          LC_TIME=C
DEBUG:          LC_NUMERIC=C
DEBUG:          LC_MONETARY=C
DEBUG:          LC_MESSAGES=C
DEBUG:          LC_CTYPE=C
DEBUG:          LC_COLLATE=C
DEBUG:          MAIL=/var/mail/postgres
DEBUG:          PGLOCALEDIR=/usr/local/share/locale
DEBUG:          PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/var/db/postgres/bin
DEBUG:          PGDATA=/var/db/postgres/data96
DEBUG:          PWD=/var/db/postgres
DEBUG:          PGSYSCONFDIR=/usr/local/etc/postgresql
DEBUG:          HOME=/var/db/postgres
DEBUG:          USER=postgres
DEBUG:          SHELL=/bin/sh
DEBUG:          PG_GRANDPARENT_PID=79045
DEBUG:          BLOCKSIZE=K
DEBUG:  -----------------------------------------
LOG:  could not create IPv6 socket: Protocol not supported
LOG:  could not bind IPv4 socket: Address already in use
HINT:  Is another postmaster already running on port 5432? If not, wait a few seconds and retry.
WARNING:  could not create listen socket for "192.168.1.51"
DEBUG:  invoking IpcMemoryCreate(size=148480000)
DEBUG:  SlruScanDirectory invoking callback on pg_notify/0000
DEBUG:  removing file "pg_notify/0000"
DEBUG:  dynamic shared memory system will support 288 segments
DEBUG:  created dynamic shared memory control segment 773439544 (2316 bytes)
DEBUG:  max_safe_fds = 984, usable_fds = 1000, already_open = 6
LOG:  ending log output to stderr
HINT:  Future log output will go to log destination "syslog".
DEBUG:  CommitTransaction
DEBUG:  name: unnamed; blockState:       STARTED; state: INPROGR, xid/subid/cid: 0/1/0, nestlvl: 1, children: 
root@stafdb:/var/db/postgres/data96 #

```

## Test the database connection

### Verify

Verify the database connection for the bacula jail. See <a href="https://www.postgresql.org/docs/9.6/static/libpq-connect.html">https://www.postgresql.org/docs/9.6/static/libpq-connect.html</a>

```
[bacula@stafbacula /var/db/bacula/.postgres]$ psql "sslmode=verify-full host=stafdb dbname=bacula sslcert=`pwd`/postgresql.crt sslkey=`pwd`/postgresql.key sslrootcert=`pwd`/root.crt"
Password:
DEBUG:  CommitTransaction
DEBUG:  name: unnamed; blockState:       STARTED; state: INPROGR, xid/subid/cid: 0/1/0, nestlvl: 1, children:
psql (9.5.7, server 9.6.3)
WARNING: psql major version 9.5, server major version 9.6.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.
bacula=>
```

### Create environment script

Bacula comes with a few scripts to popilate the catalog we will create an "environment" script to setup the required environment variabeles to connect to the database. <a href="https://www.postgresql.org/docs/9.6/static/libpq-envars.html">https://www.postgresql.org/docs/9.6/static/libpq-envars.html</a> gives an overview of PostgreSQL environment variabeles.

```
[bacula@stafbacula /var/db/bacula]$ vi psql_env.sh
```

```
PGHOST=stafdb
PGUSER=bacula
PGSSLMODE=verify-full
PGSSLCERT=/var/db/bacula/.postgres/postgresql.crt
PGSSLKEY=/var/db/bacula/.postgres/postgresql.key
PGSSLROOTCERT=/var/db/bacula/.postgres/root.crt

export PGHOST
export PGUSER
export PGSSLMODE
export PGSSLCERT
export PGSSLKEY
export PGSSLROOTCERT
```

Test the environment script

```
root@stafbacula:~ # su -m bacula -c /bin/sh
$ . /var/db/bacula/psql_env.sh
$ psql bacula
Password: 
DEBUG:  CommitTransaction
DEBUG:  name: unnamed; blockState:       STARTED; state: INPROGR, xid/subid/cid: 0/1/0, nestlvl: 1, children: 
psql (9.5.8, server 9.6.4)
WARNING: psql major version 9.5, server major version 9.6.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

bacula=> 
```

## Configure the bacula catalog

### Configuration directives

I found the bacula documention not very clear howto setup the catalog connection with certificate authentication - or I looked at the wrong place - so I downloaded the bacula source code ( version 7.4.7 )to verify the required directives. ./src/dird/d/dird_conf.c


```
[staf@vicky bacula-7.4.7]$ vim ./src/dird/dird_conf.c
```

```
/*
   Bacula(R) - The Network Backup Solution

   Copyright (C) 2000-2016 Kern Sibbald

   The original author of Bacula is Kern Sibbald, with contributions
   from many others, a complete list can be found in the file AUTHORS.

   You may use this file and others of this release according to the
   license defined in the LICENSE file, which includes the Affero General
   Public License, v3.0 ("AGPLv3") and some additional permissions and
   terms pursuant to its AGPLv3 Section 7.

   This notice must be preserved when any source code is
   conveyed and/or propagated.

   Bacula(R) is a registered trademark of Kern Sibbald.
*/

<snip>

/*
 *    Catalog Resource Directives
 *
 *   name          handler     value                 code flags    default_value
 */
static RES_ITEM cat_items[] = {
   {"Name",     store_name,     ITEM(res_cat.hdr.name),    0, ITEM_REQUIRED, 0},
   {"Description", store_str,   ITEM(res_cat.hdr.desc),    0, 0, 0},
   {"dbaddress", store_str,     ITEM(res_cat.db_address),  0, 0, 0},
   {"Address",  store_str,      ITEM(res_cat.db_address),  0, 0, 0},
   {"DbPort",   store_pint32,   ITEM(res_cat.db_port),      0, 0, 0},
   /* keep this password as store_str for the moment */
   {"dbpassword", store_str,    ITEM(res_cat.db_password), 0, 0, 0},
   {"Password", store_str,      ITEM(res_cat.db_password), 0, 0, 0},
   {"dbuser",   store_str,      ITEM(res_cat.db_user),     0, 0, 0},
   {"User",     store_str,      ITEM(res_cat.db_user),     0, 0, 0},
   {"DbName",   store_str,      ITEM(res_cat.db_name),     0, ITEM_REQUIRED, 0},
   {"dbdriver", store_str,      ITEM(res_cat.db_driver),   0, 0, 0},
   {"DbSocket", store_str,      ITEM(res_cat.db_socket),   0, 0, 0},
   {"dbsslkey", store_str,      ITEM(res_cat.db_ssl_key),  0, 0, 0},
   {"dbsslcert", store_str,     ITEM(res_cat.db_ssl_cert),  0, 0, 0},
   {"dbsslca", store_str,       ITEM(res_cat.db_ssl_ca),  0, 0, 0},
   {"dbsslcapath", store_str,   ITEM(res_cat.db_ssl_capath),  0, 0, 0},
   {"dbsslcipher", store_str,   ITEM(res_cat.db_ssl_cipher),  0, 0, 0},
   /* Turned off for the moment */
   {"MultipleConnections", store_bit, ITEM(res_cat.mult_db_connections), 0, 0, 0},
   {"DisableBatchInsert", store_bool, ITEM(res_cat.disable_batch_insert), 0, ITEM_DEFAULT, false},
   {NULL, NULL, {0}, 0, 0, 0}
};

```

The ssl directives didn't seem to work with postgresql :-( If we feed the postgresql environment variables with the correct ssl settings to the bacula director it seems to work.  

## Initialize the database

### Drop the existing bacula database

The bacacla create script will try to create a new bacaula database so we'll to drop or test database on our database server.

```
root@stafdb:~ # su - postgres
$ psql
psql (9.6.4)
Type "help" for help.

postgres=# drop database bacula ;
DROP DATABASE
postgres=# \l
                             List of databases
   Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges   
-----------+----------+----------+---------+-------+-----------------------
 postgres  | postgres | UTF8     | C       | C     | 
 template0 | postgres | UTF8     | C       | C     | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
 template1 | postgres | UTF8     | C       | C     | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
(3 rows)

postgres=# 
```

### Create the database

Logon the bacula jail and create the bacula database.

```
$ . /var/db/bacula/psql_env.sh
$ ./create_bacula_database
Creating postgresql database
Password: 
Password: 
CREATE DATABASE
ALTER DATABASE
Creation of bacula database succeeded.
Password: 
Password: 
Database encoding OK
```

### Populate the bacula tables

```
$ ./make_bacula_tables 
Making postgresql tables
Password: 
CREATE TABLE
ALTER TABLE
CREATE INDEX
CREATE TABLE
ALTER TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE INDEX
CREATE INDEX
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE INDEX
CREATE TABLE
CREATE TABLE
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
INSERT 0 1
CREATE TABLE
CREATE INDEX
INSERT 0 1
Creation of Bacula PostgreSQL tables succeeded.
$ 
```

### Verify

Logon the bacula database and verify that the database populated.

```
$ psql
Password: 
psql (9.5.8, server 9.6.4)
WARNING: psql major version 9.5, server major version 9.6.
         Some psql features might not work.
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

bacula=> \d
                       List of relations
 Schema |               Name                |   Type   | Owner  
--------+-----------------------------------+----------+--------
 public | basefiles                         | table    | bacula
 public | basefiles_baseid_seq              | sequence | bacula
 public | cdimages                          | table    | bacula
 public | client                            | table    | bacula
 public | client_clientid_seq               | sequence | bacula
 public | counters                          | table    | bacula
 public | device                            | table    | bacula
 public | device_deviceid_seq               | sequence | bacula
 public | file                              | table    | bacula
 public | file_fileid_seq                   | sequence | bacula
 public | filename                          | table    | bacula
 public | filename_filenameid_seq           | sequence | bacula
 public | fileset                           | table    | bacula
 public | fileset_filesetid_seq             | sequence | bacula
 public | job                               | table    | bacula
 public | job_jobid_seq                     | sequence | bacula
 public | jobhisto                          | table    | bacula
 public | jobmedia                          | table    | bacula
 public | jobmedia_jobmediaid_seq           | sequence | bacula
 public | location                          | table    | bacula
 public | location_locationid_seq           | sequence | bacula
 public | locationlog                       | table    | bacula
 public | locationlog_loclogid_seq          | sequence | bacula
 public | log                               | table    | bacula
 public | log_logid_seq                     | sequence | bacula
 public | media                             | table    | bacula
 public | media_mediaid_seq                 | sequence | bacula
 public | mediatype                         | table    | bacula
 public | mediatype_mediatypeid_seq         | sequence | bacula
 public | path                              | table    | bacula
 public | path_pathid_seq                   | sequence | bacula
 public | pathhierarchy                     | table    | bacula
 public | pathvisibility                    | table    | bacula
 public | pool                              | table    | bacula
 public | pool_poolid_seq                   | sequence | bacula
 public | restoreobject                     | table    | bacula
 public | restoreobject_restoreobjectid_seq | sequence | bacula
 public | snapshot                          | table    | bacula
 public | snapshot_snapshotid_seq           | sequence | bacula
--More--(byte 2667)
```

### Cleanup

Disable the access to template? and postgres databases.

```
root@stafdb:/var/db/postgres/data96 # vi pg_hba.conf
```

```
host    all             all             ::1/128                 trust
hostssl bacula          bacula          192.168.1.52/32         md5 clientcert=1
# hostssl       template0       bacula          192.168.1.52/32         md5 clientcert=1
# hostssl       template1       bacula          192.168.1.52/32         md5 clientcert=1
# hostssl       postgres        bacula          192.168.1.52/32         md5 clientcert=1
```

Reload

```
root@stafdb:/var/db/postgres/data96 # service postgresql reload
root@stafdb:/var/db/postgres/data96 # 
```

Test it. Verify that access to the postgres database is denied from the bacula host.

```
$ psql postgres
psql: FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "postgres", SSL on
$ 
```

## Bacula catalog configuration

### Update the bacula director configuration

```
root@stafbacula:/usr/local/etc/bacula # vi bacula-dir.conf
```

```
# Generic catalog service
Catalog { 
  Name = MyCatalog
  dbname = "bacula"; dbuser = "bacula"; dbpassword = "********" ; dbsslkey = "/var/db/bacula/.postgres
/postgresql.key"; dbsslcert = "/var/db/bacula/.postgres/postgresql.crt"; dbsslca= "/var/db/bacula/.postgres
/root.crt"

}
```

### Test the catalog connection

bacula include a program to verify the bacula catalog "dbcheck", the -c switch select the bacula director configuration file the -B switch print out the configuration.

```
bacula@stafbacula /usr/local]$ dbcheck -c /usr/local/etc/bacula/bacula-dir.conf -B -v
catalog=MyCatalog
db_name=bacula
db_driver=
db_user=bacula
db_password=*******
db_address=stafdb
db_port=0
db_socket=
db_type=PostgreSQL
working_dir=/var/db/bacula
[bacula@stafbacula /usr/local]$ 

```

For some reason the ssl directives aren't include and the connection fails 

```
[bacula@stafbacula /usr/local/etc/rc.d]$ dbcheck -c /usr/local/etc/bacula/bacula-dir.conf -v
dbcheck: Fatal Error at dbcheck.c:303 because:
postgresql.c:271 Unable to connect to PostgreSQL server. Database=bacula User=bacula
Possible causes: SQL server not running; password incorrect; max_connections exceeded.
09-Sep 14:22 dbcheck: Fatal Error at dbcheck.c:303 because:
postgresql.c:271 Unable to connect to PostgreSQL server. Database=bacula User=bacula
Possible causes: SQL server not running; password incorrect; max_connections exceeded.
[bacula@stafbacula /usr/local/etc/rc.d]$ 

```

On our postgres host we get the error message that the bacula host tries to connect without SSL.

```
oot@stafdb:/var/db/postgres/data96 # tail -f /var/log/messages
Sep  9 14:22:10 stafdb postgres[14183]: [10-1] FATAL:  connection requires a valid client certificate
Sep  9 14:22:10 stafdb postgres[14184]: [10-1] FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "bacula", SSL off
Sep  9 14:22:15 stafdb postgres[14185]: [10-1] FATAL:  connection requires a valid client certificate
Sep  9 14:22:15 stafdb postgres[14186]: [10-1] FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "bacula", SSL off
Sep  9 14:22:20 stafdb postgres[14187]: [10-1] FATAL:  connection requires a valid client certificate
Sep  9 14:22:20 stafdb postgres[14188]: [10-1] FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "bacula", SSL off
Sep  9 14:22:25 stafdb postgres[14190]: [10-1] FATAL:  connection requires a valid client certificate
Sep  9 14:22:25 stafdb postgres[14191]: [10-1] FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "bacula", SSL off
Sep  9 14:22:30 stafdb postgres[14193]: [10-1] FATAL:  connection requires a valid client certificate
Sep  9 14:22:30 stafdb postgres[14194]: [10-1] FATAL:  no pg_hba.conf entry for host "192.168.1.52", user "bacula", database "bacula", SSL off
```
When set the postgresql varialables with the correct ssl settings the connnection works fine.

```
[bacula@stafbacula /usr/local/etc/rc.d]$ dbcheck -c /usr/local/etc/bacula/bacula-dir.conf -v
Hello, this is the database check/correct program.
Modify database is off. Verbose is on.
Please select the function you want to perform.

     1) Toggle modify database flag
     2) Toggle verbose flag
     3) Check for bad Filename records
     4) Check for bad Path records
     5) Check for duplicate Filename records
     6) Check for duplicate Path records
     7) Check for orphaned Jobmedia records
     8) Check for orphaned File records
     9) Check for orphaned Path records
    10) Check for orphaned Filename records
    11) Check for orphaned FileSet records
    12) Check for orphaned Client records
    13) Check for orphaned Job records
    14) Check for all Admin records
    15) Check for all Restore records
    16) All (3-15)
    17) Quit
Select function number: 

```


## Bacula director

### Enable the  bacula director

```
root@stafbacula:/usr/local/etc/rc.d # sysrc bacula_dir_enable=yes
bacula_dir_enable:  -> yes
root@stafbacula:/usr/local/etc/rc.d # 

```

#### Create the bacula.log

```
root@stafbacula:/var/log # touch /var/log/bacula.log
root@stafbacula:/var/log # chown bacula:bacula /var/log/bacula.log
```

#### Include the postgreSQL ssl settings in the bacula director startup script

Update the bacula-dir startup sript to include the ssl settings. 

```
# Add the following lines to /etc/rc.conf.local or /etc/rc.conf
# to enable this service:
#
# bacula_dir_enable  (bool):   Set to NO by default.
#                Set it to YES to enable bacula_dir.
# bacula_dir_flags (params):   Set params used to start bacula_dir.
#

. /etc/rc.subr
. /var/db/bacula/psql_env.sh

```

### bconsole access

To test that the catalog works correctly with the director we need to setup bconsole access.
Open the bacula director configuration file.

```
[root@stafbacula /usr/local/etc/bacula]# vim bacula-dir.conf
```

And defined and Password

```
Director {                            # define myself
  Name = MyBaculaDirector
  DIRport = 9101                # where we listen for UA connections
  QueryFile = "/usr/local/share/bacula/query.sql"
  WorkingDirectory = "/var/db/bacula"
  PidDirectory = "/var/run"
  Maximum Concurrent Jobs = 20
  Password = "*******"         # Console password
  Messages = Daemon
}
```

Open the bconsole configuration file

```
[root@stafbacula /usr/local/etc/bacula]# vi bconsole.conf
```

and setup the same password

```
# Bacula User Agent (or Console) Configuration File
#
# Copyright (C) 2000-2015 Kern Sibbald
# License: BSD 2-Clause; see file LICENSE-FOSS
#

Director {
  Name = MyBaculaDirector
  DIRport = 9101
  address = localhost
  Password = "*****"
}

```

### Start the director & test

Start the bacula-dir service 

```
root@stafbacula /usr/local/etc/bacula]# service bacula-dir start
Starting bacula_dir.
[root@stafbacula /usr/local/etc/bacula]# ps aux | grep -i bacula 
bacula 14416  0.0  0.1 51424 6588  -  SsJ  14:40   0:00.12 /usr/local/sbin/bacula-dir -u bacula -g bacula 
root   14420  0.0  0.0 14796 1968  0  R+J  14:40   0:00.00 grep -i bacula
root   13530  0.0  0.0  8300 1596  2  I+J  13:47   0:00.00 tail -f /var/log/bacula.log
[root@stafbacula /usr/local/etc/bacula]#

``` 

And test the console access

```
bacula@stafbacula:/usr/local/etc/bacula % bconsole
Connecting to Director localhost:9101
1000 OK: 102 MyBaculaDirector Version: 7.4.7 (16 March 2017)
Enter a period to cancel a command.
*version
MyBaculaDirector Version: 7.4.7 (16 March 2017) amd64-portbld-freebsd11.0 freebsd 11.0-RELEASE-p12 
You have messages.
*
```

In a next blog post we'll continue with the bacula configuration.

<p style="font-style: italic;">
Have fun!
</p>


# Links

* bacula manual: <a href="http://www.bacula.org/9.0.x-manuals/en/main/">http://www.bacula.org/9.0.x-manuals/en/main/</a>
* <a href="https://dan.langille.org/2015/01/10/bacula-on-freebsd-with-zfs/">https://dan.langille.org/2015/01/10/bacula-on-freebsd-with-zfs/</a>

 
