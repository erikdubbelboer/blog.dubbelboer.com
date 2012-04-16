---
title: V8 performance inside try/catch
layout: post
keywords: nodejs javascript optimize v8
---

I have learned recently that V8, the javascript engine behind nodejs can't optimize inside a try/catch block. Just look at the running times of the next two examples:

{% highlight js %}
function test() {
  try {
    for (var i = 0; i < 1000000000; ++i) {
      if (i % 2) {
        ;
      }
    }
  } catch (e) {
  }
}

test();
{% endhighlight %}

This example takes on average `9` seconds to complete.


{% highlight js %}
function test() {
  for (var i = 0; i < 1000000000; ++i) {
    if (i % 2) {
      ;
    }
  }
}

try {
  test();
} catch (e) {
}
{% endhighlight %}

While this very similar example takes an average of `1.7` seconds to complete.


{% highlight js %}
function test() {
  for (var i = 0; i < 1000000000; ++i) {
    try {
      if (i % 2) {
        ;
      }
    } catch (e) {
    }
  }
}

test();
{% endhighlight %}

Setting up a try/catch frame is also very expensive as can be seen by this example taking an average of `11` seconds.

