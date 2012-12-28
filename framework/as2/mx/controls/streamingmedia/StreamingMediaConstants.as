//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * This class holds public constants used in the StreamingMedia package.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.StreamingMediaConstants
{
	public static var FLV_MEDIA_TYPE:String = "FLV";
	public static var MP3_MEDIA_TYPE:String = "MP3";
	/** "play" active play control */
	public static var PLAY_PLAY_CONTROL:String = "play";
	/** "pause" active play control */
	public static var PAUSE_PLAY_CONTROL:String = "pause";
	/** Starting volume position, between 0 and 100 */
	public static var DEFAULT_VOLUME:Number = 75;
	/**
	 * This variable controls whether real-time scrubbing is enabled.
	 * It effects two areas in the system:
	 * 1. The PlayBarThumb.handleMouseMove method sends a playheadChange event as the 
	 *    thumb is moved if scrubbing is enabled.
	 * 2. The FLVPlayer.setPlayheadTime method positions the playhead differently
	 *    depending on whether scrubbing is enabled.
	 */
	public static var SCRUBBING:Boolean = true;

	/**
	 * This variable indicates the strategy we will use for sizing FLV
	 * video objects. Allowable values are "poll" and "bufferFull".
	 *  - "poll" will repeatedly check to see if the video object has valid
	 * height or width properties before setting it.
	 *  - "bufferFull" will set the size upon receipt of the first 
	 * "NetStream.Buffer.Full" status event after initiating loading 
	 * of the media.
	 *
	 * We always use the bufferFull technique.
	public static var VIDEO_SIZING_STRATEGY:String = "bufferFull";
	 */

	/**
	 * If this is true then the "to end" button will *always* be disabled
	 * when playing FLV media. This is necessary due to limitations in
	 * the NetStream and Video objects that prevent FLV files from being
	 * reliably positioned at the end.
	 */
	public static var DISABLE_FLV_TOEND:Boolean = true;
}