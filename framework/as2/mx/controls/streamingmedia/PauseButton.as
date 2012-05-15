import mx.controls.Button;
import mx.controls.MediaController;

/**
 * Processing code for a click on the Pause button.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PauseButton
extends MovieClip
{
	private var pauseButton:Button;
	private var _controller:MediaController;

	/**
	 * Constructor
	 */
	public function PauseButton()
	{
		init();
	}

	/**
	 * Initialize the clip.
	 */
	private function init():Void
	{
		_controller = MediaController(this._parent._parent._parent);
		// Create the Button that the user will interact with
//		this.attachMovie("Button", "pauseButton", 1);
		this.attachButton();
//		pauseButton.icon = "icon.pause";
		pauseButton.setSize(50,22);
		pauseButton._x = 0;
		pauseButton._y = 0;
		
		// Register this object as an event listener for the button
		pauseButton.addEventListener("click", this);
		this.enabled = _controller.enabled;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}


	/**
	 * Attach the Button object. This code is copied from 
	 * UIObject.createClassObject. It cannot be called directly on
	 * UIObject because PauseButton does not extend UIObject and 
	 * the object that contains function gets the clip attached to it.
	 */
	private function attachButton():Void
	{
		this.attachMovie("Button", "pauseButton", 1);
//		var bSubClass:Boolean = (Button.symbolName == undefined);
//
//		if (bSubClass)
//		{
//			Object.registerClass(Button.symbolOwner.symbolName, Button);
//		}
//		this.attachMovie(Button.symbolOwner.symbolName, "pauseButton", 1);
//
//		if (bSubClass)
//		{
//			Object.registerClass(Button.symbolOwner.symbolName, Button.symbolOwner);
//		}
	}


	public function click(ev:Object):Void
	{
		// Navigate the relative path to the controller
		var c:MediaController = _controller;
		// this -> form -> play/pause button -> (h/v)buttons -> controller
		c.broadcastEvent("click", "pause");
		// Tell the controller we are pausing
		// This function displays the play button.
		c.setPlaying(false);

		// Show the play button
		// When this is done, "this" is toast. It disappears and the 
		// pause button takes its place. This must be the last line in the function.
//		this._parent.showPlayButton();

	}

	public function get enabled():Boolean
	{
		return pauseButton.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		var ico = (is ? "icon.pause" : "icon.pause-disabled");
		pauseButton.enabled = true;
		pauseButton.icon = ico;
		pauseButton.enabled = is;
	}


}
