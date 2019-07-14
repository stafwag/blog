---
layout: post
title: "CGIpaf uploaded to github"
date: 2013-03-16 11:57
comments: true
categories: git cgipaf cvs
---
I finally converted the <a href="http://www.wagemakers.be/english/programs/cgipaf">cgipaf</a> cvs repository to <a href="https://github.com/stafwag/cgipaf">github</a>.

I used <a href="http://cvs2svn.tigris.org/cvs2git.html">cvs2git</a>
It took a bit longer than expected.

My first attempt didn't had the release tags right.

Adding <code>--retain-conflicting-attic-files</code> to cvs2git resolved this issue.

You'll find how I did it it below.

### cvs2git.sh:

```
cvs2git \
    --blobfile=cvs2git-tmp/git-blob.dat \
    --dumpfile=cvs2git-tmp/git-dump.dat \
    /var/lib/cvs/cgipaf \
    --username=staf \
    --retain-conflicting-attic-files
```

### create local git:

```
$ mkdir ~/newgit
$ cd ~/newgit
$ mkdir cgipaf
$ cd cgipaf
$ git init
Initialized empty Git repository in /home/staf/newgit/cgipaf/
$ 
```

### import.sh:

```
#!/bin/bash

git fast-import --export-marks=/home/staf/cvs2git-tmp/cvs2git-marks.dat < /home/staf/cvs2git-tmp/git-blob.dat
git fast-import --import-marks=/home/staf/cvs2git-tmp/cvs2git-marks.dat < /home/staf/cvs2git-tmp/git-dump.dat
```

### push to github:

```
git remote add origin git@github.com:stafwag/cgipaf.git
git push origin --mirror

```

