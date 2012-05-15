//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.RectBorder;
import mx.skins.SkinElement;
import mx.core.ext.UIObjectExtensions;

class mx.skins.halo.ActivatorSkin extends RectBorder
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "ActivatorSkin";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.halo.ActivatorSkin;

/**
* name of this class
*/
	var className = "ActivatorSkin";

	var backgroundColorName = "buttonColor";

	var drawRoundRect:Function;

	function ActivatorSkin()
	{
	}

	function init():Void
	{
		super.init();
	}

	function size():Void
	{
		drawHaloRect(width,height);
	}

	function drawHaloRect(w:Number,h:Number):Void
	{
		var borderStyle = getStyle("borderStyle");
		var themeCol = getStyle("themeColor");

		clear();

		switch (borderStyle) {

			case "none": // up/disabled
			drawRoundRect( x,y,w,h,0,0xffffff,0);//Invisible hit area
			break;

			case "falsedown":
			drawRoundRect( x,y,w,h,0,0x919999,100);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,0,[0x333333,0xfcfcfc],100,-90,"radial");
			drawRoundRect( x+1,y+1,w-2,h-2,0,themeCol,50);
			drawRoundRect( x+3,y+3,w-6,h-6,0,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,0,themeCol,20);//face
			break;

			case "falserollover":
			drawRoundRect( x,y,w,h,0,0x919999,100);//OuterBorder
			drawRoundRect( x,y,w,h,0,themeCol,50);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,0,[0x333333,0xffffff],100,0,"radial");
			drawRoundRect( x+3,y+3,w-6,h-6,0,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,0,0xf8f8f8,100);//face
			break;
		}
	}

	static function classConstruct():Boolean
	{
		UIObjectExtensions.Extensions();
		_global.skinRegistry["ActivatorSkin"] = true;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIObjectExtensionsDependency = UIObjectExtensions;
}



