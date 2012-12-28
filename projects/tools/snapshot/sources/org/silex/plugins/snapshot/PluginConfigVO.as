/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * Define the PluginConfig class which contains all plugin specific parameters
 * @author Raphael Harmel
 * @date 2011-03-10
 */

class org.silex.plugins.snapshot.PluginConfigVO extends Object
{
	/**
	 * SnapShotTool plugin specific parameters
	 */
	public var layoutDepth:Number;
	public var imageType:String;
	public var width:Number;
	public var height:Number;
	public var xPosition:Number;
	public var yPosition:Number;
	/**
	 * Website specific specific parameters
	 */
	public var layoutStageWidth:Number;
	public var layoutStageHeight:Number;
	
}