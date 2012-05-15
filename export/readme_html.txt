@date 2011-11-24
@author Raphael Harmel

-------------
 DESCRIPTION
-------------

The batch files in this directory allows a simple and efficient way to prepare a Silex html release.

--------
 DETAIL
--------

Each batch file does some of the following actions:
 -svn export
 -cleans the export by removing the uneeded files for the release
 -compresses the corresponding directory.

--------------
 REQUIREMENTS
--------------

These batch files are only existing for Windows.

Software to install:
-SVN command line needs to be installed. This can be done via tortoise svn, be sure to check the corresponding option while installing it.
-7Zip needs to be installed in C:\"Program Files"\7-Zip\7z.exe

--------
 ISSUES
--------

Label button, supported in html5, uses Flash button as parent class, which is not supported in html5...
 => as a result we have to load it which makes it visible in the Wysiwyg, even if it is not html5 compliant.


