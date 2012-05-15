<?php
/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

require_once ROOTPATH.'cgi/library/Zend/Translate.php';

/**
* Config parser for gettext Files
*
*
* @package     Config
*/
class Config_Container_Gettext
{

    /**
    * This class options
    *
    * @var  array
    */
    var $options = array();


    /**
    * Constructor
    *
    * @access public
    * @param    string  $options    Options to be used by renderer
    */
    function Config_Container_Gettext($options = array())
    {
        foreach ($options as $key => $value) {
            $this->options[$key] = $value;
        }
    } 

    /**
    * Parses the data of the given configuration file and returns an array
    *
    * @access public
    * @param string $datasrc    path to the configuration file
    * @param object $obj        reference to a config object
    */
    function &parseDatasrc($datasrc, &$obj)
    {
		$translate = new Zend_Translate(
			array(
				'adapter' => 'gettext',
				'content' => $datasrc
			)
		);	

		$ret = $translate->getMessages();	
		
        return $ret;
    } 
	
	 /**
    * Writes the configuration to a file
    *
    * @param  mixed  datasrc        info on datasource such as path to the configuraton file
    * @param  string configType     (optional)type of configuration
    * @access public
    * @return string
    */
    function writeDatasrc($datasrc, &$obj)
    {
        $fp = @fopen($datasrc, 'w');
        if ($fp) {
            
		foreach ($this->localisedStrings as $key => $value)
		{
			fwrite($fp, "msgid \"$key\"\nmsgstr \"$value\"\n");
		}
		fclose($fp);	
			
        } 
		else {
            //PEAR::raiseError('Cannot open datasource for writing.', 1, PEAR_ERROR_RETURN);
			throw new Exception('Cannot open datasource for writing.');
        }
    } // end func writeDatasrc
}
?>
