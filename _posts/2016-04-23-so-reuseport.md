---
published: true
title: SO_REUSEPORT support
layout: post
keywords: SO_REUSEPORT linux kernel tcp
---

SO_REUSEPORT is a relatively new kernel feature which allows multiple processes to bind to the same socket:port combination.
Before SO_REUSEPORT this was only possible either by forking the original process and inheriting the file descriptors or sending the file descriptors over a unix domain socket using send2.

Having multiple processes listen on the same port can be very useful in high throughput environments.
It is also very useful for graceful upgrades of high availability processes.

The program below can be used to test if SO_REUSEPORT is available on your system.

To read more about SO_REUSEPORT please see: <a href="https://lwn.net/Articles/542629/" target="_blank">https://lwn.net/Articles/542629/</a>

{% highlight c %}
#include <stdio.h>
#include <errno.h>
#include <sys/socket.h>
#include <unistd.h>

int main() {
#ifdef SO_REUSEPORT
  int sock = socket(AF_INET, SOCK_STREAM, 0);
  int reuse = 1;
  if (setsockopt(sock, SOL_SOCKET, SO_REUSEPORT, (const char*)&reuse, sizeof(reuse)) < 0) {
    if (errno == EINVAL || errno == ENOPROTOOPT) {
      printf("SO_REUSEPORT is not supported by your kernel\n");
    } else {
      printf("unknown error\n");
    }
  } else {
    printf("SO_REUSEPORT is supported\n");
  }
  close(sock);
#else
  printf("SO_REUSEPORT is not supported by your include files\n");
#endif
  return 0;
}
{% endhighlight %}

