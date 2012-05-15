/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.silex.core.Api;
import org.silex.core.Utils;
/**
 * Manages the mouse cursor when the user interacts with the SelectionTool, display different cursor based
 * on context
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.utils.MouseCursorManager
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	//lists all the possible mouse cursors
	
	public static var MOUSE_CURSOR_OVER_COMPONENT:String = "overComponent";
	
	public static var MOUSE_CURSOR_OVER_SELECTION:String = "overSelection";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_BR:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_BL:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_TR:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_TL:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_R:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_L:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_T:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_SCALE_HANDLE_B:String = "overScaleHandle";
	
	public static var MOUSE_CURSOR_OVER_ROTATION_HANDLE_BR:String = "overRotationHandle";
	
	public static var MOUSE_CURSOR_OVER_ROTATION_HANDLE_BL:String = "overRotationHandleBL";
	
	public static var MOUSE_CURSOR_OVER_ROTATION_HANDLE_TR:String = "overRotationHandleTR";
	
	public static var MOUSE_CURSOR_OVER_ROTATION_HANDLE_TL:String = "overRotationHandleTL";
	
	public static var MOUSE_CURSOR_DEFAULT:String = "defaultState";
	
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * a reference to the movie clip containing
	 * all the mouse cursors asset, one per frame
	 */
	public var mouseCursors:MovieClip;
	
	/**
	 * Listens to the mouse move event to update the position
	 * of the mouse cursor
	 */
	private var _mouseListener:Object;
	
	/**
	 * Stores the name of the current mouse cursor
	 */
	private var _currentMouseCursor:String;
	
	/////////////////////**/*/*/*/*/*/*/
	// CONSTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function MouseCursorManager()
	{
		init();
	}
	
	
	/////////////////////**/*/*/*/*/*/*/
	// PUBLIC METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Set the mouse cursor, by showing the custom mouse cursors movieclip
	 * and displaying it at the frame corresponding to the targeted mouse cursor.
	 * If the default mouse cursor must be displayed, hides the custom mouse cursor and
	 * shows the default system mouse cursor
	 * @param	mousecursor the target mouse cursor name
	 */
	public function setMouseCursor(mousecursor:String):Void
	{
		_currentMouseCursor = mousecursor;
		switch (mousecursor)
		{
			case MOUSE_CURSOR_DEFAULT:
			Mouse.show();
			mouseCursors._visible = false;
			mouseCursors._rotation = 0;
			break;
			
			case MOUSE_CURSOR_OVER_COMPONENT:
			case MOUSE_CURSOR_OVER_SELECTION:
			Mouse.hide();
			mouseCursors.gotoAndStop(mousecursor);
			mouseCursors._visible = true;
			mouseCursors._rotation = 0;
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_BR:
			setRotationMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_BL:
			setRotationMouseCursor(90);
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_TR:
			setRotationMouseCursor(-90);
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_TL:
			setRotationMouseCursor(180);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_BR:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_BL:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_TL:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_TR:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_T:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_B:
			setScaleMouseCursor(90);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_L:
			setScaleMouseCursor(0);
			break;
			
			case MOUSE_CURSOR_OVER_SCALE_HANDLE_R:
			setScaleMouseCursor(0);
			break;
			
			default:
			Mouse.show();
			mouseCursors._visible = false;
			setRotationMouseCursor(0);
			break;
			
		}
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// PRIVATE METHODS
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * init th mouse cursor manager, hides the custom 
	 * mouse cursors and listens for mouse move events to update
	 * the position of the cursor
	 */
	private function init():Void
	{
		var silexApi:Api = _global.getSilex();
		
		mouseCursors._visible = false;
		mouseCursors.stop();
		
		_mouseListener = new Object();
		_mouseListener.onMouseMove = Utils.createDelegate(this, onMouseMove);
		_currentMouseCursor = MOUSE_CURSOR_DEFAULT;
		Mouse.addListener(_mouseListener);
		
	}
	
	/**
	 * updates the position of the mouse cursor on mouse move
	 */
	private function onMouseMove():Void
	{
		refreshMouseCursor();
	}
	
	/**
	 * Refresh rthe position of the cursor based on the actual
	 * mouse position and may apply an offset for some of the
	 * custom mouse cursors (useful when they are rotated)
	 */
	private function refreshMouseCursor():Void
	{
		var mouseCursorXOffset:Number = 0;
		var mouseCursorYOffset:Number = 0;
		
		switch(_currentMouseCursor)
		{
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_TL:
			mouseCursorXOffset = mouseCursors._width;
			mouseCursorYOffset = mouseCursors._height;
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_TR:
			mouseCursorYOffset = mouseCursors._height;
			break;
			
			case MOUSE_CURSOR_OVER_ROTATION_HANDLE_BL:
			mouseCursorXOffset = mouseCursors._width;
			break;
		}
		
		mouseCursors._x = _xmouse + mouseCursorXOffset;
		mouseCursors._y = _ymouse + mouseCursorYOffset;
	}
	
	/**
	 * Set the scale mouse cursor and rotate it depending on the hovered handle
	 * @param	rotation the angle to rotate the asset to
	 */
	private function setScaleMouseCursor(rotation:Number):Void
	{
		Mouse.hide();
		mouseCursors.gotoAndStop(MOUSE_CURSOR_OVER_SCALE_HANDLE_BL);
		mouseCursors._visible = true;
		mouseCursors._rotation = rotation;
	}
	
	/**
	 * Set the rotation mouse cursor and rotate it depending on the hovered handle
	 * @param	rotation the angle to rotate the asset to
	 */
	private function setRotationMouseCursor(rotation:Number):Void
	{
		Mouse.hide();
		mouseCursors.gotoAndStop(MOUSE_CURSOR_OVER_ROTATION_HANDLE_BR);
		refreshMouseCursor();
		mouseCursors._visible = true;
		mouseCursors._rotation = rotation;
	}
	
}