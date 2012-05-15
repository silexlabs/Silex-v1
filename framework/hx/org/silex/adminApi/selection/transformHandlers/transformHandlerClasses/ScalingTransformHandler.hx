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
import org.silex.adminApi.selection.utils.Structures;
import org.silex.adminApi.selection.utils.Enums;
import org.silex.adminApi.selection.ui.uis.uiComponents.ScaleHandle;

/**
 * Proces the scaling of one or many components
 * @author Yannick DOMINGUEZ
 */

class ScalingTransformHandler extends TransformHandlerBase
{

	/////////////////////////////////////
	// ATTRIBUTES
	////////////////////////////////////
	
	/**
	 * The position of the handle oposite to the clicked one
	 * (ex: if the user click on the bottom right handle, the oposite
	 * one is the top left)
	 */
	private var _oppositeHandlePosition:Point;
	
	/**
	 * The name of the clicked handle
	 */
	private var _scaleHandlePositionName:String;
	
	/**
	 * The position of the clicked handle
	 */
	private var _scaleHandleStartPosition:Point;
	
	/////////////////////////////////////
	// CONSTRUCTOR
	////////////////////////////////////
	
	/**
	 * Stores the variable specific to this transformation in the classes attributes
	 * @param	selectionToolEventStartData
	 * @param	selectedComponents
	 */
	public function new(selectionToolEventStartData:SelectionManagerEventData, selectedComponents:Array<ComponentCoordsProxy>) 
	{
		super(selectionToolEventStartData, selectedComponents);
		_oppositeHandlePosition = selectionToolEventStartData.parameters.opositeHandlePosition;
		_scaleHandlePositionName = selectionToolEventStartData.parameters.scaleHandlePositionName;
		_scaleHandleStartPosition = selectionToolEventStartData.parameters.scaleHandlePosition;
	}
	
	/**
	 * Process the scale of the selection region, the selected components and the pivot point
	 * @param	selectionEvent
	 * @return
	 */
	override public function transform(selectionEvent:SelectionManagerEventData):TransformResult
	{
		var transformConstrain:Coords = getTransformConstrain(selectionEvent);
		var scaledSelectionRegion:Coords = getScaledSelectionRegion(selectionEvent, transformConstrain);
		
		var transformedComponentsData:Array<ComponentCoordsProxy> = new Array<ComponentCoordsProxy>();
		var selectedComponentsLength:Int = _selectedComponents.length;
		for (i in 0...selectedComponentsLength)
		{
		
			var componentCoords:Coords = _selectedComponents[i].componentCoords;
			var scaledComponentCoords:Coords = getScaledCoords(componentCoords, selectionEvent);
			
			var componentBounds:ComponentBounds = ComponentsSelectionHelper.getComponentBounds(componentCoords);
			var componentBoundsCoords:Coords = {
				x:componentBounds.left,
				y:componentBounds.top,
				width:componentBounds.right - componentBounds.left,
				height:componentBounds.bottom - componentBounds.top,
				rotation:0.0
			};
			
			componentBoundsCoords = getScaledCoords(componentBoundsCoords, selectionEvent);
			
			
			
			// handle 90° symetry: transform back after computing for 0<r<90
			// 45° case
//			var rotation90Correction : Float = 0.0;
			
			// mod 360
//			scaledComponentCoords.rotation = scaledComponentCoords.rotation % 360;
			
/*			// det quarter
			if (scaledComponentCoords.rotation > 270)
			{
			}
			else if (scaledComponentCoords.rotation > 180)
			{
			}
			else if (scaledComponentCoords.rotation > 90)
			{
				rotation90Correction = 90;
	//			scaledComponentCoords = ComponentsSelectionHelper.getRotatedCoords(rotation90Correction, scaledComponentCoords, {x : componentBoundsCoords.x + Math.round(componentBoundsCoords.width / 2), y : componentBoundsCoords.y + Math.round(componentBoundsCoords.height / 2)});
	//			componentBoundsCoords = ComponentsSelectionHelper.getRotatedCoords(rotation90Correction, componentBoundsCoords, {x : componentBoundsCoords.x + Math.round(componentBoundsCoords.width / 2), y : componentBoundsCoords.y + Math.round(componentBoundsCoords.height / 2)});
	
				scaledComponentCoords.rotation = scaledComponentCoords.rotation - rotation90Correction;
			}
*/			
			
			scaledComponentCoords = fitCoordsWithinBounds(scaledComponentCoords, componentBoundsCoords);
			
			
			// back to the original quarter
/*			scaledComponentCoords.rotation = scaledComponentCoords.rotation + rotation90Correction;
			
			
			// det quarter
			if (scaledComponentCoords.rotation > 270)
			{
			}
			else if (scaledComponentCoords.rotation > 180)
			{
			}
			else if (scaledComponentCoords.rotation > 90)
			{
	//			scaledComponentCoords.y = componentBoundsCoords.y + scaledComponentCoords.height * Math.round(Math.cos((scaledComponentCoords.rotation - 90)*(Math.PI/180))) - componentBoundsCoords.height;
				scaledComponentCoords.x = componentBoundsCoords.x + componentBoundsCoords.width;
				var tmp = scaledComponentCoords.width;
				scaledComponentCoords.width = scaledComponentCoords.height;
				scaledComponentCoords.height = tmp;
			}
				*/
				

//			scaledComponentCoords = componentBoundsCoords;
			var transformedComponentData:ComponentCoordsProxy = { componentCoords:scaledComponentCoords, componentUid:_selectedComponents[i].componentUid };
			transformedComponentsData.push(transformedComponentData);
		}
		
		var transformResult:TransformResult = { 
			selectionRegionCoords:scaledSelectionRegion,
			transformedComponentsData:transformedComponentsData,
			pivotPoint:getTranslatedPivotPoint(selectionEvent),
			transformType:ScalingTransformType
			};
		return transformResult;
	}
	
	/**
	 * Process the constrain zone of the transformation as Silex component can't be reversed, we need
	 * to restrict the transformation around the scale center
	 * @param	eventData contains the data of the scaling event
	 * @return the coords allowed for this transformation
	 */
	private function getTransformConstrain(eventData:SelectionManagerEventData):Coords
	{
		//get the scale center
		var pivotCenter:Point = getScaleCenter(eventData);
		
		
		return switch(_scaleHandlePositionName) {
			
			case ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM_RIGHT:
				var constrainWidth:Int;
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					constrainWidth = -10000;
				}
				
				else
				{
					constrainWidth = 10000;
				}
				
				var constrainHeight:Int;
				if (pivotCenter.y > _scaleHandleStartPosition.y)
				{
					constrainHeight = -10000;
				}
				
				else
				{
					constrainHeight = 10000;
				}
				
				return { x:pivotCenter.x, y:pivotCenter.y, width:constrainWidth, height:constrainHeight, rotation:null };
				
			case ScaleHandle.SCALE_HANDLE_POSITION_TOP:
				if (pivotCenter.y < _scaleHandleStartPosition.y)
				{
					 return { x:pivotCenter.x, y:pivotCenter.y, width:10000, height:10000, rotation:null };
				}
				
				else
				{
					return { x:pivotCenter.x, y:-10000, width:10000, height:pivotCenter.y + 10000, rotation:null };
				}
				
			default:
				return { x:10000, y:10000, width:10000, height:10000, rotation:null };
			
			case ScaleHandle.SCALE_HANDLE_POSITION_LEFT:
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					return { x:-10000, y:pivotCenter.y, width:pivotCenter.x + 10000, height:1, rotation:null };
				}
				
				else
				{
					return { x:pivotCenter.x, y:pivotCenter.y, width:10000, height:1, rotation:null };
				}

			case ScaleHandle.SCALE_HANDLE_POSITION_RIGHT:
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					return { x:-10000, y:pivotCenter.y, width:pivotCenter.x + 10000, height:1, rotation:null };
				}
				
				else
				{
					return { x:pivotCenter.x, y:pivotCenter.y, width:10000, height:1, rotation:null };
				}
			
			case ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM:
				if (pivotCenter.y < _scaleHandleStartPosition.y)
				{
					 return { x:pivotCenter.x, y:pivotCenter.y, width:10000, height:10000, rotation:null };
				}
				
				else
				{
					return { x:pivotCenter.x, y:-10000, width:10000, height:pivotCenter.y + 10000, rotation:null };
				}
	
				
			case ScaleHandle.SCALE_HANDLE_POSITION_TOP_LEFT:
				var constrainWidth:Int;
				var constrainX:Int;
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					constrainWidth = pivotCenter.x + 10000;
					constrainX = -10000;
				}
				
				else
				{
					constrainWidth = 10000;
					constrainX = pivotCenter.x;
				}
				
				var constrainHeight:Int;
				var constrainY:Int;
				if (pivotCenter.y > _scaleHandleStartPosition.y)
				{
					constrainHeight = pivotCenter.y +10000;
					constrainY = -10000;
				}
				
				else
				{
					constrainHeight = 10000;
					constrainY = pivotCenter.y;
				}
				
				return { x:constrainX, y:constrainY, width:constrainWidth, height:constrainHeight, rotation:null };
		
				
			case ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM_LEFT:
				var constrainWidth:Int;
				var constrainX:Int;
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					constrainWidth = pivotCenter.x + 10000;
					constrainX = -10000;
				}
				
				else
				{
					constrainWidth = 10000;
					constrainX = pivotCenter.x;
				}
				
				var constrainHeight:Int;
				if (pivotCenter.y > _scaleHandleStartPosition.y)
				{
					constrainHeight = -10000;
				}
				
				else
				{
					constrainHeight = 10000;
				}
				
				return { x:constrainX, y:pivotCenter.y, width:constrainWidth, height:constrainHeight, rotation:null };

			case ScaleHandle.SCALE_HANDLE_POSITION_TOP_RIGHT:
				var constrainWidth:Int;
				if (pivotCenter.x > _scaleHandleStartPosition.x)
				{
					constrainWidth = -10000;
				}
				
				else
				{
					constrainWidth = 10000;
				}
				
				var constrainHeight:Int;
				var constrainY:Int;
				if (pivotCenter.y > _scaleHandleStartPosition.y)
				{
					constrainHeight = pivotCenter.y +10000;
					constrainY = -10000;
				}
				
				else
				{
					constrainHeight = 10000;
					constrainY = pivotCenter.y;
				}
				
				return { x:pivotCenter.x, y:constrainY, width:constrainWidth, height:constrainHeight, rotation:null };
	
		}
	}
	
	/**
	 * Returned the scaled pivot point, it doesn't move if it is the center of the scale
	 * @param	selectionEvent the data of the scale event
	 * @return the scaled pivot point
	 */
	private function getTranslatedPivotPoint(selectionEvent:SelectionManagerEventData):Point
	{
		return { x:Math.round(_pivotPointStartPosition.x * getXScale(selectionEvent) + getXDelta(selectionEvent))  ,
		y:Math.round(_pivotPointStartPosition.y * getYScale(selectionEvent)+ getYDelta(selectionEvent))  };
	}
	
	/**
	 * return the center of the scale, can be the oposite handle or the pivot point depending on the key pressed on
	 * the keyboard
	 * @param	eventData contains the scale event data
	 * @return the scale center position
	 */
	private function getScaleCenter(eventData:SelectionManagerEventData):Point
	{
		if (eventData.keyboardState.useAlt == true)
		{
			return _pivotPointStartPosition;
		}
		
		else
		{
			return _oppositeHandlePosition;
		}
	}
	
	/**
	 * Process the scaled coords of the selection region
	 * @param	eventData contains the scale event data
	 * @param	transformConstrains the coords within which the transformed selection region must be contained
	 * @return the transformed selection region coords
	 */
	private function getScaledSelectionRegion(eventData:SelectionManagerEventData, transformConstrains:Coords):Coords
	{
		
		var mouseCoords:Point = eventData.mousePosition;
		
		//first check if the mouse is within the constrain zone and correct
		//it's position if it isn't
		if (mouseCoords.x < transformConstrains.x)
		{
			mouseCoords.x = transformConstrains.x;
		}
		
		else if (mouseCoords.x > transformConstrains.x + transformConstrains.width)
		{
			mouseCoords.x = transformConstrains.x + transformConstrains.width;
		}
		
		if (mouseCoords.y < transformConstrains.y)
		{
			mouseCoords.y = transformConstrains.y;
		}
		
		else if (mouseCoords.y > transformConstrains.y + transformConstrains.height)
		{
			mouseCoords.y = transformConstrains.y + transformConstrains.height;
		}
		
		//scale the selection region coords
		var scaledCoords:Coords = getScaledCoords(_selectionToolStartCoords, eventData);
			 
		return scaledCoords;
	}
	
	private function getScaledCoords(coords:Coords, eventData:SelectionManagerEventData):Coords
	{
			var scaledWidth:Int = Math.round(coords.width * getXScale(eventData));
			var scaledHeight:Int = Math.round(coords.height * getYScale(eventData));
			
			var scaledX:Int = Math.round((coords.x * getXScale(eventData) + getXDelta(eventData)   ));
			var scaledY:Int = Math.round((coords.y * getYScale(eventData) + getYDelta(eventData) ));
			
			
			return {
			x:scaledX,
			y:scaledY,
			width:scaledWidth,
			height:scaledHeight,
			rotation:coords.rotation
		};	 
	}
	
	/** 
	 * rotation of the component, keep initial rotation except for 45° which is impossible
	 * size of the component, use the formula
	 * l = ((Lcos(r)) - (Hsin(r)) / (pow2(cos(r)) - pow2(sin(r)))
	 * h = ((Hcos(r)) - (Lsin(r)) / (pow2(cos(r)) - pow2(sin(r)))
	 * position of the component, use the formula
	 * x = hsin(r)
	 * y = 0
	 */
	private function fitCoordsWithinBounds(componentCoord : Coords, componentBounds : Coords):Coords
	{
		// **
		// rotation of the component, keep initial rotation except for 45° which is impossible
		// size of the component, use the formula
		// l = ((Lcos(r)) - (Hsin(r)) / (pow2(cos(r)) - pow2(sin(r)))
		// h = ((Hcos(r)) - (Lsin(r)) / (pow2(cos(r)) - pow2(sin(r)))
		// position of the component, use the formula
		// x = hsin(r)
		// y = 0
		var l:Float;
		var h:Float;
		
		// to do
		// 90° symetry: transform back after computing for 0<r<90
		// 45° case
		var newComponentCoord : Coords = normalizeComponentCoordsBeforeTransform(componentCoord, componentBounds);
		var componentWidth : Int = newComponentCoord.width;
		var componentHeight : Int = newComponentCoord.height;
		var desiredRotation : Float = newComponentCoord.rotation;
	
		
		// compute needed cos and sin
		var cosR:Float = Math.cos(desiredRotation*(Math.PI/180));
		var sinR:Float = Math.sin(desiredRotation*(Math.PI/180));
		var cosPow2R:Float = cosR * cosR;
		var sinPow2R:Float = sinR * sinR;
		
		// compute the denominators and handle the 0 cases
		var denom:Float = cosPow2R - sinPow2R;
		
		// compute width and height the component
		if (denom == 0)
		{
			l = componentWidth;
			h = componentHeight;
		}
		else
		{
			l = ((componentBounds.width * cosR) - (componentBounds.height * sinR)) / denom;
			h = ((componentBounds.height * cosR) - (componentBounds.width * sinR)) / denom;
		}
		
		// compute top left corner of the component
		var x:Float = h * sinR;
		var y:Float = 0; 
		
		// limit to positive values (to do ??)
		if (l <= 0) 
		{
			l = 0;
			h = Math.sqrt((componentBounds.width * componentBounds.width) + (componentBounds.height * componentBounds.height));
			x = componentBounds.width;
			y = 0;
		}
		if (h <= 0)
		{
			h = 0;
			l = Math.sqrt((componentBounds.width * componentBounds.width) + (componentBounds.height * componentBounds.height));
			x = 0;
			y = 0;
		}

		// build the result object
		var resCoord:Coords = {
			x : Math.round(x),
			y : Math.round(y),
			width : Math.round(l),
			height : Math.round(h),
			rotation : desiredRotation
		};

		resCoord = undoNormalizeAfterTransform(resCoord, componentCoord, componentBounds);
		
		// convert into the bounding box coordinate system
		resCoord.x += componentBounds.x;
		resCoord.y += componentBounds.y;

		return resCoord;
	}
	/**
	 * apply a rotation to the component coords so that 0<r<90
	 * @param	componentCoords
	 * @return	coords of the component with a rotation in [0,90[
	 */
	private function normalizeComponentCoordsBeforeTransform(componentCoords : Coords, componentBounds : Coords) : Coords
	{
		var newComponentCoord : Coords =  {
			x : componentCoords.x,
			y : componentCoords.y,
			width : componentCoords.width,
			height : componentCoords.height,
			rotation : componentCoords.rotation
		};
		newComponentCoord.rotation = newComponentCoord.rotation % 90;
		return newComponentCoord;
	}
	/**
	 * transform back after computing for 0<r<90
	 * this transformation is not only a rotation, the origin (x,y) and the size are to be changed also, according to the rotation
	 * the rectangle position and size should not change visually, only the rotation
	 * in case of an initial rotation in [0,90[, the origin and dimensions are unchanged (top left corner) 
	 * in case of an initial rotation in [90,180[, the origin is the top right corner and dimensions are to be switched (width becomes height and vise versa)
	 * in case of an initial rotation in [180,270[, the origin is the bottom right corner and dimensions are unchanged 
	 * in case of an initial rotation in [270,0[, the origin is the bottom left corner and dimensions are to be switched (width becomes height and vise versa)
	 * @param	finalComponentCoords
	 * @param	initialComponentCoords
	 * @return	the component, back with the right rotation
	 */
	private function undoNormalizeAfterTransform(finalComponentCoords : Coords, initialComponentCoords : Coords, componentBounds : Coords) : Coords
	{
		// are we in the case of a 0 height or width ?
		// in this case, rotation is set so that the component is the diagonal of the bounding box
		if (finalComponentCoords.width == 0)
		{
			// keep the element visible			
			finalComponentCoords.width = 1;
			// compute diagonal
			var diagonal:Float = Math.sqrt((componentBounds.width * componentBounds.width) + (componentBounds.height * componentBounds.height));
			if (diagonal != 0)
				finalComponentCoords.rotation = (Math.asin(componentBounds.width / diagonal) * 180 / Math.PI);
			else
				finalComponentCoords.rotation = initialComponentCoords.rotation;
		}
		else if (finalComponentCoords.height == 0)
		{
			// keep the element visible			
			finalComponentCoords.height = 1;
			finalComponentCoords.rotation = Math.atan(componentBounds.height / componentBounds.width) * 180 / Math.PI;
		}
		else
		{
			// reset the rotation, 
			finalComponentCoords.rotation = initialComponentCoords.rotation;
			
			if (finalComponentCoords.rotation < 0) finalComponentCoords.rotation += 360;
			if (finalComponentCoords.rotation >= 360) finalComponentCoords.rotation -= 360;
			
			// used in the computing
			var rotationInRadian : Float = finalComponentCoords.rotation * (Math.PI / 180);
			var tmpWidth : Int;
	
			// in case of an initial rotation in [270,0[, the origin is the bottom left corner and dimensions are to be switched (width becomes height and vise versa)
			if (initialComponentCoords.rotation >= 270)
			{
				// switch dimentions
				tmpWidth = finalComponentCoords.width;
				finalComponentCoords.width = finalComponentCoords.height;
				finalComponentCoords.height = tmpWidth;
				
				// rotate corner position
				finalComponentCoords.x = finalComponentCoords.x - Math.round(finalComponentCoords.width * Math.cos(rotationInRadian));
				finalComponentCoords.y = finalComponentCoords.y - Math.round(finalComponentCoords.width * Math.sin(rotationInRadian));
				
			}
			// in case of an initial rotation in [180,270[, the origin is the bottom right corner and dimensions are unchanged 
			else if (initialComponentCoords.rotation >= 180)
			{
				// rotate corner position
				finalComponentCoords.x = componentBounds.width - finalComponentCoords.x;
				finalComponentCoords.y = componentBounds.height - finalComponentCoords.y;
			}
			// in case of an initial rotation in [90,180[, the origin is the top right corner and dimensions are to be switched (width becomes height and vise versa)
			else if (initialComponentCoords.rotation >= 90)
			{
				// switch dimentions
				tmpWidth = finalComponentCoords.width;
				finalComponentCoords.width = finalComponentCoords.height;
				finalComponentCoords.height = tmpWidth;
				
				// rotate corner position
				finalComponentCoords.x = finalComponentCoords.x + Math.round(finalComponentCoords.height * Math.sin(rotationInRadian));
				finalComponentCoords.y = finalComponentCoords.y - Math.round(finalComponentCoords.height * Math.cos(rotationInRadian));
			}
			// in case of an initial rotation in [0,90[, the origin and dimensions are unchanged (top left corner) 
			else { }
		}
		// return the modified component coords
		return finalComponentCoords;
	}
	
	/**
	 * Return the X scale of the scaling, might be homothetic if Shift is pressed
	 * @param	eventData the scale event data
	 * @return the x scale
	 */
	private function getXScale(eventData:SelectionManagerEventData):Float
	{
		if (eventData.keyboardState.useShift == true)
		{
			return getHomotethicScale(eventData);
		}
		else
		{
			return doGetXScale(eventData);
		}
	}
	
	/**
	 * Returns the non homothetic x scale
	 * @param	eventData the scale event data
	 * @return the non-homothetic x scale
	 */
	private function doGetXScale(eventData:SelectionManagerEventData):Float
	{
		var mouseCoords:Point = eventData.mousePosition;
		var scaleCenter:Point = getScaleCenter(eventData);
		
		var xScale:Float;
		switch(_scaleHandlePositionName)
		{
			case ScaleHandle.SCALE_HANDLE_POSITION_TOP,
			ScaleHandle.SCALE_HANDLE_POSITION_BOTTOM:
			if (eventData.keyboardState.useShift == true)
			{
				xScale = 0;
			}
			else
			{
				xScale = 1;
			}
			
			default:
			if ( mouseCoords.x > scaleCenter.x)
			{
				xScale = (mouseCoords.x - scaleCenter.x  ) / (_selectionToolStartCoords.width - (scaleCenter.x - _oppositeHandlePosition.x));
			}
		
			else
			{
				xScale = (scaleCenter.x - mouseCoords.x ) / (_selectionToolStartCoords.width + (scaleCenter.x - _oppositeHandlePosition.x));
			}
		}
		
		return xScale ;
	}
	
	/**
	 * Return the Y scale of the scaling, might be homothetic if Shift is pressed
	 * @param	eventData the scale event data
	 * @return the y scale
	 */
	private function getYScale(eventData:SelectionManagerEventData):Float
	{
		if (eventData.keyboardState.useShift == true)
		{
			return getHomotethicScale(eventData);
		}
		else
		{
			return doGetYScale(eventData);
		}
		
	}
	
	/**
	 * Returns the non homothetic y scale
	 * @param	eventData the scale event data
	 * @return the non-homothetic y scale
	 */
	private function doGetYScale(eventData:SelectionManagerEventData):Float
	{
		var mouseCoords:Point = eventData.mousePosition;
		var scaleCenter:Point = getScaleCenter(eventData);
		
		
		var yScale:Float;
		switch(_scaleHandlePositionName)
		{
			case ScaleHandle.SCALE_HANDLE_POSITION_LEFT,
			ScaleHandle.SCALE_HANDLE_POSITION_RIGHT:
			if (eventData.keyboardState.useShift == true)
			{
				yScale = 0;
			}
			else
			{
				yScale = 1;
			}
		
			default:
			if (mouseCoords.y > scaleCenter.y)
			{
				yScale = (mouseCoords.y - scaleCenter.y ) / (_selectionToolStartCoords.height - (scaleCenter.y - _oppositeHandlePosition.y));
			}
			
			else
			{
				yScale = (scaleCenter.y - mouseCoords.y  ) / (_selectionToolStartCoords.height + (scaleCenter.y - _oppositeHandlePosition.y));
			}
			
		}
		
		return yScale;
	}
	
	/**
	 * Return the homothethic scale, the homothethic scale
	 * is the biggest scale among x and y scale
	 * @param	eventData the scale event data
	 * @return the homothetic scale
	 */
	private function getHomotethicScale(eventData:SelectionManagerEventData):Float
	{
		var xScale:Float = doGetXScale(eventData);
		var yScale:Float = doGetYScale(eventData);
		
		if (xScale > yScale)
		{
			return xScale;
		}
		else
		{
			return yScale;
		}
	}
	
	/**
	 * Return the x delta between the selection region start x position and it's scaled x position
	 * @param	eventData the scale event data
	 * @return the x delta
	 */
	private function getXDelta(eventData:SelectionManagerEventData):Int
	{
		var deltaX:Int = Math.round(getScaleCenter(eventData).x - (getScaleCenter(eventData).x * getXScale(eventData)));
		return deltaX;
	}
	
	/**
	 * Return the y delta between the selection region start y position and it's scaled y position
	 * @param	eventData the scale event data
	 * @return the y delta
	 */
	private function getYDelta(eventData:SelectionManagerEventData):Int
	{
		var deltaY:Int = Math.round(getScaleCenter(eventData).y - (getScaleCenter(eventData).y * getYScale(eventData)));
		return deltaY;
	}
	
}