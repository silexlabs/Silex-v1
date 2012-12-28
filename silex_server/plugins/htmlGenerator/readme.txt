This plugin allows you to generate an HTML version of your websites.


After having installed and activated it, you can access the HTML version of your websites by accessing your website’s URL followed by &format=html For example, if you access your website at the URL : http://myserver/?/myPublication then you can access the HTML version of it at http://myserver/?/myPublication&format=html

Also note that deeplinks should be put directly after the publication’s name without any hash. For example, in if in Flash version you have the following URL:

http://myserver/?/testsimple#/start/test

You can access the HTML version by going at

http://myserver/?/testsimple/start/test&format=html

Also, if you do not have Flash, it should automatically redirect you to the HTML version of the website you’re trying to visit.

If you do not have Flash nor Javascript, it should provide you a link to visit the HTML version of the website.

The parameters of this plugin are (in your manager, the plugins section of a publication)
* default format: Values can be 'html' or 'flash'. It is the format which will be displayed if there is not a format given in the URL (the '&format=html' or '&format=flash' in the address
* CSS declaration: Enter here CSS declaration, e.g. \"body{font-family: Verdana;}\".<br/><br/>Only taken into account in HTML version of the site.
