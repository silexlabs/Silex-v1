<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html


File: plugin_base.php
This file contains the plugins root class

Author: Thomas Fétiveau (Żabojad)  <http://tofee.fr> or <thomas.fetiveau.tech@gmail.com>
*/

require_once ROOTPATH.'cgi/includes/HookManager.php';
require_once ROOTPATH.'cgi/includes/LangManager.php';

/*
Class: plugin_base
This is the class each Silex plugin must extend in its index.php in order to be manageable from the Silex manager application.
Each plugin must define its __construct() method in which it initializes its $paramTable variable.
*/
class plugin_base
{

	/*
		Variable: $paramTable
		Each extending class will have to intialize this variable in their contructor.
		
		This has to be an array with the following form : array ( array( "name" => "...","label" => "...", "description" => "...","value" => "...", "restrict" => "" ), ... )
		
		With :
			- name : the name of the parameter as it appears in the conf.txt of each site
			- label : a full label for the parameter
			- description : a description of the parmeter (few sentences)
			- value : the value of the parameter for a given site (or the default value)
			- restrict : the input pattern containing allowed characters; used for example in the Silex manager to type a value for the parameter. Empty string means all characters are allowed.
			- type : the type of the parameter in AS2 format (string, boolean, ...)
			- maxChars : the maximum number of characters allowed for the parameter's value
	*/
	protected $paramTable;
	
	/*
		Variable: $pluginName
		The name of the plugin as it appears in the conf.txt of each site, which is also the label of the plugin's directory.
	*/
	protected $pluginName;

	
	/*
		Variable: $pluginRelativeUrl
		plugin relative url
	*/
	protected $pluginRelativeUrl;
	
	/*
		Variable: $pluginScope
		The scope of the plugin. Can be manager (binary value: 100), site (binary value: 010) or server (binary value: 001); or a mix of them, ex: 011 (3 in decimal) => plugin applicable to a site or to the entire server
		Default value is 011 for all plugins that do not redefine this constant value.
		
		Note: cannot use a constant here because of the limitations of class constants with php versions < 5.3.0. 
	*/
	protected $pluginScope = 3;

	/*
		Constructor: plugin_base
		common to all plugins
		
		Parameters:
			$pluginName - the name of the plugin's directory
			$conf - optional, the configuration of the site/server/manager for which this plugin is activated
	 */
	public function __construct($pluginName, $conf=null)
	{
		$this->pluginName = $pluginName;
		
		$this->pluginRelativeUrl = "plugins/" . $pluginName;
		
		$this->initDefaultParamTable();
		
		$this->initConfig();
		
		if(!($conf==null))
			$this->initParameters($conf);
	}
	
	/*
		Function: getPluginScope
		Getter method for the pluginScope attribute.
		
		Returns:
		the pluginScope attribute of the plugin's class
	*/
    public function getPluginScope()
	{
        return $this->pluginScope;
    }
	
	
	/*
		Function: initDefaultParamTable
		Init the paramTable variable with the default values. May be overwritten in subclasses if the plugin is using config parameters.
	*/
	function initDefaultParamTable()
	{
		$this->paramTable = array( );
	}
	
	
	/*
		Function: initParameters
		Initialize the plugin's configuration parameters values from web site configuration. If these parameters aren't set yet for the input site configuration, it will keep the default values.
		
		Parameters:
			$siteConf - array containing the site's configuration
	*/
	public function initParameters($siteConf)
	{
		for($i = 0; $i<count($this->paramTable); $i++)
		{
			if( isset( $siteConf[ $this->paramTable[$i]["name"] ] ) )
				$this->paramTable[$i]["value"] = $siteConf[ $this->paramTable[$i]["name"] ];
		}
	}
	
	/*
		Function: initHooks
		Initialize the plugin's hooks with the hook manager. By defaut, does nothing.
	*/
	public function initHooks(HookManager $hookManager) { }
    
	/*
		Function: initConfig
		Initialise the plugin's config . By default, add a callback for the listLangHook hook
	*/
	public function initConfig(){
	
		$hookManager = HookManager::getInstance();
		$hookManager->addHook("listLangHook", array($this, 'listLangCallback'));
	}
	
	/*
		browse through the "lang/" folder of the plugin if it exists and add the found ".ini" files url to
		the LangManager
	*/
	public function listLangCallback()
	{
		//looks for a 'lang folder' in the plugin folder
			$langFolder = ROOTPATH.'plugins/'.$this->pluginName.'/lang/';
			//if this directory exists
			if (file_exists($langFolder))
			{
				//list the lang folder array
				$dir = dir($langFolder);
				$files = array();
				//stores each item of the lang folder in an array
				while($name =  $dir->read())
				{
					$files[] = $name;
				}
				
				$assocFilesArray = array();
				//for each file in the lang folder
				foreach($files as $key=>$value)
				{
				//if the extension shows that it's a '.ini' file
					if (substr($value, -4 ) == ".ini")
					{
						//store the value in an array, where the key is the local and
						//the value is the url of the file
						$fileLang = substr($value, strrpos($value, "/"));
						$fileLang = substr($fileLang, 0, strrpos($fileLang, "."));
						$assocFilesArray[$fileLang] = $langFolder.$value;
					}
				}
				
				//if there is at least one item in the array
				if(count($assocFilesArray) > 0 )
				{
					//add the plugin to the langManager array
					$langManager = LangManager::getInstance();
					$langManager->addLang($this->pluginName, $assocFilesArray);
				}
			}
	}
	
	
	/*
		Function: getAdminPage
		Generates the html code corresponding to the administration page of the plugin.
		
		Parameters:
		$siteName - optional, the name of the site the plugin is beeing administrated for
		
		Returns: 
		A string containing the html code corresponding to the administration page of the plugin
	*/
	public function getAdminPage($siteName=null)
	{
		$result = "<html><body><img src=\"plugins/$this->pluginName/plugin.png\" alt=\"$this->pluginName\" /></body></html>" ;
        return $result;
	}
	
	/*
		Function: getParamTable
		Getter for the $paramTable attribute of the plugin's class
		
		Returns:
		the parameters table of the plugin
	*/
	public function getParamTable()
	{
		return $this->paramTable;
	}
	
	/*
		Function: getDescription
		Get the description of the plugin, ie: a nicer text than the raw plugin's directory name, naming or describing the plugin. For some plugin, it can be some more sofisticatly generated string then the simple plugin's name.
		
		Returns:
		The plugin's description string. By default for all plugins, the name of plugin's directory 
	*/
	public function getDescription()
	{
		return $this->pluginName;
	}

}