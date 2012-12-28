/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import mx.controls.Alert;
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.AlertStateBase;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.SimpleAlertVO;
	
	/**
	 * a state designed to remove a layout from a silex site
	 */
	public class RemoveLayoutState extends AlertStateBase
	{
		
		/**
		 * The uid of the item that might be deleted
		 */ 
		protected var _targetUid:String;
		
		/**
		 * show the alert toolbox and sets listeners on it, cancels the removal if 
		 * the selected layout is the start layout
		 */
		public function RemoveLayoutState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication, data);
			
			_targetUid = data as String;
			var dataObj:Object = new Object();
			
			var alertInfo:AlertToolVO;
			
			if (isTargetDeletable(_targetUid) == true)
			{
				alertInfo = new ConfirmAlertVO(
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_LAYER_TITLE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_LAYER_MESSAGE'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_LAYER_YES_LABEL'),
				ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_LAYER_NO_LABEL'));
				
				
			}
			
			else
			{
				alertInfo = new SimpleAlertVO(
					ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_START_LAYER_ERROR_TITLE'),
					ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_START_LAYER_ERROR_MESSAGE'),
					ResourceManager.getInstance().getString('WYSIWYG', 'ALERT_TOOLBOX_DELETE_START_LAYER_ERROR_OK_LABEL'));
			}
			
			alertInfo.data = null;
			dataObj.alertInfo = alertInfo;
			dataObj.successState = UpdateLayerState;
			dataObj.cancelState = UpdateLayerState;
			
			super.init(dataObj);

		}
		
		/**
		 * Determine wether the target canbe deleted
		 */ 
		protected function isTargetDeletable(targetUid:String):Boolean
		{
			return !(targetUid == ((_silexAdminApi.layouts.getData()[0][0]) as Layout).uid);
		}
		
		override protected function doEnterSuccessState():void
		{	
			doRemoveLayoutCallback();
			super.doEnterSuccessState();
		}
		
		/**
		 * When the user confirms his choice to remove a layout, delete the layout
		 * 
		 */
		protected function doRemoveLayoutCallback():void
		{
			_silexAdminApi.layouts.deleteItem(_targetUid);
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
		
		
		
		
	}

}