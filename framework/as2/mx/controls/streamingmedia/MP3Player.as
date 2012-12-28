//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.AbstractPlayer;
import mx.controls.streamingmedia.IPlayer;
import mx.controls.streamingmedia.StreamingMediaConstants;

/**
 * FLVPlayer contains the logic to play MP3 streaming media files.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.MP3Player
extends AbstractPlayer
implements IPlayer
{
	/** A constant that indicates that the sound should stop playing once it loads */
	public static var STOP:Number = -1;

	private var _sound:Sound;
	private var _soundHolder:MovieClip;
	private var _mediaUrl:String;
	/** # of seconds when the playhead was paused */
	private var _recentPosition:Number;
	/** Has the mp3 been loaded? */
	private var _loaded:Boolean;
	/**
	 * Position in seconds where the sound should play when it loads.
	 * STOP indicates that it should not play at all.
	 */
	private var _positionOnLoad:Number;

	private var _listeners:Array;

	/**
	 * The current volume setting. Used to initialize the volume of new
	 * mp3's that are played.
	 */
	private var _volume:Number;

	/**
	 * Constructor.
	 */
	public function MP3Player(aMediaUrl:String, aSoundHolder:MovieClip)
	{
		if ( (aMediaUrl == null) || (aSoundHolder == null) )
		{
			//throw new Error("A media url and a sound holder clip must be passed to MP3Player's constructor");
		}

		// Put parameters in the proper places
		_mediaUrl = aMediaUrl;
		_soundHolder = aSoundHolder;

		// Finish initialization
		init();
	}

	/**
	 * This is scoped public so that the MediaDisplay class can access it.
	 */
	public function willStop():Boolean
	{
		return (_positionOnLoad == STOP);
	}

	/**
	 * Initialize the mp3 player.
	 */
	private function init()
	{
		_listeners = new Array();
		_sound = new Sound(_soundHolder);
		_volume = StreamingMediaConstants.DEFAULT_VOLUME;

		var sObj:Object = Object(_sound);
		sObj.player = this;

		_sound.onSoundComplete = function()
		{
			// "this" is the sound object.
			var thisObj:Object = Object(this);
			var pl:MP3Player = thisObj.player;
			pl.setPlaying(false);
			pl.broadcastEvent("complete");
		};

		_recentPosition = 0;
		_loaded = false;
		_positionOnLoad = STOP;
		setPlaying(false);
	}

	/**
	 * This is called by the MediaDisplay object when playback starts.
	 */
	public function playStarted():Void
	{
		//Tracer.trace("MP3Player.playStarted: position at " + _positionOnLoad + ", STOP=" + STOP);
		_loaded = true;
		initializeVolume();
		if (_positionOnLoad == STOP)
		{
			//Tracer.trace("MP3Player.onLoad: stopping");
			this.stop();
		}
		else
		{
			this.play(_positionOnLoad);
		}
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
	 * function which takes two parameters: the slider and
	 * the current value of the slider.
	 */
	public function broadcastEvent(status:String):Void
	{
		//Tracer.trace("MP3Player.broadcastEvent: status=" + status);
		for (var ix:Number = 0; ix < _listeners.length; ix++)
		{
			_listeners[ix].handlePlayer(this, status);
		}
	}


	/**
	 * Load the media without playing it.
	 */
	public function load():Void
	{
		// Set the "playing" flag to indicate that the media is playing,
		// because it is for now. It will be stopped but it has not
		// been stopped yet.
		setPlaying(true);
		_positionOnLoad = STOP;
		_sound.loadSound(_mediaUrl, true);
		// Duck the volume so even if we accidently play something before
		// noticing, nothing will be heard. playStarted will correctly
		// play from the right time, and set the correct volume.
		_sound.setVolume(0);
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
		if (startingPoint == null)
		{
			startingPoint = _recentPosition;
		}

		if (_loaded)
		{
			_sound.start(startingPoint);
//			Tracer.trace("MP3Player.play: started sound at " + startingPoint);
		}
		else
		{
			_positionOnLoad = startingPoint;
			_sound.loadSound(_mediaUrl, true);
			// Duck the volume so even if we accidently play something before
			// noticing, nothing will be heard. playStarted will correctly
			// play from the right time, and set the correct volume.
			_sound.setVolume(0);
		}

		setPlaying(true);
	}

	/**
	 * Stop playback of the media without moving the playhead.
	 */
	public function pause():Void
	{
		_recentPosition = _sound.position / 1000;
		_sound.stop();
		setPlaying(false);
	}

	/**
	 * Stop playback of the media and reset the playhead to zero.
	 */
	public function stop():Void
	{
		_recentPosition = 0;
		_sound.stop();
		setPlaying(false);
	}

	/**
	 * @return The playhead position, measued in seconds since the start.
	 */
	public function getPlayheadTime():Number
	{
		// Convert Sound.position from ms to seconds
		var pt:Number = ( isPlaying() ? _sound.position / 1000 : _recentPosition );
		return pt;
	}

	/**
	 * @param aPosition Time in seconds where the playhead position should be placed
	 */
	public function setPlayheadTime(aPosition:Number):Void
	{
		_recentPosition = aPosition;
		if (isPlaying())
		{
			this.play(aPosition);
		}
	}

	public function getMediaUrl():String
	{
		return _mediaUrl;
	}

	public function setMediaUrl(aUrl:String):Void
	{
		_loaded = false;
		_mediaUrl = aUrl;
		if (isPlaying())
		{
			this.play(0);
		}
		else
		{
			_recentPosition = 0;
			this.load();
		}
	}

	public function getVolume():Number
	{
		return _volume;
	}

	public function setVolume(aVol:Number):Void
	{
		_sound.setVolume(aVol);
		_volume = aVol;
	}

	/**
	 * Set the volume of a new sound to the default volume.
	 */
	public function initializeVolume():Void
	{
		setVolume(_volume);
	}

	/**
	 * @return The number of bytes of the media that has loaded.
	 */
	public function getMediaBytesLoaded():Number
	{
		return _sound.getBytesLoaded();
	}

	/**
	 * @return The total number of bytes of the media.
	 */
	public function getMediaBytesTotal():Number
	{
		return _sound.getBytesTotal();
	}

	/**
	 * If the mp3 media has not completely loaded, then the duration property
	 * of the Sound object is not accurate. The duration property increases
	 * roughly linearly as the media loads. When the media is completely loaded,
	 * it is accurate.
	 *
	 * Hence, we can roughly calculate the total time of an mp3 by scaling the
	 * duration by the ratio of bytesTotal/bytesLoaded. In practice, this has
	 * been 95+% accurate.
	 *
	 * @return The total time of the media in seconds. For mp3 files, this is a
	 * property of the Sound object. For video, it is be a property
	 * that is manually set by the author.
	 */
	public function getTotalTime():Number
	{
		var tt:Number = _sound.duration * _sound.getBytesTotal() / _sound.getBytesLoaded();
		// Convert from ms to seconds
		return  tt / 1000;
	}

	// These last functions are required by the IPlayer interface but
	// they are not used for MP3 files.
	public function bufferIsFull():Void
	{
	}

	public function resizeVideo():Void
	{
	}

	public function playStopped():Void
	{
	}

	/**
	 * Called when the media is completely loaded.
	 */
	public function mediaLoaded():Void
	{
	}

	/**
	 * Close the player.
	 */
	public function close():Void
	{
		// Stop the sound from playing.
		_sound.stop();
	}

	public function logError(error:String):Void
	{
	}
	public function isSizeSet():Boolean
	{
		return false;
	}
	public function isSizeChange():Boolean
	{
		return false;
	}
	/**
	 * For MP3Player, this is a no-op
	 */
	public function setSeeking(isSeeking:Boolean):Void
	{
	}
}
