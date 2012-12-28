/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/** This component holds information about a list row and is needed by oof lists. 
 * If you use an oof list in flash, this component must be in your library.
 * It would be nice to eliminate this class, but at the moment it's still necessary.
 * Historically this class inherits from mx.core.UIComponent, but since 12/10 this creates issues, so copy the necessary bits here. A.S.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.lists.ListRow extends MovieClip{
	var itemIndex:Number = 0;
	var cells:Array = new Array();
	
	// these hold the actual values for the getter-setters
	var __width:Number;
	var __height:Number;	
	
	
	/**
	 * width of object
	 */
	function get width():Number
	{
		return __width;
	}
	
	/**
	 * height of object
	 */
	function get height():Number
	{
		return __height;
	}

	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		var oldWidth:Number = __width;
		var oldHeight:Number = __height;
		
		__width = w;
		__height = h;
	}

	
}