/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer
{
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveComponentState;
	
	public class StateBaseShortcut extends StateBase
	{
		public function StateBaseShortcut(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication)
		{
			super(silexAdminApi, toolCommunication);
		}
		
		/**
		 * delete the selected item(s) (might be a layout or a component), the default
		 * behavior is to enter the delete component state
		 */ 
		public function keyboardDeleteCallback():void
		{
			var selectedComponentsUids:Array = _silexAdminApi.components.getSelection();
			var selectedComponents:Array = _silexAdminApi.components.getData();
			
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, RemoveComponentState));
		}
		
		/**
		 * Allow the user to switch between components by pressing the TAB button,
		 * default behavior is to switch, it is overriden in states 
		 * 
		 * @param inOrder determine if the components must be browsed in order
		 */ 
		public function keyboardSelectComponent(inOrder:Boolean = true):void
		{
			//get all the components of the current layer
			var components:Vector.<Component> = Vector.<Component>(_silexAdminApi.components.getData()[0]);
			
			//get the first selected components (if more than one are selected)
			var firstSelectedComponentUids:String = _silexAdminApi.components.getSelection()[0];
			
			//stores the index of the selected component in the component array
			var firstSelectedComponentIndex:int;
			
			//loop in the components array to find the index of the selected component
			var componentsLength:int = components.length;
			for (var i:int = 0; i<componentsLength; i++)
			{
				if (components[i].uid == firstSelectedComponentUids)
				{
					firstSelectedComponentIndex = i;
					break;
				}
			}
			
			//if we switch in order
			if (inOrder)
			{
				
				//if the selected component is not the last of the list
				if (firstSelectedComponentIndex < components.length-1)
				{
					//select the next one
					_silexAdminApi.components.select([components[firstSelectedComponentIndex+1].uid]);
					
				}
				
				//else, select the first of the list
				else
				{
					_silexAdminApi.components.select([components[0].uid]);
				}
			}
			
			//else if we go in reverse
			else
			{
				//if the selected component is not the first of the list
				if (firstSelectedComponentIndex > 0)
				{
					//select the previous one
					_silexAdminApi.components.select([components[firstSelectedComponentIndex-1].uid]);
				}
				
				//else, select the last of the list
				else
				{
					_silexAdminApi.components.select([components[components.length-1].uid]);
				}
			}
			
		}
		
		/**
		 * unselect the layers and layouts on user interaction
		 */ 
		public function keyboardEscapeCallback():void
		{
			_silexAdminApi.layers.select([]);
		}
		
		/**
		 * used to confirm choice, mainly in alert box, default behaviour
		 * is to do nothing
		 */ 
		public function keyboardEnterKey():void
		{
			
		}
		
		/**
		 * make a one step undo
		 */ 
		public function keyboardUndo():void
		{
			_silexAdminApi.historyManager.undo();
		}
		
		/**
		 * make a one step redo
		 */ 
		public function keyboardRedo():void
		{
			_silexAdminApi.historyManager.redo();
		}
	}
}