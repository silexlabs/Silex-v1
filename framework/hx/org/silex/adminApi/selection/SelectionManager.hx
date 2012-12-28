/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection;

import flash.Lib;
import haxe.Log;
import org.silex.adminApi.selection.com.HookManagerCommunication;
import org.silex.adminApi.selection.com.SilexAdminApiCommunication;
import org.silex.adminApi.selection.com.SilexApiCommunication;
import org.silex.adminApi.selection.components.ComponentsManager;
import org.silex.adminApi.selection.components.ComponentsSelectionHelper;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.ui.UIManager;
import org.silex.adminApi.selection.transformHandlers.TransformHandlerBase;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.KeyboardTranslationTranformHandler;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.SelectionRegionDrawingTransformHandler;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.TranslationTranformHandler;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.PivotTranslationTransformHandler;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.RotationTransformHandler;
import org.silex.adminApi.selection.transformHandlers.transformHandlerClasses.ScalingTransformHandler;
import org.silex.adminApi.selection.ui.uis.uiComponents.PivotPoint;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;
import org.silex.adminApi.selection.ui.uis.uiComponents.MouseCursors;

/**
 * Manages the selection of the components on the silex scene. Split into a component manager listening the components event
 * , a UIManager acting as the view of the selection and communication class abstracting access to SilexAdminApi and SilexApi
 * @author Yannick DOMINGUEZ
 */

class SelectionManager 
{
	/////////////////////////////////////
	// CONSTANTS
	////////////////////////////////////
	
	/////////////////////////////////////////
		// PRIVATES
	////////////////////////////////////////
	
	/**
	 * the target name of the selection manager
	 */
	private static var TARGET:String = "selectionManager";
	
	
	/////////////////////////////////////////
		// PUBLIC
	////////////////////////////////////////	
	
	/**
	 * The selection mode used to draw component onto the silex scene
	 */
	public inline static var SELECTION_MODE_DRAWING:String = "selectionModeDrawing";
	
	/**
	 * The selection mode used to select components on the silex scene
	 */
	public inline static var SELECTION_MODE_SELECTION:String = "selectionModeSelection";
	
	/**
	 * The selection mode used to browse a publication
	 */
	public inline static var SELECTION_MODE_NAVIGATION:String = "selectionModeNavigation";
	
	/**
	 * The constant of a global event dispatched when the selection mode changes
	 */
	public inline static var SELECTION_MODE_CHANGED:String = "selectionModeChanged";
	
	/**
	 * This is the identifier of the selection tool, sent when the selection interacts with 
	 * the SilexAdminApi to update a property value for instance
	 */
	public inline static var SELECTION_MANAGER_ID:String = "selectionManagerId";
	
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * a reference to the component manager, in charge of listening to components and background event
	 */
	private var _componentsManager:ComponentsManager;
	
	/**
	 * a reference to the UIManager, the view of the selection displaying the currently selected component on the scene
	 * and presenting a UI for the user to update the selected components position/width/height/scale
	 */
	private var _uiManager:UIManager;
	
	/**
	 * a reference to a transformer object, used to transform the selected component(s). There is one for each transformation
	 * (translation, scale, rotation...)
	 */
	private var _tranformer:TransformHandlerBase;
	
	/**
	 * Stores the name of the current selection mode
	 */
	private var _currentSelectionMode:String;
	
	/**
	 * When a transformation starts, stores all of the selectable components coords to be used
	 * during the transformation (for instance to snap the translated components to another component)
	 */
	private var _selectableComponentsAtTransformationStart:Array<ComponentCoordsProxy>;


	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Listens for signal dispatched when SilexAdminApi the UIManager are ready. When both are ready,
	 * , init the SelectionManager
	 */
	public function new() 
	{
		HookManagerCommunication.getInstance().silexAdminApiReadyHookSignaler.bindVoid(onAdminApiReady);
		HookManagerCommunication.getInstance().uiManagerReadyHookSignaler.bind(onUIManagerReady);
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * Selects all the selectable components contained within the regionCoords
	 * @param	regionCoords the coord of the selection region drawn
	 * @param	useShift wheter Shift was pressed during the selection
	 */
	public function selectRegion(regionCoords:Dynamic, useShift:Bool = false):Void
	{
		//we type the data retrieved from the adminApi, as they all come as Strings
		var typedCoords:Coords = { x:Std.parseInt(regionCoords.x),
		y:Std.parseInt(regionCoords.y),
		width:Std.parseInt(regionCoords.width),
		height:Std.parseInt(regionCoords.height),
		rotation:0.0 };
		
		//retrieve the components within the drawn region
		var selectedComponentsWithinRegion:Array<ComponentCoordsProxy> = ComponentsSelectionHelper.getComponentsFromSelection(typedCoords, getEditableComponents());

		//if no components are within the drawn region
		//we select the first layer and set the uiManager state
		//to "unselected"
		if (selectedComponentsWithinRegion.length == 0)
		{
			resetLayerSelection();
			_uiManager.setState({stateName:Unselected, stateInitData:null});
		}
		
		//else we select the components within the selection drawing
		else
		{
			//if shift was pressed while selecting, we invert the current selection
			if (useShift == true)
			{
				var selectedComponents:Array<ComponentCoordsProxy> = getSelectedComponents();
				var componentsToSelect:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
				
				//for all the components in the drawn region
				//if the component was selected we unselect it
				//else we add it to the selection
				var selectedComponentsWithinRegionLength:Int = selectedComponentsWithinRegion.length;
				var selectedComponentsLength:Int = selectedComponents.length;
				for (i in 0...selectedComponentsWithinRegionLength)
				{
					var flagComponentSelected:Bool = false;
					for (j in 0...selectedComponentsLength)
					{
						if (selectedComponentsWithinRegion[i].componentUid == selectedComponents[j].componentUid)
						{
							flagComponentSelected = true;
							selectedComponents.splice(j, 1);
							break;
						}
					}
					
					if (flagComponentSelected == false)
					{
						selectedComponents.push(selectedComponentsWithinRegion[i]);
					}
				}
				
				selectComponents(selectedComponents);
			}
			
			//if Shift wasn't pressed we override the current selection
			//with the components in the selected region
			else
			{
				selectComponents(selectedComponentsWithinRegion);
			}
		}
	}
	
	/**
	 * Determine the right pivot point to set by determining the right
	 * PivotPointPositions object from the sent string
	 * @param	pivotPointPosition the name of the position to set the pivot point to
	 */
	public function setUntypedPivotPoint(pivotPointPosition:String):Void
	{
		switch (pivotPointPosition)
		{
			case PivotPoint.PIVOT_POINT_POSITION_TOP_LEFT:
			setPivotPoint(TopLeft);
			
			case PivotPoint.PIVOT_POINT_POSITION_TOP:
			setPivotPoint(Top);
			
			case PivotPoint.PIVOT_POINT_POSITION_TOP_RIGHT:
			setPivotPoint(TopRight);
			
			case PivotPoint.PIVOT_POINT_POSITION_RIGHT:
			setPivotPoint(Right);
			
			case PivotPoint.PIVOT_POINT_POSITION_BOTTOM_RIGHT:
			setPivotPoint(BottomRight);
			
			case PivotPoint.PIVOT_POINT_POSITION_BOTTOM:
			setPivotPoint(Bottom);
			
			case PivotPoint.PIVOT_POINT_POSITION_BOTTOM_LEFT:
			setPivotPoint(BottomLeft);
			
			case PivotPoint.PIVOT_POINT_POSITION_LEFT:
			setPivotPoint(Left);
			
			case PivotPoint.PIVOT_POINT_POSITION_CENTER:
			setPivotPoint(Center);
		}
	}
	
	/**
	 * Set the selection mode of the selection manager if it is different from
	 * the current selection mode and set it on the components manager
	 * and SilexAdminApi communication class. Make all the selectable components editable
	 * or not based on the selection mode
	 * @param	selectionMode the name of the new selection mode
	 * @param resetComponentsEdition choose wether all components must be locked/unlocked due to a
	 * state change. It is useful to prevent unlocking all components when the user unlock then select
	 * a component in Navigation mode. The selection mode switch to Selection but all locked components
	 * remain locked.
	 */
	public function setSelectionMode(selectionMode:String, resetComponentsEdition:Bool = true):Void
	{
		//do nothing if it is the current mode
		if (_currentSelectionMode == selectionMode)
		{
			return;
		}
		
		SilexAdminApiCommunication.getInstance().setSelectionMode(selectionMode);
		_componentsManager.setSelectionMode(selectionMode);
		_currentSelectionMode = selectionMode;
		
		//in drawing and navigation mode, we set the uiManager to Unselect state
		//as we don't want any components to look selected in those modes
		switch (selectionMode)
		{
			case SELECTION_MODE_DRAWING:
			setEditableComponents();
			_uiManager.setState({stateName:Unselected, stateInitData:null});
			
			case SELECTION_MODE_NAVIGATION:
			resetLayerSelection();
			if (resetComponentsEdition == true)
			{
				setComponentsEdition(false);
			}
			unsetEditableComponents();
			_uiManager.setState( { stateName:Unselected, stateInitData:null } );
			
			//when entering selection mode, set the selectable components
			//and the uiManager
		case SELECTION_MODE_SELECTION:
			if (resetComponentsEdition == true)
			{
				setComponentsEdition(true);
			}
			onComponentDataChanged();
		}
		
		
		SilexAdminApiCommunication.getInstance().dispatchEvent(SELECTION_MODE_CHANGED, TARGET);
	}
	
	/**
	 * Highlight components with the same effect as when rolled over
	 * @param	componentUids the uids of the components to highlight
	 */
	public function highlightComponents(componentUids:Array<String>):Void
	{
		
		if (componentUids != null && componentUids.length > 0)
		{
			var componentsCoordsProxys:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
			var componentUidsLength:Int = componentUids.length;
			for (i in 0...componentUidsLength)
			{
				//retrieve the component proxy with it's uid
				var componentProxy:Dynamic = SilexAdminApiCommunication.getInstance().getComponentProxyFromUid(componentUids[i]);
				componentsCoordsProxys.push(SilexAdminApiCommunication.getInstance().getComponentCoordsProxyFromComponentProxy(componentProxy));
			}
			
		
			setHighlightedComponents(componentsCoordsProxys);
			
		}
		
		//if no uid has been sent, hide the highlighted components asset
		else 
		{
			_uiManager.unsetHighlightedComponents();
		}
		
		//reset the mouse cursor display
		_uiManager.setMouseCursor(MouseCursors.MOUSE_CURSOR_DEFAULT);
	}

	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	
	/////////////////////////////////////////
		// INIT METHODS
	////////////////////////////////////////
	
	/**
	 * When the SilexAdminApi is ready, check if the uiManager is ready. 
	 * Init the SelectionManager if it is
	 */
	private function onAdminApiReady():Void
	{
		if (_uiManager != null)
		{
			init();
		}
	}
	
	/**
	 * Initialise the UiManager when it is ready and check if SilexAdminApi is ready. 
	 * Init the SelectionManager if it is
	 * 
	 * @param uis contains the ui components used to init the UIManager
	 */
	private function onUIManagerReady(uis:UIsExtern):Void
	{
		_uiManager = new UIManager(uis);
		
		if (SilexAdminApiCommunication.getInstance().getSilexAdminApi() != null)
		{
			init();
		}
	}
	
	/**
	 * Called when both SilexAdminApi and UIManager are ready, as we can't know for sure which one will be ready first.
	 * Add all the listeners on the SilexAdminApi, UIManager and ComponentManager
	 */
	private function init():Void
	{
		
		//init the component manager 
		_componentsManager = new ComponentsManager();
		
		setListeners();
	
		
		//initialise the selection manager in navigation mode by default
		setSelectionMode(SELECTION_MODE_NAVIGATION);
		
		
	}
	
	/**
	 * Set all of the Signal listeners
	 */
	private function setListeners():Void
	{
		//set listener on the SilexAdminApi via proxy
		setSilexAdminApiListeners();
	
		//set listener on the component manager
		_componentsManager.backgroundMouseDownSignaler.bindVoid(onBackgroundMouseDown);
		_componentsManager.componentPlaceHolderMouseDownSignaler.bind(onComponentMouseDown);
		_componentsManager.componentPlaceHolderRollOverSignaler.bind(onComponentRollOver);
		_componentsManager.componentPlaceHolderRollOutSignaler.bindVoid(onComponentRollOut);
	
		//Set listener on the Silex API
		SilexApiCommunication.getInstance().silexApiResizeSignaler.bindVoid(onStageResize);
		SilexApiCommunication.getInstance().silexApiLogOutSignaler.bindVoid(onLogOut);
		
		//set listeners on the UIManager
		_uiManager.selectionEventSignaler.bind(onSelectionEvent);
	}
	
	/**
	 * set listener on the SilexAdminApi via proxy
	 */
	private function setSilexAdminApiListeners():Void
	{
		SilexAdminApiCommunication.getInstance().silexAdminApiComponentDataChangeSignaler.bindVoid(onComponentDataChanged);
		SilexAdminApiCommunication.getInstance().silexAdminApiComponentSelectionChangeSignaler.bindVoid(onComponentsSelectionChanged);
		SilexAdminApiCommunication.getInstance().silexAdminApiPropertiesDataChangeSignaler.bindVoid(onPropertiesDataChanged);
	}
	
	/**
	 * Remove all the signal listener
	 */
	private function removeListeners():Void
	{
		removeSilexAdminApiListeners();
		
		_componentsManager.backgroundMouseDownSignaler.unbindVoid(onBackgroundMouseDown);
		_componentsManager.componentPlaceHolderMouseDownSignaler.unbind(onComponentMouseDown);
		_componentsManager.componentPlaceHolderRollOverSignaler.unbind(onComponentRollOver);
		_componentsManager.componentPlaceHolderRollOutSignaler.unbindVoid(onComponentRollOut);
	
		SilexApiCommunication.getInstance().silexApiResizeSignaler.unbindVoid(onStageResize);
		SilexApiCommunication.getInstance().silexApiLogOutSignaler.unbindVoid(onLogOut);
		
		_uiManager.selectionEventSignaler.unbind(onSelectionEvent);
	}
	
	/**
	 * Remove the SilexAdminApi listeners
	 */
	private function removeSilexAdminApiListeners():Void
	{
		SilexAdminApiCommunication.getInstance().silexAdminApiComponentDataChangeSignaler.unbindVoid(onComponentDataChanged);
		SilexAdminApiCommunication.getInstance().silexAdminApiComponentSelectionChangeSignaler.unbindVoid(onComponentsSelectionChanged);
		SilexAdminApiCommunication.getInstance().silexAdminApiPropertiesDataChangeSignaler.unbindVoid(onPropertiesDataChanged);
	}
	
	/////////////////////////////////////////
		// SILEX API CALLBACKS
	////////////////////////////////////////
	
	/**
	 * When the stage or browser is resized, update the uiManager display
	 * and the editable components place holders
	 */
	private function onStageResize():Void
	{
		//don't update editable/non-editable components in navigation mode
		//as there shouldn't be any components place holders
		if (_currentSelectionMode != SELECTION_MODE_NAVIGATION)
		{
			setUiManagerSelection();
			setEditableComponents();
		}
	}
	
	/**
	 * When the user logs out, remove all the listeners and enter
	 * the disabled state. Listens for when the user will log back in
	 */
	private function onLogOut():Void
	{
		removeListeners();
		SilexApiCommunication.getInstance().silexApiLogInSignaler.bindVoid(onLogIn);
		_uiManager.setState( { stateName:Disabled, stateInitData:null } );
	}
	
	/**
	 * When the user logs back in, reset listeners and enter unselected state
	 */
	private function onLogIn():Void
	{
		setListeners();
		SilexApiCommunication.getInstance().silexApiLogInSignaler.unbindVoid(onLogIn);
		_uiManager.setState( { stateName:Unselected, stateInitData:null } );
	}
	
	
	/////////////////////////////////////////
		// SILEX ADMIN API CALLBACKS
	////////////////////////////////////////
	
	/**
	 * Update the uiManager display when component seelction changes
	 */
	private function onComponentsSelectionChanged():Void
	{
		setUiManagerSelection();
	}
	
	/**
	 * When the data of the components change, set listeners on the new components place holder
	 * with the component manager, and update the uiManager display
	 */
	private function onComponentDataChanged():Void
	{
		setUiManagerSelection();
		setEditableComponents();
	}
	
	/**
	 * When properties change, update the uiManager display and the 
	 * editable components place holders
	 */
	private function onPropertiesDataChanged():Void
	{
		setUiManagerSelection();
		setEditableComponents();
	}
	
	/**
	 * When updating the uiManager selection, if components are selected and the current state isn't navigation, process
	 * the selection region  and update the uiManager selection region and pivot point, else set the uiManager to the unselected
	 * state, hiding the selection region. It then reset the pivot point position to the center of the selection region
	 */ 
	private function setUiManagerSelection():Void
	{
		var selectedComponents:Array<ComponentCoordsProxy> = getSelectedComponents();
		
		if (selectedComponents.length > 0 && _currentSelectionMode != SELECTION_MODE_NAVIGATION)
		{
			_uiManager.setState({stateName:Selected, stateInitData:null});
			_uiManager.setSelectionRegion(ComponentsSelectionHelper.unscaleCoords(getSelectionRegion()));
			var selectedComponentsLength:Int = selectedComponents.length;
			for (i in 0...selectedComponentsLength)
			{
				selectedComponents[i].componentCoords = ComponentsSelectionHelper.unscaleCoords(selectedComponents[i].componentCoords);
			}
			_uiManager.setSelectedComponents(selectedComponents);
		}
		
		else
		{
			_uiManager.setState( { stateName:Unselected, stateInitData:null } );
		}
		
		setPivotPoint(Center);
	}
	
	/////////////////////////////////////////
		// SILEX ADMIN API COMMUNICATION METHODS
	////////////////////////////////////////
	
	/**
	 * Retrieve all the selected visual components and store them in an array
	 * @return the array of selected components
	 */
	private function getSelectedComponents():Array<ComponentCoordsProxy>
	{
		return SilexAdminApiCommunication.getInstance().getSelectedComponents();
	}
	
	/**
	 * Select on array of component on the SilexAdminApi
	 * @param	componentsToSelect the cmponent to select
	 */
	private function selectComponents(componentsToSelect:Array<ComponentCoordsProxy>):Void
	{
		SilexAdminApiCommunication.getInstance().selectComponents(componentsToSelect);
	}
	
	/**
	 * returns the selection region based on the selected components
	 * @return the coords of the selected region
	 */
	private function getSelectionRegion():Coords
	{
		return ComponentsSelectionHelper.getSelectionFromComponent(getSelectedComponents());
	}
	
	/**
	 * reset the layer selection
	 */
	private function resetLayerSelection():Void
	{
		SilexAdminApiCommunication.getInstance().resetLayerSelection();
	}
	
	/**
	 * Get all the components (visual/non-visual, editable/non-editable) from the
	 * currently displayed subLayers
	 * @return
	 */
	private function getDisplayedComponents():Array<ComponentCoordsProxy>
	{
		return SilexAdminApiCommunication.getInstance().getDisplayedComponents();
	}
	
	/**
	 * Get the selectable components from the currently displayed layers
	 * @return an array of components coords proxy
	 */
	private function getSelectableComponents():Array<ComponentCoordsProxy>
	{
		return SilexAdminApiCommunication.getInstance().getSelectableComponents();
	}
	
	/**
	 * Get the editable components from the currently displayed layers
	 * @return an array of components coords proxy
	 */
	private function getEditableComponents():Array<ComponentCoordsProxy>
	{
		return SilexAdminApiCommunication.getInstance().getEditableComponents();
	}
	
	/**
	 * Get the non editable components from the currently displayed layers
	 * @return an array of components coords proxy
	 */
	private function getNonEditableComponents():Array<ComponentCoordsProxy>
	{
		return SilexAdminApiCommunication.getInstance().getNonEditableComponents();
	}
	
	/**
	 * For all the transformed components, update the value of their coordinates properties
	 * through SilexAdminApi
	 * 
	 * @param tranformedComponents the array of transformed components
	 */ 
	private function commitProperties(tranformedComponents:Array<ComponentCoordsProxy>):Void
	{
		SilexAdminApiCommunication.getInstance().commitProperties(tranformedComponents);
	}
	
	/////////////////////////////////////////
		// UIMANAGER CALLBACKS
	////////////////////////////////////////
	
	/**
	 * When a selection event signal is catched, start/progress/stop a transformation
	 * based on the type of the received signal
	 * @param	eventData contains all the transformation event data and it's type
	 */
	private function onSelectionEvent(eventData:SelectionManagerEventData):Void
	{
		switch (eventData.eventType)
		{
			case SelectionManagerEvent.SELECTION_START_SCALING:
			onSelectionStartScaling(eventData);
			
			case SelectionManagerEvent.SELECTION_START_KEYBOARD_TRANSLATION:
			onSelectionStartKeyboardTranslating(eventData);
			
			case SelectionManagerEvent.SELECTION_START_TRANSLATION:
			onSelectionStartTranslating(eventData);
			
			case SelectionManagerEvent.SELECTION_START_ROTATING:
			onSelectionStartRotating(eventData);
			
			case SelectionManagerEvent.SELECTION_REGION_START_DRAWING:
			onSelectionStartDrawing(eventData);
			
			case SelectionManagerEvent.SELECTION_REGION_DRAWING:
			onSelectionDrawing(eventData);
			
			case SelectionManagerEvent.SELECTION_REGION_STOP_DRAWING:
			onSelectionStopDrawing(eventData);
			
			case SelectionManagerEvent.SELECTION_START_PIVOT_TRANSLATION:
			onSelectionStartPivotTranslating(eventData);
			
			case SelectionManagerEvent.SELECTION_STOP_TRANSLATING :
			onSelectionStopTranslating(eventData);
			
			case 
			SelectionManagerEvent.SELECTION_ROTATING, 
			 SelectionManagerEvent.SELECTION_SCALING,
			 SelectionManagerEvent.SELECTION_TRANSLATING,
			 SelectionManagerEvent.SELECTION_KEYBOARD_TRANSLATING,
			 SelectionManagerEvent.SELECTION_TRANSLATING_PIVOT:
			onSelectionTransforming(eventData);
			
			case SelectionManagerEvent.SELECTION_STOP_KEYBOARD_TRANSLATING,
			 SelectionManagerEvent.SELECTION_STOP_ROTATING,
			 SelectionManagerEvent.SELECTION_STOP_SCALING,
			 SelectionManagerEvent.SELECTION_STOP_TRANSLATING_PIVOT:
			onSelectionStopTransforming(eventData);
		}
	}
	
	/**
	 * When a transformation starts, stores all of the editable components coords,
	 * to be used during the transformation. Stop listening for the SilexAdminApi while transforming
	 * as it may interfere with the transformation by switching to unwanted states
	 */
	private function onTransformationStart():Void
	{
		removeSilexAdminApiListeners();
		_selectableComponentsAtTransformationStart = getEditableComponents();
	}
	
	/**
	 * When the transformation stops, resume the listening of the SilexAdminApi
	 */
	private function onTransformationStop():Void
	{
		setSilexAdminApiListeners();
	}
	
	/**
	 * Instantiate the translation transformer when the translation start, passing it
	 * the event data and the selected components
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartTranslating(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		_tranformer = new TranslationTransformHandler(selectionManagerEventData, getSelectedComponents());
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * Instantiate the keyboard translation transformer, and start the transformation
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartKeyboardTranslating(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		_tranformer = new KeyboardTranslationTranformHandler(selectionManagerEventData, getSelectedComponents());
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * Instantiate the rotation transformer when the rotation start, passing it
	 * the event data and the selected components
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartRotating(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		_tranformer = new RotationTransformHandler(selectionManagerEventData, getSelectedComponents());
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * Instantiate the scale transformer when the scaling starts, passing it
	 * the event data and the selected components
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartScaling(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);

		//retrieve additional scale data
		var opositeHandlePosition:Point = { x:Std.parseInt(selectionManagerEventData.parameters.opositeHandlePosition.x), y:Std.parseInt(selectionManagerEventData.parameters.opositeHandlePosition.y) };
		var scaleHandlePosition:Point = {x:Std.parseInt(selectionManagerEventData.parameters.scaleHandlePosition.x), y:Std.parseInt(selectionManagerEventData.parameters.scaleHandlePosition.y)}
		selectionManagerEventData.parameters.opositeHandlePosition = ComponentsSelectionHelper.scalePoint(opositeHandlePosition);
		selectionManagerEventData.parameters.scaleHandlePosition = ComponentsSelectionHelper.scalePoint(scaleHandlePosition);

		_tranformer = new ScalingTransformHandler(selectionManagerEventData, getSelectedComponents());
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * Instatiate the pivot transformer when the pivot translation starts, passing it the event data and the
	 * selected components
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartPivotTranslating(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		_tranformer = new PivotTranslationTransformHandler(selectionManagerEventData, getSelectedComponents());
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * When a transform is in progress, process it with the instantiated transformer
	 * then refresh the display of the UIManager
	 * @param	selectionManagerEventData the progress event dispatched by the UiManager
	 */
	private function onSelectionTransforming(selectionManagerEventData:SelectionManagerEventData):Void
	{
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		updateDisplay(selectionManagerEventData);
	}
	
	/**
	 * When a transform is complete, process it with the instanciated tranformer then save the new value
	 * of the transformed components coords through the SilexAdminAPI. The uiManager then enter the selected states
	 * to exit the current transformation state
	 * @param	selectionManagerEventData the stop transform event dispached by the UiManager
	 */
	private function onSelectionStopTransforming(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStop();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		var transformedComponents:Array<ComponentCoordsProxy> = transformResult.transformedComponentsData;
		this.commitProperties(transformedComponents);
		_uiManager.setState( { stateName:Selected, stateInitData:null } );
		
		//adds specific behaviour after a transformation,
		//based on the type of transformation
		switch (transformResult.transformType)
		{
			//for all transformations
			//but pivot translations, we 
			//reset the pivot point position to the center
			case RotationTransformType,
			KeyboardTranslationTransformType,
			TranslationTransformType,
			ScalingTransformType,
			DrawingTransformType:
			updateDisplayEnd(selectionManagerEventData);
			setUiManagerSelection();
			
			case PivotPointTranslationTransformType:
		}
		
	}
	
	/**
	 * Special case for the translation stop event, if Alt is pressed, the selected components
	 * are duplicated at their start position
	 * @param	selectionManagerEventData
	 */
	private function onSelectionStopTranslating(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStop();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		//setPivotPoint(Center);

		
		//if Alt is pressed, copy/paste the component selection
		if (selectionManagerEventData.keyboardState.useAlt == true)
		{
			SilexAdminApiCommunication.getInstance().copySelectedComponents();
			SilexAdminApiCommunication.getInstance().pasteSelectedComponents();
		}
		
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		var transformedComponents:Array<ComponentCoordsProxy> = transformResult.transformedComponentsData;
		this.commitProperties(transformedComponents);
		
		updateDisplayEnd(selectionManagerEventData);
		
		setUiManagerSelection();
		
		_uiManager.setState( { stateName:Selected, stateInitData:null } );
	}
	
	/**
	 * dispatch events when tht user draws a selection region at start, stop and during progress
	 * @param	selectionManagerEventData the data of the drawing event
	 * @param	transformResult the result of the transformed drawing region
	 */
	private function sendSelectionDrawingEvent(selectionManagerEventData:SelectionManagerEventData, transformResult:TransformResult):Void
	{
		//send wether shift was pressed with the event data
		var useShift:Bool = selectionManagerEventData.keyboardState.useShift;
		
		var dataToSend:Dynamic = { coords:transformResult.selectionRegionCoords, useShift:useShift };
		
		SilexAdminApiCommunication.getInstance().dispatchEvent(selectionManagerEventData.eventType, TARGET, dataToSend);
	}
	
	/**
	 * When the user starts drawing a region, instantiate the drawing transformer,
	 * passing it all the required event data, then send a cross platform event and update
	 * the UIManager display
	 * @param	selectionManagerEventData the event dispatched by the uiManager
	 */
	private function onSelectionStartDrawing(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStart();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		_tranformer = new SelectionRegionDrawingTransformHandler(selectionManagerEventData, getSelectedComponents());
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		
		sendSelectionDrawingEvent(selectionManagerEventData, transformResult);
		
		_uiManager.setSelectionDrawing(ComponentsSelectionHelper.unscaleCoords(transformResult.selectionRegionCoords));
		
	}
	
	/**
	 * When the user draws the selection region, send an event containing the data. This way the event
	 * can be catched by a plugin selecting a region, drawing a component... then update the UIManager display
	 * @param	selectionManagerEventData the drawing event dispatched by the uiManager
	 */
	private function onSelectionDrawing(selectionManagerEventData:SelectionManagerEventData):Void
	{
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		
		sendSelectionDrawingEvent(selectionManagerEventData, transformResult);
		
		//if the current mode is selection, while drawing,
		//update the selected components asset of the components that will be selected
		//if the drawing is stopped
		if (_currentSelectionMode == SELECTION_MODE_SELECTION)
		{
			var componentsWithinSelectionDrawing:Array<ComponentCoordsProxy>  = ComponentsSelectionHelper.getComponentsFromSelection(transformResult.selectionRegionCoords, _selectableComponentsAtTransformationStart);
			var componentsWithinSelectionDrawingLength:Int = componentsWithinSelectionDrawing.length;
			for (i in 0...componentsWithinSelectionDrawingLength)
			{
				ComponentsSelectionHelper.unscaleCoords(componentsWithinSelectionDrawing[i].componentCoords);
			}
			_uiManager.setSelectedComponents(componentsWithinSelectionDrawing);
		}
		
		_uiManager.setSelectionDrawing(ComponentsSelectionHelper.unscaleCoords(transformResult.selectionRegionCoords));
		
	}
	
	/**
	 * When the user stops drawing the selection region, send an event containing the data. This way the event
	 * can be catched by a plugin selecting a region, drawing a component... then update the UIManager display
	 * @param	selectionManagerEventData the drawing event dispatched by the uiManager
	 */
	private function onSelectionStopDrawing(selectionManagerEventData:SelectionManagerEventData):Void
	{
		onTransformationStop();
		selectionManagerEventData =  ComponentsSelectionHelper.scaleSelectionManagerEventData(selectionManagerEventData);
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		
		sendSelectionDrawingEvent(selectionManagerEventData, transformResult);
		
		_uiManager.setSelectionDrawing(ComponentsSelectionHelper.unscaleCoords(transformResult.selectionRegionCoords));
		_uiManager.setState( { stateName:Unselected, stateInitData:null } );
	}

	/**
	 * Apply the current transform, then set the display of the selection region
	 * and pivot point on the UIManager and unscale all of the transformed
	 * components coords
	 * @param	selectionManagerEventData the transformation event data
	 * @return the unscaled transformation results
	 */
	private function initDisplay(selectionManagerEventData:SelectionManagerEventData):TransformResult
	{
		var transformResult:TransformResult = _tranformer.transform(selectionManagerEventData);
		var transformedComponentsDataLength:Int = transformResult.transformedComponentsData.length;
		for (i in 0...transformedComponentsDataLength)
		{
			transformResult.transformedComponentsData[i].componentCoords = ComponentsSelectionHelper.unscaleCoords(transformResult.transformedComponentsData[i].componentCoords);
		}
		return transformResult;
	}
	
	/**
	 * Update the display of the selected component's asset on the UIManager
	 * @param	selectionManagerEventData the transforamtion event data
	 */
	private function updateDisplay(selectionManagerEventData:SelectionManagerEventData):Void
	{
		var transformResult:TransformResult = initDisplay(selectionManagerEventData);
		_uiManager.setSelectionRegion(ComponentsSelectionHelper.unscaleCoords(transformResult.selectionRegionCoords));
		_uiManager.setPivotPoint(ComponentsSelectionHelper.unscalePoint(transformResult.pivotPoint));
		_uiManager.updateSelectedComponents(transformResult.transformedComponentsData);
	}
	
	/**
	 * Same as update display but also update the display of the editable and non-editable components
	 * when a transformationStops
	 * @param	selectionManagerEventData
	 */
	private function updateDisplayEnd(selectionManagerEventData:SelectionManagerEventData):Void
	{
		var transformResult:TransformResult = initDisplay(selectionManagerEventData);
		_uiManager.setSelectionRegion(ComponentsSelectionHelper.unscaleCoords(transformResult.selectionRegionCoords));
		_uiManager.setPivotPoint(ComponentsSelectionHelper.unscalePoint(transformResult.pivotPoint));
		_uiManager.updateSelectedComponents(transformResult.transformedComponentsData);
		_uiManager.updateEditableComponents(transformResult.transformedComponentsData);
		_uiManager.updateNonEditableComponents(transformResult.transformedComponentsData);
	}
	
	/**
	 * Set the pivot point on the UIManager
	 * @param	pivotPointPlace the place to move the pivot point to
	 */
	private function setPivotPoint(pivotPointPlace:PivotPointPositions):Void
	{
		_uiManager.setPivotPoint(ComponentsSelectionHelper.unscalePoint(PivotPoint.getPivotPoint(pivotPointPlace, getSelectionRegion())));
	}
	
	/////////////////////////////////////////
		// COMPONENT MANAGER CALLBACKS
	////////////////////////////////////////
	
	/**
	 * When a component is pressed select or unselect it and start a translation
	 * @param	componentCoordsProxy the coords of the clicked components
	 */
	private function onComponentMouseDown(componentCoordsProxy:ComponentCoordsProxy):Void
	{
		//wether shift was pressed while the component was clicked
		var useShift:Bool = _uiManager.getKeyboardState().useShift;
		
		//get the currently selected components uid
		var selectedComponentsUids:Array<String> = SilexAdminApiCommunication.getInstance().getSelectedComponentsUids();
		
		//check if the clicked component is already selected
		var flagComponentAlreadySelected:Bool = false;
		var selectedComponentsUidsLength:Int = selectedComponentsUids.length;
		for (i in 0...selectedComponentsUidsLength)
		{
			if (componentCoordsProxy.componentUid == selectedComponentsUids[i])
			{
				flagComponentAlreadySelected = true;
			}
		}
		
		//if it isn't
		if (flagComponentAlreadySelected == false)
		{
			var componentsToSelect:Array<ComponentCoordsProxy>;
			
			//if Shift was pressed, we add it to the current selection
			if (useShift == true)
			{
				componentsToSelect = getSelectedComponents();
			}
			//else we override the current selection and only select the
			//clicked component
			else
			{
				componentsToSelect = new Array<ComponentCoordsProxy>();
			}
			
			componentsToSelect.push(componentCoordsProxy);
			selectComponents(componentsToSelect);		
			
			//we then start a translation by setting the translation state on the UIManager
			_uiManager.setState({stateName:Translating, stateInitData:null});
		}
		
		//if the component is already selected
		else
		{
			//if Shift was pressed, we unselect the clicked component
			//by removing it's uid from the selected components uids
			if (useShift == true)
			{
				var selectedComponents:Array<ComponentCoordsProxy> = getSelectedComponents();
				var selectedComponentsLength:Int = selectedComponents.length;
				for (i in 0...selectedComponentsLength)
				{
					if (selectedComponents[i].componentUid == componentCoordsProxy.componentUid)
					{
						selectedComponents.splice(i, 1);
						break;
					}
				}
				
				selectComponents(selectedComponents);
			}
			
			//else if the component is selected but Shift isn't pressed, we start a translation
			else
			{
				_uiManager.setState({stateName:Translating, stateInitData:null});
			}
		}
		

		
	}
	
	/**
	 * When a component is rolled hover, calls a method on the uiManager displaying
	 * the highlight asset around the component. If the hovered component is selected, display
	 * a custom mouse cursor
	 * @param	componentCoordsProxy contains the highlighted component coords
	 */
	private function onComponentRollOver(componentCoordsProxy:ComponentCoordsProxy):Void
	{
		//check if the current hovered component is selected,
		//which may affect it's mouse cursor display
		var selectedComponentsUids:Array<String> = SilexAdminApiCommunication.getInstance().getSelectedComponentsUids();
		var isHoveredComponentSelected:Bool = false;
		var selectedComponentsUidsLength:Int = selectedComponentsUids.length;
		for (i in 0...selectedComponentsUidsLength)
		{
			if (componentCoordsProxy.componentUid == selectedComponentsUids[i])
			{
				isHoveredComponentSelected = true;
			}
		}
		
		//if the roll over component is selected, display a special mouse cursor
		if (isHoveredComponentSelected == true)
		{
			_uiManager.setMouseCursor(MouseCursors.MOUSE_CURSOR_OVER_SELECTION);
		}
		else
		{
			_uiManager.setMouseCursor(MouseCursors.MOUSE_CURSOR_OVER_COMPONENT);
		}
		
		setHighlightedComponents([componentCoordsProxy]);
	}
	
	/**
	 * When the user rolls out of a component, calls a method on the uiManager to hide the 
	 * display of the previously highlighted component
	 */
	private function onComponentRollOut():Void
	{
		_uiManager.unsetHighlightedComponents();
	}
	
	/**
	 * When the user clicks on the background, the uiManager enter the drawing state
	 */
	private function onBackgroundMouseDown():Void
	{
		_uiManager.setState({stateName:Drawing, stateInitData:null});
	}
	
	/////////////////////////////////////////
		// PRIVATE UTILS METHODS
	////////////////////////////////////////

	/**
	 * add an abstraction for setting the highligthed components, as this method
	 * is used multiple times in this class
	 * @param	componentCoordsProxys contains the highligted components coords
	 */
	private function setHighlightedComponents(componentCoordsProxys:Array<ComponentCoordsProxy>)
	{
		var componentCoordsProxysLenth:Int = componentCoordsProxys.length;
		for (i in 0...componentCoordsProxysLenth)
		{
			ComponentsSelectionHelper.unscaleCoords(componentCoordsProxys[i].componentCoords);
		}
		
		_uiManager.setHighlightedComponents(componentCoordsProxys);
	}
	
	/**
	 * add an abstraction for setting the editable component place holders as it used in multiple
	 * instance in this class. It also set at the same time the non-editable components
	 */
	private function setEditableComponents():Void
	{
		var editableComponents:Array<ComponentCoordsProxy> = getEditableComponents();
		
		var editableComponentsLength:Int = editableComponents.length;
		for (i in 0...editableComponentsLength)
		{
			ComponentsSelectionHelper.unscaleCoords(editableComponents[i].componentCoords);
		}
		
		var nonEditableComponents:Array<ComponentCoordsProxy> = getNonEditableComponents();
		var nonEditableComponentsLength:Int = nonEditableComponents.length;
		for (i in 0...nonEditableComponentsLength)
		{
			ComponentsSelectionHelper.unscaleCoords(nonEditableComponents[i].componentCoords);
		}
		
		_uiManager.setEditableComponents(editableComponents);
		_uiManager.setNonEditableComponents(nonEditableComponents);
	}
	
	/**
	 * unset the editable and non-editable components
	 * at the same time
	 */
	private function unsetEditableComponents():Void
	{
		_uiManager.unsetEditableComponents();
		_uiManager.unsetNonEditableComponents();
	}
	
	/**
	 * For all of the displayed components, set their editable property on true or false
	 * depending on the selection mode
	 * @param	isEditable wether to make the components editable or not
	 */
	private function setComponentsEdition(isEditable:Bool):Void
	{
		var displayedComponents:Array<ComponentCoordsProxy> = getDisplayedComponents();
		var displayedComponentsLength:Int = displayedComponents.length;
		for (i in 0...displayedComponentsLength)
		{
			var component:Dynamic = SilexAdminApiCommunication.getInstance().getComponentProxyFromUid(displayedComponents[i].componentUid).getComponent();
			component.isEditable = isEditable;
		}
	}
	
}