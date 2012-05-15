//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.streamingmedia.VolumeControl;

/**
 * The draggable thumb of the play bar that lets the user see and adjust
 * the current play head position.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.VolumeControlHandle
extends MovieClip
{
	/** The volume control with which this thumb is associated */
	private var _volumeControl:VolumeControl;
	/** The controller that the thumb sits in */
	private var _controller:MediaController;
	/** Is it enabled? */
	private var _enabled:Boolean;

	/**
	 * Constructor
	 */
	public function VolumeControlHandle()
	{
		init();
	}

	/**
	 * Initialize the clip.
	 */
	private function init():Void
	{
		_volumeControl = VolumeControl(this._parent);
		_controller = MediaController(this._parent._parent);
		setVolume(_controller.volume);
		enabled = _controller.enabled;
		// Disable tab support
		this.tabEnabled = false;
		this.tabChildren = false;
	}

	private function isVertical():Boolean
	{
		return (!_controller.horizontal);
	}

	/**
	 * Position the thumb according to the parameter volume.
	 * @param aVolume Volume level between 0 and 100
	 */
	public function setVolume(aVolume:Number):Void
	{
		if (aVolume < 0)
		{
			aVolume = 0;
		}
		else if (aVolume > 100)
		{
			aVolume = 100;
		}

		this._x = volumeToX(aVolume);
	}

	/**
	 * Put the thumb in mute position.
	 */
	public function setMute():Void
	{
		setVolume(0);
	}

	/**
	 * Put the thumb in loud position.
	 */
	public function setLoud():Void
	{
		setVolume(100);
	}

	/**
	 * Process a mouse click on the clip. Start dragging the thumb
	 * on the track.
	 */
	public function handlePress():Void
	{
		this.startThumbDrag();
	}


	/**
	 * The user released the mouse. Stop dragging my clip around.
	 */
	public function handleRelease():Void
	{
		this.stopThumbDrag();
	}

	/**
	 * The user released the mouse. Stop dragging my clip around.
	 */
	public function handleReleaseOutside():Void
	{
		this.stopThumbDrag();
	}

	private function startThumbDrag():Void
	{
		// Let the user drag the thumb
		this.startDrag(false, 12, 3, (12 + getRange()), 3);
		// Kick in the onMouseMove processor to instantly update the volume
		this.onMouseMove = this.handleMouseMove;
	}

	private function stopThumbDrag():Void
	{
		this.stopDrag();
		// Kill the onMouseMove processor
		delete this.onMouseMove;
		// Send an event
		this.broadcastEvent();
	}
	
	private function handleMouseMove():Void
	{
		// Send an event when the mouse moves
		this.broadcastEvent();
	}

	private function broadcastEvent():Void
	{
		_controller.broadcastEvent("volume", xToVolume(this._x));
	}

	private function xToVolume(x:Number):Number
	{
		return (x - 12) * (100 / getRange());
	}

	private function volumeToX(aVol:Number):Number
	{
		return (aVol / (100 / getRange())) + 12;
	}

	private function getRange():Number
	{
		var range:Number = ( isVertical() ? 27 : 50 );
		return range;
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
			delete this.onPress;
			delete this.onRelease;
			delete this.onReleaseOutside;
		}
	}

}
