//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * The tray of the vertical mini play bar.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.VMiniPlayBarTray
extends MovieClip
{
	/** The pieces of the tray */
	private var _top:MovieClip;
	private var _middle:MovieClip;
	private var _bottom:MovieClip;

	public function VMiniPlayBarTray()
	{

	}

	/**
	 * Get the height of the tray.
	 */
	public function getHeight():Number
	{
		return _bottom._y + _bottom._height;
	}

	/**
	 * Set the height of the tray.
	 */
	public function setHeight(aHeight:Number):Void
	{
		_middle._y = _top._height;
		_middle._height = aHeight - _top._height - _bottom._height;
		_bottom._y = _middle._y + _middle._height;
	}
}
