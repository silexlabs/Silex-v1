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

/**
 * The base class for transformation states. A transformation state starts when the user starts
 * a transformation and exits when the transformation is done
 * @author Yannick DOMINGUEZ
 */
class TransformationStateBase extends StateBase
{
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Check wether shift is currently pressed
	 */
	private var _shiftPressed:Bool;
	
	/**
	 * Check wether control is currently pressed
	 */
	private var _ctrlPressed:Bool;
	
	/**
	 * Check wether alt is currently pressed
	 */
	private var _altPressed:Bool;
	
	/**
	 * a reference to the mouse move event callback
	 */
	private var _mouseMoveDelegate:Dynamic->Void;
	
	/**
	 * a reference to the mouse up event callback
	 */
	private var _mouseUpDelegate:Dynamic->Void;
	
	
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	private function new(uis:UIsExtern)
	{
		super(uis);
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// OVERRIDEN METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When entering a transformation state, hides the highlighted component asset
	 * then start the transformation
	 * 
	 * @param initObj an optionnal init object for the state
	 */
	override public function enterState(initObj:Dynamic):Void
	{
		super.enterState(initObj);
		_uis.unsetHighlightedComponents();
		onTransformationStart();
	}
	
	/**
	 * Called when the user releases a key. Check the pressed key on the keyboard
	 * 
	 * @param event the keyboard event dispatched by the ui
	 */
	override private function onKeyBoardKeyUp(event:UIEvent):Void
	{
		checkKeyboardState();
	}
	
	/**
	 * Called when the user releases a key. Check the pressed key on the keyboard
	 * 
	 * @param event the keyboard event dispatched by the ui
	 */
	override private function onKeyBoardKeyDown(event:UIEvent):Void
	{
		checkKeyboardState();
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// PROTECTED METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * When the transformation starts, start listening to UI events to update and stop the transformation
	 * then signal the start of a transformation
	 */
	private function onTransformationStart():Void
	{	
		_mouseMoveDelegate = onTransformationProgress;
		_mouseUpDelegate = onTransformationStop;
		
		//listen to mouse move and mouse up events
		_uis.addEventListener(UIEvent.MOUSE_EVENT_MOUSE_MOVED, _mouseMoveDelegate);
		_uis.addEventListener(UIEvent.MOUSE_EVENT_MOUSE_UP, _mouseUpDelegate);
		
		selectionEventSignaler.dispatch(getEventData(getTransformStartEventType()));
	}
	
	/**
	 * Dispatch a signal for the selectionManager when the transformation is in progress
	 * @param	event the mouse move event 
	 */
	private function onTransformationProgress(event:Dynamic):Void
	{
		selectionEventSignaler.dispatch(getEventData(getTransformInProgressEventType()));
	}
	
	/**
	 * When the transformation stops, remove the listener on the UI then signal
	 * the end of the transformation to the selection manager
	 * @param	event the mouse up event
	 */
	private function onTransformationStop(event:Dynamic):Void
	{
		//remove the listeners on mouse move and mouse up events
		_uis.removeEventListener(UIEvent.MOUSE_EVENT_MOUSE_MOVED, _mouseMoveDelegate);
		_uis.removeEventListener(UIEvent.MOUSE_EVENT_MOUSE_UP, _mouseUpDelegate);
		
		selectionEventSignaler.dispatch(getEventData(getTransformStopEventType()));
	}
	
	/**
	 * return the data for a transformation event. Might be overriden
	 * @param eventType the type of the dispatched event
	 * @return contains the mouse coords, the keyboard pressed keys, selection region coords, and optionnal parameters
	 */
	private function getEventData(eventType:String):SelectionManagerEventData
	{
		return {
			eventType:eventType,
			mousePosition: _uis.getMousePosition(),
			pivotPoint:_uis.getPivotPoint(),
			selectionRegionCoords:_uis.getSelectionRegionCoords(),
			parameters:getParameters(),
			keyboardState:_uis.getKeyboardState()
		}
	}
	
	/**
	 * If a key changed occured (one of the key was just released or pressed),
	 * dispatch an event to update the SelectionTool display
	 */
	private function checkKeyboardState():Void
	{
		//get the current keyboard pressed and unpressed keys
		var keyBoardState:KeyboardState = _uis.getKeyboardState();
		
		//if one of the watched keys just changed state, update the transformation
		if (_shiftPressed != keyBoardState.useShift ||
		_altPressed != keyBoardState.useAlt ||
		_ctrlPressed != keyBoardState.useCtrl)
		{
			onTransformationProgress(Void);
		}
		
		checkPressedKey();
	}
	
	/**
	 * Save the state of the key on the keyboard
	 */
	private function checkPressedKey():Void
	{
		var keyBoardState:KeyboardState = _uis.getKeyboardState();
		
		_shiftPressed = keyBoardState.useShift;
		_altPressed = keyBoardState.useAlt;
		_ctrlPressed = keyBoardState.useCtrl;
	}
	
	/**
	 * get the event type dispatched when the transformation begins
	 */
	private function getTransformStartEventType():String
	{
		return null;
	}
	
	/**
	 * get the event type dispatched when the transformation is in progress
	 */
	private function getTransformInProgressEventType():String
	{
		return null;
	}
	
	/**
	 * get the event type dispatcvhed when the transformation stops
	 */
	private function getTransformStopEventType():String
	{
		return null;
	}
	
	/**
	 * get an optionnal parameters object used, used by inheriting class
	 * for data specific to a single transformation
	 */
	private function getParameters():Dynamic
	{
		return null;
	}
	
}