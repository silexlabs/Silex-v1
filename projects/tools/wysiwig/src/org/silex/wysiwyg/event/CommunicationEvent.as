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
	 * a custom class for communication from the ToolBoxes to the ToolController
	 */ 
	public class CommunicationEvent extends Event
	{
		/**
		 * the custom event data
		 */ 
		private var _data:Object;
		
		/**
		 * send new data when the user confirms new data selection
		 */ 
		public static const DATA_CHANGED:String = "communicationDataChanged";
		
		/**
		 * sent when components must be highligted on the scene
		 */ 
		public static const HIGHLIGHT_COMPONENTS:String = "highlightComponents";
		
		/**
		 * sent when all of a layer components must be highligted on the scene
		 */ 
		public static const HIGHLIGHT_LAYER:String = "highlightLayer";
		
		/**
		 * sent when the user cancel the new data input
		 */
		public static const CANCEL_DATA_CHANGED:String = "communicationCancelDataChanged";
		
		/**
		 * Sent when the layer data changes on the toolbox
		 */
		public static const LAYERS_SELECTION_CHANGED:String = "layerSelectionChanged";
		
		/**
		 * Sent when the components data changes on the toolbox
		 */
		public static const COMPONENTS_DATA_CHANGED:String = "componentsDataChanged";
		
		/**
		 * Sent when the user changes a property value
		 */
		public static const PROPERTY_DATA_CHANGED:String = "propertyDataChanged";
		
		/**
		 * Sent when the user wants to add a new component
		 */
		public static const ADD_COMPONENT:String = "communicationAddComponent";
		
		/**
		 * Sent when the user wants to remove an existing component
		 */
		public static const REMOVE_COMPONENT:String = "removeComponent";
		
		/**
		 * Sent when the user wants to add a new layout
		 */
		public static const ADD_LAYOUT:String = "addLayout";
		
		/**
		 * Sent when the user wants to remove an existing layout
		 */
		public static const REMOVE_LAYOUT:String = "removeLayout";
		
		/**
		 * Sent when the user wants to hide a layer
		 */
		public static const HIDE_LAYER:String =  "hideLayer";
		
		/**
		 * Sent when the user wants to show a layer
		 */
		public static const SHOW_LAYER:String = "showLayer";

		/**
		 * Sent when the user wants to lock a component's selection
		 */
		public static const LOCK_COMPONENT:String = "lockComponent";
		
		/**
		 * Sent when the user wants to lock a layer's selection
		 */
		public static const LOCK_LAYER:String = "lockLayer";
		
		/**
		 * sent when the user clicks the copy button
		 */ 
		public static const COPY_COMPONENTS:String = "copyComponents";
		
		/**
		 * sent when the user clicks the paste button
		 */ 
		public static const PASTE_COMPONENTS:String = "pasteComponents";
		
		/**
		 * Sent when the user wants to unlock a component's selection
		 */
		public static const UNLOCK_COMPONENT:String = "unlockComponent";
		
		/**
		 * Sent when the user wants to unlock a layer's selection
		 */
		public static const UNLOCK_LAYER:String = "unlockLayer";
		
		/**
		 * Sent when the user wants to choose a media from the library
		 */
		public static const CHOOSE_MEDIA:String = "communicationEventChooseMedia";
		
		/**
		 * Sent when the layouts data changes on the toolbox
		 */
		public static const PARENT_PAGE_SELECTION_CHANGED:String = "parentPageSelectionChanged";
		
		/**
		 * Sent when the components selection changes on the toolbox
		 */
		public static const ICON_SELECTION_CHANGED:String = "iconSelectionChanged";
		
		/**
		 * Sent when the components selection changes on the toolbox
		 */
		public static const COMPONENTS_SELECTION_CHANGED:String = "componentsSelectionChanged";
		
		/**
		 * Sent when the user wants to changes the component's order (z-index)
		 */
		public static const COMPONENTS_ORDER_CHANGED:String = "componentsOrderChanged";
		
		/**
		 * Sent when a form validation fails
		 */
		public static const FORM_ERROR:String = "formError";
		
		/**
		 * Sent when the user wants to show a component
		 */
		public static const SHOW_COMPONENT:String = "showComponent";
		
		/**
		 * Sent when the user wants to hide a component
		 */
		public static const HIDE_COMPONENT:String = "hideComponent";
		
		/**
		 * Sent when the user wants to swap two component's orders (z-index)
		 */
		public static const SWAP_COMPONENTS:String = "swapComponents";
		
		/**
		 * Sent when the user wants to save a layout
		 */
		public static const SAVE_LAYOUT:String = "saveLayout";
		
		/**
		 * Sent when the user wants to overwrite a skin that already exist (same name)
		 */ 
		public static const OVERWRITE_SKIN:String = "communicationEventOverWriteSkin";
		
		
		public function CommunicationEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}
		
		/**
		 * returns the event data object
		 */ 
		public function get data():Object
		{
			return _data;
		}
	}
}