//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/*************************************************************************************************
RTMPPlayer.as
*************************************************************************************************/
import mx.controls.streamingmedia.AbstractPlayer;
import mx.controls.streamingmedia.IPlayer;
import mx.controls.streamingmedia.PlayerNetStream;
import mx.controls.streamingmedia.RTMPConnection;
import mx.controls.streamingmedia.StreamingMediaConstants;

/**
 * RTMPPlayer contains the logic to play FLV streaming media files from Flash Communication Server.
 *
 * @author Stephen Cheng
 */
class mx.controls.streamingmedia.RTMPPlayer
extends AbstractPlayer
implements IPlayer
{
	/** Holds the video. Also used to control volume */
	public var _videoHolder:MovieClip;
	/** Embedded video object used to display video */
	public var _video:Video;
	/** Controls the volume of the video */
	private var _sound:Sound;
	private var _nc_rtmp:RTMPConnection;
	private var _nc_rtmpt:RTMPConnection;
	private var _ns:PlayerNetStream;
	private var _mediaUrl:String;
	private var _mediaType:String;
	private var _protocol:String;
	private var _port:String;
	private var _appUrl:String;
	private var _streamName:String;
	/** The total time of the video */
	private var _totalTime:Number;
	/** Has the flv been loaded yet? */
	private var _isLoaded:Boolean;
	/** is flv loading? */
	private var _isLoading:Boolean;
	/** Lightweight event broadcaster */
	private var _listeners:Array;
	/**
	 * The interval id used to briefly play the media when the playhead is
	 * moved when playback is paused.
	 */
	private var _momentaryPlayId:Number;
	/**
	 * The interval id used to check for the buffer size in NetStream.
	 * This is used to broadcast the "complete" status when stops.
	 */
	private var _checkCompleteId:Number;
	/**
	 * The interval id used to report connection error after timeout.
	 */
	private var _connectTimeOutId:Number;
	/**
	 * The interval id used to send an extra rtmpt request if the
	 * url is rtmp with no port specified.
	 */
	private var _conn_Id:Number;
	/** Counter for number of (bufferLength == .001) received */
	private var _statusCount:Number;
	/** local variable to keep track of the play head position */
	private var _playHeadPos:Number;
	/** boolean that shows seeking status */
	private var _isSeeking:Boolean;
	/** boolean that shows pause status */
	private var _isPausing:Boolean;
	/** is play pending? */
	private var _isPlayPending:Boolean;
	private var _videoHeight:Number;
	private var _videoWidth:Number;

	/**
	 * Constructor.
	 */
	public function RTMPPlayer(aMediaUrl:String, aMediaType:String, aVideoHolder:MovieClip, aTotalTime:Number)
	{
		if ( (aMediaUrl == null) || (aVideoHolder == null) || (aTotalTime == null) )
		{
			//throw new Error("A media url, video object, and total time must be passed to RTMPPlayer's constructor");
		}

		// Put parameters in the proper places
		_mediaUrl = aMediaUrl;
		_mediaType = aMediaType;
		_videoHolder = aVideoHolder;
		//trace("_videoHolder type: " + typeof(_videoHolder));
		_video = _videoHolder._video;
		//trace("_video type: " + typeof(_video));
		_totalTime = aTotalTime;
		_listeners = new Array();
		_connectTimeOutId = null;

		// Finish initialization
		init();
	}


	/**
	 * Initialize the FLVPlayer.
	 */
	private function init()
	{
//		Tracer.trace("FLVPlayer.init: _mediaUrl=" + _mediaUrl + ",_video=" + _video + ",_totalTime=" + _totalTime);

		var index:Number;
		index = _mediaUrl.indexOf(":");
		if (index == -1)
		{
			//throw new Error("Invalid url, no protocol is specified");
		}
		_protocol = (_mediaUrl.substring(0, index)).toLowerCase();
		if (_protocol != "rtmp" && _protocol != "rtmps" && _protocol != "rtmpt")
		{
			//throw new Error("Invalid url, protocol is not supported");
		}

		var mediaUrlWithoutProtocol = _mediaUrl.substring(index + 1, _mediaUrl.length);

		//try to get the port number
		_port = null;
		var portStart = mediaUrlWithoutProtocol.indexOf(":");
		if (portStart != -1)
		{
			_port = mediaUrlWithoutProtocol.substring(portStart + 1, mediaUrlWithoutProtocol.length);
			var portEnd = _port.indexOf("/");
			if (portEnd != -1 && portEnd < portStart)
			{
				_port = _port.substring(0, portEnd);
			}
			else
			{
				_port = null;
			}
		}
		index = mediaUrlWithoutProtocol.lastIndexOf("/");
		if (index == -1)
		{
			//throw new Error("Invalid url");
		}

		_appUrl = mediaUrlWithoutProtocol.substring(0, index);

		_streamName = mediaUrlWithoutProtocol.substring(index + 1, mediaUrlWithoutProtocol.length);

		if (_streamName.length == 0)
		{
			//throw new Error("Invalid url, no stream name is specified");
		}

		if (_mediaType == StreamingMediaConstants.FLV_MEDIA_TYPE)
		{
			// strip the file extension if it is .flv
			index = _streamName.indexOf(".");
			if (index != -1)
			{
				var extension:String;
				extension = (_streamName.substring(index)).toLowerCase();
				if (extension == ".flv")
				{
					_streamName = _streamName.substring(0, index);
				}
			}
			_streamName = "flv:" + _streamName;
		}
		else if (_mediaType == StreamingMediaConstants.MP3_MEDIA_TYPE)
		{
			// strip the file extension if it is .mp3
			index = _streamName.indexOf(".");
			if (index != -1)
			{
				var extension:String;
				extension = (_streamName.substring(index)).toLowerCase();
				if (extension == ".mp3")
				{
					_streamName = _streamName.substring(0, index);
				}
			}
			_streamName = "mp3:" + _streamName;
		}
		else
		{
			//throw new Error("The display must be playing mp3 or flv media. Instead it is trying to play " + _mediaType);
		}

		// It is not currently playing
		setPlaying(false);
		// It has not yet been loaded
		_isLoaded = false;
		_isLoading = false;
		_isPlayPending = false;
		_nc_rtmp = null;
		_nc_rtmpt = null;

		_playHeadPos = 0;
		setSeeking(false);
		_isPausing = false;

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
		return "RTMPPlayer: Playing " + getMediaUrl();
	}

	/**
	 * Close the player
	 */
	public function close():Void
	{
		_ns.onStatus = null;
		_ns.close();
		_ns = null;
		if (_nc_rtmp != null)
		{
			_nc_rtmp.onStatus = null;
			_nc_rtmp.close();
			_nc_rtmp = null;
		}
		if (_nc_rtmpt != null)
		{
			_nc_rtmpt.onStatus = null;
			_nc_rtmpt.close();
			_nc_rtmpt = null;
		}
		_video.clear();
	}

	/**
	 * Make connection to the server and load the media without playing it.
	 */
	public function load():Void
	{
//		Tracer.trace("RTMPPlayer.load");

		_isLoading = true;
		actualConnect();

		if (_connectTimeOutId != null)
		{
			clearInterval(_connectTimeOutId);
			_connectTimeOutId = null;
		}
		_connectTimeOutId = setInterval(this, "onConnectTimeOut", 6* 10000);
	}

	/**
	 * This is called when successfully connected to the server, and play the
	 * stream if play is pending.
	 */
	private function startStream(nc:NetConnection):Void
	{
		clearInterval(_connectTimeOutId);
		_connectTimeOutId = null;

		// Create a new PlayerNetStream and pass it the netConnection object as
		// it's argument.
		_ns = new PlayerNetStream(nc, this);

		if (_mediaType == StreamingMediaConstants.FLV_MEDIA_TYPE)
		{
			// Attach the stream to a video object, if you forget this step
			// you'll only hear the audio from the PlayerNetStream.
			_video.attachVideo(_ns);
		}
		_video.attachVideo(_ns);
		_videoHeight = _video.height;
		_videoWidth = _video.width;

		// Increase the buffer time so that playback isn't too choppy over
		// slowish network connections
		_ns.setBufferTime(5);

		// Attach the audio portion of the video to the holder mc
		_videoHolder.attachAudio(_ns);

		// Play the media
		_ns.play(_streamName, 0 , -1);
		_isLoading = false;
		_isLoaded = true;
		_videoHolder._visible = false;
		setPlaying(false);

		if (_isPlayPending)
		{
			this.play(null);
		}
		else
		{
			// Ok, we just got the connection success so any
			// request to pause earlier could not have succeeded.
			// So clear the flag call pause() again.
			_isPausing = false;
			this.pause();
		}
	}

	/**
	 * This is called when connection timeout.
	 */
	public function onConnectTimeOut() : Void
	{
		clearInterval(_connectTimeOutId);
		_connectTimeOutId = null;
		if (_nc_rtmpt != null)
		{
			_nc_rtmpt.onStatus = null;
			_nc_rtmpt.close();
			_nc_rtmpt = null;
		}

		if (_nc_rtmp != null)
		{
			_nc_rtmp.onStatus = null;
			_nc_rtmp.close();
			_nc_rtmp = null;
		}

		_isLoading = false;
		_isLoaded = false;

		//throw new Error("Connect TimeOut!");
	}

	/**
	 * Make the actual connection to the server, if the protocol is rtmp and no port
	 * is specified.  We make an extra rtmpt connection to the server after 1.5 seconds.
	 * And use the connection whenever which one makes the connection first.
	 */
	private function actualConnect():Void
	{
		if (_protocol == "rtmp")
		{
			_nc_rtmp = new RTMPConnection(this);
			_nc_rtmp.onStatus = function(info)
			{
				if (info.code == "NetConnection.Connect.Success")
				{
					clearInterval(this._player._conn_Id);

					this._nc_rtmpt.onStatus = null;
					this._nc_rtmpt.close();
					this._nc_rtmpt = null;

					this._player.startStream( this );
					this.popConnection();
				}
			};

			_nc_rtmp.connect("rtmp:" + _appUrl, _streamName);
		}

		if (_protocol == "rtmpt" || ( _protocol == "rtmp" && _port == null ) )
		{
			_nc_rtmpt = new RTMPConnection(this);
			_nc_rtmpt.onStatus = function(info)
			{
				if (info.code == "NetConnection.Connect.Success")
				{
					this._nc_rtmp.onStatus = null;
					this._nc_rtmp.close();
					this._nc_rtmp = null;

					this._player.startStream( this );
					this.popConnection();
				}
			};
			if (_protocol == "rtmpt")
			{
				_nc_rtmpt.connect("rtmpt:" + _appUrl, _streamName);
			}
			else
			{
				//try rtmpt
				clearInterval(_conn_Id);
				_conn_Id = setInterval(this, "connectRtmpt", 3000);
			}
		}
	}

	/**
	 * This is called if we are not getting a successful rtmp connection after 3 seconds
	 * stream if play is pending
	 */
	public function connectRtmpt():Void
	{
		clearInterval(_conn_Id);
		_nc_rtmpt.connect("rtmpt:" + _appUrl, _streamName);
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
//		Tracer.trace("RTMPPlayer.play: " + _mediaUrl);
		setPlaying(true);
		if (startingPoint != null)
		{
			_playHeadPos = startingPoint;
		}

		if (_isLoading || !_isLoaded)
		{
			_isPlayPending = true;
			if (!_isLoaded)
			{
				load();
			}
			return;
		}

		_isPlayPending = false;
		_isPausing = false;
		_ns.pause(false);
		_ns.seek(_playHeadPos);
//		Tracer.trace("RTMPPlayer.play: time=" + _ns.time);
	}

	/**
	 * Stop playback of the media without moving the playhead.
	 */
	public function pause():Void
	{
		if (!_isPausing)
		{
			_ns.pause(true);
			_isPausing = true;
			_isPlayPending = false;
			_playHeadPos = _ns.time;
			setPlaying(false);
		}
//		Tracer.trace("RTMPPlayer.pause: time=" + _ns.time);
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
//		Tracer.trace("RTMPPlayer.setPlayheadTime: " + position);
		_playHeadPos = position;
		if (!_isSeeking)
		{
			_ns.seek(position);
			setSeeking(true);
		}
		if (StreamingMediaConstants.SCRUBBING)
		{
			// Realtime scrubbing is enabled. We don't need to do anything
		}
		else if (!isPlaying())
		{

			_ns.pause(false);
			// I experimented with different interval values. This is
			// the smallest value that reasonably reliably moved the
			// media playhead.
			clearInterval(_momentaryPlayId);
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

	public function playStopped():Void
	{
		_statusCount = 2;
		clearInterval(_checkCompleteId);
		_checkCompleteId = setInterval(this, "checkComplete", 50);
	}

	public function checkComplete():Void
	{
		if (_ns.bufferLength <= .001)
		{
			if (_statusCount <= 0)
			{
				clearInterval(_checkCompleteId);
				_checkCompleteId = null;
				// Officially pause playing
				this.pause();
				broadcastEvent("complete");
			}
			else
			{
				_statusCount -= 1;
			}
		}
	}

	public function getMediaUrl():String
	{
		return _mediaUrl;
	}

	public function setMediaUrl(aUrl:String):Void
	{
		_mediaUrl = aUrl;
		_isLoaded = false;
		var boolIsPlaying:Boolean = isPlaying();
		var soundVolume = getVolume();

		close();

		//call init again, to process the _mediaUrl
		init();

		// Reinstate the volume which gets clobbered in init()
		setVolume(soundVolume);

		if (boolIsPlaying)
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
	 * @return The total time of the media in seconds. It is a property
	 * that is manually set by the author.
	 */
	public function getTotalTime():Number
	{
		return _totalTime;
	}
	public function setTotalTime(aTime:Number):Void
	{
		_totalTime = aTime;
	}

	/**
	 * Called when the media is completely loaded.
	 */
	public function mediaLoaded():Void
	{
		// Dramatically shrink the buffer time to improve
		// responsiveness.
		// There doesn't seem to be any detrimental effect from not
		// changing the buffer.
//		_ns.setBufferTime(.1);

	}
	/**
	 * Log error from FlashCom server
	 */
	public function logError(error:String):Void
	{
		//throw new Error(error);
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
	public function setSeeking(isSeeking:Boolean):Void
	{
		_isSeeking = isSeeking;
	}
}
