//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.streamingmedia.PlayBar;
import mx.controls.streamingmedia.StreamingMediaConstants;

/**
 * The draggable thumb of the play bar that lets the user see and adjust
 * the current play head position.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PlayBarThumb
extends MovieClip
{

	/** The play bar with which this thumb is associated */
	private var _playBar:PlayBar;
	private var _enabled:Boolean;
	/** Was the media playing before they dragged the playhead? */
	private var _wasPlaying:Boolean;
	/** Id of the interval used to pause playback */
	private var _pauseId:Number;
	/** Are we dragging the thumb? */
	private var _dragging:Boolean;
	/** The original controllerPolicy setting */

	public function PlayBarThumb()
	{
		init();
	}

	/**
	 * Initialize the clip.
	 */
	private function init():Void
	{
		_playBar = PlayBar(this._parent);
		enabled = _playBar.getController().enabled;
	}

	private function isVertical():Boolean
	{
		return _playBar.isVertical();
	}

	/**
	 * Process a mouse click on the clip. Start dragging the thumb
	 * on the play bar.
	 */
	public function handlePress():Void
	{
		startThumbDrag();
	}
	
	private function startThumbDrag():Void
	{
		// We are dragging
		_dragging = true;

		// Temporarily have the controller stop listening to playheadMove events
		var c:MediaController = _playBar.getController();
		c.broadcastEvent("scrubbing", true);
		
		// Stop playing the media while dragging occurs
		_wasPlaying = c.isPlaying();
		if (_wasPlaying)
		{
			c.broadcastEvent("click", "pause");
		}

		// Update the fill display immediately as the handle is dragged
		this.onMouseMove = this.handleMouseMove;
	}


	/**
	 * Emergency backup. Never kill this clip and leave dragging mode on.
	 */
	public function onUnload():Void
	{
		if (_dragging)
		{
			stopThumbDrag();
		}
	}


	/**
	 * The user released the mouse. Stop dragging my clip around.
	 */
	public function handleRelease():Void
	{
		if (_dragging)
		{
			stopThumbDrag();
		}
	}

	/**
	 * The user released the mouse outside the clip. 
	 * Stop dragging my clip around.
	 */
	public function handleReleaseOutside():Void
	{
		if (_dragging)
		{
			stopThumbDrag();
		}
	}

	private function stopThumbDrag():Void
	{
		// We are no longer dragging
		_dragging = false;

		var c:MediaController = _playBar.getController();

		// Restore the prior value of isPlaying
		if (_wasPlaying)
		{
			c.broadcastEvent("click", "play");
		}

		// Have the controller listen for playheadMove events again.
		c.broadcastEvent("scrubbing", false);

		// Stop listening for mouse movements
		delete this.onMouseMove;
	}

	/**
	 * Pause playback after a pause
	private function delayedPause():Void
	{
		clearInterval(_pauseId);
		_pauseId = null;
		_playBar.getController().broadcastEvent("click", "pause");
	}
	 */

	/**
	 * Handle mouse motion over the component.
	 */
	private function handleMouseMove():Void
	{
		var c:MediaController = _playBar.getController();

		// Move the thumb
		var scalar:Number = c.getLoadBar().getCompletionPercentage() / 100;
		if (isVertical())
		{
			var maxHt:Number = _playBar.getHeight() - 8;
			var minHt:Number = (maxHt * (1 - scalar)) - 2;
			var y:Number = _playBar._ymouse;
			if (y < minHt)
			{
				y = minHt;
			}
			else if (y > maxHt)
			{
				y = maxHt;
			}
			this._y = y;
		}
		else
		{
			var maxWd:Number = ((_playBar.getWidth() - 6) * scalar);
			var x:Number = _playBar._xmouse;
			if (x < 0)
			{
				x = 0;
			}
			else if (x > maxWd)
			{
				x = maxWd;
			}
			this._x = x;
		}

		// Update the display of the playbar
		_playBar.updateHiliteToMatchThumb();
		var percent:Number = ( isVertical() ? _playBar.yToPercent(this._y) : _playBar.xToPercent(this._x) );
		// Send an event to immediately update the media.
		// Make this easily configurable because it was locking up some player versions.
		// It seems to be working smoothly now.
		if (StreamingMediaConstants.SCRUBBING)
		{
			c.broadcastEvent("playheadChange", percent);
		}
		// Update the time in the playbar
		var totalTime:Number = c.playTime * 100 / c.playPercent;
		var time:Number = totalTime * percent / 100;
		_playBar.setTime( time );

		c.playPercent = percent;
		c.playTime = time;
	}


	public function get enabled():Boolean
	{
		return _enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		_enabled = is;
		if (is)
		{
			this.onPress = this.handlePress;
			this.onRelease = this.handleRelease;
			this.onReleaseOutside = this.handleReleaseOutside;
		}
		else
		{
			if (_dragging)
			{
				stopThumbDrag();
			}
			delete this.onPress;
			delete this.onRelease;
			delete this.onReleaseOutside;
		}
	}

	/**
	 * Is the thumb being dragged?
	 */
	public function isScrubbing():Boolean
	{
		return _dragging;
	}
}
