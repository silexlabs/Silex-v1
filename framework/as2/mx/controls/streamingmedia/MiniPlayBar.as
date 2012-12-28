//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;

/**
 * The load bar that indicates how much of the streaming media has 
 * been loaded.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.MiniPlayBar
extends MovieClip
{

	/** The controller with which this load bar is associated */
	private var _controller:MediaController;
	/** The thumb */
	private var _thumb:MovieClip;

	private var _hilite:MovieClip;
	/** The tray. Different classes for vertical and horizontal orientation so leave it untyped. */
	private var _tray;

	/**
	 * Constructor.
	 */
	public function MiniPlayBar()
	{
		init();
	}

	/**
	 * Initialize the component.
	 */
	private function init():Void
	{
		_controller = MediaController(this._parent);
		// Draw the play bar
		this.draw();
	}

	public function isVertical():Boolean
	{
		return (!_controller.horizontal);
	}

	/**
	 * Set the completion percentage.
	 */
	public function getCompletionPercentage():Number
	{
		var percent:Number;
		if (isVertical())
		{
			percent = yToPercent(this._thumb._y);
		}
		else
		{
			percent = xToPercent(this._thumb._x);
		}
//		Tracer.trace("MiniPlayBar.getCompletionPercentage=" + percent);
		return percent;
	}

	/**
	 * Set the completion percentage.
	 */
	public function setCompletionPercentage(aPercentage:Number):Void
	{
		// Error check the percentage parameter
		aPercentage = Math.floor(aPercentage);
		if (aPercentage < 1)
		{
			aPercentage = 1;
		}
		else if (aPercentage > 100)
		{
			aPercentage = 100;
		}

		if (isVertical())
		{
			// Move the thumb
			var yPos:Number = percentToY(aPercentage);
			this._thumb._y = getActualHeight() - yPos - 1;
			// Update the hilite height and position
			this._hilite._height = yPos - 1;
			this._hilite._y = getActualHeight() - yPos - 2;
		}
		else
		{
			// Move the thumb
			var xPos:Number = percentToX(aPercentage);
			this._thumb._x = xPos;
			// Update the hilite
			this._hilite._width = xPos - 1;
		}
//		Tracer.trace("MiniPlayBar.setCompletionPercentage: " + aPercentage + 
//			"%, thumb at (" + this._thumb._x + "," + this._thumb._y + ")");
	}


	/**
	 * @return The controller associated with the play bar.
	 */
	public function getController():MediaController
	{
		return _controller;
	}

	/**
	 * Draw the play bar.
	 *
	 * @param h The height at which to draw the bar. OPTIONAL.
	 * If omitted, the bar will be drawn at its standard height.
	 * This is only used if the load bar is in vertical orientation.
	 * It is ignored for horizontal bars.
	 */
	public function draw(h:Number):Void
	{
		// Remember the prior percentage
//		var prior:Number = getCompletionPercentage();

		if (isVertical())
		{
			// Position the y-coordinate
			this._y = 8;
			// Set the height of the tray
			if (h == null)
			{
				h = getHeight();
			}
			_tray.setHeight(h);
		}
		else
		{
			var w:Number = this.getWidth();
			// Position the x-coordinate
			this._x = 8;
			// Set the width of the tray
			_tray.setWidth(getWidth());
		}

		// Restore the proper percentage. For some reason, getting it at the beginning
		// of this function and setting the same value at the end doesn't work
		// properly.
//		Tracer.trace("MiniPlayBar.draw: resetting completion percentage to " + prior);
		setCompletionPercentage(_controller.playPercent);
	}

	/**
	 * @return The width of the play bar
	 */
	public function getWidth():Number
	{
		var w:Number = ( isVertical() ? 6 : _controller.width - 16 );
//		Tracer.trace("MiniPlayBar.getWidth=" + w);
		return w;
	}

	/**
	 * @return The height of the play bar
	 */
	public function getHeight():Number
	{
		// This is only present when the controller is closed. 90;
		var h:Number = ( isVertical() ? _controller.height - 16 : 6 );
//		Tracer.trace("MiniPlayBar.getHeight=" + h);
		return h;
	}

	public function getActualHeight():Number
	{
		var h:Number = _tray.getHeight();
//		Tracer.trace("MiniPlayBar.getActualHeight(): " + h);
		return h;
	}

	/**
	 * @param x The x coordinate of the thumb. Between 0 and (width - 2).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function xToPercent(x:Number):Number
	{
		var percent:Number = 100 * x / (this.getWidth() - 2);
//		Tracer.trace("MiniPlayBar.xToPercent: " + x + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The x coordinate of the thumb. Between 0 and (width - 2).
	 */
	public function percentToX(percent:Number):Number
	{
		var x:Number = (this.getWidth() - 2) * (percent / 100);
//		Tracer.trace("PlayBar.percentToX: " + percent + "->" + x);
		return x;
	}

	/**
	 * @param y The y coordinate of the thumb. Between 1 and (Height - 2).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function yToPercent(y:Number):Number
	{
		var percent:Number = 100 * (y - 1) / (this.getActualHeight() - 3);
//		Tracer.trace("MiniPlayBar.yToPercent: " + y + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The y coordinate of the thumb. Between 1 and (Height - 2).
	 */
	public function percentToY(percent:Number):Number
	{
		var y:Number = (this.getActualHeight() - 3) * (percent / 100) + 1;
//		Tracer.trace("PlayBar.percentToY: " + percent + "->" + y);

		return y;
	}

}
