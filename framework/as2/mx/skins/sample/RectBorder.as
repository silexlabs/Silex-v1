//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.Border;
import mx.styles.CSSStyleDeclaration;
import mx.core.ext.UIObjectExtensions;

/**
* The border class for drawing rectangular borders.  Does not use skins, draws programmatically.
*
* @helpid 3331
* @tiptext The border class for drawing rectangular borders.
*/
class mx.skins.sample.RectBorder extends mx.skins.RectBorder
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "RectBorder";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.sample.RectBorder;

	// Version string
#include "../../core/ComponentVersion.as"

/**
* @private
* list of color style properties that affect this component
*/
	private var colorList:Object = { highlightColor: 0, borderColor: 0, buttonColor: 0, shadowColor: 0 };

/**
@private
* constructor
*/
	function RectBorder()
	{
	}

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
	function init(Void):Void
	{
		super.init();
	}

/**
* @private
* return the thickness of the border edges
* @return Object	top, bottom, left, right thickness in pixels
*/
	function getBorderMetrics(Void):Object
	{
		if (offset == undefined)
		{
			var b:String = getStyle(borderStyleName);
			offset = 0;
			if (b == "solid")
				offset = 1;
			else if (b == "inset" || b == "outset")
				offset = 2;
		}
		if (getStyle(borderStyleName) == "menuBorder" )
 		{
 			__borderMetrics = { left: 1, top: 1, right: 2, bottom:1 };
 			return __borderMetrics;
 		}

		return super.getBorderMetrics();
	}

/**
* @private
* draw the border, either 3d or 2d or nothing at all
*/
	function drawBorder(Void):Void
	{
		var z:CSSStyleDeclaration = _global.styles[className];
		if (z == undefined)
			z = _global.styles.RectBorder;
		var b:String = getStyle(borderStyleName);
		var c:Number = getStyle(borderColorName);
		if (c == undefined) c = z[borderColorName];
		var d:Number = getStyle(backgroundColorName);
		if (d == undefined) d = z[backgroundColorName];
		if (b != "none")
		{
			var f:Number = getStyle(shadowColorName);
			if (f == undefined) f = z[shadowColorName];
			var g:Number = getStyle(highlightColorName);
			if (g == undefined) g = z[highlightColorName];
			var h:Number = getStyle(buttonColorName);
			if (h == undefined) h = z[buttonColorName];
		}
		offset = 0;

		clear();

		_color = undefined;

		if (b == "none")
		{
		}

		else if (b == "inset" || b == "default" || b == "alert" || b == "falsedown" )
		{
			_color = colorList;
			offset = 2;
			draw3dBorder(h, f, g, c);

		}
		else if (b == "outset" || b == "falseup" || b == "falseover")
		{
			_color = colorList;
			offset = 2;
			draw3dBorder(c, h, f, g);

		}
		else if (b == "truerollover" || b == "truedown")
		{
			_color = colorList;
			offset = 2;
			draw3dBorder(h, f, g, c);

		}
		else //if ((b == "solid") || (b == undefined))
		{
			var w:Number = width;
			var h:Number = height;
			offset = 1;
			beginFill(c);
			drawRect(0,0,w,h);
			drawRect(1,1,w-1,h-1);
			endFill();
			_color = borderColorName;
		}

		var o:Number = offset;

		beginFill(d);
		drawRect(o,o,width-o,height-o);
		endFill();

	}

/**
* @private
* draw a 3d border
*/
	function draw3dBorder(c1:Number, c2:Number, c3:Number, c4:Number):Void
	{
		var w:Number = width;
		var h:Number = height;

		beginFill(c1);
		drawRect(0,0,w,h);
		drawRect(0,0,w-1,h-1);
		endFill();
		beginFill(c2);
		drawRect(0,0,w,h-1);
		drawRect(1,1,w,h-1);
		endFill();
		beginFill(c3);
		drawRect(1,1,w-1,h-1);
		drawRect(1,1,w-2,h-2);
		endFill();
		beginFill(c4);
		drawRect(1,1,w-1,h-2);
		drawRect(2,2,w-1,h-2);
		endFill();
	}
	static function classConstruct():Boolean
	{
		UIObjectExtensions.Extensions();
		_global.styles.rectBorderClass = RectBorder;
		_global.skinRegistry["RectBorder"] = true;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIObjectExtensionsDependency = UIObjectExtensions;

}
