---
title: PHP autoloader exception weirdness
layout: post
keywords: php class autoloader exception
---

While writing some object oriented php at my job we ran into the following strange php behaviour.

{% highlight php %}
<?

// We want to use exceptions to catch non existing class errors.
spl_autoload_register(function($classname) {
  throw new Exception();
});
{% endhighlight %}


Now we can try to instantiate some class that doesn't exist.

{% highlight php %}
<?

try {
  new UnknownClass();
} catch (Exception $err) {
}
{% endhighlight %}

This works as it should. It will throw the Exception and the script continues to execute allowing us to recover from the error and do things in other ways.

But now we need the following construct:

{% highlight php %}
<?

try {
  UnknownClass::unknown(); // PHP will ignore the Exception thrown and throws it's own error.
} catch (Exception $err) {
}
{% endhighlight %}

In this case PHP will ignore the Exception thrown and will continue to handle it as a Fatal error stopping the execution of the script.

What we learned is that you shouldn't rely on exceptions from the autoloader and just use `class_exists()` when you aren't sure if a class will exists or not.

Update 18 Nov 2012
------------------

This issue has been fixed in PHP 5.3.0. See the [bug report](https://bugs.php.net/bug.php?id=61442).

