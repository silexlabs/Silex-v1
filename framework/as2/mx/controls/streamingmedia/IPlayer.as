//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * IPlayer defines the interface for the implementation classes that play 
 * streaming media files.
 *
 * @author Andrew Guldman
 */
interface mx.controls.streamingmedia.IPlayer
{
	/**
	 * Load the media without playing it.
	 */
	function load():Void;

	/**
	 * Play the media starting at the specified starting point. If the media
	 * hasn't yet been loaded, load it.
	 *
	 * @param startingPoint The number of seconds into the media to start at.
	 *        This is an optional parameter. If omitted, playing will occur
	 *        at the current playhead position.
	 */
	public function play(startingPoint:Number):Void;

	/**
	 * Stop playback of the media without moving the playhead.
	 */
	public function pause():Void;

	/**
	 * Stop playback of the media and reset the playhead to zero.
	 */
	function stop():Void;

	/**
	 * @return The playhead position, measued in seconds since the start.
	 */
	function getPlayheadTime():Number;
	function setPlayheadTime(position:Number):Void;

	function getMediaUrl():String;
	function setMediaUrl(aUrl:String):Void;

	function getVolume():Number;
	function setVolume(aVol:Number):Void;

	/** Is the playhead moving? */
	function isPlaying():Boolean;

	/**
	 * @return The number of bytes of the media that has loaded.
	 */
	function getMediaBytesLoaded():Number;
	/**
	 * @return The total number of bytes of the media.
	 */
	function getMediaBytesTotal():Number;

	/**
	 * @return The total time of the media, in seconds. For some media types this will be
	 * calculated based on the elapsed time, bytes loaded, and bytes total. For
	 * others, it will be a property.
	 */
	function getTotalTime():Number;

	function addListener(aListener:Object):Void;
	function removeAllListeners():Void;

	function playStopped():Void;
	function bufferIsFull():Void;
	function resizeVideo():Void;

	/**
	 * Called when the media is completely loaded.
	 */
	function mediaLoaded():Void;

	/**
	 * Close the player
	 */
	function close():Void;
	function logError(error:String):Void;
	function isSizeSet():Boolean;
	function isSizeChange():Boolean;
	function setSeeking(isSeeking:Boolean):Void;
}
