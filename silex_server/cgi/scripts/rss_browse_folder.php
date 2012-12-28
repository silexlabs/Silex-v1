<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

///////////////////////////////////////////////////////////////////////////////
// rss_browse_folder.php is used to browse a folder recursively or not and display it as an rss feed
// inputs:
// folder_path
// recursive
// reverseOrder (any value - if defined it reverses the order)
// orderBy (item name, item last modification date, item size, item type, item width, item height, folder, ext)
// allow_folder - true or false - default is false
// allow_file - true or false - default is true
// extension - filter for the extension - default is ""
//
//
// example:
// cgi/scripts/rss_browse_folder.php?folder_path=media&orderBy=item%20last%20modification%20date&reverseOrder
// output:
// rss feed with these item tags:
// - title = file name
// - type = file or folder
// - extension = file extension
// - name = file name without extension
// - pubDate = file last modification date
// - link = url of the file
// - <media:content fileSize="49862" type="image/jpeg" width="385" height="250" url="http://www.rugama.com/mowno/wp_images/04_385x250.jpg"></media:content>
///////////////////////////////////////////////////////////////////////////////
// **
// useful functions
/**
 * SORT_REGULAR - compare items normally (don't change types)
 * SORT_NUMERIC - compare items numerically
 * SORT_STRING - compare items as strings
 * item name, item last modification date, item size, item type, item width, item height, folder, ext
 */
set_include_path(get_include_path() . PATH_SEPARATOR . "../../");
set_include_path(get_include_path() . PATH_SEPARATOR . "../includes/");
require_once("rootdir.php");
require_once("logger.php");
require_once("server_config.php");
require_once("file_system_tools.php");
$logger = new logger("rss_browse_folder");
$fst = new file_system_tools();
function orderBy($dirFiles,$tagToSortOn,$sortParam=SORT_REGULAR,$reverseOrder=false)
{
	$logger = new logger("rss_browse_folder");
	//$logger->debug(" orderBy $tagToSortOn - ".print_r($dirFiles,true));
	
	if (count($dirFiles)<=0)
		return $dirFiles; 

    $cwdMod=array(); $whatWeNeed=array();
   
    // Parallel arrays (ignore the ".", ".." and inturn hidden files
    foreach ($dirFiles as $data)
    {
		if (!isset($data[$tagToSortOn]))
		{
			// error
			$logger->emerg("orderBy $tagToSortOn error : no such data in the file description");
			
			return $dirFiles;
		}
		$cwdMod[]=$data[$tagToSortOn];
    }
   
    // Merge and sort
    $mergeArray=array_combine($cwdMod, $dirFiles);
	if ($reverseOrder==true)
		ksort($mergeArray, $sortParam);
	else
		krsort($mergeArray, $sortParam);
   
    // Build new array
    foreach ($mergeArray as $key => $value)
    {
			$logger->debug("orderBy $tagToSortOn - ".$value[$tagToSortOn]);
	        $whatWeNeed[]=$value;
    }
   
    // Some maintainence
    unset($cwdMod, $mergeArray);
	return $whatWeNeed;
}
// **
// includes

// **
// inputs
$logger->debug("params : " . print_r($_GET, true));

$allow_folder = false;
if (isset($_GET["allow_folder"]) && ("true" == $_GET["allow_folder"]))
	$allow_folder=true;

$allow_file = true;
if (isset($_GET["allow_file"]) && ("true" != $_GET["allow_file"]))
	$allow_file=false;
	
$extension = "";
if (isset($_GET["extension"]))
	$extension=$_GET["extension"];
	
if (isset($_GET["folder_path"]))
	$folder_path=$_GET["folder_path"];
else{
	echo "<h2>Browse folder script of Silex</h2><b>You need to provide the path of the folder you want to browse to browse like this</b><br> cgi/scripts/rss_browse_folder.php?folder_path=media or cgi/scripts/rss_browse_folder.php?folder_path=media&recursive=true";
	echo "<br>";
	echo "<br>";
	echo "<b>The parameters are the following</b><br>";
	echo "- folder_path
		<br>		- recursive
		<br>		- reverseOrder (any value - if defined it reverses the order)
		<br>		- orderBy (item name, item last modification date, item size, item type, item width, item height, folder, ext)
		<br>		- allow_folder - true or false - default is false
		<br>		- allow_file - true or false - default is true
		<br>		- extension - filter for the extension - default is ''
		";
	echo "<br>";
	echo "<br>";
	echo "<b>resulting rss feed has these item tags</b>
		<br>		- title = file name
		<br>		- type = file or folder
		<br>		- extension = file extension
		<br>		- name = file name without extension
		<br>		- pubDate = file last modification date
		<br>		- link = url of the file
		<br>		- media:content 
		<br>            -- fileSize
		<br>            -- type= (e.g. image/jpeg) 
		<br>            -- width
		<br>            -- height
		<br>            -- url";
	echo "<br>";
	echo "<br><br><br><hr>";
		die("Help for the <a href='http://community.silexlabs.org/silex/help/?page_id=644'>PHP scripts of Silex</a><br/>&phpStatus=ko&message=Error, no page_name found&");
}

// build website contentent folder
$initial_folder_path=$folder_path."/";
$folder_path="../../".urldecode($folder_path."/");

// build an array of the folder content files
if (isset($_GET["recursive"]) && $_GET["recursive"]=="true"){
	// **
	// recursive
	$tmp_array=$fst->listFolderContent($folder_path);
	$folderContent_array=flattenArray($tmp_array,$initial_folder_path);
	error_log(print_r($folderContent_array,true));
}
else{
	// **
	// not recursive
	$folderContent_array=array();
	// check rights
	if ($fst->checkRights($fst->sanitize($folder_path),constant("file_system_tools::USER_ROLE"),constant("file_system_tools::READ_ACTION"))){
		$tmpFolder = opendir($folder_path);
		$tmp=0;
		while ( false !== ($tmpFile = readdir($tmpFolder)) )
		{
			//echo "debug : build an array of the folder content files - ".$folder_path."/".$tmpFile."
			//";
			$isFile = is_file("../../".$initial_folder_path."/".$tmpFile);
			$FileNameTokens = explode('.',$tmpFile);
			$ext = strtolower(array_pop($FileNameTokens));
			if (($tmpFile{0}!=".") && (($isFile==true && $allow_file==true) || ($isFile==false && $allow_folder==true)) && ($extension=="" || $extension==$ext))
			{
				$tmp++;
				$folderContent_array[$tmp]=array();
				$folderContent_array[$tmp][constant("file_system_tools::itemNameField")]=$tmpFile;
				$folderContent_array[$tmp][constant("file_system_tools::itemNameNoExtField")]=$tmpFile;
				$folderContent_array[$tmp][constant("file_system_tools::itemModifDateField")]=date ("Y-m-d\H:i:s", filemtime($folder_path."/".$tmpFile));
				$folderContent_array[$tmp][constant("file_system_tools::itemSizeField")]=filesize($folder_path."/".$tmpFile);
				$folderContent_array[$tmp][constant("file_system_tools::itemReadableSizeField")]=$fst->readableFormatFileSize(filesize($folder_path."/".$tmpFile));
				if ($isFile==true)
				{
					$folderContent_array[$tmp][constant("file_system_tools::itemTypeField")]="file";
					$folderContent_array[$tmp][constant("file_system_tools::itemNameNoExtField")]= implode(".", $FileNameTokens);
				}
				else
					$folderContent_array[$tmp][constant("file_system_tools::itemTypeField")]="folder";

				if($ext == 'jpeg' || $ext == 'jpg'){
					$imageSize = getimagesize ($folder_path."/".$tmpFile);
					$folderContent_array[$tmp][constant("file_system_tools::itemWidthField")] = $imageSize[0];
					$folderContent_array[$tmp][constant("file_system_tools::itemHeightField")] = $imageSize[1];
				}
				
				$folderContent_array[$tmp]["folder"]=$initial_folder_path;
				$folderContent_array[$tmp]["ext"]=$ext;
			}
		}
	}
	else{
		$logger->emerg("no rights to read $folder_path");
	}
}
if (isset($_GET["orderBy"]) && $_GET["orderBy"]!=""){
	if (isset($_GET["reverseOrder"]))
		$reverseOrder=true;
	else
		$reverseOrder=false;
		
	if (isset($_GET["sortParam"]))
		$folderContent_array=orderBy($folderContent_array,$_GET["orderBy"],$_GET["sortParam"],$reverseOrder);
	else
		$folderContent_array=orderBy($folderContent_array,$_GET["orderBy"],null,$reverseOrder);
}
// compute url base
$scriptUrl=$_SERVER['SERVER_NAME'].':'.$_SERVER['SERVER_PORT'].$_SERVER['REQUEST_URI'];
$server_config = new server_config();
$lastSlashPos=strrpos($scriptUrl,$server_config->silex_server_ini["CGI_SCRIPTS_FOLDER"]."rss_browse_folder.php");
$urlBase="http://".substr($scriptUrl,0,$lastSlashPos);
//**
// echo rss
//echo "debug : ".print_r($folderContent_array);
header('Content-Type: text/xml; charset=UTF-8');
echo '<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0"
	xmlns:content="http://purl.org/rss/1.0/modules/content/"
	xmlns:wfw="http://wellformedweb.org/CommentAPI/"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd"
	xmlns:media="http://search.yahoo.com/mrss/"
	xmlns:photo="http://www.pheed.com/pheed/"
	xmlns:buyme="http://www.rugama.com/rss/1.0/modules/buyme/"
	xmlns:rateme="http://www.rugama.com/rss/1.0/modules/rateme/">
	<channel>
		<title>Browsing '.$initial_folder_path.'</title>
		<link>'.$urlBase.'</link>
		<pubDate>'.date ("r").'</pubDate>
		<lastBuildDate>'.date ("r").'</lastBuildDate>
		<generator>http://www.silex-ria.org</generator>
		';
		
foreach ($folderContent_array as $fileObject)
{
	$filePath_tmp = "../../".$fileObject["folder"].$fileObject[constant("file_system_tools::itemNameField")];
//	echo "debug : ".$fileObject["folder"].$fileObject[constant("file_system_tools::itemNameField")]."\n\t\t".$filePath_tmp."\n\t\t";
	if ( (is_file($filePath_tmp) && $allow_file==true) || ($allow_folder==true && is_dir($filePath_tmp)))
	{
		$pubDate=date ("r",filemtime($filePath_tmp));
		$rss1Date=date ("Y-m-d\TH:i:s+00:00",filemtime($filePath_tmp));
		$readableDate=date ("Y-m-d H:i",filemtime($filePath_tmp));
		echo "		<item>
";

		// - title = file name with extension
		if (isset($fileObject[constant("file_system_tools::itemNameField")]))
			echo "			<title><![CDATA[".$fileObject[constant("file_system_tools::itemNameField")]."]]></title>
";
		// - name = file name without extension
		if (isset($fileObject[constant("file_system_tools::itemNameNoExtField")]))
			echo "			<name><![CDATA[".$fileObject[constant("file_system_tools::itemNameNoExtField")]."]]></name>
";
		// - extension = file extension
		if (isset($fileObject["ext"]))
			echo "			<extension>".$fileObject["ext"]."</extension>
";
		// - type = file or folder
		if (isset($fileObject[constant("file_system_tools::itemTypeField")]))
			echo "			<type>".$fileObject[constant("file_system_tools::itemTypeField")]."</type>
";
			
		// - pubDate = file last modification date
		echo "			<pubDate>".$pubDate."</pubDate>
";
		echo "			<rss1Date>".$rss1Date."</rss1Date>
";
		echo "			<readableDate>".$readableDate."</readableDate>
";
		// - link = url of the file
		if (isset($fileObject[constant("file_system_tools::itemNameField")]))
			echo "			<link><![CDATA[".$urlBase.$fileObject["folder"].$fileObject[constant("file_system_tools::itemNameField")]."]]></link>
";
		// - <media:content fileSize="49862" type="image/jpeg" width="385" height="250" url="http://www.rugama.com/mowno/wp_images/04_385x250.jpg"></media:content>
		if (isset($fileObject["ext"]) && isset($fileObject[constant("file_system_tools::itemTypeField")]) && $fileObject[constant("file_system_tools::itemTypeField")]!='folder')
		{
			if($fileObject["ext"] == 'jpeg' || $fileObject["ext"] == 'jpg')
				echo '			<media:content readableFileSize="'.$fileObject[constant("file_system_tools::itemReadableSizeField")].'" fileSize="'.$fileObject[constant("file_system_tools::itemSizeField")].'" type="'.$fileObject["ext"].'" width="'.$fileObject[constant("file_system_tools::itemWidthField")].'" height="'.$fileObject[constant("file_system_tools::itemHeightField")].'" url="'.$urlBase.$fileObject["folder"].$fileObject[constant("file_system_tools::itemNameField")].'"></media:content>
';
			else
				echo '			<media:content
				fileSize="'.$fileObject[constant("file_system_tools::itemSizeField")].'"
				readableFileSize="'.$fileObject[constant("file_system_tools::itemReadableSizeField")].'"
				type="'.$fileObject["ext"].'"
				url="'.$urlBase.$fileObject["folder"].$fileObject[constant("file_system_tools::itemNameField")].'">
			</media:content>
';
		}

		echo "		</item>
";
	}
}
echo '	</channel>
</rss>';
function flattenArray($array,$folder)
{
	$logger = new logger("rss_browse_folder");
	//echo "debug : flattenArray ".print_r($array);
   $flatArray = array();
   foreach( $array as $subElement ) {
		$subElement["folder"]=$folder;
		//echo "debug : flattenArray($key)";
	   $flatArray[] = $subElement;
       if(isset($subElement[constant("file_system_tools::itemContentField")]) && is_array($subElement[constant("file_system_tools::itemContentField")]) )
           $flatArray = array_merge($flatArray, flattenArray($subElement[constant("file_system_tools::itemContentField")],$folder.$subElement[constant("file_system_tools::itemNameField")]."/"));
   }
   return $flatArray;
}
?>