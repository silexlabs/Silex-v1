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
	 * A custom event class used for communication from the ToolBoxes UI to the ToolBoxes controller
	 */ 
	public class ToolsEvent extends Event
	{
		/**
		 * sent when a list selection changes
		 */ 
		public static const LIST_CHANGE:String = "listChange";
		
		/**
		 * sent when an item in the component list is rolled over
		 */ 
		public static const COMPONENT_LIST_ROLL_OVER:String = "componentListRollOver";
		
		/**
		 * sent when an item in the layout list is rolled over
		 */ 
		public static const LAYOUT_LIST_ROLL_OVER:String = "layoutListRollOver";
		
		/**
		 * sent when a layer is selected on the Layout ToolBox list
		 */ 
		public static const LIST_LAYER_CHANGE:String = "listLayerChange";
		
		/**
		 * sent when the user wants to add an item to a list
		 */ 
		public static const ADD_ITEM:String = "addItem";
		
		/**
		 * Sent when the user wants to choose a media from the library
		 */
		public static const CHOOSE_MEDIA:String = "chooseMedia";
		
		/**
		 * sent when the user wants to remove an item from a list
		 */ 
		public static const DELETE_ITEM:String = "deleteItem";
		
		/**
		 * sent when the user wants to show a layer
		 */ 
		public static const SHOW_LAYER_ITEM:String = "showLayerItem";
		
		/**
		 * sent when the user wants to hide a layer
		 */ 
		public static const HIDE_LAYER_ITEM:String = "hideLayerItem";
		
		/**
		 * sent when the user wants to swap a item to the top
		 */ 
		public static const SWAP_ITEM_TO_TOP:String = "swapItemToTop";
		
		/**
		 * sent when the user wants to swap a item up
		 */ 
		public static const SWAP_ITEM_UP:String = "swapItemUp";
		
		/**
		 * sent when the user wants to swap a item down
		 */ 
		public static const SWAP_ITEM_DOWN:String = "swapItemDown";
		
		/**
		 * sent when the user wants to swap a item to the bottom
		 */ 
		public static const SWAP_ITEM_TO_BOTTOM:String = "swapItemToBottom";
		
		/**
		 * sent when the user wants to lock an item
		 */ 
		public static const LOCK_ITEM:String = "lockItem";
		
		/**
		 * sent when the user wants to unlock an item
		 */ 
		public static const UNLOCK_ITEM:String = "unlockItem";
		
		/**
		 * sent when the user wants to change items order
		 */ 
		public static const CHANGE_ORDER:String = "changeOrder";
		
		/**
		 * sent when the user wants to save a layout
		 */ 
		public static const SAVE_LAYOUT:String = "saveLayout";
		
		/**
		 * send new data when the user confirms new data selection
		 */ 
		public static const DATA_CHANGED:String = "dataChanged";
		
		/**
		 * sent when the user cancel the new data input
		 */
		public static const CANCEL_DATA_CHANGED:String = "cancelDataChanged";
		
		/**
		 * sent when the user clicks the copy button
		 */ 
		public static const COPY_ITEM:String = "copyItem";
		
		/**
		 * sent when the user clicks the paste button
		 */ 
		public static const PASTE_ITEM:String = "pasteItem";
		
		/**
		 * Sent when the layouts data changes on the toolbox
		 */
		public static const PARENT_PAGE_SELECTION_CHANGED:String = "parentPageSelectionChanged";
		
		/**
		 * Sent when the components data changes on the toolbox
		 */
		public static const COMPONENTS_DATA_CHANGED:String = "componentsDataChanged";
		
		/**
		 * Sent when the components selection changes on the toolbox
		 */
		public static const ICON_SELECTION_CHANGED:String = "iconSelectionChanged";
		
		/**
		 * Sent when a form validation fails
		 */
		public static const FORM_ERROR:String = "formError";
		
		/**
		 * Sent by the toolbox when display needs to be refreshed
		 */
		public static const REFRESH_TOOLBOX:String = "refreshToolbox";
		
		/**
		 * Sent when the user wants to upload a new skin on the Silex server
		 */ 
		public static const UPLOAD_SKIN:String = "uploadSkin";
		
		/**
		 * Sent when the user wants to overwrite a skin that already exist (same name)
		 */ 
		public static const OVERWRITE_SKIN:String = "overWriteSkin";
		
		/**
		 * the event custom data object
		 */ 
		private var _data:Object;
		
		public function ToolsEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
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