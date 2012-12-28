//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


/**
 * The tray of the play bar.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.HPlayBarTray
extends MovieClip
{
	/** The pieces of the tray */
	private var _left:MovieClip;
	private var _middle:MovieClip;
	private var _right:MovieClip;

	/**
	 * Constructor
	 */
	public function HPlayBarTray()
	{
	}

	/**
	 * Set the width of the tray.
	 */
	public function setWidth(aWidth:Number):Void
	{
//		Tracer.trace("HPlayBarTray.setWidth: " + aWidth);
		_middle._x = _left._width;
		_middle._width = aWidth - _left._width - _right._width;
		_right._x = _middle._x + _middle._width;
	}
}
