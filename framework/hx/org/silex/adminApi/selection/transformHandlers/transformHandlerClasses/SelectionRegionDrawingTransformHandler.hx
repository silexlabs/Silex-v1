/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.transformHandlers.transformHandlerClasses;
import org.silex.adminApi.selection.transformHandlers.TransformHandlerBase;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.components.ComponentsSelectionHelper;
import org.silex.adminApi.selection.utils.Enums;

/**
 * This transform class transforms the drawing of a selection region on the scene
 * @author Yannick DOMINGUEZ
 */

class SelectionRegionDrawingTransformHandler extends TransformHandlerBase
{

	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
		
	}
	
	/////////////////////////////////////
	// OVERRIDEN METHODS
	////////////////////////////////////
	
	/**
	 * Returns the processed drawing selection region as the selectionr egion coords. The SelectionManager is in charge
	 * of using this object to draw a selection drawing instead of updating the selection region
	 * @param	selectionEvent contains the drawing event data
	 * @return the result of the transformation
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		return {
			selectionRegionCoords:getSelectionDrawingRegion(selectionEvent),
			pivotPoint:_pivotPointStartPosition,
			transformedComponentsData:new Array<ComponentCoordsProxy>(),
			transformType:DrawingTransformType
		};
	} 
	
	/////////////////////////////////////
	// PRIVATE METHODS
	////////////////////////////////////
	
	/**
	 * Process the selection drawing coords using the offsets between the mouse start position
	 * and the current mouse position
	 * @param	eventData contains the data of the event
	 * @return the coords of the drawing region
	 */
	private function doGetSelectionDrawingRegion(eventData:SelectionManagerEventData):Coords
	{
		return {
			x:getSelectionDrawingX(eventData.mousePosition),
			y:getSelectionDrawingY(eventData.mousePosition),
			width:getSelectionDrawingWidth(eventData.mousePosition),
			height:getSelectionDrawingHeight(eventData.mousePosition),
			rotation:0.0};
	}
	
	/**
	 * Process the homothetic selection drawing coords (the width and height are equals) using the offsets between the mouse start position
	 * and the current mouse position
	 * @param	eventData contains the data of the event
	 * @return the coords of tht drawing region
	 */
	private function doGetHomotheticSelectionDrawingRegion(eventData:SelectionManagerEventData):Coords
	{
		var selectionDrawingHeight:Int = getSelectionDrawingHeight(eventData.mousePosition);
		var selectionDrawingWidth:Int = getSelectionDrawingWidth(eventData.mousePosition);
		var homotheticMousePosition:Point = {x:0, y:0};
		var mousePosition:Point = eventData.mousePosition;
		
		//if the region drawing height is superior
		//to width, we use it's value for both
		if (selectionDrawingHeight > selectionDrawingWidth)
		{
			selectionDrawingWidth = selectionDrawingHeight;
		}
		
		//else we do the same for width
		else
		{
			selectionDrawingHeight = selectionDrawingWidth;
		}
		
		//we then calculate the mouse position as if it was at an 45° angle
		//from the start mouse position, so that the selection region is always
		//square
		if (mousePosition.x > _mouseStartPosition.x)
		{
			homotheticMousePosition.x = _mouseStartPosition.x + selectionDrawingWidth;
		}
		
		else
		{
			homotheticMousePosition.x = _mouseStartPosition.x - selectionDrawingWidth;
		}
		
		if (mousePosition.y > _mouseStartPosition.y)
		{
			homotheticMousePosition.y = _mouseStartPosition.y + selectionDrawingHeight;
		}
		
		else
		{
			homotheticMousePosition.y = _mouseStartPosition.y - selectionDrawingHeight;
		}
	
		
		
		return {
			x:getSelectionDrawingX(homotheticMousePosition),
			y:getSelectionDrawingY(homotheticMousePosition),
			width:selectionDrawingWidth,
			height:selectionDrawingHeight,
			rotation:0.0};
	}
	
	/**
	 * Returns the coord of the selection drawing, might be homothetic if Alt is pressed
	 * @param	eventData contains the drawing event data
	 * @return	the selection drawing coords
	 */
	private function getSelectionDrawingRegion(eventData:SelectionManagerEventData):Coords
	{
		//if Alt is pressed, return homothetic region
		if (eventData.keyboardState.useAlt == true)
		{
			return doGetHomotheticSelectionDrawingRegion(eventData);
		}
		else
		{
			return doGetSelectionDrawingRegion(eventData);
		}
	}
	
	/**
	 * Returns the x position of the transformed selection drawing based on the 
	 * mouse position
	 * @param	mousePosition the current coords of the mouse
	 * @return the x position of the transformed drawing region
	 */
	private function getSelectionDrawingX(mousePosition:Point):Int
	{
		if (mousePosition.x > _mouseStartPosition.x)
		{
			return _mouseStartPosition.x;
		}
		
		else
		{
			return mousePosition.x;
		}
	}
	
	/**
	 * Returns the y position of the transformed selection drawing based on the 
	 * mouse position
	 * @param	mousePosition the current coords of the mouse
	 * @return the y position of the transformed drawing region
	 */
	private function getSelectionDrawingY(mousePosition:Point):Int
	{
		if (mousePosition.y > _mouseStartPosition.y)
		{
			return _mouseStartPosition.y;
		}
		
		else
		{
			return mousePosition.y;
		}
	}
	
	/**
	 * Returns the width of the transformed selection drawing based on the 
	 * mouse position
	 * @param	mousePosition the current coords of the mouse
	 * @return the width of the transformed drawing region
	 */
	private function getSelectionDrawingWidth(mousePosition:Point):Int
	{
		if (mousePosition.x > _mouseStartPosition.x)
		{
			return mousePosition.x - _mouseStartPosition.x;
		}
		
		else
		{
			return _mouseStartPosition.x - mousePosition.x;
		}
	}
	
	/**
	 * Returns the height of the transformed selection drawing based on the 
	 * mouse position
	 * @param	mousePosition the current coords of the mouse
	 * @return the height of the transformed drawing region
	 */
	private function getSelectionDrawingHeight(mousePosition:Point):Int
	{
		if (mousePosition.y > _mouseStartPosition.y)
		{
			return mousePosition.y - _mouseStartPosition.y ;
		}
		
		else
		{
			return _mouseStartPosition.y - mousePosition.y;
		}
	}
	
	
}