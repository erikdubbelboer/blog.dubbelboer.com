---
title: The PHP use keyword
layout: post
keywords: php use
---

Anonymous functions
-------------------

As of 5.3.0 PHP has support for anonymous functions. There are two well known and one lesser known way to pass variables to your anonymous functions.

1. Using the global scope.
2. Passing them as arguments (optionally as reference if you want to be able to modify them).
3. Using the `use` keyword.

The `use` keyword
-----------------

The `use` keyword allows you to introduce local variables into the local scope of an anonymous function. This is useful in the case where you pass the anonymous function to some other function which you have no control over.

In this simple example we have no control over which arguments `array_filter` passes to our anonymous function. The only other way to access the `$half` variable in this example function would be to make it a global variable. The `use` keyword allows us to solve this elegantly without polluting our global scope.

{% highlight php %}
<?
function remove_lowest_half($arr) {
  $half = array_sum($arr) / count($arr); // Calculate the average value.

  return array_filter($arr, function($v) use ($half) {
    return ($v > $half);
  });
}

// 8 elements which sum up to 40.
// So half will be 5.
$input = array(1,2,3,4,6,7,8,9);

var_dump(remove_lowest_half($input));
{% endhighlight %}

This will output the expected:

<pre>
array(4) {
  [4]=>
  int(6)
  [5]=>
  int(7)
  [6]=>
  int(8)
  [7]=>
  int(9)
}
</pre>

Variables passed through `use` are not passed by reference. Like normal function arguments modifying them will not modify the original. The usage of `&` to make them references is possible.

Using this we can build another example. A simple counting function with an initial value using no global variables for the counting.

{% highlight php %}
<?
function counter($start) {
  $value = $start;

  return function() use (&$value) {
    return $value++;
  };
}

$counter = counter(6);

echo $counter() . "\n";
echo $counter() . "\n";
{% endhighlight %}

This will output the expected:

<pre>
6
7
</pre>

Note: `use` can only be used with anonymous functions. Using it with named functions gives a syntax error.

