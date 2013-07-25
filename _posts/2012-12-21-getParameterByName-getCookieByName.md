---
published: true
title: getParameterByName() and getCookieByName()
layout: post
keywords: url parameter cookie parse javascript browser
---

When writing some code that should be as small as possible you don't want to include jQuery, MooTools or any other library.
These two functions are the functions that I miss most in this case, and I actually think these should implemented natively by the browsers.

`getParameterByName(name)` returns the value of the named url parameter.

`getCookieByName(name)` returns the value of the cookie with the specified name.

These functions work in: IE 6+, Firefox 6+, Chrome 22+, Safari 6+ and Opera 12+.


[getParameterByName](http://dubbelboer.com/erik-misc-code/getParameterByName/index.html)
==================

{% highlight javascript %}
function getParameterByName(name) {
  var res = new RegExp(
      // Parameter names always start after a ? or &.
      '[\?&]' +

      // Make sure any [ or ] are escaped in the name.
      name.replace(/\[/g, '\\\[').replace(/\]/g, '\\\]') +

      // Either match a =... or match an empty value.
      // Values can be terminated by an & a # or the end of the string ($).
      '(?:=([^&#]*))?(?:[&#]|$)'
  ).exec(window.location.search);

  return res ?
    (res[1] ? // res[1] will be undefined for a parameter without value.
      decodeURIComponent(res[1].replace(/\+/g, ' ')) : ''
    ) : null;
}
{% endhighlight %}


[getCookieByName](http://dubbelboer.com/erik-misc-code/getCookieByName/index.html)
===============

{% highlight javascript %}
function getCookieByName(name) {
  // According to RFC 2109 cookies can either be separated by ';' or ','.
  var res = new RegExp(
    // Beginning of the string or just after the previous cookie.
    // Skip the whitespace.
    '(?:^|[,;])\\s*' +

    name +

    // Value ending in a ';', ',' or the end of the string.
    '=([^,;]*)(?:[,;]|$)').exec(document.cookie);

  return res ? res[1] : null;
}
{% endhighlight %}

