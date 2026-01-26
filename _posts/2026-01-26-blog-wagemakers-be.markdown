---
layout: post
title: Moved my blog to [blog.wagemakers.be](https://blog.wagemakers.be)
date: 2026-01-26 18:26 +0100
comments: true
categories: [ "jekell",  "hugo", "github", "blog", "html", "disquss", "rss" ]
excerpt_separator: <!--more-->
---

<strong>
If you follow my blog posts with an RSS reader, update the rss feed to: [https://blog.wagemakers.be/atom.xml ](https://blog.wagemakers.be/atom.xml) <br /> ...If you want to continue to follow me off-course ;-)
</strong>

I moved my blog from GitHub to my own hosting ( powered by [Procolix](https://procolix.eu) ).<br />
Procolix sponsored my hosting for 20 years, till I decided to start my company [Mask27.dev](https://mask27.dev).

One reason is that Microsoft seems to like to put “copilot everywhere”, including on repositories hosted on github. While I don’t dislike AI ( artificial intelligence ), LLM ( Large Language Models ) are a nice piece of technology. The security, privacy, and other issues are overlooked or even just ignored.

The migration was a bit more complicated as usual, as nothing “is easy” ;-)

You’ll find the pitfalls of moving my blog below as they might be useful for somebody else ( including the future me ).

<!--more-->

# Html redirect

I use [Jekyll](https://jekyllrb.com/) to generate my webpages on my blog. I might switch to [HUGO](https://gohugo.io/) in the future.

While there're Jekyll plugins available to preform a redirect, I decide to keep it simple and added a http header to ```_includes/head.html```

```
<meta http-equiv="refresh" content="0; url=https://blog.wagemakers.be{{ page.url }}" />
```

# Hardcoded links

I had some hardcoded links for ```image```, ```url```, etc on my blog posts.

I used the script below to update the links in my ```_post``` directory.

```bash
#!/bin/sh

set -o errexit
set -o pipefail
set -o nounset

for file in *; do

  echo "... Processing file: ${file}"

  sed -i ${file} -e s@https://stafwag.github.io/blog/blog/@https://blog.wagemakers.be/blog/@g
  sed -i ${file} -e s@https://stafwag.github.io/blog/images/@https://blog.wagemakers.be/images/@g
  sed -i ${file} -e s@\(https://stafwag.github.io/blog\)@\(https://blog.wagemakers.be\)@

done
```

# Disqus

I use [DISQUS](https://disqus.com/) as the comment system on my blog. As the HTML pages got a proper redirect, I could ask Disqus to reindex the pages so the old comments became available again.

More information is available at: [https://help.disqus.com/en/articles/1717126-redirect-crawler](https://help.disqus.com/en/articles/1717126-redirect-crawler)

Without a redirect, you can download the URL in a csv and add a migration URL to the csv file and upload it to Disqus. You can find information about it in the link below.

[https://help.disqus.com/en/articles/1717129-url-mapper](https://help.disqus.com/en/articles/1717129-url-mapper)

# RSS redirect

I didn’t find a good way to redirect for RSS feeds, which RSS readers use correctly.<br />
If you know a good way to handle it, please let me know.

I tried to add an XML redirect as suggested at: [https://www.rssboard.org/redirect-rss-feed](https://www.rssboard.org/redirect-rss-feed).
But this doesn't seem to work with the RSS readers I tested (NewsFlash, Akregator).

These are the steps I took.

## HTML header

I added the following headers to ```_includes/head.html```

```
{% raw %}<link rel="self" type="application/atom+xml"  href="{{ site.url }}{{ site.baseurl }}/atom.xml" />{% endraw %}
<link rel="alternate" type="application/atom+xml" title="Wagemakers Atom Feed" href="https://wagemakers.be/atom.xml">


{% raw %}<<link rel="self" type="application/rss+xml"  href="{{ site.url }}{{ site.baseurl }}/atom.xml" />{% endraw %}
<link rel="alternate" type="application/rss+xml" title="Wagemakers Atom Feed" href="https://wagemakers.be/atom.xml">
```

## Custom feed.xml

When I switched from [Octopress](http://octopress.org/) to “plain jekyll” I started to use the ```jekyll-feed ```plugin. But I still had the old RSS page from Octopress available, so I decided to use it to generate ```atom.xml``` and ```feed.xml``` in the ```link rel=self``` and ```link rel="alternate"``` directives.

Full code below or on GitHub: [https://github.com/stafwag/blog/blob/gh-pages/feed.xml](https://github.com/stafwag/blog/blob/gh-pages/feed.xml)
 
```
---
layout: null
---
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">



  <title><![CDATA[{{ site.title | cdata_escape }}]]></title>
  <link href="{{ site.url }}{{ site.baseurl }}/atom.xml" rel="self"/>
  <link rel="alternate" href="https://blog.wagemakers.be/atom.xml" /> <link href="https://blog.wagemakers.be }}"/>
  <link rel="self" type="application/atom+xml" href="{{ site.url }}{{ site.baseurl }}/atom.xml" />
  <link rel="alternate" type="application/atom+xml" href="https://blog.wagemakers.be/atom.xml" />
  <link rel="self" type="application/rss+xml" href="{{ site.url }}{{ site.baseurl }}/atom.xml" />
  <link rel="alternate" type="application/rss+xml" href="https://blog.wagemakers.be/atom.xml" />
  <updated>{{ site.time | date_to_xmlschema }}</updated>
  <id>{{ site.url }}</id>
  <author>
    <name><![CDATA[{{ site.author.name | strip_html }}]]></name>
    {% if site.email %}<email><![CDATA[{{ site.email }}]]></email>{% endif %}
  </author>
  <generator uri="http://octopress.org/">Octopress</generator>

{% raw %}{% for post in site.posts limit: 10000 %}{% endraw %}
  <entry>
{% raw %}<title type="html"><![CDATA[{% if site.titlecase %}{{ post.title | titlecase | cdata_escape }}{% else %}{{ post.title | cdata_escape }}{% endif %}]]></title>{% endraw %}
{% raw %} <link href="{{ site.url }}{{ site.baseurl }}{{ post.url }}"/>{% endraw %}
    <updated>{{ post.date | date_to_xmlschema }}</updated>
    <id>{{ site.url }}{{ site.baseurl }}{{ post.id }}</id>
    <content type="html"><![CDATA[{{ post.content | cdata_escape }}]]></content>
  </entry>
{% raw %}{% endfor %}{% endraw %}
</feed>
```

# Notify users

I created this blog post to notify the users ;-)

***Have fun!***

# Links

* [https://help.disqus.com/en/articles/1717129-url-mapper](https://help.disqus.com/en/articles/1717129-url-mapper)
* [https://help.disqus.com/en/articles/1717126-redirect-crawler](https://help.disqus.com/en/articles/1717126-redirect-crawler)
* [https://www.heerentanna.com/blog/move-disqus-comment-old-url-new.html](https://www.heerentanna.com/blog/move-disqus-comment-old-url-new.html)
* [https://www.rssboard.org/redirect-rss-feed](https://www.rssboard.org/redirect-rss-feed)
