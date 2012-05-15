//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.SkinElement;
import mx.skins.Border;

/**
* A border class that uses two end caps and a stretchable middle
*
* @tiptext
* @helpid 3323
*/
class mx.skins.CustomBorder extends Border
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "CustomBorder";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = CustomBorder;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "CustomBorder";

/**
* @private
* index of border skin
*/
	static var tagL:Number = 0;	// L = Left, R = right, M = middle
	static var tagM:Number = 1;
	static var tagR:Number = 2;

/**
* @private
* instance names for border skins
*/
	var idNames = new Array("l_mc", "m_mc", "r_mc");

/**
* symbol name of skin element for left end cap
*
* @tiptext
* @helpid 3324
*/
	var leftSkin:String = "F3PieceLeft";
/**
* symbol name of skin element stretchable middle piece
*
* @tiptext
* @helpid 3325
*/
	var middleSkin:String = "F3PieceMiddle";
/**
* symbol name of skin element for left end cap
*
* @tiptext
* @helpid 3326
*/
	var rightSkin:String = "F3PieceRight";

/**
* whether the caps and middle are placed horizontally or vertically
*
* @tiptext
* @helpid 3327
*/
	var horizontal:Boolean = true;

/**
* @private
* instance name of the left end cap
*/
	var l_mc:MovieClip;
/**
* @private
* instance name of the middle piece
*/
	var m_mc:MovieClip;
/**
* @private
* instance name of the right end cap
*/
	var r_mc:MovieClip;

/**
* minimum height of border, regardless of its orientation
*/
	var minHeight:Number;
/**
* minimum width of border, regardless of its orientation
*/
	var minWidth:Number;

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

	function CustomBorder()
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
* create child objects.  CustomBorder actually creates its children as it is drawn
*/
	function createChildren(Void):Void
	{
	}

/**
* @private
* load skins and draw.
*/
	function draw(Void):Void
	{
		if (l_mc == undefined)
		{
			var z = setSkin(tagL, leftSkin);
			if (horizontal)
			{
				minHeight = l_mc._height;
				minWidth = l_mc._width;
			}
			else
			{
				minHeight = l_mc._height;
				minWidth = l_mc._width;
			}
		}
		if (m_mc == undefined)
		{
			setSkin(tagM, middleSkin);
			if (horizontal)
			{
				minHeight = m_mc._height;
				minWidth += m_mc._width;
			}
			else
			{
				minHeight += m_mc._height;
				minWidth = m_mc._width;
			}
		}
		if (r_mc == undefined)
		{
			setSkin(tagR, rightSkin);
			if (horizontal)
			{
				minHeight = r_mc._height;
				minWidth += r_mc._width;
			}
			else
			{
				minHeight += r_mc._height;
				minWidth = r_mc._width;
			}
		}

		size();
	}

/**
* @private
* layout the two end caps and stretch the middle.
*/
	function size(Void):Void
	{
		l_mc.move(0, 0);
		if (horizontal)
		{
			r_mc.move(width - r_mc.width, 0);
			m_mc.move(l_mc.width, 0);
			m_mc.setSize(r_mc.x - m_mc.x, m_mc.height);
		}
		else
		{
			r_mc.move(0, height - r_mc.height, 0);
			m_mc.move(0, l_mc.height);
			m_mc.setSize(m_mc.width, r_mc.y - m_mc.y);
		}
	}
}

