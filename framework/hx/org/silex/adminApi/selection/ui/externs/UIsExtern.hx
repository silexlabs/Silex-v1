/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.externs;
import org.silex.adminApi.selection.utils.Structures;

/**
 * an extern class wrapping the ui components (can be as AS2/AS3 or JS)
 */
@:native("UIs") extern class UIsExtern
{
	public function new() : Void;
	
	/**
	 * Draws the selection region with the given coords
	 * @param	selectionRegionCoords the coords to use to draw the selection region
	 */
	public function setSelectionRegion(selectionRegionCoords:Coords) : Void;
	
	/**
	 * Returns the coords of the selection region
	 * @return the x,y,width,height, rotation of the selection region
	 */
	public function getSelectionRegionCoords():Coords;
	
	/**
	 * Hides the selection region
	 */
	public function unsetSelectionRegion():Void;
	
	/**
	 * Shows the selection drawing (the zone drawn when the user clicks on the background and moves the mouse)
	 */
	public function showSelectionDrawing():Void;
	
	/**
	 * set the size and position of the selection drawing
	 * @param	coords the coords of the selection drawing 
	 */
	public function setSelectionDrawing(coords:Coords):Void;
	
	/**
	 * Hides the selection drawing
	 */
	public function hideSelectionDrawing():Void;
	
	/**
	 * Add a listener on the ui components (comes from EventDispatcher inherited by UIs)
	 * @param	eventType the type of the listened event
	 * @param	callBack callback called when the event is dispatched
	 */
	public function addEventListener(eventType:String, callBack: Dynamic->Void) : Void;
	
	/**
	 * Removes a listener on the ui components (comes from EventDispatcher inherited by UIs)
	 * @param	eventType the type of the listened event to remove
	 * @param	callBack callback called when the event is dispatched to remove
	 */
	public function removeEventListener(eventType:String, callBack: Dynamic->Void) : Void;

	/**
	 * Draws the highlight region around the highligted components
	 * @param	highlightedComponentsCoords the coords of the highlighted components
	 */
	public function setHighlightedComponents(highlightedComponentsCoords:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * Hides the region around the highligted components
	 */
	public function unsetHighlightedComponents():Void;
	
	/**
	 * set the component place holders above the editable components which will dispatches
	 * UIevent
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function setEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void;
	
	
	/**
	 * update the component place holders coords 
	 * @param	editableComponentsCoords the coords of the editable components
	 */
	public function updateEditableComponents(editableComponentsCoords:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * remove all the component place holders 
	 */
	public function unsetEditableComponents():Void;
	
	/**
	 * set the component place holders above the non editable components which will prevent the default
	 * behaviour of the components when in selection mode
	 * @param	nonEditableComponentsCoords the coords of the nonEditable components
	 */
	public function setNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * update the components place holders coords 
	 * @param	nonEditableComponentsCoords the coords of the editable components
	 */
	public function updateNonEditableComponents(nonEditableComponentsCoords:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * remove all the components place holders 
	 */
	public function unsetNonEditableComponents():Void;
	
	/**
	 * place the pivot point of the ui components
	 * @param	pivotPoint the coords of the pivot point
	 */
	public function setPivotPoint(pivotPoint:Point):Void;
	
	/**
	 * Return the position of the pivot point
	 * @return the current x and y of the pivot point
	 */
	public function getPivotPoint():Point;
	
	/**
	 * set the visual asset around the selected components
	 * @param	selectedComponents the array of selected components coords
	 */
	public function setSelectedComponents(selectedComponents:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * remove the visual assets around the selected components
	 */
	public function unsetSelectedComponents():Void;
	
	/**
	 * update the visual asset around the selected components
	 * @param	selectedComponents the array of selected components coords
	 */
	public function updateSelectedComponents(selectedComponents:Array<ComponentCoordsProxy>):Void;
	
	/**
	 * Return the currently pressed keys on the keyboard
	 * @return a bool for each listned keys (Shift, Ctrl, Alt, arrows)
	 */
	public function getKeyboardState():KeyboardState;
	
	/**
	 * Return the position of the mouse
	 * @return the current x and y of the mouse pointer
	 */
	public function getMousePosition():Point;
	
	/**
	 * Hides the scale and rotation handles
	 */
	public function hideHandles():Void;
	
	/**
	 * Shows the scale and rotation handles
	 */
	public function showHandles():Void;
	
	/**
	 * Set a custom mouse cursor
	 * @param	mouseCursor the name of the target mouse cursor
	 */
	public function setMouseCursor(mouseCursor:String):Void;

}
