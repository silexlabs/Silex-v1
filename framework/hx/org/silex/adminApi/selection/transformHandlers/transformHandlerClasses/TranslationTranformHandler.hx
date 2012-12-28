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
 * The translation transform handlers move the selected components and the pivot point
 * @author Yannick DOMINGUEZ
 */

class TranslationTransformHandler extends TransformHandlerBase
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

	/**
	* The constrain constant used when moving the selected component along the top left to bottom right axis only
	*/
	private static var CONSTRAIN_DIRECTION_TOP_LEFT_BOTTOM_RIGHT:String = "constrainDirectionTopLeftBottomRight";
	
	/**
	* The constrain constant used when moving the selected component along the bottom left to top right axis only
	*/
	private static var CONSTRAIN_DIRECTION_BOTTOM_LEFT_TOP_RIGHT:String = "constrainDirectionBottomLeftTopRight";
	
	/////////////////////////////////////
	// CONTRUCTOR
	////////////////////////////////////
	
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
	}
	
	/////////////////////////////////////
	// OVERIDDEN METHODS
	////////////////////////////////////
	
	/**
	 * Process the new x and y value of the selected components, pivot point and selection region
	 * @param	selectionEvent the data of the event dispatched by the uiManager
	 * @return contains the translated coords of the selection region, pivot point and selected components
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		//get the new coords of the selection region
		var selectionRegionCoords:Coords = getTranslatedSelectionRegion(selectionEvent);
		
		//the array that will be returned
		var transformedComponentsData:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		//will store the x and y difference between the uiManager coords at the start
		//of the transformation and now
		var xDelta:Int;
		var yDelta:Int;
		
		xDelta = (selectionRegionCoords.x - _selectionToolStartCoords.x) ;
		yDelta = (selectionRegionCoords.y - _selectionToolStartCoords.y) ;

		
		//for all the selected component, add the x and y deltas to their x and y
		var selectedComponentsLength:Int = _selectedComponents.length;
		for (i in 0...selectedComponentsLength)
		{
			var componentCoords:Coords = _selectedComponents[i].componentCoords;
			
			var transformedComponentCoords:Coords = { 
				x:componentCoords.x + xDelta,
				y:componentCoords.y + yDelta,
				width:componentCoords.width,
				height:componentCoords.height,
				rotation:componentCoords.rotation 
				};
				
			var transformedComponentData:ComponentCoordsProxy = { componentCoords:transformedComponentCoords, componentUid:_selectedComponents[i].componentUid };
			transformedComponentsData.push(transformedComponentData);
		}
		var transformResult:TransformResult = {
			selectionRegionCoords:selectionRegionCoords,
			transformedComponentsData:transformedComponentsData,
			pivotPoint:getPivotPoint(selectionRegionCoords),
			transformType:TranslationTransformType
			};
		return transformResult;
	}
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Return the coords of the selection region once translated. Do a 
	 * constrained transform if shift is pressed
	 * @param	eventData contains all of the transform event data
	 * @return the coords of the translated selection region
	 */
	private function getTranslatedSelectionRegion(eventData:SelectionManagerEventData):Coords
	{
		if (eventData.keyboardState.useShift == true)
		{
			//process the constrained translation
			return getConstrainedTranslatedSelectedRegion(eventData);
		}
		
		else
		{
			//process the non constrained translation
			return doGetTranslatedSelectionRegion(eventData);
		}
	}
	
	/**
	 * Process the translation of the selection region with the deltas of the mouse x and y
	 * between the start of the translation and the curent mouse position
	 * @param	eventData contains all of the transform event data
	 * @return
	 */
	private function doGetTranslatedSelectionRegion(eventData:SelectionManagerEventData):Coords
	{
		//return the coords with the new x and y of the selection region.
		//width, height and rotation are unaffected by a translation
		return {
			x: _selectionToolStartCoords.x + getXDelta(eventData) , 
			y: _selectionToolStartCoords.y + getYDelta(eventData),
			width: _selectionToolStartCoords.width,
			height: _selectionToolStartCoords.height,
			rotation:_selectionToolStartCoords.rotation
		}
	}
	
	/**
	 * Process the constrained translation of the selection region by finding the closest
	 * constrain axis from the current mouse position
	 * @param	eventData contains all the data of the translation event
	 * @return the translated selection region
	 */
	private function getConstrainedTranslatedSelectedRegion(eventData:SelectionManagerEventData):Coords
	{
		//the current mouse position
		var mouseCoords:Point = eventData.mousePosition;
		
		//we will override the mouse actual position
		//with the position it should have to respect the constrained
		//translation
		var constrainedMouseCoords:Point = {x:0, y:0};
		
		//get the constrain direction
		switch (getClosestDirection(eventData))
		{
			//exemple : for a horizonal translation,
			//the mouse y must always be the same as the one
			//at the start of the transltaion to translate along 
			//a vertical axis, so we set the constrained mouse position y 
			//to the y position of the pivot point
			//as the constrained translation are relative to the pivot point
			case CONSTRAIN_DIRECTION_HORIZONTAL:
			constrainedMouseCoords.y = getTranslationCenter(eventData).y;
			constrainedMouseCoords.x = mouseCoords.x;
			
			case CONSTRAIN_DIRECTION_VERTICAL:
			constrainedMouseCoords.x = getTranslationCenter(eventData).x;
			constrainedMouseCoords.y = mouseCoords.y;
			
			case CONSTRAIN_DIRECTION_BOTTOM_LEFT_TOP_RIGHT:
			if (mouseCoords.x - getTranslationCenter(eventData).x > mouseCoords.y -getTranslationCenter(eventData).y)
			{
				constrainedMouseCoords.x = mouseCoords.x;
				constrainedMouseCoords.y = getTranslationCenter(eventData).y - (mouseCoords.x - getTranslationCenter(eventData).x);
			}
			
			else
			{
				constrainedMouseCoords.x = getTranslationCenter(eventData).x - (mouseCoords.y - getTranslationCenter(eventData).y);
				constrainedMouseCoords.y = mouseCoords.y;
			}
			
			case CONSTRAIN_DIRECTION_TOP_LEFT_BOTTOM_RIGHT:
			if (mouseCoords.x - getTranslationCenter(eventData).x > mouseCoords.y -getTranslationCenter(eventData).y)
			{
				constrainedMouseCoords.x = mouseCoords.x;
				constrainedMouseCoords.y = getTranslationCenter(eventData).y + (mouseCoords.x - getTranslationCenter(eventData).x);
			}
			
			else
			{
				constrainedMouseCoords.x = getTranslationCenter(eventData).x + (mouseCoords.y - getTranslationCenter(eventData).y);
				constrainedMouseCoords.y = mouseCoords.y;
			}
		}
		
		//we replace the actual mouse position with
		//the constrained one
		eventData.mousePosition = constrainedMouseCoords;
		
		return {
			x:_selectionToolStartCoords.x + getXDelta(eventData),
			y:_selectionToolStartCoords.y + getYDelta(eventData),
			width:_selectionToolStartCoords.width,
			height:_selectionToolStartCoords.height,
			rotation:_selectionToolStartCoords.rotation
		};
	}
	
	/**
	 * Return the x delta between the current mouse position and the center of the
	 * translation
	 * @param	eventData contains the translation event data
	 * @return the X delta
	 */
	private function getXDelta(eventData:SelectionManagerEventData):Int
	{
		return eventData.mousePosition.x - getTranslationCenter(eventData).x;
	}
	
	/**
	 * Return the y delta between the current mouse position and the center of the
	 * translation
	 * @param	eventData contains the translation event data
	 * @return the Y delta
	 */
	private function getYDelta(eventData:SelectionManagerEventData):Int
	{
		return eventData.mousePosition.y - getTranslationCenter(eventData).y;
	}
	
	/**
	 * Returns the center of the translation
	 * @param	eventData the translation event data
	 * @return the translation center
	 */
	private function getTranslationCenter(eventData:SelectionManagerEventData):Point
	{
		return _mouseStartPosition;
	}
	
	/**
	 * Find the closest constrain axis by processing the angle between the mouse current position
	 * and the pivot point start position
	 * @param	eventData constains all the translation event data
	 * @return the name of the closest constrain direction
	 */
	private function getClosestDirection(eventData:SelectionManagerEventData):String
	{
		var mouseCoords:Point = eventData.mousePosition;
		
		//the angle in rad between the pivot point start position and the mouse current position
		var angle:Float = Math.atan((mouseCoords.y - _pivotPointStartPosition.y) / (mouseCoords.x - _pivotPointStartPosition.x));
		
		//apply an offset to report the angle to 360°
		var offset:Float = 0;
		
		if ( mouseCoords.x >= _pivotPointStartPosition.x && mouseCoords.y <= _pivotPointStartPosition.y)
		{
			offset += 2 * Math.PI ;
		}
		
		else if ( mouseCoords.x <= _pivotPointStartPosition.x && mouseCoords.y >= _pivotPointStartPosition.y)
		{
			offset += Math.PI ;
		}
		
		else if ( mouseCoords.x < _pivotPointStartPosition.x && mouseCoords.y < _pivotPointStartPosition.y)
		{
			offset += Math.PI;
		}
		
		
		angle += offset;
		
		//determine the contrain direction based on the position of the mouse in the circle
		//around the pivot point start position
		
		return if ((angle < ((2*Math.PI) / 16) || angle > 15*((2*Math.PI) / 16)))
		{
			return CONSTRAIN_DIRECTION_HORIZONTAL;
		}
		
		else if (angle < 3*((2*Math.PI) / 16)  && angle > ((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_TOP_LEFT_BOTTOM_RIGHT;
		}
		
		else if (angle < 5*((2*Math.PI) / 16)  && angle > 3*((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_VERTICAL;
		}
		
		else if (angle < 7*((2*Math.PI) / 16) && angle > 5*((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_BOTTOM_LEFT_TOP_RIGHT;
		}
		
		else if ((angle < 9*((2*Math.PI) / 16) ) && angle > 7*((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_HORIZONTAL;
		}
		
		else if (angle < 11*((2*Math.PI) / 16)&& angle > 9*((2*Math.PI) / 16))
		{
			return CONSTRAIN_DIRECTION_TOP_LEFT_BOTTOM_RIGHT;
		}
		
		else if (angle < 13*((2*Math.PI) / 16)  && angle > 11*((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_VERTICAL;
		}
		
		else if (angle < 15*((2*Math.PI) / 16)  && angle > 13*((2*Math.PI) / 16) )
		{
			return CONSTRAIN_DIRECTION_BOTTOM_LEFT_TOP_RIGHT;
		}
		
	}
	
	/**
	 * Return the updated position of the pivot point, relative to the mouse delta
	 * @param	translatedSelectionRegion the coords of the selectionRegion once updated
	 * @return the translated pivot point
	 */
	override private function getPivotPoint(translatedSelectionRegion:Coords):Point
	{
		var xDelta:Int = translatedSelectionRegion.x - _selectionToolStartCoords.x;
		var yDelta:Int = translatedSelectionRegion.y - _selectionToolStartCoords.y;
		
		return { x:_pivotPointStartPosition.x + xDelta, y:_pivotPointStartPosition.y + yDelta };
	}
	
	
}