import mx.controls.Button;
import mx.controls.MediaController;
import mx.controls.streamingmedia.Tracer;

/**
 * Processing code for a click on the Play button.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PlayButton
extends MovieClip
{
	private var playButton:Button;
	private var _controller:MediaController;
	private var _delayedPlayId:Number;

	/**
	 * Constructor
	 */
	public function PlayButton()
	{
		init();
	}

	/**
	 * Initialize the clip.
	 */
	private function init():Void
	{
		// Find the controller
		_controller = MediaController(this._parent._parent._parent);

		// Create the Button that the user will interact with
		this.attachMovie("Button", "playButton", 1);
//		playButton.icon = "icon.play";
		playButton.setSize(50,22);
		playButton._x = 0;
		playButton._y = 0;
//		Tracer.trace("PlayButton.init: created Button: " + playButton);
		
		// Register this object as an event listener for the button
		playButton.addEventListener("click", this);
		this.enabled = _controller.enabled;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}

	public function click(ev:Object):Void
	{
		// Navigate the relative path to the controller
		// this -> form -> play/pause button -> (h/v)buttons -> controller
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


	public function get enabled():Boolean
	{
		return playButton.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		var ico = (is ? "icon.play" : "icon.play-disabled");
		playButton.enabled = true;
		playButton.icon = ico;
		playButton.enabled = is;
	}


}
