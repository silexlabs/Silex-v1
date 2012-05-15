/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.components
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.controls.listClasses.ListData;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.IListModel;
	import org.silex.adminApi.listModels.ListModelBase;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.event.ToolsItemRendererEvent;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	
	/**
	 * This toolBox lists all the components of the currently selected layer.<br>
	 * The user can add, delete a component and open the toolbox to update it's properties.<br>
	 * For each component, the user can show/hide it and lock/unlock it
	 * 
	 * has a reference to the ComponentUI class. Acts as the controller for the UI. Listens for events on ComponentsUI<br>
	 * and sends event for the ToolController
	 * 
	 * @author Yannick
	 */
	public class ComponentsTool extends SilexToolBase
	{
		
		/**
		 * The constructor instantiates the ComponentsUI, adds it to the displayList<br>
		 * and sets Listeners on it
		 */ 
		public function ComponentsTool()
		{
			super();	
			this.maxWidth = 280;
			this.width = 280;
			_toolUI = new ComponentsUI();

			_toolUI.addEventListener(ToolsEvent.ADD_ITEM, onAddItem);
			_toolUI.addEventListener(ToolsEvent.DELETE_ITEM, onDeleteItem);
			_toolUI.addEventListener(ToolsItemRendererEvent.SHOW_ITEM, onShowItem);
			_toolUI.addEventListener(ToolsItemRendererEvent.HIDE_ITEM, onHideItem);
			_toolUI.addEventListener(ToolsItemRendererEvent.LOCK_ITEM, onLockItem);
			_toolUI.addEventListener(ToolsItemRendererEvent.UNLOCK_ITEM, onUnlockItem);
			_toolUI.addEventListener(ToolsEvent.LIST_CHANGE, onListChange);
			_toolUI.addEventListener(ToolsEvent.CHANGE_ORDER, onChangeOrder);
			_toolUI.addEventListener(ToolsEvent.COPY_ITEM, onCopyItem);
			_toolUI.addEventListener(ToolsEvent.PASTE_ITEM, onPasteItem);
			_toolUI.addEventListener(ToolsEvent.COMPONENT_LIST_ROLL_OVER, onComponentListRollOver);
			
			addChild(_toolUI);
		}	

		/**
		 * Dispatches a COPY_COMPONENT event to the ToolController, asking the ToolController to store the
		 * data of the selected components
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onCopyItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.COPY_COMPONENTS, null, true));
		}
		
		/**
		 * Dispatches a PASTE_COMPONENT event to the ToolController, asking the ToolController to paste
		 * the stored components on the selected subLayer
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onPasteItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.PASTE_COMPONENTS, null, true));
		}
		
		/**
		 * Dispatches a ADD_COMPONENT event to the ToolController, asking the ToolController to open<br>
		 * the LibraryToolBox
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onAddItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.ADD_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches a REMOVE_COMPONENT event to the ToolController, passing it the component<br>
		 * and asking it to delete the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onDeleteItem(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.REMOVE_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches a SHOW_COMPONENT event to the ToolController, passing it the component<br>
		 * and asking it to show the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onShowItem(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.SHOW_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches a HIDE_COMPONENT event to the ToolController, passing it the component<br>
		 * and asking it to hide the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onHideItem(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.HIDE_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches a COMPONENTS_SELECTION_CHANGED event to the ToolController, passing it the component<br>
		 * and asking it to select the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onListChange(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.COMPONENTS_SELECTION_CHANGED, event.data, true));
		}
		
		/**
		 * Dispatches a LOCK_COMPONENT event to the ToolController, passing it the component<br>
		 * and asking it to lock the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onLockItem(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.LOCK_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches an highlight component event, prompting the wysiwyg to highlight the 
		 * component pointed to by the uid sent as event data
		 */ 
		private function onComponentListRollOver(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.HIGHLIGHT_COMPONENTS, event.data, true));
		}
		
		/**
		 * Dispatches a UNLOCK_COMPONENT event to the ToolController, passing it the component<br>
		 * and asking it to unlock the component
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onUnlockItem(event:ToolsItemRendererEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.UNLOCK_COMPONENT, event.data, true));
		}
		
		/**
		 * Dispatches a COMPONENTS_ORDER_CHANGED event to the ToolController, passing it an array of ordered components uid<br>
		 * and asking it to reorder the components according to those uid
		 * 
		 * @param event the triggered ToolsEvent
		 */ 
		private function onChangeOrder(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.COMPONENTS_ORDER_CHANGED, event.data, true));
		}
	}
}