/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.transformHandlers;
import org.silex.adminApi.selection.utils.Structures;

/**
 * A base class for transform handlers. A transform handler process a trandformation (translation, rotation, scaling...)
 * on an array of components and return an array containing the processed coords
 * @author Yannick DOMINGUEZ
 */
class TransformHandlerBase 
{
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * The array containg the selected components that will be transformed
	 */
	private var _selectedComponents:Array<ComponentCoordsProxy>;
	
	/**
	* The coords of the selection region when the transformation begins
	*/
	private var _selectionToolStartCoords:Coords;
	
	/**
	 * The position of the mouse when the transformation begins
	 */
	private var _mouseStartPosition:Point;
	
	/**
	 * The pivot point position when the transformation begins
	 */
	private var _pivotPointStartPosition:Point;

	/////////////////////////////////////
	// CONTRUCTOR
	////////////////////////////////////
	
	/**
	 * Stores the constructor parameters
	 * @param	selectionToolEventStartData the transformation event data
	 * @param	selectedComponents the selected components
	 */
	private function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		_selectedComponents = selectedComponents;
		_selectionToolStartCoords = selectionToolEventStartData.selectionRegionCoords;
		_mouseStartPosition = selectionToolEventStartData.mousePosition;
		_pivotPointStartPosition = selectionToolEventStartData.pivotPoint;
	}
	
	/////////////////////////////////////
	// PUBLIC METHODS
	////////////////////////////////////
	
	/**
	 * Abstract method. Process the selected components transformation and return an object containing
	 * all the transformed objects (selection region, components, pivot point
	 * @param	selectionEventData the data of the event dispatched by the uiManager
	 * @return contains the transformed data (selection region, components, pivot point)
	 */
	public function transform(selectionEventData:SelectionManagerEventData):TransformResult
	{
		return null;
	}
	
	/**
	 * Returns the transformed coords of the selection region
	 * @param	eventData the transformation event data
	 * @return the transformed selection region
	 */
	private function getSelectionRegionCoords(eventData:SelectionManagerEventData):Coords
	{
		return { x:_selectionToolStartCoords.x,
		y:_selectionToolStartCoords.y,
		width:_selectionToolStartCoords.width,
		height:_selectionToolStartCoords.height,
		rotation:_selectionToolStartCoords.rotation
		};
	}
	
	/**
	 * Returns the transformed pivot point
	 * @param	transformedSelectionRegion the transformed selection region used to retrieve the pivot point
	 * @return the transformed pivot point
	 */
	private function getPivotPoint(transformedSelectionRegion:Coords):Point
	{
		return { x:_pivotPointStartPosition.x, y:_pivotPointStartPosition.y };
	}
	

	
}