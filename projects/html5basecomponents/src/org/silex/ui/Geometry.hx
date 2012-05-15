/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * ...
 * @author yannick
 */

package org.silex.ui;

class Geometry extends UiBase
{
	private var TLcornerRadius:Float;
	private var TRcornerRadius:Float;
	private var BRcornerRadius:Float;
	private var BLcornerRadius:Float;
	private var bgColor:Int;
	private var bgAlpha:Int;
	private var fill:String;
	private var border:Bool;
	private var borderColor:Int;
	private var borderAlpha:Int;
	private var lineThickness:Float;
	private var gradientColors:Array<Int>;
	private var gradientRatio:Array<Int>;
	private var gradientAlpha:Array<Int>;
	private var gradientRotation:Int;
	private var shape:String;
	private var dropShadow:Bool;
	private var dropShadowAlpha:Float;
	private var dropShadowColor:Int;
	private var dropShadowDistance:Int;
	private var dropShadowAngle:Int;
	private var dropShadowBlurX:Int;
	private var dropShadowBlurY:Int;
	private var bitmapFillUrl:String;
	private var bitmapFillRepeat:Bool;
	private var jointStyle:String;
	private var capsStyle:String;
	
	public function new() 
	{
		super();
	}
	
	public override function returnHTML()
	{
		
		
		var aleaCanvasName:String = "geomCanvas" + Std.string(Math.round(Math.random() * 1000));
		var res:String = "<canvas id='" + aleaCanvasName + "' width='" + this.width + "' height='" + this.height + "'>";
		res += "</canvas>";
		res += "<script type='text/javascript'>";
		res += "drawShape('";
		res += this.shape + "','";
		res += aleaCanvasName + "',";
		res += this.width + ",";
		res += this.height + ",";
		res += "["+TLcornerRadius+","+TRcornerRadius+","+BRcornerRadius+","+BLcornerRadius+"]" + ",'";
		res += this.fill + "','";
		res += getHexColor(this.bgColor) + "',";
		res += this.bgAlpha + ",";
		res += getGradientColors() + ",";
		res += getGradientAlphas() + ",";
		res += getGradientRatio() + ",";
		res += this.gradientRotation + ",";
		res += this.lineThickness + ",'";
		res += this.jointStyle + "','";
		res += this.capsStyle + "','";
		res += getHexColor(borderColor) + "',";
		res += this.borderAlpha + ",";
		res += getBool(border) + ",";
		res += getBool(dropShadow) + ",";
		res += this.getDropShadowOffsetX() + ",";
		res += this.getDropShadowOffsetY() + ",";
		res += this.dropShadowBlurX + ",'";
		res += getHexColor(dropShadowColor) + "',";
		res += this.dropShadowAlpha + ",'";
		res += this.bitmapFillUrl + "',";
		res += getBool(bitmapFillRepeat) + ")";
		res += "</script>";
		
		
		return  res;
	}
	
	private function getGradientColors():String
	{
		var res:String = "[";
		if (gradientColors != null)
		{
			for (i in 0...gradientColors.length)
			{
				res += "'" + getHexColor(gradientColors[i]) + "'";
				if (i < gradientColors.length-1)
				{
					res += ",";
				}
			}
		}
		
		res += "]";
		
		return res;
	}
	
	private function getGradientAlphas():String
	{
		var res:String = "[";
		if (gradientAlpha != null)
		{
			for (i in 0...gradientAlpha.length)
			{
				res += gradientAlpha[i] ;
				if (i < gradientAlpha.length-1)
				{
					res += ",";
				}
			}
		}
		
		res += "]";
		
		return res;
	}
	
	private function getGradientRatio():String
	{
		var res:String = "[";
		if (gradientRatio != null)
		{
			for (i in 0...gradientRatio.length)
			{
				res += gradientRatio[i] ;
				if (i < gradientRatio.length-1)
				{
					res += ",";
				}
			}
		}
		
		res += "]";
		
		return res;
	}
	
	private function getHexColor(color:Int):String
	{
		var hexColor:String = StringTools.hex(color);
		
		while (hexColor.length < 6)
		{
			hexColor = "0" + hexColor;
		}
		
		return "#"+hexColor;
	}
	
	private function getDropShadowOffsetX():Int
	{
		return Math.round(Math.cos(dropShadowAngle / 180 * Math.PI) * dropShadowDistance);
	}
	
	private function getDropShadowOffsetY():Int
	{
		return Math.round(Math.sin(dropShadowAngle / 180 * Math.PI) * dropShadowDistance);
	}
	
	private function getBool(value:Bool):String
	{
		if (value == true)
		{
			return "true";
		}
		else
		{
			return "false";
		}
	}
	
}