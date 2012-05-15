//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.SimpleButton;
import mx.controls.streamingmedia.Tracer;

/**
 * Processing code for a click on the ToEnd button.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.ToEndButton
extends MovieClip
{
	private var toEndSimpleButton:SimpleButton;

	/**
	 * Constructor
	 */
	public function ToEndButton()
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
		this.attachMovie("SimpleButton", "toEndSimpleButton", 1, {
			falseUpSkin: "ToEnd-False-Up",
			falseOverSkin: "ToEnd-False-Over",
			falseDownSkin: "ToEnd-False-Down",
			falseDisabledSkin: "ToEnd-False-Disabled" });
		
		// Register this as an event listener
		toEndSimpleButton.addEventListener("click", this);

		// Check to see if this should be disabled
		var c:MediaController = MediaController(this._parent._parent);
		c.evaluateToEnd();

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}


	public function get enabled():Boolean
	{
		return toEndSimpleButton.enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		toEndSimpleButton.enabled = is;
	}



	public function click(ev:Object):Void
	{
		// Navigate the relative path to the controller
		// this -> (h/v)buttons -> controller
		var c:MediaController = MediaController(this._parent._parent);
		Tracer.trace("ToEndButton.click: playAtBeginning=false");
		c.playAtBeginning = false;
		c.broadcastEvent("playheadChange", 100);
	}

}
