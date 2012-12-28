<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html

Author: Thomas Fétiveau (¯abojad)  <http://tofee.fr> or <thomas.fetiveau.tech@gmail.com>
*/

require_once("logger.php");

/*
Class: plugin_manager
This class describes the plugin manager, that instanciates the plugins for silex sites when they initialize
*/
class plugin_manager
{
	/*
		Variable: $logger
		reference to a logger object
	*/
	private $logger = null;
	

	/*
		Constructor: plugin_manager
	*/
	function __construct()
	{
		$this->logger = new logger("plugin_manager");
	}
	
	/*
		Function: createActivePlugins
		Creates the plugins for a given configuation (can be either a site configuration => conf.txt or the silex server plugins configuration => conf/plugins_server.php). 
		In the creation loop, the hook manager references the callback methods of these plugins.
		
		Parameters:
			$conf - the configuration of a given site
			$hook_manager - a reference to the hook manager
	*/
	public function createActivePlugins($conf, $hook_manager)
	{
		$activatedPlugins = $this->listActivatedPlugins($conf);
		
		foreach($activatedPlugins as $pluginName)
		{
			$plugin = $this->createPlugin($pluginName, $conf);
			if($plugin !== null)
				$plugin->initHooks($hook_manager);
		}
	}
	
	/*
		Function: createPlugin
		Creates a plugin according to a given site's configuration
		
		Parameters:
			$pluginName - The name of the plugin we want to create
			$conf - optional, the configuration of the site we want to create a plugin for
		
		Returns:
		A plugin object configured for a given site
	*/
	function createPlugin($pluginName, $conf=null)
	{
		if(is_file(ROOTPATH."plugins/$pluginName/index.php"))
		{
			require_once ROOTPATH."plugins/$pluginName/index.php";
			return new $pluginName($pluginName, $conf);
		}
		return null;
	}
	
	/*
		Function: listActivatedPlugins
		Lists the activated plugins for a given site
		
		Parameters:
			$conf - the configuration of the site we want its activated plugins
			
		Returns:
		an array of the activated plugins names for a given website configuration
	 */
	function listActivatedPlugins($conf)
	{
		if(isset($conf["PLUGINS_LIST"]) && $conf["PLUGINS_LIST"]!="")
			return explode("@", $conf["PLUGINS_LIST"]);
		return array();
	}
	
	/*
		Function: listInstalledPlugins
		Lists the installed plugins on the server for a given scope
		
		Parameters:
			$scope - optional, the scope for which we want the installed plugins list. Default is all scopes (manager, site and server)
			
		Returns:
		an array containing the names of the installed plugins for a given scope
	 */
	function listInstalledPlugins($scope=7)
	{
		$this->logger->debug("listInstalledPlugins($scope) - enter");
		$resultList = array(); $rawList = array();
		
		$serverContent = new server_content();
		$rawList = $serverContent->listPluginsFolderContent();
		
		foreach($rawList as $pluginFolder)
		{
			$this->logger->debug("listInstalledPlugins - ".$pluginFolder[file_system_tools::itemNameField]);
			$plugin = $this->createPlugin($pluginFolder["item name"]);
			if($plugin !== null)
				if($plugin->getPluginScope() & $scope)
					$resultList[] = $pluginFolder["item name"];
				else
					$this->logger->debug("listInstalledPlugins - ".$pluginFolder["item name"]."(".$plugin->getPluginScope().") not matching $scope");
		}
		
		return $resultList;
	}
}

?>
