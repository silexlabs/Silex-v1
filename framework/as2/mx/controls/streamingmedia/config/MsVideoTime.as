//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.config.MediaConfig;
import mx.controls.streamingmedia.config.VideoTime;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.MsVideoTime
extends MovieClip
{
	private var hoursTextField:TextField;
	private var minutesTextField:TextField;
	private var secondsTextField:TextField;
	private var msTextField:TextField;
	private var videoTime:VideoTime;

	public function MsVideoTime()
	{
		init();
	}

	private function init():Void
	{
		Tracer.trace("MsVideoTime.init: start");
		videoTime = VideoTime(this._parent);

		// Initial values
		var x:Object = _root.xch;
		var totalTime:Number = x[videoTime.getVariableName("totalTime")];
		var hms:Array = MediaConfig.decomposeSeconds(totalTime);
		hoursTextField.text = hms[0];
		minutesTextField.text = hms[1];
		secondsTextField.text = hms[2];
		msTextField.text = hms[3];

		// TextField change handlers
		hoursTextField.displayControl = this;
		hoursTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
		};
		minutesTextField.displayControl = this;
		minutesTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
		};
		secondsTextField.displayControl = this;
		secondsTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
		};
		msTextField.displayControl = this;
		msTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
		};

		// Only let the user enter #'s into these fields
		hoursTextField.restrict = "0-9";
		minutesTextField.restrict = "0-9";
		secondsTextField.restrict = "0-9";
		msTextField.restrict = "0-9";

		Tracer.trace("MsVideoTime.init: end");
	}

	public function updateTime():Void
	{
		var seconds:Number = MediaConfig.composeSeconds( 
			Number(hoursTextField.text),
			Number(minutesTextField.text),
			Number(secondsTextField.text),
			Number(msTextField.text) );
		videoTime.updateData("totalTime", seconds);
	}
	

}
