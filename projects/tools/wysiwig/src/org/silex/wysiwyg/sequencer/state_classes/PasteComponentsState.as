/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes
{
	import flash.events.Event;
	
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listedObjects.Message;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.utils.ComponentCopier;
	
	/**
	 * the application enters this state when the user paste one or many component(s)
	 */ 
	public class PasteComponentsState extends StateBaseShortcut
	{
		/**
		 * listens for the end of the paste process
		 */ 
		public function PasteComponentsState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object)
		{
			super(silexAdminApi, toolCommunication);
			
			silexAdminApi.components.addEventListener(org.silex.adminApi.listModels.Components.EVENT_COMPONENT_END_PASTE, onPasteEnd);
		}
		
		/**
		 * When the paste process is done, refresh the component toolbox and
		 * enters the update layer state
		 */  
		private function onPasteEnd(event:AdminApiEvent):void
		{
			_silexAdminApi.components.removeEventListener(org.silex.adminApi.listModels.Components.EVENT_COMPONENT_END_PASTE, onPasteEnd);
			
			updateComponentToolbox();
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
		
		/**
		 * we override the component seelction changed callback as we need to select
		 * the copied components before pasting their actions and we need to remain
		 * in the PasteComponent state. The default behaviour would make the wysiwyg enter
		 * the UpdateComponent state
		 * 
		 * @param event the AdminApiEvent triggered
		 */ 
		override public function componentsSelectionChangeCallback(event:AdminApiEvent):void
		{
			
		}
		
		/**
		 * same as above, prevent listening to component creation events
		 */ 
		override public function componentCreatedCallback(event:AdminApiEvent):void
		{
			
		}
		
		/**
		 * same as above, prevent listening to component data change event
		 */ 
		override public function componentsDataChangeCallback(event:AdminApiEvent):void
		{
			
		}
		



	}
}