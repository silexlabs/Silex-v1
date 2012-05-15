/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
	
/**
 * Name : Image.as
 * Package : ui.players
 * Version : 1.0a2
 * Date :  2007-08-03
 * Author : julien Rollin
 * URL : http://www.jenreve.fr
 * Mail : j.rollin@jenreve.fr	 
 */


import org.silex.ui.players.PlayerBase;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
	 
[Event("onStatus")]
[Event("onMetadata")]
[Event("bufferEmpty")]
[Event("bufferFull")]
[Event("netStreamNotFound")]
[Event("netStreamPlay")]
[Event("netStreamPause")]
[Event("netStreamStop")]
[Event("netStreamStart")]
[Event("netStreamEnd")]
class org.silex.ui.players.Video extends PlayerBase {
	
	//contener media
   	var contener_video:MovieClip;
	var nav_video:MovieClip;
	var __width:Number;
	var __height:Number;

	//video
	var screen_video:Video;
	//netStream
	var _ns:NetStream = null;
	var	streamDuration:Number ;
	var _streamReceived:Boolean = false;
	//Set interval for time
	var time_interval:Number;
	//netconnection
	var _nc:NetConnection = null;
	//sound
	var _sound:Sound;
	var _volume:Number;
	var isMuted_bool:Boolean;
	//video
	var _autoPlay_bool:Boolean;
	var isPlaying_bool:Boolean = false;
	var isPlayInit_bool:Boolean = false;
	var autoSize_bool:Boolean;
	var _loop_bool:Boolean;
	var _showNav_bool:Boolean;
	var _bufferSize:Number;
	//url
	var privateUrl_str:String = null;
	//accesssors 
	var current_time:Number;
	var total_time:Number;
	var _currentTimePlayer_str:String;
	var _totalTimePlayer_str:String;
	var playerTotal_obj:Object;
	var playerCurrent_obj:Object;
	/**
	 * step by which is incremented the alpha when we show the image
	 */
	var fadeInStep:Number;
	
	
	/**
	  * constructor
	  * @return void
	  */
     public function Video(){
     	super();
     	// inheritance
     	typeArray.push("org.silex.ui.players.Video");
    }    
	
	/**
	 * function initialize
	 * @return void
	 */
	private function _initialize():Void{
		super._initialize();

		//nav
		nav_video = this.attachMovie("nav_video","nav_video", this.getNextHighestDepth());
		nav_video.mute_btn._visible	= false;
		nav_video.unmute_btn._visible	= false;
		//anim
		playAnim(nav_video);
		
		//context menu
		this.availableContextMenuMethods.push(
/*			{ fct :"changeScale", 	description :"100% scale", 			param : 100}*/
		);
		//availableEvents
		this.availableEvents.push(
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_STATUS, 			description : "onStatus"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_METADATA,			description : "onMetadata"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_BUFFER_EMPTY, 		description : "bufferEmpty"},
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_BUFFER_FULL, 		description : "bufferFull"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_NOSTREAM, 			description : "netStreamNotFound"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_PLAY, 				description : "netStreamPlay"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_PAUSE, 				description : "netStreamPause"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_STOP, 				description : "netStreamStop"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_START, 				description : "netStreamStart"}	,
			{modifier:silexInstance.config.UI_PLAYERS_EVENT_END, 				description : "netStreamEnd"}		
        );		

		//availableMethods
		this.availableMethods.push(
			{modifier:"PLAY", 		description : "play video"	, parameters:new Array()},
			{modifier:"PAUSE",		description : "pause video"	, parameters:new Array()},
			{modifier:"STOP", 		description : "stop video"	, parameters:new Array()},
			{modifier:"MUTE", 		description : "mute video"	, parameters:new Array()},
			{modifier:"UNMUTE", 	description : "unmute video", parameters:new Array()}
        );		
		
		//editableProperties first position
		this.editableProperties.unshift(   
			{ name :"width" ,			description:"PROPERTIES_LABEL_WIDTH", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER			, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:"PROPERTIES_LABEL_HEIGHT", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"scale" , 			description:"PROPERTIES_LABEL_SCALE", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER			, defaultValue: ""	, isRegistered: false	, minValue:1,  	maxValue:5000, group:"attributes" },
			{ name :"autoPlay" , 		description:"PROPERTIES_LABEL_AUTOPLAY", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"parameters" },
			{ name :"autoSize" , 		description:"PROPERTIES_LABEL_AUTOSIZE", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"loop" , 			description:"PROPERTIES_LABEL_AUTOREPLAY", 			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"parameters" },
			{ name :"showNavigation" , 	description:"PROPERTIES_LABEL_SHOW_UI", 			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"bufferSize" , 		description:"PROPERTIES_LABEL_BUFFER_SIZE_MS", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER			, defaultValue: 6	, isRegistered: true	, minValue:1,  	maxValue:30, group:"parameters" },
			{ name :"mute" , 			description:"PROPERTIES_LABEL_IS_MUTED", 					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"parameters" },
			{ name :"volume" , 			description:"PROPERTIES_LABEL_VOLUME_LEVEL", 					type: silexInstance.config.PROPERTIES_TYPE_NUMBER			, defaultValue: 50	, isRegistered: true	, minValue:1,  	maxValue:100, group:"parameters" }/*,
			{ name :"currentTimePlayer" , description:"currentTime Player text", 					type: silexInstance.config.PROPERTIES_TYPE_TEXT			, defaultValue: ""	, isRegistered: true	, group:"parameters" },
			{ name :"totalTimePlayer" , description:"total Player text", 		type: silexInstance.config.PROPERTIES_TYPE_TEXT			, defaultValue: ""	, isRegistered: true	, group:"parameters" }*/
		)
		//push end
		this.editableProperties.push(  
			{ name :"useHandCursor" , 	description:"PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER", 	type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"attributes" },
			{ name :"fadeInStep" , 	description:"PROPERTIES_LABEL_FADE_IN_STEP", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: 100	, isRegistered: true	, minValue:.1,  	maxValue:100, group:"parameters" }/*,
			{ name :"_focusrect" , 		description:"show yellow border", 		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"_tabEnabled" , 	description:"enables tabulation ",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"_tabChildren" , 	description:"children during tab",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"_tabIndex" , 		description:"the index for the tab", 	type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: 1		, isRegistered:true , minValue:+1,  	maxValue:+5000, group:"others" }*/
		);	
		
		//video
		contener_video.onRelease 	= Utils.createDelegate(this, _onRelease);
		contener_video.onPress 		= Utils.createDelegate(this, _onPress);
		contener_video.onRollOver 	= Utils.createDelegate(this, _onRollOver);
		contener_video.onRollOut 	= Utils.createDelegate(this, _onRollOut);
		// UI init
		nav_video.play_btn.onRelease	= Utils.createDelegate(this,playMedia);
		nav_video.pause_btn.onRelease	= Utils.createDelegate(this,pauseMedia);
		nav_video.stop_btn.onRelease	= Utils.createDelegate(this,stopMedia);		
		// sound
		nav_video.mute_btn.onRelease	= Utils.createDelegate(this,muteMedia);
		nav_video.unmute_btn.onRelease= Utils.createDelegate(this,unmuteMedia);
		
		
		//NetConnection objects
		_nc	= new NetConnection;
		_nc.connect(null);
		//NetStream
		_ns = new NetStream(_nc);
		_ns.onStatus	= Utils.createDelegate(this,_onStatus);
		_ns.onMetaData	= Utils.createDelegate(this,_onMetaData);
		//video + sound
		contener_video.screen_video.attachVideo(_ns);
		this.attachAudio(_ns);
		_sound = new Sound(this);		
	}
   	

	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		//usehandcursor
		if(!useHandCursor){
			contener_video.useHandCursor = false;
		}else{
			contener_video.useHandCursor = true;
		}				
		//show nav
		if(showNavigation){
			nav_video._visible = true;
		}else{
			nav_video._visible = false;
		}
		//Adjust navigation position ( bottom left)
		nav_video._x = 0;
		nav_video._y = height ;
		//sound
		if(mute){
			//hide mute btn
			nav_video.mute_btn._visible=false;
			nav_video.unmute_btn._visible=true;
		}else{
			//hide unmute btn
			nav_video.mute_btn._visible = true;
			nav_video.unmute_btn._visible = false;
		}
		//nav
		if(isPlaying_bool){
			nav_video.play_btn._visible = false;
			nav_video.pause_btn._visible = true;
		}else{
			nav_video.play_btn._visible = true;
			nav_video.pause_btn._visible = false;
		}
		
		
	}
	
	
	
	/**
	 * context menu 
	 */
	 
	//changeScale
	function changeScale(scaleValue:Number){
		this.scale = scaleValue;
	}

	
	/** anim intro **/
	var doFadeInContainerDelegated:Function;
	function playAnim()
	{
		_alpha = 0;
		doFadeInContainerDelegated = Utils.createDelegate(this, doFadeInContainer);
		silexInstance.sequencer.addEventListener("onEnterFrame", doFadeInContainerDelegated);
	}
	public function doFadeInContainer()
	{
		_alpha += fadeInStep;
		if (_alpha >= 100)
		{
			silexInstance.sequencer.removeEventListener("onEnterFrame", doFadeInContainerDelegated);
		}
	}
	
	
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set width( intValue:Number):Void{		
		//assign
		contener_video.screen_video._width = intValue;
		__width = intValue;		
		//refresh
		redraw()
	}
	
	function get width ():Number{
		return __width;
	}
	
	
	
	/**
	 * function set/get height
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set height( intValue:Number):Void{
		
		contener_video.screen_video._height = intValue;		
		__height= intValue;
		//refresh
		redraw()
	}
	
	function get height ():Number{
		return __height;
	}
	

	/**
	 * set/get scale
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set scale( numValue:Number):Void{
		this.contener_video.screen_video._xscale = numValue;
		this.contener_video.screen_video._yscale = numValue;
		width  = contener_video.screen_video._width 
		height = contener_video.screen_video._height
	}
	
	function get scale():Number{
		return Math.round( this.contener_video.screen_video._xscale + this.contener_video.screen_video._yscale)/2;		
	}
	
	
	/**
	 * set/get volume 
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set volume(vol_int:Number):Void{
		//stock voulme
		this._volume = vol_int;
		//change volume
		_sound.setVolume(this._volume);
	}
	
	function get volume():Number{
		//stock voulme
		return this._volume ;
	}
	
	
	
	
	
	/**
	 * set/get autoPlay 
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set autoPlay(auto_bool:Boolean):Void{
		//stock voulme
		this._autoPlay_bool = auto_bool;
	}
	
	function get autoPlay():Boolean{
		//stock voulme
		return this._autoPlay_bool ;
	}
	
	/**
	 * set/get autoSize
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set autoSize(auto_bool:Boolean):Void{
		//stock voulme
		this.autoSize_bool = auto_bool;
		//if autosize, rewind video to recheck metadata infos
		if(this.autoSize_bool){
			//replay
			stopMedia();
			isPlayInit_bool = false;
		}
	}
	
	function get autoSize():Boolean{
		//stock voulme
		return this.autoSize_bool ;
	}
	
	
	/**
	 * set/get loop
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set loop(auto_bool:Boolean):Void{
		//stock voulme
		this._loop_bool = auto_bool;
	}
	
	function get loop():Boolean{
		//stock voulme
		return this._loop_bool ;
	}
	
	
	/**
	 * set/get showNavigation
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set showNavigation(auto_bool:Boolean):Void{
		//stock voulme
		this._showNav_bool = auto_bool;
		//show nav_video
		redraw();
	}
	
	function get showNavigation():Boolean{
		//stock voulme
		return this._showNav_bool ;
	}
	
	/**
	 * set/get bufferSize
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set bufferSize(buffer:Number):Void{
		//stock voulme
		this._bufferSize = buffer;
		_ns.setBufferTime(this._bufferSize);
	}
	
	function get bufferSize():Number{
		//stock voulme
		return this._bufferSize ;
	}
	
	
	/**
	 * set/get mute
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set mute(mute_bool:Boolean):Void{
		if(mute_bool){
			muteMedia();
		}else{
			unmuteMedia();
		}
		redraw();
	}
	
	function get mute():Boolean{
		//stock voulme
		return this.isMuted_bool;
	}
	
	
	/**
	 * muteMedia 
	 * @return  void
	 */
	function muteMedia():Void{
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
	function unmuteMedia():Void{
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
	function setMediaVolume(vol:Number):Void{
		_sound.setVolume(vol);
	}
	
	
	/**
	 * function set/get useHandcursor
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set useHandcursor( value_bool:Boolean):Void{
		this.contener_video.screen_video.useHandCursor = value_bool;
	}
	
	function get useHandcursor ():Boolean{
		return this.contener_video.screen_video.useHandCursor;
	}
	
			
	/**
	 * set/get _focusrect
	 * @param 	Boolean		focusrect player
	 * @return  void|Boolean
	 */ 
	public function set _focusrect(value_bool:Boolean):Void {
		this.contener_video._focusrect = value_bool;			
	}
	
	public function get _focusrect():Boolean {
		return this.contener_video._focusrect;		
	}
	
	/**
	 * set/get tabEnabled
	 * @param 	Boolean		tabEnabled player
	 * @return  void|Boolean
	 */ 
	public function set tabEnabled(value_bool:Boolean):Void {
		this.contener_video.tabEnabled = value_bool;			
	}
	
	public function get tabEnabled():Boolean {
		return this.contener_video.tabEnabled;		
	}

	
	/**
	 * set/get tabChildren
	 * @param 	Boolean		tabChildren player
	 * @return  void|Boolean
	 */ 
	public function set tabChildren(value_bool:Boolean):Void {
		this.contener_video.tabChildren = value_bool;			
	}
	
	public function get tabChildren():Boolean {
		return this.contener_video.tabChildren;		
	}
	
	/**
	 * set/get tabIndex
	 * @param 	Number		tabIndex player
	 * @return  void|Number
	 */ 
	public function set tabIndex(numValue:Number):Void {
		this.contener_video.tabIndex = numValue;			
	}
	
	public function get tabIndex():Number {
		return this.contener_video.tabIndex;		
	}
	
	
	/**
	 * set/get currentTimePlayer
	 * @param 	String		currentTimePlayer player
	 * @return  void|String
	 */ 
	public function set currentTimePlayer(value_str:String):Void {
		_currentTimePlayer_str = value_str;			
		redraw();
	}
	
	public function get currentTimePlayer():String {
		return _currentTimePlayer_str;		
	}
	
	/**
	 * set/get totalTimePlayer
	 * @param 	String		totalTimePlayer player
	 * @return  void|String
	 */ 
	public function set totalTimePlayer(value_str:String):Void {
		_totalTimePlayer_str = value_str;			
		redraw();
	}
	
	public function get totalTimePlayer():String {
		return _totalTimePlayer_str;		
	}
	
	
	
	/**
	 * set/get url 
	 * @param 	String		
	 * @return  void|Number
	 */	
	function get url():String{
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
		privateUrl_str=filteredObj.url;
		doLoadMedia(privateUrl_str);

	}
	
	
	/**
	 * play media
	 */
	function playMedia():Void{		
		//not yet initialized
		if (!isPlayInit_bool ) {
			
			// build url
			var url_str:String;
			if (privateUrl_str.indexOf("http")==0 || privateUrl_str.indexOf("file")==0)
				url_str = privateUrl_str
			else
				url_str = silexInstance.rootUrl + privateUrl_str;

			//play url
			_ns.play( url_str );			
			isPlaying_bool = true;
		}else{
			//fct pauseMedia
			pauseMedia();						
		}
		
		redraw();
	}
	
	/**
	 * pause media
	 */
	function pauseMedia():Void{
		//if pause
		if(isPlaying_bool){
			_ns.pause(true);
			isPlaying_bool = false;
		}else{
			_ns.pause(false);
			isPlaying_bool = true;
		}
		//redraw
		redraw();
	}
	
	/**
	 * stop media
	 */
	function stopMedia():Void{
		//retour debut
		_ns.pause(true);
		_ns.seek(0);
		isPlaying_bool = false;
		//redraw
		redraw();
	}
	
	
	/**
	  * wrappers methods
	  */
	 function PLAY(){
		playMedia(); 
	 }
	 
	 function PAUSE(){
		pauseMedia(); 
	 }
	 
	 function STOP(){
		stopMedia(); 
	 }
	 
	 function MUTE(){
		muteMedia(); 
	 }
	 
	 function UNMUTE(){
		unmuteMedia(); 
	 }
	
	
	/**
	 * _onstatus (NetStream)
	 *
	 */
	function _onStatus(infoObject:Object){

		
		// Stream states
		if (infoObject.code=="NetStream.Buffer.Full")		{
			//buffer full
			this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_BUFFER_FULL });
			//ready to play
			//autoplay
			if(!autoPlay && !this.isPlayInit_bool){
				pauseMedia();
			}	
			if(!this.isPlayInit_bool ){
				this.isPlayInit_bool = true;				
			}
			
		}
		
		
		if (infoObject.code=="NetStream.Play.Stop")
		{
			// if playhead is less than 2 sec before the approx duration, it is the end of the media
			if (_ns.time>streamDuration-2)
			{
				//stop
				stopMedia();
				//loop
				if(loop){					
					playMedia();
				}
				this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_END });
			}
			else
			{
				this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_STOP });
				//stop
				stopMedia();
			}
		}
		
		if (infoObject.code=="NetStream.Buffer.Empty")
		{
			// if playhead is less than 2 sec before the approx duration, it is the end of the media
			if (_ns.time>streamDuration-2)
			{
				// It is the end of the media => EVENT_END has been dispatched when NetStream.Play.Stop is thrown
				// ?! dispatchEvent({target:this,type:EVENT_END});
			}
			else
			{
				this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_BUFFER_EMPTY });
			}
		}
		
		
		if (infoObject.code=="NetStream.Play.StreamNotFound")
		{
			this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_NOSTREAM });
		}
	}
	
	
	
	
	/**
	 *_onMetadata (NetStream)
	 *
	 */
	function _onMetaData(infoObject:Object):Void{
		//dispatch onStatus
		this.dispatch({target:this,type: silexInstance.config.UI_PLAYERS_EVENT_STATUS });
		//get info duration
		streamDuration= Math.round(infoObject.duration);
		//timetotal
		total_time = streamDuration;
		//time
		time_interval = setInterval(this,"displayTime", 800);	
		
		
		
		//Size media
		if (autoSize_bool)
		{
			__width  =	infoObject.width;
			__height =	infoObject.height;	
		}	
		else{
			if (!__width) {
				__width=		infoObject.width;
			}
			if (!__height){
				__height=	infoObject.height;				
			}
		}
		//assign dimensions
		width =__width;
		height =__height;

		//
		
		this._streamReceived = true;
		//visible true
		//_visible=true;
		//redraw
		redraw();
	}
	
	
	//displaytime insterval
	function displayTime(){
		if(_ns.time != undefined){
			current_time = Math.round( _ns.time);
		}else{
			current_time = 0;
		}	
	
		//refreshTime();
	}
	
	function refreshTime(){
		
		//players
		playerCurrent_obj = silexInstance.application.getPlayerByName(currentTimePlayer);
		playerTotal_obj = silexInstance.application.getPlayerByName(totalTimePlayer);
		playerCurrent_obj.htmlText = current_time;
		playerTotal_obj.htmlText = total_time;
	}
	

	
	
	
	/**
	 * function _onPress
	 * @param 	string	media url 
	 * @return 	void
	 */
	public function loadMedia(url_str:String):Void{
		//stock url
		this.url = url_str; // => setter will call doLoadMedia
	}
	
	//change media, replay new media url
	function doLoadMedia() {
		//play video
		//if(_autoPlay_bool){
			//playmedia if autoplay
			this._streamReceived = false;
			this.isPlayInit_bool = false;
			playMedia();
		//}
	}

	
	/**
	 * function unloadMedia
	 * @return 	void
	 */
	public function unloadMedia():Void {
		super.unloadMedia();
		clearInterval(time_interval);
		_ns.close();
	}
	
	
	
	// **
	// override PlayerBase class :
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:contener_video.screen_video._x,y:contener_video.screen_video._y};
	
		// to global
		contener_video.localToGlobal(coordTL);
		
		return coordTL;
	}
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:contener_video.screen_video._width+contener_video.screen_video._x,y:contener_video.screen_video._height+contener_video.screen_video._y};
	
		// to global
		contener_video.localToGlobal(coordBR);

		return coordBR;
	}
	// **
	// override PlayerBase class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object){
		// back to local
		this.layerInstance.globalToLocal(coord);
		// apply the new coordinates to the player
		_x = coord.x;
		_y = coord.y;
	}
	function setGlobalCoordBR(coord:Object){
		// back to local
		contener_video.globalToLocal(coord);
		// apply the new coordinates to the player
		width = coord.x ;
		height= coord.y;
	}
	
	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	 function getSeoData(url_str:String):Object {
		var res_obj:Object=super.getSeoData();
		
		// keywords
		//res_obj.text="";

		// html equivalent
		if (descriptionText)
			res_obj.htmlEquivalent="<a href='"+url_str+privateUrl_str+"'>"+descriptionText+"</a>";
		else
			res_obj.htmlEquivalent="<a href='"+url_str+privateUrl_str+"'>"+url_str+privateUrl_str+"</a>";
		
		return res_obj;
	}
	/*	//override PlayerBase method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object=new Object;
		res_obj.keywords = descriptionText;
		res_obj.description = descriptionText;
		res_obj.context = getUiContext();
		//html 
		var htmlContent = '<img';
		if (descriptionText)
			htmlContent += ' alt="' + descriptionText +'"';
		//htmlContent += ' longdesc="'    + descriptionText + '"';
		htmlContent += ' name="' 	   + playerName + '"';
		htmlContent += ' src="' 	   + url_str + silexInstance.config.initialFtpFolderPath+silexInstance.config.websiteFtpRelativeUrl+this.privateUrl_str	+ '"';
		htmlContent += '>';		
		//assign
		res_obj.htmlEquivalent = htmlContent;
		return res_obj;
	}
*/}