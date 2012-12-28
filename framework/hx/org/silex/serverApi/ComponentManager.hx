/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.ComponentManagerExtern;

/**
*  This class is here to help with components management.
*/
class ComponentManager
{
	var componentManagerExtern : ComponentManagerExtern;
	
	public function new()
	{
		componentManagerExtern = new ComponentManagerExtern();
	}
	
	/**
	*  Returns all component descriptors.
	*/
	public function getComponentDescriptors() : Array<ComponentDescriptor>
	{
		var tmp = componentManagerExtern.getComponentDescriptors();
		tmp = untyped __call__("array_values", tmp);
		var res = new Array<ComponentDescriptor>();
		for(el in php.Lib.toHaxeArray(tmp))
		{
			res.push(new ComponentDescriptor(el));
		}
		return res;
	}
}