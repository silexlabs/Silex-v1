//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.FLVPlayer;
import mx.controls.streamingmedia.IPlayer;
import mx.controls.streamingmedia.RTMPPlayer;

/**
 * A subclass of NetStream that is tailored to work with the FLVPlayer
 * class.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.PlayerNetStream
extends NetStream
{
	private var _player:IPlayer;
	// Id of the interval used to capture the start of the media playback
	private var initId:Number;
	private var checkSizeInterval:Number;
	private var detectedFirstBuffer:Boolean;

	/**
	 * Constructor takes two mandatory parameters.
	 *
	 * @param nc The NetConnection used by this NetStream
	 * @param aPlayer The IPlayer associated with the NetStream
	 */
	public function PlayerNetStream(nc:NetConnection, aPlayer:IPlayer)
	{
		super(nc);
		setPlayer(aPlayer);
	}

	public function getPlayer():IPlayer
	{
		return _player;
	}

	public function get player():IPlayer
	{
		return getPlayer();
	}

	public function setPlayer(aPlayer:IPlayer)
	{
		_player = aPlayer;
	}

	public function set player(aPlayer:IPlayer)
	{
		setPlayer(aPlayer);
	}

	/**
	 * Add debugging logging call.
	 */
	public function pause(shouldPause:Boolean):Void
	{
		//Tracer.trace("PlayerNetStream.pause(" + shouldPause + ")");
		super.pause(shouldPause);
	}

	public function	setBufferTime(time:Number):Void
	{
		//Tracer.trace("PlayerNetStream.setBufferTime(" + time + ")");
		super.setBufferTime(time);
	}

	public function play(name:Object, st:Number, len:Number, reset:Object)
	{
	//	Tracer.trace("PlayerNetStream.play(" + name + ")");
//		Tracer.trace("PlayerNetStream.play(" + name + "," + st + "," + len + "," reset + ")");
		super.play(name, st, len, reset);
	}

	public function seek(offset:Number):Void
	{
		//Tracer.trace("PlayerNetStream.seek(" + offset + ")");
		super.seek(offset);
	}

	public function close():Void
	{
		//Tracer.trace("PlayerNetStream.close()");
		super.close();
	}

	public function attachAudio(theMicrophone:Microphone):Void
	{
		//Tracer.trace("PlayerNetStream.attachAudio(" + theMicrophone + ")");
		super.attachAudio(theMicrophone);
	}

	public function attachVideo(theCamera:Camera,snapshotMilliseconds:Number):Void
	{
		//Tracer.trace("PlayerNetStream.attachVideo(" + theCamera + "," + snapshotMilliseconds + ")");
		super.attachVideo(theCamera,snapshotMilliseconds);
	}


	/**
	 * onStatus function for the NetStream. "this" is the NetStream object.
	 */
	public function onStatus(info)
	{
		var pl:IPlayer = this.getPlayer();
		//Tracer.trace("PlayerNetStream.onStatus: code=" + info.code + ", level=" + info.level + ", this=" + this + ", player=" + pl);

		switch (info.code)
		{
			case "NetStream.Buffer.Full":
//				Tracer.trace("PlayerNetStream.onStatus: buffer full. video size=" + pl._video.width + "x" + pl._video.height);

//				pl.bufferIsFull();
				break;

			case "NetStream.Play.Start":
				//we are setting up a timer to detect if there is a size change, and trigger the redraw if necessary
				detectedFirstBuffer = false;
				clearInterval(this.initId);
				this.checkSizeInterval = 10;
				this.initId = setInterval(this, "detect", this.checkSizeInterval);
				break;

			case "NetStream.Pause.Notify":
//				Tracer.trace("PlayerNetStream.onStatus: paused playback");
				break;

			case "NetStream.Play.Stop":
				// This happens when the playhead reaches the end of the FLV.
//				Tracer.trace("PlayerNetStream.onStatus: stopped playback");
				clearInterval(this.initId);
				pl.playStopped();
				break;
			case "NetStream.Play.Failed":
			case "NetStream.Play.StreamNotFound":
				//For now, this is for rtmp to return error if stream not found
				var error:String;
				error = "Error playing URL: " + info.description;
				pl.logError(error);
				break;
			case "NetStream.Seek.Notify":
				pl.setSeeking(false);
				break;
		}
	}


	/**
	 * Detect when the video object's width and height are set.
	 */
	public function detect()
	{
		var pl:IPlayer = this.getPlayer();

		//we should start playing immediately because a video frame can come in late, and we worry about resizing later
		//when we call detect().
		if (!detectedFirstBuffer && pl.isSizeSet())
		{
			detectedFirstBuffer = true;
			pl.bufferIsFull();
		}

		//Tracer.trace("detect: " + pl._video.width + "x" + pl._video.height);
		if (pl.isSizeChange())
		{
			// The stream is initialized when the video's width & height are set
			pl.resizeVideo();
		}
		//detect should never stop while a stream is playing, so that it can catch a 
		//video size change.  But we should double the interval everytime a detect fails
		//because the size probably only change once at the beginning.  And we won't 
		//waste too much cpu to detect.
		clearInterval(this.initId);
		this.checkSizeInterval = this.checkSizeInterval * 2;
		this.initId = setInterval(this, "detect", this.checkSizeInterval);
	}

	/**
	 * This is the handler which will process meta information
	 * The argument passed in is an array.
	 */
	public function onMetaData(info)
	{
		// Currently only duration is defined
		var pl:IPlayer = getPlayer();

		if (pl instanceof FLVPlayer)
		{
			var fp:FLVPlayer = FLVPlayer(pl);
			fp.setTotalTime(info.duration);
		}
		else if (pl instanceof RTMPPlayer)
		{
			var rp:RTMPPlayer = RTMPPlayer(pl);
			rp.setTotalTime(info.duration);
		}
	}

}