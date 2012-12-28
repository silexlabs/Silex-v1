@date 2011-11-24
@author Raphael Harmel

-------------
 DESCRIPTION
-------------

The batch files in this directory allows a simple and efficient way to prepare a Silex release.

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

-------------
 BATCH FILES
-------------

export_silex_design_kit.bat
 => exports trunk\silex_design_kit directory
 => compresses it to silex_design_kit.zip
 
export_silex_dev_kit.bat
 => exports trunk\silex_dev_kit directory
 => compresses it to silex_dev_kit.zip
 
export_silex_server.bat
 => exports trunk\silex_server directory
 => removes the following files or directories:
	-all directories in silex_server\contents (corresponding only to tests publications on 2011-11-24)
	-silex_server\media\test directory
 => compresses it to silex_server.zip

 