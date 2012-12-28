//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.Button;
import mx.controls.MediaController;
import mx.controls.streamingmedia.Tracer;

/**
 * The PlayPauseButton control contains an instance of a play button and
 * a pause button. When one is clicked, the other is displayed.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PlayPauseButton
extends MovieClip
{
	/** The button */
	private var _playPauseButton:Button;
	/** The controller containing this clip */
	private var _controller:MediaController;
	/** Is the play button showing? */
	private var _isPlaying:Boolean;

	/**
	 * Constructor
	 */
	public function PlayPauseButton()
	{
		init();
	}

	/**
	 * Initialize the component.
	 */
	private function init():Void
	{
		_controller = MediaController(this._parent._parent);
//		Tracer.trace("PlayPauseButton: _controller=" + _controller + ", isPlaying=" + _controller.isPlaying());
//		Tracer.trace("PlayPauseButton.init: _root.controller._y=" + _root.controller._y);

		// Create the Button that the user will interact with
		this.attachMovie("Button", "_playPauseButton", 1);
		_playPauseButton.setSize(50,22);
		_playPauseButton._x = 0;
		_playPauseButton._y = 0;
		// Register this object as an event listener for the button
		_playPauseButton.addEventListener("click", this);

		// This button should match the controller.
		// These are set opposite because the controller indicates whether the 
		// media is playing while this indicates whether we should show the
		// play button.
		_isPlaying = (!_controller.isPlaying());

		// This is enabled if and only if the controller is enabled
		// Setting the enabled property will automatically display the 
		// proper button icon
		this.enabled = _controller.enabled;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
		
	}

	/**
	 * Display the play button.
	 */
	public function showPlayButton():Void
	{
		Tracer.trace("PlayPauseButton.showPlayButton");
		_isPlaying = true;
		assignIcon();
	}

	/**
	 * Display the pause button.
	 */
	public function showPauseButton():Void
	{
		Tracer.trace("PlayPauseButton.showPauseButton");
		_isPlaying = false;
		assignIcon();
	}

	public function get enabled():Boolean
	{
		return _playPauseButton.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		_playPauseButton.enabled = is;
		assignIcon();
	}

	/**
	 * Assign the icon based on whether the button is in play or pause mode
	 * and whether it is enabled.
	 */
	private function assignIcon():Void
	{
		var isEnabled:Boolean = this.enabled;
		var isPlay:Boolean = this._isPlaying;
		Tracer.trace("PlayPauseButton.assignIcon: start: enabled=" + isEnabled + ", play=" + isPlay);
		var theIcon:String = "";
		if (isPlay)
		{
			theIcon = (isEnabled ? "icon.play" : "icon.play-disabled");
		}
		else
		{
			theIcon = (isEnabled ? "icon.pause" : "icon.pause-disabled");
		}
		Tracer.trace("PlayPauseButton.assignIcon: icon=" + theIcon);

		var prior:Boolean = _playPauseButton.enabled;
		if (!prior)
		{
			// Enable the button in order to set the icon
			// Enabling the button causes weird side effects so avoid 
			// doing so unless absolutely necessary
			_playPauseButton.enabled = true;
		}
		_playPauseButton.icon = theIcon;
		// Restore prior enabled setting
		if (!prior)
		{
			_playPauseButton.enabled = false;
		}
		Tracer.trace("PlayPauseButton.assignIcon: done");
	}

	/**
	 * Click handler for the button
	 */
	public function click(ev:Object):Void
	{
		if (_isPlaying)
		{
			playClick();
		}
		else
		{
			pauseClick();
		}
	}

	/**
	 * Handle a click on the play button
	 */
	private function playClick():Void
	{
		var c:MediaController = _controller;

		Tracer.trace("PlayButton.click: playAtBeginning=" + c.playAtBeginning);
		if (c.playAtBeginning)
		{
			// Move the playhead to the beginning
			c.broadcastEvent("playheadChange", 0);
			// Only do this once
			Tracer.trace("PlayButton.click: playAtBeginning=false");
			c.playAtBeginning = false;
		}

		c.broadcastEvent("click", "play");
		// Tell the controller we are playing.
		// This function displays the pause button.
		c.setPlaying(true);
	}

	/**
	 * Handle a click on the pause button
	 */
	private function pauseClick():Void
	{
		var c:MediaController = _controller;
		c.broadcastEvent("click", "pause");
		// Tell the controller we are pausing
		// This function displays the play button.
		c.setPlaying(false);
	}

}
