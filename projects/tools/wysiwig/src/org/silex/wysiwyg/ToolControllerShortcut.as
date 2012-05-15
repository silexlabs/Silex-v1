/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import mx.containers.HBox;
	import mx.controls.NumericStepper;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.managers.FocusManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.Shortcut;
	import org.silex.adminApi.WysiwygModel;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.toolboxes.SilexToolBase;
	import org.silex.wysiwyg.toolboxes.properties.PropertiesUI;
	
	/**
	 * this class extends the ToolController, adding all the callback related to key board shortcut
	 */ 
	public class ToolControllerShortcut extends ToolController
	{
		public function ToolControllerShortcut(siteEditor:HBox)
		{
			super(siteEditor);
			setKeyboardShortcuts();
			
		}
		
		/**
		 * suscribe all the keyboard shortcut in the SilexAdminApi
		 */ 
		private function setKeyboardShortcuts():void
		{
			_silexAdminApi.shortcut.suscribe(keyboardSaveCallback, 83, int(String("s").charCodeAt(0)), true, false, false, "save a layout");
			_silexAdminApi.shortcut.suscribe(keyboardSaveAllCallback, 83, int(String("s").charCodeAt(0)), true, true, false, "save all layouts");
			_silexAdminApi.shortcut.suscribe(keyboardSaveCallback, 83, int(String("s").charCodeAt(0)), false, false, true, "save a layout");
			_silexAdminApi.shortcut.suscribe(keyboardSaveAllCallback, 83, int(String("s").charCodeAt(0)), false, true, true, "save all layouts");
			
			_silexAdminApi.shortcut.suscribe(keyboardEscapeCallback, 27, Shortcut.ESCAPE_KEY, false, false, false, "unselect all layouts and layers or cancel");
			_silexAdminApi.shortcut.suscribe(keyboardDeleteCallback, 46, 127, false, false, false, "remove a layout or component(s)");
			
			_silexAdminApi.shortcut.suscribe(keyboardSelectComponent, 9, 9, false, false, false, "switch between component(s)");
			_silexAdminApi.shortcut.suscribe(keyboardSelectComponent, 9, 9, false, true, false, "switch between component(s)");
			_silexAdminApi.shortcut.suscribe(keyboardUndo, 50, String("z").charCodeAt(0), true, false, false, "undo");
			_silexAdminApi.shortcut.suscribe(keyboardRedo, 50, String("y").charCodeAt(0), true, false, false, "redo");
			_silexAdminApi.shortcut.suscribe(keyboardCopy, 50, String("c").charCodeAt(0), true, false, false, "copy");
			_silexAdminApi.shortcut.suscribe(keyboardPaste, 50, String("v").charCodeAt(0), true, false, false, "paste");

			_silexAdminApi.shortcut.suscribe(keyboardEnterKey, 13, Shortcut.ENTER_KEY, false, false, false, "confirms a choice)");
		}
		
		private function unsetKeyboardShortcuts():void
		{
			_silexAdminApi.shortcut.unSuscribe(keyboardSaveCallback, 83, String("s").charCodeAt(0), true, false, false, "save a layout");
			_silexAdminApi.shortcut.unSuscribe(keyboardSaveCallback, 83, String("s").charCodeAt(0), false, false, true, "save a layout");
			_silexAdminApi.shortcut.unSuscribe(keyboardSaveCallback, 83, String("s").charCodeAt(0), true, true, false, "save a layout");
			
			_silexAdminApi.shortcut.unSuscribe(keyboardEscapeCallback, 27, Shortcut.ESCAPE_KEY, false, false, false, "unselect all layouts and layers or cancel");
			_silexAdminApi.shortcut.unSuscribe(keyboardDeleteCallback, 46, 127, false, false, false, "remove a layout or component(s)");
			
			_silexAdminApi.shortcut.unSuscribe(keyboardSelectComponent, 9, 9, false, false, false, "switch between component(s)");
			_silexAdminApi.shortcut.unSuscribe(keyboardSelectComponent, 9, 9, false, true, false, "switch between component(s)");
			_silexAdminApi.shortcut.unSuscribe(keyboardUndo, 50, String("z").charCodeAt(0), true, false, false, "undo");
			_silexAdminApi.shortcut.unSuscribe(keyboardRedo, 50, String("y").charCodeAt(0), true, false, false, "redo");
			
			_silexAdminApi.shortcut.unSuscribe(keyboardEnterKey, 13, Shortcut.ENTER_KEY, false, false, false, "confirms a choice)");
		}
		
		
		
		/**
		 * save all the selected layout(s)
		 */ 
		private function keyboardSaveCallback(event:AdminApiEvent):void
		{
			_statesController.currentState.saveLayoutCallback(new CommunicationEvent(""));
		}
		
		/**
		 * Save all the displayed layout(s)
		 */ 
		private function keyboardSaveAllCallback(event:AdminApiEvent):void
		{
			_statesController.currentState.saveAllLayoutCallback(new CommunicationEvent(""));
		}
		
		/**
		 * unselect the layers and layouts on user interaction
		 */ 
		private function keyboardEscapeCallback(event:AdminApiEvent):void
		{
			_statesController.currentState.keyboardEscapeCallback();
		}
		
		/**
		 * delete the selected item(s) (might be a layout or a component), call
		 * a method on StateBase object overriden as needed based on the state
		 * 
		 */ 
		private function keyboardDeleteCallback(event:AdminApiEvent):void
		{
			//call immediately the method if the event comes from as2
			if (event.data.dispatchFrom == "AS2")
			{
				_statesController.currentState.keyboardDeleteCallback();
			}
			
			//else check if the user isn't editing a text field before calling the method
			else if ( (_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextInput) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextArea) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is NumericStepper) == false)
			{
					_statesController.currentState.keyboardDeleteCallback();
			}
		}
		
		/**
		 * When a layer is selected allow the user to switch between components
		 */ 
		private function keyboardSelectComponent(event:AdminApiEvent):void
		{
			//check if the event comes from the AS2 core
			//if it comes from the wysiwyg we do nothing
			if (event.data.dispatchFrom == "AS2")
			{
				//browse in order if shift isn't pressed
				if (String(event.data.useShift) == "false")
				{
					_statesController.currentState.keyboardSelectComponent(true);
				}
				
				//else browse in reverse order
				else
				{
					_statesController.currentState.keyboardSelectComponent(false);
				}
			}
		}
		
		/**
		 * used to confirm choice, mainly in alert box
		 */ 
		private function keyboardEnterKey(event:AdminApiEvent):void
		{
			_statesController.currentState.keyboardEnterKey();
		}
		
		private function keyboardUndo(event:AdminApiEvent):void
		{
			_statesController.currentState.keyboardUndo();
			
			
		}
		
		private function keyboardCopy(event:AdminApiEvent):void
		{
			if ( (_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextInput) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextArea) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is NumericStepper) == false)
			{
				_statesController.currentState.copyComponents(new CommunicationEvent(""));
			}
			
		}
		
		private function keyboardPaste(event:AdminApiEvent):void
		{
			if ( (_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextInput) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is TextArea) == false
				&&(_toolCommunication.getToolBox(ToolCommunication.COMPONENTS_TOOLBOX).focusManager.getFocus() is NumericStepper) == false)
			{
				_statesController.currentState.pasteComponents(new CommunicationEvent(""));
			}
			
		}
		
		
		
		private function keyboardRedo(event:AdminApiEvent):void
		{
				_statesController.currentState.keyboardRedo();
			
			
		}
	
	}
}