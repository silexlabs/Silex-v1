//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.FullScreenToggle;
import mx.controls.streamingmedia.Tracer;

/**
 * This class draws the chrome used by the display and player components.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.Chrome
extends MovieClip
{
	// The public vars are normally sent in an initObj
	public var visible:Boolean;
	public var width:Number;
	public var height:Number;
	public var showToggles:Boolean;

	private var _chromeFill:MovieClip;
	private var _chromeHilite:MovieClip;
	private var _chromeEdge:MovieClip;

	// Four full-screen toggles: one for each corner
	private var _toggleNW:FullScreenToggle;
	private var _toggleNE:FullScreenToggle;
	private var _toggleSW:FullScreenToggle;
	private var _toggleSE:FullScreenToggle;


	public function Chrome()
	{
		init();
	}

	private function init():Void
	{
		if (visible == null)
		{
			visible = true;
		}
		if ( (width != null) && (height != null) )
		{
			draw();
		}

		// Cascade the enabled value from the controller or playback 
		// component that contains this.
		Tracer.trace("Chrome.init: setting enabled to " + this._parent.enabled);
		this.setEnabled(this._parent.enabled);
	}

	public function setSize(w:Number, h:Number):Void
	{
		width = w;
		height = h;
	}


	public function draw():Void
	{
//		Tracer.trace("Chrome.draw: " + this + ": " + width + "x" + height + 
//			( visible ? " " : " in" ) + "visible at (" + this._x + "," + this._y + ")");

		// Draw a box for debugging
//		this.clear();
//		this.lineStyle(0, 0xff0000, 100);
//		this.moveTo(0,0);
//		this.lineTo(width,0);
//		this.lineTo(width,height);
//		this.lineTo(0,height);
//		this.lineTo(0,0);
		
		if (visible)
		{
			this._alpha = 100;
		}
		else
		{
			// Don't make _visible false so that the chrome will still detect mouse rollovers
			this._alpha = 0;
		}

		this._chromeEdge._width = width;
		this._chromeEdge._height = height;
		this._chromeEdge._x = 0;
		this._chromeEdge._y = 0;

		this._chromeHilite._width = width - 2;
		this._chromeHilite._x = 1;
		this._chromeHilite._y = 1;
		
		this._chromeFill._width = width - 2;
		this._chromeFill._height = height - 3;
		this._chromeFill._x = 1;
		this._chromeFill._y = 2;

		if (visible && showToggles)
		{
			_toggleNW._visible = true;
			_toggleSW._visible = true;
			_toggleNE._visible = true;
			_toggleSE._visible = true;
			// Position the 4 toggles
			_toggleNW._x = 0;
			_toggleNW._y = 0;
			_toggleNE._x = width; // - _toggleNE._width;
			_toggleNE._y = 0;
			_toggleSW._x = 0;
			_toggleSW._y = height; // - _toggleSW._height;
			_toggleSE._x = width; // - _toggleNE._width;
			_toggleSE._y = height; // - _toggleSW._height;
		}
		else
		{
			_toggleNW._visible = false;
			_toggleSW._visible = false;
			_toggleNE._visible = false;
			_toggleSE._visible = false;
		}
	}

	/**
	 * @return All the toggles
	 */
	public function getAllToggles():Array
	{
		return [ _toggleNW, _toggleNE, _toggleSW, _toggleSE ];
	}

	/**
	 * @return An active full-screen toggle. There is currently only one: NE.
	 */
	public function getOneToggle():FullScreenToggle
	{
		return _toggleNE;
	}

	public function getEnabled():Boolean
	{
		return _parent.enabled;
	}

	public function setEnabled(is:Boolean):Void
	{
		Tracer.trace("Chrome.setEnabled: " + is);
		_toggleNW.setEnabled(is);
		_toggleNE.setEnabled(is);
		_toggleSW.setEnabled(is);
		_toggleSE.setEnabled(is);
	}

}