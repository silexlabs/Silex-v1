/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component plays audio. (Display here means audio too)
 *  
 * see org.oof.dataIos.display to see how to configure this component.
 * 
 * @author Ariel Sommeria-klein
 * */
import mx.utils.Delegate;
import org.oof.dataIos.Display;

class org.oof.dataIos.displays.AudioDisplay extends Display{
	var _restartAt:Number = 0;
	// **
	// constructor
	function AudioDisplay()
	{
		super();
		_className = "org.oof.dataIos.displays.AudioDisplay";
		typeArray.push(_className);
		_sound.onLoad = Delegate.create(this, onSoundLoad);
		_sound.onSoundComplete = Delegate.create(this, onSoundComplete);
	}
	
	
	function onLoadComplete(){
		super.onLoadComplete();
		streamDuration = _sound.duration / 1000;
	}
	
	function onSoundLoad(success:Boolean){
		if(success){
			onLoadComplete();
		}else{
			_errorMessage = this + " problem loading sound";
			playerState = PLAYER_STATE_ERROR;
			stopMedia();
		}
	}
	
	function onSoundComplete(){
		haltPlayback();
		playerState = PLAYER_STATE_END;
		
	}
	
	
	private function loadMediaFile(url:String){
		super.loadMediaFile(url);
		_sound.loadSound(url, true);
		
	}
	
	function playMedia(){
		super.playMedia();
		
		_sound.start(_restartAt);
	}
	
	
	function pauseMedia()
	{
		super.pauseMedia();
		_restartAt = Math.round(_sound.position/1000);
		_sound.stop();
		
	}
	
	function haltPlayback(){
		super.haltPlayback();
		_sound.stop();
		_restartAt = 0;
		//these 2 below are necessary to reset the position
		_sound.start(0);
		_sound.stop();
	}
	
	
	function getBytesLoaded():Number{
		return _sound.getBytesLoaded();
	}
	
	function getBytesTotal():Number{
		return _sound.getBytesTotal();
	}
	
	/**function set position
	 * value between 0 and 1
	 */
	function set position(val:Number){
		_sound.stop();
		_sound.start(streamDuration * val);
	}
	
	/**function get position
	 * value between 0 and 1
	 */
	function get position():Number{
		return _sound.position / 1000 / streamDuration;
	}
	
}