//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.MediaController;
import mx.controls.MediaPlayback;
import mx.controls.streamingmedia.CuePoint;
import mx.controls.streamingmedia.FLVPlayer;
import mx.controls.streamingmedia.FullScreenToggle;
import mx.controls.streamingmedia.ICuePointHolder;
import mx.controls.streamingmedia.IPlayer;
import mx.controls.streamingmedia.MP3Player;
import mx.controls.streamingmedia.RTMPPlayer;
import mx.controls.streamingmedia.ScreenAccommodator;
import mx.controls.streamingmedia.StreamingMediaConstants;
import mx.core.UIComponent;

[RequiresDataBinding(true)]
[IconFile("MediaDisplay.png")]

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
 * @tiptext start event
 * @helpid 3488
 */
[Event("start")]
/**
 * @tiptext resizeVideo event
 * @helpid ????
 */
[Event("resizeVideo")]

/**
 * MediaDisplay plays FLV and MP3 files.
 *
 * @author Andrew Guldman
 * @tiptext	MediaDisplay plays FLV and MP3 files
 * @helpid 3491
 */
class mx.controls.MediaDisplay
extends UIComponent
implements ICuePointHolder
{
	// This set of properties is for FUIComponent
	static var symbolName:String = "MediaDisplay";
	static var symbolOwner:Object = mx.controls.MediaDisplay;
	var	className:String = "MediaDisplay";
//#include "../core/MediaComponentVersion.as"

	var clipParameters:Object =
	{
		mediaType: "FLV",
		contentPath: "",
		totalTime: 0,
		autoSize: true,
		autoPlay: true,
		initCuePointNames: new Array(),
		initCuePointTimes: new Array(),
		fps: 30
	};


	// The rest of the properties do not pertain to FUIComponent

	/**
	 * The frames per second is only used for video, and is only used in
	 * the configuration UI. The config UI uses it to calculate
	 * milliseconds based on frame number.
	 */
	[Inspectable(defaultValue=30)]
	public var fps:Number;

	/**
	 * An array of cue point names. One for each cue point.
	 * Each entry is a string.
	 * This is only used at startup to initialize the cue point array.
	 */
	[Inspectable]
	public var initCuePointNames:Array;

	/**
	 * An array of cue point times. One for each cue point.
	 * There must be the same number as there are names.
	 * Each element is the number of seconds, with decimals allowed.
	 * This is only used at startup to initialize the cue point array.
	 */
	[Inspectable]
	public var initCuePointTimes:Array;

	private var _contentPath:String;

	private var _mediaType:String;

	/** Automatically size the component to fit the media that is loaded? */
	private var _autoSize:Boolean;

	/**
	 * True to respect the aspect ratio; false to ignore it. Only
	 * applies if autoSize = false.
	 */
	private var _aspectRatio:Boolean;

	/** Automatically play the media at startup? */
	private var _autoPlay:Boolean;

	private var _deadPreview:MovieClip;

	private var _toggleControl:FullScreenToggle;

	private var _playerImpl:IPlayer;

	/**
	 * Holder object that holds the video to show the FLV.
	 * Put the video in a holder so that the volume can be controlled
	 * by attaching a sound object to the holder.
	 */
	private var _videoHolder:MovieClip;

	/**
	 * An empty clip used to control the volume of mp3 audio
	 */
	private var _soundHolder:MovieClip;

	/** Clip used for onEnterFrame processing */
	private var _processor:MovieClip;

	/**
	 * The playhead time at the prior sample. Used to determine whether to
	 * broadcast a change event.
	 */
	private var _priorTime:Number = 0;
	/**
	 * The bytes loaded at the prior sample. Used to determine whether to
	 * broadcast a progress event.
	 */
	private var _priorBytesLoaded:Number = 0;

	/** The cue points for this piece of media */
	private var _cuePoints:Array;

    /** The most recently fired cue point */
    private var _mostRecentCuePoint;

	/** Boolean to indicate whether we're scrubbing or not. If scrubbing, fire the cuepoints even if _fireCuePoints is false. */
	private var _scrubbing:Boolean = false;
	
	/** Boolean to control firing of cue points. We don't want to fire them on rewind, for example. */
	private var _fireCuePoints:Boolean = true;
	
	/** Start time of playback, used for MP3 stream */
	private var _startingTime:Number;

	/** Total number of seconds, used for video stream */
	private var _totalTime:Number;

	/** Has the stream started yet? */
	private var _started:Boolean;

	/** Should the poll method send a complete event? */
	private var _sendCompleteEvent:Boolean;
	/** Is the media completely loaded? */
	private var _fullyLoaded:Boolean;

	/** Is the component enabled? */
		// It is enabled by default
	private var _enabled:Boolean = true;
	/** Was the component playing when it was disabled? */
	private var _playingBeforeDisabled:Boolean;

	/** The interval id for polling */
	private var _pollId:Number;

	/**
	 * A flag that tells the draw() function to make the video object visible.
	 * This is public because the MediaPlayback class needs to be able to
	 * set it.
	 */
	public var makeVideoVisible:Boolean = false;

	/**
	 * The screen accommodator automatically enables and disables the
	 * component inside a screen.
	 */
	private var _screenAccommodator:ScreenAccommodator;

	/**
	 * Constructor
	 */
	public function MediaDisplay()
	{
	}

	// The next group of functions is connected to FUIComponent and FUIObject

	/**
	 * Initialize the player.
	 */
	function init(Void):Void
	{
		// Initialize parameters
		initializeParameters();

		// Read the size of the dead preview before calling super.init()
		// because that function sets _xscale and _yscale to 100.
		var piWidth:Number = this._width;
		var piHeight:Number = this._height;
		// Now that we've got the height and width, hide the dead preview
		this._deadPreview._visible = false;

		super.init();

		// Restore the prior size
		this.setSize(piWidth, piHeight, true);

		// Check to see if the properties were properly initialized
		//Tracer.trace("MediaDisplay.init: Initialized properties:");
		//Tracer.trace("  contentPath=" + _contentPath);
		//Tracer.trace("  mediaType=" + mediaType);
		//Tracer.trace("  autoSize=" + _autoSize);
		//Tracer.trace("  aspectRatio=" + _aspectRatio);
		//Tracer.trace("  autoPlay=" + _autoPlay);
		//Tracer.trace("  totalTime=" + totalTime);
		//Tracer.trace("  initCuePointNames=" + initCuePointNames);
		//Tracer.trace("  initCuePointTimes=" + initCuePointTimes);

		// Initialize the cue points
		initCuePoints();

		// Default starting time is always at the beginning.
		_startingTime = 0;

		_playingBeforeDisabled = false;

		// The stream hasn't started yet
		_started = false;
		// Don't send a complete event yet
		_sendCompleteEvent = false;
		// The media is not yet fully loaded
		_fullyLoaded = false;
		// Don't show the video yet
		makeVideoVisible = false;

		// Disable tab support
		this.tabEnabled = false;
		this.tabChildren = false;

		// Create a ScreenAccommodator to manage the interactions with screens,
		// if there are any. Keep a reference to it to ensure that it isn't
		// garbage collected
		_screenAccommodator = new ScreenAccommodator(this);
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
	}

	/**
	 * Initialize the cue points from the init parameters.
	 * The data from the initCuePointNames and initCuePointTimes arrays
	 * will be consolidated into the single _cuePoints array.
	 */
	private function initCuePoints():Void
	{
		_cuePoints = new Array();
		for (var ix:Number = 0; ( (ix < initCuePointNames.length) && (ix < initCuePointTimes.length) ); ix++)
		{
			this.addCuePoint(initCuePointNames[ix], initCuePointTimes[ix]);
			//Tracer.trace("MediaDisplay.initCuePoints: added " + cp.toString());
		}
		//Tracer.trace("MediaDisplay.initCuePoints: " + _cuePoints);

		// Now delete the initialization arrays
		delete this.initCuePointNames;
		delete this.initCuePointTimes;
		
		_mostRecentCuePoint = undefined;
	}

	/**
	 * Prepare the component for the media and load it.
	 *
	 * @param switchType Switch to a new media type. OPTIONAL
	 */
	public function initMedia(switchType:Boolean):Void
	{
		if (isLivePreview())
		{
			// Don't do anything if we are in livepreview mode
			return;
		}

		// Use this to maintain the volume setting when a new player is created,
		// since it gets initialized with the default volume level.
		var	maintainedVolumeSetting = volume;

		if (switchType)
		{
			// Stop the existing player from playing
			_playerImpl.stop();
		}

		if (isFLV())
		{
			if (isRtmp(_contentPath))
			{
				_playerImpl = new RTMPPlayer(_contentPath, StreamingMediaConstants.FLV_MEDIA_TYPE,
											this._videoHolder, _totalTime);
			}
			else
			{
				_playerImpl = new FLVPlayer(_contentPath, this._videoHolder, _totalTime);
			}
		}
		else if (isMP3())
		{
			if (switchType)
			{
				this.releaseVideo();
				// Get rid of the audio
//				this._videoHolder.attachAudio(null);
				// Detach the existing video
//				this._videoHolder._video.attachVideo(null);
//				this._videoHolder._video.clear();
			}
			if (isRtmp(_contentPath))
			{
				_playerImpl = new RTMPPlayer(_contentPath, StreamingMediaConstants.MP3_MEDIA_TYPE,
											 this._videoHolder, _totalTime);
			}
			else
			{
				this.createEmptyMovieClip("_soundHolder", 10);
				_playerImpl = new MP3Player(_contentPath, this._soundHolder);
			}
		}
		else
		{
			//throw new Error("The display must be playing mp3 or flv media. Instead it is trying to play " + _mediaType);
		}

		// Guard against the first time through, when there was no previous player,
		// so the maintainedVolumeSetting has the value of "undefined"
		if (maintainedVolumeSetting != undefined)
			volume = maintainedVolumeSetting;

		// Update the display -- size the video object
		redraw(true);

		// Add the display component as a listener to see when playback starts and ends
		_playerImpl.removeAllListeners();
		_playerImpl.addListener(this);
		_started = false;

		if (!switchType)
		{
			if (_autoPlay)
			{
				// Play the media
				this.play();
			}
			else
			{
				// Load the media without playing it
				this.load();
			}

			// Monitor what's going on
			this.poll(true);
			if (_pollId != null)
			{
				clearInterval(_pollId);
			}
			_pollId = setInterval(this, "poll", 250);
		}
	}

	/**
	 * Update the display -- size the video object. Don't do anything
	 * for mp3 media.
	 */
	public function draw():Void
	{
		if (isFLV())
		{
			//Tracer.trace("draw: resizing component to " + width + "x" + height);
//			this.clear();
//			this.lineStyle(0, 0xff0000, 100);
//			this.moveTo(0,0);
//			this.lineTo(width,0);
//			this.lineTo(width,height);
//			this.lineTo(0,height);
//			this.lineTo(0,0);

			if (makeVideoVisible)
			{
				_videoHolder._visible = true;
				// No need to do this every time
				makeVideoVisible = false;
			}

			if (_autoSize)
			{
				assignPreferredSize();
			}
			else
			{
				if (_aspectRatio)
				{
					var pW:Number = preferredWidth;
					var pH:Number = preferredHeight;
					// Make the display as big as it can be while respecting the aspect ratio
					var scale:Number = Math.min( width / pW, height / pH );
					// Scale the FLV to fit the available space
					//Tracer.trace("MediaDisplay.draw: _aspectRatio=true, scale=" +
					//	scale + ", height=" + height + ", preferredHeight=" + pH);
					setVideoDisplaySize( scale * pW, scale * pH );
				}
				else
				{
					setVideoDisplaySize(width, height);
				}
			}
		}
	}



	// The remaining functions are independent of FUIComponent and FUIObject

	/**
	 * @param w The new width of the component
	 * @param h The new height of the component
	 */
	private function setVideoDisplaySize(w:Number, h:Number):Void
	{
		if (isFLV())
		{
			var v:MovieClip = _videoHolder._video;
			v._width = w;
			v._height = h;
			//Tracer.trace("MediaDisplay.setVideoDisplaySize: resized video to " + v._width + "x" + v._height);

			// Position the FLV centered on the display component
			v._x = (width - v._width) / 2;
			v._y = (height - v._height) / 2;
			//Tracer.trace("MediaDisplay.setSize: positioned video at (" + v._x +
//				"," + v._y + "). width=" + width + ", _vh.w=" + _videoHolder._width);
		}
	}


	/**
	 * @return The actual width of the video display.
	 */
	public function get videoWidth():Number
	{
		var w:Number;
		if (isMP3())
		{
			w = 0;
		}
		else
		{
			w = _videoHolder._video._width;
		}

		return w;
	}

	/**
	 * @return The actual height of the display.
	 */
	public function get videoHeight():Number
	{
		var h:Number;
		if (isMP3())
		{
			h = 0;
		}
		else
		{
			h = _videoHolder._video._height;
		}

		return h;
	}


	/**
	 * @return The preferred width of the display.
	 * This is the width of the video object.
	 * @tiptext The preferred width of the display
	 * @helpid 3466
	 */
	public function get preferredWidth():Number
	{
		var w:Number;
		if (isMP3())
		{
			w = 0;
		}
		else
		{
			w = _videoHolder._video.width;
		}

		return w;
	}

	/**
	 * @return The preferred height of the display.
	 * This is the height of the video object.
	 * @tiptext The preferred height of the display
	 * @helpid 3465
	 */
	public function get preferredHeight():Number
	{
		var h:Number;
		if (isMP3())
		{
			h = 0;
		}
		else
		{
			h = _videoHolder._video.height;
		}

		return h;
	}


	public function assignPreferredSize():Void
	{
		setVideoDisplaySize( preferredWidth, preferredHeight, true );
	}

	/**
	 * Handle events broadcast by the player implementation.
	 */
	public function handlePlayer(player:IPlayer, status:String)
	{
		//Tracer.trace("MediaDisplay: handling '" + status + "' event from " + player);
		if ( status == "start" || status == "resizeVideo")
		{
			if (this._parent instanceof MediaPlayback)
			{
				// This is contained in a media playback component.
				// The playback component will adjust the size of the display,
				// then draw it. The "start" event triggers that.
				// Don't to anything now.
			}
			else
			{
				// This is *not* contained in a playback component.
				// Immediately update the display
				makeVideoVisible = true;
				draw();
			}
			if (_started)
			{
				var ev:Object = { target: this, type: "resizeVideo" };
				dispatchEvent(ev);
			}
			else
			{
				var ev:Object = { target: this, type: "start" };
				dispatchEvent(ev);
	
				if (isRtmp(_contentPath))
				{
					ev = { target: this, type: "progress" };
					dispatchEvent(ev);
				}
	
				// We only need to handle this event once. Flag that we already have.
				_started = true;
			}
		}
		else if (status == "complete")
		{
			// Finished playing. Send a "complete" event in the next poll() cycle.
			// Wait for poll to ensure that the complete event is sent *after*
			// the last "change" event.
			_sendCompleteEvent = true;
		}
	}

	/**
	 * @return A string representation of this object
	 */
	public function toString():String
	{
		return "MediaDisplay: media=" + _contentPath;
	}


	/**
	 * Load the media without playing it.
	 * @tiptext Load the media without playing it
	 * @helpid 3475
	 */
	public function load():Void
	{
		_playerImpl.load();
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
		if (startingPoint != undefined)
			_startingTime = startingPoint;
			
		if (enabled)
    		_playerImpl.play(startingPoint);
    	else
    	    _playingBeforeDisabled = true;
	}

	/**
	 * Stop playback of the media without moving the playhead.
	 * @tiptext Pauses the playhead at the current location
	 * @helpid 3477
	 */
	public function pause():Void
	{
		_playerImpl.pause();
	}

	/**
	 * Stop playback of the media and reset the playhead to zero.
	 * @tiptext Stops the playhead and moves it to the beginning of the media
	 * @helpid 3493
	 */
	public function stop():Void
	{
		_playerImpl.stop();
	}

	/**
	 * @tiptext Determines whether the display sizes itself according to the preferred size of the media
	 * @helpid 3543
	 */
	// The inspectable tag is a bit finicky. If it is placed after the getter,
	// it treats the Boolean property as type "default" which becomes a string.
	// It seems to need to be immediately before the getter which is immediately
	// before the setter. Not sure how comments effect it.
	[Inspectable(defaultValue=true)]
	public function get autoSize():Boolean
	{
		return _autoSize;
	}
	public function set autoSize(flag:Boolean):Void
	{
		if (_autoSize != flag)
		{
			_autoSize = flag;
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
		return _aspectRatio;
	}
	public function set aspectRatio(flag:Boolean):Void
	{
		if (_aspectRatio != flag)
		{
			_aspectRatio = flag;
			invalidate();
		}
	}


	/**
	 * Autoplay is strictly an initialization parameter.
	 * @tiptext Determines whether media will immediately begin to buffer and play
	 * @helpid 3452
	 */
	[Inspectable(defaultValue=true)]
	public function get autoPlay():Boolean
	{
		return _autoPlay;
	}
	public function set autoPlay(flag:Boolean):Void
	{
		_autoPlay = flag;
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
		return _playerImpl.getPlayheadTime();
	}

	public function set playheadTime(position:Number):Void
	{
		if (position != undefined)
			_startingTime = position;
		_playerImpl.setPlayheadTime(position);
	}

	/**
	 * Create a contentPath property.
	 * @tiptext Holds the relative path and filename of the media to be streamed
	 * @helpid 3457
	 */
	[Inspectable(defaultValue="")]
	[ChangeEvent("start")]
	[Bindable]
	public function get contentPath():String
	{
		return _contentPath;
	}

	/**
	 * Set the content path. This should only be called during configuration.
	 * It does not work at runtime.
	 */
	public function set contentPath(aUrl:String):Void
	{
		setMedia(aUrl);
	}

	/**
	 * Set both the content path and the media type together.
	 * @tiptext	Associates the contentPath and mediaType to the MediaDisplay
	 * @helpid 3494
	 */
	public function setMedia(aUrl:String, aType:String)
	{
		// Media is changing, so we can ignore the cuePoints until it actually starts up.
		_fireCuePoints = false;
		
		// aType is optional
		if (aType == null)
		{
			aType = deduceMediaType(aUrl);
		}
		else
		{
			// A type was specified. Make sure it is ok.
			if ( (aType != StreamingMediaConstants.FLV_MEDIA_TYPE) &&
				(aType != StreamingMediaConstants.MP3_MEDIA_TYPE) )
			{
				//throw new Error("The media type must be either " +
					//StreamingMediaConstants.FLV_MEDIA_TYPE + " or " + StreamingMediaConstants.MP3_MEDIA_TYPE);
			}
		}
		//Tracer.trace("MediaDisplay.setMedia: url=" + aUrl + ", type=" + aType);

		// If we got here, the error wasn't thrown
		var oldType:String = _mediaType;
		_mediaType = aType;

		//Tracer.trace("Display.set contentPath: " + System.capabilities.serverString);
		//Tracer.trace("Display.set contentPath to " + aUrl);
		var oldRtmp:Boolean = isRtmp(_contentPath);
		var newRtmp:Boolean = isRtmp(aUrl);
		_contentPath = aUrl;
		// The media is not yet fully loaded
		_fullyLoaded = false;

		_startingTime = 0;

		if (!isLivePreview())
		{
			if (_contentPath == "")
			{
				// Clear any media that may have previously been playing
				this.releaseVideo();
			}
			else if (_playerImpl == null)
			{
				initMedia();
			}
			else if ( (oldType != _mediaType) || (oldRtmp != newRtmp) )
			{
				// Was the media already playing?
				var priorPlaying:Boolean = _playerImpl.isPlaying();
				// The player has already been initialized. Switch it to
				// the new media type.
				initMedia(true);
				if (priorPlaying)
				{
					_playerImpl.play(0);
				}
				else
				{
					_playerImpl.load();
				}
			}
			else
			{
				// We get here if both the type and rtmp stayed the same
				// Send the new url to the player implementation
				//Tracer.trace("***MediaDisplay.setMedia: about to call setMediaUrl");
				_playerImpl.setMediaUrl(aUrl);
				// The new content hasn't started yet
				_started = false;
			}
		}

	}

	private function deduceMediaType(aUrl:String) : String
	{
		// Try to deduce the type from the content path
		var last3:String = aUrl.substr(-3);
		if ( (last3 == "flv") || (last3 == "FLV") )
			return "FLV";

		if ( (last3 == "mp3") || (last3 == "MP3") )
			return "MP3";

		// Leave the type unchanged
		return _mediaType;
	}

	/**
	 * Completely release the video from the display. This is trickier
	 * than it might seem. Incompletely releasing the video leads to problems.
	 * If the same FLV is subsequently reloaded and its video or audio
	 * is already attached to the movie, the NetStream.play() call will fail.
	 */
	private function releaseVideo():Void
	{
		//Tracer.trace("MediaDisplay.releaseVideo: clearing prior video: _videoHolder=" + _videoHolder);
/*
//				_playerImpl.stop();
		var nc:NetConnection = new NetConnection();
		nc.connect(null);
		var ns:NetStream = new NetStream(nc, this);
		this._videoHolder._video.attachVideo(ns);
		this._videoHolder.attachAudio(ns);

//				this._videoHolder.attachAudio(null);
//				this._videoHolder._video.attachVideo(null);
		this._videoHolder._video.clear();
//				delete this._playerImpl;
*/
		_playerImpl.close();
		_playerImpl = null;
	}

	/**
	 * @return True if we are in live preview; false if not.
	 */
	private function isLivePreview():Boolean
	{
		// MMExecute does *not* work in live preview mode
//		var ver:String = MMExecute("fl.version");

		// There is a file mm_livepreview.as in the .../Configuration/Include
		// directory that seems to be run when we are in live preview mode.
		// This file creates a "contents.obj" object. contents.obj only exists
		// in live preview mode.
		// Use _root.contents.obj so that it works from both the MediaDisplay
		// and MediaPlayback components. The component that is being previewed
		// has a "contents.obj" property in it that points to
		// _root.contents.obj.
		//Tracer.trace("contents.obj=" + _root.contents.obj);
		return (_root.contents.obj != null);
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
		return _playerImpl.getVolume();
	}
	public function set volume(aVol:Number):Void
	{
		_playerImpl.setVolume(aVol);
	}

	/**
	 * @tiptext Is the instance trying to play
	 * @helpid 3464
	 */
	[ChangeEvent("change")]
	[Bindable]
	public function get playing():Boolean
	{
		return _playerImpl.isPlaying();
	}

	/**
	 * @tiptext Number of bytes already loaded
	 * @helpid 3455
	 */
	[ChangeEvent("progress")]
	[Bindable]
	public function get bytesLoaded():Number
	{
		return _playerImpl.getMediaBytesLoaded();
	}

	/**
	 * @tiptext Number of bytes to be loaded
	 * @helpid 3456
	 */
	[ChangeEvent("start")]
	[Bindable]
	public function get bytesTotal():Number
	{
		return _playerImpl.getMediaBytesTotal();
	}

	/**
	 * Convenience function for internal use only
	 */
	private function isFLV():Boolean
	{
		return (_mediaType == StreamingMediaConstants.FLV_MEDIA_TYPE);
	}
	/**
	 * Convenience function for internal use only
	 */
	private function isMP3():Boolean
	{
		return (_mediaType == StreamingMediaConstants.MP3_MEDIA_TYPE);
	}

	/**
	 * @tiptext Type of media to be played
	 * @helpid 3462
	 */
	[Inspectable(enumeration="MP3,FLV", defaultValue="FLV")]
	[ChangeEvent("start")]
	[Bindable]
	public function get mediaType():String
	{
		return this._mediaType;
	}

	/**
	 * Set the media type. This should only be called during configuration.
	 * It does not work at runtime.
	 */
	public function set mediaType(aType:String):Void
	{
		_mediaType = aType;
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
		var tt:Number;
		if (_playerImpl == null)
		{
			tt = _totalTime;
		}
		else
		{
			tt = _playerImpl.getTotalTime();
		}
		return tt;
	}

	public function set totalTime(aTime:Number):Void
	{
		_totalTime = aTime;
		if ((_playerImpl instanceof FLVPlayer))
		{
			FLVPlayer(_playerImpl).setTotalTime(aTime);
		}
		else if ((_playerImpl instanceof RTMPPlayer))
		{
			RTMPPlayer(_playerImpl).setTotalTime(aTime);
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
		return _cuePoints;
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

	/**
	 * An array of cue point objects
	 */
	public function setCuePoints(cp:Array):Void
	{
		_cuePoints = cp;
		// Assign the display property of each cue point
		for (var ix:Number = 0; ix < _cuePoints.length; ix++)
		{
			_cuePoints[ix].display = this;
		}
	}
	/**
	 * An array of cue point objects
	 */
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
		var theCue:CuePoint = null;
		var cueIx:Number = getCuePointIndex(pointName);
		if (cueIx > -1)
		{
			theCue = _cuePoints[cueIx];
		}

		return theCue;
	}

	/**
	 * Add the given cue point.
	 * @param aCuePoint The CuePoint to add.
	 * @tiptext Adds a cue point object to the display instance
	 * @helpid 3469
	 */
	public function addCuePoint(aName:String, aTime:Number):Void
	{
		var aCuePoint:CuePoint = new CuePoint(aName, aTime);
		addCuePointObject(aCuePoint);
	}

	/**
	 * Add the given cue point.
	 * @param aCuePoint The CuePoint to add.
	 */
	public function addCuePointObject(aCuePoint:CuePoint):Void
	{
		aCuePoint.display = this;
		_cuePoints.push(aCuePoint);
	}

	/**
	 * Remove the given cue point.
	 * @param aCuePoint The CuePoint to remove.
	 * @tiptext Delete a specific cuepoint associated with this instance
	 * @helpid 3479
	 */
	public function removeCuePoint(aCuePoint:CuePoint):Void
	{
		var cueIx:Number = getCuePointIndex(aCuePoint.name);
		if (cueIx > -1)
		{
			_cuePoints.splice(cueIx, 1);
		}
	}

	/**
	 * Remove all the CuePoints.
	 * @tiptext Deletes all cuepoint objects associated with this instance
	 * @helpid 3478
	 */
	public function removeAllCuePoints():Void
	{
		_cuePoints.length = 0;
		_mostRecentCuePoint = undefined;
	}

    /**
     * Retrieve the most recently fired cue point.
     * Unbindable since binding cannot handle structures.
     */
    public function get mostRecentCuePoint():CuePoint
    {
        return _mostRecentCuePoint;
    }
    
    /*
     * Retrieve the most recently fired cue point name.
     */
    [ChangeEvent("cuePoint")]
    [Bindable]
    public function get mostRecentCuePointName():String
    {
        return _mostRecentCuePoint.name;
    }
    
    /**
     * Retrieve the most recently fired cue point time.
     */
    [ChangeEvent("cuePoint")]
    [Bindable]
    public function get mostRecentCuePointTime():Number
    {
        return _mostRecentCuePoint.time;
    }
    
	/**
	 * Listen to events from the controller. The following events are
	 * actually propogated: click, playheadChange, volume.
	 * The others included below were available during development
	 * but are not now.
	 */
	public function handleEvent(ev:Object):Void
	{
//		Tracer.trace("MediaDisplay: handling " + ev.type + " event:" + ev.detail);
		if ( (ev.type == "click") && (ev.detail == "play") )
		{
			// Handle a click on the play button
			handlePlayEvent(ev);
		}
		else if ( (ev.type == "click") && (ev.detail == "pause") )
		{
			// Handle a click on the pause button
			handlePauseEvent(ev);
		}
		else if (ev.type == "playheadChange")
		{
			handlePlayheadChangeEvent(ev);
		}
		else if (ev.type == "volume")
		{
			handleVolumeEvent(ev);
		}
		else if (ev.type == "scrubbing")
		{
			handleScrubbingEvent(ev);
		}
		else
		{
			// Handle an unrecognized event
			handleUnrecognizedEvent(ev);
		}
	}

	// Private functions

	/**
	 * Handle a click on the play button
	 */
	private function handlePlayEvent(ev:Object):Void
	{
		this.play();
	}

	/**
	 * Handle a click on the stop button
	 */
	private function handleStopEvent(ev:Object):Void
	{
		this.stop();
	}

	/**
	 * Handle a click on the pause button
	 */
	private function handlePauseEvent(ev:Object):Void
	{
		this.pause();
	}

	/**
	 * Handle a click on the rewind button
	 */
	private function handleRewindEvent(ev:Object):Void
	{
		//Tracer.trace("handling rewindEvent");
		// If it is playing, it will continue playing.
		// If stopped, it will stay stopped.
		this.playheadTime = 0;
	}

	/**
	 * Handle a click on the fast forward button
	 */
	private function handleFastForwardEvent(ev:Object):Void
	{
		var end:Number = this.totalTime;
		this.playheadTime = end;
//		this.pause();
	}

	/**
	 * Handle a new playhead position event
	 */
	private function handlePlayheadChangeEvent(ev:Object):Void
	{
		var percentDone:Number = ev.detail;
		var targetTime:Number = (percentDone/100) * this.totalTime;
		//Tracer.trace("handling playheadChangeEvent: " + percentDone + "%=" + targetTime + " sec");
		// If we're scrubbing, set _fireCuePoints to true so the fire no matter whant.
		// If we're not scrubbing, e.g. rewinding or going to the end, don't fire the cuePoints this time the playhead changes.
		_fireCuePoints = _scrubbing;
		this.playheadTime = targetTime;
	}

	/**
	 * Handle a volume event
	 */
	private function handleVolumeEvent(ev:Object):Void
	{
		var volumeLevel:Number = ev.detail;
		//Tracer.trace("handling volume event: volume=" + volumeLevel);
		this.volume = volumeLevel;
	}

	/**
	 * Handle a scrubbing event
	 */
	private function handleScrubbingEvent(ev:Object):Void
	{
		_scrubbing = ev.detail;
	}
	
	/**
	 * Handle an unrecognized event
	 */
	private function handleUnrecognizedEvent(ev:Object):Void
	{
		//Tracer.trace("received an unrecognized event of type " + ev.type + " with target " + ev.target);
	}

	/**
	 * @return The index of the cue point with given name, or -1 if not found.
	 */
	private function getCuePointIndex(pointName:String):Number
	{
		var cueIx:Number = -1;
		for (var ix:Number = 0; (ix < _cuePoints.length) && (cueIx == -1); ix++)
		{
			if (_cuePoints[ix].name == pointName)
			{
				cueIx = ix;
			}
		}

		return cueIx;
	}

	/**
	 * Monitor the current status of the component.
	 *
	 * @param first True if this is the first time poll is being called.
	 */
	private function poll(first:Boolean):Void
	{
		var newTime = playheadTime;
		var newLoaded = bytesLoaded;

		//Tracer.trace("loaded/total=" + this._ns.bytesLoaded + "/" + this._ns.bytesTotal);
		//Tracer.trace("width:height=" + this._video.width + ":" + this._video.height);
		//Tracer.trace("Poll: time=" + _ns.time + ", bufferTime=" + _ns.bufferTime + ", bufferLength=" + _ns.bufferLength);
		//Tracer.trace("Poll: time=" + _priorTime + "->" + newTime + ",loaded=" + _priorBytesLoaded + "->" + newLoaded);
		//Tracer.trace("scale=(" + this._xscale + "," + this._yscale + ")");

		// Broadcast the appropriate events
		// [Event("change")]
		// [Event("progress")]
		// [Event("cuePoint")]
		// [Event("complete")]
		if (newTime != _priorTime)
		{
			// Recognize the start of mp3 media by polling.
			// There is no Sound object event to alert us that the media has
			// started playing. The onLoad event fires when the media has
			// *finished* loading, not when it starts playing.
			//
			// If we think that the sound hasn't started, yet the player thinks it is playing,
			// it's time to get things started.
			if ( (_mediaType == "MP3") && (_playerImpl.isPlaying()) && (!_started) )
			{
				// Dispatch a start event
				//Tracer.trace("Poll: dispatching start event for MP3");
				MP3Player(_playerImpl).playStarted();
				// Sometimes (when we are loading a new sound while playing, playStarted doesn't reset
				// the playheadTime. If it didn't work this time, make sure we come back and try again.
				var pht = playheadTime;
				if ((_startingTime - 0.1) < pht && pht < (_startingTime + 0.1))
				{
					_started = true;
					var ev:Object = { target: this, type: "start" };
					dispatchEvent(ev);
				}
			}

			// Dispatch a change event
			//Tracer.trace("Broadcasting change event");
			var ev:Object = { type: "change", target: this };
			dispatchEvent(ev);
		}

		var progress:Boolean = false;
		// Leave a small 100 byte buffer for discrepancies between
		// bytesLoaded & bytesTotal
		if ((!_fullyLoaded) && (bytesLoaded >= bytesTotal - 100))
		{
			// The media is completely loaded
			_fullyLoaded = true;
			// The mediaLoaded() method doesn't ever do anything,
			// so don't bother calling it.
			_playerImpl.mediaLoaded();
			progress = true;
		}
		else if (first || (newLoaded != _priorBytesLoaded))
		{
			progress = true;
		}
		if (progress)
		{
			// Dispatch a progress event
			//Tracer.trace("Broadcasting progress event");
			var ev:Object = { type: "progress", target: this };
			dispatchEvent(ev);
		}

		// See if any cue points have been passed
		var cp:CuePoint = null;
		for (var ix = 0; _fireCuePoints && ix < _cuePoints.length; ix++)
		{
			cp = _cuePoints[ix];
			if  ( ( (_priorTime < cp.time) && (newTime >= cp.time) ) ||
				( (_priorTime > cp.time) && (newTime <= cp.time) ) )
			{
				// We passed this cue point.
				// It doesn't matter if we are going forward or backwards.
				// Fire the event.
				//Tracer.trace("Broadcasting cue point event: " + cp);
				_mostRecentCuePoint = cp;
				var ev:Object = { type: "cuePoint", target: this, cuePointName: cp.name, cuePointTime: cp.time };
				dispatchEvent(ev);
			}
		}

		// If cuePoint firing was off due to rewind or goto end, turn them back on again.
		_fireCuePoints = true;
		
		if (_sendCompleteEvent)
		{
			//Tracer.trace("Broadcasting complete event. Time=" + newTime + " seconds");
			// Only send the event once per cycle
			_sendCompleteEvent = false;
			var ev:Object = { type: "complete", target: this };
			dispatchEvent(ev);
		}

		// Update the values of the prior time and loaded
		this._priorTime = newTime;
		this._priorBytesLoaded = newLoaded;
	}

	public function isRtmp(mediaUrl:String):Boolean
	{
		if (mediaUrl != null)
		{
			var urlLowerCase:String;
			urlLowerCase = mediaUrl.toLowerCase();
			return (urlLowerCase.indexOf("rtmp") == 0);
		}
		return false;
	}


	/**
	 * Associated this display with a controller. Set up the event listeners
	 * between the two.
	 * @tiptext Associates a display instance with a given controller instance
	 * @helpid 3470
	 */
	public function associateController(c:MediaController):Void
	{
		c.addEventListener("click", this);
		c.addEventListener("playheadChange", this);
		c.addEventListener("volume", this);
		c.addEventListener("scrubbing", this);
		addEventListener("change", c);
		addEventListener("progress", c);
		addEventListener("complete", c);
	}

	public function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
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

		if (_enabled == is)
		{
			// No need to do anything
			return;
		}
		_enabled = is;
		if (is)
		{
			if (_playingBeforeDisabled)
			{
				this.play();
				_playingBeforeDisabled = false;
			}
		}
		else
		{
			_playingBeforeDisabled = playing;
			if ( _playingBeforeDisabled && (_playerImpl instanceof MP3Player) )
			{
				_playingBeforeDisabled = ! MP3Player(_playerImpl).willStop();
			}
			this.pause();
		}
	}

	/**
	 * Make sure media playing stops when we unload the clip.
	 */
	public function onUnload():Void
	{
		//Tracer.trace("unloading!");
		_playerImpl.close();
	}
}
