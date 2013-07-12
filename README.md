Push Notifications - Zero to Engagement
===

What is a push notification?
---

To your users, push notifications seem completely obvious; something happened and this app is letting me know. In the background, there are a lot of things going on to make those notifications a reality. There are persistent socket connections to manage, binary protocols to navigate, and reliability issues to keep in mind. We'll take a look at the basics of what is needed to send push notifications from scratch, some of the pitfalls of doing it yourself, as well as mentioning some third party services that can help you along the way.

What's in the repository?
---
/Slides - a [reveal.js](http://lab.hakim.se/reveal-js) project with the slides from a talk I gave to Philly CocoaHeads on 7/11/2013

/Demo - a minimal iOS application that subscribes for push notifications along with a minimal ruby script to send an iOS push notification

Running the demos
---
To run the iOS app demo:

* Configure a provisioning profile with a non wildcard bundle id
* Configure the same provisioning profile for push notifications
* Change the Info.plist to reflect the bundle id
* Sign the application with the configured provisioning profile

To run the push.rb demo:

* Generate server side push notification SSL certificates
 * Here's a [tutorial](https://zeropush.com/documentation/generating_certificates)
* Convert your certs to .pem format
 * openssl pkcs12 -in mycert.p12 -out client-cert.pem -nodes -clcerts
* Set the path to the .pem file in push.rb

License
---

Copyright (C) 2013 Adam Duke

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.