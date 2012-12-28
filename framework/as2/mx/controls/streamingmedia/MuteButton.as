//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.SimpleButton;

/**
 * Processing code for a click on the Mute button.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.MuteButton
extends MovieClip
{
	public var muteSimpleButton:SimpleButton;

	/**
	 * Constructor
	 */
	public function MuteButton()
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
		this.attachMovie("SimpleButton", "muteSimpleButton", 1, {
			falseUpSkin: "Mute-False-Up",
			falseOverSkin: "Mute-False-Over",
			falseDownSkin: "Mute-False-Down",
			falseDisabledSkin: "Mute-False-Disabled"});
		
		// Register this as an event listener
		muteSimpleButton.addEventListener("click", this);

		// Initialize enabled
		muteSimpleButton.enabled = this._parent._parent.enabled;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}

	public function click(ev:Object):Void
	{
		// Navigate the relative path to the controller
		// this -> form -> (h/v)buttons -> controller
		this._parent._parent.broadcastEvent("volume", 0);
		// Adjust the handle in the volume control
		this._parent.getHandle().setMute();
	}
}
