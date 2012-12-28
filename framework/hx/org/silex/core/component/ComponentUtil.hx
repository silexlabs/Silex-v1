/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.core.component;

import flash.MovieClip;
/**
*  some utility functions for manipulating components
*  */
class ComponentUtil{
	
	/*for sizing: 3 cases:
	- simple movie clips: use _width and _height
	- uicomponents. detected by seeing if there is a setSize function. If so use setSize
	- uibase : use width and height setters, because setSize somehow doesn't work. Difficult to detect uicomponent from uibase, 
	so do both cases together
	*/
	public static function sizeComponent(component:MovieClip, width:Float, height:Float):Void{
		//flash.Lib.trace("sizeComponent" + component.playerName + ", " + width + ", " + height + component.setSize);
		if (component.setSize != null) {
			component.setSize(width, height);
			component.width = width;
			component.height = height;
		}else {
			//flash.Lib.trace("sizeComponent, no setSize : " + component + ", width : " + width);
			component._width = width;
			//flash.Lib.trace("component._width : " + component._width);
			component._height = height;
		}
	}	
	
}