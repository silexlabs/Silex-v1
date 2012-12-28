/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.components;
import haxe.Log;
import org.silex.adminApi.selection.com.SilexAdminApiCommunication;
import org.silex.adminApi.selection.com.SilexApiCommunication;
import org.silex.adminApi.selection.utils.Structures;

/**
 * This class exposes static helper methods related to component selection.
 * @author Yannick DOMINGUEZ
 */

class ComponentsSelectionHelper 
{
	////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	private function new() 
	{
		
	}
	
	////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	////////////////////**/*/*/*/*/*/*/
		// SELECTION METHODS
		// get component from selection or vice-versa
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Returns the selection region formed by the currently selected components
	 * @param	selectedComponents the currently selected components coords
	 * @return  the coords of the selection region
	 */
	public static function getSelectionFromComponent(selectedComponents:Array<ComponentCoordsProxy>):Coords
	{
		//if no components are selected, returns an empty region
		if (selectedComponents.length == 0)
		{
			var nullSelectionRegion:Coords = null;
			return nullSelectionRegion;
		}

		//we set reference coordinate for our selectionRegion, each reference will be updated by selected component
		//when appropriate to retrieve the selection rectangle. For instance, the refTop is by default set to a value way below
		//the stage that will be overriden by the first component then all the subsequent component which are higher than this component
		//, thus we will find the higher component among the selected component and the at the same time, the top of the selection region
		var refTop:Int = 50000;
		var refLeft:Int = 50000;
		var refBottom:Int = -50000;
		var refRight:Int = -50000;
		
		//we loop in all the selected components
		var selectedComponentsLength:Int = selectedComponents.length;
		for (i in 0...selectedComponentsLength)
		{
			//we retrieve the bounds of the component
			var componentBounds:ComponentBounds = getComponentBounds(selectedComponents[i].componentCoords);
				
			//we override the reference values if the current
			//component values are more appropriate. For instance, for x
			//we are looking for the component with the smaller value
			//(the one placed the most to the left)
			if (componentBounds.left < refLeft)
			{
				refLeft = componentBounds.left;
			}
				
			if (componentBounds.top < refTop)
			{
				refTop = componentBounds.top;
			}
							
			if (componentBounds.bottom > refBottom)
			{
				refBottom = componentBounds.bottom;
			}
					
			if (componentBounds.right > refRight)
			{
				refRight = componentBounds.right;
			}
			
		}	
		//process the selection region coords
		var selectionRegionCoords:Coords = {
			x:refLeft,
			y:refTop,
			width : refRight - refLeft,
			height :  refBottom - refTop,
			rotation:0.0
		};
			
		//then we return them
		return selectionRegionCoords;
	}
	
	/**
	 * Retrieve the selectable components within the drawn selection Drawing region
	 * @param	selectionRegionCoord the drawn selection drawing coords
	 * @param	selectableComponents the array of components that can be selected
	 * @return  an array of components coords contained within the selection region
	 */
	public static function getComponentsFromSelection(selectionRegionCoord:Coords, selectableComponents:Array<ComponentCoordsProxy>):Array<ComponentCoordsProxy>
	{
		//the array that will be returned
		var componentsWithinSelectionRegion:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		
		//get the bounds of the drawn selection drawing
		var selectionRegionBounds:ComponentBounds = getComponentBounds(selectionRegionCoord);
		
		//we loop in the selectable components
		var selectableComponentsLength:Int = selectableComponents.length;
		for (i in 0...selectableComponentsLength)
		{
			//get the coords of the current component
			var componentCoords:Coords = selectableComponents[i].componentCoords;
			
			//get the bounds of the current component
			var componentBounds:ComponentBounds = getComponentBounds(componentCoords);
			
			
			//if the current component bounds are contained within the drawn selection
			//region bounds, we add it to the selection
			if (componentBounds.left > selectionRegionBounds.left)
			{
				if (componentBounds.right < selectionRegionBounds.right)
				{
					if (componentBounds.top > selectionRegionBounds.top )
					{
						if (componentBounds.bottom < selectionRegionBounds.bottom)
						{
							//push a copy of the component coords
							componentsWithinSelectionRegion.push( { componentCoords: {
								x:selectableComponents[i].componentCoords.x,
								y:selectableComponents[i].componentCoords.y,
								width:selectableComponents[i].componentCoords.width,
								height:selectableComponents[i].componentCoords.height,
								rotation:selectableComponents[i].componentCoords.rotation,
								},
								componentUid:selectableComponents[i].componentUid
							});
						}
					}
				}
			}
		}
		return componentsWithinSelectionRegion;
	}
	
	////////////////////**/*/*/*/*/*/*/
		// SCALING METHODS
		// Scale and unscale coords and points
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Scale the coords to fit with the properties value retrieved
	 * from SilexAdminApi
	 * @param	coords the coords to scale
	 * @return the scaled coords
	 */
	public static function scaleCoords(coords:Coords):Coords
	{
		var silexScaleX:Float = SilexApiCommunication.getInstance().getSilexXScale();
		var silexScaleY:Float = SilexApiCommunication.getInstance().getSilexYScale();
		
		coords.x -= SilexApiCommunication.getInstance().getSilexSceneBounds().left;
		coords.y -= SilexApiCommunication.getInstance().getSilexSceneBounds().top;
		coords.x =  Math.round(coords.x / silexScaleX);
		coords.y =  Math.round(coords.y / silexScaleY);
		coords.width = Math.round(coords.width / silexScaleX);
		coords.height = Math.round(coords.height / silexScaleY);
		
		return coords;
	}
	
	/**
	 * Scale the coords to the scale of the silex scene
	 * @param	coords the coords to unscale
	 * @return the unscaled coords
	 */
	public static function unscaleCoords(coords:Coords):Coords
	{
		var silexScaleX:Float = SilexApiCommunication.getInstance().getSilexXScale();
		var silexScaleY:Float = SilexApiCommunication.getInstance().getSilexYScale();
		
		coords.x = Math.round(coords.x * silexScaleX);
		coords.y = Math.round(coords.y * silexScaleY);
		coords.x +=  SilexApiCommunication.getInstance().getSilexSceneBounds().left;
		coords.y +=  SilexApiCommunication.getInstance().getSilexSceneBounds().top;
		coords.width = Math.round(coords.width * silexScaleX);
		coords.height = Math.round(coords.height * silexScaleY);
	
		return coords;
	}
	
	/**
	 * Scale the point to fit with the properties value retrieved
	 * from SilexAdminApi
	 * @param	point the point to scale
	 * @return the scaled point
	 */
	public static function scalePoint(point:Point):Point
	{
		var silexScaleX:Float = SilexApiCommunication.getInstance().getSilexXScale();
		var silexScaleY:Float = SilexApiCommunication.getInstance().getSilexYScale();
		
		point.x -= SilexApiCommunication.getInstance().getSilexSceneBounds().left;
		point.y -= SilexApiCommunication.getInstance().getSilexSceneBounds().top;
		point.x = Math.round(point.x / silexScaleX);
		point.y = Math.round(point.y / silexScaleY);
		
		return point;
	}
	
	/**
	 * Scale the point to the scale of the silex scene
	 * @param	point the point to unscale
	 * @return the unscaled point
	 */
	public static function unscalePoint(point:Point):Point
	{
		var silexScaleX:Float = SilexApiCommunication.getInstance().getSilexXScale();
		var silexScaleY:Float = SilexApiCommunication.getInstance().getSilexYScale();
		
		var newX:Int = point.x;
		newX = Math.round(newX * silexScaleX);
		newX += SilexApiCommunication.getInstance().getSilexSceneBounds().left;
		point.x = newX;
		
		var newY:Int = point.y;
		newY = Math.round(newY * silexScaleY);
		newY += SilexApiCommunication.getInstance().getSilexSceneBounds().top;
		point.y = newY;

		return point;
	}
	
	/**
	 * Scale all of the scalable data of a transformation event
	 * @param	data contains the unscaled selection region coords, mouse position, and pivot point
	 * @return the scaled event data
	 */
	public static function scaleSelectionManagerEventData(data:SelectionManagerEventData):SelectionManagerEventData
	{
		data.selectionRegionCoords = scaleCoords(data.selectionRegionCoords);
		
		data.mousePosition = scalePoint(data.mousePosition);
		
		data.pivotPoint = scalePoint(data.pivotPoint);
		
		return data;
	}
	
	////////////////////**/*/*/*/*/*/*/
		// ROTATION METHODS
		// Rotate coords and points
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Rotates the given coords (can be the selection region or a selected component) around the pivot point
	 * and returns the rotated coords
	 * @param	rotationAngle the desired absolut rotation angle
	 * @param	coords the coords to rotate
	 * @param  pivotPoint the center point of the rotation
	 * @return the rotated coords
	 */
	public static function getRotatedCoords(rotationAngle:Float, coords:Coords, pivotPoint:Point):Coords
	{
		
		//get each rotated points of the given coords
		var rotatedCoordsPoints:Array<RotatedPoint> = getRotatedCoordsPoints(coords, rotationAngle, pivotPoint);
		
		//we will determine the bounds of the coords
		var xMin:Int = 50000;
		var xMax:Int = -50000;
		var yMin:Int = 50000;
		var yMax:Int = -50000;
		
		//for each rotated point, we look for the bounds of the coords
		var rotatedCoordsPointsLength:Int = rotatedCoordsPoints.length;
		for (i in 0...rotatedCoordsPointsLength)
		{
			//get a reference to one of the rotated point
			var rotatedPoint:Point = rotatedCoordsPoints[i].rotatedPoint;
			
			//exemple : if the current point is greater than the current
			//xMax (the right bound of the coords), then it becomes the new xMax
			if (rotatedPoint.x > xMax )
			{
				xMax = rotatedPoint.x;
			}
			
			if (rotatedPoint.x < xMin)
			{
				xMin = rotatedPoint.x;
			}
			
			if (rotatedPoint.y > yMax)
			{
				yMax = rotatedPoint.y;
			}
							
			if (rotatedPoint.y < yMin)
			{
				yMin = rotatedPoint.y;
			}
		}
		
		//retrieve the x and y delta between the coords at the start of the rotation
		//and the rotated coords
		var xDelta:Int = rotatedCoordsPoints[3].originPoint.x - rotatedCoordsPoints[3].rotatedPoint.x;
		var yDelta:Int = rotatedCoordsPoints[3].originPoint.y - rotatedCoordsPoints[3].rotatedPoint.y;
		
		//the rotated coords : 
		//the x and y are equal to the coords at the start of the rotation + their delta
		//the width and height don't change during a rotation
		//the rotation is equal to the coords angle at the start of the rotation + the current rotation
		//the rotation is converted from rad to degree
		var rotatedCoords:Coords = { 
			x:coords.x - xDelta ,
			y:coords.y - yDelta,
			width:coords.width,
			height:coords.height,
			rotation:coords.rotation + ((rotationAngle) / ((Math.PI * 2) / 360))
		};
		
		//prevent negative rotartion angle
		if (rotatedCoords.rotation < 0)
		{
			rotatedCoords.rotation = 360 - Math.abs(rotatedCoords.rotation);
		}
		
		//prevent the rotation to be superior to 360°
		while (rotatedCoords.rotation > 360)
		{
			rotatedCoords.rotation -= 360;
		}
		
		return rotatedCoords;
	}
	
	/**
	 * Rotate each point of a coords according to the given angle
	 * @param	coords the coords to rotate
	 * @param	rotationAngle the angle of rotation
	 * @param   pivotPoint the center point of the rotation
	 * @return an array in which each item contains the origin and rotated points x and y
	 */
	private static function getRotatedCoordsPoints(coords:Coords, rotationAngle:Float, pivotPoint:Point):Array<RotatedPoint>
	{
		var points:Array<RotatedPoint> = new Array<RotatedPoint>();
		
		//for each point of the coords, get the origin (non rotated) point coords
		var point1:Point = {
			x : Math.round(coords.x + coords.width * Math.cos(coords.rotation * (Math.PI / 180))) ,
			y : Math.round(coords.y + coords.width * Math.sin(coords.rotation  * (Math.PI / 180)))
		};
		
		//then get the rotated point coord
		var rotatedPoint1:Point = getRotatedPoint(point1, rotationAngle, pivotPoint);
		
		
		var point2:Point = {
		x : Math.round(coords.x + coords.width * Math.cos(coords.rotation * (Math.PI / 180)) - coords.height * Math.sin(coords.rotation * (Math.PI / 180))),
		y : Math.round(coords.y + coords.height * Math.cos(coords.rotation * (Math.PI / 180)) + coords.width * Math.sin(coords.rotation * (Math.PI / 180)))
		};
		
		var rotatedPoint2:Point = getRotatedPoint(point2, rotationAngle, pivotPoint);
		
		
		var point3:Point = {
		x : Math.round(coords.x - coords.height * Math.sin(coords.rotation * (Math.PI / 180))),
		y : Math.round(coords.y + coords.height * Math.cos(coords.rotation * (Math.PI /  180)))
		};	
		
		
		var rotatedPoint3:Point = getRotatedPoint(point3, rotationAngle, pivotPoint);
		
		
		var point4:Point = {
			x: coords.x,
			y : coords.y
		};
		
		var rotatedPoint4:Point = getRotatedPoint(point4, rotationAngle, pivotPoint);
		
		
		points.push({originPoint: point1, rotatedPoint:rotatedPoint1});
		points.push({originPoint: point2, rotatedPoint:rotatedPoint2});
		points.push({originPoint: point3, rotatedPoint:rotatedPoint3});
		points.push({originPoint: point4, rotatedPoint:rotatedPoint4});
		
		return points;
		
	}
	
	/**
	 * Rotate a point along the  provided angle
	 * @param	point the point to rotate
	 * @param	angle the angle of the rotation
	 * @param   pivotPoint the center point of the rotation
	 * @return the rotated point
	 */
	private static function getRotatedPoint(point:Point, angle:Float, pivotPoint:Point):Point
	{
		//we first translate the origin point to make the pivot point
		//the origin of the rotation
		point.x -= pivotPoint.x;
		point.y -= pivotPoint.y;
		
		//we then rotate the point and store the rotated point
		var rotatedPoint:Point =  {
				x:Math.round((point.x * Math.cos(angle)) - ( point.y * Math.sin(angle))),
				y:Math.round((point.x  * Math.sin(angle)) + ((point.y) * Math.cos(angle)))
			};
		
		//we then translate back the rotated and origin point 
		//to the correct origin
		rotatedPoint.x += pivotPoint.x;
		rotatedPoint.y += pivotPoint.y;
		point.x += pivotPoint.x;
		point.y += pivotPoint.y;
		
		return rotatedPoint;
	}
	
	////////////////////**/*/*/*/*/*/*/
		// OTHER METHODS
		// because sometimes, you just don't 
		// know where to put methods
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * returns the bounds of a component
	 * @param	componentCoords the component in which we look for the bounds
	 * @return  the bounds of the component (top, left, right, bottom)  
	 */
	public static function getComponentBounds(componentCoords:Coords):ComponentBounds
	{
		//We retrieve each point of the component bounds
		var point1:Point = {
			x : Math.round(componentCoords.x + componentCoords.width * Math.cos(componentCoords.rotation * (Math.PI / 180))),
			y : Math.round(componentCoords.y + componentCoords.width * Math.sin(componentCoords.rotation * (Math.PI / 180)))
		};
		
		var point2:Point = {
		x : Math.round(componentCoords.x + componentCoords.width * Math.cos(componentCoords.rotation * (Math.PI / 180)) - componentCoords.height * Math.sin(componentCoords.rotation * (Math.PI / 180))),
		y : Math.round(componentCoords.y + componentCoords.height * Math.cos(componentCoords.rotation * (Math.PI / 180)) + componentCoords.width * Math.sin(componentCoords.rotation * (Math.PI / 180)))
		};
		
		var point3:Point = {
		x : Math.round(componentCoords.x - componentCoords.height * Math.sin(componentCoords.rotation * (Math.PI / 180))),
		y : Math.round(componentCoords.y + componentCoords.height * Math.cos(componentCoords.rotation * (Math.PI /  180)))
		};	
		
		var point4:Point = {
			x: componentCoords.x,
			y : componentCoords.y
		};
		
		//we stores all the points within an array of point
		var points:Array<Point> = new Array<Point>();
		points.push(point1);
		points.push(point2);
		points.push(point3);
		points.push(point4);
		
		var componentBounds:ComponentBounds = {
			left:0,
			right:0,
			top:0,
			bottom:0
			};
		
		var refTop:Int = 50000;
		var refLeft:Int = 50000;
		var refBottom:Int = -50000;
		var refRight:Int = -50000;
		
		//we then loop in each point and determine which
		//one is at the top, which bottom, left and right
		var pointsLength:Int = points.length;
		for (i in 0...pointsLength)
		{
			if (points[i].x < refLeft)
			{
				refLeft = points[i].x;
				componentBounds.left = points[i].x;
			}
			
			if (points[i].x > refRight)
			{
				refRight = points[i].x;
				componentBounds.right = points[i].x;
			}
			
			if (points[i].y < refTop)
			{
				refTop = points[i].y;
				componentBounds.top = points[i].y;
			}
			
			if (points[i].y > refBottom)
			{
				refBottom = points[i].y;
				componentBounds.bottom = points[i].y;
			}
			
		}
		
		return componentBounds;
	}
	
	
}