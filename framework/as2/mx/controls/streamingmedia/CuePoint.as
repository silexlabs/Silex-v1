//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaDisplay;
import mx.controls.MediaPlayback;

/**
 * CuePoints are points where an event will be fired during the playback of
 * streaming media.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.CuePoint
{
	/** The name of the cue point */
	public var name:String;
	/** The time in seconds at which the cue point is fired */
	public var time:Number;
	/** The display with which this cue point is associated */
	public var display:MediaDisplay;
	/** The playback component with which this cue point is associated */
	public var playback:MediaPlayback;

	/**
	 * Public constructor.
	 */
	public function CuePoint(aName:String, aTime:Number) //, aDisplay:MediaDisplay, aPlayback:MediaPlayback)
	{
		name = aName;
		time = aTime;
//		display = aDisplay;
//		playback = aPlayback;
	}

	public function toString():String
	{
		return "CuePoint: " + name + " at " + time + " seconds";
	}

}
