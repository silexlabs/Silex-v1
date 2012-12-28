//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.streamingmedia.PlayBarThumb;

/**
 * The load bar that indicates how much of the streaming media has 
 * been loaded.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PlayBar
extends MovieClip
{
	private static var TEXT_ALPHA_DARK:Number = 100;
	private static var TEXT_ALPHA_LIGHT:Number = 50;
	/** The length of each pulse in ms */
	private static var PULSE_DURATION:Number = 1400;
	/** The portion of the pulse where active transition occurs */
	private static var ACTIVE_PULSE_PORTION:Number = .4;

	/** Id's of localized strings */
	private static var STREAMING_ID:String = "streaming";
	private static var PAUSED_ID:String = "paused";

	/** The controller with which this load bar is associated */
	private var _controller:MediaController;
	/** The draggable thumb */
	private var _thumb:PlayBarThumb;

	private var _hilite:MovieClip;
	/**
	 * The type of the tray will change (HPlayBarTray or VPlayBarTray) 
	 * depending on orientation. Leave the member untyped.
	 */
	private var _tray;
	private var _statusTextField:TextField;
	private var _timeTextField:TextField;

	/** Make the text darker */
	private var _darkenText:Boolean;
	/** Time that the text color started this pulse */
	private var _textPulseTime:Number;

	/**
	 * Constructor.
	 */
	public function PlayBar()
	{
		init();
	}

	/**
	 * Initialize the component.
	 */
	private function init():Void
	{
		_controller = MediaController(this._parent);

		// Initialize the time and percent from the controller
		setCompletionPercentage( _controller.playPercent );
		setTime( _controller.playTime );

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
			this._thumb._y = getHeight() - yPos - 9;
		}
		else
		{
			// Move the thumb
			var xPos:Number = percentToX(aPercentage);
			this._thumb._x = xPos;
		}
		updateHiliteToMatchThumb();
	//		Tracer.trace("PlayBar.setCompletionPercentage: " + aPercentage + "%, thumbx=" + this._thumb._x);
	}


	public function updateHiliteToMatchThumb():Void
	{
		if (isVertical())
		{
			// Update the hilite
			this._hilite._height = getHeight() - this._thumb._y - 6;
			this._hilite._y = getHeight() - _hilite._height - 1;
		}
		else
		{
			// Update the hilite
			this._hilite._width = this._thumb._x + 4;
		}
	}

	/**
	 * Set the current time in seconds
	 */
	public function setTime(aTime:Number):Void
	{
		// Convert the number of seconds to hh:mm:ss.mmm format
		var hours:Number = Math.floor(aTime / 3600);
		var leftover:Number = aTime % 3600;
		var minutes:Number = Math.floor(leftover / 60);
		leftover %= 60;
		var seconds:Number = Math.floor(leftover);
		leftover %= 1;
		var ms:Number = Math.round( leftover * 1000 );
		var timeStr:String = hours + ":" + ( (minutes < 10) ? "0" : "" ) +
			minutes + ":" + ( (seconds < 10) ? "0" : "" ) + seconds + ".";
		if (ms < 10)
		{
			timeStr += ("00" + String(ms));
		}
		else if (ms < 100)
		{
			timeStr += ("0" + String(ms));
		}
		else
		{
			timeStr += String(ms);
		}

//		Tracer.trace("PlayBar.setTime: " + aTime + "=" + timeStr);

		// Update the time text
		this._timeTextField.text = timeStr;
	}

	/**
	 * Let the playBar know if it is playing. Update the status text.
	 */
	public function setIsPlaying(isPlaying:Boolean):Void
	{
		//Tracer.trace("PlayBar.setIsPlaying: " + isPlaying);
		if (isPlaying)
		{
			this._statusTextField.text = _controller.getLocalizedString(STREAMING_ID);
			// Don't pulse the text fields
			delete this.onEnterFrame;
			// Make sure the text is dark
			setDarkText();
		}
		else
		{
			this._statusTextField.text = _controller.getLocalizedString(PAUSED_ID);
			// Pulse the text fields
			_darkenText = false;
			_textPulseTime = getTimer();
			this.onEnterFrame = this.pulseText;
		}
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
	 */
	public function draw():Void
	{
		// Remember the prior percentage
		var prior:Number = getCompletionPercentage();

		if (isVertical())
		{
			// Position this
			this._x = (_controller.width - this.getWidth()) / 2;
			this._y = 8;
			_tray.setHeight( getHeight() );
			// Position the status text field on the bottom of the play bar
			this._statusTextField._y = this.getHeight() - 4; //this._statusTextField._height;
			//Tracer.trace("PlayBar.draw: statusTF: y=" + _statusTextField._y + ", height=" + _statusTextField._height);
		}
		else
		{
			// Position the x-coordinate
			this._x = 8;
			_tray.setWidth( getWidth() );
			// Position the time text field on the right side of the play bar
			this._timeTextField._x = this.getWidth() - this._timeTextField._width - 3;
		}

		// Initialize the status text, according to whether the controller is playing
		setIsPlaying( _controller.isPlaying() );

		// Restore the prior percentage
		setCompletionPercentage(prior);
	}


	/**
	 * @return The width of the play bar
	 */
	public function getWidth():Number
	{
		var w:Number = ( isVertical() ? 20 : _controller.width - 16);
//		Tracer.trace("PlayBar.getWidth=" + w);
		return w;
	}

	/**
	 * @return The height of the play bar
	 */
	public function getHeight():Number
	{
		var h:Number = ( isVertical() ? _controller.height - 90 : 20);
//		Tracer.trace("PlayBar.getHeight: " + h);
		return h;
	}

	/**
	 * @param x The x coordinate of the thumb. Between -3 and (width - 6).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function xToPercent(x:Number):Number
	{
		var percent:Number = 100 * ((x + 3) / (this.getWidth() - 3));
//		Tracer.trace("PlayBar.xToPercent: " + x + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The x coordinate of the thumb. Between -3 and (width - 6).
	 */
	public function percentToX(percent:Number):Number
	{
		var x:Number = ((this.getWidth() - 3) * (percent / 100)) - 3;
//		Tracer.trace("PlayBar.percentToX: " + percent + "->" + x);
		return x;
	}


	/**
	 * @param y The y coordinate of the thumb. Between -3 and (height - 6).
	 * @return The percent complete. Between 0 and 100.
	 */
	public function yToPercent(y:Number):Number
	{
//		var percent:Number = 100 * ((y + 3) / (this.getHeight() - 3));
		var percent:Number = 100 * ((getHeight() - 3 - y) / getHeight());
		//Tracer.trace("PlayBar.yToPercent: " + y + "->" + percent);
		return percent;
	}

	/**
	 * @param percent The percent complete. Between 0 and 100.
	 * @return The y coordinate of the thumb. Between -3 and (height - 6).
	 */
	public function percentToY(percent:Number):Number
	{
		var y:Number = ((this.getHeight() - 3) * (percent / 100)) - 3;
//		Tracer.trace("PlayBar.percentToY: " + percent + "->" + y);
		return y;
	}


	/**
	 * Gently pulse the text fields
	 */
	private function pulseText():Void
	{
		var elapsed:Number = getTimer() - _textPulseTime;
		var portion:Number = Math.min(1, elapsed / PULSE_DURATION);
		// Only animate for part of the pulse. The rest will be 
		// still at one extreme or the other.
		var activeDuration = PULSE_DURATION * ACTIVE_PULSE_PORTION;
		var activePortion:Number = Math.min(1, elapsed / activeDuration);
		var alphaDelta:Number = activePortion * (TEXT_ALPHA_DARK - TEXT_ALPHA_LIGHT);
		var newAlpha:Number = (_darkenText ? TEXT_ALPHA_LIGHT + alphaDelta : TEXT_ALPHA_DARK - alphaDelta);
		_statusTextField._alpha = newAlpha;
		_timeTextField._alpha = newAlpha;

		if (portion >= 1)
		{
			// We are done with this swing. Start in the other direction
			_darkenText = (!_darkenText);
			_textPulseTime = getTimer();
		}
	}

	/**
	 * Make the text fields dark
	 */
	private function setDarkText():Void
	{
		_statusTextField._alpha = TEXT_ALPHA_DARK;
		_timeTextField._alpha = TEXT_ALPHA_DARK;
	}

	/**
	 * Make the text fields light
	 */
	private function setLightText():Void
	{
		_statusTextField._alpha = TEXT_ALPHA_LIGHT;
		_timeTextField._alpha = TEXT_ALPHA_LIGHT;
	}

	public function get enabled():Boolean
	{
		return _thumb.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		_thumb.enabled = is;
	}

	/**
	 * Is the thumb being dragged?
	 */
	public function isScrubbing():Boolean
	{
		return _thumb.isScrubbing();
	}
}
