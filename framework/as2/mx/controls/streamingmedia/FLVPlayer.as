//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.streamingmedia.AbstractPlayer;
import mx.controls.streamingmedia.IPlayer;
import mx.controls.streamingmedia.PlayerNetStream;
import mx.controls.streamingmedia.StreamingMediaConstants;

/**
 * FLVPlayer contains the logic to play FLV streaming media files.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.FLVPlayer
extends AbstractPlayer
implements IPlayer
{
	/** Holds the video. Also used to control volume */
	public var _videoHolder:MovieClip;
	/** Embedded video object used to display video */
	public var _video:Video;
	/** Controls the volume of the video */
	private var _sound:Sound;
	private var _nc:NetConnection;
	private var _ns:PlayerNetStream;
	private var _mediaUrl:String;
	/** The total time of the video */
	private var _totalTime:Number;
	/** Has the flv been loaded yet? */
	private var _isLoaded:Boolean;
	/** Lightweight event broadcaster */
	private var _listeners:Array;
	/**
	 * The interval id used to briefly play the media when the playhead is
	 * moved when playback is paused.
	 */
	private var _momentaryPlayId:Number;
	private var _videoHeight:Number;
	private var _videoWidth:Number;

	/**
	 * Constructor.
	 */
	public function FLVPlayer(aMediaUrl:String, aVideoHolder:MovieClip, aTotalTime:Number)
	{
		if ( (aMediaUrl == null) || (aVideoHolder == null) || (aTotalTime == null) )
		{
			//throw new Error("A media url, video object, and total time must be passed to FLVPlayer's constructor");
		}

		// Put parameters in the proper places
		_mediaUrl = aMediaUrl;
		_videoHolder = aVideoHolder;
		_video = _videoHolder._video;
		_totalTime = aTotalTime;

		// Finish initialization
		init();
	}


	/**
	 * Initialize the FLVPlayer.
	 */
	private function init()
	{
//		Tracer.trace("FLVPlayer.init: _mediaUrl=" + _mediaUrl + ",_video=" + _video + ",_totalTime=" + _totalTime);

		_listeners = new Array();

		// It is not currently playing
		setPlaying(false);
		// It has not yet been loaded
		_isLoaded = false;

		// Attach a sound object to control the volume of the video
		_sound = new Sound(_videoHolder);
		setVolume(StreamingMediaConstants.DEFAULT_VOLUME);

	}


	public function addListener(aListener:Object):Void
	{
		_listeners.push(aListener);
	}
	public function removeAllListeners():Void
	{
		_listeners.length = 0;
	}
	
	/**
	 * The listeners must implement the "handlePlayer"
	 * function which takes the current status as a parameter.
	 */
	public function broadcastEvent(status:String):Void
	{
		for (var ix:Number = 0; ix < _listeners.length; ix++)
		{
			_listeners[ix].handlePlayer(this, status);
		}
	}

	public function bufferIsFull():Void
	{
		broadcastEvent("start");
		if (!isPlaying())
		{
			this.pause();
		}
	}

	public function resizeVideo():Void
	{
		broadcastEvent("resizeVideo");
		if (!isPlaying())
		{
			this.pause();
		}
	}
	
	/**
	 * @return A string representation of this player.
	 */
	public function toString():String
	{
		return "FLVPlayer: Playing " + getMediaUrl();
	}

	/**
	 * Close the player
	 */
	public function close():Void
	{
		_ns.close();
		_nc.close();
		_video.clear();
	}

	/**
	 * Load the media without playing it.
	 */
	public function load():Void
	{
//		Tracer.trace("FLVPlayer.load");

		//create a new netConnection object.
		_nc = new NetConnection();
		// Set that connection to null. This netConnection object doesn't 
		// connect to anything but a netStream needs a netConnection to function.
		_nc.connect(null);
		// Create a new netStream and pass it the netConnection object as 
		// it's argument.
		_ns = new PlayerNetStream(_nc, this);
		// Set the buffer time. This is an optional step, the default 
		// buffer is .1.
		assignBufferTime();
		// Attach the stream to a video object, if you forget this step 
		// you'll only hear the audio from the netStream.
		_video.attachVideo(_ns);
		_videoHeight = _video.height;
		_videoWidth = _video.width;

		// Attach the audio portion of the video to the holder mc
		_videoHolder.attachAudio(_ns);

		// Play the media
		_ns.play(_mediaUrl);
		_isLoaded = true;
		_videoHolder._visible = false;
		setPlaying(false);
	}

	/**
	 * Assign the buffer time of the netstream as a function of the total time.
	 */
	private function assignBufferTime():Void
	{
		// Increase the buffer time so that playback isn't too choppy over 
		// slowish network connections
		// Determine the buffer size relative to the total time of the FLV.
		// Buffer size = length / 4, with a minimum size of .1 and a maximum size of 5
		var bufferSize:Number = _totalTime / 4;
		if (bufferSize < .1) bufferSize = .1;
		else if (bufferSize > 5) bufferSize = 5;
		_ns.setBufferTime(bufferSize);
	}

	/**
	 * Play the media starting at the specified starting point. If the media
	 * hasn't yet been loaded, load it.
	 *
	 * @param startingPoint The number of seconds into the media to start at.
	 *        This is an optional parameter. If omitted, playing will occur
	 *        at the current playhead position.
	 */
	public function play(startingPoint:Number):Void
	{
//		Tracer.trace("FLVPlayer.play");
		if (!_isLoaded)
		{
			load();
		}

		if (startingPoint != null)
		{
			_ns.seek(startingPoint);
		}
		_ns.pause(false);
//		Tracer.trace("FLVPlayer.play: time=" + _ns.time);

		setPlaying(true);
	}

	/**
	 * Stop playback of the media without moving the playhead.
	 */
	public function pause():Void
	{
		_ns.pause(true);
		setPlaying(false);
//		Tracer.trace("FLVPlayer.pause: time=" + _ns.time);
	}

	/**
	 * Stop playback of the media and reset the playhead to zero.
	 */
	public function stop():Void
	{
		this.pause();
		setPlayheadTime(0);
	}

	/**
	 * @return The playhead position, measued in seconds since the start.
	 */
	public function getPlayheadTime():Number
	{
		return _ns.time;
	}
	
	public function setPlayheadTime(position:Number):Void
	{
//		Tracer.trace("FLVPlayer.setPlayheadTime: " + position);
		_ns.seek(position);
		if (StreamingMediaConstants.SCRUBBING)
		{
			// Realtime scrubbing is enabled. We don't need to do anything
		}
		else if (!isPlaying())
		{
			// Briefly play the media in order to display a new frame.
			// I would have preferred to stop playback in the buffer full
			// function but that plays the media for too long.
			_ns.pause(false);
			// I experimented with different interval values. This is 
			// the smallest value that reasonably reliably moved the 
			// media playhead.
			_momentaryPlayId = setInterval(this, "doneUpdateFrame", 50);
		}
	}

	/**
	 * Stop the playback.
	 */
	public function doneUpdateFrame():Void
	{
		clearInterval(_momentaryPlayId);
		_momentaryPlayId = null;
		_ns.pause(true);
	}

	/**
	 * The media finished playing.
	 */
	public function playStopped():Void
	{
		// Officially pause playing
		this.pause();
		broadcastEvent("complete");
	}

	public function getMediaUrl():String
	{
		return _mediaUrl;
	}

	public function setMediaUrl(aUrl:String):Void
	{
		_mediaUrl = aUrl;
		_isLoaded = false;
		if (isPlaying())
		{
			this.play(0);
		}
		else
		{
			this.load();
		}
	}

	public function getVolume():Number
	{
		return _sound.getVolume();
	}

	public function setVolume(aVol:Number):Void
	{
//		Tracer.trace("FLVPlayer.setVolume: setting volume to " + aVol);
		_sound.setVolume(aVol);
	}

	/**
	 * @return The number of bytes of the media that has loaded.
	 */
	public function getMediaBytesLoaded():Number
	{
		return _ns.bytesLoaded;
	}

	/**
	 * @return The total number of bytes of the media.
	 */
	public function getMediaBytesTotal():Number
	{
		return _ns.bytesTotal;
	}

	/**
	 * @return The total time of the media in seconds. For mp3 files, this
	 * is a property of the Sound object. For video, it is a property
	 * that is manually set by the author.
	 */
	public function getTotalTime():Number
	{
		return _totalTime;
	}
	public function setTotalTime(aTime:Number):Void
	{
		_totalTime = aTime;
		// Adjust the buffer as appropriate
		assignBufferTime();
	}

	/**
	 * Called when the media is completely loaded.
	 */
	public function mediaLoaded():Void
	{
		// Dramatically shrink the buffer time to improve
		// responsiveness.
		// This was being called too frequently, so comment it out.
		// There doesn't seem to be any detrimental effect from not
		// changing the buffer.
//		_ns.setBufferTime(.1);
	}
	public function logError(error:String):Void
	{
	}
	public function isSizeSet():Boolean
	{
		if ( ( _video.width > 0) && (_video.height > 0) )
		{
			return true;
		}
		return false;
	}
	public function isSizeChange():Boolean
	{
		if ( _video.width != _videoWidth || _video.height != _videoHeight ) 
		{
			_videoWidth = _video.width;
			_videoHeight = _video.height;
			return true;
		}
		return false;
	}
	/** 
	 * For FLVPlayer, this is a no-op
	 */
	public function setSeeking(isSeeking:Boolean):Void
	{
	}
}
