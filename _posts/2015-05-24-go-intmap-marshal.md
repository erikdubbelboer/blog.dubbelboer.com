---
title: Marshal map[int]int in Golang
layout: post
keywords: golang go map json marshal
---

The Golang JSON module doesn't support marshaling maps with keys that are anything else than a string. I needed to serialize a map with integers as keys, so I wrote one. I'm just posting this here in case it's useful for anyone else:

{% highlight go %}
type Intmap map[int]int

func (i Intmap) MarshalJSON() ([]byte, error) {
  x := make(map[string]int)
  for k, v := range i {
    x[strconv.FormatInt(int64(k), 10)] = v
  }
  return json.Marshal(x)
}

func (i *Intmap) UnmarshalJSON(b []byte) error {
  x := make(map[string]int)
  if err := json.Unmarshal(b, &x); err != nil {
    return err
  }
  *i = make(Intmap, len(x))
  for k, v := range x {
    if ki, err := strconv.ParseInt(k, 10, 32); err != nil {
      return err
    } else {
      (*i)[int(ki)] = v
    }
  }
  return nil
}
{% endhighlight %}

It still serializes the keys to strings seeing as only strings are supported by the JSON standard. But it correctly handles the unserializing from the string keys back to integers.

