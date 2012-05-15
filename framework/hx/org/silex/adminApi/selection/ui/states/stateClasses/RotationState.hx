/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states.stateClasses;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.utils.Structures;

/**
 * This state is used when the user rotates the selected component(s) with one of the rotation handles
 * @author Yannick DOMINGUEZ
 */
class RotationState extends TransformationStateBase
{
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Contains the rotation specific data
	 */
	private var _parameters:Dynamic;
	
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
	 * override to store the parameters specific to the rotation transformation passed
	 * at the start of the state (clicked rotation handle position + click rotation handle position name)
	 * 
	 * @param iniObj contains the data specific to rotation
	 */
	override public function enterState(initObj:Dynamic):Void
	{
		var rotationHandlePosition:Point = initObj.target;
		var rotationHandlePositionName:String = initObj.handlePosition;
		
		_parameters = {
			rotationHandlePosition: rotationHandlePosition,
			rotationHandlePositionName:rotationHandlePositionName
			};
		super.enterState(initObj);
	}
	
	/**
	 * When a rotation is in progress, hides the rotation and scaling handles (as seen in Illustrator, don't sue us please)
	 * @param	event the mouse move event 
	 */
	override private function onTransformationProgress(event:Dynamic):Void
	{
		super.onTransformationProgress(event);
		_uis.hideHandles();
	}
	
	/**
	 * When a rotation stops, shows the rotation and scaling handles
	 * @param	event the mouse up event 
	 */
	override private function onTransformationStop(event:Dynamic):Void
	{
		_uis.showHandles();
		super.onTransformationStop(event);
	}
		
	/**
	 * override to return the stored rotation specific data
	 * @return the rotation specific data
	 */
	override private function getParameters():Dynamic
	{
		return _parameters;
	}
	
	/**
	 * get the event type dispatched when the transformation begins
	 */
	override private function getTransformStartEventType():String
	{
		return SelectionManagerEvent.SELECTION_START_ROTATING;
	}
	
	/**
	 * get the event type dispatched when the transformation is in progress
	 */
	override private function getTransformInProgressEventType():String
	{
		return SelectionManagerEvent.SELECTION_ROTATING;
	}
	
	/**
	 * The event type dispatcvhed when the transformation stops
	 */
	override private function getTransformStopEventType():String
	{
		return SelectionManagerEvent.SELECTION_STOP_ROTATING;
	}
	
}