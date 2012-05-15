<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

////////////////////////////////////////////////////////////////////////
// log_command.php
// inputs (POST) :
// * message or htmlText_str (for compatibility with send_text command)
// * logFileName
////////////////////////////////////////////////////////////////////////


$serverRootPath="../../";
set_include_path(get_include_path() . PATH_SEPARATOR . $serverRootPath);
set_include_path(get_include_path() . PATH_SEPARATOR . "../library/");
/** Zend_Debug */
require_once 'Zend/Debug.php';
/** Zend_Log */
require_once 'Zend/Log.php';
require_once "Zend/Log/Writer/Stream.php";

$inputSource=$_POST;
//$inputSource=$_GET;

// read ini file
$silex_server_ini = parse_ini_file($serverRootPath."conf/silex_server.ini",false);
		
// logger
if (!$silex_server_ini["LOGS_FOLDER"]){
	echo "&result=error : LOGS_FOLDER folder constant is not defined in server ini file (".$serverRootPath."conf/silex_server.ini)&";
	exit (0);
}

//Control that file is in LOGS_FOLDER
if(!(strpos(realpath($serverRootPath.$silex_server_ini["LOGS_FOLDER"].$inputSource["logFileName"]),realpath($serverRootPath.$silex_server_ini["LOGS_FOLDER"]))===0))
{
    echo "&result=error : The specified file is not in LOGS_FOLDER&";
    exit(0);
}

//Control that the extension is .log
if(strtolower(pathinfo($inputSource["logFileName"], PATHINFO_EXTENSION)) != "log")
{
    echo "&result=error : The specified extension is not .log";
    exit(0);
}

try
{
	$logger = new Zend_Log(new Zend_Log_Writer_Stream($serverRootPath.$silex_server_ini["LOGS_FOLDER"].$inputSource["logFileName"]));
}
catch (Exception $e) 
{
//	echo 'Caught exception: ',  $e->getMessage(), "\n";
	echo "&result=".$e->getMessage()."&";
	exit(0);
}
// set the verbosity of SILEX logs in the .log files of the logs/ directory
$filter = new Zend_Log_Filter_Priority(constant("Zend_Log::".$silex_server_ini["LOG_LEVEL"]));
$logger->addFilter($filter);


// trace
if (isset($inputSource["message"]))
	$logger->debug(strip_tags(urldecode($inputSource["message"])));
if (isset($inputSource["htmlText_str"]))
	$logger->debug(strip_tags(urldecode($inputSource["htmlText_str"])));
	

echo "&result=done&";

?>