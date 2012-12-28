/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	import mx.states.State;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.AlertStateBase;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsUI;
	
	/**
	 * a state designed to remove one or many component(s) from a layer
	 */
	public class RemoveComponentState extends AlertStateBase
	{
		/**
		 * Shows the alert toolbox and add listeners to listens for either his confirmation or cancellation
		 */
		public function RemoveComponentState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication, data);
			
			var alertInfo:AlertToolVO = new ConfirmAlertVO(
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_COMPONENT_TITLE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_COMPONENT_MESSAGE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_COMPONENT_YES_LABEL'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_COMPONENT_NO_LABEL')
			);
			
			alertInfo.data = null;
			
			
			var dataObj:Object = new Object();
			dataObj.alertInfo = alertInfo;
			dataObj.successState = UpdateLayerState;
			dataObj.cancelState = UpdateComponentState;
			
			super.init(dataObj);
			
		}
		
		override protected function doEnterSuccessState():void
		{
			doRemoveComponentCallback();
			super.doEnterSuccessState();
		}
		
		/**
		 * When the user confirms his choice to remove one or many component(s), removes all the components one by one,
		 * looping in the component's uid array then enters the default state and emties the components selection
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		private function doRemoveComponentCallback():void
		{
			var selectedComponentUids:Array = _silexAdminApi.components.getSelection();
			
			for (var  i:int = 0; i<selectedComponentUids.length; i++)
			{
				_silexAdminApi.components.deleteItem(selectedComponentUids[i]);
			}
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
			_silexAdminApi.components.select([]);
			_toolCommunication.callMethod(ToolCommunication.LAYOUT_TOOLBOX, LayoutsUI.CHECK_DIRTY);
		
		}
		
	}

}