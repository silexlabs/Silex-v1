<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
if ( !isset ( $_GET['folder'] ) )
{
	die('&phpStatus=ko&message=Error, no destination folder specified');
}	

// make sure that the project base directory is in the include path; 
require_once('../../rootdir.php');
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH.'cgi/library/');
require_once("../includes/file_system_tools.php");

if (isset($_GET['session_id'])) $session_id = $_GET['session_id'];
else $session_id = NULL;

$cl = new file_system_tools () ;

if (isset ($_GET['rootFolder']))
{
	$rootFolder = $_GET['rootFolder'];
}

else
{
	$rootFolder = NULL;
}

if (isset($_GET['fileDataPropertyName']))
{
	$fileDataPropertyName = $_GET['fileDataPropertyName'];
}
else
{
	$fileDataPropertyName = "Filedata";
}
session_id($session_id);
session_start();

//create the folder before uploading the file, create only if it doesn't exist already
$cl->createFtpFolder("" , $_GET['folder'], $rootFolder);
$ret = $cl->uploadFtpItem ($_GET['folder'] , $_GET['name'],$session_id, $fileDataPropertyName, $rootFolder) ;

if ($ret)
	echo "&phpStatus=ko&message=$ret";
else
	echo '&phpStatus=ok'

				
?>