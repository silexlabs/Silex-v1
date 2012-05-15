/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.ui.uis.uiComponents;
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;

/**
 * Exposes methods to process the 
 * position of the pivot point and constants for each of the pivot point
 * authorised positions
 * @author Yannick DOMINGUEZ
 */
class PivotPoint 
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	//The list of authorised pivot point positions
	
	public static var PIVOT_POINT_POSITION_TOP_LEFT:String = "pivotPointPositionTopLeft";
	
	public static var PIVOT_POINT_POSITION_TOP:String = "pivotPointPositionTop";
	
	public static var PIVOT_POINT_POSITION_TOP_RIGHT:String = "pivotPointPositionTopRight";
	
	public static var PIVOT_POINT_POSITION_RIGHT:String = "pivotPointPositionRight";
		
	public static var PIVOT_POINT_POSITION_BOTTOM_RIGHT:String = "pivotPointPositionBottomRight";
	
	public static var PIVOT_POINT_POSITION_BOTTOM:String = "pivotPointPositionBottom";
	
	public static var PIVOT_POINT_POSITION_BOTTOM_LEFT:String = "pivotPointPositionBottomLeft";
	
	public static var PIVOT_POINT_POSITION_LEFT:String = "pivotPointPositionLeft";
	
	public static var PIVOT_POINT_POSITION_CENTER:String = "pivotPointPositionCenter";
	
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function new() 
	{
		
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Return the pivot point position according to the passed position constant
	 * @param	pivotPointPosition  the pivot point position to move to 
	 * @param	selectionRegionCoords the current selection region coords
	 * @return  the pivot point position
	 */
	public static function getPivotPoint(pivotPointPosition:PivotPointPositions, selectionRegionCoords:Coords):Point
	{
		return switch(pivotPointPosition)
		{
			case TopLeft:
			return { x:selectionRegionCoords.x, y:selectionRegionCoords.y };
			
			case Top:
			return { x:selectionRegionCoords.x + Math.round((selectionRegionCoords.width / 2)), y:selectionRegionCoords.y };
			
			case TopRight:
			return { x:selectionRegionCoords.x + selectionRegionCoords.width, y:selectionRegionCoords.y };
			
			case Right:
			return { x:selectionRegionCoords.x + selectionRegionCoords.width, y:selectionRegionCoords.y + Math.round(selectionRegionCoords.height / 2) };
			
			case BottomRight:
			return { x:selectionRegionCoords.x + selectionRegionCoords.width, y:selectionRegionCoords.height + selectionRegionCoords.y };
			
			case Bottom:
			return { x:selectionRegionCoords.x + Math.round(selectionRegionCoords.width / 2), y: selectionRegionCoords.y + selectionRegionCoords.height };
			
			case BottomLeft:
			return { x:selectionRegionCoords.x, y:selectionRegionCoords.y + selectionRegionCoords.height};
			
			case Left:
			return { x:selectionRegionCoords.x, y:Math.round(selectionRegionCoords.height / 2) +selectionRegionCoords.y };
			
			case Center:
			return { x:selectionRegionCoords.x + Math.round(selectionRegionCoords.width / 2), y:Math.round(selectionRegionCoords.height / 2) + selectionRegionCoords.y };
		}
	}
	
}