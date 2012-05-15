//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * The tray of the horizontal mini play bar.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.HMiniPlayBarTray
extends MovieClip
{
	/** The pieces of the tray */
	private var _left:MovieClip;
	private var _middle:MovieClip;
	private var _right:MovieClip;

	public function HMiniPlayBarTray()
	{
		// Set the initial width based on the parent's width.
		// This prevents the annoying flash when this appears for the
		// first frame at the wrong size.
	}

	/**
	 * Set the width of the tray.
	 */
	public function setWidth(aWidth:Number):Void
	{
		_middle._x = _left._width;
		_middle._width = aWidth - _left._width - _right._width;
		_right._x = _middle._x + _middle._width;
	}

	/**
	 * Get the height of the tray.
	 */
	public function getHeight():Number
	{
		return _left._height;
	}

}
