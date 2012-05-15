/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.utils;
import org.silex.adminApi.selection.utils.Enums;

/**
 * A utils class containing some structures used by the SelectionManager
 * @author Yannick DOMINGUEZ
 */

 /**
  * The coords of a component or selection region
  */
 typedef Coords = {
	 var x :Int;
	 var y :Int;
	 var width : Int;
	 var height : Int;
	 var rotation : Float;
 }
 
 /**
  * The coord data of a component, used to transform it's coord
  * and to retrieve the component with it's uid
  */
 typedef ComponentCoordsProxy = {
	 var componentCoords : Coords;
	 var componentUid : String;
 }
 
 /**
  * The data of a transformation, containing the transformed components
  * data, the transformed selection region and pivot point and the type of
  * the transformation
  */
 typedef TransformResult = {
	 var transformType:TransformTypes;
	 var transformedComponentsData : Array<ComponentCoordsProxy>;
	 var selectionRegionCoords:Coords;
	 var pivotPoint:Point;
	 
 }
 
 /**
  * A point in 2d space
  */
 typedef Point = {
	 var x : Int;
	 var y : Int;
 }
 
 /**
  * contains all the data necessary to update
  * a component property
  */
 typedef UpdatePropertyData = {
	 var propertyName:String;
	 var componentUid:String;
	 var value:Int;
 }
 
 /**
  * constains the required data for a selection manager event
  * plus an optionnal parameters dynamic object
  */
 typedef SelectionManagerEventData = {
	 var eventType:String;
	 var selectionRegionCoords:Coords;
	 var pivotPoint:Point;
	 var mousePosition:Point;
	 var keyboardState:KeyboardState;
	 var parameters:Dynamic;
 }
 
 /**
  * Determine, for all listened keyboard key, wether they are pressed
  * (true) or not (false)
  */
 typedef KeyboardState = {
	 var useShift:Bool;
	 var useCtrl:Bool;
	 var useAlt:Bool;
	 var useLeft:Bool;
	 var useRight:Bool;
	 var useDown:Bool;
	 var useUp:Bool;
 }
 
 /**
  * The data used when changing state, contains the name of the 
  * new state and an optionnal parameters object passed to the state when entering
  * it
  */
 typedef StateChangeData = {
	 var stateName:SelectionStates;
	 var stateInitData:Dynamic;
 }
 
 /**
  * When rotating, stores a rotated point and it's original point positions
  */
 typedef RotatedPoint = {
	 var originPoint:Point;
	 var rotatedPoint:Point;
 }
 
 /**
  * represent the bounds of a component
  */
 typedef ComponentBounds = {
	 var top:Int;
	 var bottom:Int;
	 var left:Int;
	 var right:Int;
 }
 

 
 
class Structures 
{

	public function new() 
	{
		
	}
	
}