<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	require_once("rootdir.php");
	require_once("server_config.php");
	require_once("logger.php");
	require_once("file_system_tools.php");
	//class for retrieving info about the server's available content: languages, plugins, sites etc.
	class server_content{
		var $logger = null;
		var $server_config = null;
		
		
		function server_content(){
			$this->logger = new logger("server_content");
			$this->server_config = new server_config();
		
		}
		/**
		 * used by the manager to list languages and by index.php
		 */
		function getLanguagesList()
		{
			if ($this->logger) $this->logger->debug("getLanguagesList() ");
			$res = "";
			$_array=$this->listLanguageFolderContent();
			foreach( $_array as  $file)
			{
				if($res!="")
					$res .= ",";
				$res .= $file[file_system_tools::itemNameNoExtField];
			}
			return $res;
		}
		function listLanguageFolderContent()
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listLanguageFolderContent() ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["LANG_FOLDER"],false);
			return $_array;
		}
		function listWebsiteFolderContent($id_site)
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listWebsiteFolderContent($id_site) ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["CONTENT_FOLDER"].$id_site."/");
			return $_array;
		}
		function listToolsFolderContent($path)
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listToolsFolderContent($path) ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["TOOLS_FOLDER"].$path);
			return $_array;
		}
		
		/*
			Function: listPluginsFolderContent
			Lists the names of the directories which are in the root of the plugins directory
			
			Returns
			An array with the names of the plugins directories
		*/
		function listPluginsFolderContent()
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listPluginsFolderContent() ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["PLUGINS_FOLDER"],false,null,"",false,2);
			return $_array;
		}
		
		function listFtpFolderContent($path, $isRecursive=true)
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listFtpFolderContent($path) ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["MEDIA_FOLDER"].$path,$isRecursive);
			return $_array;
		}
		function listFolderContent($path, $isRecursive=true, $filter=null , $orderBy = "" , $reverseOrder = false, $typeFilter=1)
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listFolderContent($path) ");
			$_array=$fst->listFolderContent(ROOTPATH . $path,$isRecursive, $filter , $orderBy , $reverseOrder, $typeFilter);
			return $_array;
		}
		
		/*
			Function: listFontsFolderContent
			Lists the files within the fonts directory
			
			Returns
			An array with the names of the files within the fonts directory
		*/
		function listFontsFolderContent()
		{
			$fst = new file_system_tools();
			if ($this->logger) $this->logger->debug("listFontsFolderContent() ");
			$_array=$fst->listFolderContent(ROOTPATH . $this->server_config->silex_server_ini["FONTS_FOLDER"],false);
			return $_array;
		}
	}
?>