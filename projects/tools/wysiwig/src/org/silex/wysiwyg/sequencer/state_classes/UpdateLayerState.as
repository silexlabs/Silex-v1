/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes
{
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	
	public class UpdateLayerState extends StateBaseShortcut
	{
		public function UpdateLayerState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object)
		{
			super(silexAdminApi, toolCommunication);
		}
		
		/**
		 * When the state is instantiated, show and hide the right toolboxes
		 * and check if the wysiwyg is not supposed to be in another state
		 */ 
		override public function enterState():void
		{
			_toolCommunication.show(ToolCommunication.LAYOUT_TOOLBOX);
			_toolCommunication.show(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.hide(ToolCommunication.PROPERTIES_TOOLBOX);
			getLayoutsLayersData();
			checkLayerSelection();
			checkComponentsSelection();
		}
		
		/**
		 * delete the selected layer by entering the remove layer state, providing
		 * the selected layer uid
		 */ 
		override public function keyboardDeleteCallback():void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, RemoveLayerState, _silexAdminApi.layers.getSelection()[0]));
		}
		
		
		
		
		/**
		 * Allow the user to switch between components by pressing the TAB button,
		 * select the first or last component of the layer
		 * 
		 * @param inOrder determine if the components must be browsed in order
		 */ 
		override public function keyboardSelectComponent(inOrder:Boolean = true):void
		{
			
		}
		
	}
}