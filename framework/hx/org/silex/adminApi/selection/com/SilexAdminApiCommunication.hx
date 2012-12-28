/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.com;
import haxe.Log;
import org.silex.adminApi.selection.SelectionManager;
import org.silex.adminApi.selection.utils.Structures;
import flash.Lib;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

/**
 * A singleton abstracting the access to SilexAdminApi to separate DOM specific methods from the core
 * of the SelectionManager
 * @author Yannick DOMINGUEZ
 */
class SilexAdminApiCommunication 
{
	////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The returned class instance of the singleton
	 */
	private static var _silexAdminApiCommunication:SilexAdminApiCommunication;
	
	/**
	 * The current SelectionManager selection mode
	 */
	private var _selectionMode:String;
	
	/**
	 * Signals when the components data changes on the SilexAdminApi
	 */
	public var silexAdminApiComponentDataChangeSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signals when the component selection changes on the SilexAdminApi
	 */
	public var silexAdminApiComponentSelectionChangeSignaler(default, null):Signaler<Void>;
	
	/**
	 * Signals when the properties data changes on the SilexAdminApi
	 */
	public var silexAdminApiPropertiesDataChangeSignaler(default, null):Signaler<Void>;
	
	/**
	 * A reference to the SilexAdminApi
	 */
	private var _silexAdminApi:Dynamic;
	
	/**
	 * Stores the current editable components. Acts as a buffer, only
	 * refrshed when necessary
	 */
	private var _editableComponents:Array<ComponentCoordsProxy>;
	
	/**
	 * Stores the current non-editable components. Acts as a buffer, only
	 * refreshed when necessary
	 */
	private var _nonEditableComponents:Array<ComponentCoordsProxy>;
	
	/**
	 * Stores the current displayed components. Acts as a buffer, only
	 * refreshed when necessary
	 */
	private var _displayedComponents:Array<ComponentCoordsProxy>;
	
	/**
	 * Stores the current selectable components. Acts as a buffer, only
	 * refreshed when necessary
	 */
	private var _selectableComponents:Array<ComponentCoordsProxy>;
	
	/**
	 * Stores the current selected components. Acts as a buffer, only
	 * refreshed when necessary
	 */
	private var _selectedComponents:Array<ComponentCoordsProxy>;
	
	/**
	 * Stores the uids of the currently displayed layers. Acts as a buffer, 
	 * only refreshed when necessary
	 */
	private var _layersUid:Array<String>;
	
	/**
	 * Stores the reference to the ComponentProxy currently displayed. Acts
	 * as a buffer, only refreshed when necessary
	 */
	private var _components:Array<Dynamic>;
	
	/**
	 * Callback delegates
	 */
	private var _componentsSelectionChangedDelegate:Void->Void;
	private var _layersDataChangedDelegate:Void->Void;
	private var _componentsDataChangedDelegate:Void->Void;
	private var _propertiesDataChangedDelegate:Dynamic->Void;
	private var _componentStartPasteDelegate:Void->Void;
	private var _componentEndPasteDelegate:Void->Void;
	private var _componentCreatedDelegate:Void->Void;
	private var _layoutsDataChangedDelegate:Void->Void;
	
	
	////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Stores a reference to SilexAdminApi, initialise the signaler and
	 * listen for events on SilexAdminApi
	 */
	private function new() 
	{
		_silexAdminApi = Lib._global.org.silex.adminApi.SilexAdminApi.getInstance();
		
		silexAdminApiComponentDataChangeSignaler = new DirectSignaler(this);
		silexAdminApiPropertiesDataChangeSignaler = new DirectSignaler(this);
		silexAdminApiComponentSelectionChangeSignaler = new DirectSignaler(this);
		
		setListeners();
	}
	
	////////////////////**/*/*/*/*/*/*/
	// EVENT METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Set all the listeners on SilexAdminApi. Stores delegate to allow
	 * clean event removing
	 */
	private function setListeners():Void
	{
		_componentsSelectionChangedDelegate = onComponentsSelectionChanged;
		_layersDataChangedDelegate = onLayersDataChanged;
		_layoutsDataChangedDelegate = onComponentDataChanged;
		_propertiesDataChangedDelegate = onPropertiesDataChanged;
		_componentCreatedDelegate = onComponentDataChanged;
		_componentStartPasteDelegate = onComponentStartPaste;
		_componentsDataChangedDelegate = onComponentDataChanged;
		
		
		_silexAdminApi.components.addEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_SELECTION_CHANGED, _componentsSelectionChangedDelegate);
		_silexAdminApi.layers.addEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _layersDataChangedDelegate);
		_silexAdminApi.layouts.addEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _layoutsDataChangedDelegate);
		_silexAdminApi.properties.addEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _propertiesDataChangedDelegate);
		_silexAdminApi.components.addEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_CREATED, _componentCreatedDelegate);
		_silexAdminApi.components.addEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_START_PASTE, _componentStartPasteDelegate);
		_silexAdminApi.components.addEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _componentsDataChangedDelegate);
	}
	
	/**
	 * Removes all listeners on SilexAdminApi, with the stored delegates. Reset
	 * the delegates
	 */
	private function removeListeners():Void
	{
		_silexAdminApi.components.removeEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_SELECTION_CHANGED, _componentsSelectionChangedDelegate);
		_silexAdminApi.layers.removeEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _layersDataChangedDelegate);
		_silexAdminApi.layouts.removeEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _layoutsDataChangedDelegate);
		_silexAdminApi.properties.removeEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _propertiesDataChangedDelegate);
		_silexAdminApi.components.removeEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_CREATED, _componentCreatedDelegate);
		_silexAdminApi.components.removeEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_START_PASTE, _componentStartPasteDelegate);
		_silexAdminApi.components.removeEventListener(
		Lib._global.org.silex.adminApi.AdminApiEvent.EVENT_DATA_CHANGED, _componentsDataChangedDelegate);
		
		_componentsSelectionChangedDelegate = null;
		_layersDataChangedDelegate = null;
		_layoutsDataChangedDelegate = null;
		_propertiesDataChangedDelegate = null;
		_componentCreatedDelegate = null;
		_componentStartPasteDelegate = null;
		_componentsDataChangedDelegate = null;
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Return the class and instance of the singleton and initialise it
	 * if null
	 * @return the class instance
	 */
	public static function getInstance():SilexAdminApiCommunication
	{
		if (_silexAdminApiCommunication == null)
		{
			_silexAdminApiCommunication = new SilexAdminApiCommunication();
		}
		
		return _silexAdminApiCommunication;
	}
	
	/**
	 * Return a component proxy from it's uid
	 * @param	componentUid the uid of the component
	 * @return the component proxy
	 */
	public function getComponentProxyFromUid(componentUid:String):Dynamic
	{
		return Lib._global.org.silex.adminApi.listedObjects.ComponentProxy.createFromUid(componentUid);
	}
	
	/**
	 * Returns a component coords proxy from an uid
	 * @param	componentUid the uid of the target component
	 * @return the component proxy
	 */
	public function getComponentCoordsProxyFromUid(componentUid:String):ComponentCoordsProxy
	{
		return getComponentCoordsProxyFromComponentProxy(getComponentProxyFromUid(componentUid));
	}
	
	/**
	 * Return a component proxy from a component
	 * @param	component the component
	 * @return the component proxy
	 */
	public function getComponentProxyFromComponent(component:Dynamic):Dynamic
	{
		return Lib._global.org.silex.adminApi.listedObjects.ComponentProxy.createFromComponent(component);
	}
	
	/**
	 * Return the coords of component from a component
	 * @param	component the component
	 * @return the component coords
	 */
	public function getComponentCoordsProxyFromComponent(component:Dynamic):ComponentCoordsProxy
	{
		var componentProxy:Dynamic = Lib._global.org.silex.adminApi.listedObjects.ComponentProxy.createFromComponent(component);
		return getComponentCoordsProxyFromComponentProxy(componentProxy);
		
	}
	
	/**
	 * Return a component coord proxy from a component proxy
	 * @param	componentProxy the target component proxy
	 * @return the component proxy coords
	 */
	public function getComponentCoordsProxyFromComponentProxy(componentProxy:Dynamic):ComponentCoordsProxy
	{
		var properties:Dynamic = _silexAdminApi.properties.getSortedData(
		[componentProxy.uid],
		["x", "y", "width", "height", "rotation"], "name")[0];
		
		var componentCoordsProxy:ComponentCoordsProxy = {
			componentCoords:{
				x:properties.x.currentValue,
				y:properties.y.currentValue,
				width:properties.width.currentValue,
				height:properties.height.currentValue,
				rotation:properties.rotation.currentValue
			},
			componentUid:componentProxy.uid
		}
		
		return componentCoordsProxy ;
	}
	
	/**
	 * Reset the layer selection, it will reset the
	 * seelction to the top layer
	 */
	public function resetLayerSelection():Void
	{

		_silexAdminApi.layers.select([], SelectionManager.SELECTION_MANAGER_ID);
	}
	
	/**
	 * Set the selection mode, reset all the components buffers
	 * @param	selectionMode the current selection mode
	 */
	public function setSelectionMode(selectionMode:String):Void
	{
		_layersUid = null;
		_components = null;
		_displayedComponents = null;
		_selectableComponents = null;
		_editableComponents = null;
		_nonEditableComponents = null;
		_selectedComponents = null;
		_selectionMode = selectionMode;
	}
	
	/**
	 * Select components on the SilexAdminApi and the corresponding layers
	 * @param	componentsToSelect the components to select
	 */
	public function selectComponents(componentsToSelect:Array<ComponentCoordsProxy>):Void
	{
		var componentsToSelectUids:Array<String> = new Array<String>();
		var layersToSelectUids:Array<String> = new Array<String>();
		
		var selectedComponentsUid:Array<String> = _silexAdminApi.components.getSelection();
		var selectedLayerssUid:Array<String> = _silexAdminApi.layers.getSelection();
		
		var componentsToSelectLength:Int = componentsToSelect.length;
		
		for (i in 0...componentsToSelectLength)
		{
			var componentProxy:Dynamic = Lib._global.org.silex.adminApi.listedObjects.ComponentProxy.createFromUid(componentsToSelect[i].componentUid);
			
			componentsToSelectUids.push(componentProxy.uid);
			var layerProxy:Dynamic =  Lib._global.org.silex.adminApi.listedObjects.LayerProxy.createFromComponent(componentProxy.getComponent());
			var flagLayerAlreadySelected:Bool = false;
			
			var layersToSelectUidsLength:Int = layersToSelectUids.length;
			for (j in 0...layersToSelectUidsLength)
			{
				if (layersToSelectUids[j] == layerProxy.uid)
				{
					flagLayerAlreadySelected = true;
				}
			}
			
			if (flagLayerAlreadySelected == false)
			{
				layersToSelectUids.push(layerProxy.uid);
			}
				
		}
		//we select the component and subLayer through SilexAdminApi
		
		//check if layer selection has changed, only select if it has
		//if the layers selection changes, always select components, as changing
		//the layers selection reset the components selection
		if (checkDifferentSelection(selectedLayerssUid, layersToSelectUids) == true)
		{
			_silexAdminApi.layers.select(layersToSelectUids, SelectionManager.SELECTION_MANAGER_ID);
			_silexAdminApi.components.select(componentsToSelectUids, SelectionManager.SELECTION_MANAGER_ID);
		}
		//else only select the components, it is required to refresh the ui
		else
		{
			_silexAdminApi.components.select(componentsToSelectUids, SelectionManager.SELECTION_MANAGER_ID);
		}
		
	}
	
	
	/**
	 * Returns the currently selected components uids
	 * @return the selected uids
	 */
	public function getSelectedComponentsUids():Array<String>
	{
		return _silexAdminApi.components.getSelection();
	}
	
	/**
	 * Proxies access to the selected components. Retrieve them if it's the first
	 * request. Return a copy of the components
	 * @return the array of selected components
	 */
	public function getSelectedComponents():Array<ComponentCoordsProxy>
	{
		if (_selectedComponents == null)
		{
			_selectedComponents = doGetSelectedComponents();
		}
		return getCopy(_selectedComponents);
	}
	
	
	/**
	 * Proxies access to the displayed components. Retrieve them if it's the first
	 * request. Return a copy of the components
	 * @return the array of displayed components
	 */
	public function getDisplayedComponents():Array<ComponentCoordsProxy>
	{
		if (_displayedComponents == null)
		{
			_displayedComponents = doGetDisplayedComponents();
		}
		return getCopy(_displayedComponents);
	}
	
	/**
	 * Proxies access to the selectable components. Retrieve them if it's the first
	 * request. Return a copy of the components
	 * @return the array of selectable components
	 */
	public function getSelectableComponents():Array<ComponentCoordsProxy>
	{
		if (_selectableComponents == null)
		{
			_selectableComponents = doGetSelectableComponents();
		}
		return getCopy(_selectableComponents);
	}
	
	/**
	 * Proxies access to the editable components. Retrieve them if it's the first
	 * request. Return a copy of the components
	 * @return the array of editable components
	 */
	public function getEditableComponents():Array<ComponentCoordsProxy>
	{
		if (_editableComponents == null)
		{
			_editableComponents = doGetEditableComponents();
		}
		return getCopy(_editableComponents);
	}
	
	/**
	 * Proxies access to the non-editable components. Retrieve them if it's the first
	 * request. Return a copy of the components
	 * @return the array of editable components
	 */
	public function getNonEditableComponents():Array<ComponentCoordsProxy>
	{
		if (_nonEditableComponents == null)
		{
			_nonEditableComponents = doGetNonEditableComponents();
		}
		return getCopy(_nonEditableComponents);
	}
	
	/**
	 * Copy the currently selected components through SilexAdminApi
	 */
	public function copySelectedComponents()
	{
		_silexAdminApi.components.copy();
	}
	
	/**
	 * Paste the previously selected components through SilexAdminApi
	 */
	public function pasteSelectedComponents()
	{
		_silexAdminApi.components.paste();
	}
	
	/**
	 * For all the transformed components, update the value of their coordinates properties
	 * through SilexAdminApi
	 * 
	 * @param tranformedComponents the array of component transformed
	 */ 
	public function commitProperties(tranformedComponents:Array<ComponentCoordsProxy>):Void
	{
		//update the stored components properties
		updateComponentsPlaceHolders(tranformedComponents);
		
		//an array storing the name of all the properties we want to update
		var propertiesToUpdateNames:Array<String> = ["x", "y", "width", "height", "rotation"];
		
		var transformedComponentsLength:Int = tranformedComponents.length;
		var propertiesToUpdateNamesLength:Int = propertiesToUpdateNames.length;
		for (i in 0...transformedComponentsLength)
		{
			var transformedComponentData:ComponentCoordsProxy = tranformedComponents[i];
			
			for (j in 0...propertiesToUpdateNamesLength)
			{
				var targetPropertyValue:Int = Reflect.field(transformedComponentData.componentCoords, propertiesToUpdateNames[j]);
				//if the targeted proeprty is not null, update it's value
				if (targetPropertyValue != null)
				{
					var updatePropertyData:UpdatePropertyData = {
						value : targetPropertyValue, 
						propertyName : propertiesToUpdateNames[j], 
						componentUid:transformedComponentData.componentUid 
						};
	
					this.commitProperty(updatePropertyData);
				}
			}
		}
	}
	
	/**
	 * Returns the reference to SilexAdminApi
	 * @return a reference to SilexAdminApi
	 */
	public function getSilexAdminApi():Dynamic
	{
		return _silexAdminApi;
	}
	
	/**
	 * Dispatches a cross platform event through SilexAdminApi
	 * @param	eventType the type of event to dispatch
	 * @param	target the target of the event on SilexAdminApi
	 * @param	data the data of the event
	 */
	public function dispatchEvent(eventType:String, target:String, data:Dynamic = null):Void
	{
		var eventToDispatch:Dynamic = untyped __new__(Lib._global.org.silex.adminApi.AdminApiEvent, eventType, target, data);
		Lib._global.org.silex.adminApi.ExternalInterfaceController.getInstance().dispatchEvent(eventToDispatch);
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When components are transformed with the selectionTool, update the stored
	 * componenents (editable components, selectable components...) to stay in sync with the
	 * model without having to retrieve the new coordinates of the components through SilexAdminApi
	 * @param	transformedComponents
	 */
	private function updateComponentsPlaceHolders(transformedComponents:Array<ComponentCoordsProxy>):Void
	{
		//if no components where transformed like the
		//pivot point transform for instance, 
		//don't overwrite seelcted components
		if (transformedComponents == null || transformedComponents.length == 0)
		{
			return;
		}
		
		
		//update all the selected components with the transformed components, as all transformed components
		//must be selected
		_selectedComponents = transformedComponents;
		
		
		//for other components type (editable components, non-editable components...), loop
		//in the transformed components array to find and replace the matching components with 
		//their uids
		var transformedComponentsLength:Int = transformedComponents.length;
		for (i in 0...transformedComponentsLength)
		{
			var editableComponentsLength:Int = _editableComponents.length;
			for (j in 0...editableComponentsLength)
			{
				if (transformedComponents[i].componentUid == _editableComponents[j].componentUid)
				{
					_editableComponents[j] = transformedComponents[i];
				}
			}
		}
	}
	
	/**
	 * Proxies acces to the currently displayed layers uids. Retrieve 
	 * them if it is the first access or if the displayed layers changed
	 * @return an array containing all the displayed layers'uids
	 */
	private function getLayersUids():Array<String>
	{
		if (_layersUid == null)
		{
			_layersUid = doGetLayersUids();
		}
		return _layersUid;
	}
	
	/**
	 * Proxies access to the currently displayed components. Retrieve them
	 * if first access or if the displayed components changed after a page change
	 * @return an array of ComponentProxy
	 */
	private function getComponents():Array<Dynamic>
	{
		if (_components == null)
		{
			_components = _silexAdminApi.components.getData(getLayersUids());
		}
		return _components;
	}
	
	/**
	 * Get all the components (visual and non-visual) from the currently
	 * displayed subLayers
	 * @return an array of components coords proxy
	 */
	private function doGetDisplayedComponents():Array<ComponentCoordsProxy>
	{
		var components:Array<Dynamic> = getComponents();
		var displayedComponents:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		var componentsLength:Int = components.length;
		for (i in 0...componentsLength)
		{
			//reverse components else they are not sorted by z-order
			var currentLayerComponents:Array<Dynamic> = components[i].reverse();
			var currentLayersComponentsLength:Int = currentLayerComponents.length;
			for (j in 0...currentLayersComponentsLength)
			{
				var displayedComponentProxy:Dynamic = currentLayerComponents[j];
				displayedComponents.push(getComponentCoordsProxyFromComponentProxy(displayedComponentProxy));
			}
			
		}
		return displayedComponents;
	}
	
	/**
	 * Get the visual components from the currently displayed subLayers
	 * @return an array of components coords proxy
	 */
	private function doGetSelectableComponents():Array<ComponentCoordsProxy>
	{
		var displayedComponents:Array<ComponentCoordsProxy> = getDisplayedComponents();
		var selectableComponents:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		var displayedComponentsLength:Int = displayedComponents.length;
		for (i in 0...displayedComponentsLength)
		{
			var displayedComponentProxy:Dynamic = getComponentProxyFromUid((displayedComponents[i]).componentUid);
			if (displayedComponentProxy.getIsVisual() == true && displayedComponentProxy.getVisible() == true)
			{
				selectableComponents.push(displayedComponents[i]);
			}
		}
			
		return selectableComponents;
	}
	
	/**
	 * Get the visual and editable components from the currently displayed subLayers
	 * @return an array of components coords proxy
	 */
	private function doGetEditableComponents():Array<ComponentCoordsProxy>
	{
		var selectableComponents:Array<ComponentCoordsProxy> = getSelectableComponents();
		var editableComponents:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		var selectableComponentsLength:Int = selectableComponents.length;
		for (i in 0...selectableComponentsLength)
		{
			var selectableComponentProxy:Dynamic = getComponentProxyFromUid(selectableComponents[i].componentUid);
			if (selectableComponentProxy.getEditable() == true)
			{
				editableComponents.push(getComponentCoordsProxyFromComponentProxy(selectableComponentProxy));
			}
		}
		return editableComponents;
		
	}
	
	/**
	 * Get the non-editable visual components from the currently displayed sublayers
	 * @return an array of components coords proxy
	 */
	private function doGetNonEditableComponents():Array<ComponentCoordsProxy>
	{
		var editableComponents:Array<ComponentCoordsProxy> = getEditableComponents();
		var selectableComponents:Array<ComponentCoordsProxy> = getSelectableComponents();
		
		var editableComponentsLength:Int = editableComponents.length;
		var selectableComponentsLength:Int = selectableComponents.length;
		
		var nonEditableComponents:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		//check in all selectable components for the components which are not in the 
		//editable components array, as those are by substraction the non-editable components
		for (i in 0...selectableComponentsLength)
		{
			var flagIsEditableComponent:Bool = false;
			for (j in 0...editableComponentsLength)
			{
				if (editableComponents[j].componentUid == selectableComponents[i].componentUid)
				{
					flagIsEditableComponent = true;
				}
			}
			if (flagIsEditableComponent == false)
			{
				nonEditableComponents.push(selectableComponents[i]);
			}
		}
		
		return nonEditableComponents;
	}
	
	/**
	 * Retrieve all the selected visual and editable components coords and uids and return them in an array
	 * @return the array of selected components
	 */
	private function doGetSelectedComponents():Array<ComponentCoordsProxy>
	{
		var selectedComponentUids:Array<String> = getSelectedComponentsUids();
		
		var editableComponents:Array<ComponentCoordsProxy> = getEditableComponents();
		
		var selectedComponents:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		var editableComponentsLength:Int = editableComponents.length;
		var selectedComponentUidsLength:Int = selectedComponentUids.length;
		for(i in 0...editableComponentsLength){
			
			for (j in 0...selectedComponentUidsLength)
			{
				if (editableComponents[i].componentUid == selectedComponentUids[j])
				{
					selectedComponents.push(editableComponents[i]);
				}
			}
		}	
		return selectedComponents;
	}
	
	/**
	 * Retrieve all of the currently displayed and visible subLayer uids
	 * @return an array of subLayer uids
	 */
	private function doGetLayersUids():Array<String>
	{
		var layouts:Array<Dynamic> = _silexAdminApi.layouts.getData()[0];
		var layoutsUid:Array<Dynamic> = new Array<Dynamic>();
		
		var layoutsLength:Int = layouts.length;
		for (i in 0...layoutsLength)
		{
			layoutsUid.push(layouts[i].uid);
		}
		
		var layers:Array<Dynamic> = _silexAdminApi.layers.getData(layoutsUid);
		var layersUid:Array<String> = new Array<String>();
		
		var layersLength:Int = layers.length;
		for (i in 0...layersLength)
		{
			var currentLayerLength:Int = layers[i].length;
			for (j in 0...currentLayerLength)
			{
				if (layers[i][j].getVisible() == true)
				{
					layersUid.push(layers[i][j].uid);
				}
			}
		}
		
		return layersUid;
	}
	
	
	/**
	 * Update the value of a component's property through SilexAdminApi
	 * @param	updatePropertyData contains all the data to update a property
	 */
	private function commitProperty(updatePropertyData:UpdatePropertyData):Void
	{
		var properties:Dynamic = _silexAdminApi.properties.getSortedData([updatePropertyData.componentUid], [updatePropertyData.propertyName], "name")[0];
		var propertyProxy:Dynamic = Reflect.field(properties, updatePropertyData.propertyName);
		if (propertyProxy.currentValue != updatePropertyData.value)
		{
			propertyProxy.updateCurrentValue(updatePropertyData.value, SelectionManager.SELECTION_MANAGER_ID);
			dispatchComponentEvent(updatePropertyData);
		}
		
	}
	
	////////////////////**/*/*/*/*/*/*/
	// SILEXADMINAPI CALLBACK METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When a paste process, pasting one or multiple component(s) starts,
	 * stop listening to other SilexAdminApi event to avoid overloading the processor,
	 * and start listening the the paste end event
	 */
	private function onComponentStartPaste():Void
	{
		removeListeners();
		
		_componentEndPasteDelegate = onComponentEndPaste;
		
		_silexAdminApi.components.addEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_END_PASTE, _componentEndPasteDelegate);
	}
	
	/**
	 * when the paste process is done, resume listening to SilexAdminApi events
	 */
	private function onComponentEndPaste():Void
	{
		
		_silexAdminApi.components.removeEventListener(
		Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_END_PASTE, _componentEndPasteDelegate);
		
		_componentEndPasteDelegate = null;
		
		//onComponentDataChanged();
		setListeners();
		
	}
	
	/**
	 * When the displayed layers changes, refresh the list
	 * of currently displayed layers uids
	 */
	private function onLayersDataChanged():Void
	{
		_layersUid = doGetLayersUids();
	}
	
	/**
	 * Signal when the components data changes on SilexAdminApi. Refresh
	 * the components buffers as needed
	 */
	private function onComponentDataChanged():Void
	{
		_components = null;
		
		_displayedComponents = doGetDisplayedComponents();
		_selectableComponents = doGetSelectableComponents();
		_editableComponents = doGetEditableComponents();
		_nonEditableComponents = doGetNonEditableComponents();
		_selectedComponents = doGetSelectedComponents();
		signalAdminApiEvent(silexAdminApiComponentDataChangeSignaler);
	}
	
	/**
	 * Signal when the components selection changes on SilexAdminApi.Refresh
	 * the components buffers as needed
	 */
	private function onComponentsSelectionChanged():Void
	{
		_selectedComponents = doGetSelectedComponents();
		signalAdminApiEvent(silexAdminApiComponentSelectionChangeSignaler);
	}
	
	/**
	 * Signal when the properties data changes on SilexAdminApi.Refresh
	 * the components buffers as needed
	 */
	private function onPropertiesDataChanged(event:Dynamic):Void
	{
		if (event.data != SelectionManager.SELECTION_MANAGER_ID)
		{
			_displayedComponents = doGetDisplayedComponents();
			_selectableComponents = doGetSelectableComponents();
			_editableComponents = doGetEditableComponents();
			_nonEditableComponents = doGetNonEditableComponents();
			_selectedComponents = doGetSelectedComponents();
			signalAdminApiEvent(silexAdminApiPropertiesDataChangeSignaler);
		}
	}
	
	/**
	 * dispatch SilexAdminApi changes event only in SelectionMode
	 * @param	signaler
	 */
	private function signalAdminApiEvent(signaler:Signaler<Void>):Void
	{
		if (_selectionMode == SelectionManager.SELECTION_MODE_SELECTION)
		{
			signaler.dispatch();
		}
	}
	
	////////////////////**/*/*/*/*/*/*/
	// UTILS METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Methods used for legacy reasons, makes the transformed components dispatch event if they are
	 * moved or resized, else some of the components interactions won't work.
	 */
	private function dispatchComponentEvent(updatePropertyData:UpdatePropertyData):Void
	{
		if (updatePropertyData.propertyName == "x" || updatePropertyData.propertyName == "y")
		{
			var component:Dynamic = getComponentProxyFromUid(updatePropertyData.componentUid).getComponent();
			component.dispatch( { type:"move", target:component } );
		}
		else if (updatePropertyData.propertyName == "width" || updatePropertyData.propertyName == "height")
		{
			var component:Dynamic = getComponentProxyFromUid(updatePropertyData.componentUid).getComponent();
			component.dispatch( { type:"resize", target:component } );
		}
	}
	
	/**
	 * Return a deep copy of an array of componentCoordsProxy
	 * @param	componentCoordsProxies the array to copy
	 * @return the copied array
	 */
	private function getCopy(componentCoordsProxies:Array<ComponentCoordsProxy>):Array<ComponentCoordsProxy>
	{
		var componentCoordsProxiesLength:Int = componentCoordsProxies.length;
		var componentCoordsProxiesCopy:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		for (i in 0...componentCoordsProxiesLength)
		{
			var componentUidCopy:String = componentCoordsProxies[i].componentUid;
			var componentCoordsXCopy:Int = componentCoordsProxies[i].componentCoords.x;
			var componentCoordsYCopy:Int = componentCoordsProxies[i].componentCoords.y;
			var componentCoordsWidthCopy:Int = componentCoordsProxies[i].componentCoords.width;
			var componentCoordsHeightCopy:Int = componentCoordsProxies[i].componentCoords.height;
			var componentCoordsRotationCopy:Float = componentCoordsProxies[i].componentCoords.rotation;
			
			var componentCoordsCopy:Coords = {
				x:componentCoordsXCopy,
				y:componentCoordsYCopy,
				width:componentCoordsWidthCopy,
				height:componentCoordsHeightCopy,
				rotation:componentCoordsRotationCopy
			};
			
			
			var componentCoordsProxyCopy:ComponentCoordsProxy = {
				componentUid:componentUidCopy,
				componentCoords:componentCoordsCopy
			};
			
			componentCoordsProxiesCopy.push(componentCoordsProxyCopy);
		}
		
		return componentCoordsProxiesCopy;
	}
	
	/**
	 * Utils method, returning if two sets of uids match
	 * @param	selectedUids the currently selected uids
	 * @param	uidsToSelect the uids to select
	 * @return false if there is no difference
	 */
	private function checkDifferentSelection(selectedUids:Array<String>, uidsToSelect:Array<String>):Bool
	{
		var flagDifferentSelection:Bool = false;
		
		//if the length is different, the selection is always different
		if (selectedUids.length != uidsToSelect.length)
		{
			flagDifferentSelection = true;
		}
		
		//else for each selected uid, check if we find one matching uid
		else
		{
			for (i in 0...selectedUids.length)
			{
				var foundMatchingUid:Bool = false;
				for (j in 0...uidsToSelect.length)
				{
					if (selectedUids[i] == uidsToSelect[j])
					{
						foundMatchingUid = true;
					}
				}
				//if no match is found for this uid, then the selection is different
				if (foundMatchingUid == false)
				{
					flagDifferentSelection = true;
				}
			}
		}
	
		return flagDifferentSelection;
	}
}