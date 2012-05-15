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
class mx.controls.streamingmedia.LoadBar
extends MovieClip
{
	/** The controller with which this load bar is associated */
	private var _controller:MediaController;

	private var _background:MovieClip;
	private var _border:MovieClip;
	private var _fill:MovieClip;


	public function LoadBar()
	{
		init();
	}


	private function init():Void
	{
		_controller = MediaController(this._parent);
		draw();
	}

	/** Is the load bar vertical? (vs horizontal) */
	private function isVertical():Boolean
	{
		return (!_controller.horizontal);
	}

	/**
	 * Get the completion percentage.
	 */
	public function getCompletionPercentage():Number
	{
		var percentage:Number;
		if (isVertical())
		{
			percentage = yToPercent(this._fill._height);
		}
		else
		{
			percentage = xToPercent(this._fill._width);
		}
		return percentage;
	}

	/**
	 * Set the completion percentage.
	 */
	public function setCompletionPercentage(aPercentage:Number):Void
	{
		aPercentage = Math.floor(aPercentage);
		if (aPercentage < 0)
		{
			aPercentage = 0;
		}
		else if (aPercentage > 100)
		{
			aPercentage = 100;
		}

		if (isVertical())
		{
			_fill._height = percentToY(aPercentage);
			// It has to fill from the bottom up, so change the position as well as the height.
			_fill._y = getActualHeight() - _fill._height - 1;
		}
		else
		{
			this._fill._width = percentToX(aPercentage);
		}
//		Tracer.trace("LoadBar.setCompletionPercentage: set percent=" + aPercentage + ", get percent=" + getCompletionPercentage());
//		Tracer.trace("LoadBar.setCompletionPercentage: _root.controller._y=" + _root.controller._y);
	}



	/**
	 * Draw the load bar.
	 *
	 * @param size The height or width at which to draw the load bar. OPTIONAL.
	 * If omitted, the load bar will be drawn at its standard height or width.
	 */
	public function draw(size:Number):Void
	{
		// Remember the prior percentage
		var prior:Number = getCompletionPercentage();
		//Tracer.trace("LoadBar.draw: before=" + prior + "%");

		if (isVertical())
		{
			if (size == null)
			{
				size = this.getHeight();
			}
			// Position this. More positioning is done by the controller.
			this._y = 8;
			// Set the height of the border
			_border._height = size;
			// And the height of the background
			_background._height = size - 2;
		}
		else
		{
			if (size == null)
			{
				size = this.getWidth();
			}
			// Position the x-coordinate
			this._x = 8;
			// Set the width of the border
			_border._width = size;
			// And the width of the background
			_background._width = size - 2;
		}

		// Restore the prior percentage
		setCompletionPercentage(prior);
		//Tracer.trace("LoadBar.draw: after=" + getCompletionPercentage() + "%");
	}

	/**
	 * @return The width of the play bar
	 */
	public function getWidth():Number
	{
		var w:Number;
		if (isVertical())
		{
			w = 3;
		}
		else
		{
			w = _controller.width - 16;
		}
//		Tracer.trace("LoadBar.getWidth=" + w);
		return w;
	}

	/**
	 * @return The height of the load bar
	 */
	public function getHeight():Number
	{
		var h:Number;
		if (isVertical())
		{
			if (_controller.expanded)
			{
				h = getOpenHeight();
			}
			else
			{
				h = getClosedHeight();
			}
		}
		else
		{
			h = 3;
		}
//		Tracer.trace("LoadBar.getHeight=" + h);
		return h;
	}

	/**
	 * This "actual" functions are necessary because the bar height animates
	 * when the controller expands and contracts in vertical position.
	 * We need the fill to animate accurately also.
	 */
	private function getActualHeight():Number
	{
		return _border._height;
	}

	private function getActualWidth():Number
	{
		return _border._width;
	}


	public function getOpenHeight():Number
	{
		return _controller.height - 90;
	}


	public function getClosedHeight():Number
	{
		return _controller.height - 16;
	}

	/**
	 * @param x The x coordinate of the thumb. Between 0 and (width - 2).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function xToPercent(x:Number):Number
	{
		var percent:Number = 100 * x / (this.getActualWidth() - 2);
//		Tracer.trace("LoadBar.xToPercent: " + x + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The x coordinate of the thumb. Between 0 and (width - 2).
	 */
	public function percentToX(percent:Number):Number
	{
		var x:Number = (this.getWidth() - 2) * (percent / 100);
//		Tracer.trace("LoadBar.percentToX: " + percent + "->" + x);
		return x;
	}

	/**
	 * @param y The y coordinate of the fill bar. Between 0 and (height - 2).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function yToPercent(y:Number):Number
	{
		var percent:Number = 100 * (y - 0) / (this.getActualHeight() - 2);
//		Tracer.trace("LoadBar.xToPercent: " + x + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The y coordinate of the fill bar. Between 0 and (height - 2).
	 */
	public function percentToY(percent:Number):Number
	{
		var y:Number = (this.getActualHeight() - 2) * (percent / 100);
//		Tracer.trace("LoadBar.percentToX: " + percent + "->" + x);
		return y;
	}

}
