---
published: true
title: Weirdness in php getters/setters
layout: post
keywords: php getter setter
---

While writing some PHP I ran into the following undocumented behaviour. When calling a getter for a property recursively PHP will always return NULL on the recursive calls.

{% highlight php %}
<?

class Test {
  private $data = array();

  public function __set($name, $value) {
    $this->data[$name] = $value;
  }

  public function __get($name) {
    if (isset($this->data[$name])) {
      return $this->data[$name];
    } else {
      call_user_func(array($this, 'get'.ucfirst($name)));

      return $this->data[$name];
    }
  }

  public function __isset($name) {
    return isset($this->data[$name]);
  }


  // This function will be called inside __get.
  public function getSomething() {
    $this->something = 1337;

    var_dump(isset($this->something)); // Outputs: true


    // Since we just set it and isset returns it's set I assume we should now be able to access it.
    var_dump($this->something); // Doesn't work, outputs: NULL


    // This does work (expected since isset also worked).
    var_dump($this->data['something']); // Does work, outputs: 1337
  }
}


$t = new Test();

var_dump($t->something); // Outputs: 1337
{% endhighlight %}

