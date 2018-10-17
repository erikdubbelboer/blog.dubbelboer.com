---
title: UE4 Simple Programmatic Materials
layout: post
keywords: unreal engine ue4 material beam ring texture
---

As a programmer working on an Unreal game I sometimes need simple textures to design effects. Seeing as I'm really bad with photoshop and other image editing software I always prefer to generate the textures programatically. In the following screenshot you can see a simple material that generates a beam texture. You can make the beam wider or narrower by playing with the exponent in the Power function. You can turn the bean by 90 degrees by using the R instead of the G component of the BreakOut node.

[![Simple Beam Material](/images/2018-10-15-beam-material.png)](/images/2018-10-15-beam-material.png)

Another example is a simple translucent sphere material where again we use the texture coordinates to build the look of the material.

[![Simple Translucent Sphere Material](/images/2018-10-15-sphere-material.png)](/images/2018-10-15-sphere-material.png)

Or pulsating rings using the Sin of a Time node.

[![Pulsating Rings Material](/images/2018-10-15-pulsating-rings-material.png)](/images/2018-10-15-pulsating-rings-material.png)

Or rotating ring segments using a combination of the techniques above.

[![Rotating Ring Segments Material](/images/2018-10-15-rotating-ring-segments-material.png)](/images/2018-10-15-rotating-ring-segments-material.png)

