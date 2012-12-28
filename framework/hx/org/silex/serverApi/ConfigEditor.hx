/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.ConfigEditorExtern;

class ConfigEditor
{
	private var configEditorExtern : ConfigEditorExtern;
	
	public function new()
	{
		configEditorExtern = new ConfigEditorExtern();
	}
	
	/**
	*  Merges new configuration (from dataToMerge) with the existing one (from filePath) and saves it in filePath.<br/>
	*  filePath is relative to the root of the SILEX Server.<br/>
	*  File has to be in the format specified by the fileFormat parameter.<br/>
	*  Returns true in case of success, false otherwise.
	*/
	public function updateConfigFile(filePath : String, fileFormat : String, dataToMerge : Hash<String>) : Bool
	{
		return configEditorExtern.updateConfigFile(filePath, fileFormat, php.Lib.associativeArrayOfHash(dataToMerge));
	}
	
	/**
	*  Reads the specified configuration file and returns a Hash with keys and values
	*  from the configuration file.<br/>
	*  Configuration file has to be in the format specified by fileFormat.
	*/
	public function readConfigFile(filePath : String, fileFormat : String) : Hash<String>
	{
		return php.Lib.hashOfAssociativeArray(configEditorExtern.readConfigFile(filePath, fileFormat));
	}
	
	/**
	*  Merges configuration files listed in filesList into a FlashVars-like formatted value.
	*/
	public function mergeConfFilesIntoFlashvars(filesList : Array<String>) : Array<String>
	{
		return untyped php.Lib.toHaxeArray(configEditorExtern.mergeConfFilesIntoFlashvars(php.Lib.toPhpArray(filesList)));
	}
}