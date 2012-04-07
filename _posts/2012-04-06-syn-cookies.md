---
published: false
title: All you need to know about SYN cookies
layout: post
keywords: c tcp kernel syn cookies
---

Busy servers

/var/log/syslog

<pre>
TCP: Possible SYN flooding on port 80. Sending cookies.
</pre>

[tcp_syncookies](https://github.com/torvalds/linux/blob/v2.6.38/Documentation/networking/ip-sysctl.txt#L422)

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



[`net/ipv4/tcp_ipv4.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/tcp_ipv4.c#L799)
{% highlight c %}
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

[`net/ipv4/tcp_ipv4.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/tcp_ipv4.c#L1213)
{% highlight c %}
int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
{
  // ...

  if (inet_csk_reqsk_queue_is_full(sk) && !isn) {
    if (net_ratelimit())
      syn_flood_warning(skb);

  // ...
}
{% endhighlight %}

[`include/net/inet_connection_sock.h`](https://github.com/torvalds/linux/blob/v2.6.38/include/net/inet_connection_sock.h#L289)
{% highlight c %}
static inline int inet_csk_reqsk_queue_is_full(const struct sock *sk)
{
  return reqsk_queue_is_full(&inet_csk(sk)->icsk_accept_queue);
}
{% endhighlight %}

[`include/net/request_sock.h`](https://github.com/torvalds/linux/blob/v2.6.38/include/net/request_sock.h#L236)
{% highlight c %}
static inline int reqsk_queue_is_full(const struct request_sock_queue *queue)
{
  return queue->listen_opt->qlen >> queue->listen_opt->max_qlen_log;
}
{% endhighlight %}

Something about the log and bitshift.

So to what value is `max_qlen_log` set?

[`net/core/request_sock.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/core/request_sock.c#L38)
{% highlight c %}
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

`sysctl_max_syn_backlog` is `net.ipv4.tcp_max_syn_backlog`

[`net/ipv4/inet_connection_sock.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/inet_connection_sock.c#L621)
{% highlight c %}
int inet_csk_listen_start(struct sock *sk, const int nr_table_entries)
{
  // ...

  reqsk_queue_alloc(&icsk->icsk_accept_queue, nr_table_entries);

  // ...
}
{% endhighlight %}

[`net/ipv4/af_inet.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/af_inet.c#L192)
{% highlight c %}
int inet_listen(struct socket *sock, int backlog)
{
  // ...

  err = inet_csk_listen_start(sk, backlog);

  // ...
}
{% endhighlight %}

`inet_stream_ops` struct in [`net/ipv4/af_inet.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/ipv4/af_inet.c#L907)

[`net/socket.c`](https://github.com/torvalds/linux/blob/v2.6.38/net/socket.c#L1440)
{% highlight c %}
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

`sock_net(sock->sk)->core.sysctl_somaxconn` is actually `net.core.somaxconn` which defaults to the [SOMAXCONN](https://github.com/torvalds/linux/blob/v2.6.38/include/linux/socket.h#L240) macro which equals 128.

