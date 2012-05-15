<?php
/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
require_once('../../rootdir.php');
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH . 'cgi/library/');
require_once("cgi/includes/file_system_tools.php");
require_once("cgi/includes/server_config.php");
require_once("cgi/includes/LangManager.php");


/**
* send the response to the client
*/
function response($phpStatus, $message)
{
	global $localisedStrings;
	//echo( "phpStatus=" . $phpStatus . "&message=" . htmlentities($message, ENT_COMPAT, "UTF-8") );
	if ($phpStatus == 'ok') {
		$fullMessage = $localisedStrings['SNAPSHOT_MESSAGE_COMPLETE'] . ': ' . $message . '. ';
	} else {
		$fullMessage = $localisedStrings['SNAPSHOT_MESSAGE_ERROR'] . ': ' . $message . '. ';
	}
	echo( "phpStatus=" . $phpStatus . "&message=" . $fullMessage );
}

/**
* write png image from POST data on the server
*/
function writePngImage($filePath)
{
	// Get the width and height of the destination image from the POST variables and convert them into integer values
	$w = (int)$_POST['width'];
	$h = (int)$_POST['height'];

	// Create the image with desired width and height
	$img = imagecreatetruecolor($w, $h);
	// Set the flag to save full alpha channel information
	imagesavealpha($img, true);

	// Define needed colors
	$transparentColor = imagecolorallocatealpha($img,0x00,0x00,0x00,127);
	$whiteColor = imagecolorallocatealpha($img,0xFF,0xFF,0xFF,0);
	// Fill the image with transparent color
	imagefill($img, 0, 0, $transparentColor);
	
	$rows = 0;
	$cols = 0;

	// Process every POST variable which contains a pixel color
	for($rows = 0; $rows < $h; $rows++){
		// convert the string into an array of n elements
		$c_row = explode(",", $_POST[$rows]);
		for($cols = 0; $cols < $w; $cols++){
			// get the single pixel color value
			$value = $c_row[$cols];
			// if value is not empty fill the pixel with the correct color 
			if($value != ""){
				$hex = $value;
				// Convert value from HEX to RGB
				// png: gets ARGB values
				$a = ( -(int)(hexdec(substr($hex, 0, 2)) / 2 )) + 127;
				$r = hexdec(substr($hex, 2, 2));
				$g = hexdec(substr($hex, 4, 2));
				$b = hexdec(substr($hex, 6, 2));
				// If recived ARGB color value is not transparent, fill pixel with color
				/*if ($hex != '00000000') {
				$color = imagecolorallocate($img, $r, $g, $b);}*/
				$color = imagecolorallocatealpha($img, $r, $g, $b, $a);
				// set the pixel at the correct color
				imagesetpixel($img, $cols, $rows, $color);
			// If value is empty, fill the pixel with blank
			} else {
				imagesetpixel($img, $cols, $rows, $whiteColor);
			}
		}
	}

	// Output image to file
	imagepng($img, $filePath,9);
	// Remove image
	imagedestroy($img);	
}


/**
* write jpg image from POST data on the server
*/
function writeJpgImage($filePath)
{
	// Get the width and height of the destination image from the POST variables and convert them into integer values
	$w = (int)$_POST['width'];
	$h = (int)$_POST['height'];

	// Create the image with desired width and height
	$img = imagecreatetruecolor($w, $h);

	// Define needed colors
	$whiteColor = imagecolorallocate($img,0xFF,0xFF,0xFF);
	// Fill the image with white color
	imagefill($img, 0, 0, $whiteColor);
	
	$rows = 0;
	$cols = 0;

	// Process every POST variable which contains a pixel color
	for($rows = 0; $rows < $h; $rows++){
		// convert the string into an array of n elements
		$c_row = explode(",", $_POST[$rows]);
		for($cols = 0; $cols < $w; $cols++){
			// get the single pixel color value
			$value = $c_row[$cols];
			// if value is not empty fill the pixel with the correct color 
			if($value != ""){
				$hex = $value;
				// Convert value from HEX to RGB
				// jpg: gets RGB values
				$r = hexdec(substr($hex, 0, 2));
				$g = hexdec(substr($hex, 2, 2));
				$b = hexdec(substr($hex, 4, 2));
				$color = imagecolorallocate($img, $r, $g, $b);
				// set the pixel at the correct color
				imagesetpixel($img, $cols, $rows, $color);
			}
		}
	}

	// Output image to file
	imagejpeg($img, $filePath,100);
	// Remove image
	imagedestroy($img);	
}


// start session. needed to check if user is allowed to write file.
session_start();

// get plugin language data
//$langManager = new LangManager();
$langManager = LangManager::getInstance();
$localisedFileUrl = $langManager->getLangFile('snapshot');
$localisedStrings = $langManager->getLangObject('snapshot', $localisedFileUrl);

// Verify if id_site GET parameter is missing
if ( !isset($_GET['id_site']) or ($_GET['id_site']=='') )  {
	response('ko',$localisedStrings['SNAPSHOT_MESSAGE_ERROR_1']);
} else {
	$id_site = $_GET['id_site'];
	// Verify if file GET parameter is missing
	if ( !isset($_GET['file']) or ($_GET['file']=='') ) {
		response('ko',$localisedStrings['SNAPSHOT_MESSAGE_ERROR_2']);
	} else {
		$fileName = $_GET['file'];
		// server_config instance
		$server_config = new server_config(); 
		// build website content folder
		$contentFolder = $server_config->getContentFolderForPublication($id_site);
		// build website content folder path
		$websiteContentFolder = $contentFolder . $id_site . '/';

		// Verify if POST data is empty
		if (empty($_POST)) {
			response('ko',$localisedStrings['SNAPSHOT_MESSAGE_ERROR_3']);
		} else {
			// file_system_tools instance
			$fst = new file_system_tools();
			// Verify is folder is not accessible with write privileges
			//if ($fst->isAllowed( $fst->sanitize('./'.$websiteContentFolder) , file_system_tools::WRITE_ACTION , TRUE)===FALSE)
			if ($fst->isAllowed( './'.$websiteContentFolder , file_system_tools::WRITE_ACTION , TRUE)===FALSE)
			{
				response('ko',$localisedStrings['SNAPSHOT_MESSAGE_ERROR_4']);
			} else {
			
				// build the full file path
				$filePath = ROOTPATH . $websiteContentFolder . $fileName;
				
				// Output file
				try
				{
					$extension = substr($fileName,-3);
					if ($extension=='png') {
						// write png image to file
						writePngImage($filePath);
						response('ok', $localisedStrings['SNAPSHOT_MESSAGE_COMPLETE_1']);
					} else if ($extension=='jpg'){
						// write jpg image to file
						writeJpgImage($filePath);
						response('ok', $localisedStrings['SNAPSHOT_MESSAGE_COMPLETE_1']);
						// file saved on server
						} else {
							response('ko', $localisedStrings['SNAPSHOT_MESSAGE_ERROR_5']);
						}
				}catch(Exception $e)
				{
					response('ko', $localisedStrings['SNAPSHOT_MESSAGE_ERROR_6']);
				}
			}
		}
	}
}
	
?>
