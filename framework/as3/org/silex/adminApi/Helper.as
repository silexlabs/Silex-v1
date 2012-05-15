/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.adminApi.util.Serialization;
	
	public class Helper
	{
	
		private static const FUNC_GET_ALL_COMPONENTS:String = "getAllComponents";
		
		public function Helper() 
		{
			
		}
		
		public function getAllComponents(filter:String):Array
		{
			
			var fromApi:Object = ExternalInterfaceController.getInstance().callJsApiFunction("helper", FUNC_GET_ALL_COMPONENTS, [filter]);

			return fromApi as Array;
		}
		
		/**
		 * AS3 method only, returns an object containing only the property object
		 * with a matching names if given or all properties sorted by name
		 * @param properties the full array of properties
		 * @param the optionnal searched properties names
		 */ 
		public function getPropertyByName(properties:Array, propertyNames:Array = null):Object
		{
			var retObj:Object = new Object();
			
			var propertiesLength:int = properties.length;
			 
			
			if (propertyNames != null)
			{
				var foundItems:int = 0;
				var propertyNamesLength:int = propertyNames.length;
				for (var i:int= 0; i<propertiesLength; i++)
				{
					for (var j:int = 0; j<propertyNamesLength; j++)
					{
						if ((properties[i] as Property).name == propertyNames[j])
						{ 
							retObj[propertyNames[j]] = properties[i] as Property;
							foundItems++;
							if (foundItems == propertyNames.length)
							{
								break;
							}
						}
					}
				}
				
			}
			
			else
			{
				for (i =0; i<propertiesLength; i++)
				{
					retObj[(properties[i] as Property).name] = properties[i]; 
				}
			}
			
			
			return retObj;
		}
	
	}
}