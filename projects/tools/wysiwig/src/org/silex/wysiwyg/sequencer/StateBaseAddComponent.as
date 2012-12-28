/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer
{
	import flash.errors.IllegalOperationError;
	
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Message;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateComponentState;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	
	/**
	 * thisd is a base state for state adding component. It defines default behaviour for the wysiwyg when adding a component
	 */ 
	public class StateBaseAddComponent extends StateBaseShortcut
	{
		/**
		 * constructor, hide alert toolbox and listen for event when a component is created and when a component
		 * is selected in the library
		 */ 
		public function StateBaseAddComponent(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication)
		{
			super(silexAdminApi, toolCommunication);
			_silexAdminApi.components.addEventListener(Components.EVENT_COMPONENT_CREATED_ERROR, componentErrorCallback);
			_toolCommunication.addEventListener(CommunicationEvent.CHOOSE_MEDIA, onChooseLibraryMedia);
			_toolCommunication.hide(ToolCommunication.ALERT_TOOLBOX);
		}
		
		/**
		 * removes all listeners on the toolbox then hide it and the alert toolbox
		 * 
		 * @param	event the trigerred Communication event
		 */
		override public function destroy():void
		{			
			_toolCommunication.removeEventListener(CommunicationEvent.CHOOSE_MEDIA, onChooseLibraryMedia);
			_toolCommunication.hide(ToolCommunication.ALERT_TOOLBOX);
			_silexAdminApi.components.removeEventListener(Components.EVENT_COMPONENT_CREATED_ERROR, componentErrorCallback);
			
		}
		
		/**
		 * display a message informing the user there was a trouble at component creation and
		 * update the component toolbox
		 */ 
		protected function componentErrorCallback(event:AdminApiEvent):void
		{
			trace("component created error");
			updateComponentToolbox();
			_silexAdminApi.messages.addItem({
				text:ResourceManager.getInstance().getString(ToolConfig.getInstance().wysiwygLanguageBundleName, "COMPONENT_ADDED_ERROR_MESSAGE"),
				status:Messages.STATUS_ERROR,
				time:5000
				
			});
		}
		
		/**
		 * abstract method called when the user selects a component to add. Implemented by the 
		 * sub-classes
		 */ 
		protected function onChooseLibraryMedia(event:CommunicationEvent):void
		{
			throw new IllegalOperationError("abstract method, must be overriden");
		}
		
		/**
		 * refresh the component toolbox to make the new component appear, then
		 * displays a message informing the user that the component was successfully added
		 */ 
		override public function componentCreatedCallback(event:AdminApiEvent):void
		{
			trace("component created");
			updateComponentToolbox();
			_silexAdminApi.messages.addItem({
				text:ResourceManager.getInstance().getString(ToolConfig.getInstance().wysiwygLanguageBundleName, "COMPONENT_ADDED_MESSAGE"),
				status:Messages.STATUS_INFO,
				time:3000
				
			});
		}
		
		/**
		 * when the layer selection change, we change the layer selection but we don't switch state. That way we 
		 * can switch the layer to whom we want to add components
		 * 
		 * @param event the AdminApiEvent triggered
		 */ 
		override public function layersSelectionChangeCallback(event:AdminApiEvent):void
		{
			if (_silexAdminApi.layers.getSelection() && _silexAdminApi.layers.getSelection().length > 0)
			{
				_toolCommunication.setSelection(ToolCommunication.LAYOUT_TOOLBOX, Vector.<String>(_silexAdminApi.layers.getSelection()));
			}
				
			//if no layer is selected, check if a layout is selected and select it if it does
			else
			{
				_toolCommunication.setSelection(ToolCommunication.LAYOUT_TOOLBOX,  Vector.<String>(_silexAdminApi.layouts.getSelection()));
			}
		}
		
		
		/**
		 * sets the selection on the ComponentsToolBox 
		 * then if one or more components are selected, load the corresponding editor editor then enters the update components state designed to edit
		 * a component's properties. Also refresh the component names displayed in the property toolbox headers
		 * 
		 * @param event the AdminApiEvent triggered
		 */ 
		override public function componentsSelectionChangeCallback(event:AdminApiEvent):void
		{
			_toolCommunication.setSelection(ToolCommunication.COMPONENTS_TOOLBOX, Vector.<String>(_silexAdminApi.components.getSelection()));
			if (_silexAdminApi.components.getSelection().length != 0)
			{
				ToolBoxAPIController.getInstance().loadEditor(ToolBoxAPIController.getInstance().getDefaultEditor().editorUrl, ToolBoxAPIController.getInstance().getDefaultEditor().description)
				dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateComponentState));
			}
			refreshPropertyToolboxHeaderNames();
		}
		
		/**
		 * when the components data change, sets the data on the components ToolBox and refresh
		 * the toolbox. Overriden to prevent swithing to updateComponent state
		 *
		 * @param event the triggerred AdminApiEvent
		 */ 
		override public function componentsDataChangeCallback(event:AdminApiEvent):void
		{
			updateComponentToolbox();
			//update the visual selection in the component toolbox 
			_toolCommunication.setSelection(ToolCommunication.COMPONENTS_TOOLBOX, Vector.<String>(_silexAdminApi.components.getSelection()));
		}
	}
}