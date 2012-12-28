/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.ui.players.PlayerBase;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;

[Event("onSoundComplete")]
[Event("soundPlay")]
[Event("soundPause")]
[Event("soundStop")]
[Event("soundId3")]
[Event("soundLoaded")]

class org.silex.ui.players.Audio extends PlayerBase {

	//dimensions
	var __width:Number;
	var __height:Number;
	var nav_sound:MovieClip;
	var contener_mc:MovieClip;
	
	static var FIXED_WIDTH:Number = 20; 
	static var FIXED_HEIGHT:Number = 20;

	//sound
	var soundObject;
	var sndClip:MovieClip;
	var _volume:Number;
	var _savePosition:Number;
	var isMuted_bool:Boolean;
	var _autoPlay_bool:Boolean;
	var isPlaying_bool:Boolean;
	var isPlayInit_bool:Boolean;
	var _loop_bool:Boolean;
	var _showNav_bool:Boolean;
	//Set intervat for time
	var time_interval:Number;
	//url
	var privateUrl_str:String = null;
	/**
	 * Id3 object which will contain media metadata
	 * @example	soundId3 alert:<<myAudioComponent.id3.songname>>
	 */
	var id3:Object;

    /**
	 * function constructor
	 * @return void
	 */
	function Audio() {
     	super();
     	// inheritance
     	typeArray.push("org.silex.ui.players.Audio");
		//create contener global
		this.createEmptyMovieClip("contener_mc",this.getNextHighestDepth());
		//contener image
		contener_mc.createEmptyMovieClip("contenerVide_mc",contener_mc.getNextHighestDepth());
		//nav
		nav_sound = this.attachMovie("nav_sound", "nav_sound", this.getNextHighestDepth());
	}

	function _initialize() {
		super._initialize();

		//available contextmenu
		this.availableContextMenuMethods.push(
/*			{fct:"changeScale", description:"100% scale", param:100}*/
		);
		//availableEvents
		this.availableEvents.push(
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_LOADED, 		description : "on sound loaded"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_COMPLETE,		description : "on sound complete"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_ID3, 			description : "on sound id3"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_PLAY, 		description : "on sound play"},		
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_PAUSE, 		description : "on sound pause"},		
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_SOUND_STOP, 		description : "on sound stop"}		
        );
		//availableMethods
		this.availableMethods.push(
			{modifier:"PLAY", 		description : "play sound"	, parameters: new Array()},
			{modifier:"PAUSE",		description : "pause sound"	, parameters: new Array()},
			{modifier:"STOP", 		description : "stop sound"	, parameters: new Array()},
			{modifier:"MUTE", 		description : "mute sound"	, parameters: new Array()},
			{modifier:"UNMUTE", 	description : "unmute sound", parameters: new Array()}
        );

		//editableProperties first position
		this.editableProperties.unshift(
				{name:"width", 				description:"PROPERTIES_LABEL_WIDTH", 		type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:"", isRegistered:true, minValue:-5000, maxValue:5000, group:"attributes"},
				{name:"height",				description:"PROPERTIES_LABEL_HEIGHT", 		type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:"", isRegistered:true, minValue:-5000, maxValue:5000, group:"attributes"},
				{name:"autoPlay", 			description:"PROPERTIES_LABEL_AUTOPLAY", 		type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"parameters"},
				{name:"loop", 				description:"PROPERTIES_LABEL_AUTOREPLAY", 	type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"parameters"},
				{name:"showNavigation", 	description:"PROPERTIES_LABEL_SHOW_UI",  type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:true, isRegistered:true, group:"parameters"},
				{name:"mute", 				description:"PROPERTIES_LABEL_IS_MUTED", 			type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"parameters"},
				{name:"volume", 			description:"PROPERTIES_LABEL_VOLUME_LEVEL", 			type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:50, isRegistered:true, minValue:1, maxValue:100, group:"parameters"}
		);
		//push end
		this.editableProperties.push({name:"useHandCursor", description:silexInstance.config.PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER, type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"attributes"});
		
		contener_mc.onRollOver = Utils.createDelegate(this, _onRollOver);
		contener_mc.onRollOut = Utils.createDelegate(this, _onRollOut);
		contener_mc.onRelease = Utils.createDelegate(this, _onRelease);
		contener_mc.onPress = Utils.createDelegate(this, _onPress);
		/*
		nav_sound.onRollOver = Utils.createDelegate(this, _onRollOver);
		nav_sound.onRollOut = Utils.createDelegate(this, _onRollOut);
		nav_sound.onRelease = Utils.createDelegate(this, _onRelease);
		nav_sound.onPress = Utils.createDelegate(this, _onPress);*/
		
		// UI init
		nav_sound.mute_btn._visible = false;
		nav_sound.unmute_btn._visible = false;
		//event
		nav_sound.play_btn.onRelease = Utils.createDelegate(this, playMedia);
		nav_sound.pause_btn.onRelease = Utils.createDelegate(this, pauseMedia);
		nav_sound.stop_btn.onRelease = Utils.createDelegate(this, stopMedia);
		// sound
		nav_sound.mute_btn.onRelease = Utils.createDelegate(this, muteMedia);
		nav_sound.unmute_btn.onRelease = Utils.createDelegate(this, unmuteMedia);


		//sound
		soundObject = new Sound();
		soundObject.onLoad = Utils.createDelegate(this, _onLoaded);
		soundObject.onID3 = Utils.createDelegate(this, _onId3);
		soundObject.onSoundComplete = Utils.createDelegate(this, _onSoundComplete);
		_soundbuftime = 6;


		//init
		isPlaying_bool = false;
		isPlayInit_bool = false;
		_savePosition = 0;
		
	}

	/**
	 * function redraw
	 * @return void
	 */
	function redraw() {
		
		//usehandcursor
		if (!useHandCursor) {
			contener_mc.useHandCursor = false;
		} else {
			contener_mc.useHandCursor = true;
		}
		//show nav
		if (showNavigation) {
			nav_sound._visible = true;
		} else {
			nav_sound._visible = false;
		}
		//Adjust navigation position ( bottom left)
		nav_sound._x = 0;
		nav_sound._y = 0;
		//sound
		if (mute) {
			//hide mute btn
			nav_sound.mute_btn._visible = false;
			nav_sound.unmute_btn._visible = true;
		} else {
			//hide unmute btn
			nav_sound.mute_btn._visible = true;
			nav_sound.unmute_btn._visible = false;
		}
		//nav
		if (isPlaying_bool) {
			nav_sound.play_btn._visible = false;
			nav_sound.pause_btn._visible = true;
		} else {
			nav_sound.play_btn._visible = true;
			nav_sound.pause_btn._visible = false;
		}
	}
	/**
	 * set/get rotation
	 * @param Numbershow/hide
	 * @return  void|Number
	 */
	public function set rotation(rotationNumber:Number):Void {
		this.contener_mc._rotation = rotationNumber;
		//refresh
		redraw();
	}
	public function get rotation():Number {
		return this.contener_mc._rotation;
	}
	/**
	 * function set/get width
	 * @param Number
	 * @return  void|Number
	 */
	function set width(intValue:Number):Void {
		//contener_mc._width = FIXED_WIDTH;
		__width = nav_sound._width;
		//__width = 20;
		//refresh
		redraw();
	}
	function get width():Number {
		return __width;
	}
	/**
	 * function set/get height
	 * @param Number
	 * @return  void|Number
	 */
	function set height(intValue:Number):Void {
		//contener_mc._height = FIXED_HEIGHT;
		__height = nav_sound._height;
		//refresh
		redraw();
	}
	function get height():Number {
		return __height;
	}
	/**
	 * set/get mute
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set mute(mute_bool:Boolean):Void {
		if (mute_bool) {
			muteMedia();
		} else {
			unmuteMedia();
		}
		redraw();
	}
	function get mute():Boolean {
		//stock voulme
		return this.isMuted_bool;
	}
	/**
	 * muteMedia 
	 * @return  void
	 */
	function muteMedia():Void {
		//set vol 0
		setMediaVolume(0);
		//mute
		this.isMuted_bool = true;
		//redraw
		redraw();
	}
	/**
	 * unmuteMedia 
	 * @return  void//
	 */
	function unmuteMedia():Void {
		//set volume to volume stocked
		setMediaVolume(volume);
		//mute
		this.isMuted_bool = false;
		//redraw
		redraw();
	}
	/**
	 * setMediaVolume
	 */
	function setMediaVolume(vol:Number):Void {
		soundObject.setVolume(vol);
	}
	/**
	 * set/get volume 
	 * @param Number
	 * @return  void|Number
	 */
	function set volume(vol_int:Number):Void {
		//stock volume
		this._volume = vol_int;
		//change volume
		soundObject.setVolume(this._volume);
	}
	function get volume():Number {
		//return volume
		return this._volume;
	}

	/**
	 * set/get autoPlay 
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set autoPlay(auto_bool:Boolean):Void {
		//stock auto play
		this._autoPlay_bool = auto_bool;
	}
	function get autoPlay():Boolean {
		//return auto play
		return this._autoPlay_bool;
	}
	/**
	 * set/get loop
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set loop(auto_bool:Boolean):Void {
		//stock voulme
		this._loop_bool = auto_bool;
	}
	function get loop():Boolean {
		//stock voulme
		return this._loop_bool;
	}
	/**
	 * set/get showNavigation
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set showNavigation(auto_bool:Boolean):Void {
		//stock voulme
		this._showNav_bool = auto_bool;
		//show nav_video
		redraw();
	}
	function get showNavigation():Boolean {
		//stock voulme
		return this._showNav_bool;
	}
	/**
	 * set/get url 
	 * @param String
	 * @return  void|Number
	 */
	function get url():String {
		return privateUrl_str;
	}
	function set url(url_str:String):Void {
		
		var urlRevealed:String = silexInstance.utils.revealAccessors(url_str,this);
		var ext = urlRevealed.substr(-3);
		
		var hookManager:HookManager = HookManager.getInstance();
		var filteredObj:Object = {url:urlRevealed, fileExtension:ext};
		hookManager.callHooks("org.silex.core.filter.url", filteredObj);
		
		//reinitialize 
		isPlayInit_bool = false;
		privateUrl_str = filteredObj.url;
		silexInstance.sequencer.doInNextFrame(Utils.createDelegate(this, doLoadMedia));


	}
	/**
	 * play media
	 */
	function playMedia():Void {
		//not yet initialized
		if (!isPlayInit_bool) {
			isPlayInit_bool = true;
			_savePosition = 0;
			//load song in streaming
			//var url:String = silexInstance.config.websiteFtpRelativeUrl;
			// build url
			var url_str:String;
			if (privateUrl_str.indexOf("http")==0 || privateUrl_str.indexOf("file")==0)
				url_str = privateUrl_str
			else
				url_str = silexInstance.rootUrl + privateUrl_str;			

			soundObject.loadSound( url_str,true);
			isPlaying_bool = true;
			////todo : display loading ??
			redraw();
		} else {
			//fct pauseMedia
			pauseMedia();
		}
		trace("execution fonction playMedia");
	}
	
	/**
	 * pause media
	 */
	function pauseMedia():Void {
		//if pause
		if (isPlaying_bool) {
			isPlaying_bool = false;
			//stop
			soundObject.stop();
			// _savePosition is in milliseconds
			_savePosition = soundObject.position;
			//event
			this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_PAUSE});
		} else {
			//start
			// soundObject.start is in seconds
			soundObject.start(_savePosition/1000);
			isPlaying_bool = true;
			//event
			this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_PLAY});
		}
		//redraw
		redraw();
	}
	
	/**
	 * stop media
	 */
	function stopMedia():Void {
		//retour debut
		isPlaying_bool = false;
		soundObject.stop();
		_savePosition = 0;
		//redraw
		redraw();
		//event
		this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_STOP});
	}
	
	
	/** 
	 * wrappers functions
	 **/
	function STOP(){
		stopMedia();
	}
	
	function PAUSE(){
		pauseMedia();
	}
	
	function PLAY(){
		playMedia();
	}
	
	function MUTE(){
		muteMedia();
	}
	
	function UNMUTE(){
		unmuteMedia();
	}
	
	
	
	/* song loaded*/
	function _onLoaded() {
		//todo : hide loading ????
		//playMedia();
		soundObject.start();
		redraw();
		//event
		this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_LOADED});
	}
	
	/* song complete */
	function _onSoundComplete() {
		_savePosition = 0;
		isPlaying_bool = false;
		if (loop) {
			playMedia();
		}
		//event
		this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_COMPLETE});
	}

	/* infos */
	function _onId3() {
		// stores id3 in new object as soundObject.id3 is not always available for silex
		id3 = new Object;
		var prop:String;
		for (prop in soundObject.id3) {
			id3[prop] = soundObject.id3[prop];
			trace("id3-" + prop + ": " + id3[prop]);
		}
		// removed (see above's comment)
		//id3 = soundObject.id3;
		//event
		this.dispatch({target:this, type:silexInstance.config.UI_PLAYERS_EVENT_SOUND_ID3});
	}
	
	//displaytime insterval
	function displayTime(interval) {
		//position
		if (soundObject.position != undefined) {
			nav_sound.playTime.text = Math.round(soundObject.position);
		} else {
			nav_sound.playTime.text = 0;
		}
		//duration
		nav_sound.totalTime.text = Math.round(soundObject.duration);
	}

	/**
	 * function _onPress
	 * @param stringmedia url 
	 * @return void
	 */
	public function loadMedia(url_str:String):Void {
		//stock url
		this.url = url_str;// => setter will call doLoadMedia
	}
	
	function doLoadMedia() {
		Utils.removeDelegate(this, doLoadMedia);
		//time
		time_interval = setInterval(this, "displayTime", 500);
		//play video
		if (autoPlay) {
			//playmedia if autoplay
			playMedia();
		} else {
			//msg ?
		}
	}
	/**
	 * function unloadMedia
	 * @return void
	 */
	public function unloadMedia():Void {
		super.unloadMedia();
		clearInterval(time_interval);
		soundObject.stop();
		Utils.removeDelegate(this, _onLoaded);
		Utils.removeDelegate(this, _onId3);
		Utils.removeDelegate(this, _onSoundComplete);

	}
	// **
	// override PlayerBase class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object) {
		// to local
		this.layerInstance.globalToLocal(coord);

		// apply the new coordinates to the player
		_x = coord.x;
		_y = coord.y;
	}
	function setGlobalCoordBR(coord:Object) {
		// to local
		this.layerInstance.globalToLocal(coord);
		// get width and height
		coord.x = coord.x-_x;
		coord.y = coord.y-_y;

		// apply the new coordinates to the player
		width = coord.x;
		height = coord.y;
	}
	function getGlobalCoordTL() {
		// from global coords
		var coordTL:Object = {x:_x, y:_y};

		// to global
		this.layerInstance.localToGlobal(coordTL);

		return coordTL;
	}
	function getGlobalCoordBR() {
		// from global coords
		var coordBR:Object = {x:width+_x, y:height+_y};

		// to global
		this.layerInstance.localToGlobal(coordBR);

		return coordBR;
	}

	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	 function getSeoData(url_str:String):Object {
		var res_obj:Object=super.getSeoData();
		
		// html equivalent
/*		if (descriptionText)
			res_obj.htmlEquivalent="<a href='"+url_str+privateUrl_str+"'>"+descriptionText+"</a>";
		else
			res_obj.htmlEquivalent="<a href='"+url_str+privateUrl_str+"'>"+url_str+privateUrl_str+"</a>";
*/		
		res_obj.htmlEquivalent = '<object type="audio/mpeg" data="'+url_str+privateUrl_str+'" width="200" height="20">';
		res_obj.htmlEquivalent += '<param name="src" value="'+url_str+privateUrl_str+'"><param name="autoplay" value="false"><param name="autoStart" value="0">';
		if (descriptionText)
			res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + descriptionText + "</a>";
		else
			res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + privateUrl_str + "</a>";			
		res_obj.htmlEquivalent += '</object>';

		return res_obj;
	}
	/*	//override PlayerBase method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object = new Object();
		res_obj.keywords = descriptionText;
		res_obj.description = descriptionText;
		res_obj.context = getUiContext();
		//html 
		var htmlContent = '<a href="';
		htmlContent += url_str+silexInstance.config.initialFtpFolderPath+silexInstance.config.websiteFtpRelativeUrl+this.privateUrl_str;
		htmlContent +='">';
		if (descriptionText)
			htmlContent += descriptionText;
		else
			htmlContent += this.privateUrl_str;

		htmlContent += '</a>';
		//assign
		res_obj.htmlEquivalent = htmlContent;
		return res_obj;
	}
*/}