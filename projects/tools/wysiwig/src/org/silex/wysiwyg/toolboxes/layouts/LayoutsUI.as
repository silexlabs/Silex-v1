/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.layouts
{

	import mx.collections.ArrayCollection;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.ListedObjectBase;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.event.ToolsItemRendererEvent;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUIHeader;
	
	
	/**
	 * Acts as a wrapper for the Layout ToolBox UI. Composes the Layout ToolBox with a reference to each part (header, body, footer)
	 * 
	 * @author Yannick
	 */
	public class LayoutsUI extends StdUI
	{
		
		/**
		 * the layer constant
		 */ 
		public static const LAYER:int = 0;
		
		/**
		 * the layout constant
		 */ 
		public static const LAYOUT:int = 1;
		
		/**
		 * the name of the function checking if layouts are dirty
		 */ 
		public static const CHECK_DIRTY:String = "checkDirty";
		
		/**
		 * Defines the header, body and footer class
		 */ 
		public function LayoutsUI()
		{
		 	_toolBoxHeaderClass = LayoutsUIHeader;
			_toolBoxBodyClass = LayoutsUIBody;
			_toolBoxFooterClass = LayoutsUIFooter;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			
			super();
		}
		
		/**
		 * Sets the listeners on each Layout ToolBox part
		 * 
		 * @param event The FlexEvent dispatched on creation complete
		 */
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolBoxBody.addEventListener(ToolsEvent.DELETE_ITEM, onDeleteItem);
			_toolBoxFooter.addEventListener(ToolsEvent.ADD_ITEM, onAddItem);
			_toolBoxBody.addEventListener(ToolsEvent.LIST_CHANGE, onListChange);
			_toolBoxFooter.addEventListener(ToolsEvent.SAVE_LAYOUT, onSaveLayout);
			_toolBoxBody.addEventListener(ToolsItemRendererEvent.HIDE_ITEM, onHideItem);
			_toolBoxBody.addEventListener(ToolsItemRendererEvent.SHOW_ITEM, onShowItem);
			_toolBoxBody.addEventListener(ToolsEvent.LAYOUT_LIST_ROLL_OVER, onListRollOver);
		}
		
		/**
		 * override the default toolbox style to add a higher footer
		 */ 
		override protected function createChildren():void
		{
			super.createChildren();
			_toolBoxFooter.height = 47;
			_toolBoxFooter.styleName = "";	
		}
		
		/**
		 * Listens for a LIST_CHANGE event on the ToolBoxBody, then
		 * dispatches a LIST_LAYER_CHANGE
		 * and enable/disable the buttons depending on the event data type
		 * 
		 * @param event The ToolsItemRendererEvent dispatched by the ToolBoxBody list's itemRenderer
		 */ 
		private function onListChange(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.LIST_LAYER_CHANGE, event.data));
			refreshToolbox();
		}
		
		/**
		 * Forward the layer list item roll over event
		 * @param event the triggered tools event, contains the uid of
		 * the rolled over layer item
		 */ 
		private function onListRollOver(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.LAYOUT_LIST_ROLL_OVER, event.data));
		}
		
		/**
		 * Enable/disables the toolbox buttons based on the selected item
		 */ 
		private function refreshToolbox():void
		{
			var selectedItems:Array = (_toolBoxBody as LayoutsUIBody).getSelectedItem() as Array;
			
			//if more than one layer is selected, deactivate all option but save
			if (selectedItems.length > 1)
			{
				(_toolBoxFooter as LayoutsUIFooter).isPropertiesButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isDeleteButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isSaveLayoutButtonEnabled = true;
				(_toolBoxFooter as LayoutsUIFooter).isUnselectLayerButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isAddButtonEnabled = false;
			}
			
			//if only one layer is selected
			else if (selectedItems.length == 1)
			{
				(_toolBoxFooter as LayoutsUIFooter).isPropertiesButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isDeleteButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isSaveLayoutButtonEnabled = true;
				(_toolBoxFooter as LayoutsUIFooter).isUnselectLayerButtonEnabled = true;
				(_toolBoxFooter as LayoutsUIFooter).isAddButtonEnabled = true;
				
			}
			
			//else if no items are selected in the list
			else if (selectedItems == null)
			{
				(_toolBoxFooter as LayoutsUIFooter).isDeleteButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isUnselectLayerButtonEnabled = false;
				(_toolBoxFooter as LayoutsUIFooter).isAddButtonEnabled = true;
			}
		}
		
		/**
		 * Listens for an DELETE_ITEM event on the ToolBoxFooter then 
		 * dispatches an event containing a reference to the item currently selected in the ToolBoxBody
		 * and his parent
		 * 
		 * @param event The ToolsEvent dispatched by the ToolBoxFooter
		 */ 
		private function onDeleteItem(event:ToolsEvent):void
		{
			event.stopPropagation();
			dispatchEvent(new ToolsEvent(ToolsEvent.DELETE_ITEM, (event.data as Layout).uid));
		}
		
		
		/**
		 * Listens for an ADD_ITEM event on the ToolBoxFooter then
		 * dispatches an event containing the current selected object
		 * 
		 * @param event The ToolsEvent dispatched by the ToolBoxFooter
		 */ 
		private function onAddItem(event:ToolsEvent):void
		{
			var selectedLayout:Layout;
			
			selectedLayout = (_toolBoxBody as LayoutsUIBody).getParentLayout();
			
			dispatchEvent(new ToolsEvent(ToolsEvent.ADD_ITEM, selectedLayout));
		}
		
		/**
		 * Listens for an SAVE_LAYOUT event on the ToolBoxFooter then
		 * pass it to the toolbox controller
		 * 
		 * @param event The ToolsEvent dispatched by the ToolBoxFooter
		 */
		private function onSaveLayout(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.SAVE_LAYOUT, null));
		}
		
		
		/**
		 * Listens for an SHOW_LAYER event on the ToolBoxBody then
		 * dispatches a SHOW_LAYER event for the tool controller
		 * 
		 * @param event The ToolsItemRendererEvent dispatched by the ToolBoxBody list's itemRenderer
		 */ 
		private function onShowItem(event:ToolsItemRendererEvent):void
		{
			event.stopPropagation();
			dispatchEvent(new ToolsEvent(ToolsEvent.SHOW_LAYER_ITEM, event.data));
		}
		
		/**
		 * Listens for an HIDE_LAYER event on the ToolBoxBody then
		 * dispatches a HIDE_LAYER event for the tool controller
		 * 
		 * @param event The ToolsItemRendererEvent dispatched by the ToolBoxBody list's itemRenderer
		 */ 
		private function onHideItem(event:ToolsItemRendererEvent):void
		{
			event.stopPropagation();
			dispatchEvent(new ToolsEvent(ToolsEvent.HIDE_LAYER_ITEM, event.data));
		}
		
		/**
		 * sets the selected item in the Layouts ToolBox's list
		 * 
		 * @param value the data to be set
		 */ 
		override public function select(value:Vector.<String>):void
		{
			//fills an array with all the items in the toolbox list
			var dataArray:Array = _toolBoxBody.data as Array;
			
			//checks if the value is not null
			if (value)
			{
				var flagSelection:Boolean = false;
				var selectedLayers:Array = new Array();
				//loop in all the list items and check if the uid matches for all uids in the value object 
				var dataArrayLength:int = dataArray.length;
				for (var  i:int = 0; i<dataArrayLength; i++)
				{
					for (var j:int = 0; j<value.length; j++)
					{
						if((dataArray[i].uid as String) == value[j])
						{
							//if there is a match, push it in the selected layers array
							selectedLayers.push(dataArray[i]);
							flagSelection = true;
						}
					}
					
				}
				
				//if there is no match, unselect all the items in the list
				if (! flagSelection)
				{
					(_toolBoxBody as LayoutsUIBody).selectListItem(null);
				}
				else
				{
					(_toolBoxBody as LayoutsUIBody).selectListItem(selectedLayers);
				}
			
			}
			
			refreshToolbox();
			
		}
		
		/**
		 * sets the data on the toolbox body
		 * 
		 * @param value the data to be set
		 */ 
		override public function set data(value:Object):void
		{
			_toolBoxBody.data = value;
			refreshToolbox();
		}
		
		public function checkDirty(arguments:Object):void
		{
			(_toolBoxBody as LayoutsUIBody).checkDirty();
		}
	}
}