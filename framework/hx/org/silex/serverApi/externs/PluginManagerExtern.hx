/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

@:native("plugin_manager") extern class PluginManagerExtern
{
	private static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/plugin_manager.php");
		null;
	}
	
	/**
	*  Creates instances of all activated plugin in the specified configuration.
	*/
	public function createActivePlugins(conf : php.NativeArray, hookManager : HookManagerExtern) : Void;
	/**
	*  Creates and returns a plugin instance with the specified configuration.
	*/
	public function createPlugin(pluginName : String, conf : php.NativeArray) : Dynamic;
	/**
	*  Returns an array of activated plugins.
	*/
	public function listActivatedPlugins(conf : php.NativeArray) : php.NativeArray;
	
	public function new() : Void
	{}
}