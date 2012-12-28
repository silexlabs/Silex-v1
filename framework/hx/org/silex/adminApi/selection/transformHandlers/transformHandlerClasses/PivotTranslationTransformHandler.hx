/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.transformHandlers.transformHandlerClasses;
import haxe.Log;
import org.silex.adminApi.selection.transformHandlers.TransformHandlerBase;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.components.ComponentsSelectionHelper;
import org.silex.adminApi.selection.utils.Enums;

/**
 * This transform class translate the position of the pivot point
 * @author Yannick DOMINGUEZ
 */

class PivotTranslationTransformHandler extends TransformHandlerBase
{

	/////////////////////////////////////
	// CONSTANTS
	////////////////////////////////////
	
	/**
	* The constrain constant used when moving the selected component along the x axis only
	*/
	private static var CONSTRAIN_DIRECTION_HORIZONTAL:String = "constrainDirectionHorizontal";
	
	/**
	* The constrain constant used when moving the selected component along the y axis only
	*/
	private static var CONSTRAIN_DIRECTION_VERTICAL:String = "constrainDirectionVertical";
	
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
	}
	
	/////////////////////////////////////
	// OVERIDDEN METHODS
	////////////////////////////////////
	
	/**
	 * Process the new pivot point position and returns the start selection region coords as it is not moved. Returns also
	 * an empty array of transfromed component as none were affected by this transformation
	 * @param	selectionEvent contains the translation event data
	 * @return the resutl of the transformation
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		return {
			selectionRegionCoords:getSelectionRegionCoords(selectionEvent),
			pivotPoint:getTranslatedPivotPoint(selectionEvent),
			transformedComponentsData:new Array<ComponentCoordsProxy>(),
			transformType:PivotPointTranslationTransformType
		}
	} 

	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Process tht translation of the pivot point, if shift is pressed, move it along
	 * a constrained axis
	 * @param	eventData contains the data of the translation event
	 * @return the new positon of the pivot point
	 */
	private function getTranslatedPivotPoint(eventData:SelectionManagerEventData):Point
	{
		if (eventData.keyboardState.useShift == true)
		{
			return getConstrainedTranslatedPivotPoint(eventData);
		}
		
		else
		{
			return doGetTranslatedPivotPoint(eventData);
		}
	}
	
	/**
	 * Process the unconstrained new pivot point position
	 * @param	eventData contains the data of the translation event
	 * @return the new positon of the pivot point
	 */
	private function doGetTranslatedPivotPoint(eventData:SelectionManagerEventData):Point
	{
		//the current mouse postion
		var mouseCoords:Point = eventData.mousePosition;
		
		//the delta between the current mouse position and the mouse position
		//at the start of the translation
		var xDelta:Int = mouseCoords.x - _pivotPointStartPosition.x;
		var yDelta:Int = mouseCoords.y - _pivotPointStartPosition.y;
		
		//return the coords with the new x and y of the selection region.
		//width, height and rotation are unafected by a translation
		return {
			x: _pivotPointStartPosition.x + xDelta, 
			y: _pivotPointStartPosition.y + yDelta
		};
	}
	
	/**
	 * Process the constrained translation of the pivot point by finding the closest
	 * constrain axis from the current mouse position
	 * @param	eventData contains all the data of the translation event
	 * @return the translated pivot point
	 */
	private function getConstrainedTranslatedPivotPoint(eventData:SelectionManagerEventData):Point
	{
		//the current mouse position
		var mouseCoords:Point = eventData.mousePosition;
		
		//the delta between the current position and position at the 
		//start of the translation
		var xDelta:Int = mouseCoords.x - _pivotPointStartPosition.x;
		var yDelta:Int = mouseCoords.y - _pivotPointStartPosition.y;
		
		var translatedX:Int = _pivotPointStartPosition.x;
		var translatedY:Int = _pivotPointStartPosition.y;
		
		//get the closest contrain axis and process the x and y
		//of the pivot point accordingly
		switch (getClosestDirection(eventData))
		{
			//if we move the component along the x axis,
			//only the x is affected by the translation,
			//y remains the same as when the translation started
			case CONSTRAIN_DIRECTION_HORIZONTAL:
			translatedY = _pivotPointStartPosition.y;
			translatedX = _pivotPointStartPosition.x + xDelta;
			
			case CONSTRAIN_DIRECTION_VERTICAL:
			translatedY = _pivotPointStartPosition.y + yDelta;
			translatedX = _pivotPointStartPosition.x;
		}
		
		return {
			x:translatedX,
			y:translatedY,
		};
	}
	
	/**
	 * Find the closest constrain axis by comparing the distance between the mouse current position
	 * and mouse position at the start of the translation
	 * @param	eventData constains all the translation event data
	 * @return the name of the closest constrain direction
	 */
	private function getClosestDirection(eventData:SelectionManagerEventData):String
	{
		var mouseCoords:Point = eventData.mousePosition;
		
		//if the mouse current x is farthest from the mouse x initial position then mouse current y is from
		//the mouse initial y, then we are translating along the x axis
		if (Math.abs(_pivotPointStartPosition.x - mouseCoords.x) > Math.abs(_pivotPointStartPosition.y - mouseCoords.y))
		{
			return CONSTRAIN_DIRECTION_HORIZONTAL;
		}
		
		//else, along the vertical axis
		else
		{
			return CONSTRAIN_DIRECTION_VERTICAL;
		}
	}
}