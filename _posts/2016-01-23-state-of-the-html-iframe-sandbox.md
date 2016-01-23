---
published: true
title: State of the html iframe standbox
layout: post
keywords: html html5 iframe sandbox allow-popups allow-popups-to-escape-sandbox allow-modals
---

Most browsers support the iframe sandbox attribute in some form:

|Browser|Version|
|-------|-------|
|IE     |10+ (<a href="https://msdn.microsoft.com/en-us/library/hh673561%28v=vs.85%29.aspx" target="_blank">msdn</a>)|
|Chrome |5+ (<a href="http://blog.chromium.org/2010/05/security-in-depth-html5s-sandbox.html" target="_blank">blog</a>)|
|Firefox|17+ (<a href="https://developer.mozilla.org/en-US/Firefox/Releases/17" target="_blank">mdn</a>)|
|Opera  |15+ (<a href="https://developer.mozilla.org/en/docs/Web/HTML/Element/iframe" target="_blank">msdn</a>)|
|Safari |5+|

Propagation
---

When an iframe opens a new window through <code>target=_blank</code> or <code>window.open()</code>, some browsers will propagate the sandbox attributes to this new window.

|Browser|Action|
|-------|------|
|IE|Always propagates|
|Firefox|Always propagates|
|Chrome|Propagates until 46, see below|
|Opera|30-34 and Next seem to propagate|
|Safari|<a href="https://bugs.webkit.org/show_bug.cgi?id=21288" target="_blank">?</a>|

Attributes
---

The following attributes are supported by all browsers that implement the sandbox attribute: allow-scripts, allow-forms, allow-same-origin, allow-top-navigation

Attributes that are not always supported:

allow-popups
------

Firefox 27 before this version popups were always disallowed.

Other browsers: always supported.


allow-popups-to-escape-sandbox
------

Chrome 46+ (<a href="http://dubbelboer.com/allow-popups-to-escape-sandbox/" target="_blank">test</a>)

Before chrome always propagated the sandbox attributes to popups.

Firefox: currently not supported, work has started: [Bugzilla #1190641](https://bugzilla.mozilla.org/show_bug.cgi?id=1190641)


allow-modals
------

Chrome 46+ (<a href="https://googlechrome.github.io/samples/block-modal-dialogs-sandboxed-iframe/" target="_blank">test</a>)

Before 46 Chrome always allowed modals. All other browsers always allow modals.

Other browsers: not supported.

