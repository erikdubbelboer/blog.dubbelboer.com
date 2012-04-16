---
title: Posts
layout: default
---

{{ page.title }} [![RSS](/images/rss.png)](/atom.xml)
=====================================================

{% for post in site.posts %}

[{{ post.title }}]({{ post.url }}) (*{{ post.date | date_to_string }}*)

{% endfor %}

