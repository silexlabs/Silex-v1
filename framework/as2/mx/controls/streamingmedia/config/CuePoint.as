//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.config.MediaConfig;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.CuePoint
extends MovieClip
{
	private static var MS_FPS:Number = -1;

	// Temporary variables used during initialization
	public var name:String;
	public var row:Number;
	public var seconds:Number;
	
	// Data being tracked
	private var _row:Number;
	
	// Contained controls
	private var _nameTextField:TextField;
	private var _hoursTextField:TextField;
	private var _minutesTextField:TextField;
	private var _secondsTextField:TextField;
	private var _msTextField:TextField;
	private var _frameTextField:TextField;
	private var delimiterTextField:TextField;

	/** Prior FPS value; -1 for ms */
	private var priorFps:Number;

	public function CuePoint()
	{
		init();
	}
	
	public function toString():String
	{
		return "CuePoint: name=" + _nameTextField.text + ", seconds=" + 
			MediaConfig.composeSeconds(Number(_hoursTextField.text), 
			Number(_minutesTextField.text), Number(_secondsTextField.text), 
			Number(_msTextField.text)) + ", row=" + _row;
	}
	
	private function init():Void
	{
		// The following init parameters must be sent:
		// name, seconds, row.
//		Tracer.trace("CuePoint.init: " + name + ", " + seconds + ", " + row);
		_nameTextField.text = name;
		
		if (MediaConfig.isMs())
		{
			var hmsm:Array = MediaConfig.decomposeSeconds(seconds);
			_hoursTextField.text = hmsm[0];
			_minutesTextField.text = hmsm[1];
			_secondsTextField.text = hmsm[2];
			_msTextField.text = hmsm[3];

			_msTextField._visible = true;
			_frameTextField._visible = false;
			delimiterTextField.text = ".";
		}
		else
		{
			var hmsf:Array = MediaConfig.decomposeSecondsToFrames(seconds, MediaConfig.getFps());
			_hoursTextField.text = hmsf[0];
			_minutesTextField.text = hmsf[1];
			_secondsTextField.text = hmsf[2];
			_frameTextField.text = hmsf[3];

			_msTextField._visible = false;
			_frameTextField._visible = true;
			delimiterTextField.text = ":";
		}

		priorFps = MediaConfig.getFps();
		
		_row = row;
		
		// Now remove the init params
		delete this.name;
		delete this.seconds;
		delete this.row;
		
		// Create listeners for the text fields.
		// The onKillFocus is *not* called if the user clicks out of the
		// configuration panel.
		_nameTextField.onChanged = function() { _parent.updateData(); };
		_hoursTextField.onChanged = function() { _parent.updateData(); };
		_minutesTextField.onChanged = function() { _parent.updateData(); };
		_secondsTextField.onChanged = function() { _parent.updateData(); };
		_msTextField.onChanged = function() { _parent.updateData(); };
		_frameTextField.onChanged = function() { _parent.updateData(); };

		// Restrict the characters that can be entered into the text fields
		_nameTextField.restrict = "a-zA-Z0-9_\\-";
		_hoursTextField.restrict = "0-9";
		_minutesTextField.restrict = "0-9";
		_secondsTextField.restrict = "0-9";
		_msTextField.restrict = "0-9";
		_frameTextField.restrict = "0-9";

	
	}
	
	/**
	 * Push the data presented by this control up to the central repository.
	 */
	public function updateData():Void
	{
//		Tracer.trace("CuePoint.updateData: editor=" + );
		var seconds:Number;
		if (MediaConfig.isMs())
		{
			seconds = MediaConfig.composeSeconds(Number(_hoursTextField.text), 
				Number(_minutesTextField.text), Number(_secondsTextField.text), 
				Number(_msTextField.text));
		}
		else
		{
			seconds = MediaConfig.composeSecondsFromFrames(Number(_hoursTextField.text), 
				Number(_minutesTextField.text), Number(_secondsTextField.text), 
				Number(_frameTextField.text), MediaConfig.getFps());
		}
		MediaConfig.cuePointEditor.updateRow(_row, _nameTextField.text, seconds);
	}

	public function updateDisplay():Void
	{
		if (MediaConfig.isMs())
		{
			showMs();
		}
		else
		{
			showFrame();
		}
	}

	/**
	 * Show the cue point position in ms. If it was previously displayed in
	 * frames, then we need to convert the value. Otherwise, do nothing.
	 */
	public function showMs():Void
	{
		Tracer.trace("showMs");
		if (!wasUsingMs())
		{
			Tracer.trace("Updating from frame");
			// Calculate the ms value from the frame and prior fps values
			var ms:Number = 
				Math.round( (Number(_frameTextField.text) / MediaConfig.getFrameFps()) * 1000 );
			Tracer.trace("CuePoint.showMs: fps=" + MediaConfig.getFrameFps() + 
				", ms=" + ms + ", frame=" + _frameTextField.text);
			_msTextField.text = String(ms);
			_msTextField._visible = true;
			_frameTextField._visible = false;
			setUsingMs();
			delimiterTextField.text = ".";
		}
	}

	/**
	 * Show the cue point position in frames. If it was previously displayed in
	 * ms, then we need to convert the value from ms to frames. Otherwise, 
	 * we need to convert to a new fps value.
	 */
	public function showFrame():Void
	{
		Tracer.trace("showFrame");
		if (wasUsingMs())
		{
			// Calculate the frame value from the ms and fps value
			var frame:Number = Math.round( MediaConfig.getFps() * (Number(_msTextField.text) / 1000) );
			Tracer.trace("CuePoint.showFrame: fps=" + MediaConfig.getFps() + 
				", ms=" + _msTextField.text + ", frame=" + frame);
			_msTextField._visible = false;
			_frameTextField._visible = true;
			_frameTextField.text = String(frame);
			priorFps = MediaConfig.getFps();
			delimiterTextField.text = ":";
		}
	}

	private function wasUsingMs():Boolean
	{
		return (priorFps == MS_FPS);
	}
	private function setUsingMs():Void
	{
		priorFps = MS_FPS;
	}
}
