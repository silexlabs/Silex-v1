/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states.stateClasses;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.ui.states.TransformationStateBase;

/**
 * The state used when the user draws a selection region on the scene. Update the display
 * of the drawn region by sending events to the SelectionManager
 * @author Yannick DOMINGUEZ
 */
class DrawingState extends TransformationStateBase
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
	 * When the drawing start, shows the selection drawing asset
	 * then dispatches an event for the SelectionManager containing the required data
	 * to start the drawing
	 */
	override private function onTransformationStart():Void
	{
		_uis.showSelectionDrawing();
		super.onTransformationStart();
	}
	
	/**
	 * When the user release the mouse, hide the selection drawing
	 * and send an event containing the final coords of the mouse
	 * @param	event the mouse up event
	 */
	override private function onTransformationStop(event:Dynamic):Void
	{
		_uis.hideSelectionDrawing();
		super.onTransformationStop(event);
	}
	
	/**
	 * get the event type dispatched when the transformation begins
	 */
	override private function getTransformStartEventType():String
	{
		return SelectionManagerEvent.SELECTION_REGION_START_DRAWING;
	}
	
	/**
	 * get the event type dispatched when the transformation is in progress
	 */
	override private function getTransformInProgressEventType():String
	{
		return SelectionManagerEvent.SELECTION_REGION_DRAWING;
	}
	
	/**
	 * get the event type dispatched when the transformation stops
	 */
	override private function getTransformStopEventType():String
	{
		return SelectionManagerEvent.SELECTION_REGION_STOP_DRAWING;
	}
	
	
}