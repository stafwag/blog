---
layout: post
title: "Bacula on FreeBSD (part 1 PostgresSQL in a jail)"
date: 2017-08-06 08:43:28 +0200
comments: true
categories: [ bacula, freebsd, backup, postgresql ]
---

I do take backups; my current solution are couple of shell script wrapper around dump/zfs send/btrfs send/rsync which is a mess.
So decided give <a href="http://www.bacula.org/">bacula</a> a try 


I use <a href="http://erdgeist.org/arts/software/ezjail/">ezjail</a> to manage my <a href="https://en.wikipedia.org/wiki/FreeBSD_jail">FreeBSD jails</a>. <a href="https://www.postgresql.org/">PostgresSQL</a> is my favorite database and will use this database as the backend for bacula  and will use this database as the backend for bacula. I want to move all my databases to 1 FreeBSD jail this should make the easier to create reliable database backup in the further. For this reason we'll setup 2 FreeBSD jails 1 for the database and 1 for bacula.

You'll find my journey of installing PostgreSQL on a FreeBSD jail. In another blog post we will continue with the installation of bacula.


## PostgreSQL

### Jail

#### Create the PostgreSQL Jail

```
root@rataplan:~ # ezjail-admin create stafdb "em0|192.168.1.51"
Warning: Some services already seem to be listening on all IP, (including 192.168.1.51)
  This may cause some confusion, here they are:
root     ntpd       754   20 udp6   *:123                 *:*
root     ntpd       754   21 udp4   *:123                 *:*
root     rpc.statd  717   4  udp6   *:640                 *:*
root     rpc.statd  717   5  tcp6   *:640                 *:*
root     rpc.statd  717   6  udp4   *:640                 *:*
root     rpc.statd  717   7  tcp4   *:640                 *:*
root     nfsd       713   5  tcp4   *:2049                *:*
root     nfsd       713   6  tcp6   *:2049                *:*
root     mountd     707   5  udp6   *:753                 *:*
root     mountd     707   6  tcp6   *:753                 *:*
root     mountd     707   7  udp4   *:753                 *:*
root     mountd     707   8  tcp4   *:753                 *:*
root     rpcbind    676   6  udp6   *:111                 *:*
root     rpcbind    676   7  udp6   *:847                 *:*
root     rpcbind    676   8  tcp6   *:111                 *:*
root     rpcbind    676   9  udp4   *:111                 *:*
root     rpcbind    676   10 udp4   *:766                 *:*
root     rpcbind    676   11 tcp4   *:111                 *:*
root     syslogd    657   6  udp6   *:514                 *:*
root     syslogd    657   7  udp4   *:514                 *:*
root@rataplan:~ # 
```

#### PostgreSQL requires shared memory

PostgreSQL uses shared memory it's required to set "allow.sysvipc=1" for the jail. I don't want to enable this globaly since this might be a security risk. Shared memory has permissions set based on the uid enabling sysvipc on a jail might cause the jail to read shared memory from the host system or another jail.

To enable "allow.sysvipc=1" a jail we can update the ezjail configuration. Ezjail keep the jail configuration in /usr/local/etc/ezjail 

```
root@rataplan:~ # cd /usr/local/etc/ezjail
root@rataplan:/usr/local/etc/ezjail # ls
stafansible     staffs          stafproxy       staftestbuild
stafdb          stafmail        stafpuppet
root@rataplan:/usr/local/etc/ezjail # 
```

Open the database jail file and update the configuration.

```
root@rataplan:/usr/local/etc/ezjail # vi stafdb
```

```
#
# Required to run PostgeSQL in the jail
#

export jail_stafdb_parameters="allow.sysvipc=1"
```

#### Start the database jail

```
root@rataplan:~ # ezjail-admin start stafdb
Starting jails: stafdb.
/etc/rc.d/jail: WARNING: Per-jail configuration via jail_* variables  is obsolete.  Please consider migrating to /etc/jail.conf.
root@rataplan:~ #
```

#### Console access

```
root@rataplan:~ # ezjail-admin console stafdb
FreeBSD 11.0-RELEASE-p9 (GENERIC) #0: Tue Apr 11 08:48:40 UTC 2017

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
root@stafdb:~ # 
root@stafdb:~ # 
```

### ProgreSQL installation

#### Install pkg

Set up dns

```
root@stafdb:~ # vi /etc/resolv.conf
```

```
nameserver 192.168.1.1
```

Bootstrap pkg

```
root@stafdb:~ # pkg
The package management tool is not yet installed on your system.
Do you want to fetch and install it now? [y/N]: y
Bootstrapping pkg from pkg+http://pkg.FreeBSD.org/FreeBSD:11:amd64/quarterly, please wait...
Verifying signature with trusted certificate pkg.freebsd.org.2013102301... done
[stafdb] Installing pkg-1.10.1...
[stafdb] Extracting pkg-1.10.1: 100%
pkg: not enough arguments
Usage: pkg [-v] [-d] [-l] [-N] [-j <jail name or id>|-c <chroot path>|-r <rootdir>] [-C <configuration file>] [-R <repo config dir>] [-o var=value] [-4|-6] <command> [<args>]

For more information on available commands and options see 'pkg help'.
root@stafdb:~ # 
```

#### Install PostgreSQL

Search for the latest PostgreSQL server version.

```
root@stafdb:~ # pkg search postgresql | grep server
pgtcl-postgresql92-2.0.0_1     TCL extension for accessing a PostgreSQL server (PGTCL-NG)
pgtcl-postgresql93-2.0.0_1     TCL extension for accessing a PostgreSQL server (PGTCL-NG)
pgtcl-postgresql94-2.0.0_1     TCL extension for accessing a PostgreSQL server (PGTCL-NG)
pgtcl-postgresql95-2.0.0_1     TCL extension for accessing a PostgreSQL server (PGTCL-NG)
pgtcl-postgresql96-2.0.0_1     TCL extension for accessing a PostgreSQL server (PGTCL-NG)
postgresql92-server-9.2.21_1   PostgreSQL is the most advanced open-source database available anywhere
postgresql93-server-9.3.17_1   PostgreSQL is the most advanced open-source database available anywhere
postgresql94-server-9.4.12_1   PostgreSQL is the most advanced open-source database available anywhere
postgresql95-server-9.5.7_1    PostgreSQL is the most advanced open-source database available anywhere
postgresql96-server-9.6.3_1    PostgreSQL is the most advanced open-source database available anywhere
root@stafdb:~ # 
```

Install the PostgreSQL package.

```
root@stafdb:~ # pkg install postgresql96-server
Updating FreeBSD repository catalogue...
FreeBSD repository is up to date.
All repositories are up to date.
The following 8 package(s) will be affected (of 0 checked):

New packages to be INSTALLED:
        postgresql96-server: 9.6.3_1
        libxml2: 2.9.4
        icu: 58.2_2,1
        gettext-runtime: 0.19.8.1_1
        indexinfo: 0.2.6
        postgresql96-client: 9.6.3_2
        perl5: 5.24.1_1
        readline: 7.0.3

Number of packages to be installed: 8

The process will require 131 MiB more space.
30 MiB to be downloaded.

Proceed with this action? [y/N]: y
[stafdb] [1/8] Fetching postgresql96-server-9.6.3_1.txz: 100%    4 MiB 357.1kB/s    00:11    
[stafdb] [2/8] Fetching libxml2-2.9.4.txz: 100%  802 KiB 410.4kB/s    00:02    
[stafdb] [3/8] Fetching icu-58.2_2,1.txz: 100%    9 MiB 313.3kB/s    00:30    
[stafdb] [4/8] Fetching gettext-runtime-0.19.8.1_1.txz: 100%  147 KiB 151.0kB/s    00:01    
[stafdb] [5/8] Fetching indexinfo-0.2.6.txz: 100%    5 KiB   5.3kB/s    00:01    
[stafdb] [6/8] Fetching postgresql96-client-9.6.3_2.txz: 100%    2 MiB 300.0kB/s    00:08    
[stafdb] [7/8] Fetching perl5-5.24.1_1.txz: 100%   13 MiB 341.5kB/s    00:41    
[stafdb] [8/8] Fetching readline-7.0.3.txz: 100%  334 KiB 342.3kB/s    00:01    
Checking integrity... done (0 conflicting)
[stafdb] [1/8] Installing indexinfo-0.2.6...
[stafdb] [1/8] Extracting indexinfo-0.2.6: 100%
[stafdb] [2/8] Installing gettext-runtime-0.19.8.1_1...
[stafdb] [2/8] Extracting gettext-runtime-0.19.8.1_1: 100%
[stafdb] [3/8] Installing perl5-5.24.1_1...
[stafdb] [3/8] Extracting perl5-5.24.1_1: 100%
[stafdb] [4/8] Installing readline-7.0.3...
[stafdb] [4/8] Extracting readline-7.0.3: 100%
[stafdb] [5/8] Installing libxml2-2.9.4...
[stafdb] [5/8] Extracting libxml2-2.9.4: 100%
[stafdb] [6/8] Installing icu-58.2_2,1...
[stafdb] [6/8] Extracting icu-58.2_2,1: 100%
[stafdb] [7/8] Installing postgresql96-client-9.6.3_2...
[stafdb] [7/8] Extracting postgresql96-client-9.6.3_2: 100%
[stafdb] [8/8] Installing postgresql96-server-9.6.3_1...
===> Creating groups.
Creating group 'postgres' with gid '770'.
===> Creating users
Creating user 'postgres' with uid '770'.

  =========== BACKUP YOUR DATA! =============
  As always, backup your data before
  upgrading. If the upgrade leads to a higher
  minor revision (e.g. 8.3.x -> 8.4), a dump
  and restore of all databases is
  required. This is *NOT* done by the port!
  ===========================================
[stafdb] Extracting postgresql96-server-9.6.3_1: 100%
Message from perl5-5.24.1_1:
The /usr/bin/perl symlink has been removed starting with Perl 5.20.
For shebangs, you should either use:

#!/usr/local/bin/perl

or

#!/usr/bin/env perl

The first one will only work if you have a /usr/local/bin/perl,
the second will work as long as perl is in PATH.
Message from postgresql96-client-9.6.3_2:
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
Message from postgresql96-server-9.6.3_1:
For procedural languages and postgresql functions, please note that
you might have to update them when updating the server.

If you have many tables and many clients running, consider raising
kern.maxfiles using sysctl(8), or reconfigure your kernel
appropriately.

The port is set up to use autovacuum for new databases, but you might
also want to vacuum and perhaps backup your database regularly. There
is a periodic script, /usr/local/etc/periodic/daily/502.pgsql, that
you may find useful. You can use it to backup and perform vacuum on all
databases nightly. Per default, it performs `vacuum analyze'. See the
script for instructions. For autovacuum settings, please review
~pgsql/data/postgresql.conf.

If you plan to access your PostgreSQL server using ODBC, please
consider running the SQL script /usr/local/share/postgresql/odbc.sql
to get the functions required for ODBC compliance.

Please note that if you use the rc script,
/usr/local/etc/rc.d/postgresql, to initialize the database, unicode
(UTF-8) will be used to store character data by default.  Set
postgresql_initdb_flags or use login.conf settings described below to
alter this behaviour. See the start rc script for more info.

To set limits, environment stuff like locale and collation and other
things, you can set up a class in /etc/login.conf before initializing
the database. Add something similar to this to /etc/login.conf:
---
postgres:\
        :lang=en_US.UTF-8:\
        :setenv=LC_COLLATE=C:\
        :tc=default:
---
and run `cap_mkdb /etc/login.conf'.
Then add 'postgresql_class="postgres"' to /etc/rc.conf.

======================================================================

To initialize the database, run

  /usr/local/etc/rc.d/postgresql initdb

You can then start PostgreSQL by running:

  /usr/local/etc/rc.d/postgresql start

For postmaster settings, see ~pgsql/data/postgresql.conf

NB. FreeBSD's PostgreSQL port logs to syslog by default
    See ~pgsql/data/postgresql.conf for more info

======================================================================

To run PostgreSQL at startup, add
'postgresql_enable="YES"' to /etc/rc.conf
```

Enable the postgresql daemon at the jail startup

```
root@stafdb:~ # sysrc postgresql_enable="YES"
postgresql_enable:  -> YES
root@stafdb:~ # grep postgresql_enable /etc/rc.conf
postgresql_enable="YES"
root@stafdb:~ # 
```

Initialize the database

```
root@stafdb:~ # service postgresql initdb
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "C".
The default text search configuration will be set to "english".

Data page checksums are disabled.

creating directory /var/db/postgres/data96 ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... ok
syncing data to disk ... ok

WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    /usr/local/bin/pg_ctl -D /var/db/postgres/data96 -l logfile start

root@stafdb:~ # 
```

Start the database

```
Droot@stafdb:~ # service postgresql start
LOG:  could not create IPv6 socket: Protocol not supported
LOG:  ending log output to stderr
HINT:  Future log output will go to log destination "syslog".
root@stafdb:~ # 
```

Verify the database

```
root@stafdb:~ # su - postgres                                                                                                   
$ psql -l                                                                                                                       
psql: could not connect to server: No such file or directory                                                                    
        Is the server running locally and accepting                                                                             
        connections on Unix domain socket "/tmp/.s.PGSQL.5432"?                                                                 
$ ^Droot@stafdb:~ # service postgresql start
LOG:  could not create IPv6 socket: Protocol not supported                                                                      
LOG:  ending log output to stderr                                                                                               
HINT:  Future log output will go to log destination "syslog".                                                                   
root@stafdb:~ # su - postgres
$ psql -l
                             List of databases
   Name    |  Owner   | Encoding | Collate | Ctype |   Access privileges   
-----------+----------+----------+---------+-------+-----------------------
 postgres  | postgres | UTF8     | C       | C     | 
 template0 | postgres | UTF8     | C       | C     | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
 template1 | postgres | UTF8     | C       | C     | =c/postgres          +
           |          |          |         |       | postgres=CTc/postgres
(3 rows)

$ 
```

<p style="font-style: italic;">
Have fun!
</p>


# Links

* https://dan.langille.org/2015/01/10/bacula-on-freebsd-with-zfs/
* https://cwharton.com/blog/2016/10/postgresql-and-freebsd-quick-start/
* https://dan.langille.org/2013/07/09/fatal-could-not-create-shared-memory-segment-function-not-implemented/
