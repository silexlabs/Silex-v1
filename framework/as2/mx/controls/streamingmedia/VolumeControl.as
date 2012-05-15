//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.LoudButton;
import mx.controls.streamingmedia.MuteButton;
import mx.controls.streamingmedia.VolumeControlHandle;

/**
 * VolumeControl lets the user adjust the volume of the media.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.VolumeControl
extends MovieClip
{
	private var _handle:VolumeControlHandle;
	public var _muteButton:MuteButton;
	public var _loudButton:LoudButton;

	public function VolumeControl()
	{
		init();
	}

	private function init():Void
	{
		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;
	}

	public function getHandle():VolumeControlHandle
	{
		return _handle;
	}
}
