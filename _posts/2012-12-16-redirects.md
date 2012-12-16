---
published: true
title: How many redirects do browsers follow
layout: post
keywords: 302 redirects browsers ie firefox chrome opera safari
---

Today I was wondering how many 302 redirects browsers would follow before stopping.
There are some posts about this but I couldn't find a source which was up to date and included all browsers. So I decided to make my own:

<table>
<tr><th style="width: 9em">Browser</th><th>Redirects</th></tr>
<tr><td>Firefox (6.0 - 18.0)</td><td>20</td></tr>
<tr><td>Chrome (22 - 23)</td><td>20</td></tr>
<tr><td>Opera (12)</td><td>20</td></tr>
<tr><td>Safari (6)</td><td>16</td></tr>
<tr><td>IE 6</td><td>100</td></tr>
<tr><td>IE 7</td><td>10</td></tr>
<tr><td>IE 8</td><td>10</td></tr>
<tr><td>IE 9</td><td>110</td></tr>
<tr><td>IE 10</td><td>110</td></tr>
</table>

And here's the little nodejs script I used to test this.

{% highlight javascript %}
var http = require('http');

http.createServer(function(request, response) {
  var n = parseInt(request.url.substr(2));

  if (isNaN(n)) {
    n = 0;
  }

  console.log(n);

  response.writeHead(302, {
    'Location'      : '?' + (n + 1),
    'Cache-Control' : 'no-cache, must-revalidate',
    'Expires'       : -1,
    'Connection'    : 'close'
  });

  response.end();
}).listen(12345);
{% endhighlight %}

