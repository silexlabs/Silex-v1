<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once("rootdir.php");
	require_once("silex_config.php");
	require_once("logger.php");
	//loads, parses and holds the config of the silex server
	class server_config{
		var $logger = null;	
	
		var $silex_server_ini = null;
		var $silex_client_ini = null;
		
		var $admin_write_ok;
		var $admin_read_ok;
		var $user_write_ok;
		var $user_read_ok;	
		
		var $sepCharForDeeplinks="."; // read in ini file
	
		// ***********
		// constructor
		function server_config(){
			$this->logger = new logger("server_config");
            $conf = new silex_config;
			// **
			// read ini files
			// silex_server.ini
				$fullPath = ROOTPATH . "conf/silex_server.ini";
				if(!file_exists($fullPath)){
					$this->logger->alert("wanted conf file $fullPath does not exist");
				}else{
					$parsedConfig = $conf->parseConfig( $fullPath, 'inicommented');        
					$parsedConfigAsArray = $parsedConfig->toArray();
					$confRoot = $parsedConfigAsArray["root"];
					if ($confRoot){
						$this->silex_server_ini = $confRoot;
					}
				}
		
							
			// **
			// rights
			$this->admin_write_ok=explode(",", $this->silex_server_ini["admin_write_ok"]);
			$this->admin_read_ok=explode(",", $this->silex_server_ini["admin_read_ok"]);
			$this->user_write_ok=explode(",", $this->silex_server_ini["user_write_ok"]);
			$this->user_read_ok=explode(",", $this->silex_server_ini["user_read_ok"]);
			
			// **
			// read client side ini files
			// silex.ini (client side ini file)
			$this->silex_client_ini = Array();
			$client_ini_files = explode(",", $this->silex_server_ini["SILEX_CLIENT_CONF_FILES_LIST"]);
			
			foreach ($client_ini_files as $ini_file_name){
				$fullPath = ROOTPATH . $ini_file_name;
				if(!file_exists($fullPath)){
					$this->logger->alert("wanted conf file $fullPath does not exist");
				}else{
					$parsedConfig = $conf->parseConfig($fullPath, 'flashvars');        
					$parsedConfigAsArray = $parsedConfig->toArray();
					$confRoot = $parsedConfigAsArray["root"];
					if ($confRoot){
						$this->silex_client_ini = array_merge($this->silex_client_ini,$confRoot);
					}
				}
			}
			
			// init constants from ini file
			if (isset($this->silex_client_ini["sepchar"])){
				$this->sepCharForDeeplinks=$this->silex_client_ini["sepchar"];
			}
		
		}
		/**
		 * this function returns the contents folder, or the contents-themes folder, or the contents-utilities folder, depending on which one contains the provided id_site<br />
		 * the contents, contents-themes and contents-utilities folders have their values in conf/silex_server.ini (CONTENTS_THEMES_FOLDER, CONTENTS_UTILITIES_FOLDER and CONTENT_FOLDER)
		 */
		function getContentFolderForPublication($id_site)
		{
			$contentFolder = $this->silex_server_ini["CONTENT_FOLDER"];
			// if it is not in "contents/", return the themes folder
			if(!file_exists(ROOTPATH.$contentFolder.$id_site))
			{
				$contentFolder = $this->silex_server_ini["CONTENTS_UTILITIES_FOLDER"];
				if(!file_exists(ROOTPATH.$contentFolder.$id_site))
				{
					$contentFolder = $this->silex_server_ini["CONTENTS_THEMES_FOLDER"];
				}
			}
			return $contentFolder;
		}
	}
	
?>
