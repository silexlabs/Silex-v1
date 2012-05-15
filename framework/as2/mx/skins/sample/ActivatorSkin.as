//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.RectBorder;
import mx.skins.SkinElement;
import mx.core.ext.UIObjectExtensions;

class mx.skins.sample.ActivatorSkin extends RectBorder
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
	static var symbolOwner:Object = mx.skins.sample.ActivatorSkin;

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
		drawRect(width,height);
	}

	function drawRect(w:Number,h:Number):Void
	{
		var borderStyle = getStyle("borderStyle");
		var buttonCol = getStyle("buttonColor");

		clear();

		switch (borderStyle) {

			case "none": // up/disabled
			drawRoundRect( x,y,w,h,0,0xffffff,0);//Invisible hit area
			break;

			case "falsedown":
			drawRoundRect( x,y,w,h,0,buttonCol,100);//face
			break;

			case "falserollover":
			drawRoundRect( x,y,w,h,0,buttonCol,100);//face
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



