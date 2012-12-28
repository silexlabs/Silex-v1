<?php
/*
	this file is part of SILEX
	SILEX : RIA developement tool - see http://silex-ria.org/

	SILEX is (c) 2004-2007 Alexandre Hoyau and is released under the GPL License:

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License (GPL)
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
	GNU General Public License for more details.
	
	To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
set_include_path(get_include_path() . PATH_SEPARATOR . "../../");
set_include_path(get_include_path() . PATH_SEPARATOR . "../library/");
set_include_path(get_include_path() . PATH_SEPARATOR . "../includes/");
set_include_path(get_include_path() . PATH_SEPARATOR . "./cgi/includes/");


require_once("cgi/includes/domxml.php");
/** Zend_Debug */
require_once 'Zend/Debug.php';
//Config
require_once("silex_config.php");
require_once("server_config.php");
require_once("password_manager.php");
require_once("file_system_tools.php");

require_once("rootdir.php");
require_once("logger.php");
require_once("site_editor.php");
require_once("server_content.php");

require_once("plugin_manager.php");
require_once("HookManager.php");
require_once("config_editor.php");
require_once("ComponentManager.php");
require_once ROOTPATH.'cgi/includes/ComponentDescriptor.php';

class data_exchange
{
	
	var $logger = null;
	// ***********
	// constructor
	function data_exchange()
	{
		// fix bug "date.timezone warning message" which screw up amfphp
		// with the warning message "PHP Warning: PHP Startup: It is not safe to rely on the system's timezone settings. You are *required* to use the date.timezone setting or the date_default_timezone_set() function."
		date_default_timezone_set("America/Santiago");
		
		$this->logger = new logger("data_exchange");
		// **
		require_once("data_exchange.methodTable.php");
		$hookManager = HookManager::getInstance();
		$plugin_manager = new plugin_manager();
		$config_editor = new config_editor();

		$serverConfig = new server_config(); 

		// create silex plugins 
		$silexPluginsConf = $config_editor->readConfigFile($serverConfig->silex_server_ini['SILEX_PLUGINS_CONF'], "phparray");
		$plugin_manager->createActivePlugins($silexPluginsConf, $hookManager);		
		
		
		
	}


	// ***********
	
	/**
	 * used by the manager to list languages and by index.php
	 */
	function getLanguagesList()
	{
		$s = new server_content();
		return $s->getLanguagesList();
	}
	function listLanguageFolderContent()
	{
		$s = new server_content();
		return $s->listLanguageFolderContent();
	}
	function listWebsiteFolderContent($id_site){
		$s = new server_content();
		return $s->listWebsiteFolderContent($id_site);
	}
	function listToolsFolderContent($path){
		$s = new server_content();
		return $s->listToolsFolderContent($path);
	}
	function listFtpFolderContent($path,$isRecursive=true){
		$s = new server_content();
		return $s->listFtpFolderContent($path,$isRecursive);
	}
	function listFolderContent($path,$isRecursive=true, $filter=null, $orderBy = "" , $reverseOrder = false, $typeFilter = 11){
		$s = new server_content();
		return $s->listFolderContent($path,$isRecursive, $filter, $orderBy, $reverseOrder, $typeFilter);
	}
	/*
	Create a new folder for FtpClient
	*/
	function createFtpFolder($path,$newFolderName){
		
		$f = new file_system_tools();
		return $f->createFtpFolder($path,$newFolderName);
	}
	/*
	Rename an item for FtpClient
	*/
	function renameFtpItem($path,$oldItemName,$newItemName){
		
		$f = new file_system_tools();
		return $f->renameFtpItem($path,$oldItemName,$newItemName);
	}
	/*
	Delete an item for FtpClient
	*/
	function deleteFtpItem ( $path , $itemName )
	{
		$f = new file_system_tools();
		return $f->deleteFtpItem($path , $itemName);
	}
	/*
	Rename an item for FtpClient
	*/
	function uploadFtpItem($path,$filename){
		
		$f = new file_system_tools();
		return $f->uploadFtpItem($path,$filename);
	}
    /*
    merge different configs into 1 flash vars like file
    */
	function getDynData($wesiteInfo,$filesList){
		if ($this->logger) $this->logger->debug("getDynData(" . print_r(func_get_args(), true));

		$configEditor = new config_editor();
		return $configEditor->mergeConfFilesIntoFlashvars($filesList);
	}
    /** 
	 * delete a website
     */
    function deleteWebsite($id_site){
		$s = new site_editor();
		return $s->deleteWebsite($id_site);
    }
    /** 
	 * create a website
     */
    function createWebsite($id_site){
		$s = new site_editor();
		return $s->createWebsite($id_site);
    }
    /** 
	 * rename a website
     */
    function renameWebsite($id_site,$newId){
		$s = new site_editor();
		return $s->renameWebsite($id_site,$newId);
    }
    /**
    * deprecated. this is still used by the website config tool, and createWebsite so leave it for now.
    */
	function writeWebsiteConfig($websiteInfo,$id_site){
		$s = new site_editor();
		return $s->writeWebsiteConfig($websiteInfo, $id_site);
	}
	
	function duplicateWebsite($id_site,$newName){
		$s = new site_editor();
		return $s->duplicateWebsite($id_site,$newName);
	}
	
	/*
	Function: moveWebsiteInThemes
	Creates a theme from an existing website
	
	Parameters:
		$id_site - id of the site to copy
		$themeName - name of the theme to create
	
	Author: Thomas Fétiveau, http://www.tofee.fr/ or thomas.fetiveau.tech [at] gmail.com
	*/
	function moveWebsiteInThemes($id_site,$themeName)
	{
		$s = new site_editor();
		return $s->moveWebsiteInThemes($id_site,$themeName);
	}
	
	function getWebsiteConfig($id_site,$mergeWithServerConfig=false){
		$s = new site_editor();
		return $s->getWebsiteConfig($id_site,$mergeWithServerConfig);
	}
	
	/*
		Function: getSiteThumb
		Get the thumb of a site
		
		Parameters:
			$siteName - the name of the site
			
		Returns:
		The informations of the thumb of the given site
	*/
	function getSiteThumb($siteName) {
		$s = new site_editor();
		return $s->getSiteThumb($siteName);
	}
	
	/*
		Function: getPluginParameters
		Get the parameters of a given plugin for a given site/server/manager's configuration
		
		Parameters:
			$pluginName - the name of the plugin
			$conf - configuration of a site/server/manager for which the plugin is being used
		
		Returns:
		An array (ready to use in a RichTextList DataProvider) containing the parameters of the plugin
	*/
	function getPluginParameters($pluginName, $conf)
	{
		$plugin_manager = new plugin_manager();
	
		$plugin = $plugin_manager->createPlugin($pluginName, $conf);
		
		if($plugin !== null)
			return $plugin->getParamTable();
			
		return array();
	}
	
	/*
		Funcrion: getPluginAdminPage
		Get the plugin's administration page.
		
		Parameters:
			$pluginName - the name of the plugin
			$conf - the configuration of the site/server/manager for which the plugin is being used
			$siteName - optional, the name of the site for which the plugin is activated/used
		
		Returns:
		The html code of the administration page of the plugin
	*/
	function getPluginAdminPage($pluginName, $conf, $siteName=null)
	{
		$plugin_manager = new plugin_manager();
		
		$plugin = $plugin_manager->createPlugin($pluginName, $conf);
		
		if($plugin !== null)
		{
			return $plugin->getAdminPage($siteName);
		}
		
		$serverConfig = new server_config();
		return $serverConfig->silex_server_ini['MISSING_PLUGIN_ERROR'];
	}	
	
	/*
		Function: getPluginsList
		Service that lets you get the list of installed plugins for a given scope
		
		Parameters:
			$scope - the scope for which we want the plugins list. The scope can be manager (100), site (010) or server (001) or mixes of them, ex: 011 => list of plugins applicable to a site or to the entire silex server.
			$conf - optional, can be useful for getting some plugins descriptions
		
		Returns:
		The list of installed plugins for the given scope.
	*/
	function getInstalledPluginsList($scope, $conf=null)
	{
		$result = array();
		
		$plugin_manager = new plugin_manager();
				
		$installedPlugins = $plugin_manager->listInstalledPlugins($scope);
		
		foreach($installedPlugins as $installedPluginName)
		{
			$plugin = $plugin_manager->createPlugin($installedPluginName, $conf);
			$result[] = array( "label" => $plugin->getDescription() , "name" => $installedPluginName );
		}
		
		return $result;
	}
	
	/**
	 * interface for calc_dir_size
	 * returns the size of a folder in a readable form
	 */
	function getFolderSize($folder){
		$fst = new file_system_tools();
		return $fst->getFolderSize($folder);
	}
	
    /**
    * filePath : example conf/silex.ini. will be concatenated with root
    * fileFormat: see library/Config.php. example: phpconstants , flashvars
    * dataToMerge: an array with key, values
    */
    function updateConfigFile($filePath, $fileFormat, $dataToMerge){
		$c = new config_editor();
		return $c->updateConfigFile($filePath, $fileFormat, $dataToMerge);
    }
	
    /**
    * filePath : example conf/silex.ini. will be concatenated with root
    * fileFormat: see library/Config.php. example: phpconstants , flashvars
    * returns array
    */
    function readConfigFile($filePath, $fileFormat){
		$c = new config_editor();
		return $c->readConfigFile($filePath, $fileFormat);
	}
	
	/**
	 * write xml data into a file
	 */
	function writeSectionData($xmlData, $xmlFileName,$sectionName, $id_site, $seoObject, $domObject){
		$s = new site_editor();
		return $s->writeSectionData($xmlData, $xmlFileName,$sectionName, $id_site, $seoObject, $domObject);
	}
	
	/**
	 * rename a page and its preview
	 */
	function renameSection($siteName, $oldSectionName, $newSectionName){	
		$s = new site_editor();
		return $s->renameSection($siteName, $oldSectionName, $newSectionName);
	}

	/**
	 * Duplicate a page<br/>
	 * duplicate the preview of the page if there is one (jpg or png)
	 */
	function duplicateSection($siteName, $oldSectionName, $newSectionName){	
		$s = new site_editor();
		return $s->duplicateSection($siteName, $oldSectionName, $newSectionName);
	}
	/**
	 * create an empty xml file or duplicate from existing template
	 */
	function createSection($siteName, $newSectionName){	
		$s = new site_editor();
		return $s->createSection($siteName, $newSectionName);
	}
	/**
	 * delete a page<br />
	 * delete the preview of the page if there is one (jpg or png)
	 */
	function deleteSection($siteName, $sectionName){	
		$s = new site_editor();
		return $s->deleteSection($siteName, $sectionName);
	}
	/**
	 * save the structure of the publication
	 * usually XML data comes from the PublicationStructureEditor (flex) directly
	 * save a .draft.xml (structure with the deactivated pages) and a .xml (structure without the deactivated pages)
	 */
	function savePublicationStructure($siteName, $xmlContent, $xmlContentPublished){	
		$s = new site_editor();
		return $s->savePublicationStructure($siteName, $xmlContent, $xmlContentPublished);
	}
	/**
	 * returns the .draft.xml (structure with the deactivated pages)
	 */
	function loadPublicationStructure($siteName,$isPublishedVersion = FALSE){	
		$s = new site_editor();
		return $s->loadPublicationStructure($siteName,$isPublishedVersion);
	}

	// **
	// authentication services
	function doLogin(){
		if ($this->logger) $this->logger->debug("doLogin ok");
		return true;
	}
	function doLogout(){
		Authenticate::logout();
		if ($this->logger) $this->logger->debug("doLogout");
		return true;
	}	
	// This function will authenticate the client
	// before return the value of method call
	function _authenticate($user, $pass){
		$p = new password_manager;
		$this->logger->debug(" _authenticate($user, $pass)");
		return $p->authenticate($user, $pass);
	}

	// **
	// find the desired records
	function getSectionSeoData($id_site,$deeplink,$urlBase=null){
		$s = new site_editor();
		return $s->getSectionSeoData($id_site,$deeplink,$urlBase);
	}
	
	function setPassword($login, $password){
		$p = new password_manager;
		return $p->setPassword($login, $password);
	}	
	
	function getLogins(){
		$p = new password_manager;
		return $p->getLogins();
	}
	
	function deleteAccount($login){
		$p = new password_manager;
		return $p->deleteAccount($login);
	}
	
	/**
	* get all the component descriptors for the components available in the active plugins
	*/
	function getComponentDescriptors($id_site){
		$s = new site_editor();
		$hookManager = HookManager::getInstance();
		$plugin_manager = new plugin_manager();
		$conf = $s->getWebsiteConfig($id_site);
		$plugin_manager->createActivePlugins($conf, $hookManager);
		
		$cm = new ComponentManager();
		return $cm->getComponentDescriptors();
	}
	
	/*
		Function: getFonts
		get the list of fonts installed on the Silex server
		
		Returns:
		The list of installed fonts.
	*/
	function getFonts()
	{
		$this->logger->debug("getFonts() - enter");
		$resultList = array(); $rawList = array();
		
		$serverContent = new server_content();
		$rawList = $serverContent->listFontsFolderContent();
		
		foreach($rawList as $fontFile)
		{
			$this->logger->debug("getFonts - ".$fontFile[file_system_tools::itemNameField]);
			
			if( strlen($fontFile[file_system_tools::itemNameField]) > 11 
				&& substr($fontFile[file_system_tools::itemNameField], -11) == "_import.swf")  // matching _import.swf ?
			$resultList[] = array( "label" => substr($fontFile[file_system_tools::itemNameField], 0, strlen($fontFile[file_system_tools::itemNameField])-11) , "data" => substr($fontFile[file_system_tools::itemNameField], 0, strlen($fontFile[file_system_tools::itemNameField])-11) );
			
			else
				$this->logger->debug("getFonts - ".$fontFile[file_system_tools::itemNameField]." not matching _import.swf");
		}
		
		return $resultList;
	}
}
?>