<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * upload an image for the given page
 * if we upload a png image for page X, it renames the image X.png, potentially replacing the previous preview (deleting X.jpg and replacing X.png)
 */

// make sure that the project base directory is in the include path; 
require_once('../../rootdir.php');
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH.'cgi/library/');
require_once("../includes/file_system_tools.php");
$cl = new file_system_tools () ;


function getArgInPostAndGet($argName)
{
	if ( isset ( $_GET[$argName] ) )
	{
		return $_GET[$argName];
	}
	if ( isset ( $_POST[$argName] ) )
	{
		return $_POST[$argName];
	}
	return FALSE;
}
// inputs
$page_name = getArgInPostAndGet('page_name');
if ( $page_name === FALSE )
{
	?><br />upload an image for the given page<br />if we upload a png image for page X, it renames the image X.png, potentially replacing the previous preview (deleting X.jpg and replacing X.png)<br /><br /><br /><hr />
	Help page of the script upload_preview.php of <a href='http://projects.silexlabs.org/?/silex'>Silex</a>
	<?php
		die("&phpStatus=ko&message=Error, no page_name found&");
}
$id_site = getArgInPostAndGet('id_site');
if ( $id_site === FALSE )
{
	die('&phpStatus=ko&message=Error, no id_site found');
}
if ( empty($_FILES['Filedata']) )
{
	die('&phpStatus=ko&message=Error, no image bytes found in "Filedata"');
}
$session_id = getArgInPostAndGet('session_id');
if ( $session_id === FALSE )
{
	$session_id = NULL;
}

// retrieve file extension
$ext = pathinfo($_FILES['Filedata']['name'], PATHINFO_EXTENSION);//end(explode('.', $_FILES['Filedata']['tmp_name']));//

if ($ext != 'jpg' && $ext != 'png')
	die('&phpStatus=ko&message=Error, unsupported file extension ".'.strip_tags($ext).'"');

// do the upload
$ret = $cl->uploadItem( "contents/$id_site/","$page_name.$ext",$session_id) ;
// handle errors
if ($ret)
	echo "&phpStatus=ko&message=$ret";
else
{
	// remove the existing preview for the page
	if ($ext != 'png' && is_file (ROOTPATH ."contents/$id_site/$page_name.png" ))
		unlink(ROOTPATH ."contents/$id_site/$page_name.png" );

	if ($ext != 'jpg' && is_file (ROOTPATH ."contents/$id_site/$page_name.jpg" ))
			unlink(ROOTPATH ."contents/$id_site/$page_name.jpg" );
	
	// no error
	echo '&phpStatus=ok';
}			
?>