---
published: true
title: Blurring images in PHP
layout: post
keywords: php image blur filter
---

For my work I needed to blur parts of an image. PHP has several methods to do this which all yield different results. This post shows the output of most of these methods.

Normal image
------------
![normal](/images/blur/normal.png)


Gaussian filter
---------------
![gaussian](/images/blur/gaussian.png)


Gaussian filter times 20
------------------------
This time I applied the gaussian filter 20 times in a row. This can be quite slow.

![gaussian20](/images/blur/gaussian20.png)

Smooth 0
--------
The [IMG_FILTER_SMOOTH](http://php.net/imagefilter) filter with a smoothness level of 0.

![smooth0](/images/blur/smooth0.png)

Smooth -2
---------
The [IMG_FILTER_SMOOTH](http://php.net/imagefilter) filter with a smoothness level of -2.

![smooth-2](/images/blur/smooth-2.png)


Custom horizontal
-----------------
Using the [imageconvolution()](http://php.net/imageconvolution) function you can specify a custom convolution matrix. This allows you to do your own blurring. For example only in the horizontal direction.

![custom-horizontal](/images/blur/custom-horizontal.png)

Gaussian and smooth combined
----------------------------
You can also combine some filters. This example combines the gaussian filter with a smoothness filter of level -4. This blurs a lot while still being fast.

![gaussian-smooth-4-gaussian](/images/blur/gaussian-smooth-4-gaussian.png)


The code
--------

I used the following code to generate these images.

I did not use the [IMG_FILTER_SELECTIVE_BLUR](http://php.net/imagefilter) filter since for some reason it messed up all the colors.

{% highlight php %}
<?

function blur($name, $cb) {
  echo $name , "\n";

  $image = imagecreatefrompng('normal.png');

  // The imagefilter functions only work on the whole image.
  // We only want to blur half of the image so copy half to a temporary image,
  // apply the blur, and copy it back to the original image.
  $tempImage = imagecreate(400, 600);
  imagecopy  ($tempImage, $image, 0, 0, 0, 0, 400, 600);
  $cb($tempImage);
  imagecopy  ($image, $tempImage, 0, 0, 0, 0, 400, 600);
  imagedestroy($tempImage);

  imagepng($image, $name . '.png');
}


blur('gaussian', function($image) {
  imagefilter($image, IMG_FILTER_GAUSSIAN_BLUR);
});

blur('gaussian20', function($image) {
  for ($i = 0; $i < 20; ++$i) {
    imagefilter($image, IMG_FILTER_GAUSSIAN_BLUR);
  }
});

foreach (array(0, -2) as $i) {
  blur('smooth' . $i, function($image) use($i) {
    imagefilter($image, IMG_FILTER_SMOOTH, $i);
  });
}

blur('custom-horizontal', function($image) {
  $matrix = array(
    array(0, 0, 0),
    array(2, 1, 2),
    array(0, 0, 0)
  );

  // For normal use the third argument should be the sum of all the values in the matrix.
  imageconvolution($image, $matrix, array_sum(array_map('array_sum', $matrix)), 0);
});

blur('gaussian-smooth-4-gaussian', function($image) {
  imagefilter($image, IMG_FILTER_GAUSSIAN_BLUR);
  imagefilter($image, IMG_FILTER_SMOOTH, -4);
  imagefilter($image, IMG_FILTER_GAUSSIAN_BLUR);
});
{% endhighlight %}

