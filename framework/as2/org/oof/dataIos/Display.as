/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.DataIo;
import org.oof.dataIos.StringIo;
import mx.utils.Delegate;
import gs.TweenLite;

/* class: org.oof.dataIos.Display
	This is the base class for all displays. A display shows/plays a media:
	text, video, audio, image, etc.
	It provides the following common functionality:
  - events and commands to control and react to the display. play pause stop, media ended, etc.
  - status such as head position, media duration etc.
  - fade in/out.
  
  	Mostly you use a display with a DataSelector. The DataSelector retrieves a list of media,
  	the user clicks one and the displays plays it accordingly. 
  	to do this, you must configure "outputFormats" in the DataSelector. 
  	for example, put videoDisplay.value=<<mediaUrl>> there.
  	Of you want to use it standalone, set singleMediaUrl
  	
  	Note: multiple types of media in one list are not supported. 
  	You must have only audio, only video, etc.
  	
	author:
	 Ariel Sommeria-klein
*/
class org.oof.dataIos.Display extends StringIo{
	/** 
	 * Group: constants (internal)
	 * */
	static var PLAYER_STATE_INIT:String = "INIT";
	static var PLAYER_STATE_PLAY:String = "PLAY";
	static var PLAYER_STATE_LOADING:String = "LOADING";
	static var PLAYER_STATE_PAUSE:String = "PAUSE";
	static var PLAYER_STATE_STOP:String = "STOP";
	static var PLAYER_STATE_ERROR:String = "ERROR";
	static var PLAYER_STATE_END:String = "END";

	//these events correspond to player state changes, and are triggered in the set playerState procedure
	static var EVENT_INIT:String = "displayInit"; // player init
	static var EVENT_PLAY:String = "displayPlay"; // Playback has started
	static var EVENT_LOADING:String = "displayLoading"; // Playback has started
	static var EVENT_PAUSE:String = "displayPause"; // Playback has paused
	static var EVENT_STOP:String = "displayStop"; // Playback has stopped(user intervention)
	static var EVENT_END:String = "displayEnd"; // Playback has ended(end of media)
	static var EVENT_ERROR:String = "displayError"; // error
	
	//this event corresponds to streamDuration change, and is triggered in the set streamDuration procedure
	static var EVENT_DURATIONKNOWN:String = "displayDurationKnown"; //the display knows how long the stream lasts

	/**
	 * Group: Events/callbacks
	 * */
	var displayInit:Function = null;
	var displayPlay:Function = null;
	var displayLoading:Function = null;
	var displayPause:Function = null;
	var displayStop:Function = null;
	var displayEnd:Function = null;
	var displayError:Function = null;
	var displayDurationKnown:Function = null;
	
	/**
	 * Group: internal variables
	 * */
	 
	private var _singleMediaUrl:String = null;
	private var _streamDuration:Number = 0; //stored in seconds

	private var _playerState:String = "";
	private var _mediaUrl:String=null;

	private var _initialVolume:Number = 0;	
	private var _sound:Sound;

	private var _fadeDuration:Number = 0;
	private var _fadeCoef:Number = 0;
	private var _isFaded:Boolean = false;
	
	private var _mediaToChangeToOnFadeOutFinished:String = null;
	private var _errorMessage:String = null;
	private var _mediaLoaded:Boolean = false;
	
	private var _setData:String = null;
	
	//ui 
	var screen:MovieClip;
// **
	/**
	 * Group: internal class functions
	 * */
	 
	// constructor
	function Display()
	{
		super();
		//_className = "org.oof.dataIos.Display";
		// states
		playerState = PLAYER_STATE_INIT;
		_sound = new Sound(this);
		
		if(_fadeDuration != 0){
			//start faded
			_isFaded = true;
			_fadeCoef = 0;
			_sound.setVolume(0);
			screen._alpha = 0;
		}else{
			_isFaded = false;
			_fadeCoef = 100;
			_sound.setVolume(_initialVolume);
			screen._alpha = 100;
		}
	}
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tryToLoadFromSingleMediaUrl();


	
	}
	
	 /**
	 * looks at single media url and tries to load from it if it is set
	 * */
	 private function tryToLoadFromSingleMediaUrl():Void{
		 
		 if((_singleMediaUrl != null) && (_singleMediaUrl != "")){
			 changeMedia(silexPtr.utils.revealAccessors (_singleMediaUrl, this));
		 }
	 }
	
	/** private function setUiData
	* display the data on the user interface. Here it displays the Image
	* @returns void
	*/
	private function setUiData(val:String){
		_setData= val;
		changeMedia(val);
	}
	
	/** private function getDataFromUi
	* get the data from the user interface(url passed)
	* @return String
	*/
	private function getDataFromUi():String{
		return _setData;
	}
	
	/**
	 * the size() fucntion used to be called by uibase, but not any more. As it is only used in tyhe oof displays,
	 * call it here
	 * */
	function setSize(w:Number, h:Number, noEvent:Boolean):Void{
		super.setSize(w, h, noEvent);
		size();
	} 
	
	function size(){
		screen._width = width;
		screen._height = height;
	}
	
	function onLoadComplete(){
		fadeIn();
		_mediaLoaded = true;
		//somehow sound volume reset when new sound loaded. 
		_sound.setVolume(_initialVolume);
		//start playback is automatic in all cases, for the moment.
		playerState = PLAYER_STATE_PLAY;
	}
	
	private function loadMediaFile(url:String){
		playerState = PLAYER_STATE_LOADING;
		//implement loading code in subclass
	}
	
	function reload(){
		loadMediaFile(_mediaUrl);
	}
	
	private function changeMedia(url:String){
		
		if ((url == null) || (url == "") || (url == undefined)){
			//stop the player. not necessarily an error, this happens when the selector clears its data.
			stopMedia();
			return;
		}
		
		_mediaUrl = url;
		if(playerState == PLAYER_STATE_PLAY){
			//player running. fade out before playing new media
			_mediaToChangeToOnFadeOutFinished = url;
			fadeOut();
			return;
		}
		
		loadMediaFile(buildUrl(url));
		
	}
	
	function doOnFadeOutFinished(){
		if(_mediaToChangeToOnFadeOutFinished != null){
			loadMediaFile(buildUrl(_mediaToChangeToOnFadeOutFinished));
			_mediaToChangeToOnFadeOutFinished = null;
		}
		
	}	
	
	function doOnFadeInFinished(){
		//nothing in base class for now
	}	
	
	function fadeIn(){
		_isFaded = false;
		TweenLite.to(screen, _fadeDuration, {_alpha:100, onComplete:Delegate.create(this, doOnFadeInFinished)});
	}	

	function fadeOut(){
		_isFaded = true;
		TweenLite.to(screen, _fadeDuration, {_alpha:0, onComplete:Delegate.create(this, doOnFadeOutFinished)});
	}
	
	private function haltPlayback(){
		//private function called by error, stop, end
		//don't set player state here. do it in calling function.
		fadeOut();
	}
	
	/** 
	 * group: public functions and properties. 
	 * */ 
	 
	 /**
	 * function: playMedia
	 * starts media playback
	 * */
	 
	function playMedia()
	{
		if((playerState != PLAYER_STATE_PAUSE) && (playerState != PLAYER_STATE_STOP)){
			return;
		} 
		if(_isFaded){
			fadeIn();
		}
			
		playerState = PLAYER_STATE_PLAY;
	}

	 /**
	 * function: pauseMedia
	 * pauses media playback
	 * */
	 
	function pauseMedia()
	{
		if (playerState != PLAYER_STATE_PLAY){
			return;
		}
		playerState = PLAYER_STATE_PAUSE;

		
	}

	 /**
	 * function: stopMedia
	 * stops media playback
	 * */
	 
	function stopMedia(isEndOfMedia:Boolean)
	{
		haltPlayback();
		playerState = PLAYER_STATE_STOP;

	}
	
	 /**
	 * function: getBytesLoaded
	 * useful for a loading status bar
	 * */
	 
	function getBytesLoaded():Number{
		throw new Error(this + " getBytesLoaded not implemented");
		return null;
	}

	 /**
	 * function: getBytesTotal
	 * useful for a loading status bar
	 * */
	 
	function getBytesTotal():Number{
		throw new Error(this + " getBytesTotal not implemented");
		return null;
	}
	
	/**
	 * property: position
	 * the position of the playback head.
	 * value between 0 and 1. 0 is the beginning, 1 is the end.
	 */
	function set position(val:Number){
		throw new Error(this + " set position not implemented");
		
	}

	function get position():Number{
		throw new Error(this + " get position not implemented");
		return null;
		
	}
	
	/** 
	 * property: playerState
	 * you probably shouldn't be setting this, but a display control needs 
	 * to get it. Possible values are defined by the playback_state constants(see above)
	 * */ 
	public function set playerState(val:String){
		//trigger associated event
		var eventType = null;
		switch(val){
			case PLAYER_STATE_INIT:
				eventType = EVENT_INIT;
				break;
			case PLAYER_STATE_PLAY:
				eventType = EVENT_PLAY;
				break;
			case PLAYER_STATE_LOADING:
				eventType = EVENT_LOADING;
				break;
			case PLAYER_STATE_PAUSE:
				eventType = EVENT_PAUSE;
				break;
			case PLAYER_STATE_STOP:
				eventType = EVENT_STOP;
				break;
			case PLAYER_STATE_END:
				eventType = EVENT_END;
				break;
			case PLAYER_STATE_ERROR:
				eventType = EVENT_ERROR;
				break;
			default :
				throw new Error(this + "play state not recognised : " + val);
		}
		dispatch({target:this, type:eventType});
		if(this[eventType] != null){
			//user callback defined from outside
			this[eventType].call(this);
		}
		_playerState = val;
	}
	
	public function get playerState():String{
		return _playerState;
	}		
	
	/** 
	 * property: streamDuration
	 * how long the media lasts, in seconds
	 * */
	public function get streamDuration():Number{
		return _streamDuration;
	}		

	public function set streamDuration(val:Number){
		//trigger associated event
		_streamDuration = val;
		dispatchEvent({target:this, type:EVENT_DURATIONKNOWN});
	}
	

	/** 
	 * property: volume
	 * the volume, between 0 and 1
	 * */
	public function get volume() : Number {
		return _sound.getVolume();
	}
	
	public function set volume(pVolume : Number) : Void {
			_sound.setVolume(pVolume);
	}	
	

	/** function get errorMessage
	* @returns String
	*/
	
	public function get errorMessage():String{
		return _errorMessage;
	}		
	
	/**
	 * Group: inspectable properties
	 * */
	
	
	
	/** property: singleMediaUrl
	 * supposing you don't want to get a DataSelector to feed the media
	 * url to the display. use this!
	 * */
	[Inspectable(name="url",type=String, defaultValue="")]
	public function set singleMediaUrl(val:String){
		_singleMediaUrl = val;
		if(_initAfterRegisterOccuredFlag){
			tryToLoadFromSingleMediaUrl();
		}
	}
	
	public function get singleMediaUrl():String{
		return _singleMediaUrl;
	}		

	/** 
	 * property: fadeDuration
	 * how long it takes for the player to fade in and out. (mute for audio)
	 * */
	[Inspectable(name="fade/mute duration", type=Number, defaultValue=1)]
	public function set fadeDuration(val:Number){
		_fadeDuration = val;
	}
	
	public function get fadeDuration():Number{
		return _fadeDuration;
	}			

	/** 
	 * property: initialVolume
	 * audio volume that the player starts with. Only used on load
	 * */ 	
	[Inspectable(name="initial volume", type=Number, defaultValue=100)]
	public function set initialVolume(val:Number){
		_initialVolume = val;
	}
	
	public function get initialVolume():Number{
		return _initialVolume;
	}		
}