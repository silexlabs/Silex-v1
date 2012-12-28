//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.scrollClasses.ScrollBar;

[IconFile("VScrollBar.png")]

/**
* vertical scrollbar.  It is actually a wrapper on the base scrollbar
*
* @helpid 3209
* @tiptext
*/
class mx.controls.VScrollBar extends ScrollBar
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "VScrollBar";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.core.UIComponent;

	// Version string//#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "VScrollBar";

	// the detail strings for horizontal scroll events
	var minusMode:String = "Up";
	var plusMode:String = "Down";
	var minMode:String = "AtTop";
	var maxMode:String = "AtBottom";

	function VScrollBar()
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
* map keys to scroll events
*/
	function isScrollBarKey(k:Number):Boolean
	{
		if (k == Key.UP)
		{
			scrollIt("Line",-1);
			return true;
		}
		else if (k == Key.DOWN)
		{
			scrollIt("Line",1);
			return true;
		}
		else if (k == Key.PGUP)
		{
			scrollIt("Page",-1);
			return true;
		}
		else if (k == Key.PGDN)
		{
			scrollIt("Page",1);
			return true;
		}

		return super.isScrollBarKey(k);

	}

	[Bindable]
	[ChangeEvent("scroll")]
	var	_inherited_scrollPosition:Number;
}
