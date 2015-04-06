---
title: The multipart/x-mixed-replace content type
layout: post
keywords: php http content-type multipart x-mixed-replace
---

Looking at the new Google Analytics live view I noticed they use the [multipart/x-mixed-replace](http://en.wikipedia.org/wiki/MIME#Mixed-Replace_.28experimental.29) content type to push live updates to the webbrowser.

Using this special Content-type you can replace the contents of a page. You can find this example here: [dubbelboer.com/multipart.php](http://dubbelboer.com/multipart.php).

{% highlight php %}
<?

// Make sure PHP isn't buffereing anything.
ob_end_clean();

// Sending this header will prevent nginx from buffering the output.
header('X-Accel-Buffering: no');

header('Content-type: multipart/x-mixed-replace; boundary=endofsection');

// Keep in mind that the empty line is important to separate the headers
// from the content.
echo 'Content-type: text/plain

After 5 seconds this will go away and a cat will appear...
--endofsection
';
flush(); // Don't forget to flush the content to the browser.


sleep(5);


echo 'Content-type: image/jpg

';

$stream = fopen('cat.jpg', 'rb');
fpassthru($stream);
fclose($stream);

echo '
--endofsection
';

{% endhighlight %}

It's fun to experiment with but since it isn't supported by IE it's not really practical for real usage.


### Update 16-10-2014 ###

Fixed PHP and/or nginx buffering bug.

The current version of Safari (7.0.6) will not display the cat image but instead download it and open it in Preview.

The current version of Chrome (36) Opera Next (24) will not display anything anymore.

