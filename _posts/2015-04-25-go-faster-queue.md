---
title: Faster queues in Go
layout: post
keywords: golang go queue slice memory ring buffer
---

In my [previous post](/2015/04/06/go-queue.html) I tested the implementation of a queue in Go.
As I noted in the post I was a bit surprised at how in Go you don't need a ring buffer to implement a queue.
Today for comparison I also implemented the same queue using a ring buffer in Go.
The result surprised me. The ring version seems to be more than twice as fast and uses less memory:

<pre>
BenchmarkSliceAdd       20000000                42.2 ns/op            41 B/op          0 allocs/op
BenchmarkRingAdd        30000000                23.5 ns/op            17 B/op          0 allocs/op
BenchmarkSliceRemove    10000000                92.8 ns/op            16 B/op          0 allocs/op
BenchmarkRingRemove     20000000                37.6 ns/op             0 B/op          0 allocs/op
</pre>

The <a target='_blank' href='https://github.com/ErikDubbelboer/ringqueue/blob/master/ringqueue.go'>code for the queue</a> and some tests can be found in this Github repository: <a target='_blank' href='https://github.com/ErikDubbelboer/ringqueue'>https://github.com/ErikDubbelboer/ringqueue</a>

