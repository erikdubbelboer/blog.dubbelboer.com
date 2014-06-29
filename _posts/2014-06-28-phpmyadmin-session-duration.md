---
title: phpMyAdmin session duration
layout: post
keywords: phpmyadmin session cookie timeout duration
---

To increase the session duration in [phpMyAdmin](http://www.phpmyadmin.net/) you have to change 2 different settings. I'm mostly writing this post for myself because I always forget which two.


In `phpmyadmin/config.inc.php` you have to add:
{% highlight php %}
<?

$cfg['LoginCookieValidity'] = 60*60*24; // 1 day.
{% endhighlight %}


And in `/etc/php5/fpm/php.ini` you have to change:
{% highlight ini %}
session.gc_maxlifetime = 86400
{% endhighlight %}

If you don't change this setting it will be 1440 seconds by default and your phpMyAdmin session won't be able to last longer.

