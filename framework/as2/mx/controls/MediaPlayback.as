//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.MediaController;
import mx.controls.MediaDisplay;
import mx.controls.streamingmedia.Chrome;
import mx.controls.streamingmedia.CuePoint;
import mx.controls.streamingmedia.FullScreenToggle;
import mx.controls.streamingmedia.ICuePointHolder;
import mx.controls.streamingmedia.StreamingMediaConstants;
import mx.core.UIComponent;

[RequiresDataBinding(true)]
[IconFile("MediaPlayback.png")]

// Event metadata a la C#
/**
 * @tiptext change event
 * @helpid 3480
 */
[Event("change")]
/**
 * @tiptext progress event
 * @helpid 3485
 */
[Event("progress")]
/**
 * @tiptext cuePoint event
 * @helpid 3483
 */
[Event("cuePoint")]
/**
 * @tiptext complete event
 * @helpid 3482
 */
[Event("complete")]
/**
 * @tiptext play event
 * @helpid 3487
 */
[Event("play")]
/**
 * @tiptext start event
 * @helpid 3488
 */
[Event("start")]
/**
 * @tiptext pause event
 * @helpid 3489
 */
[Event("pause")]
/**
 * @tiptext playheadChange event
 * @helpid 3484
 */
[Event("playheadChange")]
/**
 * @tiptext volume event
 * @helpid 3486
 */
[Event("volume")]
/**
 * @tiptext resizeVideo event
 * @helpid ????
 */
[Event("resizeVideo")]

/**
 * MediaPlayback is a full-featured displayer and controller of
 * streaming media. It plays FLV and MP3 files.
 *
 * @author Andrew Guldman
 * @tiptext	MediaPlayback is a displayer and controller of streaming media
 * @helpid 3492
 */
class mx.controls.MediaPlayback
extends UIComponent
implements ICuePointHolder
{
	// This set of properties is for FUIComponent
	static var symbolName:String = "MediaPlayback";
	static var symbolOwner:Object = mx.controls.MediaPlayback;
	var	className:String = "MediaPlayback";
//#include "../core/MediaComponentVersion.as"

	var clipParameters:Object =
	{
		mediaType: "FLV",
		contentPath: "",
		totalTime: 0,
		autoSize: true,
		autoPlay: true,
		controllerPolicy: "auto",
		initCuePointNames: new Array(),
		initCuePointTimes: new Array(),
		controlPlacement: "bottom",
		fps: 30
	};


	// The rest of the properties do not pertain to FUIComponent
	private static var TOP_CONTROL_POSITION:String = "top";
	private static var BOTTOM_CONTROL_POSITION:String = "bottom";
	private static var LEFT_CONTROL_POSITION:String = "left";
	private static var RIGHT_CONTROL_POSITION:String = "right";

	/** The horizontal border around the edge of the display */
	private static var H_BORDER:Number = 8;
	private static var V_BORDER:Number = 8;

	// Initialization variables. They are only used to initialize the
	// properties of the player.
	/**
	 * The frames per second is only used for video, and is only used in
	 * the configuration UI. The config UI uses it to calculate
	 * milliseconds based on frame number.
	 */
	[Inspectable(defaultValue=30)]
	public var fps:Number;
	private var _mediaType:String;
	private var _contentPath:String;
	private var _totalTime:Number;
	private var _autoSize:Boolean;
	private var _aspectRatio:Boolean;
	private var _autoPlay:Boolean;
	private var _controllerPolicy:String;
	[Inspectable]
	public var initCuePointNames:Array;
	[Inspectable]
	public var initCuePointTimes:Array;

	private var _display:MediaDisplay;
	private var _controller:MediaController;

	private var _deadPreview:MovieClip;

	private var _chrome:Chrome;

	/**
	 * The position of the controls relative to the display.
	 * top, bottom, left, or right.
	 */
	private var _controlPlacement:String;

	/** Is the component enabled? */
	private var _enabled:Boolean;

	/** Is the component in the middle of setting the media? */
	private var _settingMedia:Boolean = false;

	/**
	 * Constructor
	 */
	public function MediaPlayback()
	{
	}

	// The next group of functions is connected to FUIComponent and FUIObject

	/**
	 * Initialize the player.
	 */
	function init(Void):Void
	{
//		Tracer.trace("MediaPlayback.init");

		initializeParameters();

		// Read the size of the dead preview before calling super.init()
		// because that function sets _xscale and _yscale to 100.
		var piWidth:Number = this._width;
		var piHeight:Number = this._height;
		// Now that we've got the height and width, hide the dead preview
		this._deadPreview._visible = false;

		super.init();

		// Check to see if the properties were properly initialized
		/*
		Tracer.trace("MediaPlayback.init: Initialized properties:");
		Tracer.trace("  contentPath=" + _contentPath);
		Tracer.trace("  mediaType=" + _mediaType);
		Tracer.trace("  autoSize=" + _autoSize);
		Tracer.trace("  aspectRatio=" + _aspectRatio);
		Tracer.trace("  autoPlay=" + _autoPlay);
		Tracer.trace("  totalTime=" + _totalTime);
		Tracer.trace("  initCuePointNames=" + initCuePointNames);
		Tracer.trace("  initCuePointTimes=" + initCuePointTimes);
		Tracer.trace("  controlPlacement=" + _controlPlacement);
		Tracer.trace("  controllerPolicy=" + _controllerPolicy);
		*/
		// Create and configure the display
		var initObj:Object = { contentPath:_contentPath,
			mediaType:_mediaType, autoPlay:_autoPlay,
			autoSize:_autoSize, aspectRatio:_aspectRatio, totalTime:_totalTime,
			initCuePointNames:initCuePointNames,
			initCuePointTimes:initCuePointTimes };
		this.attachMovie("MediaDisplay", "_display", 1, initObj);

		// Create and configure the controller
		var playControl:String = ( _autoPlay ?  StreamingMediaConstants.PAUSE_PLAY_CONTROL :  StreamingMediaConstants.PLAY_PLAY_CONTROL );
		var bgStyle:String = ( (_mediaType == "MP3") ? "default" : "none" );
		var isHoriz:Boolean = ( (controlPlacement == "top") || (controlPlacement == "bottom") );
		initObj = { horizontal:isHoriz, controllerPolicy:_controllerPolicy, backgroundStyle:bgStyle, activePlayControl:playControl};
		this.attachMovie("MediaController", "_controller", 2, initObj);

		// Now restore the width and height that the user wanted
		this.setSize(piWidth, piHeight, true);

		// Create listeners between the display and controller
		_display.associateController(_controller);

		// The player will listen for all the events broadcast by the display
		// and controller components. In most cases, all it will rebroadcast them.
		// This makes it so users can listen to the player for the events
		// rather than the subcomponents.
		_controller.addEventListener("click", this);
		_controller.addEventListener("playheadChange", this);
		_controller.addEventListener("volume", this);
		_controller.addEventListener("scrubbing", this);
		_display.addEventListener("change", this);
		_display.addEventListener("progress", this);
		_display.addEventListener("start", this);
		_display.addEventListener("resizeVideo", this);
		_display.addEventListener("cuePoint", this);
		_display.addEventListener("complete", this);

		// By default it is enabled
		_enabled = true;

		// Now set up tab support
		this.tabEnabled = false;
		this.tabChildren = true;

		// Create the UI decorations
		this.redraw(true);

	}


	/**
	 * Create default values for absent parameters
	 */
	private function initializeParameters():Void
	{
		if (mediaType == null)
		{
			mediaType = "FLV";
		}
		if (totalTime == null)
		{
			totalTime = 0;
		}
		if (contentPath == null)
		{
			contentPath = "";
		}
		if (autoPlay == null)
		{
			autoPlay = true;
		}
		if (autoSize == null)
		{
			autoSize = true;
		}
		if (aspectRatio == null)
		{
			aspectRatio = true;
		}
		if (controllerPolicy == null)
		{
			controllerPolicy = "auto";
		}
		if (controlPlacement == null)
		{
			controlPlacement = "bottom";
		}
	}


	/**
	 * Draw the component. This is called upon initialization and when
	 * the component is invalidated.
	 */
	function draw(Void):Void
	{
//		Tracer.trace("MediaPlayback.draw(): autoSize=" + _autoSize);
		if (_mediaType == "MP3")
		{
			this.drawMP3();
		}
		else
		{
			// Video
			this.drawFLV();
		}

	}

	// The remaining functions are independent of FUIComponent and FUIObject


	private function drawMP3():Void
	{
		// Autosize is ignored for mp3. Always use the specified size.
		// No drawing is done for mp3: the controller drawing is used.
		// Position the display
		_display._x = 0;
		_display._y = 0;
		// Position the controller
		_controller._x = 0;
		_controller._y = 0;
		// Size the controller
		_controller.setSize(width, height, true);
		// The controller should draw its own chrome
		_controller.backgroundStyle = "default";
		// The mp3 controller always opens down or right
		_controller.setOpenUpOrLeft(false);
		// Refresh the controller
		_controller.redraw(true);
		// Hide the player's own chrome
		_chrome.visible = false;
		_chrome.showToggles = false;
		_chrome.draw();
	}

	private function drawFLV():Void
	{
//		Tracer.trace("MediaPlayback.drawFLV()");

		// Draw the chrome
		drawChrome();

		// Position the controller. The controller has built-in margins.
		drawFLVController();

		// Position and size the display component
		drawFLVDisplay();
	}

	private function drawChrome():Void
	{
		var closedChromeWd:Number;
		var closedChromeHt:Number;
		if (_controller.horizontal)
		{
			closedChromeHt = height - _controller.getMinimumOpenHeight() + _controller.getMinimumClosedHeight();
			closedChromeWd = width;
		}
		else
		{
			closedChromeWd = width - _controller.getMinimumOpenWidth() + _controller.getMinimumClosedWidth();
			closedChromeHt = height;
		}
		var openChromeWd:Number = width;
		var openChromeHt:Number = height;
		var chromeWd:Number = ( (_controllerPolicy == "on") ? openChromeWd : closedChromeWd );
		var chromeHt:Number = ( (_controllerPolicy == "on") ? openChromeHt : closedChromeHt );

		// Keep the end position fixed rather than the start position
		var fixedEnd:Boolean = (isTopControlPlacement() || isLeftControlPlacement());

		_chrome._x = 0;
		_chrome._y = 0;
		if (isTopControlPlacement() && ((_controllerPolicy == "off") || (_controllerPolicy == "auto")))
		{
			_chrome._y = _controller.getMinimumOpenHeight() - _controller.getMinimumClosedHeight();
		}
		else if (isLeftControlPlacement() && ((_controllerPolicy == "off") || (_controllerPolicy == "auto")))
		{
			_chrome._x = _controller.getMinimumOpenWidth() - _controller.getMinimumClosedWidth();
		}

		_chrome.visible = true;
		_chrome.showToggles = true;
		_chrome.setSize(chromeWd, chromeHt);
		_chrome.draw();
		// Add the chrome as a second chrome for the controller so it will animate properly
		addSecondChrome(_chrome, closedChromeHt, openChromeHt, closedChromeWd, openChromeWd, fixedEnd);
	}

	/**
	 * Position the controller for an FLV player.
	 * The placement is dictated by the controlPlacement member.
	 */
	private function drawFLVController():Void
	{
		if (isBottomControlPlacement())
		{
			// Size the controller
			_controller.setSize( width, _controller.getMinimumOpenHeight(), true);
			_controller.horizontal = true;
			_controller._x = 0;
			_controller._y = height - _controller.height;
		}
		else if (isTopControlPlacement())
		{
			// Size the controller
			_controller.setSize( width, _controller.getMinimumOpenHeight(), true);
			_controller.horizontal = true;
			_controller.setOpenUpOrLeft(true);
			_controller._x = 0;
			if (_controllerPolicy == "on")
			{
				_controller._y = 0;
			}
			else
			{
				_controller._y = _controller.height - _controller.getMinimumClosedHeight();
			}
		}
		else if (isRightControlPlacement())
		{
			// Size the controller
			_controller.setSize( _controller.getMinimumOpenWidth(), height, true );
			_controller.horizontal = false;
			_controller._x = width - _controller.width;
			_controller._y = 0;
		}
		else if (isLeftControlPlacement())
		{
			// Size the controller
			_controller.setSize( _controller.getMinimumOpenWidth(), height, true );
			_controller.horizontal = false;
			_controller.setOpenUpOrLeft(true);
			if (_controllerPolicy == "on")
			{
				_controller._x = 0;
			}
			else
			{
				_controller._x = _controller.width - _controller.getMinimumClosedWidth();
			}
			_controller._y = 0;
		}
		// The controller should *not* draw its own chrome
		_controller.backgroundStyle = "none";
		_controller.invalidate();
//		Tracer.trace("MediaPlayback.drawFLVController: " + _controller.getDisplayWidth() +
//			"x" + _controller.getDisplayHeight() + " at (" + _controller._x + "," + _controller._y + ")");
	}

	private function drawFLVDisplay():Void
	{
		// Size the display
		displaySetProperSize();

		// Center the display
		var xOffset:Number = 0;
		var yOffset:Number = 0;
		if (isTopControlPlacement())
		{
			yOffset = _controller.height;
		}
		else if (isLeftControlPlacement())
		{
			xOffset = _controller.width;
		}
		_display._x = xOffset + H_BORDER;
		_display._y = yOffset + V_BORDER;
//		Tracer.trace("MediaPlayback.drawFLVDisplay: " + _display.width + "x" + _display.height +
//			" at (" + _display._x + "," + _display._y +
//			"), canvas=" + canvasW + "x" + canvasH + ", offset=(" + xOffset +
//			"," + yOffset + ")");
	}

	private function displaySetProperSize():Void
	{
		// Make it fill the available display space.
		// It will preserve its own aspect ratio (or not) as appropriate.
		var canvasW:Number = width - (H_BORDER * 2);
		var canvasH:Number = height - (V_BORDER * 2);
		if (isBottomControlPlacement() || isTopControlPlacement())
		{
			// Horizontal
//			Tracer.trace("MediaPlayback.displaySetProperSize: horizontal: controller.h=" + _controller.height);
			canvasH -= _controller.height;
		}
		else
		{
//			Tracer.trace("MediaPlayback.displaySetProperSize: vertical: controller.w=" + _controller.width);
			canvasW -= _controller.width;
//			Tracer.trace("displaySetProperSize: canvas: _display.width=" + _display.width +
//				", controller.width=" + _controller.width +
//				", _display.height=" + _display.height);
		}
//		Tracer.trace("MediaPlayback.displaySetProperSize: horizontal: controller.h=" + _controller.height);

		if ( (_autoSize) && ( (_display.preferredWidth > canvasW) || (_display.preferredHeight > canvasH) ) )
		{
			// We need to shrink the display to fit the display even though the
			// user wants to autoSize it.
			_display.autoSize = false;
			_display.aspectRatio = true;
		}
		else
		{
			// Cascade the autoSize and aspectRatio properties to the display
			_display.autoSize = _autoSize;
			_display.aspectRatio = _aspectRatio;
		}

		_display.setSize( canvasW, canvasH, true );
		_display.invalidate();
	}

	/**
	 * Handle all the events broadcast by the display and controller
	 * components. Rebroadcast them.
	 *
	 * Special attention is paid to a "start" event from the display component.
	 * This component will listen to see when playback of the media starts.
	 * It will resize the video at that time.
	 */
	public function handleEvent(ev):Void
	{
//		Tracer.trace("MediaPlayback.handleEvent: Rebroadcasting type=" + ev.type);
		// Re-target this event so it looks like it came from here (the
		// MediaPlayback) instead of from the MediaDisplay.
		ev.target = this;
		dispatchEvent(ev);
		if (ev.type == "start")
		{
			if ( _mediaType == "FLV" )
			{
//				Tracer.trace("handleEvent: handling first start event from display");
				// FLV media started playing for the first time.
				// Size and position the display component based on the size of the media.
				// Stop hiding the video object
				_display.makeVideoVisible = true;
				this.redraw(true);
			}
			else if (_mediaType == "MP3")
			{
				// Make sure the controller is in sync with the display, in case autoPlay is set.
				_controller.setPlaying(_display.playing);
			}
		}
		if (ev.type == "resizeVideo")
		{
			if ( _mediaType == "FLV" )
			{
				// Size and position the display component based on the size of the media.
				// Stop hiding the video object
				_display.makeVideoVisible = true;
				this.redraw(true);
			}
		}
	}


	/**
	 * @return A string representation of this object
	 */
	public function toString():String
	{
		return "MediaPlayback: media=" + _contentPath;
	}

	public function getController():MediaController
	{
		return _controller;
	}

	public function isRtmp(mediaUrl:String):Boolean
	{
		if (_display != null)
		{
			return _display.isRtmp(mediaUrl);
		}
		return false;
	}


	/**
	 * Load the media without playing it.
	 * @tiptext Load the media without playing it
	 * @helpid 3475
	 */
	public function load():Void
	{
		_display.load();
	}

	/**
	 * Play the media starting at the specified starting point. If the media
	 * hasn't yet been loaded, load it.
	 *
	 * @param startingPoint The number of seconds into the media to start at.
	 *        This is an optional parameter. If omitted, playing will occur
	 *        at the current playhead position.
	 * @tiptext Plays the media from the given starting point
	 * @helpid 3476
	 */
	public function play(startingPoint:Number):Void
	{
		_display.play(startingPoint);
		_controller.setPlaying(true);
	}

	/**
	 * Stop playback of the media without moving the playhead.
	 * @tiptext Pauses the playhead at the current location
	 * @helpid 3477
	 */
	public function pause():Void
	{
		_display.pause();
		_controller.setPlaying(false);
	}

	/**
	 * Stop playback of the media and reset the playhead to zero.
	 * @tiptext Stops the playhead and moves it to the beginning of the media
	 * @helpid 3493
	 */
	public function stop():Void
	{
		_display.stop();
		_controller.setPlaying(false);
	}

	/**
	 * @tiptext Determines whether the display sizes itself according to the preferred size of the media
	 * @helpid 3543
	 */
	[Inspectable(defaultValue=true)]
	public function get autoSize():Boolean
	{
		if (_display != null)
		{
			_autoSize = _display.autoSize;
		}
		return _autoSize;
	}
	public function set autoSize(flag:Boolean):Void
	{
		_autoSize = flag;
		if (_display != null)
		{
			displaySetProperSize();
			invalidate();
		}
	}


	/**
	 * @tiptext Determines whether a Display or Playback instance maintains aspect ratio
	 * @helpid 3451
	 */
	[Inspectable(defaultValue=true)]
	public function get aspectRatio():Boolean
	{
		if (_display != null)
		{
			_aspectRatio = _display.aspectRatio;
		}
		return _aspectRatio;
	}
	public function set aspectRatio(flag:Boolean):Void
	{
		_aspectRatio = flag;
		if (_display != null)
		{
			displaySetProperSize();
			invalidate();
		}
	}


	/**
	 * @tiptext Determines whether media will immediately begin to buffer and play
	 * @helpid 3452
	 */
	[Inspectable(defaultValue=true)]
	public function get autoPlay():Boolean
	{
		if (_display != null)
		{
			_autoPlay = _display.autoPlay;
		}
		return _autoPlay;
	}
	public function set autoPlay(flag:Boolean):Void
	{
		_autoPlay = flag;
		if (_display != null)
		{
			_display.autoPlay = flag;
		}
	}


	/**
	 * @return The playhead position, measued in seconds since the start.
	 * @tiptext Current position of the playhead in seconds
	 * @helpid 3463
	 */
	[ChangeEvent("change")]
	[Bindable]	
	public function get playheadTime():Number
	{
		return _display.playheadTime;
	}
	public function set playheadTime(position:Number):Void
	{
		_display.playheadTime = position;
	}

	/**
	 * @tiptext Holds the relative path and filename of the media to be streamed
	 * @helpid 3457
	 */
	[Inspectable(defaultValue="")]
	[ChangeEvent("start")]
	[Bindable]
	public function get contentPath():String
	{
		if (_display != null)
		{
			_contentPath = _display.contentPath;
		}
		return _contentPath;
	}
	public function set contentPath(aUrl:String):Void
	{
		_contentPath = aUrl;
		if (_display != null)
		{
			if (!_settingMedia)
				_display.contentPath = aUrl;
			_mediaType = _display.mediaType;
		}
	}


	/**
	 * @return The most recent volume setting
	 * @tiptext The volume setting in value range from 0 to 100
	 * @helpid 3468
	 */
	[ChangeEvent("volume")]
	[Bindable]
	public function get volume():Number
	{
		return _display.volume;
	}
	public function set volume(aVol:Number):Void
	{
		_display.volume = aVol;
		_controller.volume = aVol;
	}

	/**
	 * @tiptext Is the instance trying to play
	 * @helpid 3464
	 */
	[ChangeEvent("change")]
	[Bindable]
	public function get playing():Boolean
	{
		return _display.playing;
	}

	/**
	 * @tiptext The preferred width of the display
	 * @helpid 3466
	 */
	public function get preferredWidth():Number
	{
		return _display.preferredWidth;
	}

	/**
	 * @tiptext The preferred height of the display
	 * @helpid 3465
	 */
	public function get preferredHeight():Number
	{
		return _display.preferredHeight;
	}

	/**
	 * @tiptext Number of bytes already loaded
	 * @helpid 3455
	 */
	[ChangeEvent("progress")]
	[Bindable]
	public function get bytesLoaded():Number
	{
		return _display.bytesLoaded;
	}

	/**
	 * @tiptext Number of bytes to be loaded
	 * @helpid 3456
	 */
	[ChangeEvent("start")]
	[Bindable]
	public function get bytesTotal():Number
	{
		return _display.bytesTotal;
	}

	/**
	 * @tiptext Type of media to be played
	 * @helpid 3462
	 */
	[Inspectable(enumeration="FLV,MP3", defaultValue="FLV")]
	[ChangeEvent("start")]
	[Bindable]
	public function get mediaType():String
	{
		if (_display != null)
		{
			// Make sure the value is current
			_mediaType = _display.mediaType;
		}
		return _mediaType;
	}

	/**
	 * This should only be called to configure the component initially.
	 * It does not work at runtime.
	 */
	public function set mediaType(aType:String):Void
	{
		// Save this locally so it can stored prior to the existance of the
		// _display component.
		_mediaType = aType;
		if (_display != null)
		{
			_display.mediaType = aType;
			// Show or hide the controller chrome
			if (aType == "MP3")
			{
				_controller.backgroundStyle = "none";
				removeSecondChrome();
			}
			else
			{
				_controller.backgroundStyle = "default";
				drawChrome();
			}
			invalidate();
		}
	}

	/**
	 * Set both the url and the type in a single call.
	 * @tipText	Associates the contentPath and mediaType to the MediaPlayback
	 * @helpid 3494
	 */
	public function setMedia(aUrl:String, aType:String):Void
	{
		_settingMedia = true;
		var priorType:String = _mediaType;

		_display.setMedia(aUrl, aType);

		if (aType == null)
		{
			// Try to deduce the type from the content path
			var last3:String = aUrl.substr(-3);
			if ( (last3 == "flv") || (last3 == "FLV") )
			{
				aType = "FLV";
			}
			else if ( (last3 == "mp3") || (last3 == "MP3") )
			{
				aType = "MP3";
			}
			else
			{
				// Leave the type unchanged
				aType = _mediaType;
			}
		}

		if (priorType != aType)
		{
			this.mediaType = aType;
		}
		this.contentPath = aUrl;
		_settingMedia = false;
	}


	/**
	 * @return The total time of the media. For mp3 files, this is a
	 * property of the Sound object. For video, it is be a property
	 * that is manually set by the author.
	 * @tiptext The total length of the media in seconds
	 * @helpid 3467
	 */
	[Inspectable(defaultValue=0)]
	[ChangeEvent("start")]
	[Bindable]
	public function get totalTime():Number
	{
		if (_display != null)
		{
			_totalTime = _display.totalTime;
		}
		return _totalTime;
	}

	public function set totalTime(aTime:Number):Void
	{
		_totalTime = aTime;
		if (_display != null)
		{
			_display.totalTime = _totalTime;
		}
	}

	// Functions that implement the ICuePointHolder interface
	/**
	 * @return An array of CuePoint objects. All the CuePoints associated
	 * with this object.
	 * @tiptext Returns the cuePoint object
	 * @helpid 3474
	 */
	public function getCuePoints():Array
	{
		return _display.getCuePoints();
	}

	/**
	 * @return An array of CuePoint objects. All the CuePoints associated
	 * with this object.
	 * @tiptext Array of cuepoint objects
	 * @helpid 3460
	 */
	public function get cuePoints():Array
	{
		return getCuePoints();
	}

	public function setCuePoints(cp:Array):Void
	{
		// Assign the playback property of each cue point
		for (var ix:Number = 0; ix < cp.length; ix++)
		{
			cp[ix].playback = this;
		}
		_display.cuePoints = cp;
	}
	public function set cuePoints(cp:Array):Void
	{
		setCuePoints(cp);
	}

	/**
	 * @param pointName The name of the cue point to find.
	 * @return The CuePoint associated with this object that has the given
	 * name.
	 */
	public function getCuePoint(pointName:String):CuePoint
	{
		return _display.getCuePoint(pointName);
	}

	/**
	 * Add the given cue point.
	 * @param aCuePoint The CuePoint to add.
	 * @tiptext Adds a cue point object to the playaback instance
	 * @helpid 3469
	 */
	public function addCuePoint(aName:String, aTime:Number):Void
	{
		var aCuePoint:CuePoint = new CuePoint(aName, aTime);
		aCuePoint.playback = this;
		this.addCuePointObject( aCuePoint );
	}

	public function addCuePointObject(aCuePoint:CuePoint):Void
	{
		aCuePoint.playback = this;
		_display.addCuePointObject(aCuePoint);
	}

	/**
	 * Remove the given cue point.
	 * @param aCuePoint The CuePoint to remove.
	 * @tiptext Delete a specific cuepoint associated with this instance
	 * @helpid 3479
	 */
	public function removeCuePoint(aCuePoint:CuePoint):Void
	{
		_display.removeCuePoint(aCuePoint);
	}

	/**
	 * Remove all the CuePoints.
	 * @tiptext Deletes all cuepoint objects associated with this instance
	 * @helpid 3478
	 */
	public function removeAllCuePoints():Void
	{
		_display.removeAllCuePoints();
	}

    /**
     * Retrieve the most recently fired cue point.
     * Unbindable since binding cannot handle structures.
     */
    public function get mostRecentCuePoint():CuePoint
    {
        return _display.mostRecentCuePoint;
    }
    
    /**
     * Retrieve the most recently fired cue point name.
     */
    [ChangeEvent("cuePoint")]
    [Bindable]
    public function get mostRecentCuePointName():String
    {
        return _display.mostRecentCuePointName;
    }
    
    /**
     * Retrieve the most recently fired cue point time.
     */
    [ChangeEvent("cuePoint")]
    [Bindable]
    public function get mostRecentCuePointTime():Number
    {
        return _display.mostRecentCuePointTime;
    }
    
	// The next functions delegate to the contained controller instance.

	/**
	 * @tiptext Determines whether the controller only displays itself on mouse over
	 * @helpid 3458
	 */
	[Inspectable(enumeration="auto,on,off", defaultValue="auto")]
	public function get controllerPolicy():String
	{
		if (_controller != null)
		{
			_controllerPolicy = _controller.controllerPolicy;
		}
		return _controllerPolicy;
	}

	/**
	 * @param doHide True to hide the controller when the mouse is not
	 * over it; false to not hide it.
	 */
	public function set controllerPolicy(aPolicy:String):Void
	{
		_controllerPolicy = aPolicy;
		if (_controller != null)
		{
			_controller.controllerPolicy = aPolicy;
		}
	}


	public function addSecondChrome(theChrome:Chrome,
		closedHeight:Number, openHeight:Number,
		closedWidth:Number, openWidth:Number, fixedEnd:Boolean):Void
	{
		_controller.addSecondChrome(theChrome,
			closedHeight, openHeight,
			closedWidth, openWidth, fixedEnd);
	}

	public function removeSecondChrome():Void
	{
		_controller.removeSecondChrome();
	}

	public function getMinimumOpenHeight():Number
	{
		return _controller.getMinimumOpenHeight();
	}
	public function getMinimumOpenWidth():Number
	{
		return _controller.getMinimumOpenWidth();
	}
	public function getMinimumClosedHeight():Number
	{
		return _controller.getMinimumClosedHeight();
	}
	public function getMinimumClosedWidth():Number
	{
		return _controller.getMinimumClosedWidth();
	}

	public function expand(force:Boolean):Void
	{
		_controller.expand(force);
	}
	public function contract(force:Boolean):Void
	{
		//Tracer.trace("MediaPlayback.contract: about to call contract");
		_controller.contract(force);
	}


	// Now some extra functions

	/**
	 * The position of the controls relative to the display component.
	 * @tiptext Determines where the controller is positioned relative to the display
	 * @helpid 3459
	 */
	[Inspectable(enumeration="top,bottom,left,right", defaultValue="bottom")]
	public function get controlPlacement():String
	{
		return _controlPlacement;
	}
	public function set controlPlacement(aPos:String):Void
	{
		_controlPlacement = aPos;
		if (_controller != null)
		{
			var topOrLeft:Boolean = ( isTopControlPlacement() || isLeftControlPlacement() );
			_controller.setOpenUpOrLeft(topOrLeft);
			// Assign the controller orientation based on the control placement
			var horiz:Boolean = (isTopControlPlacement() || isBottomControlPlacement());
			_controller.horizontal = horiz;
			this.invalidate();
		}
	}

	private function isTopControlPlacement():Boolean
	{
		return (_controlPlacement == TOP_CONTROL_POSITION);
	}
	private function isBottomControlPlacement():Boolean
	{
		return (_controlPlacement == BOTTOM_CONTROL_POSITION);
	}
	private function isLeftControlPlacement():Boolean
	{
		return (_controlPlacement == LEFT_CONTROL_POSITION);
	}
	private function isRightControlPlacement():Boolean
	{
		return (_controlPlacement == RIGHT_CONTROL_POSITION);
	}

	/**
	 * Display the player in full-screen mode. This makes the player
	 * occupy the entire Flash stage. It does *not* change the size
	 * of the Flash stage.
	 * @tiptext Sends the PlayBack component instance into full screen mode
	 * @helpid 3472
	 */
	public function displayFull():Void
	{
		var toggle:FullScreenToggle = _chrome.getOneToggle();
//		Tracer.trace("MediaPlayback.displayFull: toggle=" + toggle);
		toggle.displayFull(false);
	}

	/**
	 * Display the player in normal mode (as opposed to full screen).
	 * The original size and position of the player are retained when it
	 * toggles between full screen and normal mode.
	 * @tiptext Sends the PlayBack back to its original size
	 * @helpid 3473
	 */
	public function displayNormal():Void
	{
		var toggle:FullScreenToggle = _chrome.getOneToggle();
//		Tracer.trace("MediaPlayback.displayNormal: toggle=" + toggle);
		toggle.displayNormal(false);
	}


	public function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		// Each dimension must be at least 17 pixels larger than the
		// controller's minimum size. That leaves 16 border pixels and one
		// pixel for the display component.
		w = Math.max(w, _controller.getMinimumOpenWidth() + 17);
		h = Math.max(h, _controller.getMinimumOpenHeight() + 17);
//		Tracer.trace("MediaPlayback.setSize: " + w + "x" + h);
		super.setSize(w, h, noEvent);
		// Force a redraw
		this.invalidate();
	}

	public function get enabled():Boolean
	{
		return _enabled;
	}

	public function set enabled(is:Boolean):Void
	{
		_enabled = is;
		// Cascade the enabled flag
		_display.enabled = is;
		_controller.enabled = is;
		//Tracer.trace("MediaPlayback.set enabled: _chrome=" + this._chrome);
		this._chrome.setEnabled(is);
	}

}

