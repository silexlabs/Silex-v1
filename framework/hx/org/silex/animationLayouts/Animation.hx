/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.animationLayouts;

import flash.MovieClip;
/**
*  This class defines an Animation to be used by a Sequencer
*/
class Animation
{
	/**
	*  The current playing frame's number of the Animation
	*/
	public var _currentFrame : Int;
	
	/**
	*  The number of frames making the Animation
	*/
	public var _totalFrames : Int;
	
	/**
	*  Can the end of the animation be autodetected? Defaults to false
	*/
	public var endDetectable(default, null) : Bool;
	
	/**
	*  Triggered when the animation starts. Good place to set your handler for  onEnterFrame
	*/
	public function play(): Void
	{
	}
	
	public var _visible : Bool;
	
	public function new()
	{
		this.endDetectable = false;
	}
	
	public function stop()
	{}
}