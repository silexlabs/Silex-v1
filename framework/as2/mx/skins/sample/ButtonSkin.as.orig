//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.sample.RectBorder;
import mx.skins.SkinElement;
import mx.core.ext.UIObjectExtensions;

class mx.skins.sample.ButtonSkin extends RectBorder
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "ButtonSkin";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.sample.ButtonSkin;

/**
* name of this class
*/
	var className = "ButtonSkin";

	var backgroundColorName = "buttonColor";



	function ButtonSkin()
	{

	}

	function init():Void
	{
		super.init();
	}

	function size():Void
	{

		drawBorder();

	}



	static function classConstruct():Boolean
	{
		UIObjectExtensions.Extensions();
		_global.skinRegistry["ButtonSkin"] = true;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIObjectExtensionsDependency = UIObjectExtensions;
}



