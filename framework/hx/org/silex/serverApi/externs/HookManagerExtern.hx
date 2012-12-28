/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

/**
*  This class manages hooks.<br/>
*  Attention! It is a singleton, use getInstance.
*/
@:native("HookManager") extern class HookManagerExtern
{
	private static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/HookManager.php");
		null;
	}

	/**
	*  Returns the instance of HookManager to be used.
	*/
	public static function getInstance() : HookManagerExtern;
	
	/**
	*  Call all functions that have been attached to hookName with the specified parameters.
	*/
	public function callHooks(hookName : String, paramsArray : php.NativeArray) : Dynamic;
	/**
	*  Attach callBack to the specified hook.<br/>
	*  Callback can be a function of a PHP array of [className, functionName] or a PHP array of [object, functionName].
	*/
	public function addHook(hookName : String, callBack : Dynamic->Dynamic) : Dynamic;
}