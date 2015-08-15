---
published: true
title: Slice vs map for set in golang
layout: post
keywords: golang slice array map set struct
---

Ever wonder if it's faster to use a slice or map to represent a set in go? I wrote the following program to find out:

{% highlight go %}
package main

import (
  "fmt"
  "math/rand"
  "time"
)

const maxSize = 26
const tests = 20000000
const findMult = 9999999999 // 100 = 1% hit rate, 1 = 100% hit rate.

type lst []int

func (l lst) has(xxxx int) bool {
  for _, i := range l {
    if i == xxxx {
      return true
    }
  }
  return false
}

type mp map[int]struct{}

func (m mp) has(xxxx int) bool {
  _, ok := m[xxxx]
  return ok
}

func main() {
  rand.Seed(time.Now().UnixNano())

  for size := 1; size < maxSize; size++ {
    l := make(lst, 0, size)
    m := make(mp, size)
    for i := 0; i < size; i++ {
      e := rand.Int()
      l = append(l, e)
      m[e] = struct{}{}
    }

    found := 0
    start := time.Now()
    for x := 0; x < tests; x++ {
      xxxx := rand.Intn(size * findMult)
      if l.has(xxxx) {
        found++
      }
    }
    sliceDuration := time.Now().Sub(start)

    start = time.Now()
    for x := 0; x < tests; x++ {
      xxxx := rand.Intn(size * findMult)
      if m.has(xxxx) {
        found++
      }
    }
    mapDuration := time.Now().Sub(start)

    // Do something with found so it doesn't get optimized away.
    if found > 0 {
      rand.Int()
    }

    fmt.Printf("%d\t%v\n", size, sliceDuration-mapDuration)
  }
}
{% endhighlight %}

And here is the output:
{% raw %}
<pre>
$ ./bench.sh
1       -261.887532ms
2       -283.816189ms
3       -180.629338ms
4       -273.558558ms
5       -170.395637ms
6       -110.11527ms
7       -238.179383ms
8       -86.595302ms
9       -386.665905ms
10      -230.164293ms
11      -240.030718ms
12      -310.295027ms
13      -183.209792ms
14      -172.458055ms
15      -210.97313ms
16      -130.370425ms
17      -134.322002ms
18      37.839305ms
19      49.001029ms
20      35.248726ms
21      158.058773ms
22      231.8019ms
23      1.846585ms
24      39.449983ms
25      33.189299ms
</pre>
{% endraw %}

Conclusion
-----------

As you can see, for less than 18 elements a slice seems to be faster than a map.

Here is the resulting set that I wrote: [github.com/ErikDubbelboer/set](https://github.com/ErikDubbelboer/set)

The out of place timings you see around 7, 15 and 23 probably have to do with the [number of elements go stores per bucket](https://github.com/golang/go/blob/f9ed2f75c43cb8745a1593ec3e4208c46419216a/src/runtime/hashmap.go#L9). But I haven't had the time to look into this.

