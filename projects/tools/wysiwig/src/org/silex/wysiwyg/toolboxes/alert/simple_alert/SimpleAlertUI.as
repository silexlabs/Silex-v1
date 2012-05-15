/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.alert.simple_alert
{
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.SimpleAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.standard_alert.StandardAlertUIHeader;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.ToolUIBase;
	
	/**
	 * A simple alert UI needed when the user needs to be informed (after an update or an error for exemple).
	 * It displays a text message and an OK button that the user needs to press to resume the interactions with the 
	 * application
	 */ 
	public class SimpleAlertUI extends StdUI
	{
		/**
		 * Sets the UI classes for the header, body and footer
		 */ 
		public function SimpleAlertUI()
		{
			_toolBoxHeaderClass = StandardAlertUIHeader;
			_toolBoxBodyClass = SimpleAlertUIBody;
			_toolBoxFooterClass = SimpleAlertUIFooter;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			super();
		}
		
		/**
		 * Sets the listener on the UI
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolBoxFooter.height = 30;
			_toolBoxBody.styleName = "AlertToolBoxBody";
			_toolBoxHeader.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCloseSimpleAlert);
			_toolBoxFooter.addEventListener(ToolsEvent.DATA_CHANGED, onCloseSimpleAlert);
		}
		
		/**
		 * Sets the toolbox title, message and confirm button label
		 * 
		 * @param value the data to be set
		 */
		override public function set data(value:Object):void
		{
			
			_toolBoxHeader.title = (value as SimpleAlertVO).title;
			(_toolBoxFooter as SimpleAlertUIFooter).alertYesLabel = (value as SimpleAlertVO).alertOkLabel;
			_toolBoxBody.data = (value as SimpleAlertVO).alertMsg;
			
		}
		
		/**
		 * when the user clicks on the close or OK button, sends
		 * an event to the tool controller asking it to close the toolbox
		 * 
		 * @param event the trigerred event
		 */ 
		private function onCloseSimpleAlert(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.DATA_CHANGED));
		}
	}
}