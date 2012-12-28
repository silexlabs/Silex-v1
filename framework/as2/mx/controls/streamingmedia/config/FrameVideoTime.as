//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.ComboBox;
import mx.controls.streamingmedia.config.MediaConfig;
import mx.controls.streamingmedia.config.VideoTime;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.FrameVideoTime
extends MovieClip
{
	private var hoursTextField:TextField;
	private var minutesTextField:TextField;
	private var secondsTextField:TextField;
	private var videoTime:VideoTime;
	private var frameTextField:TextField;
	private var otherFpsTextField:TextField;
	private var fpsComboBox:ComboBox;

	private var fpsHandler:Object;

	public function FrameVideoTime()
	{
		init();
	}

	private function init():Void
	{
		videoTime = VideoTime(this._parent);
	}

	private function initOnFrame1():Void
	{
		Tracer.trace("FrameVideoTime.initOnFrame1: start");
		// Initial values
		var x:Object = _root.xch;
		var totalTime:Number = x[videoTime.getVariableName("totalTime")];
		MediaConfig.activateFrameFps();
		var fps:Number = MediaConfig.getFps();

		var hmsf:Array = MediaConfig.decomposeSecondsToFrames(totalTime, fps);
		hoursTextField.text = hmsf[0];
		minutesTextField.text = hmsf[1];
		secondsTextField.text = hmsf[2];
		frameTextField.text = hmsf[3];

		// Add items to the combobox
		fpsComboBox.removeAll();
		fpsComboBox.addItem("30", 30);
		fpsComboBox.addItem("29.97", 29.97);
		fpsComboBox.addItem("25", 25);
		fpsComboBox.addItem("24", 24);
		fpsComboBox.addItem("23.976", 23.976);
		fpsComboBox.addItem("15", 15);
		fpsComboBox.addItem("12", 12);
		fpsComboBox.addItem("11.88", 11.88);
		fpsComboBox.addItem("10", 10);
		fpsComboBox.addItem("7.5", 7.5);
		fpsComboBox.addItem("5", 5);
		fpsComboBox.addItem("Other", "Other");

		// Position the combobox
		var len:Number = fpsComboBox.getLength();
		var cbIx:Number = null;
		for (var ix:Number = 0; ( (ix < len) && (cbIx == null) ); ix++)
		{
			if (fpsComboBox.getItemAt(ix).data == fps)
			{
				cbIx = ix;
				setOther(false);
				// Default setting for the other fps text field
				otherFpsTextField.text = "1";
			}
		}
		if (cbIx == null)
		{
			// "Other" is the last item in the list
			cbIx = len - 1;
			setOther(true);
			otherFpsTextField.text = String(fps);
		}
		fpsComboBox.setSelectedIndex(cbIx);

		fpsHandler = new Object();
		fpsHandler.form = this;
		fpsHandler.change = function(ev)
		{
			var item = this["form"].fpsComboBox.getSelectedItem();
			Tracer.trace("fps change: ev=" + ev + ", target=" + ev.target + 
				", item=" + item + ", data=" + item.data + ", label=" + item.label);
			this["form"].handleFps(item.data);
		};
		fpsComboBox.addEventListener("change", fpsHandler);

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
		frameTextField.displayControl = this;
		frameTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
		};
		otherFpsTextField.displayControl = this;
		otherFpsTextField.onChanged = function()
		{
			this["displayControl"].updateTime();
			MediaConfig.setFps(Number(this.text));
		};

		// Only let the user enter #'s into these fields
		hoursTextField.restrict = "0-9";
		minutesTextField.restrict = "0-9";
		secondsTextField.restrict = "0-9";
		frameTextField.restrict = "0-9";
		otherFpsTextField.restrict = "0-9.";

		Tracer.trace("FrameVideoTime.initOnFrame1: end");
	}

	private function isOther():Boolean
	{
		return otherFpsTextField._visible;
	}

	private function setOther(flag:Boolean):Void
	{
		otherFpsTextField._visible = flag;
	}

	public function handleFps(fps):Void
	{
		// Changing fps changes the # of seconds in the video
		Tracer.trace("handleFps: " + fps);
		setOther(String(fps) == "Other");
		updateTime();
		videoTime.updateData("fps", getFps());
		MediaConfig.setFps(getFps());
	}

	private function getFps():Number
	{
		var fps:Number;
		if (isOther())
		{
			fps = Number(otherFpsTextField.text);
		}
		else
		{
			fps = fpsComboBox.getSelectedItem().data;
		}
		return fps;
	}

	public function updateTime():Void
	{
		var fps:Number = getFps();
		var seconds:Number = MediaConfig.composeSecondsFromFrames( 
			Number(hoursTextField.text),
			Number(minutesTextField.text),
			Number(secondsTextField.text),
			Number(frameTextField.text),
			fps );
		videoTime.updateData("totalTime", seconds);
	}
}
