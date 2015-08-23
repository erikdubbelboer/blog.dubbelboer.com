---
published: true
title: sync.RWMutex vs atomic.Value vs unsafe.Pointer
layout: post
keywords: golang go sync RWMutex atomic Value unsafe Pointer
---

When using multiple goroutines you often want to have shared access of some read only resource. There are multiple ways to implements this. Three of them are; sync.RWMutex, atomic.Value and unsafe.Pointer.

sync.RWMutex is a whole mutex so I would expect that to be the slowest.

atomic.Value basically stores an interface\{\} value and makes sure that once assigned the type is never allowed to change.

And unsafe.Pointer is just a simple pointer on which we use the atomic.StorePointer and atomic.LoadPointer methods to get atomic access.

So when your code is simple and you know you are only storing one type using unsafe.Pointer instead of atomic.Value can be much faster.
Here are the benchmark results on my mac-book:

{% raw %}
<pre>
$ go test -bench .
BenchmarkPointer 200000000         7.76 ns/op
BenchmarkValue__  50000000          25.7 ns/op
BenchmarkRWMutex  100000000         22.6 ns/op
$ GOMAXPROCS=6 go test -bench .
BenchmarkPointer-6  100000000         11.9 ns/op
BenchmarkValue__-6  30000000          39.9 ns/op
BenchmarkRWMutex-6  5000000       302 ns/op
</pre>
{% endraw %}

The code:
{% highlight go %}
package main

import (
        "runtime"
        "sync"
        "sync/atomic"
        "testing"
        "unsafe"
)


func BenchmarkPointer(b *testing.B) {
        var ptr unsafe.Pointer

        m := make(map[int]int)
        m[1] = 2

        atomic.StorePointer(&ptr, unsafe.Pointer(&m))

        var wg sync.WaitGroup

        for g := 0; g < runtime.GOMAXPROCS(0); g++ {
                wg.Add(1)

                go func() {
                        for i := 0; i < b.N; i++ {
                                m := (*map[int]int)(atomic.LoadPointer(&ptr))
                                _ = (*m)[1]
                        }

                        wg.Done()
                }()
        }

        wg.Wait()
}


func BenchmarkValue__(b *testing.B) {
        var ptr atomic.Value

        m := make(map[int]int)
        m[1] = 2

        ptr.Store(m)

        var wg sync.WaitGroup

        for g := 0; g < runtime.GOMAXPROCS(0); g++ {
                wg.Add(1)

                go func() {
                        for i := 0; i < b.N; i++ {
                                m := ptr.Load().(map[int]int)
                                _ = m[1]

                        }

                        wg.Done()
                }()
        }

        wg.Wait()
}

func BenchmarkRWMutex(b *testing.B) {
        var l sync.RWMutex

        m := make(map[int]int)
        m[1] = 2

        var wg sync.WaitGroup

        for g := 0; g < runtime.GOMAXPROCS(0); g++ {
                wg.Add(1)

                go func() {
                        for i := 0; i < b.N; i++ {
                                l.RLock()
                                _ = m[1]
                                l.RUnlock()
                        }

                        wg.Done()
                }()
        }

        wg.Wait()
}
{% endhighlight %}



The [source of atomic.Value](https://github.com/golang/go/blob/8ca785621e7239b2f11ae2e02f00ef961241712f/src/sync/atomic/value.go#L20) nicely shows how interface\{\} is implemented:
{% highlight go %}
type ifaceWords struct {
        typ  unsafe.Pointer
        data unsafe.Pointer
}
{% endhighlight %}

