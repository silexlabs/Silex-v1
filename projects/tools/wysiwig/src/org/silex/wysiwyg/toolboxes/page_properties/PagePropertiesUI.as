/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.page_properties
{
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	
	/**
	 * the toolbox UI. Displays a form allowing the user enter the new layout data (name, icon, deeplink, parent_page, gabarit
	 * and isDefaultIcon)
	 */ 
	public class PagePropertiesUI extends StdUI
	{
		/**
		 * Sets the toolbox parts 
		 */ 
		public function PagePropertiesUI()
		{
			_toolBoxBodyClass = PagePropertiesUIBody;
			_toolBoxHeaderClass = PagePropertiesUIHeader;
			_toolBoxFooterClass = PagePropertiesUIFooter;
			
			super();
			
			
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
		}
		
		/**
		 * sets the listeners on the toolbox parts
		 * 
		 * @param eventthe trigerred FlexEvent
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			
			_toolBoxBody.styleName = "pageProperties";
			
			_toolBoxHeader.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
			_toolBoxBody.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
			_toolBoxBody.addEventListener(ToolsEvent.FORM_ERROR, onFormError);
			_toolBoxBody.addEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
			_toolBoxBody.addEventListener(ToolsEvent.ICON_SELECTION_CHANGED, onComponentsSelectionChanged);
			_toolBoxBody.addEventListener(ToolsEvent.PARENT_PAGE_SELECTION_CHANGED, onLayoutsSelectionChanged);
		}
		
		/**
		 * Dispatch a CANCEL_DATA_CHANGED event to the tool controller when the user cancels his choice
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onCancelDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.CANCEL_DATA_CHANGED));
		}
		
		/**
		 * Dispatch a FORM_ERROR event to the tool controller when the user inputs contains error
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onFormError(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.FORM_ERROR));
		}
		
		/**
		 * Dispatch a DATA_CHANGED event to the tool controller when the user confirms his choice
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.DATA_CHANGED, event.data));
		}
		
		/**
		 * Dispatch a ICON_SELECTION_CHANGED event to the tool controller when the user change the selected icon
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onComponentsSelectionChanged(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.ICON_SELECTION_CHANGED, event.data));
		}
		
		/**
		 * Dispatch a PARENT_PAGE_SELECTION_CHANGED event to the tool controller when the user change the selected parent page
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onLayoutsSelectionChanged(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.PARENT_PAGE_SELECTION_CHANGED, event.data));
		}
		
		/**
		 * Sets the data on the toolbox body
		 * 
		 * @param value the data to be set
		 */ 
		override public function set data(value:Object):void
		{
			_toolBoxBody.data = value;
		}
	}
}