/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg
{
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.HBox;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.ListModelBase;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Action;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.IVisibility;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Message;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.adminApi.selection.SelectionManager;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.StatesController;
	import org.silex.wysiwyg.sequencer.state_classes.AddLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.ChooseMediaState;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateLayerState;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxApi.event.ToolBoxAPIEvent;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.SimpleAlertVO;
	import org.silex.wysiwyg.toolboxes.components.ComponentsUI;
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsUI;
	import org.silex.wysiwyg.toolboxes.page_properties.PagePropertiesVO;
	
	/**
	 * The toolBox controller manages the calls to SilexAdminAPI and listens for data change or selection change event on SilexAdminAPI.<br>
	 * It has a reference to the communication class which acts as a link between the controller and the Wysiwyg UI.
	 */
	public class ToolController 
	{
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * a reference to the SilexAdminApi singleton
		 */
		protected var _silexAdminApi:SilexAdminApi;
		
		/**
		 * a reference to the toolcommunication object storing the toolboxes
		 */
		protected var _toolCommunication:ToolCommunication;
		
		/**
		 * a reference to the sequencer managing the application state
		 */ 
		protected var _statesController:StatesController;
		
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// CONSTRUCTOR
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		public function ToolController(siteEditor:HBox)
		{
			onInit(siteEditor);
		}

		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// INIT
		////*/*/*/*/*/*/*/*/*/*/*/*/
		// all the init methods, called at wysiwyg startup
		
		/**
		 * inits the class with references to the visual container, the communication class and the SilexAdminAPI
		 * 
		 * @param siteEditor a reference to the Box containing the toolBoxes
		 * @param toolCommunication a reference to the communication class
		 * @param silexAdminAPI a reference to the SilexAdminAPI singleton
		 */ 
		private function onInit(siteEditor:HBox):void
		{
			//inits the reference to SilexAdminApi and to the Toolboxes
			_silexAdminApi = SilexAdminApi.getInstance();
			
			
			_toolCommunication = new ToolCommunication();
			_statesController = new StatesController(_silexAdminApi, _toolCommunication);
			
			//set the default panel that will be loaded in the properties toolbox, 
			//once it's done initialising
			ToolBoxAPIController.getInstance().setAsDefault(ToolConfig.getInstance().defaultEditorUrl, "");
			
			//instantiate the lang controller and set
			//the default language
			var langController:LangController = new LangController();
			langController.setLanguage(ToolConfig.getInstance().defaultLanguage);
			
			_toolCommunication.addEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteCallback);
			
			//adds the Toolboxes to the display list
			siteEditor.addChild(_toolCommunication);
		}
		
		
		/**
		 * when the toolBoxes are loaded, sets the data in them
		 * 
		 * @event the trigerred FlexEvent
		 */ 
		private function creationCompleteCallback(event:FlexEvent):void
		{
			_toolCommunication.removeEventListener(FlexEvent.CREATION_COMPLETE, creationCompleteCallback);
			
			//Events coming from the wysiwyg sequencer
			_statesController.addEventListener(StateEvent.CHANGE_STATE, changeStateCallback);
			
			
			//shows the layouts and components toolBox
			_statesController.enterState(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
			initListeners();
		}
		
		/**
		 * Add all the wysiwyg listeners, all of of them calling back
		 * methods on the current state
		 */ 
		private function initListeners():void
		{
			//Events coming from SILEX
			_silexAdminApi.layers.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.layersSelectionChangeCallback);
			_silexAdminApi.layouts.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.layoutsDataChangeCallback);
			_silexAdminApi.layouts.addEventListener(AdminApiEvent.EVENT_SAVE_LAYOUT_OK, _statesController.currentState.layoutsSaveOKCallback);
			_silexAdminApi.components.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.componentsSelectionChangeCallback);
			_silexAdminApi.components.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.componentsDataChangeCallback);
			_silexAdminApi.properties.addEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.propertiesSelectionChangeCallback);
			_silexAdminApi.properties.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.propertiesDataChangeCallback);
			_silexAdminApi.actions.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.actionDataChangeCallback);
			_silexAdminApi.components.addEventListener(Components.EVENT_COMPONENT_CREATED, _statesController.currentState.componentCreatedCallback);
			_silexAdminApi.selectionManager.addEventListener(SelectionManager.SELECTION_MODE_CHANGED, _statesController.currentState.selectionModeChangedCallback);
			_silexAdminApi.components.addEventListener(Components.EVENT_COMPONENT_START_PASTE, _statesController.currentState.componentStartPasteCallback);
			
			//Events coming form the toolboxes
			
			_toolCommunication.addEventListener(CommunicationEvent.ADD_COMPONENT, _statesController.currentState.AddComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.REMOVE_COMPONENT, _statesController.currentState.removeComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.ADD_LAYOUT, _statesController.currentState.addLayoutCallback);
			_toolCommunication.addEventListener(CommunicationEvent.REMOVE_LAYOUT, _statesController.currentState.removeLayoutCallback);
			_toolCommunication.addEventListener(CommunicationEvent.LAYERS_SELECTION_CHANGED, _statesController.currentState.userLayersSelectionChangeCallback);
			_toolCommunication.addEventListener(CommunicationEvent.COMPONENTS_SELECTION_CHANGED, _statesController.currentState.userComponentsSelectionChangeCallback);
			_toolCommunication.addEventListener(CommunicationEvent.COMPONENTS_ORDER_CHANGED, _statesController.currentState.componentsOrderChangeCallback);
			_toolCommunication.addEventListener(CommunicationEvent.SWAP_COMPONENTS, _statesController.currentState.componentsSwapCallback);
			_toolCommunication.addEventListener(CommunicationEvent.HIDE_LAYER, _statesController.currentState.hideLayerCallback);
			_toolCommunication.addEventListener(CommunicationEvent.SHOW_LAYER, _statesController.currentState.showLayerCallback);
			_toolCommunication.addEventListener(CommunicationEvent.HIDE_COMPONENT, _statesController.currentState.hideComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.SHOW_COMPONENT, _statesController.currentState.showComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.SAVE_LAYOUT, _statesController.currentState.saveLayoutCallback);
			_toolCommunication.addEventListener(CommunicationEvent.LOCK_COMPONENT, _statesController.currentState.lockComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.UNLOCK_COMPONENT, _statesController.currentState.unlockComponentCallback);
			_toolCommunication.addEventListener(CommunicationEvent.LOCK_LAYER, _statesController.currentState.lockLayerCallback);
			_toolCommunication.addEventListener(CommunicationEvent.UNLOCK_LAYER, _statesController.currentState.unlockLayerCallback);
			_toolCommunication.addEventListener(CommunicationEvent.COPY_COMPONENTS, _statesController.currentState.copyComponents); 
			_toolCommunication.addEventListener(CommunicationEvent.PASTE_COMPONENTS, _statesController.currentState.pasteComponents);
			_toolCommunication.addEventListener(CommunicationEvent.OVERWRITE_SKIN, _statesController.currentState.overWriteSkin);
			_toolCommunication.addEventListener(CommunicationEvent.HIGHLIGHT_COMPONENTS, _statesController.currentState.highlightComponents);
			_toolCommunication.addEventListener(CommunicationEvent.HIGHLIGHT_LAYER, _statesController.currentState.highlightLayer);
			
			
			//Events coming from the ToolBoxAPI
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_EDITOR, _statesController.currentState.loadEditorCallback);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_LIBRARY, _statesController.currentState.loadLibraryCallback);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.REFRESH_COMPONENT_NAME, _statesController.currentState.onRefreshComponentName);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_SKINNABLE_COMPONENT, _statesController.currentState.loadSkinnableComponentCallback);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_COMPONENT, _statesController.currentState.loadComponentCallback);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_LEGACY_COMPONENT, _statesController.currentState.loadLegacyComponentCallback);
		}
		
		/**
		 * remove all of the current state listeners
		 */ 
		private function removeListeners():void
		{
			//Events coming from SILEX
			_silexAdminApi.layers.removeEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.layersSelectionChangeCallback);
			_silexAdminApi.layouts.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.layoutsDataChangeCallback);
			_silexAdminApi.components.removeEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.componentsSelectionChangeCallback);
			_silexAdminApi.layouts.removeEventListener(AdminApiEvent.EVENT_SAVE_LAYOUT_OK, _statesController.currentState.layoutsSaveOKCallback);
			_silexAdminApi.components.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.componentsDataChangeCallback);
			_silexAdminApi.properties.removeEventListener(AdminApiEvent.EVENT_SELECTION_CHANGED, _statesController.currentState.propertiesSelectionChangeCallback);
			_silexAdminApi.properties.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.propertiesDataChangeCallback);
			_silexAdminApi.actions.removeEventListener(AdminApiEvent.EVENT_DATA_CHANGED, _statesController.currentState.actionDataChangeCallback);
			_silexAdminApi.components.removeEventListener(Components.EVENT_COMPONENT_CREATED, _statesController.currentState.componentCreatedCallback);
			_silexAdminApi.selectionManager.removeEventListener(SelectionManager.SELECTION_MODE_CHANGED, _statesController.currentState.selectionModeChangedCallback);
			_silexAdminApi.components.removeEventListener(Components.EVENT_COMPONENT_START_PASTE, _statesController.currentState.componentStartPasteCallback);
			
			
			//Events coming form the toolboxes
			
			_toolCommunication.removeEventListener(CommunicationEvent.ADD_COMPONENT, _statesController.currentState.AddComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.REMOVE_COMPONENT, _statesController.currentState.removeComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.ADD_LAYOUT, _statesController.currentState.addLayoutCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.REMOVE_LAYOUT, _statesController.currentState.removeLayoutCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.LAYERS_SELECTION_CHANGED, _statesController.currentState.userLayersSelectionChangeCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.COMPONENTS_SELECTION_CHANGED, _statesController.currentState.userComponentsSelectionChangeCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.COMPONENTS_ORDER_CHANGED, _statesController.currentState.componentsOrderChangeCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.SWAP_COMPONENTS, _statesController.currentState.componentsSwapCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.HIDE_LAYER, _statesController.currentState.hideLayerCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.SHOW_LAYER, _statesController.currentState.showLayerCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.HIDE_COMPONENT, _statesController.currentState.hideComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.SHOW_COMPONENT, _statesController.currentState.showComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.SAVE_LAYOUT, _statesController.currentState.saveLayoutCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.LOCK_COMPONENT, _statesController.currentState.lockComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.UNLOCK_COMPONENT, _statesController.currentState.unlockComponentCallback);
			_toolCommunication.removeEventListener(CommunicationEvent.COPY_COMPONENTS, _statesController.currentState.copyComponents); 
			_toolCommunication.removeEventListener(CommunicationEvent.PASTE_COMPONENTS, _statesController.currentState.pasteComponents);
			_toolCommunication.removeEventListener(CommunicationEvent.OVERWRITE_SKIN, _statesController.currentState.overWriteSkin);
			_toolCommunication.removeEventListener(CommunicationEvent.HIGHLIGHT_COMPONENTS, _statesController.currentState.highlightComponents);
			_toolCommunication.removeEventListener(CommunicationEvent.HIGHLIGHT_LAYER, _statesController.currentState.highlightLayer);
		
			
			
			//Events coming from the ToolBoxAPI
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.LOAD_EDITOR, _statesController.currentState.loadEditorCallback);
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.LOAD_LIBRARY, _statesController.currentState.loadLibraryCallback);
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.REFRESH_COMPONENT_NAME, _statesController.currentState.onRefreshComponentName);
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.LOAD_SKINNABLE_COMPONENT, _statesController.currentState.loadSkinnableComponentCallback);
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.LOAD_COMPONENT, _statesController.currentState.loadComponentCallback);
			ToolBoxAPIController.getInstance().removeEventListener(ToolBoxAPIEvent.LOAD_LEGACY_COMPONENT, _statesController.currentState.loadLegacyComponentCallback);
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// STATES METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Called when the current state of the wysiwyg
		 * must be changed. Remove the listeners, enter the new state,
		 * then state new listeners
		 */ 
		private function changeStateCallback(event:StateEvent):void
		{
			removeListeners();
			_statesController.enterState(event);
			initListeners();
		}
		
	}
}