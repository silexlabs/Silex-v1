/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseAddComponent;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxes.addComponents.AddComponentsUI;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateItemAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateTextAlertVO;
	
	/**
	 * a state designed to add a component to a layer
	 */
	public class AddComponentState extends StateBaseAddComponent
	{

		/**
		 * show the add component toolbox and set it's data to "null", which hides the skin panel of the add component
		 * toolbox
		 */
		public function AddComponentState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);		
			
			_toolCommunication.show(ToolCommunication.ADD_COMPONENTS_TOOLBOX);
			_toolCommunication.setData(ToolCommunication.ADD_COMPONENTS_TOOLBOX, null);
			
		}
		
		/**
		 * hide the add component toolbox
		 * 
		 * @param	event the trigerred Communication event
		 */
		override public function destroy():void
		{			
			super.destroy();
			_toolCommunication.hide(ToolCommunication.ADD_COMPONENTS_TOOLBOX);
		
		}
	}

}