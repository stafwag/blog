---
layout: post
title: "Migrate from octopress to jekyll"
date: 2019-07-15 19:20:37 +0200
comments: true
categories: [ "blog", "octopress", "jekyll" ] 
excerpt_separator: <!--more-->
---

<img src="{{ '/images/octopress.png' | absolute_url  }}" class="left" width="227" height="227" alt="octopress_logo" />
I migrated [my blog](https://stafwag.github.io/blog) from [Octopress](http://octopress.org) to [Jekyll](https://jekyllrb.com). The primary reason is that octopress isn't maintained any more. I'm sure its great theme will live on in a lot of projects.

I like static webpage creators, they allow you to create nice websites without the need to have any code on the remote website. Anything that runs code has the possibility to be cracked, having a static website limit the [attack vectors](https://en.wikipedia.org/wiki/Vector_(malware)). You still need to protect the upload of the website and the system(s) that hosts your site of course.
<!--more-->

Octopress was/is based on Jekyll, so Jekyll seems to be the logical choice as my next website creator. My blog posts are written in [markdown](https://en.wikipedia.org/wiki/Markdown), this makes it easier to migrate to a new site creator.

There are a lot of Jekyll themes available, I'm not the greatest website designer so after reviewing a few themes I went with the [Minimal Mistakes](https://mademistakes.com/work/minimal-mistakes-jekyll-theme/) theme.
<img src="{{ '/images/jekyll.png' | absolute_url }}" class="right" width="452" height="230" alt="jekyll_logo" />
It has a nice layout and is very well [documented](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/).

The migration was straight-forward ... as simple as copying the blog posts markdown files to the new location.
Well kind of... There were a few pitfalls.

* **post layout**

Minimal Mistakes doesn't have a ```post``` layout, it has a ```single``` layout that is [recommended for posts](https://mmistakes.github.io/minimal-mistakes/docs/posts/).
But all my post markdown files had the ```layout: post``` directive set. I'd have removed this from all my blog posts but I created a [soft link](https://en.wikipedia.org/wiki/Symbolic_link) to get around this issue.

* **images**

Images - or the image location - are bit of a problem in markdown. I was using the custom [octopress img tag](http://octopress.org/docs/plugins/image-tag/). With the custom octopress img tag it was easy to get around the markdown image issue to get the correct path; I didn't needed to care about [absolute and relative paths](https://en.wikipedia.org/wiki/Path_(computing)#Absolute_and_relative_paths). In Jekyll and Octogress the ```baseurl``` is set in the site configuration file ```_config.yaml```. The custom img tag resolved it by added ```baseurl``` to the image path automatically.

This can be resolved with a ```relative_url``` pre-processed script.

{% raw %}
```{{ '/images/opnsense_out_of_inodes.jpg' | absolute_url }}```
{% endraw %}

So I create a few [sed](https://en.wikipedia.org/wiki/Sed) scripts to transfor the octopress img tags.

* **youtube**

I have a few links to youtube videos and was using a custom plugin for this. I replaced it plain markdown code.

{% raw %}
```[![jenkins build](https://img.youtube.com/vi/BNn9absXkE8/0.jpg)](https://www.youtube.com/watch?v=BNn9absXkE8)```
{% endraw %}

With the custom tags removed and few customizations, my new blog site was ready. Although I still spend a few hours on it...

***Have fun***

# Links

* [https://waher.se/Markdown.md](https://waher.se/Markdown.md)
* [http://octopress.org]([http://octopress.org)
* [https://jekyllrb.com](https://jekyllrb.com)
* [https://mademistakes.com/work/minimal-mistakes-jekyll-theme/](https://mademistakes.com/work/minimal-mistakes-jekyll-theme/) 
