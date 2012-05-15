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
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	
	/**
	 * the default state displays the components and layouts toolboxes, hides the others
	 */
	public class NoState extends StateBaseShortcut
	{
		/**
		 * the default state, hide all toolBoxes but the components and layouts
		 * toolBoxes
		*/ 
		public function NoState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);
			trace("enter no state");
			
			_toolCommunication.hide(ToolCommunication.PROPERTIES_TOOLBOX);
			_toolCommunication.hide(ToolCommunication.PAGE_PROPERTIES_TOOLBOX);
			_toolCommunication.show(ToolCommunication.LAYOUT_TOOLBOX);
			_toolCommunication.show(ToolCommunication.COMPONENTS_TOOLBOX);
		}
		
		override public function destroy():void
		{
			
		}
		
		/**
		 * delete the selected item(s) (might be a layout or a component), in this state,
		 * nothing is deleted so nothing happens
		 */ 
		override public function keyboardDeleteCallback():void
		{
			
		}
		
		/**
		 * Allow the user to switch between components by pressing the TAB button,
		 * do nothing in this state
		 * 
		 * @param inOrder determine if the components must be browsed in order
		 */ 
		override public function keyboardSelectComponent(inOrder:Boolean = true):void
		{
			
		}
		
		/**
		 * properties data changed does'nt do anything in no state because
		 * no component is selected. 
		 * 
		 * @param event the trigerred AdminApiEvent
		 */ 
		override public function propertiesDataChangeCallback(event:AdminApiEvent):void
		{
			
		}
		
	}

}