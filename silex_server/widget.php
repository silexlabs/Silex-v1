<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	function parse_client_side_ini_file($filePath){
		// check rights
		if (is_file($filePath)){
			$tmp = @file($filePath,FILE_SKIP_EMPTY_LINES);
			foreach ($tmp as $line) {
				// remove bom
				if(substr($line, 0,3) == pack("CCC",0xef,0xbb,0xbf)) {
					$line=substr($line, 3);
				}
				// if there is a "=" and no ":" at the beginning, then split the line 
				if ($line!="" && (strpos($line,";")===FALSE || strpos($line,";")>0) && strpos($line,"=")!==FALSE){
					$keyvalue=explode("=",$line);

					if ($keyvalue[0] && $keyvalue[1] && $keyvalue[0]!="" && $keyvalue[1]!="")
						$res[$keyvalue[0]]=substr($keyvalue[1],0,strlen($keyvalue[1])-2);
				}
			}
		}
		return $res;
	}
// **
// inputs
// id_site
$id_site=$_GET["id_site"];

// **
// read ini files
// silex_server.ini
$serverRootPath = "";
$silex_server_ini = parse_ini_file("conf/silex_server.ini", false);

// retrieve website config data
$filePath=$silex_server_ini["CONTENT_FOLDER"].$id_site."/".$silex_server_ini["WEBSITE_CONF_FILE"];
$websiteConfig=parse_client_side_ini_file($filePath);

// redirect to 404 website
if (!$websiteConfig)
{
	$id_site = $silex_server_ini["DEFAULT_ERROR_WEBSITE"];
	// retrieve website config data
	$filePath=$silex_server_ini["CONTENT_FOLDER"].$id_site."/".$silex_server_ini["WEBSITE_CONF_FILE"];
	$websiteConfig=parse_client_side_ini_file($filePath);
}

// compute url base
require_once( 'rootdir.php' );
$urlBase=$ROOTURL;

// **
// silex params (from index.php)
$php_website_conf_file=$silex_server_ini["CONTENT_FOLDER"].$id_site."/".$silex_server_ini["WEBSITE_CONF_FILE"];
$SILEX_CLIENT_CONF_FILES_LIST=$php_website_conf_file.",".$silex_server_ini["SILEX_CLIENT_CONF_FILES_LIST"];
//$flashPlayerVersion=$websiteConfig["flashPlayerVersion"];
$CONFIG_START_SECTION=$websiteConfig["CONFIG_START_SECTION"];
$SILEX_ADMIN_AVAILABLE_LANGUAGES=$silex_server_ini["SILEX_ADMIN_AVAILABLE_LANGUAGES"];
$SILEX_ADMIN_DEFAULT_LANGUAGE=$silex_server_ini["SILEX_ADMIN_DEFAULT_LANGUAGE"];
$htmlTitle=$websiteConfig["htmlTitle"];
//$preload_files_list="";
$preload_files_list=$websiteConfig["layoutFolderPath"].$websiteConfig["initialLayoutFile"]/*.",fp".$websiteConfig["flashPlayerVersion"]."/".$websiteConfig["layerSkinUrl"]*/;
$bgColor=$websiteConfig["bgColor"];

/*
// old, with flash player version
$getVariables = "rootUrl=".urlencode($urlBase)."&id_site=".$id_site."&ENABLE_DEEPLINKING=false&silex_result_str=_no_value_&silex_exec_str=_no_value_&flashPlayerVersion=".$flashPlayerVersion."&SILEX_ADMIN_DEFAULT_LANGUAGE=".$SILEX_ADMIN_DEFAULT_LANGUAGE."&SILEX_ADMIN_AVAILABLE_LANGUAGES=".$SILEX_ADMIN_AVAILABLE_LANGUAGES."&initialPath=".$CONFIG_START_SECTION."&config_files_list=".$SILEX_CLIENT_CONF_FILES_LIST."&preload_files_list=".$preload_files_list;
*/

// variables which replace what would be found in the config files and returned by the call to amfphp get_data service
$getVariables = "rootUrl=".urlencode($urlBase)."&id_site=".$id_site."&ENABLE_DEEPLINKING=false&silex_result_str=_no_value_&silex_exec_str=_no_value_&SILEX_ADMIN_DEFAULT_LANGUAGE=".$SILEX_ADMIN_DEFAULT_LANGUAGE."&SILEX_ADMIN_AVAILABLE_LANGUAGES=".$SILEX_ADMIN_AVAILABLE_LANGUAGES."&initialPath=".$CONFIG_START_SECTION."&config_files_list=".$SILEX_CLIENT_CONF_FILES_LIST."&preload_files_list=".$preload_files_list;


echo $getVariables;
die;

/*

$newUrl = $urlBase."loader.swf?".$getVariables;
//header("Location:".$newUrl);
 
//header("Status: 307");
//header("Location: ".$newUrl,TRUE,301);

header("HTTP/1.1 301 Moved Permanently"); 
header("Location:".$newUrl); 
header("Connection: close"); 
exit;
*/
?>