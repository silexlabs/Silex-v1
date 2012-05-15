/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * Class controlling the scale handles. List constants for scale handle positions
 * @author Yannick DOMINGUEZ
 */
class org.silex.tools.selectionTool.ui.uis.uiComponents.ScaleHandle extends MovieClip
{
	/////////////////////**/*/*/*/*/*/*/
	// CONSTANTS
	////////////////////**/*/*/*/*/*/*/
	
	public static var SCALE_HANDLE_POSITION_TOP_LEFT:String = "scaleHandlePositionTopLeft";
	
	public static var SCALE_HANDLE_POSITION_TOP:String = "scaleHandlePositionTop";
	
	public static var SCALE_HANDLE_POSITION_TOP_RIGHT:String = "scaleHandlePositionTopRight";
		
	public static var SCALE_HANDLE_POSITION_RIGHT:String = "scaleHandlePositionRight";
	
	public static var SCALE_HANDLE_POSITION_BOTTOM_RIGHT:String = "scaleHandlePositionBottomRight";
	
	public static var SCALE_HANDLE_POSITION_BOTTOM:String = "scaleHandlePositionBottom";
	
	public static var SCALE_HANDLE_POSITION_BOTTOM_LEFT:String = "scaleHandlePositionBottomLeft";

	public static var SCALE_HANDLE_POSITION_LEFT:String = "scaleHandlePositionLeft";
	
	/////////////////////**/*/*/*/*/*/*/
	// ATTRIBUTES
	////////////////////**/*/*/*/*/*/*/
	
	/**
	 * Stores the position of the scale handle
	 */
	private var _handlePosition:String;
	
	/////////////////////**/*/*/*/*/*/*/
	// COSNTRUCTOR
	////////////////////**/*/*/*/*/*/*/
	
	public function ScaleHandle() 
	{
		
	}
	
	/////////////////////**/*/*/*/*/*/*/
	// GETTERS/SETTERS
	////////////////////**/*/*/*/*/*/*/
	
	public function get handlePosition():String 
	{
		return _handlePosition;
	}
	
	public function set handlePosition(value:String):Void 
	{
		_handlePosition = value;
	}
	
}