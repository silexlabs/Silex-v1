//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.Border;
import mx.styles.CSSStyleDeclaration;

/**
* The abstract border class for drawing rectangular borders.
*
* @helpid 3328
* @tiptext The abstract border class for drawing rectangular borders.
*/
class mx.skins.RectBorder extends Border
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
	static var symbolOwner:Object = mx.skins.RectBorder;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var	className:String = "RectBorder";

/**
* @private
* name of style property for the borderStyle this class
*/
	var borderStyleName:String = "borderStyle";
/**
* @private
* name of style property for the black edge in a border
*/
	var borderColorName:String = "borderColor";
/**
* @private
* name of style property for the 3d inset shadow in a border
*/
	var shadowColorName:String = "shadowColor";
/**
* @private
* name of style property for the 3d outset highlight in a border
*/
	var highlightColorName:String = "highlightColor";
/**
* @private
* name of style property for the 3d outside edge in a border
*/
	var buttonColorName:String = "buttonColor";
/**
* @private
* name of style property for the background fill of a border
*/
	var backgroundColorName:String = "backgroundColor";

/**
* @private
* since all sides of these borders are the same width, we store it once.
*/
	var offset:Number;

/**
* @private
* internal object that contains the thickness of each edge of the border
*/
	var __borderMetrics:Object;

/**
@private
* constructor
*/
	function RectBorder()
	{
	}

/**
* width of object
* Read-Only:  use setSize() to change.
*/
	function get width():Number
	{
		return __width;
	}

/**
* height of object
* Read-Only:  use setSize() to change.
*/
	function get height():Number
	{
		return __height;
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
* draw handler.  No assets to load so just calls size()
*/
	function draw(Void):Void
	{
		size();
	}

/**
* @private
* return the thickness of the border edges
* @return Object	top, bottom, left, right thickness in pixels
*/
	function getBorderMetrics(Void):Object
	{
		var o:Number = offset;

		if (__borderMetrics == undefined)
		{
			__borderMetrics = { left: o, top: o, right: o, bottom:o };
		}
		else
		{
			__borderMetrics.left = o;
			__borderMetrics.top = o;
			__borderMetrics.right = o;
			__borderMetrics.bottom = o;
		}

		return __borderMetrics;
	}

/**
* getter for borderMetrics
*/
	function get borderMetrics():Object
	{
		return getBorderMetrics();
	}

/**
* @private
* draw the border, either 3d or 2d or nothing at all
*/
	function drawBorder(Void):Void
	{
	}

/**
* @private
* size handler
*/
	function size(Void):Void
	{
		drawBorder();
	}

/**
* @private
* react to color style changes
*/
	function setColor(Void):Void
	{
		drawBorder();
	}

}
