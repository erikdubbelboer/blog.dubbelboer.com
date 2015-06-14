---
published: true
title: Is the write() syscall thread safe?
layout: post
keywords: write syscall linux
---

Well of course it's thread safe. All syscalls are thread safe. My real question is if calls to write() from multiple threads would interleave the data or write it one after the other. To test this I wrote a simple program:

{% highlight c %}
#include <unistd.h>
#include <fcntl.h>
#include <pthread.h>
#include <stdlib.h>

const int bs = 1024*(1024*3+1);

int fd;

void foobar(char* x) {
  // Put this on the heap cause the stack might be too small.
  // On Mac OSX putting this on the stack causes a Bus error: 10
  char* bar = malloc(bs);

  for (int i = 0; i < 1024; i++) {
    for (int j = 0; j < 1024; j++) {
      bar[i*(1024*3+1)+j*3+0] = x[0];
      bar[i*(1024*3+1)+j*3+1] = x[1];
      bar[i*(1024*3+1)+j*3+2] = x[2];
    }
    bar[i*(1024*3+1)+1024*3] = '\n';
  }

  for (int i = 0; i < 1024; i++) { // less than 4GB
    if (write(fd, bar, bs) != bs) {
      exit(3);
    }
  }
}

void* other(void* unused) {
  foobar("bar");
  return 0;
}

int main() {
  fd = open("test.txt", O_RDWR | O_CREAT | O_TRUNC, 0777);

  pthread_t t;

  if (pthread_create(&t, 0, other, 0)) {
    exit(1);
  }

  foobar("foo");

  pthread_join(t, 0);

  return 0;
}
{% endhighlight %}


The output of the program looked like this:
{% raw %}
<pre>
$ time ./test

real  0m22.166s
user  0m0.016s
sys   0m12.418s

$ echo $?
0

$ ls -lh test.txt
-rw-r--r--  1 erik  staff   6.0G Feb 14 16:25 test.txt

$ time grep -v foo test.txt | grep -v bar
real  0m15.032s
user  0m5.749s
sys   0m4.725s

$ time grep -v -e foo -e bar test.txt 
real  0m14.879s
user  0m4.822s
sys   0m3.237s
erik$ 

$ awk '{ print length() }' test.txt | uniq
3072
</pre>
{% endraw %}

As you can see nothing went wrong and the program wrote 6GB of data in 22 seconds. Interleaving data would result in a single line containing both foo and bar. As you can see from the lacking output of grep this was not the case. Just to be sure the output of the awk line also shows that all lines are similar length meaning all writes completed fully after each other.

So the conclusion and answer to the question is that write() is completely thread safe and multiple calls to it are executed after each other.

One interesting side note is that the file did not contain interleaving lines of foo and bar as I would expect. Instead it contains large blocks of either foo or bar:

{% raw %}
<pre>
$ sed 's/\(...\).*/\1/' test.txt | uniq  -c
6144 foo
7168 bar
4096 foo
2048 bar
83968 foo
1024 bar
1024 foo
1024 bar
1024 foo
1024 bar
2048 foo
29696 bar
1024 foo
^C
</pre>
{% endraw %}

