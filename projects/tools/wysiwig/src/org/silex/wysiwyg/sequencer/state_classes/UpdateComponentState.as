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
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsUI;
	
	/**
	 * a state used to update a component's properties
	 */
	public class UpdateComponentState extends StateBaseShortcut
	{
		
		public function UpdateComponentState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);
		}
		
		/**
		 * When the state is instantiated, show  the right toolboxes
		 */ 
		override public function enterState():void
		{
			_toolCommunication.show(ToolCommunication.COMPONENTS_TOOLBOX);
			_toolCommunication.show(ToolCommunication.PROPERTIES_TOOLBOX);
		}
		
		/**
		 * hide the properties toolbox and quit listening for DATA_CHANGE event on it
		 */
		override public function destroy():void
		{
			_toolCommunication.hide(ToolCommunication.PROPERTIES_TOOLBOX);
		}
		
	}

}