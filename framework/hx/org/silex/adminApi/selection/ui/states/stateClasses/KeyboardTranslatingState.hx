/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states.stateClasses;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.events.UIEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;

/**
 * A state used when the user moves the selection with the keyboard arrows
 * @author Yannick DOMINGUEZ
 */
class KeyboardTranslatingState extends TransformationStateBase
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function new(uis:UIsExtern)
	{
		super(uis);
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// OVERRIDEN METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * override the method to prevent listening to mouse event, only keyboard events
	 * are listened in this state
	 */
	override private function onTransformationStart():Void
	{
		selectionEventSignaler.dispatch(getEventData(getTransformStartEventType()));
	}
	
	/**
	 * override the method to remove all operation related to listening to the mouse
	 * @param event the keyboard up event
	 */
	override private function onTransformationStop(event:Dynamic):Void
	{
		selectionEventSignaler.dispatch(getEventData(getTransformStopEventType()));
	}
	
	/**
	 * In this state, the keyUp correspond to the end of the transformation, so we call the stop
	 * transformation method when the user releases the arrow key
	 * 
	 * @param event the key up event
	 */
	override private function onKeyBoardKeyUp(event:UIEvent):Void
	{
		onTransformationStop(null);
	}
	
	/**
	 * In this state the pressed keys correspond to the transformation in progress, so we call the 
	 * transformation progress method as long as the user presses the arrow key
	 * 
	 * @param event the key down event
	 */
	override private function onKeyBoardKeyDown(event:UIEvent):Void
	{
		onTransformationProgress(null);
	}
	
	/**
	 * get the event type dispatched when the transformation begins
	 */
	override private function getTransformStartEventType():String
	{
		return SelectionManagerEvent.SELECTION_START_KEYBOARD_TRANSLATION;
	}
	
	/**
	 * get the event type dispatched when the transformation is in progress
	 */
	override private function getTransformInProgressEventType():String
	{
		return SelectionManagerEvent.SELECTION_KEYBOARD_TRANSLATING;
	}
	
	/**
	 * The event type dispatcvhed when the transformation stops
	 */
	override private function getTransformStopEventType():String
	{
		return SelectionManagerEvent.SELECTION_STOP_KEYBOARD_TRANSLATING;
	}
	

	
}