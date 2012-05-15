//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;

/**
* Base class for Borders
*
* - extends UIObject
* - Draws borders around objects
*
* Most implementations use RectBorder, but non-rectangular borders can use this
* class or subclass
*
* @tiptext
* @helpid 3321
*/
class mx.skins.Border extends UIObject
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "Border";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.Border;

/**
* name of this class
*/
	var	className:String = "Border";

/**
* @private
* index of border skin
*/
	var tagBorder:Number = 0;
/**
* @private
* instance names for border skin
*/
	var idNames:Array = new Array("border_mc");

	// styles supported here
	var borderStyle:String;

/**
* @private
* constructor
*/
	function Border()
	{
	}

/**
* @private
* init variables
*/
	function init(Void):Void
	{
		super.init();
	}
}

