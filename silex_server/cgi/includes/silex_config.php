<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
// $Id: Config.php,v 1.22 2006/12/22 00:35:34 aashley Exp $

require_once("rootdir.php");
require_once(ROOTPATH . 'cgi/includes/Config/Container.php');
require_once("logger.php");

define("GLOBALS_TYPE_STORAGE", "SILEX_CONFIG_TYPES");

$GLOBALS[GLOBALS_TYPE_STORAGE] = 
        array(
            'apache'        => array(ROOTPATH . 'cgi/includes/Config/Container/Apache.php', 'Config_Container_Apache'),
            'genericconf'   => array(ROOTPATH . 'cgi/includes/Config/Container/GenericConf.php', 'Config_Container_GenericConf'),
            'inifile'       => array(ROOTPATH . 'cgi/includes/Config/Container/IniFile.php', 'Config_Container_IniFile'),
            'inicommented'  => array(ROOTPATH . 'cgi/includes/Config/Container/IniCommented.php', 'Config_Container_IniCommented'),
            'phparray'      => array(ROOTPATH . 'cgi/includes/Config/Container/PHPArray.php', 'Config_Container_PHPArray'),
			'phpconstants'  => array(ROOTPATH . 'cgi/includes/Config/Container/PHPConstants.php', 'Config_Container_PHPConstants'),
			'flashvars'  => array(ROOTPATH . 'cgi/includes/Config/Container/FlashVars.php', 'Config_Container_FlashVars'),
            'xml'           => array(ROOTPATH . 'cgi/includes/Config/Container/XML.php', 'Config_Container_XML'),
			'gettext' => array(ROOTPATH . 'cgi/includes/Config/Container/Gettext.php', 'Config_Container_Gettext')
            );

/**
* Config
*
* This class allows for parsing and editing of configuration datasources.
* Do not use this class only to read datasources because of the overhead
* it creates to keep track of the configuration structure.
*
* @author   Bertrand Mansion <bmansion@mamasam.com>
* @package  Config
*/
//renamed to silex_config so that it fits in silex without any possible version/naming conflicts
class silex_config {

	var $logger = null;	

    /**
    * Datasource
    * Can be a file url, a dsn, an object...
    * @var mixed
    */
    var $datasrc;

    /**
    * Type of datasource for config
    * Ex: IniCommented, Apache...
    * @var string
    */
    var $configType = '';

    /**
    * Options for parser
    * @var string
    */
    var $parserOptions = array();

    /**
    * Container object
    * @var object
    */
    var $container;

    /**
    * Constructor
    * Creates a root container
    *
    * @access public
    */
    function silex_config()
    {
		//this->logger = new logger("silex_config");
        $this->container = new Config_Container('section', 'root');
		
    } // end constructor

    /**
    * Returns true if container is registered
    *
    * @param    string  $configType  Type of config
    * @access public
    * @return   bool
    */
    function isConfigTypeRegistered($configType)
    {
        return isset($GLOBALS[GLOBALS_TYPE_STORAGE][strtolower($configType)]);
    } // end func isConfigTypeRegistered

    /**
     * Register a new container
     *
     * @param    string       $configType  Type of config
     * @param    array|false  $configInfo  Array of format:
     *           array('path/to/Name.php',
     *                 'Config_Container_Class_Name').
     *
     *           If left false, defaults to:
     *           array('Config/Container/$configType.php',
     *                 'Config_Container_$configType')
     * @access   public
     * @static
     * @author   Greg Beaver <cellog@users.sourceforge.net>
     * @return   true|PEAR_Error  true on success
     */
    function registerConfigType($configType, $configInfo = false)
    {
        if (Config::isConfigTypeRegistered($configType)) {
            $info = $GLOBALS[GLOBALS_TYPE_STORAGE][strtolower($configType)];
            if ($info[0] == $configInfo[0] &&
                $info[1] == $configInfo[1]) {
                return true;
            } else {
                //return PEAR::raiseError("Config::registerConfigType registration of existing $configType failed.", null, PEAR_ERROR_RETURN);
				throw new Exception("Config::registerConfigType registration of existing $configType failed.");
            }
        }
        if (!is_array($configInfo)) {
            // make the normal assumption, that this is a standard config container added in at runtime
            $configInfo = array('Config/Container/' . $configType . '.php',
                                'Config_Container_'. $configType);
        }
        $file_exists = @include_once($configInfo[0]);
        if ($file_exists) {
            if (!class_exists($configInfo[1])) {
                //return PEAR::raiseError("Config::registerConfigType class '$configInfo[1]' not found in $configInfo[0]", null, PEAR_ERROR_RETURN);
				throw new Exception("Config::registerConfigType class '$configInfo[1]' not found in $configInfo[0]");
            }
        } else {
            //return PEAR::raiseError("Config::registerConfigType file $configInfo[0] not found", null, PEAR_ERROR_RETURN);
			throw new Exception("Config::registerConfigType file $configInfo[0] not found");
        }
        $GLOBALS[GLOBALS_TYPE_STORAGE][strtolower($configType)] = $configInfo;
        return true;
    } // end func registerConfigType

    /**
    * Returns the root container for this config object
    *
    * @access public
    * @return   object  reference to config's root container object
    */
    function &getRoot()
    {
        return $this->container;
    } // end func getRoot

    /**
    * Sets the content of the root Config_container object.
    *
    * This method will replace the current child of the root
    * Config_Container object by the given object.
    *
    * @param object  $rootContainer  container to be used as the first child to root
    * @access public
    * @return   mixed    true on success or PEAR_Error
    */
    function setRoot(&$rootContainer)
    {
        if (is_object($rootContainer) && strtolower(get_class($rootContainer)) === 'config_container') {
            if ($rootContainer->getName() === 'root' && $rootContainer->getType() === 'section') {
                $this->container =& $rootContainer;
            } else {
                $this->container = new Config_Container('section', 'root');
                $this->container->addItem($rootContainer);
            }
            return true;
        } else {
            //return PEAR::raiseError("Config::setRoot only accepts object of Config_Container type.", null, PEAR_ERROR_RETURN);
			throw new Exception("Config::setRoot only accepts object of Config_Container type.");
        }
    } // end func setRoot

    /**
    * Parses the datasource contents
    *
    * This method will parse the datasource given and fill the root 
    * Config_Container object with other Config_Container objects.
    *
    * @param mixed   $datasrc     Datasource to parse
    * @param string  $configType  Type of configuration
    * @param array   $options     Options for the parser
    * @access public
    * @return mixed PEAR_Error on error or Config_Container object
    */
    function &parseConfig($datasrc, $configType, $options = array())
    {
        $configType = strtolower($configType);
        if (!$this->isConfigTypeRegistered($configType)) {
            //return PEAR::raiseError("Configuration type '$configType' is not registered in Config::parseConfig.", null, PEAR_ERROR_RETURN);
			throw new Exception("Configuration type '$configType' is not registered in Config::parseConfig.");
        }
        $includeFile = $GLOBALS[GLOBALS_TYPE_STORAGE][$configType][0];
        $className = $GLOBALS[GLOBALS_TYPE_STORAGE][$configType][1];
		//$this->logger->debug("includeFile : $includeFile");
        include_once($includeFile);

        $parser = new $className($options);
		$error = $parser->parseDatasrc($datasrc, $this);
        if ($error !== true) {
            return $error;
        }
        $this->parserOptions = $parser->options;
        $this->datasrc = $datasrc;
        $this->configType = $configType;
        return $this->container;
    } // end func &parseConfig

	
	function convertConfig($datasrcIn, $configTypeIn, $datasrcOut, $configTypeOut)
	{
		$this->parseConfig($datasrcIn, $configType);
		$this->writeConfig($datascrOut, $configTypeOut);
		return $this->container;
	}
	
    /**
    * Writes the container contents to the datasource.
    *
    * @param mixed   $datasrc     Datasource to write to
    * @param string  $configType  Type of configuration
    * @param array   $options     Options for config container
    * @access public
    * @return mixed PEAR_Error on error or true if ok
    */
    function writeConfig($datasrc = null, $configType = null, $options = array())
    {
        if (empty($datasrc)) {
            $datasrc = $this->datasrc;
        }
        if (empty($configType)) {
            $configType = $this->configType;
        }
        if (empty($options)) {
            $options = $this->parserOptions;
        }
        return $this->container->writeDatasrc($datasrc, $configType, $options);
    } // end func writeConfig
} // end class Config
?>
