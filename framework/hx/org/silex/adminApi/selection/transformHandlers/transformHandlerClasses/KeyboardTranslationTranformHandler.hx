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
import org.silex.adminApi.selection.utils.Enums;
import org.silex.adminApi.selection.components.ComponentsSelectionHelper;

/**
 * The keyboard translation transform handlers move the selected components on arrow keys press
 * @author Yannick DOMINGUEZ
 */
class KeyboardTranslationTranformHandler extends TransformHandlerBase
{
	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * Stores the x delta, representing the x difference
	 * between the selection region start x position and it's current position
	 */
	private var _xDelta:Int;
	
	/**
	 * Stores the y delta, representing the y diferrence
	 * between the seelection region start y position and it's current position
	 */
	private var _yDelta:Int;
	
	/////////////////////////////////////
	// CONTRUCTOR
	////////////////////////////////////
	
	/**
	 * Initialise the delta attributes
	 * @param	selectionToolEventStartData
	 * @param	selectedComponents
	 */
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
		_xDelta = 0;
		_yDelta = 0;
	}
	
	/////////////////////////////////////
	// OVERIDDEN METHODS
	////////////////////////////////////
	
	/**
	 * Process and return the translated selection region, along
	 * with each of the translated component data and the position of the pivot point
	 * @param	selectionEvent constains the data of the teansaltion event
	 * @return contains the translated selection region, pivot point and components
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		//get the selection region translated coords
		var selectionRegionCoords:Coords = getSelectionRegionCoords(selectionEvent);
	
		var transformedComponentsData:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		//for each component, translate it according to the translated selection region offset
		//with the start selection region coords
		var selectedComponentsLength:Int = _selectedComponents.length;
		for (i in 0...selectedComponentsLength)
		{
			var componentCoords:Coords = _selectedComponents[i].componentCoords;
			
			var componentCoords:Coords = { 
				x:componentCoords.x + (selectionRegionCoords.x - _selectionToolStartCoords.x), 
				y:componentCoords.y + (selectionRegionCoords.y - _selectionToolStartCoords.y), 
				width:componentCoords.width,
				height:componentCoords.height,
				rotation:componentCoords.rotation
				};
			
			var transformedComponentData:ComponentCoordsProxy = { componentCoords:componentCoords, componentUid:_selectedComponents[i].componentUid };
			transformedComponentsData.push(transformedComponentData);
		}
		
		return { 
			selectionRegionCoords:selectionRegionCoords,
			pivotPoint:getPivotPoint(selectionRegionCoords),
			transformedComponentsData:transformedComponentsData,
			transformType:KeyboardTranslationTransformType
		}
	}
	
	/**
	 * Update the x and y delta according to the pressed keyboard keys, then use them 
	 * to translate the selection region
	 * @param	eventData contains the keyboard translation event data
	 * @return the translated selection region coords
	 */
	override private function getSelectionRegionCoords(eventData:SelectionManagerEventData):Coords
	{
		checkKeyboard(eventData);
		return {
			x:_selectionToolStartCoords.x + _xDelta,
			y:_selectionToolStartCoords.y + _yDelta,
			width:_selectionToolStartCoords.width,
			height:_selectionToolStartCoords.height,
			rotation:_selectionToolStartCoords.rotation
		}
	}
	
	/**
	 * Check which keyboard keys are pressed and increment the x and y offsets
	 * accordingly
	 * @param	eventData contains the translation event data
	 */
	private function checkKeyboard(eventData:SelectionManagerEventData):Void
	{
		//default is 1 pixel at a time
		var offset:Int = 1;
		
		//it's 10 if Shift is pressed
		if (eventData.keyboardState.useShift == true)
		{
			offset = 10;
		}
		
		//and 100 if Ctrl is pressed
		if (eventData.keyboardState.useCtrl == true)
		{
			offset = 100;
		}
		
		//increment/decrement the deltas based on the pressed keys
		var keyboardState:KeyboardState = eventData.keyboardState;
		
		if (keyboardState.useRight == true)
		{
			_xDelta += offset;
		}
		
		if (keyboardState.useLeft == true)
		{
			_xDelta -= offset;
		}
		
		if (keyboardState.useUp == true)
		{
			_yDelta -= offset;
		}
		
		if (keyboardState.useDown == true)
		{
			_yDelta += offset;
		}
	}
	
	/**
	 * Return the updated position of the pivot point, relative to the translated selection region delta
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