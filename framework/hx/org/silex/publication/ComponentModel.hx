/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.publication;

/**
*  This class a represent a Component on a SubLayer.
*/
class ComponentModel
{
	
	/**
	 * special fields in the component model
	 */
	public static inline var FIELD_PLAYER_NAME:String = "playerName";
		
	public var as2Url:String;
	public var html5Url : String;
	public var className:String;
	public var componentRoot:String;
	public var metaData:Dynamic;
	
	/**
	*  Hash containing the properties of the Component
	*/
	public var properties : Hash<Dynamic>;
	/**
	*  Actions of the Component
	*/
	public var actions : List<ActionModel>;
	
	public function new()
	{
		properties = new Hash<Dynamic>();
		actions = new List<ActionModel>();
	}
}