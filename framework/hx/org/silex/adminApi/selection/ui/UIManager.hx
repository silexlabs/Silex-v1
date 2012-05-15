/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui;
import haxe.Log;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.ui.states.StateBase;
import org.silex.adminApi.selection.ui.states.stateClasses.DisabledState;
import org.silex.adminApi.selection.ui.states.stateClasses.DrawingState;
import org.silex.adminApi.selection.ui.states.stateClasses.RotationState;
import org.silex.adminApi.selection.ui.states.stateClasses.ScalingState;
import org.silex.adminApi.selection.ui.states.stateClasses.SelectedState;
import org.silex.adminApi.selection.ui.states.stateClasses.TranslatingPivotPoint;
import org.silex.adminApi.selection.ui.states.stateClasses.TranslatingState;
import org.silex.adminApi.selection.ui.states.stateClasses.KeyboardTranslatingState;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.states.stateClasses.UnselectedState;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;
import hsl.haxe.Signaler;
import hsl.haxe.DirectSignaler;

/**
 * The entry point of the UIManager. Manages the selection states, exposes methods allowing the selectionManager
 * to control the UIManager and relays the signals dispatched by it's states to the SelectionManager
 * @author Yannick DOMINGUEZ
 */
class UIManager
{
	
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * a reference to the current state of the UIManager
	 */
	private var _currentState:StateBase;
	
	/**
	 * The name of the current state of the UIManager
	 */
	private var _currentStateName:SelectionStates;

	/**
	 * A reference to all the graphical components of the UIManager
	 */
	private var _uis:UIsExtern;
	
	/**
	 * Signals when an event occurs on the SelectionTool (start/progress/stop of a transformation)
	 */
	public var selectionEventSignaler(default, null):Signaler<SelectionManagerEventData>;
	
	/**
	 * a reference to the state change callback
	 */
	private var _selectionStateChangeDelegate:Dynamic->Void;
	
	/**
	 * a reference to the selection event callback
	 */
	private var _selectionEventDelegate:Dynamic->Void;
	
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Stores a reference to the uis (conatains all the selection tool
	 * user interfaces)
	 * @param	uis
	 */
	public function new(uis:UIsExtern) 
	{
		_uis = uis;
		selectionEventSignaler = new DirectSignaler(this);
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * Changes the state of the UIManager. sets listeners on the new state
	 * @param	stateChangeData contains the name of the state to switch to and an optionnal
	 * init object passed to the new state
	 */
	public function setState(stateChangeData:StateChangeData):Void
	{
		
		//change state only if it is undefined or if it is a different one than the current one
		if (_currentStateName != stateChangeData.stateName || _currentStateName == null)
		{
			//exit the current state if it exists (not the first state)
			if (_currentState != null)
			{
				_currentState.exitState();
				
				//remove all the listener on the previous state if it exists
				removeListeners();
			}
			
			
			//instantiate the new state
			switch (stateChangeData.stateName)
			{
				case Unselected:
				_currentState = new UnselectedState(_uis);
				
				case Selected:
				_currentState = new SelectedState(_uis);
				
				case Translating:
				_currentState = new TranslatingState(_uis);
				
				case Rotating:
				_currentState =  new RotationState(_uis);
				
				case Scaling:
				_currentState = new ScalingState(_uis);
				
				case Drawing:
				_currentState = new DrawingState(_uis);
				
				case TranslatingPivotPoint:
				_currentState = new TranslatingPivotPoint(_uis);
				
				case KeyboardTranslating:
				_currentState = new KeyboardTranslatingState(_uis);
				
				case Disabled:
				_currentState = new DisabledState(_uis);
			}
			
			//set listeners to the new state and init it
			addListeners();
			_currentState.enterState(stateChangeData.stateInitData);
			_currentStateName = stateChangeData.stateName;
		}
	}
	
	/**
	 * Draws the selection region around the selected components
	 * @param selectionRegionCoord the coords of the region to draw
	 */ 
	public function setSelectionRegion(selectionRegionCoord:Coords):Void
	{
		_currentState.setSelectionRegion(selectionRegionCoord);
	}
	
	/**
	 * Draws the highlight region around the highligted components
	 * @param	highlightedComponentsCoords the coords of the highlighted components
	 */
	public function setHighlightedComponents(highlightedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.setHighlightedComponents(highlightedComponentsCoords);
	}
	
	/**
	 * set the size and position of the selection drawing
	 * @param	coords the coords of the selection drawing 
	 */
	public function setSelectionDrawing(coords:Coords):Void
	{
		_currentState.setSelectionDrawing(coords);
	}
	
	/**
	 * Hides the region around the highlighted components
	 */
	public function unsetHighlightedComponents():Void
	{
		_currentState.unsetHighlightedComponents();
	}
	
	/**
	 * Place the pivot point
	 * @param	pivotPoint the pivot point position
	 */
	public function setPivotPoint(pivotPoint:Point):Void
	{
		_currentState.setPivotPoint(pivotPoint);
	}
	
	/**
	 * set the component place holders above the editable components which will dispatches
	 * UIevent
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function setEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.setEditableComponents(editableComponentsCoords);
	}
	
	
	/**
	 * update the component place holders coords 
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function updateEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.updateEditableComponents(editableComponentsCoords);
	}
	
	/**
	 * remove all the component place holders 
	 */
	public function unsetEditableComponents():Void
	{
		_currentState.unsetEditableComponents();
	}
	
	/**
	 * set the component place holders above the non editable components which will prevent the default
	 * behaviour of the components when in selection mode
	 * @param	nonEditableComponentsCoords the coords of the nonEditable components
	 */
	public function setNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.setNonEditableComponents(nonEditableComponentsCoords);
	}
	
	/**
	 * update the components place holders coords 
	 * @param	nonEditableComponentsCoords the coords of the editable components
	 */
	public function updateNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.updateNonEditableComponents(nonEditableComponentsCoords);
	}
	
	/**
	 * remove all the components place holders 
	 */
	public function unsetNonEditableComponents():Void
	{
		_currentState.unsetNonEditableComponents();
	}
	
	/**
	 * set the visual asset around the selected components
	 * @param	selectedComponentsCoords contains all of the selected components coords
	 */
	public function setSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.setSelectedComponents(selectedComponentsCoords);
	}
	
	/**
	 * remove all the visual assets around selected components
	 */
	public function unsetSelectedComponents():Void
	{
		_currentState.unsetSelectedComponents();
	}
	
	/**
	 * Update the coords of all the currently displayed selected components background assets
	 * @param	selectedComponentsCoords contains all of the selected components coords
	 */
	public function updateSelectedComponents(selectedComponentsCoords:Array<ComponentCoordsProxy>):Void
	{
		_currentState.updateSelectedComponents(selectedComponentsCoords);
	}
	
	/**
	 * returns the pressed keys on the keyboard
	 * @return a bool for each key (true if pressed, else false)
	 */
	public function getKeyboardState():KeyboardState
	{
		return _currentState.getKeyboardState();
	}
	
	/**
	 * Set a custom mouse cursor
	 * @param	mouseCursor the name of the target mouse cursor
	 */
	public function setMouseCursor(mouseCursor:String):Void
	{
		_uis.setMouseCursor(mouseCursor);
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Add all the signal listeners on the current state
	 */
	private function addListeners():Void
	{
		_selectionStateChangeDelegate = onSelectionStateChange;
		_selectionEventDelegate = onSelectionEvent;
		
		_currentState.stateChangeSignaler.bind(_selectionStateChangeDelegate);
		_currentState.selectionEventSignaler.bind(_selectionEventDelegate);
	}
	
	/**
	 * remove all the signal listeners from the state about to be exited
	 */
	private function removeListeners():Void
	{
		_currentState.stateChangeSignaler.unbind(_selectionStateChangeDelegate);
		_currentState.selectionEventSignaler.unbind(_selectionEventDelegate);
		
	}
	
	/////////////////////////////////////
	// CALLBACKS METHODS
	////////////////////////////////////
	
	/**
	 * Called when the state of the UIManager must be changed
	 * @param	stateChangeData contains the name of the state to switch to and the init obj to initialise the state with  
	 */
	private function onSelectionStateChange(stateChangeData:StateChangeData):Void
	{
		this.setState(stateChangeData);
	}
	
	/**
	 * Relays the current state signals to the SelectionManager
	 * @param	selectionManagerEventData the event to relay
	 */
	private function onSelectionEvent(selectionManagerEventData:SelectionManagerEventData):Void
	{
		selectionEventSignaler.dispatch(selectionManagerEventData);
	}
	
}