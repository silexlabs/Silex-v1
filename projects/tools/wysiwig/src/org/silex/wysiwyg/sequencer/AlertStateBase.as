/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer
{
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	
	/**
	 * this class is a base for all all alert state (like confirm state, simple alert state, prompt state...)
	 */ 
	public class AlertStateBase extends StateBaseShortcut
	{
		/**
		 * the state in which to go in cas of success
		 */ 
		protected var _successState:Class;
		
		/**
		 * the state in which to go in case of cancellation
		 */ 
		protected var _cancelState:Class;
		

		public function AlertStateBase(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object)
		{
			super(silexAdminApi, toolCommunication);	
		}
		
		/**
		 * set the data on the alert toolbox, listens for event on it and shows it
		 */ 
		protected function init(data:Object):void
		{
			
			_successState = data.successState as Class;
			_cancelState = data.cancelState as Class;
			
			_toolCommunication.setData(ToolCommunication.ALERT_TOOLBOX, data.alertInfo as AlertToolVO);
			
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, enterSuccessState);
			_toolCommunication.addEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, enterCancelState);
			
			_toolCommunication.show(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * removes the listeners on the alert toolbox and hides it
		 */
		override public function destroy():void
		{
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, enterSuccessState);
			_toolCommunication.removeEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, enterCancelState);
			
			_toolCommunication.hide(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * method called when the user confirms his choice
		 * 
		 * @param event the trigerred CommunicationEvent
		 */ 
		protected function enterSuccessState(event:CommunicationEvent):void
		{
			doEnterSuccessState();
		}
		
		/**
		 * enter the succes state, might be overriden to add behaviour before or
		 * after entering the state
		 */ 
		protected function doEnterSuccessState():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, _successState));
		}
		
		/**
		 * enter the cancel state, might be overriden to add behaviour before or
		 * after entering the state
		 */ 
		protected function enterCancelState(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, _cancelState));
		}
		
		/**
		 * cancel the choice of the user and enters the cancel state
		 */ 
		override public function keyboardEscapeCallback():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, _cancelState));
		}
		
		/**
		 * used to confirm choice, mainly in alert box, default behaviour
		 * is to do nothing
		 */ 
		override public function keyboardEnterKey():void
		{
			doEnterSuccessState();
		}
	}
}