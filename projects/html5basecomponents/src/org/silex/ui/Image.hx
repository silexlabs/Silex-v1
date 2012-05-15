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
*  This class implements the Image component in HTML5.
*/
class Image extends UiBase
{
	private var clickable : Bool;
	private var scale : Float;
	private var useHandCursor : Bool;
	private var mask : String;
	private var scaleMode : String;
	private var visibleFrame_bool : Bool;
	private var shadow : Bool;
	private var shadowOffsetX : Float;
	private var shadowOffsetY : Float;
	private var _focusrect : Bool;
	private var tabChildren : Bool;
	private var fadeInStep : Float;
	
	public function new() 
	{
		super();
	}
	
	public override function returnHTML()
	{
		if(this.url.split(".").pop().toLowerCase() != "swf")
		{
			return "<img style='width:" +this.width + "px;height:" + this.height +"px; margin-top:0px; vertical-align:top;' src='" + this.url+ "'></img>";
		} else
		{
			return '<object scale="exactfit" wmode="transparent" width="' + this.width + '" height="' + this.height + '">
			<param name="movie" value="' + url + '">
			<embed scale="exactfit" wmode="transparent" src="' + url + '" width="' + this.width + '" height="' + this.height + '">
			</embed>
			</object>';
		}
	}
}