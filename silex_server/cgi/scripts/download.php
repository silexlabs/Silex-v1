<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	// display help for this script

	//Default values for parameters that have some.
	$force_download = true;
	
	if (!isset($GLOBALS['HTTP_RAW_POST_DATA']) && !isset($_GET['initial_name']) && !isset($_GET['final_name']))
	{
		?>
		<h2>Download script for Silex</h2>
		<h3>About</h3>
		<i>cgi/scripts/download.php</i><br /><br />
		This script is useful if you want to put a link in your website, which leads to a file, and you do not want the file to be opened in the browser, but to be downloaded by the user instead.<br /><br />
		Here you will find <a href='http://community.silexlabs.org/silex/help/'>the user guide of Silex</a>, brought to you by <a href='http://www.silexlabs.org/'>Silex Labs</a>.<br /><br />
		<h3>How to use this script</h3>
		Put a link on a button or in a text field which leads to this script with the path to the file which should be downloaded by the user, in the URL. For example, if you have the file <a href="../../media/logosilex.jpg">media/logosilex.jpg</a> in your library, here is the action to put on a button or image in Silex:<br /><br />
		<code>onRelease openUrl:cgi/scripts/download.php?initial_name=media/logosilex.jpg</code><br /><br />
		And the action to put in a text field:<br /><br />
		<code>[[openUrl:cgi/scripts/download.php?initial_name=media/logosilex.jpg|Click here to download the file]]</code><br /><br />
		<h3>The result</h3>
		The result of these actions, is <a href='download.php?initial_name=media/logosilex.jpg'>this download link</a> instead of <a href='../../media/logosilex.jpg'>this direct link</a>.<br /><br />
		<br /><br /><br/><br/><hr />
		<?php
		die("Help for the <a href='http://community.silexlabs.org/silex/help/?page_id=644'>PHP scripts of Silex</a>");
	}
	//RECUP DES VARIABLES
	if (isset($GLOBALS['HTTP_RAW_POST_DATA']))
	{
	    $_AMF_RAW_DATA = str_replace("&","\";$","$".URLDecode($GLOBALS['HTTP_RAW_POST_DATA']));
	    $_AMF_RAW_DATA = str_replace("=","=\"",$_AMF_RAW_DATA)."\";";
	
		//echo "BRUT ".URLDecode($GLOBALS['HTTP_RAW_POST_DATA']);
		//echo "\nCODE ".$_AMF_RAW_DATA;
	
	    eval($_AMF_RAW_DATA);
	
		//echo "FINAL ".$chemin.$fichier;
	}
	else
	{
		if (isset($_GET['initial_name']))
		{
			$final_name=$_GET['final_name'];
			$initial_name=$_GET['initial_name'];
			if($_GET['force_download'] == 'false')
			{
			    $force_download = false;
			}
		}
		else
		{
			$final_name=$_POST['final_name'];
			$initial_name=$_POST['initial_name'];
			if($_POST['force_download'] == 'false')
			{
			    $force_download = false;
			}
		}
	}
if (!$final_name) $final_name=$initial_name;

$initial_name = urldecode($initial_name);
$final_name = urldecode($final_name);

// check rights
$silex_server_ini = parse_ini_file("../../conf/silex_server.ini", false);	
/* isInFolder
 * @param filepath			file about to be accessed
 * @param folderName			folder name 
 * @returns true if filepath designate a path which is in the folder corresponding to folderName
 */
function isInFolder($filepath,$folderName){
	//return true;
	//echo realpath("../../".$filepath)." , ".realpath("../../".$folderName)."<br>";
	return (strpos(realpath("../../".$filepath),realpath("../../".$folderName))===0);
}
function getMIMEType($file)
{
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    switch($ext)
    {
        case "pdf":
            return "application/pdf";
        case "jpg":
            return "image/jpeg";
    }
    return "application/octet-stream";
}
if (!isInFolder($initial_name,$silex_server_ini["MEDIA_FOLDER"])){
	// error : no right to access this folder
	//echo "error : no right to access this folder";
	?>
		<h1>Download script for Silex</h1><h2>Access rights error</h2>There was an error: no right to access this folder<br/><a href="download.php">Here is the help page for this script</a><br/><br/><br/><hr />
	<?php
	die( "Help for the <a href='http://community.silexlabs.org/silex/help/?page_id=644'>PHP scripts of Silex</a>");
//	exit(0);
}
/* YES FINAL 
header("Content-Type: application/force-download");
header("Content-Length: " .(string)(filesize($myFile)) );
header('Content-disposition: attachment; filename="'.$final_name.'"');
header("Content-Transfer-Encoding: binary");
*/

// from http://fr2.php.net/header
//$mm_type="application/octet-stream";
//$mm_type = mime_content_type($initial_name);
$mm_type = getMIMEType($initial_name);
if(!$force_download)
{
    $content_disposition = 'inline';
} else
{
    $content_disposition = 'attachment';
}
header("Cache-Control: public, must-revalidate");
header("Pragma: hack");
header("Content-Type: " . $mm_type);
header("Content-Length: " .(string)(filesize("../../".$initial_name)) );
header('Content-Disposition: '.$content_disposition.'; filename="'.basename($final_name).'"');
header("Content-Transfer-Encoding: binary\n");
// for IE7
header('Vary: User-Agent');


// ecrit direct dans le doc: echo "Download should begin shortly... You can close this window.";
// ecrit direct dans le doc: echo "<script language=\"javascript\">alert ('Download should begin shortly... You can close this window.');</script>";
//echo "<script language=\"javascript\">window.close();</script>";

readfile("../../".$initial_name);
/**/
exit();
?>