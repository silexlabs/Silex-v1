<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

	require_once ROOTPATH.'cgi/includes/silex_config.php';

	/**
	 *	This classes allows plugins localisation, exposing static method to get access to lang file url and data, and listing
	 *	the available languages of the plugins
	 */
	class LangManager{
		
		/**
		* used for storage in the hooks array
		*/
		const LIST_LANG_HOOK = "listLangHook";
		
		/*
		* a const for the ini file format
		*/
		const INI_FILE_FORMAT = "ini";
		
		/*
		* a const for the container of ini file
		*/
		const INI_CONTAINER = "inicommented";
		
		/**
		* list all available plugins lang, added via the
		* addLang() method
		*/
		private $availableLanguages;
		
		/**
		* private instance of singleton
		*/
		private static $instance = NULL;
		
		/**
		 * constructor
		 */
		private function __construct(){
			$this->availableLanguage = Array();
		}
		
		/*
		* return the instance of the LangManager
		*/
		public static function getInstance() {
			if (self::$instance == NULL) {
				self::$instance = new LangManager();
			}
			return self::$instance;
		}
		
		/*
		*	Looks for the plugin's lang file in ini format
		*/
		public function getLangFile($pluginName, $defaultLanguage = null)
		{
			//looks first for a corresponding .ini lang file
			$ret = $this->doGetLangFile($pluginName, $defaultLanguage, LangManager::INI_FILE_FORMAT);
			if ($ret != false)
			{
				return $ret;
			}
			
			return false;
		}
		
		/*
		Function: doGetLangFile
		returns the lang file url of the given format by looking in the plugin's "lang/" folder
		*/
		private function doGetLangFile($pluginName, $defaultLanguage, $fileType) 
		{
			//get a reference to the server config var
			//global $serverConfig;
			$serverConfig = new server_config();
			//get the admin lang
			$silexAdminLang = $serverConfig->silex_server_ini['SILEX_ADMIN_DEFAULT_LANGUAGE'];
			
			//looks for a 'lang folder' in the plugin folder
			$langFolder = ROOTPATH.'plugins/'.$pluginName.'/lang/';
			//if this directory exists
			if (file_exists($langFolder))
			{	
				//looks for a file 
				$langFile = ROOTPATH.'plugins/'.$pluginName.'/lang/'.$silexAdminLang.".".$fileType;
				//if the file exists
				if (file_exists($langFile))
				{
					//return it's URL
					return $langFile;
				}
				
				//else if the file is not found,
				//if a default language has been set for the plugin,
				else if(isset($defaultLanguage))
				{
					//looks for the file matching the default language
					$defaultLangFile = ROOTPATH.'plugins/'.$pluginName.'/lang/'.$defaultLanguage.".".$fileType;
					//if the file exists
					if (file_exists($defaultLangFile))
					{
						//return it's URL
						return $defaultLangFile;
					}
				}
				
				//else, as a last resort, load the first .ini file in the "lang/" folder
				else
				{
					//list the lang folder array
					$dir = dir($langFolder);
					$files = array();
					//stores each ".ini" item of the lang folder in an array
					while($name =  $dir->read())
					{
						if (substr($name, -4) == LangManager::INI_FILE_FORMAT)
						{
							$files[] = $name;
						}
					}
					
					//if at least one file is found, return the first item of the array
					if (isset($files[0]))
					{
						return $files[0];
					}
					
				}
			}
			
			//if no file or folder has been found, return false
			return false;
		}
		
		/*
		*	return an assoc array containing all the data of the file
		*	given as a parameter or deduce it from the name of the plugin,
		*	then return it
		*/
		public function getLangObject($pluginName, $langFile = null)
		{
			if (isset($langFile))
			{
				return $this->doGetLangObject($langFile);
			}
			
			else
			{
				$langFile = $this->getLangFile($pluginName);
				return $this->doGetLangObject($langFile);
			}
		}
		
		/*
		*	Find the type of the given file and returned a parsed assoc array of the 
		*	file's data
		*/
		private function doGetLangObject($langFile)
		{
			//get a new silexConfig object that will parse the lang files
			$silexConfig = new silex_config();
			
			//extract the extension of the file
			$fileExtension = substr($langFile, strrpos($langFile, ".")+1); 
			switch ($fileExtension)
			{
				//get the localised strings in an assoc array
				case LangManager::INI_FILE_FORMAT:
				$parsedConfig = $silexConfig->parseConfig($langFile, LangManager::INI_CONTAINER);
				$parsedConfigAsArray = $parsedConfig->toArray();
				$confRoot = $parsedConfigAsArray["root"];
				return $confRoot;
				
				default:
				return false;
			}
		}
		
		/*
		* add the given langs to the lang array if they aren't listed already	
		*/
		public function addLang($pluginName, $langs)
		{
			$this->availableLanguage[$pluginName] = $langs;
		}
		
		/*
		* return the available lang array
		*/
		public function getLang($pluginName = null)
		{
			if (isset($pluginName))
			{
				return $this->availableLanguage[$pluginName];
			}
			else
			{
				return $this->availableLanguage;
			}
		}
		
		
	}
?>