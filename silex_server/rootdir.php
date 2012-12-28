<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

	//Workaround for IIS not setting REQUEST_URI...
	if (!isset($_SERVER['REQUEST_URI']))
	{
		$_SERVER['REQUEST_URI'] = $_SERVER['PHP_SELF'];
		if (isset($_SERVER['QUERY_STRING']))
			$_SERVER['REQUEST_URI'].='?'.$_SERVER['QUERY_STRING'];
	}
	//End of IIS workaround

	if (!defined('ROOTPATH'))
		define( 'ROOTPATH', dirname(__FILE__) . DIRECTORY_SEPARATOR);

	if (!isset($ROOTURL))
	{
		global $ROOTURL;
		// compute url base
		$scriptUrl=$_SERVER['SERVER_NAME'].':'.$_SERVER['SERVER_PORT'].$_SERVER['REQUEST_URI'];
		// supress the get arguments of the querry
		$qmPos=strpos($scriptUrl,'?');
		if ($qmPos > 0) $scriptUrl = substr($scriptUrl,0,$qmPos);
		
		$lastSlashPos=strrpos($scriptUrl,'/');
		$ROOTURL = 'http://'.substr($scriptUrl, 0, $lastSlashPos + 1);
	}
	
    // php5 is needed before loading the class (mainly because of the static keyword)
    //Also ensure the root_dir class has not already been defined (it seems some scripts agressively include rootdir.php)
	if (version_compare(PHP_VERSION,'5','>') && !class_exists("root_dir", false))
	{
            require_once("cgi/includes/root_dir.php");
	}
?>
