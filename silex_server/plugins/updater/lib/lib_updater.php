<?php

/*
   Function: downloadFile
   Download a file into the temporary directory (specifyied by POST variable temp_dir_path). 

   Parameters:
      $request - the url of the remote file
      $local_file_path - local path of the file to download.
      $signature - optional, the signature that should have the downloaded file.

   Returns:
      true if the download and signature check succeeded
      false if not
*/
function downloadFile($request, $local_file_path , $signature = null)
{
	global $logger;
	
	if(empty($request) || empty($local_file_path))
		return false;
	
	(dirname($local_file_path) == '.') ? $dirName = '' : $dirName = dirname($local_file_path);
	if(!is_dir(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $dirName))
		if(!(@mkdir(ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $dirName, 0777, true)))
		{
			$logger->err("downloadFile $local_file_path   failed to mkdir ".ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $dirName);
			return false;
		}
	
	$triesCount = 0; 
	$downloadedFilePath = ROOTPATH . TEMP_DIR_PATH . DIRECTORY_SEPARATOR . $local_file_path;
	
	do {
		$triesCount++;
		
		if( !($wfp = @fopen($downloadedFilePath, 'wb')) )
		{
			$logger->err("downloadFile $local_file_path   failed to fopen $downloadedFilePath");
			return false;
		}
		
		if( !($rfp = @fopen($request, 'rb')) )
		{
			$logger->err("downloadFile $local_file_path   failed to fopen $request");
			return false;
		}
				
		while ( ($buffer = fread($rfp, 1024)) != '' )
			if(fwrite($wfp, $buffer) == 0)
			{
				$logger->err("downloadFile   An ERROR happened while fwrite $downloadedFilePath");
				break;
			}
		
		if($buffer === false)
			$logger->err("downloadFile   An ERROR happened while fread $request");
		
		if( !fclose($rfp) ) $logger->err("downloadFile  An ERROR happened when fclose $request");
		if( !fclose($wfp) ) $logger->err("downloadFile  An ERROR happened when fclose $downloadedFilePath");
		
	} while( !empty($signature) && $signature!=FileModel::getFileSignature($downloadedFilePath) && $triesCount<3 );
	
	if($triesCount<3)
		return true;
	return false;
}


/*
   Function: updateDir
   Copies the entire source directory into the destination directory by overwritting the already existing files in the destination directory.

   Parameters:
      $srcDir - The path of the source directory
      $destDir - The path of the destination directory
      $updateReport - a reference to an array where to keep trace of the errors that could happen during the update

   Returns:
   true on success, 
   false on failure
*/
function updateDir( $srcDir , $destDir , &$updateReport=null )
{
	global $logger;
	
	if ( $dh = @opendir($srcDir) )
	{	
		if( !file_exists($destDir) )
			if(!@mkdir($destDir, 0777, true))
			{
				$logger->err("updateDir  ERROR when mkdir $destDir");
				$updateReport[] = $destDir;
				return false;
			}
	
		while ( ( $file = readdir($dh) ) !== false )
		{
			if ( $file === '.' || $file === '..' )
				continue;
			
			if ( is_file( $srcDir . DIRECTORY_SEPARATOR . $file ) )
			{
			
				$destFile = $destDir . DIRECTORY_SEPARATOR . $file; $srcFile = $srcDir . DIRECTORY_SEPARATOR . $file;
			
				if( !($wfp = @fopen($destFile, 'wb')) )
				{
					$logger->err("updateDir  failed to fopen wb $destFile");
					$updateReport[] = $destFile;
					return false;
				}
				
				if( !($rfp = @fopen($srcFile, 'rb')) )
				{
					$logger->err("updateDir  failed to fopen rb $srcFile");
					$updateReport[] = $destFile;
					return false;
				}
						
				while ( ($buffer = fread($rfp, 1024)) != '' )
					if(fwrite($wfp, $buffer) == 0)
					{
						$logger->err("updateDir  An ERROR happened while fwrite $destFile");
						$updateReport[] = $destFile;
						return false;
					}
				
				if($buffer === false)
				{
					$logger->err("updateDir  An ERROR happened while fread $srcFile");
					$updateReport[] = $destFile;
					return false;
				}
				
				if( !fclose($rfp) ) { $logger->err("updateDir  An ERROR happened when fclose $srcFile"); $updateReport[] = $destFile; return false; }
				if( !fclose($wfp) ) { $logger->err("updateDir  An ERROR happened when fclose $destFile"); $updateReport[] = $destFile; return false; }
			}
			else
			{
				updateDir( $srcDir . DIRECTORY_SEPARATOR . $file , $destDir . DIRECTORY_SEPARATOR . $file, $updateReport );
			}
		}
		closedir($dh);
	}
	else
	{
		$logger->err("updateDir  ERROR when opendir $srcDir");
		$updateReport[] = $destDir;
		return false;
	}
	return true;
}


/*
   Function: delDir
   Deletes a entire directory and its contents in the local file system

   Parameters:
      $dir - The path to the directory to delete
      &$report - optional, a reference to the report to fill in when errors happen
      $keepMe - optional, a boolean telling if we keep the directory itself (and delete thus only its contents) or not
      $doNotDelete - list of path not to delete. 
	  
	TODO support not only file at REMP_DIR_ROOT level $doNotDelete
*/
function delDir($dir, &$report=null, $keepMe=false, $doNotDelete=null)
{
	global $logger;
	if ( is_dir($dir) && $dir != ROOTPATH ) // we don't want to loose our entire Silex file tree
	{
		if ( $dh = @opendir($dir) )
		{
			while ( ( $file = readdir($dh) ) !== false )
			{
				if ( $file === '.' || $file === '..' || $file===".svn" || ($doNotDelete != null && in_array($file, $doNotDelete)) )
					continue;
				if( is_dir( $dir.DIRECTORY_SEPARATOR.$file ) )
					delDir( $dir.DIRECTORY_SEPARATOR.$file, $report );
				else
					delFile( $dir.DIRECTORY_SEPARATOR.$file, $report );
			}
			
			closedir($dh);
		}
		// else TODO manage this error
	    
		if ( empty($doNotDelete) && !$keepMe && !(@rmdir( $dir )) && is_array($report) )
		{
			$report[] = $dir;
			$logger->err("delDir  failed to rmdir $dir");
		}
	}
}


/*
   Function: delFile
   Deletes a file on the local file system

   Parameters:
      $file - The path to the file to delete
      &$report - optional, a reference to the report to fill in when errors happen
*/
function delFile($file, &$report=null)
{
	global $logger;
	if( is_file($file) && !(@unlink( $file )) && is_array($report) )
	{
		$report[] = $file;
		$logger->err("delFile  failed to unlink $file");
	}
}


/*
   Function: generateUniqueFileName
   Generate a unique file name that doesn't already exist in the directory passed in parameters

   Parameters:
      $path - The path where we want a unique non-already-existing name
      $extension - optional, if we want a specific extension for the resource name
*/
function generateUniqueFileName($path, $extension=null)
{
	global $logger;
	
	$filenames = array();
	
	if ( $dh = @opendir($path) )
	{
		while ( ( $file = readdir($dh) ) !== false )
		{
			if ( $file === '.' || $file === '..' )
				continue;
			
			$filenames[] = strtolower($file);
		}
		closedir($dh);
	}
	
	$name = "";
	for ($i=0; $i<31; $i++)
	{
		$d = rand(1,30)%2;
		$name.= $d ? chr(rand(65,90)) : chr(rand(48,57));
	}
	if(!empty($extension))
		$name .= $extension;
	
	if( in_array( $name , $filenames ) )
		return generateUniqueFileName($path, $extension);
	
	return $name;
}


/*
   Function: urlencodeArray
   

   Parameters:
      $itemsArray
*/
function urlencodeArray($itemsArray)
{
	global $logger;
	
	foreach($itemsArray as $key => $item)
	{
		if(is_array($item))
			$itemsArray[$key] = urlencodeArray($item);
		else
			$itemsArray[$key] = urlencode($item);
	}
	
	return $itemsArray;
}


/*
   Function: urldecodeArray
   

   Parameters:
      $itemsArray
*/
function urldecodeArray($itemsArray)
{
	global $logger;
	
	foreach($itemsArray as $key => $item)
	{
		if(is_array($item))
			$itemsArray[$key] = urldecodeArray($item);
		else
			$itemsArray[$key] = urldecode($item);
	}
	
	return $itemsArray;
}
?>