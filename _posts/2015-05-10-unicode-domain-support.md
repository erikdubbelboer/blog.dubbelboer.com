---
published: true
title: Unicode domain support in browsers
layout: post
keywords: firefox chrome ie safari dom referrer Unicode Punycode
---

According to [RFC 3492](http://tools.ietf.org/html/rfc3492) Unicode domains are encoded using [Punycode](http://en.wikipedia.org/wiki/Punycode). So [http://日本語.jp](http://日本語.jp) is actually [http://xn--wgv71a119e.jp](http://xn--wgv71a119e.jp)

I was interested in when browsers would use Unicode and when they would use Punycode. Here are the results of my tests:

| browser       | location bar | location.href | dom referrer | http referrer |
| ------------- | ------------ | ------------- | ------------ | ------------- |
| firefox 36    | Unicode      | Unicode       | ASCII        | ASCII         |
| safari  8.0.3 | Unicode      | ASCII         | ASCII        | ASCII         |
| chrome 41     | ASCII        | ASCII         | ASCII        | ASCII         |
| IE 9          | Unicode      | Unicode       | Unicode      | ASCII         |
| IE 11         | Unicode      | Unicode       | Unicode      | ASCII         |
| opera 12      | Unicode      | Unicode       | Unicode      | ASCII         |
| opera 28      | ASCII        | ASCII         | ASCII        | ASCII         |

