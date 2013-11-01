---
title: All you need to know about SYN floods
layout: post
keywords: c tcp kernel syn cookies
description: A deep look into what causes the 'Possible SYN flooding on port ...' message.
---

SYN cookies
-----------

So one day I noticed `/var/log/syslog` on one of our servers was filled with the following message:
{% raw %}
<pre>
TCP: Possible SYN flooding on port 80. Sending cookies.
</pre>
{% endraw %}

This message can come a from a [SYN DDOS](http://en.wikipedia.org/wiki/SYN_flood), but in our case it was because of the amount of new connections one of our application was receiving.
The syslog message is emitted when the SYN backlog of a socket is full.

The [kernel documentation](https://github.com/torvalds/linux/blob/v2.6.38/Documentation/networking/ip-sysctl.txt#L422) has the following to say about SYN cookies:
{% raw %}
<pre>
Note, that syncookies is fallback facility.
It MUST NOT be used to help highly loaded servers to stand
against legal connection rate. If you see SYN flood warnings
in your logs, but investigation shows that they occur
because of overload with legal connections, you should tune
another parameters until this warning disappear.
See: tcp_max_syn_backlog, tcp_synack_retries, tcp_abort_on_overflow.

syncookies seriously violate TCP protocol, do not allow
to use TCP extensions, can result in serious degradation
of some services (f.e. SMTP relaying), visible not by you,
but your clients and relays, contacting you. While you see
SYN flood warnings in logs not being really flooded, your server
is seriously misconfigured.
</pre>
{% endraw %}

To fix this problem I started by increasing the `net.ipv4.tcp_max_syn_backlog` kernel parameter. On our Ubuntu system the default was 2048 so I changed it to 4096 and restarted our application.

Nothing changed and the flooding messages still kept being emitted.
I tried tuning some more parameters like `tcp_synack_retries` and `netdev_max_backlog` but nothing helped.
Finally a friend pointed out to me that I could be looking at the actual kernel source to find out why the message was still being emitted.

Going back to the source
------------------------

The obvious place to start this search was the function that actually emitted the message.

I found the function in [`net/ipv4/tcp_ipv4.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/tcp_ipv4.c#L799):
{% highlight cpp %}
static void syn_flood_warning(const struct sk_buff *skb)
{
  const char *msg;

#ifdef CONFIG_SYN_COOKIES
  if (sysctl_tcp_syncookies)
    msg = "Sending cookies";
  else
#endif
    msg = "Dropping request";

  pr_info("TCP: Possible SYN flooding on port %d. %s.\n",
        ntohs(tcp_hdr(skb)->dest), msg);
}
{% endhighlight %}

This function was only being called from one point, another function in [`net/ipv4/tcp_ipv4.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/tcp_ipv4.c#L1213):
{% highlight cpp %}
int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
{
  // ...

  if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
    if (net_ratelimit())
      syn_flood_warning(skb);

  // ...
}
{% endhighlight %}

This function is called every time a new connection is set up.
The `net_ratelimit()` is only there to prevent the syslog from being flooded with messages.
So I followed the `inet_csk_reqsk_queue_is_full()` function to see what caused it to return true.

The function is defined in [`include/net/inet_connection_sock.h`](https://github.com/torvalds/linux/blob/v2.6.38/include/net/inet_connection_sock.h#L289):
{% highlight cpp %}
static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
{
  return reqsk_queue_is_full(&inet_csk(sk)->icsk_accept_queue);
}
{% endhighlight %}

It simply calles another function in [`include/net/request_sock.h`](https://github.com/torvalds/linux/blob/v2.6.38/include/net/request_sock.h#L236):
{% highlight cpp %}
static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
{
  return queue->listen_opt->qlen >> queue->listen_opt->max_qlen_log;
}
{% endhighlight %}

So this is the actual check to see if the backlog is full.
At a first glance the function looks a bit strange.
The queue length is bit shifted by a max length variable.
`qlen` is an integer so shifting it to the left will decrease it's value.
`max_qlen_log` is a base 2 logarithm of the max queue length (which can only be a power of 2).
So when `qlen` is smaller than the maximum queue length all 1 bits will be shifted out and the return value will be 0. When `qlen` is larger it will still have bits set to 1 and the function will return a positive number.

So where is `max_qlen_log` set?

Size of the backlog
-------------------

Searching for an assignment of `max_qlen_log` I found only one place.

[`net/core/request_sock.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/core/request_sock.c#L38):
{% highlight cpp %}
int reqsk_queue_alloc(struct request_sock_queue *queue,
                      unsigned int nr_table_entries)
{
  // ...

  nr_table_entries = min_t(u32, nr_table_entries, sysctl_max_syn_backlog);
  nr_table_entries = max_t(u32, nr_table_entries, 8);
  nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);

  // ...

  for (lopt->max_qlen_log = 3;
       (1 << lopt->max_qlen_log) < nr_table_entries;
       lopt->max_qlen_log++);

  // ...
}
{% endhighlight %}

The `reqsk_queue_alloc()` function is called each time a new socket starts listening for connections.
As you can see from the code `max_qlen_log` will depend on the `nr_table_entries` argument.

First `nr_table_entries` is bound to the 8,`sysctl_max_syn_backlog` range.
This is the first sign of a kernel parameter, namely `net.ipv4.tcp_max_syn_backlog`, that I tried to tune.
Apparently it has some effect on the backlog size but it only specifies a maximum, not the actual value like many resources would have you believe.

`nr_table_entries` then it is incremented by 1 (which still seems strange to me, see below) and rounded to the nearest power of 2.
The for loop then sets `max_qlen_log` to the base 2 logarithm of `nr_table_entries`.

So from this function I found the maximum size of the backlog is bound by `net.ipv4.tcp_max_syn_backlog` but the actual size is determined by the `nr_table_entries` argument.
Time to find out where `reqsk_queue_alloc()` is called.

The only place it is called from is in [`net/ipv4/inet_connection_sock.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/inet_connection_sock.c#L621):
{% highlight cpp %}
int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
{
  // ...

  reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);

  // ...
}
{% endhighlight %}

The `inet_csk_listen_start()` function does nothing with the `nr_table_entries` argument and is itself called in [`net/ipv4/af_inet.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/af_inet.c#L192):
{% highlight cpp %}
int inet_listen(struct socket *sock, int backlog)
{
  // ...

  err = inet_csk_listen_start(sk, backlog);

  // ...
}
{% endhighlight %}

This function doesn't change the backlog size either. The function is not called directly in the source but is assign to a function pointer inside the `inet_stream_ops` struct in [`net/ipv4/af_inet.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/af_inet.c#L907).

The pointer in the struct is called in [`net/socket.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/socket.c#L1440):
{% highlight cpp %}
SYSCALL_DEFINE2(listen, int, fd, int, backlog)
{
  // ...

  int somaxconn;

  // ...

    somaxconn = sock_net(sock->sk)->core.sysctl_somaxconn;

    if ((unsigned)backlog > somaxconn)
      backlog = somaxconn;

    // ...

    sock->ops->listen(sock, backlog);

  // ...
}
{% endhighlight %}

Now this is the actual [`listen()` syscall](http://linux.die.net/man/2/listen) which has a backlog argument.
This function also seems to put an upper limit on the backlog size. `sock_net(sock->sk)->core.sysctl_somaxconn` is another kernel parameter controlled by `net.core.somaxconn`. It defaults to the [SOMAXCONN](https://github.com/torvalds/linux/blob/v2.6.38/include/linux/socket.h#L240) macro which equals 128 on our system.

128 is quite low so I increased it to 4096 as well. I restarted our application but to my supprise the flooding message still kept being emitted.

Lucky the application we are using is open source. So I opened up the source and found the application calling `listen()` with a backlog of again `SOMAXCONN`. After changing this to 1000000 (why not set it very high and let the kernel parameters limit it?), recompiling and restarting the application the message finally stopped.

*Note: kernel 3.3 does exactly the same as 2.6 (on which this post is based)*

A reasonably backlog size
-------------------------

In the [`reqsk_queue_alloc()`](https://github.com/torvalds/linux/blob/v2.6.38/net/core/request_sock.c#L38) function you can see an array of `request_sock *` pointers the size of `nr_table_entries` is allocated.
On a 64 bit system the size of the [request_sock](https://github.com/torvalds/linux/blob/v2.6.38/include/net/request_sock.h#L54) is 56 bytes. Plus the 8 bytes for the pointer makes it around 64 bytes per entry. So 4096 entries would only take up 0.25 MB. 4096 should be enough for most servers but you can see that increasing it even more wouldn't be a problem.

Keep in mind that setting the backlog to 4096 will actually make it 8192 entries big.
This because of the strange `+ 1` in `nr_table_entries = roundup_pow_of_two(nr_table_entries + 1);`.
This is the reason that software like [nginx](https://github.com/git-mirror/nginx/blob/master/src/os/unix/ngx_linux_config.h#L97), [redis](https://github.com/antirez/redis/blob/unstable/src/anet.c#L265) and [apache](http://httpd.apache.org/docs/2.0/mod/mpm_common.html#listenbacklog) all set the backlog to 511.

Conclusion
----------

The main thing I learned from this all is that using open source software allows you to track and fix problems that closed source software would not.

Also fixing the SYN flooding problem requires you to modify `net.ipv4.tcp_max_syn_backlog`, `net.core.somaxconn` and the backlog size passed to the `listen()` syscall.

