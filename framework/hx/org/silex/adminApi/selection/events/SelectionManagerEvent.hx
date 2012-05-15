/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.selection.events;
import org.silex.adminApi.selection.utils.Structures;

/**
 * A custom event class listing all the event dispatched by the uiManager
 * (the view of the selectionManager)
 * @author Yannick DOMINGUEZ
 */
class SelectionManagerEvent 
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Dispatched when the user starts drawing a selection region
	 */
	public inline static var SELECTION_REGION_START_DRAWING:String = "selectionRegionStartDrawing";
	
	/**
	 * Dispatched when the user is drawing a selection region
	 */
	public inline static var SELECTION_REGION_DRAWING:String = "selectionRegionDrawing";
	
	/**
	 * Dispatched when the user stops drawing a selection region
	 */
	public inline static var SELECTION_REGION_STOP_DRAWING:String = "selectionRegionStopDrawing";
	
	/**
	 * Dispatched when the user starts translating one/many component(s)
	 */
	public inline static var SELECTION_START_TRANSLATION:String = "selectionStartTranslation";
	
	/**
	 * Dispatched when the user is translating one/many component(s)
	 */
	public inline static var SELECTION_TRANSLATING:String = "selectionTranslating";
	
	/**
	 * Dispatched when the user stops translating one/many component(s)
	 */
	public inline static var SELECTION_STOP_TRANSLATING:String = "selectionStopTranslating";
	
	/**
	 * Dispatched when the user starts translating one/many component(s) with the keyboard arrows
	 */
	public inline static var SELECTION_START_KEYBOARD_TRANSLATION:String = "selectionStartKeyboardTranslation";
	
	/**
	 * Dispatched when the user is translating one/many component(s) with the keyboard arrows
	 */
	public inline static var SELECTION_KEYBOARD_TRANSLATING:String = "selectionKeyboardTranslating";
	
	/**
	 * Dispatched when the user stops translating one/many component(s) with the keyboard arrows
	 */
	public inline static var SELECTION_STOP_KEYBOARD_TRANSLATING:String = "selectionStopKeyboardTranslating";
	
	/**
	 * Dispatched when the user starts rotating one/many component(s)
	 */
	public inline static var SELECTION_START_ROTATING:String = "selectionStartRotating";
	
	/**
	 * Dispatched when the user is rotating one/many component(s)
	 */
	public inline static var SELECTION_ROTATING:String = "selectionRotating";
	
	/**
	 * Dispatched when the user stops rotating one/many component(s)
	 */
	public inline static var SELECTION_STOP_ROTATING:String = "selectionStopRotating";
	
	/**
	 * Dispatched when the user starts scaling one/many component(s)
	 */
	public inline static var SELECTION_START_SCALING:String = "selectionStartScaling";
	
	/**
	 * Dispatched when the user is scaling one/many component(s)
	 */
	public inline static var SELECTION_SCALING:String = "selectionScaling";
	
	/**
	 * Dispatched when the user stops scaling one/many component(s)
	 */
	public inline static var SELECTION_STOP_SCALING:String = "selectionStopScaling";
	
	/**
	 * Dispatched when the user starts translating the pivot point
	*/
	public inline static var SELECTION_START_PIVOT_TRANSLATION:String = "selectionStartPivotTranslation";
	
	/**
	 * Dispatched when the user is translating the pivot point
	 */
	public inline static var SELECTION_TRANSLATING_PIVOT:String = "selectionTranslatingPivot";
	
	/**
	 * Dispatched when the user stops translating the pivot point
	 */
	public inline static var SELECTION_STOP_TRANSLATING_PIVOT:String = "selectionStopTranslatingPivot";
	
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The type of the dispatched event
	 */
	public var type:String;
	
	/**
	 * The target name (name of the target for the SilexAdminApi)
	 */
	public var targetName:String;
	
	/**
	 * The data of the event
	 */ 
	public var data:SelectionManagerEventData;
	 
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function new(eventType:String, eventTargetName:String, eventData:SelectionManagerEventData) 
	{
		this.type = eventType;
		this.targetName = eventTargetName;
		this.data = eventData;
	}
	
}