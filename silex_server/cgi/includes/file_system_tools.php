<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


	require_once("consts.php");
	require_once("server_config.php");
	require_once("silex_config.php");
	require_once("password_manager.php");
	
	require_once("rootdir.php");
	require_once("server_content.php");

	require_once("rootdir.php");
	require_once("logger.php");
	require_once("consts.php");
	
	class file_system_tools{
		var $logger = null;
		var $server_config;
	
		// for rights to read or write folders and files
		const WRITE_ACTION="write";
		const READ_ACTION="read";
		const ADMIN_ROLE="admin";
		const USER_ROLE="user";		
	
		// ftp client web service constants
		// folders list xml node names
		const itemTypeField="item type";
		const itemSizeField="item size";
		const itemReadableSizeField="item readable size";
		const itemNameField="item name";
		const itemNameNoExtField="item name no extension";
		const itemModifDateField="item last modification date";
		const itemWidthField="item width";
		const itemHeightField="item height";
		const itemImageTypeField="image type";
		const itemContentField="itemContent";
	
		function file_system_tools(){
			$this->logger = new logger("file_system_tools");
		}
		
		/* sanitize: create a full absolute path from any path
		* @param $filepath    path to convert which can be non absolute
		* @param $allowNotExistingFiles
		*/
		function sanitize($filepath, $allowNotExistingFiles = FALSE){
			//if ($this->logger) $this->logger->debug("sanitize : $filepath, 1 : ". strip_tags($filepath) . ", 2: " . htmlentities(strip_tags($filepath)) . ", 3 : ". realpath(htmlentities(strip_tags($filepath))));
			if (!$filepath || $filepath == "") return FALSE;
			
			// sanitise input
			if ($allowNotExistingFiles == FALSE)
				$filepath=realpath(htmlentities(strip_tags($filepath)));
			else
			{
				$lastSlashPos = strrpos( $filepath , "/" ) ;
				if($lastSlashPos===FALSE) $lastSlashPos = strrpos( $filepath , "\\" ) ;
				
				$filepath = realpath(htmlentities(strip_tags(substr( $filepath , 0 , $lastSlashPos ))));
				if ($filepath !== FALSE)
				{
					$filepath .= substr( $filepath , $lastSlashPos );
				}
//				$filepath=$this->get_absolute_path(htmlentities(strip_tags($filepath)));
			}

			// return sanitized path
			return $filepath;
		}
		/* isInFolder
		 * @param filepath			file about to be accessed
		 * @param folderName			folder name 
		 * @return true if filepath designate a path which is in the folder corresponding to folderName
		 */
		function isInFolder($filepath,$folderName){
			return (strpos($filepath,realpath(ROOTPATH . $folderName))===0);
		}
		
		
		/**
		 * write a string to a file
		 * @return	"" if there is no error - the error message otherwise
		 */
		function writeToFile($xmlFileName,$xmlData) 
		{
				//  open file
				try{
					$fileHandle=fopen($xmlFileName,"w");
					if (!$fileHandle){
						if ($this->logger) $this->logger->debug("writeToFile error opening file ".$fileHandle);
						return "error opening file ".$xmlFileName;
					}
				}
				catch(Exception $e){
					return "error opening file ".$xmlFileName;
				}

				if ($this->logger) $this->logger->debug("writeToFile open ok ("."/".$xmlFileName.")");

				// add UTF-8 header
				$xmlData="\xEF\xBB\xBF".$xmlData; 

				// write data
				try{
					if (!fputs ($fileHandle,$xmlData)){
						if ($this->logger) $this->logger->emerg("writeToFile error writing to file ".$fileHandle);
						return "error writing to file ".$xmlFileName;
					}
					// close
					fclose($fileHandle);
				}
				catch(Exception $e){
					return "error writing file ".$xmlFileName;
				}
				if ($this->logger) $this->logger->debug("writeToFile close ok");

				return "";
		}
		/**
		 * convert a file wheight in bytes into a readable format, e.g. "3Mo" 
		 */
		function readableFormatFileSize($size, $round = 0) 
		{
			//Size must be bytes!
			$sizes = array('B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
			for ($i=0; $size > 1024 && $i < count($sizes) - 1; $i++) $size /= 1024;
			return round($size,$round).$sizes[$i];
		} 
		/**
		 * Calculate directory size info.
		 * @param   string  $path   without trailing '/' or '\' (eg. '/users/sampleUser', not '/users/sampleUser/')
		 * @return  array with size, count, and dircount
		 */
		function get_dir_size_info($path)
		{
		  $totalsize = 0; 
		  $totalcount = 0; 
		  $dircount = 0; 
		  if ($handle = opendir ($path)) 
		  { 
			while (false !== ($file = readdir($handle))) 
			{ 
			  $nextpath = $path . '/' . $file; 
			  if ($file != '.' && $file != '..' && !is_link ($nextpath)) 
			  { 
				if (is_dir ($nextpath)) 
				{ 
				  $dircount++; 
				  $result = $this->get_dir_size_info($nextpath); 
				  $totalsize += $result['size']; 
				  $totalcount += $result['count']; 
				  $dircount += $result['dircount']; 
				} 
				elseif (is_file ($nextpath)) 
				{ 
				  $totalsize += filesize ($nextpath); 
				  $totalcount++; 
				} 
			  } 
			} 
		 	closedir ($handle); 
		  }
		  $total['size'] = $totalsize; 
		  $total['count'] = $totalcount; 
		  $total['dircount'] = $dircount; 
		  if ($this->logger) $this->logger->debug("get_dir_size_info for $path : " . print_r($total, true));
		  return $total; 
		}
		
		/**
		 * interface for get_dir_size_info
		 * returns the size of a folder in a readable form
		 */
		function getFolderSize($folder)
		{
			if ($this->logger) $this->logger->debug("getFolderSize($folder) ");
			 
			if ($this->isAllowed( $folder, self::READ_ACTION ))
			{
				$sizeObj = $this->get_dir_size_info(ROOTPATH . $folder);
				//if ($this->logger) $this->logger->debug("sizeObj : " . print_r($sizeObj, true));
				return $this->readableFormatFileSize($sizeObj['size']);
			}
			
			return "FORBIDDEN";
		}	
		
		private function getFtpPath ( $folder, $rootFolder = NULL )
		{
			if ( is_null ( $this->server_config ) )
			{
				$this->server_config = new server_config();
			}
			
			if (is_null($rootFolder))
			{
				$rootFolder = $this->server_config->silex_server_ini['MEDIA_FOLDER'];
			}
			
			return  $rootFolder. str_replace( '../' , '' , urldecode( $folder ) ) ;
		}
		
		function createFtpFolder ($folder,$name,$rootFolder = NULL)
		{
			$folder = $this->getFtpPath ( $folder,$rootFolder);
			
			if (!$this->isAllowed( $folder , self::WRITE_ACTION ) )
			{
				return 'FORBIDDEN' ;
			}
			
			$full_path = ROOTPATH . $folder ;
			
			$name = urldecode( $name ) ;
			
			
			if ( is_dir ( $full_path.$name ) )
			{
				return 'DIRECTORY_EXISTS' ;
			}
			
			if ( mkdir ($full_path.$name ) )
			{
				return 'DONE'  ;
			}
			
			return 'UNKNOWN_FAILURE' ;
		}
		
		function renameFtpItem ($folder,$oldItemName,$newItemName)
		{
			
			$folder = $this->getFtpPath ( $folder );
			
			if (!$this->isAllowed( $folder , self::WRITE_ACTION ) )
			{
				return 'FORBIDDEN' ;
			}
			
			$oldItemName = urldecode( $oldItemName ) ;
			$newItemName = urldecode( $newItemName ) ;
			$full_path = ROOTPATH . $folder ;
			
			if ( !is_dir ( $full_path.$oldItemName ) && !is_file ( $full_path.$oldItemName ) )
			{
				return 'ITEM_NOT_EXISTS';
			}
			
			if ( rename ($full_path.$oldItemName , $full_path.$newItemName ) )
			{
				return 'DONE'  ;
			}
			
			return 'UNKNOWN_FAILURE' ;
		}
		
		
		function deleteFtpItem ($folder,$name)
		{
			$folder = $this->getFtpPath ( $folder );
			
			if (!$this->isAllowed( $folder , self::WRITE_ACTION ) )
			{
				return 'FORBIDDEN' ;
			}
			
			$name = urldecode( $name ) ;
			
			$full_path = ROOTPATH . $folder ;
			
			if ( !is_dir ( $full_path.$name ) && !is_file ( $full_path.$name ) )
			{
				return 'ITEM_NOT_EXISTS';
			}
			
			if ( is_dir ( $full_path.$name ) )
			{
				rmdir($full_path.$name);
			} else {
				unlink($full_path.$name);
			}
			
			return 'DONE' ;
		}
		
		
		
		/**
		 * upload an item to the server, in the "media/" folder<br />
		 * the data is in $_FILES['Filedata'] by default
		 */
		function uploadFtpItem ($folder,$name,$session_id=NULL,$fileDataPropertyName='Filedata',$rootFolder = null)
		{
			if ($this->logger) $this->logger->debug("uploadFtpItem ($folder,$name,$session_id)") ;
			if ($this->logger) $this->logger->debug(print_r($_GET,TRUE)) ;
			$folder = $this->getFtpPath ( $folder, $rootFolder );
			return $this->uploadItem ($folder,$name,$session_id,$fileDataPropertyName);
		}
		/**
		 * upload an item to the server<br />
		 * the data is in $_FILES['Filedata'] by default
		 */
		function uploadItem ($folder,$name,$session_id=NULL,$fileDataPropertyName='Filedata')
		{
			if ($this->logger) $this->logger->debug("uploadItem ($folder,$name,$session_id)") ;
			//if ($session_id) session_id($session_id);
			//instance of file_system_tools
		   // session_start () ;
			// make sure we can access the file
			if (!$this->isAllowed( $folder .urldecode( $name ) , file_system_tools::WRITE_ACTION, TRUE ) )
			{
				if ($this->logger) $this->logger->debug("uploadItem right access ko - FORBIDEN") ;
/*				require_once(ROOTPATH . "/cgi/amf-core/util/Authenticate.php");
				$path = ROOTPATH . $folder .urldecode( $name ) ;
				$path = $this->sanitize($path, TRUE);
				$isAllowed = false;
				$auth = new Authenticate();
				$isAdmin = $auth->isUserInRole(AUTH_ROLE_USER);
*/				return 'UNAUTH '.$folder .urldecode( $name )." , isAdmin=$isAdmin , ".AUTH_ROLE_USER;//." , ".$_FILES['Filedata']['tmp_name']." ----- ".print_r($_FILES['Filedata'],TRUE) ;
			}
			if ($this->logger) $this->logger->debug("uploadItem right access ok") ;
		
			
			
			// Attempt to set the maximum upload size to 10M (sample size) 
			// Hosting services frequently prevent overriding the default settings in php.ini
			// In this case, an alternate possibility is adding the following line to the .htaccess file:
			// php_value upload_max_filesize 10M
			// ini_set('upload_max_filesize', '10M');  
		
			// Try to limit the upload time to two minutes. As above, whether we can determine these settings 
			// at runtime is dependent upon server configuration
			// ini_set('max_input_time', 120);
			
			
			if ( !empty($_FILES[$fileDataPropertyName]) )
			{
				// compute file path
				$uploadFile = ROOTPATH . $folder .urldecode( $name );
				
				// check ext
				$ext = pathinfo($uploadFile, PATHINFO_EXTENSION); 
				if ( $ext == 'php' || $ext == 'asp' )
				{
					return 'UNAUTH wrong file type' ;
				}
				
				// rename uploaded file
				move_uploaded_file($_FILES[$fileDataPropertyName]['tmp_name'], $uploadFile);
			}
			else
				return 'File data missing, it is expected in Files["'.$fileDataPropertyName.'"]' ;
		}
		
		
		/*
			Function: listFolderContent 
			List the files contained in a given folder, and optionnally contained in the folders inside the given folder.
			 
			Parameters :
				$folder - the given folder to list (REQUIRED)
				$isRecursive - if set to true, will also list the contents of the folders which are inside the given folder (Optional: default true)
				$filter - use it to filter the listed contents by their extensions. Must be an array of the extension you want to keep, ex : array('txt, 'jpg') or just array('jpg') (Optional: default null)
				$orderBy - use it to order the listed contents by a given property (see properties list below) (Optional: default "")
					const itemTypeField="item type";
					const itemSizeField="item size";
					const itemReadableSizeField="item readable size";
					const itemNameField="item name";
					const itemNameNoExtField="item name no extension";
					const itemModifDateField="item last modification date";
					const itemWidthField="item width";
					const itemHeightField="item height";
					const itemContentField="itemContent";
				$reverseOrder - use it to reverse the order of the list (when orderBy is used) (Optional: default false)
				$typeFilter - the type of item we want to get: 01 for files, 10 for folders and 11 for both (numbers in binary base). Default is 1 for files.  For folders you would have to set it to 2 in decimal base, and 3 for both. 
		*/
		function listFolderContent( $folder , $isRecursive = true , $filter = null , $orderBy = "" , $reverseOrder = false, $typeFilter=1 )
		{
			
			$folder = urldecode( $folder ) ;

			$resArray = array() ;
			
			if ($this->logger) $this->logger->debug("listFolderContent($folder) ") ;
			
			if ( $this->checkRights( $this->sanitize( $folder ), self::USER_ROLE, self::READ_ACTION ) )
			{
				$tmpFolder = opendir( $folder ) ;
				
				$tmp = 0 ;
				
				while ( false!== ($tmpFile = readdir( $tmpFolder )) ) 
				{
					if( is_dir( $folder."/".$tmpFile ) && ( ( $typeFilter & 2 ) || $isRecursive ) )
					{
						if( strpos( $tmpFile, '.' ) !== 0 ) //don't list folders starting with '.'
						{
							$resArray[$tmp][self::itemNameField] = $tmpFile ;
							$resArray[$tmp][self::itemTypeField] = "folder" ;
							
							if( $isRecursive )
								$resArray[$tmp][self::itemContentField] = $this->listFolderContent($folder.'/'.$tmpFile.'/', $isRecursive, $filter, $orderBy, $reverseOrder, $typeFilter);
						}
					}
				
					if ( is_file( $folder."/".$tmpFile ) && ( $typeFilter & 1 ) )
					{
						$FileNameTokens = explode( '.' , $tmpFile ) ;
						$ext = strtolower ( array_pop ( $FileNameTokens ) ) ;
						
						if( $filter == null || in_array( $ext , array_map('strtolower', $filter ) ) )
						{
							$resArray[$tmp][self::itemNameField] = $tmpFile ;
							$resArray[$tmp][self::itemNameNoExtField] = implode(".", $FileNameTokens) ;
							$resArray[$tmp][self::itemModifDateField] = date ("Y-m-d\H:i:s", filemtime($folder."/".$tmpFile)) ;
							$resArray[$tmp][self::itemSizeField] = filesize($folder."/".$tmpFile) ;
							$resArray[$tmp][self::itemReadableSizeField] = $this->readableFormatFileSize(filesize($folder."/".$tmpFile)) ;
							$resArray[$tmp][self::itemTypeField] = "file" ;


						//Try block is used to circumvent a bug when the file is nor a folder nor an image
						//(could throw an exception)
						try
						{
							$imageSize = getimagesize ($folder."/".$tmpFile) ;
						} catch(Exception $e)
						{
							$imageSize = null;
						}
							if( $imageSize )
							{
								$resArray[$tmp][self::itemWidthField] = $imageSize[0] ;
								$resArray[$tmp][self::itemHeightField] = $imageSize[1] ;
								$resArray[$tmp][self::itemImageTypeField] = $imageSize["mime"] ;
							}
							
							$resArray[$tmp]["ext"] = $ext ;
						}
						
					}

					$tmp++;
				}
				
				closedir( $tmpFolder ) ;
				
				// Order by
				if( $orderBy != "" )
				{
					// First we check if the orderBy param is one of the constants
					if( $orderBy == self::itemTypeField || $orderBy == self::itemSizeField || $orderBy == self::itemReadableSizeField ||
						$orderBy == self::itemNameField	|| $orderBy == self::itemNameNoExtField || $orderBy == self::itemModifDateField ||
						$orderBy == self::itemWidthField ||	$orderBy == self::itemHeightField || $orderBy == self::itemContentField )
					{
						
						// We check the $reverseOrder
						$order = SORT_DESC ;
						if( !$reverseOrder )
							$order = SORT_ASC ;
						
						// Then we sort
						$tmp = Array() ;
						foreach( $resArray as $res )
							$tmp[] = strtolower( $res[ $orderBy ] ) ;
							
						array_multisort( $tmp , $order , $resArray ) ;
					}
				}
			}
			else
			{
				if ($this->logger) $this->logger->emerg("listFolderContent($folder) - not allowed to list this folder ");
			}
			
			$this->logger->debug("listFolderContent--return ".print_r($resArray,true));
			return $resArray;
		}	

		/**
		 * from http://fr.php.net/realpath
		 * Because realpath() does not work on files that do not
		 * exist, I wrote a function that does.
		 * It replaces (consecutive) occurences of / and \\ with
		 * whatever is in DIRECTORY_SEPARATOR, and processes /. and /.. fine.
		 * Paths returned by get_absolute_path() contain no
		 * (back)slash at position 0 (beginning of the string) or
		 * position -1 (ending)
		 */
		function get_absolute_path($path) {
			$path = str_replace(array('/', '\\'), DIRECTORY_SEPARATOR, htmlentities(strip_tags($path)));
			$parts = array_filter(explode(DIRECTORY_SEPARATOR, $path), 'strlen');
			$absolutes = array();
			foreach ($parts as $part) {
				if ('.' == $part) continue;
				if ('..' == $part) {
					array_pop($absolutes);
				} else {
					$absolutes[] = $part;
				}
			}
			return implode(DIRECTORY_SEPARATOR, $absolutes);
		}
		
		
		/* isAllowed
		 * check if user is allowed to access (read or write) a file  given the user's role - works in combination with checkRights()
		 * @param $folder	the folder 
		 * @param $action	the type of action : self::READ_ACTION or self::WRITE_ACTION
		 * @param $allowNotExistingFiles	
		 * returns false if role is not allowed to do the action
		 */
		function isAllowed ( $folder , $action, $allowNotExistingFiles = FALSE)
		{
			require_once(ROOTPATH . "/cgi/amf-core/util/Authenticate.php");
			$path = ROOTPATH . $folder;
			$path = $this->sanitize($path, $allowNotExistingFiles);
			
			// echo "ROOTPATH . $folder -> $path<br/>";

			$isAllowed = false;
			$auth = new Authenticate();
			$isAdmin = $auth->isUserInRole(AUTH_ROLE_USER);
			if($isAdmin){
				return $this->checkRights($path, self::ADMIN_ROLE, $action);
			}else{
				return $this->checkRights($path, self::USER_ROLE, $action);
			}
		}
		
		
		/* checkRights
		 * check if user is allowed to access (read or write) a file  given the user's role
		 * @param $filepath	the path to the file 
		 * @param $usertype	the type of user : self::ADMIN_ROLE or self::USER_ROLE
		 * @param $action	the type of action : self::READ_ACTION or self::WRITE_ACTION
		 * returns false if role is not allowed to do the action
		 */
		function checkRights($filepath,$usertype,$action){
			$serverConfig = new server_config();
//			return $filepath." - ".$this->isInFolder($filepath,"contents/");
			// debug trace
			if ($this->logger) $this->logger->debug("checkRights($filepath,$usertype,$action) --  ".self::ADMIN_ROLE);
			
			switch($action){
				case self::READ_ACTION:
					// if user is an admin
					if ($usertype==self::ADMIN_ROLE){
						// for each path
						foreach ($serverConfig->admin_read_ok as $folderName){
							// if the file is below this path, return true
							if ($this->isInFolder($filepath,$folderName)){
								if ($this->logger) $this->logger->debug("checkRights return true");
								return true;
							}
						}
					}
					// for each path
					foreach ($serverConfig->user_read_ok as $folderName){
						$isInFolder = $this->isInFolder($filepath,$folderName);
						if ($this->logger) $this->logger->debug("checkRights isInFolder($filepath,$folderName) -> " . $isInFolder);
						// if the file is below this path, return true
						if ($isInFolder){
							if ($this->logger) $this->logger->debug("checkRights return true");
							return true;
						}
					}
				break;
				case self::WRITE_ACTION:
					// if user is an admin
					if ($usertype==self::ADMIN_ROLE){
						// for each path
						foreach ($serverConfig->admin_write_ok as $folderName){
							// if the file is below this path, return true
							if ($this->isInFolder($filepath,$folderName)){
								if ($this->logger) $this->logger->debug("checkRights return true");
								return true;
							}
						}
					}
					// for each path
					foreach ($serverConfig->user_write_ok as $folderName){
						// if the file is below this path, return true
						if ($this->isInFolder($filepath,$folderName)){
							if ($this->logger) $this->logger->debug("checkRights return true");
							return true;
						}
					}
				break;
			}
			// the file is not under a convenient path
			if ($this->logger) $this->logger->info("checkRights($filepath,$usertype,$action) returns false - the file is not under a convenient path");
			return false;
		}		
	}
?>