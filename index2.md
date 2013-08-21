---
title: Posts
layout: default
---

{{ page.title }} [![RSS](/images/rss.png)](/atom.xml)
=====================================================

<table style="width: 100%">
{% for post in site.posts %}
<tr>
<td>
<a href="{{ post.url }}">{{ post.title }}</a>
</td>
<td>
(*{{ post.date | date_to_string }}*)
</td>
</tr>
{% endfor %}
</table>

