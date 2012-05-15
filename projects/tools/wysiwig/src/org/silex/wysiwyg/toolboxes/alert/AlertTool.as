/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.alert
{
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.HBox;
	import mx.controls.Alert;
	import mx.core.IFlexDisplayObject;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateItemAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateTextAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.SimpleAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.confirm_alert.ConfirmAlertUI;
	import org.silex.wysiwyg.toolboxes.alert.prompt_alert.PromptAlertUI;
	import org.silex.wysiwyg.toolboxes.alert.simple_alert.SimpleAlertUI;
	
	/**
	 * Acts as the link between the ToolBox's UI and the ToolController. 
	 * Listens for event on the AlertsUI and dispatch CommunicationEvent for the ToolController
	 */ 
	public class AlertTool extends SilexToolBase
	{
		/**
		 * a temporary reference to the alert value
		 */ 
		private var _tempAlertValue:Object;
		
		/**
		 * a container for the alerts
		 */ 
		private var _alertContainer:HBox;
		
		/**
		 * sets the alert container styles and adds it to the displayList
		 */ 
		public function AlertTool()
		{
			super();
			this.percentWidth = 100;
			_alertContainer = new HBox();
			
			_alertContainer.percentHeight = 100;
			_alertContainer.percentWidth = 100;
			
			
			_alertContainer.setStyle("horizontalAlign", "center");
			_alertContainer.setStyle("verticalAlign", "middle");
			addChild(_alertContainer);
			
		}
		
		/**
		 * instanciate the UI based on the AlertInfo type, then
		 * sets the data on the _toolUI
		 */ 
		override public function set data(value:Object):void
		{
			
			switch (getQualifiedClassName(value))
			{
				case getQualifiedClassName(SimpleAlertVO) :
					_toolUI = new SimpleAlertUI();	
				break;
				
				case getQualifiedClassName(ConfirmAlertVO) :
					_toolUI = new ConfirmAlertUI();
				break;
					
			}
			
			_toolUI.maxWidth = _toolUI.minWidth = 350;
			_toolUI.maxHeight = _toolUI.minHeight = 210;
			
			_toolUI.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			_tempAlertValue = value;
		}
		
		/**
		 * sets the data on the toolBox UI when all the visual elements are set
		 * 
		 * @param event the trigerred FlexEvent
		 */ 
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolUI.removeEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			_toolUI.data = _tempAlertValue;
		}
		
		/**
		 * dispatch a DATA_CHANGED event for the ToolController when the user confirms his choice
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.DATA_CHANGED, event.data, true));
		}
		
		/**
		 * dispatch a CANCEL_DATA_CHANGED event for the ToolController when the user cancels his choice
		 * 
		 * @param event the trigerred ToolsEvent
		 */ 
		private function onCancelDataChanged(event:ToolsEvent):void
		{
			dispatchEvent(new CommunicationEvent(CommunicationEvent.CANCEL_DATA_CHANGED, null, true));
		}
		
		/**
		 * add the toolBox UI to the toolboxes container, on top of the
		 * other toolboxes then disables all the other toolboxes
		 * 
		 * @param target the ToolBox container
		 */ 
		override public function show(target:ToolCommunication):void
		{
			if (! target.getChildByName(this.name))
			{
				_toolUI.addEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
				_toolUI.addEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
				_toolUI.percentHeight = 30;
				_toolUI.percentWidth = 30;
			
				_alertContainer.addChild(_toolUI);
				
				//prevents the user from interacting with other toolboxes
				target.hDividedBox.enabled = false;
				target.hDividedBox.blendMode = BlendMode.MULTIPLY;
				
				target.hDividedBox.alpha = 0.5;
				
				//adds the alert toolbox to the toolboxes container
				target.addChild(this);
				this.setFocus();
			}

			
		}
		
		/**
		 * removes the Toolox UI from thetoolboxes container and re-enables interactions
		 * with the other toolboxes
		 * 
		 * @param target the ToolBox container
		 */ 
		override public function hide(target:ToolCommunication):void
		{			
			if (target.getChildByName(this.name))
			{
				_toolUI.removeEventListener(ToolsEvent.DATA_CHANGED, onDataChanged);
				_toolUI.removeEventListener(ToolsEvent.CANCEL_DATA_CHANGED, onCancelDataChanged);
				_alertContainer.removeChild(_toolUI);
				target.removeChild(this);
				target.hDividedBox.enabled = true;
				target.hDividedBox.blendMode = BlendMode.NORMAL;
				target.hDividedBox.alpha = 1;
				target.setFocus();
			}
		}
	}
}