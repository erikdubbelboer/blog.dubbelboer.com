---
title: sync.Pool vs chan pool
layout: post
keywords: go golang sync Pool chan benchmark
---

For anyone like me wanting to relieve some stress on the garbage collector and wondering if they should use <a href="https://golang.org/pkg/sync/#Pool" target="_blank">sync.Pool</a> or use a buffered chan. Wonder no more, here is a simple benchmark to show the difference:

<pre>
BenchmarkNoPool-4   3000000000          21.4 ns/op         8 B/op        1 allocs/op
BenchmarkSyncPool-4 3000000000          25.9 ns/op         0 B/op        0 allocs/op
BenchmarkChanPool-4 300000000           266  ns/op         0 B/op        0 allocs/op
</pre>

As you can see sync.Pool is clearly the winner and is only a little bit slower than no pool.

And here is the code:

{% highlight go %}
package test

import (
	"sync"
	"testing"
)

type somestruct struct {
	x int
}

var g *somestruct

// No pool

func BenchmarkNoPool(b *testing.B) {
	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			x := &somestruct{}
			g = x
		}
	})
}

// sync.Pool

func BenchmarkSyncPool(b *testing.B) {
	p := sync.Pool{
		New: func() interface{} {
			return &somestruct{}
		},
	}

	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			x := p.Get().(*somestruct)
			g = x
			p.Put(x)
		}
	})
}

// Channel pool

type Pool struct {
	New func() interface{}

	pool chan interface{}
}

func NewPool(n func() interface{}) Pool {
	p := Pool{
		New: n,
		pool: make(chan interface{}, 1024),
	}

	return p
}

func (p Pool) Get() interface{} {
	select {
	case o := <-p.pool:
		return o
	default:
		return p.New()
	}
}

func (p Pool) Put(o interface{}) {
	select {
	case p.pool <- o:
	default:
	}
}

func BenchmarkChanPool(b *testing.B) {
	p := NewPool(func() interface{} {
		return &somestruct{}
	})

	b.RunParallel(func(pb *testing.PB) {
		for pb.Next() {
			x := p.Get().(*somestruct)
			g = x
			p.Put(x)
		}
	})
}
{% endhighlight %}

