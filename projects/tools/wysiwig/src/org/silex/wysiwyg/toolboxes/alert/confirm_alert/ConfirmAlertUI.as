/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.alert.confirm_alert
{
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.standard_alert.StandardAlertUIFooter;
	import org.silex.wysiwyg.toolboxes.alert.standard_alert.StandardAlertUIHeader;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	
	/**
	 * a Confirm ToolBox containing a message and an OK and CANCEL button
	 */ 
	public class ConfirmAlertUI extends StdUI
	{
		
		/**
		 * a reference to the data set on the ToolBox
		 */ 
		private var _objectData:Object;
		
		/**
		 * set the ToolBox class for each part of the UI
		 */ 
		public function ConfirmAlertUI()
		{
			_toolBoxHeaderClass = StandardAlertUIHeader;
			_toolBoxBodyClass = ConfirmAlertUIBody;
			_toolBoxFooterClass = StandardAlertUIFooter;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			super();
		}
		
		/**
		 * Saves the data in a temp object then set the toolBox title
		 * body message and footer button label, then sets the toolbox body data
		 * 
		 * @param value the data to be set
		 */
		override public function set data(value:Object):void
		{
			_objectData = (value as ConfirmAlertVO).data;
	
			_toolBoxHeader.title = (value as ConfirmAlertVO).title;
			(_toolBoxFooter as StandardAlertUIFooter).alertYesLabel = (value as ConfirmAlertVO).alertYesLabel;
			(_toolBoxFooter as StandardAlertUIFooter).alertNoLabel = (value as ConfirmAlertVO).alertNoLabel;
			_toolBoxBody.data = (value as ConfirmAlertVO).alertMsg;
			
		}
		
		/**
		 * sets the listeners on the toolbox parts when their creation is complete
		 * 
		 * @param event the trigerred event
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolBoxFooter.height = 30;
			_toolBoxBody.styleName = "AlertToolBoxBody";
			_toolBoxHeader.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
			_toolBoxFooter.addEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
			_toolBoxFooter.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
		}
		
		/**
		 * When the user confirms his choice, remove all listerners then dispatch
		 * a DATA_CHANGED event for the AlertTool
		 * 
		 * @param the trigerred toolsEvent
		 */ 
		private function onDataChanged(event:ToolsEvent):void
		{
			removeListeners();
			dispatchEvent(new ToolsEvent(ToolsEvent.DATA_CHANGED, _objectData));
		}
		
		/**
		 * When the user cancels his choice, remove all listerners then dispatch
		 * a CANCEL_DATA_CHANGED event for the AlertTool
		 * 
		 * @param the trigerred toolsEvent
		 */ 
		private function onCancelDataChanged(event:ToolsEvent):void
		{
			removeListeners();
			dispatchEvent(new ToolsEvent(ToolsEvent.CANCEL_DATA_CHANGED));
		}
		
		/**
		 * utlity method removing all listeners from the toolbox parts
		 */ 
		private function removeListeners():void
		{
			_toolBoxHeader.removeEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
			_toolBoxFooter.removeEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
			_toolBoxFooter.removeEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
		}
		
		
	}
}