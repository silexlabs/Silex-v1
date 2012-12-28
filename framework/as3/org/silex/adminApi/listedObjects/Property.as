/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listedObjects
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.silex.adminApi.ExternalInterfaceController;

	/**
	 * a property of a component in Silex. Dynamic
	 * */
	public dynamic class Property extends ListedObjectBase 
	{
		/**
		 * number type as string
		 * */
		public static const TYPE_NUMBER:String = "number";
		public static const TYPE_TEXT:String = "text";
		public static const TYPE_URL:String = "url";
		public static const TYPE_RICH_TEXT:String = "rich text";
		public static const TYPE_BOOLEAN:String = "boolean";
		public static const TYPE_ARRAY:String = "array";
		public static const TYPE_ENUM:String = "enum";
		
		public function Property(){
		}
		/**
		 * the silex type
		 * */
		public var type:String;
				
		/**
		* a subtype for the property to better qualilfy it.
		* ex: Enum, RichText, Url
		*/
		public var subType:String;
		
		/**
		 * the current value. No strong type yet. Needs a wrapper function. 
		 * Note: this must be "currentValue" and not simply "value" because somehow it messes with the datagrid that sets value to the silexproperty itself
		 * */
		public var currentValue:*;
		

		
		/**
		 * send an update command through the api to silex 
		 * */
		public function updateCurrentValue(value:*, orignatorId:String = ""):void
		{
			ExternalInterfaceController.getInstance().updateProperty(uid, value, orignatorId);
			currentValue = value;
		}
		
		
	}
}