/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	
	/**
	 * a state designed to swap a components media URL with the library
	 */
	public class ChooseMediaState extends StateBaseShortcut
	{
		/**
		 * shows the library toolbox, hide the component toolbox then adds listeners on the library toolbox
		 */
		public function ChooseMediaState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);
			
			_toolCommunication.show(ToolCommunication.LIBRARY_TOOLBOX);
			_toolCommunication.hide(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.addEventListener(CommunicationEvent.DATA_CHANGED, doChooseMediaCallback);
			_toolCommunication.addEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, doExitChooseMediaState);
		}
		
		
		/**
		 * shows the component toolbox, hide the library toolbox then removes listeners on it
		 */
		override public function destroy():void
		{
			_toolCommunication.hide(ToolCommunication.LIBRARY_TOOLBOX);
			_toolCommunication.show(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.removeEventListener(CommunicationEvent.DATA_CHANGED, doChooseMediaCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.CANCEL_DATA_CHANGED, doExitChooseMediaState);
		}
		
		/**
		 * When the user cancels his choice to swap the media's url, enters the update component state
		 * 
		 * @param	event the trigerred Communication event
		 */
		private function doExitChooseMediaState(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateComponentState));
		}
		
		/**
		 * When the user confirms his choice to swap a media's url, it updates the property value to the new url then
		 * enters update component state
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		private function doChooseMediaCallback(event:CommunicationEvent):void
		{
			(event.data.property as Property).updateCurrentValue(event.data.currentValue);
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateComponentState));
		}
		
	}

}