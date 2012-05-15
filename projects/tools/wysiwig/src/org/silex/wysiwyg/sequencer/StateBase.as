/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer 
{
	import flash.errors.IllegalOperationError;
	import flash.events.EventDispatcher;
	
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.messaging.AbstractConsumer;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.WysiwygModel;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layer;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Property;
	import org.silex.adminApi.selection.SelectionManager;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.state_classes.AddComponentLibraryState;
	import org.silex.wysiwyg.sequencer.state_classes.AddComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.AddLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.AddLegacyComponentLibraryState;
	import org.silex.wysiwyg.sequencer.state_classes.AddSkinnedComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.ChooseMediaState;
	import org.silex.wysiwyg.sequencer.state_classes.OverWriteSkinState;
	import org.silex.wysiwyg.sequencer.state_classes.PasteComponentsState;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.RemoveLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateComponentState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateLayerState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateMultiSubLayerState;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxApi.event.ToolBoxAPIEvent;
	import org.silex.wysiwyg.toolboxes.addComponents.AddComponentLibrary;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.ConfirmAlertVO;
	import org.silex.wysiwyg.toolboxes.components.ComponentsUI;
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsUI;
	import org.silex.wysiwyg.toolboxes.properties.PropertiesUI;
	import org.silex.wysiwyg.utils.ComponentCopier;

	/**
	 * This is a base class for all Wysiwyg states. Implements default behaviour for
	 * common events and lists virtual methods
	 * @author Yannick Dominguez
	 */
	public class StateBase extends EventDispatcher
	{
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * A reference to the Silex Admin Api singleton
		 */ 
		protected var _silexAdminApi:SilexAdminApi;
		
		/**
		 * a reference to the ToolCommunication singleton, used as 
		 * an abstraction to call methods on the toolboxes
		 */ 
		protected var _toolCommunication:ToolCommunication;
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// CONSTRUCTOR
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * stores ref to silex Admin Api and tool communication
		 */ 
		public function StateBase(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication) 
		{
			_silexAdminApi = silexAdminApi;
			_toolCommunication = toolCommunication;
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PUBLIC METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * A method called just after the state instantiation, used to perform all
		 * the state initialisation. It's better to use this method rather than the
		 * constructor of the state, as when the constructor is called, the toolController
		 * listeners are not yet set on the newly instantiated state
		 */ 
		public function enterState():void
		{
			
		}
		
		/**
		 * A method called before a state is closed, used to remove all event and
		 * do all the required clean-up operations
		 */ 
		public function destroy():void
		{
			
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// SILEX ADMIN API CALLBACK METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		// those methods are called as a result
		// of an event dispatched by the SilexAdminApi.
		// might be overriden by inheriting states
		
		/**
		 * when the layer selection change, checks the layer selection
		 * state
		 * 
		 * @param event the AdminApiEvent triggered
		 */ 
		public function layersSelectionChangeCallback(event:AdminApiEvent):void
		{
			checkLayerSelection();
		}
		
		/**
		 * When a component is added, refresh the component toolbox then enter the
		 * update layer state (default state)
		 */ 
		public function componentCreatedCallback(event:AdminApiEvent):void
		{
			updateComponentToolbox();
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
		}
		
		
		/**
		 * when the layouts data changes, get the layouts and layers data from
		 * the SilexAdminApi then sets the data on the LayoutsToolBox through ToolCommunication
		 *  
		 * @param event the AdminApiEvent triggered
		 */ 
		public function layoutsDataChangeCallback(event:AdminApiEvent):void
		{	
			//refresh the layout toolbox
			getLayoutsLayersData();
			
			//then enter the approprate state
			checkLayerSelection();
		}
		
		/**
		 * when the components data change, sets the data on the components ToolBox
		 *
		 * 
		 * @param event the triggerred AdminApiEvent
		 */ 
		public function componentsDataChangeCallback(event:AdminApiEvent):void
		{
			updateComponentToolbox();
			checkComponentsSelection();
			//update the visual selection in the component toolbox 
			_toolCommunication.setSelection(ToolCommunication.COMPONENTS_TOOLBOX, Vector.<String>(_silexAdminApi.components.getSelection()));
		}
		
		/**
		 * sets the selection on the ComponentsToolBox 
		 * then if one or more components are selected, load the default editor then enters the update components state designed to edit
		 * a component's properties
		 * 
		 * @param event the AdminApiEvent triggered
		 */ 
		public function componentsSelectionChangeCallback(event:AdminApiEvent):void
		{
			checkComponentsSelection();
		
		}
		
		/**
		 * When one or many layout(s) has/have been saved, check for the dirty layouts
		 */ 
		public function layoutsSaveOKCallback(event:AdminApiEvent):void
		{
			_toolCommunication.callMethod(ToolCommunication.LAYOUT_TOOLBOX, LayoutsUI.CHECK_DIRTY);
		}
		
		/**
		 * when the properties data change, sets the new data on the properties Toolbox
		 * through the _toolCommunication object
		 * 
		 * @param event the trigerred AdminApiEvent
		 */ 
		public function propertiesDataChangeCallback(event:AdminApiEvent):void
		{
			_toolCommunication.callMethod(ToolCommunication.LAYOUT_TOOLBOX, LayoutsUI.CHECK_DIRTY);
		}
		
		/**
		 * when action changed, check if the layout is dirty
		 */ 
		public function actionDataChangeCallback(event:AdminApiEvent):void
		{
			_toolCommunication.callMethod(ToolCommunication.LAYOUT_TOOLBOX, LayoutsUI.CHECK_DIRTY);
		}
		
		/**
		 * When the properties selection changes, determines which property editor
		 * to open then loads it using the ToolBoxAPI
		 */ 
		public function propertiesSelectionChangeCallback(event:AdminApiEvent):void
		{
			var selectedPropertyUid:Vector.<String> = Vector.<String>(_silexAdminApi.properties.getSelection()) ;
			var selectedProperty:Property;
			
			var properties:Vector.<Property> = Vector.<Property>(_silexAdminApi.properties.getData()[0]);
			
			var propertiesLength:int = properties.length;
			for (var i:int = 0; i<propertiesLength; i++)
			{
				if (properties[i].uid == selectedPropertyUid[0])
				{
					selectedProperty = properties[i] as Property;
				}
			}
			
			var propertyEditorData:Object = getPropertyEditorData(selectedProperty);
			
			if (propertyEditorData != null)
			{
				ToolBoxAPIController.getInstance().loadEditor(propertyEditorData.url, propertyEditorData.description);
			}
		}
		
		/**
		 * When the selection mode changes, refresh the component and layout toolboxes toolbox selection to be sure
		 * to stay in sync with the editable/non-editable components
		 */ 
		public function selectionModeChangedCallback(event:AdminApiEvent):void
		{
			//update the visual selection of layers in the layer toolbox
			_toolCommunication.setSelection(ToolCommunication.LAYOUT_TOOLBOX, Vector.<String>(_silexAdminApi.layers.getSelection()));
			
			//update the visual selection in the component toolbox 
			_toolCommunication.setSelection(ToolCommunication.COMPONENTS_TOOLBOX, Vector.<String>(_silexAdminApi.components.getSelection()));
		}
		
		/**
		 * When a paste process begins for one or multiple component(s), 
		 * enter the paste components state
		 */ 
		public function componentStartPasteCallback(event:AdminApiEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, PasteComponentsState));
		}
		
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// USER INTERACTION CALLBACK METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		// those methods are called as a result
		// of a user interaction. Might be overriden
		// by inheriting states
		
		/**
		 * calls the SilexAdminAPI show method, passing it the Layer's uid.
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function showLayerCallback(event:CommunicationEvent):void
		{
			(event.data as Layer).setVisible(true);
		}
		
		
		/**
		 * calls the SilexAdminAPI hide method, passing it the Layer's uid.
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function hideLayerCallback(event:CommunicationEvent):void
		{
			(event.data as Layer).setVisible(false);
		}
		
		/**
		 *  calls the save layout method on SilexAdminAPI on the necessary layout.
		 *  the default behavior is to save the selected layout, it is overriden in other states
		 * 
		 */ 
		public function saveLayoutCallback(event:CommunicationEvent):void
		{
			var layouts:Vector.<Layout> = Vector.<Layout>(_silexAdminApi.layouts.getData()[0]);
			var selectedLayerUid:String = _silexAdminApi.layers.getSelection()[0];
			
			var layoutsLength:int = layouts.length;
			for (var i:int; i<layoutsLength; i++)
			{
				var tempLayers:Vector.<Layer> = Vector.<Layer>(_silexAdminApi.layers.getData([(layouts[i] as Layout).uid])[0]);
				var tempLayersLength:int = tempLayers.length;
				for (var j:int = 0; j<tempLayersLength; j++)
				{
					if (tempLayers[j].uid == selectedLayerUid)
					{
						layouts[i].save();
					}
				}
			}
		}
		
		/**
		 *  calls the save layout method on SilexAdminAPI on all the layouts.
		 */ 
		public function saveAllLayoutCallback(event:CommunicationEvent):void
		{
			var layouts:Vector.<Layout> = Vector.<Layout>(_silexAdminApi.layouts.getData()[0]);
			
			var layoutsLength:int = layouts.length;
			for (var i:int; i<layoutsLength; i++)
			{
				layouts[i].save();
			}
		}
		
		
		/**
		 * calls the SilexAdminAPI show method, passing it the component's uid.
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function showComponentCallback(event:CommunicationEvent):void
		{
			(event.data as Component).setVisible(true);
		}
		
		/**
		 * calls the SilexAdminAPI hide method, passing it the component's uid.
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function hideComponentCallback(event:CommunicationEvent):void
		{
			(event.data as Component).setVisible(false);
		}
		
		/**
		 * Lock the component passed as parameter
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function lockComponentCallback(event:CommunicationEvent):void
		{
			(event.data as Component).setEditable(false);
		}
		
		/**
		 * unlock the component passed as a parameter
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function unlockComponentCallback(event:CommunicationEvent):void
		{
			(event.data as Component).setEditable(true);
		}
		
		/**
		 * Lock the layer passed as parameter
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function lockLayerCallback(event:CommunicationEvent):void
		{
			(event.data as Layer).setEditable(false);
		}
		
		/**
		 * unlock the layer passed as a parameter
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function unlockLayerCallback(event:CommunicationEvent):void
		{
			(event.data as Layer).setEditable(true);
		}
		
		/**
		 *  calls the select layer method on SilexAdminAPI on user selection
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function userLayersSelectionChangeCallback(event:CommunicationEvent):void
		{
			var uids:Array = new Array();
			
			var layers:Vector.<Layer> = Vector.<Layer>(event.data);
			var layersLength:int = layers.length;
			for (var i:int = 0; i<layersLength; i++)
			{
				uids.push(layers[i].uid);
			}
			
			//if there are mor than one layer to select, it means the user
			//added another layer to the current layer selection and so we keep the current
			//components selection
			if (uids.length > 1)
			{
				var selectedComponentsUids:Array = _silexAdminApi.components.getSelection();
				_silexAdminApi.layers.select(uids, ToolCommunication.LAYOUT_TOOLBOX);
				_silexAdminApi.components.select(selectedComponentsUids);
			}
			else
			{
				_silexAdminApi.layers.select(uids, ToolCommunication.LAYOUT_TOOLBOX);
			}
		}
		
		/**
		 *  calls the select component method on SilexAdminAPI on user selection
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function userComponentsSelectionChangeCallback(event:CommunicationEvent):void
		{
			_silexAdminApi.components.select(event.data as Array, ToolCommunication.COMPONENTS_TOOLBOX);
		}
		
		/**
		 *  calls the change component's order method on SilexAdminAPI on user selection
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function componentsOrderChangeCallback(event:CommunicationEvent):void
		{
			_silexAdminApi.components.changeOrder(event.data.uidArray as Array);
			_toolCommunication.callMethod(ToolCommunication.LAYOUT_TOOLBOX, LayoutsUI.CHECK_DIRTY);
		}
		
		/**
		 *  calls the swap component's items depth method on SilexAdminAPI on user selection then 
		 * selects the swapped component
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function componentsSwapCallback(event:CommunicationEvent):void
		{
			_silexAdminApi.components.swapItemDepths((event.data as Array)[0], (event.data as Array)[1]);
			_silexAdminApi.components.select([(event.data as Array)[0]], ToolCommunication.COMPONENTS_TOOLBOX );
			
		}
		
		/**
		 * Highlight components on the scene with their uids
		 * @param the triggered communication event, containing the uids of the 
		 * components to highlight
		 */ 
		public function highlightComponents(event:CommunicationEvent):void
		{
			_silexAdminApi.selectionManager.highlightComponents(event.data as Array);
		}
		
		/**
		 * Highlight all of a layer's components. 
		 * @param event the triggered communication event, containing the uid of the layer to 
		 * highlight
		 */ 
		public function highlightLayer(event:CommunicationEvent):void
		{
			//store the components uids
			var componentsUids:Array = new Array();
			
			//if the uid is null, send an empty array
			if (event.data != null)
			{
				//retrieve the layer's components
				var components:Vector.<Component> = Vector.<Component>(_silexAdminApi.components.getData(event.data as Array)[0]);
				var componentsLength:int = components.length;
			
				for (var i:int = 0; i<componentsLength; i++)
				{
					componentsUids.push(components[i].uid);
				}
			}
			
			_silexAdminApi.selectionManager.highlightComponents(componentsUids);
		}
		
		
		/**
		 *  enters the ADD_COMPONENT state
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function AddComponentCallback(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddComponentState));
		}
		
		/**
		 * When the user wants to add a layout, enters the default state, then instantiate a PagePropertiesVO value object.
		 * This object will store all the necessary data displayed by the pagePropertiesToolbox
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function addLayoutCallback(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddLayoutState));
		}
		
		/**
		 * When the user wants to remove one or many components, sets the data on the alert toolbox and open it
		 * to ask the user to confirm his choice
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function removeComponentCallback(event:CommunicationEvent):void
		{			
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, RemoveComponentState));
		}
		
		/**
		 * When the user wants to remove a layout, the alert toolbox is shown with a message asking the
		 * user to confirm his choice
		 * 
		 */
		public function removeLayoutCallback(event:CommunicationEvent):void
		{	
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, RemoveLayoutState, event.data));
		}
		
		
		/**
		 * stores the data of the selected components
		 * 
		 * @param event the trigerred event
		 */ 
		public function copyComponents(event:CommunicationEvent):void
		{
			ComponentCopier.getInstance().copy();
		}
		
		/**
		 * paste the previously copied components to the first selected layer
		 * 
		 * @param event the trigerred event
		 */ 
		public function pasteComponents(event:CommunicationEvent):void
		{
			ComponentCopier.getInstance().paste();
		}
		
		/**
		 * Enter an alert state to prompt the user to confirm
		 * the skin overwrite
		 */ 
		public function overWriteSkin(event:CommunicationEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, OverWriteSkinState));
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// TOOLBOX API CALLBACK METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		// those methods are called as a result
		// of an event dispatched by the ToolBoxApi.
		// might be overriden by inheriting states
		
		/**
		 *  update the name of the component displayed in the components toolbox
		 * 
		 * @param event the CommunicationEvent triggered
		 */ 
		public function onRefreshComponentName(event:ToolBoxAPIEvent):void
		{
			_toolCommunication.callMethod(ToolCommunication.COMPONENTS_TOOLBOX, ComponentsUI.REFRESH_COMPONENTS_NAME, event.data);
			refreshPropertyToolboxHeaderNames();
		}
		
		/**
		 * set the data on the properties toolbox, loading a new panel in it
		 * 
		 * @param event the event dispatched by the ToolBoxApi
		 */ 
		public function loadEditorCallback(event:ToolBoxAPIEvent):void
		{
			_toolCommunication.setData(ToolCommunication.PROPERTIES_TOOLBOX, event.data);
		}
		
		/**
		 * displays the add component library toolbox and enters AddLegacyComponentLibraryState
		 */ 
		public function loadLegacyComponentCallback(event:ToolBoxAPIEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddLegacyComponentLibraryState));
		}
		
		/**
		 * when the wysiwyg is prompted to open the library to add media components, it enters the AddComponentsLibraryState, opening the 
		 * AddComponents Toolbox in Library mode
		 * 
		 * @param event the triggered ToolBoxApievent contening the filters array for the library
		 */ 
		public function loadLibraryCallback(event:ToolBoxAPIEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddComponentLibraryState));
		}
		
		/**
		 * displays the skinned component panel in the addComponent toolbox
		 */ 
		public function loadSkinnableComponentCallback(event:ToolBoxAPIEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddSkinnedComponentState));
		}
		
		/**
		 * displays the add component toolbox and enters the AddComponent state
		 */ 
		public function loadComponentCallback(event:ToolBoxAPIEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, AddComponentState));
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PROTECTED METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * Check the current layer selection and react accordingly. If no layers are selected,
		 * select the top layer (the one displayed on top), as at least one layer must always be selected.
		 * If one layer is selected, enter the updateLayerState, if more than one, enter the updateMultipleLayer
		 * state
		 */ 
		protected function checkLayerSelection():void
		{
			var layerSelection:Vector.<String> = Vector.<String>(_silexAdminApi.layers.getSelection());
			
			//update the visual selection of layers in the layer toolbox
			_toolCommunication.setSelection(ToolCommunication.LAYOUT_TOOLBOX, layerSelection);
		
			if (layerSelection.length == 1)
			{
				updateComponentToolbox();
				//trace("check layer select");
				dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
			}
				
			else if (layerSelection.length > 1)
			{
				dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateMultiSubLayerState));
			}
		}
		
		/**
		 * checks the current component selection. If at least one component
		 * is selected, enter the update component state, else enter the
		 * update layer state
		 */ 
		protected function checkComponentsSelection():void
		{
			var selectedComponentsUid:Vector.<String> = Vector.<String>(_silexAdminApi.components.getSelection());
			
			//update the visual selection in the component toolbox 
			_toolCommunication.setSelection(ToolCommunication.COMPONENTS_TOOLBOX, selectedComponentsUid);
			refreshPropertyToolboxHeaderNames();
			
			if (selectedComponentsUid != null && selectedComponentsUid.length > 0)
			{
				dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateComponentState ));
				ToolBoxAPIController.getInstance().loadEditor(ToolBoxAPIController.getInstance().getDefaultEditor().editorUrl, ToolBoxAPIController.getInstance().getDefaultEditor().description);
			}
				
			else
			{
				//trace("check comp select");
				dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, UpdateLayerState));
			}
		}
		
		/**
		 * display the name(s) of the selected component(s) in the property toolbox header
		 */ 
		protected function refreshPropertyToolboxHeaderNames():void
		{
			//get the string of the selected components names
			var ret:String = _toolCommunication.callMethod(ToolCommunication.COMPONENTS_TOOLBOX, ComponentsUI.GET_SELECTED_COMPONENTS_NAMES);
			
			//call the method on the properties toolbox that will update the header text
			//with the name of the new selected components
			_toolCommunication.callMethod(ToolCommunication.PROPERTIES_TOOLBOX, PropertiesUI.UPDATE_HEADER_TEXT, ret);
		}
		
		/**
		 * update the components toolbox data
		 */ 
		protected function updateComponentToolbox():void
		{
			//trace("update component toolbox method");
			_toolCommunication.setData(ToolCommunication.COMPONENTS_TOOLBOX, _silexAdminApi.components.getData()[0]);
		}
		
		/**
		 * gets the current layouts and layers from the SilexAdminAPI,
		 * store them in an array and sends it to the layouts Toolbox
		 */ 
		protected function getLayoutsLayersData():void
		{
			//trace("getLayoutsLayersData  method");
			//the array that will store all the layouts and layers for the data list
			var dataArray:Array = new Array();
			
			//a vector of the currently displayed layouts
			var layouts:Vector.<Layout> = Vector.<Layout>(_silexAdminApi.layouts.getData()[0]);
			
			//if we can't access the layouts data, we do nothing
			if(layouts == null)
			{
				return;
			}
			
			//an array that will contain the currents layouts uids
			var layoutsUid:Array = new Array();
			
			var layoutsLength:int = layouts.length;
			//extract the uids of each layouts and store them in the vector
			for (var k:int = 0; k<layoutsLength; k++)
			{
				layoutsUid[k] = layouts[k].uid;
			}
			
			//fills an array with the currently displayed layers
			var layers:Array =  _silexAdminApi.layers.getData(layoutsUid);
			//loop in each layout
			for (var i:int = 0; i < layoutsLength; i++)
			{
				//add the layout to the data list array
				dataArray[dataArray.length] = layouts[i];
				
				//loop in each layer
				var currentLayers:Vector.<Layer> = Vector.<Layer>(layers[i]);
				var layersLength:int = currentLayers.length;
				for (var j:int = 0; j < layersLength; j++)
				{
					//add the layer to the data list array
					dataArray[dataArray.length] = (currentLayers[j]);
				}
				
			}
			
			//sets the data on the layout Toolbox
			_toolCommunication.setData(ToolCommunication.LAYOUT_TOOLBOX, dataArray);
		}
		
	
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PRIVATE METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * returns the url and the description of the property editor based on the name of the property or on 
		 * it's subType if there is no match with it's name and at last on it's type.
		 * 
		 * @param	property the property object
		 */
		private function getPropertyEditorData(property:Property):Object
		{	
			
			var propertyEditors:Object = ToolConfig.getInstance().propertyEditorsPlugins;
			
			//return if no property given
			if (property == null)
			{
				return null;
			}
			
			//return if no property editor is defined
			if (propertyEditors == null)
			{
				return null;
			}
			
			//check if there is a property editor with the same name as the property
			if (propertyEditors[property.name] != null)
			{
				return {url:propertyEditors[property.name], description:property.description};
			}
			
			//if the property has a subType
			if (property.subType != null)
			{
				//check if there is a propertyEditor whose name corresponds to the subtype
				if (propertyEditors[property.subType] != null)
				{
					return {url:propertyEditors[property.subType], description:property.description};
				}
			}
			
			//at last, check if there is a property editor whose name matches the type of the property
			if (propertyEditors[property.type] != null)
			{
				return {url:propertyEditors[property.type], description:property.description};
			}
			
			return null;
		}
		
		/**
		 * utility method replacing characters in a string
		 * @param	org the string whick will be parsed
		 * @param	fnd the characters that need to be replaced
		 * @param	rpl the replacing characther
		 */
		private function replace(org:String, fnd:String, rpl:String):String
		{
			return org.split(fnd).join(rpl);
		}
		
	}

}