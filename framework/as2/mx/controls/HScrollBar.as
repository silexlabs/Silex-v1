//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

//import mx.core.UIComponent;
import mx.controls.scrollClasses.ScrollBar;

[IconFile("HScrollBar.png")]

/**
* horizontal scrollbar.  It is actually the base scrollbar rotated 90 degrees
* Most of the code swaps axes
*
* @helpid 3124
* @tiptext
*/
class mx.controls.HScrollBar extends ScrollBar
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "HScrollBar";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.core.UIComponent;

	// Version string//#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "HScrollBar";

	// the detail strings for horizontal scroll events
	var minusMode:String = "Left";
	var plusMode:String = "Right";
	var minMode:String = "AtLeft";
	var maxMode:String = "AtRight";


/**
* @private
* override this instead of adding your own getter-setter for minWidth
*/
	function getMinWidth(Void):Number
	{
		return _minHeight;
	}

/**
* @private
* override this instead of adding your own getter-setter for minHeight
*/
	function getMinHeight(Void):Number
	{
		return _minWidth;
	}

	function HScrollBar()
	{
	}

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
	function init(Void):Void
	{
		super.init();

		// scroll bar does some tricky things based on its orientation
		// most components won't need to do this
		_xscale = -100;
		_rotation = -90;

	}

	// for internal use only
	function get virtualHeight():Number
	{
		return __width;
	}

/**
* @private
* map keys to scroll events
*/
	function isScrollBarKey(k:Number):Boolean
	{
		if (k == Key.LEFT)
		{
			scrollIt("Line",-1);
			return true;
		}
		else if (k == Key.RIGHT)
		{
			scrollIt("Line",1);
			return true;
		}
		return super.isScrollBarKey(k);

	}

	[Bindable]
	[ChangeEvent("scroll")]
	var	_inherited_scrollPosition:Number;

}
