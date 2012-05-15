<?php

/*
this function should only be called if php is  not set to 5 without a specific line in the root .htaccess

include this script from a php file in a directory with a .htaccess experiment to force php version to 5. 
call function with 2 params: 
- the path of the .htaccess file containing the line. the .htaccess file must contain one line and one line only
containing the possible fix for php.
- the path to which we want to write the .htaccess. If a file already exists, it will be appended

to use this method we do successive calls or multiple frames. With multiple frames, we try not to write multiple times. 
*/

define("PHP_VERSION_FORCE_MARKER", "#force php version to 5");

function tryToFixHtaccessForPhpVersion($sourceHtaccessPath, $destHtaccessPath){
	//echo PHP_VERSION;
	$commandLine = file_get_contents($sourceHtaccessPath);
	if (version_compare(PHP_VERSION,'5','>=')){
		//echo "\n php version is ok with <br/>" . $commandLine;
		//the php file calling this function has a right htaccess file. do copy/merge if marker not already found in target file
		if(file_exists($destHtaccessPath)){
			$targetFileContents = file_get_contents($destHtaccessPath);
			if(strpos($targetFileContents, PHP_VERSION_FORCE_MARKER) !== false){
				//echo "<br/> A line to force php version is already in .htaccess file, so it wasn't changed.";
				//force already set. return not to set another
				return;
			}
		}
		$dataToAdd = "\n" . PHP_VERSION_FORCE_MARKER . "\n" . $commandLine;
		//echo $destHtaccessPath;
		file_put_contents($destHtaccessPath, $dataToAdd, FILE_APPEND);
		//echo "<br/> The .htaccess file was set. Please refresh!";
	}else{
	//	echo "php version is insufficient with " . $commandLine ;
	}
}
