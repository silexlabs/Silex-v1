//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.CheckBox;
import mx.controls.Label;
import mx.controls.streamingmedia.config.DisplayControls;
import mx.controls.streamingmedia.config.FrameVideoTime;
import mx.controls.streamingmedia.config.MediaConfig;
import mx.controls.streamingmedia.config.MsVideoTime;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.VideoTime
extends MovieClip
{
	private var msCheckBox:CheckBox;
	private var videoTimeLabel:Label;
	private var msVideoTime:MsVideoTime;
	private var frameVideoTime:FrameVideoTime;
	private var displayControls:DisplayControls;
	/** True if ms display is showing; false if frame display is */
	private var showingMs:Boolean;

	private var msHandler:Object;
	
	public function VideoTime()
	{
		init();
	}
	
	private function init():Void
	{
		displayControls = DisplayControls(this._parent);
	}
	
	
	private function initOnFrame1():Void
	{
		Tracer.trace("VideoTime.initOnFrame1: start");
		refresh();

		msHandler = new Object();
		msHandler.form = this;
		msHandler.click = function(ev)
		{
			this["form"].handleMsCheckBox(ev.target.getSelected());
		};
		msCheckBox.addEventListener("click", msHandler);

		Tracer.trace("VideoTime.initOnFrame1: end");

	}

	public function refresh():Void
	{
		// Refresh the display
		var x:Object = _root.xch;
		Tracer.trace("VideoTime.refresh: mediaType=" + 
			x[getVariableName("mediaType")] + ", fps=" + x[getVariableName("fps")]);

		if (x[getVariableName("mediaType")] == "MP3")
		{
			// MP3
			this.gotoAndStop("ms");
			this._visible = false;
			// Set the ms flag so that cue points will properly use ms values
			MediaConfig.useMs();
		}
		else
		{
			// FLV
			this._visible = true;
			if (x[getVariableName("fps")] == "ms")
			{
				// User chose ms display
				MediaConfig.useMs();
				this.gotoAndStop("ms");
				msCheckBox.setState(true);
				showingMs = true;
			}
			else
			{
				MediaConfig.setFps( x[getVariableName("fps")] );
				this.gotoAndStop("frameName");
				msCheckBox.setState(false);
				showingMs = false;
			}
		}
	}

	public function getDisplayControls():DisplayControls
	{
		return displayControls;
	}

	public function getVariableName(id:String):String
	{
		return displayControls.getVariableName(id);
	}

	public function updateData(id:String, value:Object):Void
	{
		displayControls.updateData(id, value);
	}

	/**
	 * Show the milliseconds display.
	 */
	public function showMilliseconds():Void
	{
		Tracer.trace("VideoTime.showMilliseconds");
		if (!showingMs)
		{
			this.gotoAndStop("ms");
			showingMs = true;
			updateData( "fps", "ms" );
			MediaConfig.useMs();
		}
	}

	public function showFrames():Void
	{
		Tracer.trace("VideoTime.showFrames");
		if (showingMs)
		{
			this.gotoAndStop("frameName");
			showingMs = false;
			MediaConfig.activateFrameFps();
		}
	}

	public function handleMsCheckBox(selected):Void
	{
		if (selected)
		{
			// Show the ms display
			showMilliseconds();
		}
		else
		{
			// Show the frame display
			showFrames();
		}
	}

}