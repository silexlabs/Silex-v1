/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.states.stateClasses;
import haxe.Log;
import org.silex.adminApi.selection.events.SelectionManagerEvent;
import org.silex.adminApi.selection.ui.externs.UIsExtern;
import org.silex.adminApi.selection.utils.Structures;

/**
 * The state used when the user starts scaling the selected components. Dispatches update events
 * for the SelectionManager and exits when the user stops the scaling by releasing the handle
 * @author Yannick DOMINGUEZ
 */
class ScalingState extends TransformationStateBase
{

	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Contains the scale specific data
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
	 * override to store the parameters specific to the scaling transformation passed
	 * at the start of the state (clicked and oposed scaling handles position + clicked scaling handle position name)
	 * 
	 * @param iniObj contains the data specific to scaling
	 */
	override public function enterState(initObj:Dynamic):Void
	{
		var scaleHandlePosition:Point = initObj.target;
		var opositeHandlePosition:Point = initObj.opositeHandle;
		var scaleHandlePositionName:String = initObj.handlePosition;
		
		_parameters = {
			scaleHandlePosition: scaleHandlePosition,
			opositeHandlePosition:opositeHandlePosition,
			scaleHandlePositionName:scaleHandlePositionName
			};
		
		super.enterState(initObj);
	}
	
	/**
	 * override to return the stored scaling specific data
	 * @return the scaling specific data
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
		return SelectionManagerEvent.SELECTION_START_SCALING;
	}
	
	/**
	 * get the event type dispatched when the transformation is in progress
	 */
	override private function getTransformInProgressEventType():String
	{
		return SelectionManagerEvent.SELECTION_SCALING;
	}
	
	/**
	 * The event type dispatched when the transformation stops
	 */
	override private function getTransformStopEventType():String
	{
		return SelectionManagerEvent.SELECTION_STOP_SCALING;
	}
	
}