//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.CheckBox;
import mx.controls.Label;
import mx.controls.RadioButton;
import mx.controls.RadioButtonGroup;
import mx.controls.streamingmedia.config.MediaConfig;
import mx.controls.streamingmedia.config.VideoTime;
import mx.controls.streamingmedia.Tracer;

class mx.controls.streamingmedia.config.DisplayControls
{
	private static var PLAYER_VARIABLES:Object = {
		mediaType:"mediaType",
		contentPath:"contentPath",
		totalTime:"totalTime",
		autoSize:"autoSize",
		aspectRatio:"aspectRatio",
		autoPlay:"autoPlay",
		fps:"fps" };
	private static var DISPLAY_VARIABLES:Object = {
		mediaType:"mediaType",
		contentPath:"contentPath",
		totalTime:"totalTime",
		autoSize:"autoSize",
		aspectRatio:"aspectRatio",
		autoPlay:"autoPlay",
		fps:"fps" };

	/** The variable names to use */
	private var _variableNames:Object;

	private var videoTime:VideoTime;
	private var _autoplayCheckBox:CheckBox;
	private var _autosizeCheckBox:CheckBox;
	private var _aspectRatioCheckBox:CheckBox;
	private var videoTimeLabel:Label;
	private var urlLabel:Label;
	private var _urlTextField:TextField;
	private var flvRadioButton:RadioButton;
	private var mp3RadioButton:RadioButton;
	private var mediaTypeGroup:RadioButtonGroup;

	private var mediaTypeHandler:Object;
	
	public function DisplayControls()
	{
		init();
	}
	
	private function init():Void
	{
		_variableNames = ( (MediaConfig.mode == "player") ? PLAYER_VARIABLES : DISPLAY_VARIABLES );
//		Tracer.trace("DisplayControls.init: end");
	}
	
	public function getVariableName(id:String):String
	{
//		Tracer.trace("DisplayControls.getVariableName: " + id + "=" + _variableNames[id]);
		return _variableNames[id];
	}
	
	private function initOnFrame1():Void
	{
		var x:Object = _root.xch;
		
		// Initial values
		_urlTextField.text = x[getVariableName("contentPath")];
//		Tracer.trace("urlTextInput=" + urlTextInput + ", url=" + x[getVariableName("mediaUrl")]);

		var isMP3:Boolean = (x[getVariableName("mediaType")] == "MP3");
		if (isMP3)
		{
			mp3RadioButton.setSelected(true);
		}
		else
		{
			// FLV is default value
			if (x[getVariableName("mediaType")] != "FLV")
			{
				updateData("mediaType", "FLV");
			}
			flvRadioButton.setSelected(true);

		}

		// Get a reference to the radio button group
		mediaTypeGroup = this[ flvRadioButton.groupName ];
//		Tracer.trace("flvRadioButton=" + flvRadioButton + ", groupName=" + 
//			flvRadioButton.groupName + ", mediaTypeGroup=" + mediaTypeGroup);
		// Create an event listener for that group
		mediaTypeHandler = new Object();
		mediaTypeHandler.form = this;
		mediaTypeHandler.click = function(ev)
		{
//			Tracer.trace("media type changed!");
			this["form"].handleMediaType();
		};
		mediaTypeGroup["addEventListener"]("click", mediaTypeHandler);

		_autoplayCheckBox.selected = x[getVariableName("autoPlay")];
		_autosizeCheckBox.selected = x[getVariableName("autoSize")];
		_aspectRatioCheckBox.selected = x[getVariableName("aspectRatio")];

		uiChanges();
	
		// TextField change handlers
		_urlTextField.form = this;
		_urlTextField.onChanged = function()
		{
			this["form"].updateData("contentPath", this.text);
		};

//		Tracer.trace("DisplayControls.initOnFrame1: end");
	}

	/**
	 * Handle a change to the media type radio buttons
	 */
	public function handleMediaType():Void
	{
		var aType:String = getMediaType();
//		Tracer.trace("new media type=" + aType);
		updateData("mediaType", aType);
		videoTime.refresh();
		uiChanges();
	}


	/**
	 * Update the UI controls based on (a) the mp3 media type and (b)
	 * the autosize setting.
	 */
	private function uiChanges()
	{
		var isMP3:Boolean = (getMediaType() == "MP3");
		var isAuto:Boolean = _autosizeCheckBox.selected;
		if (isMP3)
		{
			// De-select and disable the autosize and aspect ratio boxes
			updateData("aspectRatio", false);
			_aspectRatioCheckBox.selected = false;
			_aspectRatioCheckBox.enabled = false;
			updateData("autoSize", false);
			_autosizeCheckBox.selected = false;
			_autosizeCheckBox.enabled = false;
		}
		else
		{
			// Enable the autosize and aspect ratio boxes
			_autosizeCheckBox.enabled = true;
			if (isAuto)
			{
				updateData("aspectRatio", true);
				_aspectRatioCheckBox.selected = true;
			}
			_aspectRatioCheckBox.enabled = (!isAuto);
		}
	}


	/**
	 * @return The selected media type
	 */
	private function getMediaType():String
	{
		var mediaType:String = "";
		if (flvRadioButton.selected)
		{
			mediaType = flvRadioButton.data;
		}
		else if (mp3RadioButton.selected)
		{
			mediaType = mp3RadioButton.data;
		}

		return mediaType;
	}


	public function handleAutosize(isAuto:Boolean):Void
	{
//		Tracer.trace("autosize=" + isAuto);
		updateData("autoSize", isAuto);
		uiChanges();
	}

	
	public function handleAutoplay(isAuto:Boolean):Void
	{
//		Tracer.trace("autoplay=" + isAuto);
		updateData("autoPlay", isAuto);
	}

	public function handleAspectRatio(respect:Boolean):Void
	{
//		Tracer.trace("autoplay=" + respect);
		updateData("aspectRatio", respect);
	}

	/**
	 * Update a data item to the xch object.
	 */
	public function updateData(id:String, value:Object):Void
	{
		Tracer.trace("DisplayControls.updateData: " + getVariableName(id) +
			"=" + value); // + ", into " + _root.xch + 
//			", prior value=" + _root.xch[getVariableName(id)]);
		_root.xch[getVariableName(id)] = value;
	}
	
}