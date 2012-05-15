/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * A custom event class listing all the event dispatched by the user interface
 * @author Yannick DOMINGUEZ
 */

class org.silex.tools.selectionTool.ui.event.UIEvent 
{
	
	/////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Dispatched when mouse is moved
	 */
	public static var MOUSE_EVENT_MOUSE_MOVED:String = "mouseEventMouseMoved";
	
	/**
	 * Dispatched when mouse is released
	 */
	public static var MOUSE_EVENT_MOUSE_UP:String = "mouseEventMouseUp";
	
	/**
	 * Dispatched when a keyboard key is pressed
	 */
	public static var KEYBOARD_EVENT_KEY_DOWN:String = "keyboardEventKeyDown";
	
	/**
	 * Dispatched when a keyboard key is released
	 */
	public static var KEYBOARD_EVENT_KEY_UP:String = "keyboardEventKeyUp";
	
	/**
	 * Dispatched when a scale handle is clicked
	 */
	public static var MOUSE_EVENT_SCALE_HANDLE_MOUSE_DOWN:String = "mouseEventScaleHandleMouseDown";
	
	/**
	 * Dispatched when a rotation handle is clicked
	 */
	public static var MOUSE_EVENT_ROTATION_HANDLE_MOUSE_DOWN:String = "mouseEventRotationHandleMouseDown";
	
	/**
	 * Dispathced when the pivot point is clicked
	 */
	public static var MOUSE_EVENT_PIVOT_POINT_MOUSE_DOWN:String = "mouseEventPivotPointMouseDown";
	
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * The type of the dispatched event
	 */
	public var type:String;

	/**
	 * The data of the event
	 */ 
	public var data:Object;
	
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function UIEvent(eventType:String, eventData:Object) 
	{
		this.type = eventType;
		this.data = eventData;
	}
	
}