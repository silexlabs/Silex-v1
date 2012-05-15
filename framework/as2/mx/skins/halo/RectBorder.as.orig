//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.Border;
import mx.styles.CSSStyleDeclaration;
import mx.core.ext.UIObjectExtensions;

class mx.skins.halo.RectBorder extends mx.skins.RectBorder
{

	static var symbolName:String = "RectBorder";

	static var symbolOwner:Object = mx.skins.halo.RectBorder;

	// Version string
#include "../../core/ComponentVersion.as"

	var borderCapColorName:String = "borderCapColor";
	var shadowCapColorName:String = "shadowCapColor";

	private var colorList:Object = { highlightColor: 0, borderColor: 0, buttonColor: 0, shadowColor: 0, borderCapColor: 0, shadowCapColor: 0};

	// a look up table for the offsets
	private var borderWidths:Object = { none: 0, solid: 1, inset: 2, outset: 2, alert: 3, dropDown: 2, menuBorder: 2, comboNonEdit: 2 };

	var drawRoundRect:Function;

/**
@private
* constructor
*/
	function RectBorder()
	{

	}

/**
@private
* variable initialization
*/
	function init(Void):Void
	{
		borderWidths["default"] = 3;
		super.init();
	}

/**
* return the thickness of the border edges
* @return Object	top, bottom, left, right thickness in pixels
*/
	function getBorderMetrics(Void):Object
	{
		//@@ add support for "custom" style type here when we support it
		if (offset == undefined)
		{
			var b:String = getStyle(borderStyleName);
			offset = borderWidths[b];
		}

 		if (getStyle(borderStyleName) == "default" || getStyle(borderStyleName) == "alert")
 		{
 			__borderMetrics = { left: 3, top: 1, right: 3, bottom:3 };
 			return __borderMetrics;
 		}

		return super.getBorderMetrics();
	}

/**
@private
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
		var e:String = getStyle("backgroundImage");

		if (b != "none")
		{

			var f:Number = getStyle(shadowColorName);
			if (f == undefined) f = z[shadowColorName];
			var g:Number = getStyle(highlightColorName);
			if (g == undefined) g = z[highlightColorName];
			var h:Number = getStyle(buttonColorName);
			if (h == undefined) h = z[buttonColorName];
			var i:Number = getStyle(borderCapColorName);
			if (i == undefined) i = z[borderCapColorName];
			var j:Number = getStyle(shadowCapColorName);
			if (j == undefined) j = z[shadowCapColorName];
		}
		offset = borderWidths[b];
		var o = offset;
		var ww:Number = width;
		var hh:Number = height;

		clear();

		_color = undefined;

		if (b == "none")
		{
		}

		else if (b == "inset")
		{
			_color = colorList;
			draw3dBorder(i,h,c,g,f,j);
		}
		else if (b == "outset")
		{
			_color = colorList;
			draw3dBorder(i,c,h,f,g,j);
		}
		else if (b == "alert")
		{
			var themeCol = getStyle("themeColor");
			drawRoundRect( 0,5,ww,hh-5,5,0x5e5e5e,10);//OuterBorder
			drawRoundRect( 1,4,ww-2,hh-5,4,[0x5e5e5e,0x5e5e5e],10,0,"radial");
			drawRoundRect( 2,0,ww-4,hh-2,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( 2,0,ww-4,hh-2,3,themeCol,50);
			drawRoundRect( 3,1,ww-6,hh-4,2,0xffffff,100);//face
		}
		else if (b == "default")
		{
			drawRoundRect( 0,5,ww,hh-5,{tl:5,tr:5,br:0,bl:0},0x5e5e5e,10);//OuterBorder
			drawRoundRect( 1,4,ww-2,hh-5,{tl:4,tr:4,br:0,bl:0},[0x5e5e5e,0x5e5e5e],10,0,"radial");
			drawRoundRect( 2,0,ww-4,hh-2,{tl:3,tr:3,br:0,bl:0},[0xc4cccc,0xb4bcbc],100,0,"radial");
			drawRoundRect( 3,1,ww-6,hh-4,{tl:2,tr:2,br:0,bl:0},0xffffff,100);//face
		}
		else if (b == "dropDown")
		{
			drawRoundRect( 0,0,ww+1,hh,{tl:4,tr:0,br:0,bl:4},[0xcacaca,0x787878],100,-10,"linear");
			drawRoundRect( 1,1,ww-1,hh-2,{tl:3,tr:0,br:0,bl:3},0xffffff,100);
		}
		else if (b == "menuBorder")
		{
			var themeCol = getStyle("themeColor");
			drawRoundRect( 4,4,ww-2,hh-3,0,[0x5e5e5e,0x5e5e5e],10,0,"radial");//dropShadow
			drawRoundRect( 4,4,ww-1,hh-2,0,0x5e5e5e,10);//dropShadow
			drawRoundRect( 0,0,ww+1,hh,0,[0x000000,0xdadada],100,250,"linear")//base color
			drawRoundRect( 0,0,ww+1,hh,0,themeCol,50); // themeColor
			drawRoundRect( 2,2,ww-3,hh-4,0,0xffffff,100);
		}
		else if (b == "comboNonEdit")
		{
		}

		else //if ((b == "solid") || (b == undefined))
		{
			beginFill(c);
			drawRect(0,0,ww,hh);
			drawRect(1,1,ww-1,hh-1);
			endFill();
			_color = borderColorName;
		}

		if (d != undefined)
		{
			beginFill(d);
			drawRect(o,o,width-o,height-o);
			endFill();
		}
	}

/**
@private
* draw a 3d border
*/

	function draw3dBorder(c1:Number, c2:Number, c3:Number, c4:Number,c5:Number,c6:Number):Void
	{
		var w:Number = width;
		var h:Number = height;

		beginFill(c1);
		drawRect(0,0,w,h);
		drawRect(1,0,w-1,h);
		endFill();
		//outsidetop
		beginFill(c2);
		drawRect(1,0,w-1,1);
		endFill();
		//outsidebottom
		beginFill(c3);
		drawRect(1,h -1,w-1,h);
		endFill();
		//insidetop
		beginFill(c4);
		drawRect(1,1,w-1,2);
		endFill();
		//insidebottom
		beginFill(c5);
		drawRect(1,h-2,w-1,h-1);
		endFill();
		//insidesides
		beginFill(c6);
		drawRect(1,2,w-1,h-2);
		drawRect(2,2,w-2,h-2);
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
