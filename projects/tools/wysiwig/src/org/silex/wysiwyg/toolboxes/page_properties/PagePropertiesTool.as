/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.page_properties
{
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	
	/**
	 * Acts as the link betwwen the ToolController and the toolbox UI. this toolbox allows the user to create
	 * new layouts on a silex site
	 */ 
	public class PagePropertiesTool extends SilexToolBase
	{
		
		/**
		 * Instantiates the UI then sets listeners on it
		 */ 
		public function PagePropertiesTool()
		{	
			super();
			
			_toolUI = new PagePropertiesUI();
			addChild(_toolUI);
			
			_toolUI.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
			_toolUI.addEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
			_toolUI.addEventListener(ToolsEvent.PARENT_PAGE_SELECTION_CHANGED, onLayoutSelectionChanged);
			_toolUI.addEventListener(ToolsEvent.ICON_SELECTION_CHANGED, onComponentSelectionChanged);
			_toolUI.addEventListener(ToolsEvent.FORM_ERROR, onFormError);
		}
		
		/**
		 * When the user validates his choice, sends a DATA_CHANGED event to the toolcontroller asking
		 * it to create a new layout
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.DATA_CHANGED, event.data, true));
		}
		
		/**
		 * When the user cancels his choice, sends a CANCEL_DATA_CHANGED to the ToolController asking it to close the
		 * page_properties toolbox
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onCancelDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.CANCEL_DATA_CHANGED, null, true));
		}
		
		/**
		 * when the user selects a different page_parent, sends a PARENT_PAGE_SELECTION_CHANGED event to the ToolController
		 * asking it to get the new layout component's data
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onLayoutSelectionChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.PARENT_PAGE_SELECTION_CHANGED, event.data, true));
		}
		
		/**
		 * When the user selects a different icon, sends an ICON_SELECTION_CHANGED event to the ToolController asking
		 * it to get new component properties data
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onComponentSelectionChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.ICON_SELECTION_CHANGED, event.data, true));
		}
		
		/**
		 * When there is an error in the user inputs, asks the ToolController to open an alert Toolbox
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onFormError(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.FORM_ERROR, event.data, true));
		}
		

	}
}