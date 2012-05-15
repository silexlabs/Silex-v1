//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.SimpleButton;

/**
 * Processing code for a click on the ToStart button.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.ToStartButton
extends MovieClip
{
	private var toStartSimpleButton:SimpleButton;

	/**
	 * Constructor
	 */
	public function ToStartButton()
	{
		init();
	}

	/**
	 * Initialize the clip. Must be implemented by subclasses.
	 * This always simply calls findController but it has to be called by
	 * the concrete subclass in order to be in the movie clip hierarchy.
	 */
	public function init():Void
	{
		// Create the SimpleButton that the user will interact with
		this.attachMovie("SimpleButton", "toStartSimpleButton", 1, {
			falseUpSkin: "ToStart-False-Up",
			falseOverSkin: "ToStart-False-Over",
			falseDownSkin: "ToStart-False-Down",
			falseDisabledSkin: "ToStart-False-Disabled" });
		// Register this as an event listener
		toStartSimpleButton.addEventListener("click", this);

		var c:MediaController = MediaController(this._parent._parent);
		this.enabled = c.enabled;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}

	public function get enabled():Boolean
	{
		return toStartSimpleButton.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		toStartSimpleButton.enabled = is;
	}

	public function click(ev:Object):Void
	{
		// Navigate the relative path to the controller
		// this -> (h/v)buttons -> controller
		this._parent._parent.broadcastEvent("playheadChange", 0);
	}

}
