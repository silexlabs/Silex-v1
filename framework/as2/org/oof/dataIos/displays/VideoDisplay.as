/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import org.oof.dataIos.Display;
/** This component displays video.
 * see org.oof.dataIos.display to see how to configure this component. The only additional
 * properties is bufferTime.
 * 
 * @author Ariel Sommeria-klein, Alexandre Hoyau
 * */
class org.oof.dataIos.displays.VideoDisplay extends Display{

	//screen movieclip in base class contains video
	private var _bufferTime:Number;
	// NetStream and NetConnection objects
	private var _nc:NetConnection;
	private var _ns:NetStream;
	// **
	// constructor
	function VideoDisplay()
	{
		super();
		_className = "org.oof.dataIos.displays.VideoDisplay";
		typeArray.push(_className);
		// NetStream and NetConnection objects
		_nc = new NetConnection;
		_nc.connect(null);
		_ns = new NetStream(_nc);
		_ns.bufferTime = _bufferTime;
		_ns.onStatus = Delegate.create(this,onNsStatus);
		_ns.onMetaData = Delegate.create(this,onNsMetaData);
		screen.video.attachVideo(_ns);
		this.attachAudio(_ns);
	}

	function haltPlayback(){
		super.haltPlayback();
		_ns.seek(0);
		_ns.pause(true);
	}
	
	// onNsStatus: status function for NetStream object
	function onNsStatus(infoObject:Object)
	{
		//tyu("onNsStatus", infoObject);

		// Stream states
		if (infoObject.code == "NetStream.Buffer.Full")
		{
			onLoadComplete();
		}
		
	if (infoObject.code == "NetStream.Play.Stop")
		{
			playerState = PLAYER_STATE_END;
			//reset position, and stop
			haltPlayback();
		}
		
		if (infoObject.code == "NetStream.Buffer.Empty")
		{
			_errorMessage = "buffer empty";
			playerState = PLAYER_STATE_ERROR;
		}
		
		if (infoObject.code == "NetStream.Play.StreamNotFound")
		{
			playerState = PLAYER_STATE_ERROR;
			_errorMessage = "stream not found";
		}
	}
	// onNsMetaData: meta data function for NetStream object
	function onNsMetaData(infoObject:Object) 
	{
		//tyu("onNsMetaData", infoObject);
		
		if(infoObject.duration){
			streamDuration = infoObject.duration;
		}
		if(_playerState == PLAYER_STATE_LOADING){
			onLoadComplete();
		}

	}

	private function loadMediaFile(url:String){
		//note: this would be better done more centrally, but url handling is a mess here and needs to be rewritten. 
		//So do it here to localize possible side effect A.S.
		if(url.indexOf("http://") == -1){
			url = silexPtr.rootUrl + url;
		}
		super.loadMediaFile(url);
		_ns.play(url);
		tyu("loadMediaFile" , url);

	}

	function playMedia(){
		super.playMedia();
		_ns.pause(false);
	}
	
	function pauseMedia()
	{
		super.pauseMedia();
		_ns.pause(true);

	}


	function getBytesLoaded():Number{
		return _ns.bytesLoaded;
	}

	function getBytesTotal():Number{
		return _ns.bytesTotal;
	}
	
	/**function set position
	* value between 0 and 1
	*/
	function set position(val:Number){
		_ns.seek(streamDuration * val);
	}
	
	/**function get position
	* value between 0 and 1
	*/
	function get position():Number{
		return _ns.time / streamDuration;
	}
	
	/** 
	 * property: bufferTime
	 * the buffer size in seconds
	 * */
	[Inspectable(name="buffer size in seconds", type=Number, defaultValue = 6)]
	public function set bufferTime(val:Number){
		_bufferTime = val;
	}
	

	public function get bufferTime():Number{
		return _bufferTime;
	}				
}