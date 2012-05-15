//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.streamingmedia.FullScreenToggle;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.FullScreenToggleControl
extends MovieClip
{
	/** The toggle of which this control is a member */
	private var toggle:FullScreenToggle;

	private var _enabled:Boolean;

	public function FullScreenToggleControl()
	{
		init();
	}

	private function init():Void
	{
		toggle = FullScreenToggle(_parent);
		this.setEnabled(toggle.getEnabled());
	}

	public function handleRollOver():Void
	{
		getController().setNotAnimating(true);
	}

	public function handleRollOut():Void
	{
		getController().setNotAnimating(false);
	}


	public function handleRelease():Void
	{
		toggle.toggleDisplay();
	}

	private function getController():MediaController
	{
		return toggle.getPlayer().getController();
	}

	public function getEnabled():Boolean
	{
		return _enabled;
	}

	public function setEnabled(is:Boolean):Void
	{
		Tracer.trace("FullScreenToggleControl.setEnabled: " + is);
		_enabled = is;
		if (is)
		{
			this.onRollOver = this.handleRollOver;
			this.onRollOut = this.handleRollOut;
			this.onRelease = this.handleRelease;
			this.gotoAndStop("_up");
		}
		else
		{
			delete this.onRollOver;
			delete this.onRollOut;
			delete this.onRelease;
			this.gotoAndStop("_disabled");
		}
	}

}
