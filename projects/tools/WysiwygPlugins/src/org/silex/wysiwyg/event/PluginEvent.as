/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.event
{
	import flash.events.Event;
	
	public class PluginEvent extends Event
	{
		/**
		 * an optionnal data object
		 */ 
		private var _data:Object;
		
		/**
		 * dispatched when a property value must be changed
		 */ 
		public static const PROPERTIES_DATA_CHANGED:String = "propertiesDataChanged";
		
		/**
		 * dispatched when the toolbox needs to be refreshed
		 */ 
		public static const REFRESH_TOOLBOX:String = "refreshToolbox";
		
		/**
		 * dispatched when the toolbox needs to be closed
		 */ 
		public static const CLOSE_TOOLBOX:String = "closeToolbox";
		
		/**
		 * dispatched when a action value must be changed
		 */ 
		public static const ACTION_DATA_CHANGED:String = "actionDataChanged";
		
		/**
		 *dispatched when a specific property editor must be opened
		 */
		public static const OPEN_SPECIFIC_EDITOR:String = "openSpecificEditor";
		
		/**
		 * Sent when the user wants to choose a media from the library
		 */
		public static const CHOOSE_MEDIA:String = "chooseMedia";
		
		/**
		 * sent the user wants to add an item in an array
		 */ 
		public static const ADD_ITEM:String = "addItem";
		
		/**
		 * sent the user wants to remove an item in an array
		 */ 
		public static const REMOVE_ITEM:String = "removeItem";
		
		/**
		 * sent the user wants to copy an item in an array
		 */ 
		public static const COPY_ITEM:String = "copyItem";
		
		/**
		 * sent the user wants to select an item in an array
		 */ 
		public static const SELECT_ITEM:String = "selectItem";
		
		/**
		 * sent the user wants to validate an item in an array
		 */ 
		public static const VALIDATE_ITEM:String = "validateItem";
		
		/**
		 * sent the user wants to cancel an item in an array
		 */ 
		public static const CANCEL_ITEM:String = "cancelItem";
		
		
		/**
		 * sent the user wants to paste an item in an array
		 */ 
		public static const PASTE_ITEM:String = "pasteItem";
		
		/**
		 * sent when the user navigate the library
		 */ 
		public static const UPDATE_LIBRARY_PATH:String = "updateLibraryPath";
		
		/**
		 * sent when the user select an item in the library
		 */ 
		public static const SELECT_LIBRARY_ITEM:String = "selectLibraryItem";
		
		/**
		 * a special case event for when the user seelcts an AS3 swf, a frame needs to be added
		 * instead of an image component
		 */ 
		public static const SELECT_AS3_LIBRARY_ITEM:String = "selectAs3LibraryItem";
		
		
		public static const DATA_CHANGED:String = "dataChanged";
		
		public function PluginEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		public function get data():Object
		{
			return _data;
		}
	}
}