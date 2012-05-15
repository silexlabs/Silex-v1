/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.transformHandlers.transformHandlerClasses;
import haxe.Log;
import org.silex.adminApi.selection.components.ComponentsSelectionHelper;
import org.silex.adminApi.selection.transformHandlers.TransformHandlerBase;
import org.silex.adminApi.selection.ui.uis.uiComponents.RotationHandle;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;

/**
 * This classe rotates one or mny components around the pivot point
 * @author Yannick DOMINGUEZ
 */

class RotationTransformHandler extends TransformHandlerBase
{

	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * This the angle beetween the selection region and the mouse pointer at the start of the
	 * rotation, stored to apply an offset to each subsequent rotation
	 */
	private var _initialAngle:Float;
	
	/**
	 * The name of the clicked rotation handle
	*/
	private var _rotationHandlePositionName:String;
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Stores the initial angle of the rotation and the clicked handle position name
	 * @param	selectionToolEventStartData
	 * @param	selectedComponents
	 */
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
		
		_rotationHandlePositionName = selectionToolEventStartData.parameters.rotationHandlePositionName;
		
		//stores the initial angle in rad
		_initialAngle = doGetSelectionRegionRotation(selectionToolEventStartData) + (_selectionToolStartCoords.rotation * Math.PI / 180);
	}
	
	/////////////////////////////////////
	// OVERRIDEN METHODS
	////////////////////////////////////
	
	/**
	 * Rotate the selection region and each of the selected components around the pivot point
	 * @param	selectionEvent contains all the rotation event data
	 * @return the rotated selection region, components coords and the pivot point position (doesn't change in a rotation)
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		//the rotated selection region
		var selectionRegionCoords:Coords = getSelectionRegionCoords(selectionEvent);
		
		var transformedComponentsData:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		//for each component, rotate it's coordinate and push it in an array
		var selectedComponentsLength:Int = _selectedComponents.length;
		for (i in 0...selectedComponentsLength)
		{
			var componentCoords:Coords = _selectedComponents[i].componentCoords;
			
			componentCoords = getRotatedCoords(selectionEvent, componentCoords);
			
			var transformedComponentData:ComponentCoordsProxy = { componentCoords:componentCoords, componentUid:_selectedComponents[i].componentUid};
			transformedComponentsData.push(transformedComponentData);
		}
		
		
		return {
			selectionRegionCoords:selectionRegionCoords,
			pivotPoint:getPivotPoint(selectionRegionCoords),
			transformedComponentsData:transformedComponentsData,
			transformType:RotationTransformType
		};
	}
	
	/**
	 * rotate the selection region and return the rotated coords
	 * @param	eventData contain the data of the rotation event
	 * @return the rotated selection region coords
	 */
	override private function getSelectionRegionCoords(eventData:SelectionManagerEventData):Coords
	{
		return getRotatedCoords(eventData, _selectionToolStartCoords);
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Rotates the given coords (can be the selection region or a selected component) around the pivot point
	 * and returns the rotated coords
	 * @param	eventData the rotation event data
	 * @param	coords the coords to rotate
	 * @return the rotated coords
	 */
	private function getRotatedCoords(eventData:SelectionManagerEventData, coords:Coords):Coords
	{
		return ComponentsSelectionHelper.getRotatedCoords(getSelectionRegionRotation(eventData), coords, _pivotPointStartPosition);
	}

	/**
	 * Returns the current angle of rotation (in rad). This is the angle between the selection region start
	 * position and the mouse
	 * @param	eventData contains all the roation data
	 * @return the angle of rotation
	 */
	private function doGetSelectionRegionRotation(eventData:SelectionManagerEventData):Float
	{
		//get the deltas betwwen the mouse and the pivot point
		var xDelta:Int = _pivotPointStartPosition.x - eventData.mousePosition.x ;
		var yDelta:Int  = _pivotPointStartPosition.y - eventData.mousePosition.y;
		
		//get the angle of rotation from the delta
		var angle:Float = Math.atan((yDelta / xDelta));
		
		//add variying offsets, according to the current mouse position to 
		//return an angle between 0° to 360°
		var offset:Float = - Math.PI;
		
		if ( eventData.mousePosition.x >= _pivotPointStartPosition.x && eventData.mousePosition.y <= _pivotPointStartPosition.y)
		{
			offset += 2 * Math.PI;
		}
		
		if ( eventData.mousePosition.x > _pivotPointStartPosition.x && eventData.mousePosition.y > _pivotPointStartPosition.y)
		{
			offset += 2 * Math.PI;
		}
		
		else if ( eventData.mousePosition.x <= _pivotPointStartPosition.x && eventData.mousePosition.y >= _pivotPointStartPosition.y)
		{
			offset += 3 * Math.PI;
		}
		
		else if ( eventData.mousePosition.x < _pivotPointStartPosition.x && eventData.mousePosition.y < _pivotPointStartPosition.y)
		{
			offset += Math.PI;
		}
		
		var rotationAngle:Float = angle + offset;
		
		//if Shift is pressed, returns a constrained angle, the closest
		//angle multiple of 45°
		if (eventData.keyboardState.useShift == true)
		{
			var constrainedAngle:Float = 0;
			var index:Int = 0;
			while (constrainedAngle < rotationAngle)
			{
				constrainedAngle += Math.PI / 4;
				index++;
			}
			
			rotationAngle = index * ( Math.PI / 4);
		}
		
		return rotationAngle;
	}
	
	/**
	 * returns the selection region rotation, minus the initial angle offset
	 * @param	eventData the rotation event data
	 * @return the rotation angle
	 */
	private function getSelectionRegionRotation(eventData:SelectionManagerEventData):Float
	{
		return doGetSelectionRegionRotation(eventData) - getInitialRotationAngle(eventData);
	}
	
	/**
	 * Returns the initial rotation angle (at the start of the selection
	 * @param	eventData
	 * @return the initial angle
	 */
	private function getInitialRotationAngle(eventData:SelectionManagerEventData):Float
	{
		//if shift was not pressed, we return the true initial angle
		if (eventData.keyboardState.useShift == false)
		{
			return _initialAngle;
		}
		
		//else we return a constrain angle to match with the constrain rotation
		else
		{
			return switch (_rotationHandlePositionName)
			{
				case RotationHandle.ROTATION_HANDLE_POSITION_TL:
				Math.PI / 4;
				
				case RotationHandle.ROTATION_HANDLE_POSITION_TR:
				(Math.PI * 3) / 4;
				
				case RotationHandle.ROTATION_HANDLE_POSITION_BR:
				(Math.PI * 5) / 4;
				
				case RotationHandle.ROTATION_HANDLE_POSITION_BL:
				(Math.PI * 7) / 4;
			}
		}
	}
	
}