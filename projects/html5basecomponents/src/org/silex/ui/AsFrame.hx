/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.ui;

/**
 * ...
 * @author Benjamin Dasnois
 */

/**
*  This class implements the AsFrame components in HTML5
*/
class AsFrame extends UiBase
{
	private var clickable : Bool;
	private var scale : Float;
	private var htmlText : String;
	private var embededObject : String;
	private var location : String;
	private var backgroundVisible : Bool;
	
	public function new() 
	{
		super();
	}
	
	public override function returnHTML()
	{
				return "<iframe frameborder='0' style='width:" +this.width + "px;height:" + this.height +"px;' src='" + this.location+ "'></iframe>";
	}
	
}