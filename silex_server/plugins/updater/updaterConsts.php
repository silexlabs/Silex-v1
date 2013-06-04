<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/*
	Constant: TEMP_DIR_PATH
	The path to the directory where downloading the files to update
*/
define("TEMP_DIR_PATH", 'plugins' . DIRECTORY_SEPARATOR . 'updater' . DIRECTORY_SEPARATOR . 'downloaded_files');

/*
	Constant: VERSIONS_DIR_PATH
	The path to the directory where the element's version files are kept
*/
define("VERSIONS_DIR_PATH", 'plugins' . DIRECTORY_SEPARATOR . 'updater' . DIRECTORY_SEPARATOR . 'versions');

/*
	Constant: USE_FILE_SIGNATURE_CHECK
	Use the file signatures to check integrity
	This happens when downloading from Silex Labs server, either for plugins, themes, ... update or install
	Or for Silex server update
	? This is buggy since the new version of Silex Labs exchange platform on silexlabs.org (2013) ?
*/
define("USE_FILE_SIGNATURE_CHECK", false);
	
?>