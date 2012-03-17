---
title: Premature C optimizations
layout: post
tags:
- c
---

If you are writing some really high performance C code. Or if you just like to do some premature C optimizations. Here's a gcc compiler buildin you can use:

{% highlight c %}
__builtin_expect((integer variable),(expected value))
{% endhighlight %}

Since CPU's prefetch instructions in a sequential way, jumps to other instructions will flush all prefetched instructions. Because of this it is better to only jump in the least expected case so the expected case can keep using the prefetched instructions.

This buildin allows you to hint the compiler about which case is more likely to happen. The return value of \_\_builtin_expect is the first argument passed to it. The expected value needs to be a compile-time constant.

Example usage:

{% highlight c %}
int example(int almostalwaysone) {
  if (__builtin_expect(almostalwaysone, 1)) {
    // most likely path
  } else {
    // least likely path
  }
}
{% endhighlight %}

This code will result in the assambly looking something like this:

{% highlight nasm %}
; almostalwaysone is placed in eax

  test   eax, eax
  je     .else
  ; if case
  ret
.else
  ; else case
  ret
{% endhighlight %}

As you can see the if case is execute sequentially while the else case requires a jump.

