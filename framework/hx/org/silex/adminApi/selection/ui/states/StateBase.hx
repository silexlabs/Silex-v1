/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states;

import haxe.Log;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.events.UIEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

/**
 * The base class for all selection states. Defines and exposes methods called by the UIManager class
 * and set default behaviour for those methods
 * @author Yannick DOMINGUEZ
 */
class StateBase
{
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * A reference to all the UIComponents of the UIManager
	 */
	private var _uis:UIsExtern;
	
	/**
	 * A signaler signaling state change, binded by the UIManager
	 */
	public var stateChangeSignaler(default, null):Signaler<StateChangeData>;
	
	/**
	 * Signals when an event occurs on the current state (start/progress/stop of a transformation)
	 */
	public var selectionEventSignaler(default, null):Signaler<SelectionManagerEventData>;
	
	/**
	 * A reference to the pivot mouse down callback
	 */
	private var _pivotPointMouseDownDelegate:UIEvent->Void;
	
	/**
	 * a reference to the rotation handle mouse down callback
	 */
	private var _rotationHandleMouseDownDelegate:UIEvent->Void;
	
	/**
	 * a reference to the scale handle mouse down event
	 */
	private var _scaleHandleMouseDownDelegate:UIEvent->Void;
	
	/**
	 * a reference to key up callback
	 */
	private var _keyboardKeyUpDelegate:UIEvent->Void;
	
	/**
	 * a reference to the key down callback
	 */
	private var _keyboardKeyDownDelegate:UIEvent->Void;
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Stores the reference to the user interface, initiate the signalers
	 * @param	uis the reference to the user interface
	 */
	private function new(uis:UIsExtern) 
	{
		this._uis = uis;
		stateChangeSignaler = new DirectSignaler(this);
		selectionEventSignaler = new DirectSignaler(this);
		
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * called right after the state instanciation. Used to init the state
	 * 
	 * @param initObj an optionnal initObj for the state
	 */
	public function enterState(initObj:Dynamic):Void
	{
		setListeners();
	}
	
	/**
	 * Called just before the state is destroyed. Used to remove all listeners or reset datas
	 */
	public function exitState():Void
	{
		removeListeners();
	}
	
	/**
	 * Draws the selection region around the selected components
	 * @param	selectionRegionCoord the coords of the region to draw
	 */
	public function setSelectionRegion(selectionRegionCoord:Coords):Void
	{
		_uis.setSelectionRegion(selectionRegionCoord);
	}
	
	/**
	 * Hides the selection region
	 */
	public function unsetSelectionRegion():Void
	{
		_uis.unsetSelectionRegion();
	}
	
	/**
	 * Draws the highlight region around the highligted components
	 * @param	highlightedComponentsCoords the coords of the highlighted components
	 */
	public function setHighlightedComponents(highlightedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.setHighlightedComponents(highlightedComponentsCoords);
	}
	
	/**
	 * Hides the region around the highligted components
	 */
	public function unsetHighlightedComponents():Void
	{
		_uis.unsetHighlightedComponents();
	}
	
	/**
	 * set the size and position of the selection drawing
	 * @param	coords the coords of the selection drawing 
	 */
	public function setSelectionDrawing(coords:Coords):Void
	{
		_uis.setSelectionDrawing(coords);
	}
	
	/**
	 * Place the pivot point
	 * @param	pivotPointPosition the pivot point position
	 */
	public function setPivotPoint(pivotPoint:Point):Void
	{
		_uis.setPivotPoint(pivotPoint);
	}
	
	/**
	 * set the component place holders above the editable components which will dispatches
	 * UIevent
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function setEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		
		_uis.setEditableComponents(editableComponentsCoords);
	}
	
	/**
	 * update the component place holders coords 
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function updateEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.updateEditableComponents(editableComponentsCoords);
	}
	
	/**
	 * remove all the component place holders 
	 */
	public function unsetEditableComponents():Void
	{
		_uis.unsetEditableComponents();
	}
	
	/**
	 * set the component place holders above the non editable components which will prevent the default
	 * behaviour of the components when in selection mode
	 * @param	nonEditableComponentsCoords the coords of the nonEditable components
	 */
	public function setNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.setNonEditableComponents(nonEditableComponentsCoords);
	}
	
	/**
	 * update the components place holders coords 
	 * @param	nonEditableComponentsCoords the coords of the editable components
	 */
	public function updateNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.updateNonEditableComponents(nonEditableComponentsCoords);
	}
	
	/**
	 * remove all the components place holders 
	 */
	public function unsetNonEditableComponents():Void
	{
		_uis.unsetNonEditableComponents();
	}
	
	/**
	 * set the visual asset around the selected components
	 * @param	selectedComponentsCoords contains all of the selected components coords
	 */
	public function setSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.setSelectedComponents(selectedComponentsCoords);
	}
	
	/**
	 * remove all the visual assets around selected components
	 */
	public function unsetSelectedComponents():Void
	{
		_uis.unsetSelectedComponents();
	}
	
	/**
	 * Update the coords of all the currently dispaled selected components background assets
	 * @param	selectedComponentsCoords contains all of the selected components coords
	 */
	public function updateSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_uis.updateSelectedComponents(selectedComponentsCoords);
	}
	
	/**
	 * returns the pressed key on the keyboard
	 * @return a bool for each key (true if pressed)
	 */
	public function getKeyboardState():KeyboardState
	{
		return _uis.getKeyboardState();
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * set the listeners on the ui and the keyboard
	 */
	private function setListeners():Void
	{
		_scaleHandleMouseDownDelegate = onSelectionStartScaling;
		_rotationHandleMouseDownDelegate = onSelectionStartRotating;
		_pivotPointMouseDownDelegate = onPivotPointStartTranslating;
		_keyboardKeyDownDelegate = onKeyBoardKeyDown;
		_keyboardKeyUpDelegate = onKeyBoardKeyUp;
		
		_uis.addEventListener(UIEvent.MOUSE_EVENT_ROTATION_HANDLE_MOUSE_DOWN, _rotationHandleMouseDownDelegate);
		_uis.addEventListener(UIEvent.MOUSE_EVENT_SCALE_HANDLE_MOUSE_DOWN, _scaleHandleMouseDownDelegate);
		_uis.addEventListener(UIEvent.MOUSE_EVENT_PIVOT_POINT_MOUSE_DOWN, _pivotPointMouseDownDelegate);
		
		_uis.addEventListener(UIEvent.KEYBOARD_EVENT_KEY_DOWN, _keyboardKeyDownDelegate);
		_uis.addEventListener(UIEvent.KEYBOARD_EVENT_KEY_UP, _keyboardKeyUpDelegate);
		
	}
	
	/**
	 * remove the listeners on the ui and keyboard when the state closes
	 */
	private function removeListeners():Void
	{
		_uis.removeEventListener(UIEvent.MOUSE_EVENT_ROTATION_HANDLE_MOUSE_DOWN, _rotationHandleMouseDownDelegate);
		_uis.removeEventListener(UIEvent.MOUSE_EVENT_SCALE_HANDLE_MOUSE_DOWN, _scaleHandleMouseDownDelegate);
		_uis.removeEventListener(UIEvent.MOUSE_EVENT_PIVOT_POINT_MOUSE_DOWN, _pivotPointMouseDownDelegate);
		
		_uis.removeEventListener(UIEvent.KEYBOARD_EVENT_KEY_DOWN, _keyboardKeyDownDelegate);
		_uis.removeEventListener(UIEvent.KEYBOARD_EVENT_KEY_UP, _keyboardKeyUpDelegate);
	}
	
	/////////////////////////////////////////
		// UIS CALLBACKS 
		// callbacks to events dispatched by the user interface
	////////////////////////////////////////
	
	/**
	 * When a rotation handle is clicked, dispatches a signal to switch to rotation state
	 * @param event the event dispatched by the ui on rotation handle click
	 */
	private function onSelectionStartRotating(event:UIEvent):Void
	{
		stateChangeSignaler.dispatch({ stateName:Rotating, stateInitData:event.data });
	}
	
	/**
	 * When a scaling handle is clicked, dispatches a signal to switch to scale state
	 * @param	event the event dispatched by the ui on scale handle click
	 */
	private function onSelectionStartScaling(event:UIEvent):Void
	{
		stateChangeSignaler.dispatch({ stateName:Scaling, stateInitData:event.data });
	}

	/**
	 * When the pivot point is clicked, dispatches a signal to switch to translate pivot state
	 * @param	event the event dispatched by the ui on pivot point click
	 */
	private function onPivotPointStartTranslating(event:UIEvent):Void
	{
		stateChangeSignaler.dispatch( { stateName:TranslatingPivotPoint, stateInitData:event.data } );
	}
	
	/**
	 * Called when the user releases a key
	 * @param the keyboard up event dispatched by the ui
	 */
	private function onKeyBoardKeyUp(event:UIEvent):Void
	{
		//abstract
	}
	
	/**
	 * Called when the user presses a key. 
	 * @param the keyboard down event dispatched by the ui
	 */
	private function onKeyBoardKeyDown(event:UIEvent):Void
	{
		//retrieve all the pressed key
		var keyboardState:KeyboardState = _uis.getKeyboardState();
		
		//if an arrow key is pressed, 
		//dispatch a signal to switch to keyboard translation state
		if (
		keyboardState.useLeft == true ||
		keyboardState.useRight == true ||
		keyboardState.useUp == true ||
		keyboardState.useDown == true )
		{
			stateChangeSignaler.dispatch( { stateName:KeyboardTranslating, stateInitData:null } );
		}
		
		
	}
}