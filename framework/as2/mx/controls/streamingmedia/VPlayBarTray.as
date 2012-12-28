//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


/**
 * The tray of the vertical play bar.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.VPlayBarTray
extends MovieClip
{
	/** The pieces of the tray */
	private var _top:MovieClip;
	private var _middle:MovieClip;
	private var _bottom:MovieClip;

	/**
	 * Constructor
	 */
	public function VPlayBarTray()
	{
	}

	/**
	 * Set the width of the tray.
	 */
	public function setHeight(aHeight:Number):Void
	{
//		Tracer.trace("VPlayBarTray.setHeight: " + aHeight);
//		Tracer.trace("VPlayBarTray.setHeight: _root.controller._y=" + _root.controller._y);
		_middle._y = _top._height;
		_middle._height = aHeight - _top._height - _bottom._height;
		_bottom._y = _middle._y + _middle._height;
	}
}
