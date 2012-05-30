---
title: AJAX file upload problem
layout: post
keywords: ajax javascript php
---

For one of our company websites we have an HTML file upload utility.

{% highlight html %}
<input type=file id=input onchange="handleFiles(this.files)">
{% endhighlight %}

The utility uses an XMLHttpRequest to post the files to our server.

{% highlight javascript %}
function handleFiles(files) {
  var xhr = new XMLHttpRequest;
  xhr.open('post', handler.url, true);
  xhr.setRequestHeader('X-File-Name' , files[0].fileName);
  xhr.setRequestHeader('X-File-Size' , files[0].fileSize);
  xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
  xhr.send(files[0]);
}
{% endhighlight %}

As you can see the file is send to the server on which puts it in the right place.

{% highlight php %}
<?

$filedata = file_get_contents('php://input');
$filename = $_SERVER['HTTP_X_FILE_NAME'];

// do something with $filedata and $filename
{% endhighlight %}

This has worked perfectly for a while until recently I had a file which failed to upload giving me the PHP error `Warning: Input variables exceeded 1000. To increase the limit change max_input_vars in php.ini.`. Other files still seem to work but this specific file failed. The file was only 20kb so that wasn't the problem.

After printing the contents of `$_POST` I found that PHP was trying to parse the raw file contents into an url encoded array of input variables. Apparently PHP has been doing this with our files all along but this specific file contained many `&` characters which made it reach it's input limit.

The bug was fixed by changing the `Content-type` of the AJAX request to `application/octet-stream`. This way PHP won't try to parse the input data.

