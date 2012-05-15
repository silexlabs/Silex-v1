/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

@:native("ComponentDescriptor") extern class ComponentDescriptorExtern
{
	private static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/ComponentDescriptor.php");
		null;
	}
	
	public var componentName : String;
	public var as2Url : String;
	public var html5Url : String;
	public var className : String;
	public var specificEditorUrl : String;
	public var componentRoot : String;
	public var properties : php.NativeArray;
	public var metaData : php.NativeArray;
	
	public function new() : Void;
}