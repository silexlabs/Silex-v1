/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listModels
{
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Property;

	/**
	 * the silex list model for Properties
	 * 
	 * note: all strings are received base64 encoded, because ExternalInterface corrupts certain characters
	 * see http://mihai.bazon.net/blog/externalinterface-is-unreliable
	 * update : its only for outgoing strings when compiled for Flash8. 
	 * So do the encoding only when sending from AS2 to AS3, not the other way.
	 * */
	public class Properties extends ListModelBase
	{
		public function Properties()
		{
			super();
			_equivalentAS2ObjectName = "properties";
			_dataType = Property;
		}
				
	}
}