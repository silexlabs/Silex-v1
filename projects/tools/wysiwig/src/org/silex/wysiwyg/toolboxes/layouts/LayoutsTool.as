/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.layouts
{
	import mx.collections.ArrayCollection;
	import mx.controls.listClasses.ListData;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.IListModel;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.event.ToolsItemRendererEvent;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;

	/**
	 * This ToolBox lists all the layouts and layer displayed on the screen in a tree list. the user can select<br>
	 * a layout or a layer, and add/remove/update a layout.
	 * 
	 * has a reference to the LayoutUI class. Listen for events on LayoutsUI<br>
	 * and dispatches event for the ToolController
	 * 
	 * @author Yannick
	 */
	public class LayoutsTool extends SilexToolBase
	{

		/**
		 * Instantiates the LayoutUI, adds it to the displayList and sets listener on it
		 */ 
		public function LayoutsTool()
		{
			super();
			this.maxWidth = 280;
			this.width = 280;
			_toolUI = new LayoutsUI();
			
			_toolUI.addEventListener(ToolsEvent.ADD_ITEM, onAddItem);
			_toolUI.addEventListener(ToolsEvent.DELETE_ITEM, onDeleteItem);
			_toolUI.addEventListener(ToolsEvent.SHOW_LAYER_ITEM, onShowLayerItem);
			_toolUI.addEventListener(ToolsEvent.HIDE_LAYER_ITEM, onHideLayerItem);
			_toolUI.addEventListener(ToolsItemRendererEvent.LOCK_ITEM, onLockLayer);
			_toolUI.addEventListener(ToolsItemRendererEvent.UNLOCK_ITEM, onUnlockLayer);
			_toolUI.addEventListener(ToolsEvent.LIST_LAYER_CHANGE, onListLayerChange);
			_toolUI.addEventListener(ToolsEvent.SAVE_LAYOUT, onSaveLayout);
			_toolUI.addEventListener(ToolsEvent.LAYOUT_LIST_ROLL_OVER, onListRollOver);
			
			addChild(_toolUI);
		}
			
			
		/**
		 * Dispatches a LAYERS_SELECTION_CHANGED for the ToolController, asking it to select a new layer
		 * 
		 * @param event The triggered ToolsEvent 
		 */	
		protected function onListLayerChange(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.LAYERS_SELECTION_CHANGED, event.data, true));
		}
		
		/**
		 * Dispatches a ADD_LAYOUT for the ToolController, asking it to add a new layout
		 * 
		 * @param event The triggered ToolsEvent 
		 */
		private function onAddItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.ADD_LAYOUT, event.data, true));
		}
		
		
		/**
		 * Dispatches a REMOVE_LAYOUT for the ToolController, asking it to remove an existing layout
		 * 
		 * @param event The triggered ToolsEvent 
		 */
		protected function onDeleteItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.REMOVE_LAYOUT, event.data, true));
		}
		
		/**
		 * Dispatches a HIDE_LAYER for the ToolController, asking it to hide a layer
		 * 
		 * @param event The triggered ToolsEvent 
		 */
		protected function onHideLayerItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.HIDE_LAYER, event.data, true));
		}
		
		/**
		 * Dispatches a SHOW_LAYER for the ToolController, asking it to show a layer
		 * 
		 * @param event The triggered ToolsEvent 
		 */
		protected function onShowLayerItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.SHOW_LAYER, event.data, true));
		}
		
		/**
		 * Dispatches a LOCK_LAYER event to the ToolController, passing it the layer<br>
		 * and asking it to lock the layer
		 * 
		 * @param event the triggered ToolsItemRendererEvent containing the layer
		 */ 
		private function onLockLayer(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.LOCK_LAYER, event.data, true));
		}
		
		/**
		 * Dispatches a UNLOCK_LAYER event to the ToolController, passing it the layer<br>
		 * and asking it to unlock the layer
		 * 
		 * @param event the triggered ToolsItemRendererEvent containing the layer
		 */ 
		private function onUnlockLayer(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.UNLOCK_LAYER, event.data, true));
		}
		
		/**
		 * Dispatches an highlight layer event, prompting the wysiwyg to highlight all the components of 
		 * the layer pointed to by the uid sent as event data
		 */ 
		private function onListRollOver(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.HIGHLIGHT_LAYER, event.data, true));
		}

		
		/**
		 * Dispatches a SAVE_LAYOUT for the ToolController, asking it to save an existing layout
		 * 
		 * @param event The triggered ToolsEvent 
		 */
		protected function onSaveLayout(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.SAVE_LAYOUT, null, true));
		}
		

		
	}
}