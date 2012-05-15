/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.event
{
	import flash.events.Event;
	
	
	/**
	 * A custom event class used for communication between the ToolBoxes' UI and the ToolBoxes'UI itemRenderer
	 */
	public class ToolsItemRendererEvent extends Event
	{
		/**
		 * the custom data object to set
		 */ 
		private var _data:Object;
		
		/**
		 * sent when the user wants to show an item
		 */ 
		public static const SHOW_ITEM:String = "showItem";
		
		/**
		 * sent when the user wants to hide an item
		 */ 
		public static const HIDE_ITEM:String = "hideItem";
		
		/**
		 * sent when the user wants to lock an item
		 */
		public static const LOCK_ITEM:String = "lockItem";
		
		/**
		 * sent when the user wants to unlock an item
		 */
		public static const UNLOCK_ITEM:String = "unlockItem";
		
		public function ToolsItemRendererEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
			
		}
		
		/**
		 * gets the custom data object
		 */ 
		public function get data():Object
		{
			return _data;
		}
	}
}