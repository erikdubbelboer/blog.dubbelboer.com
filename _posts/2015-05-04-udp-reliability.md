---
published: true
title: Cross datacenter UDP reliability
layout: post
keywords: UDP datacenter linux go golang
---

For an internal project I did some research into how reliable [UDP](https://en.wikipedia.org/wiki/User_Datagram_Protocol) really is. In our case each new packets would overwrite any old ones so missing a couple of packets would be no issue. With UDP it's technically also possible for packets to arrive in a different order. This would easily be detected by having an incrementing version counter and only accepting the packet if it has a higher version than the last one we had seen.

As described missing a couple of packets wouldn't be an issue as long as we don't miss to many. To test how reliable UDP really is I setup a test between one of our servers in London and one in Salt Lake City.

The following [Golang](https://golang.org/) code was run on the London side:
{% highlight go %}
package main

import (
	"encoding/binary"
	"log"
	"net"
)

func main() {
	addr, err := net.ResolveUDPAddr("udp", "0.0.0.0:9999")
	if err != nil {
		log.Panic(err)
	}

	conn, err := net.ListenUDP("udp", addr)
	if err != nil {
		log.Panic(err)
	}

	current := int64(0)

	buffer := make([]byte, 1500)
	for {   
		if n, err := conn.Read(buffer); err != nil {
			log.Print(err)
		} else if n != 1400 {
			log.Printf("only received %d bytes", n)
		} else {
			x := int64(binary.LittleEndian.Uint64(buffer))
			missed := x - current
			if missed != 1 {
				log.Printf("missed %d packets", x-current-1)
			}
			current = x
		}
	}
}
{% endhighlight %}

This Golang code was run on the Salt Lake City side:
{% highlight go %}
package main

import (
	"encoding/binary"
	"log"
	"net"
	"time"
)

func main() {
	raddr, err := net.ResolveUDPAddr("udp", "london-1:9999")
	if err != nil {
		log.Panic(err)
	}

	laddr, err := net.ResolveUDPAddr("udp", "0.0.0.0:0")
	if err != nil {
		log.Panic(err)
	}

	conn, err := net.ListenUDP("udp", laddr)
	if err != nil {
		log.Panic(err)
	}

	current := int64(1)
	buffer := make([]byte, 1400)

	for {   
		binary.LittleEndian.PutUint64(buffer[:8], uint64(current))

		if n, err := conn.WriteToUDP(buffer, raddr); err != nil {
			log.Print(err)
		} else if n != len(buffer) {
			log.Printf("only %d bytes written", n)
		}

		current++

		time.Sleep(time.Millisecond * 500)
	}
}
{% endhighlight %}


I ran the two programs for multiple days. At the end of this post you can see the raw output. Below is a small table showing how many packets were missed per day:

{% raw %}
<pre>
day - misses
15  - 10
16  - 1
17  - 4
18  - 0
19  - 0
20  - 343
21  - 5
</pre>
{% endraw %}

I did not expect the connection to be this stable. With 172.800 packets being send per day a loss of less than 10 packets (0,005%) is quite good and very usable. But what happened on the 20th shows where UDP is a problem. I did not notice on the day it self so I could not do any research, but my guess is that one or more of the networks between the servers had a higher usage than usual. This resulted in a lot of packets being dropped that day. Using TCP would probably have resulted in either the packets not being dropped or at least retried. My next test will be to run a TCP connection next to UDP to it to see if the TCP connection keeps being reliable while UDP fails.

My conclusion from this test was that UDP was almost reliable enough. We ended up using UDP for light frequent updates while using TCP for periodic slower updates.


Raw output:
{% raw %}
<pre>
2015/03/15 07:37:39 missed 1 packets
2015/03/15 07:43:42 missed 1 packets
2015/03/15 14:41:59 missed 1 packets
2015/03/15 14:42:32 missed 1 packets
2015/03/15 14:44:37 missed 1 packets
2015/03/15 14:49:15 missed 1 packets
2015/03/15 14:49:17 missed 1 packets
2015/03/15 14:49:19 missed 1 packets
2015/03/15 14:50:04 missed 1 packets
2015/03/15 15:40:02 missed 1 packets
2015/03/16 20:11:26 missed 1 packets
2015/03/17 10:58:57 missed 3 packets
2015/03/17 10:58:58 missed 1 packets
2015/03/20 06:46:25 missed 169 packets
2015/03/20 06:47:12 missed 8 packets
2015/03/20 06:47:32 missed 10 packets
2015/03/20 06:48:00 missed 33 packets
2015/03/20 06:48:27 missed 7 packets
2015/03/20 06:48:53 missed 14 packets
2015/03/20 06:49:14 missed 16 packets
2015/03/20 06:49:37 missed 15 packets
2015/03/20 06:50:11 missed 3 packets
2015/03/20 07:51:16 missed 10 packets
2015/03/20 14:43:35 missed 7 packets
2015/03/20 14:46:41 missed 4 packets
2015/03/20 15:14:05 missed 9 packets
2015/03/20 15:14:32 missed 11 packets
2015/03/20 15:14:50 missed 11 packets
2015/03/20 15:15:50 missed 3 packets
2015/03/20 15:16:37 missed 8 packets
2015/03/20 16:07:16 missed 1 packets
2015/03/20 16:07:18 missed 1 packets
2015/03/20 16:07:43 missed 1 packets
2015/03/20 16:07:45 missed 2 packets
2015/03/21 05:24:25 missed 3 packets
2015/03/21 07:37:53 missed 1 packets
2015/03/21 09:49:08 missed 2 packets
</pre>
{% endraw %}

