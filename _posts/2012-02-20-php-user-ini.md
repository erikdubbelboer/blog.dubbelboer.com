---
title: PHP .user.ini
layout: post
keywords: php user ini
description: How to use the PHP .user.ini file.
---

A feature of PHP that many people don't seem to be aware of is the [.user.ini](http://php.net/manual/en/configuration.file.per-user.php) file.

This per directory configuration file can be very useful in combination with the following settings  

&nbsp;  

`auto_prepend_file`

If your application always includes a common include file you can also add it like this. In our applications we use a `auto_prepend_file = "autoloader.php"` which registers a class autoloader. This way we never have to include anything.  

&nbsp;  

`magic_quotes_gpc`

Setting this in the ini file allows you to control this setting per application. This can be useful if you are running some old and new applications on the same host.

