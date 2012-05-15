//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
* The class for skin elements.  SkinElements support a common API for sizing and positioning
* If you do not have any other special needs just register your skins as skin elements.  If
* you do have your own class, register that class anyway otherwise it will get re-registered as
* a skin element and your class code will not be executed.  This is essentially UIObject without
* events, style API, and child object management.
*
* @helpid 3329
* @tiptext The class for all skin elements
*/
class mx.skins.SkinElement extends MovieClip
{
	// mixins
	var width:Number;
	var height:Number;
	var top:Number;
	var visible:Boolean;

/**
* All library assets that want to participate in our resizing and recoloring schemes
* need to be SkinElements or UIObjects.  If you are not a SkinElement you must register here.
* Otherwise, you will be a SkinElement automatically
* @param name Symbol name of object
* @param className Name of Class that supports the object
*/
	static function registerElement(name:String, className:Function):Void
	{
		Object.registerClass(name, (className == undefined) ? SkinElement : className);
		_global.skinRegistry[name] = true;
	}
/**
* @see mx.core.UIObject
*/
	function __set__visible(visible:Boolean):Void
	{
		_visible = visible;
	}

/**
* @see mx.core.UIObject
*/
	function move(x:Number, y:Number):Void
	{
		_x = x;
		_y = y;
	}

/**
* @see mx.core.UIObject
*/
	function setSize(w:Number, h:Number):Void
	{
		_width = w;
		_height = h;
	}
}
