/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.ui.UiBase;
import org.silex.core.Utils;
import mx.controls.List;


[Event("listChange")]
[Event("listItemRollOut")]
[Event("listItemRollOver")]
[Event("listScroll")]
[Event("listDraw")]
[Event("listHide")]
[Event("listLoad")]
[Event("listMove")]
[Event("listResize")]
[Event("listReveal")]
[Event("listUnload")]

class org.silex.ui.components.ComponentPlaylist extends org.silex.ui.UiBase {
	
	//dimensions
	var __width:Number;
	var __height:Number;
	var contener_mc:MovieClip;
	
	//ui
	var playlist_lst;
	var playlist_nav:MovieClip;
	//extensions authorized
	var validExtension_array:Array;
	//infos
	var _libraryPath_str:String;
	var _captionTextField_str:String;
	var _showPlaylist_bool:Boolean;
	var _playlistX_int:Number;
	var _playlistY_int:Number;
	//
	var _autoPlay_bool:Boolean;
	var isPlaying_bool:Boolean;
	var isPlayInit_bool:Boolean;
	var _loop_bool:Boolean;
	var _showNav_bool:Boolean;
	//url
	var privateUrl_str:String = null;
	//listener
	var listListener_obj:Object;
	//stock infos
	var _filesDesc_array:Array;
	var _filesList_array:Array;
	var _currentPlay_num:Number;
	//accessor
	var selectedIndex:Number;
	var selectedItem:Object;

	
	function ComponentPlaylist() {
		validExtension_array  = new Array();
		//create contener global		
		this.createEmptyMovieClip("contener_mc",this.getNextHighestDepth());
		//nav
		playlist_nav = this.attachMovie("playlist_nav", "playlist_nav", this.getNextHighestDepth());
	}
	
	
	function _initialize() {
		//parent
		super._initialize();		

		//availableEvents
		this.availableEvents.push(
			{modifier:"listChange", 		description : "listChange"},
			{modifier:"listItemRollOut",	description : "listItemRollOut"},
			{modifier:"listItemRollOver", 	description : "listItemRollOver"},			
		    {modifier:"listScroll", 		description : "listScroll"},
			{modifier:"listDraw", 			description : "listDraw"},
			{modifier:"listHide", 			description : "listHide"},
			{modifier:"listLoad", 			description : "listLoad"},
			{modifier:"listMove", 			description : "listMove"},
			{modifier:"listResize", 		description : "listResize"},
			{modifier:"listReveal", 		description : "listReveal"},
			{modifier:"listUnload", 		description : "listUnload"}
        );
		//availableMethods
		this.availableMethods.push(
			{modifier:"PLAY", 		description : silexInstance.config.METHODS_LABEL_PLAY	, parameters: new Array()},
			{modifier:"PAUSE",		description : silexInstance.config.METHODS_LABEL_PAUSE	, parameters: new Array()},
			{modifier:"STOP", 		description : silexInstance.config.METHODS_LABEL_STOP	, parameters: new Array()},
			{modifier:"NEXT", 		description : silexInstance.config.METHODS_LABEL_NEXT		, parameters:new Array()},
			{modifier:"PREVIOUS",	description : silexInstance.config.METHODS_LABEL_PREVIOUS	, parameters:new Array()}
        );		
		//editableProperties first position
		this.editableProperties.unshift(
				{name:"width", 				description:silexInstance.config.PROPERTIES_LABEL_WIDTH, 		type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:"", isRegistered:true, minValue:-5000, maxValue:5000, group:"attributes"},
				{name:"height",				description:silexInstance.config.PROPERTIES_LABEL_HEIGHT, 		type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:"", isRegistered:true, minValue:-5000, maxValue:5000, group:"attributes"},
				{name:"autoPlay", 			description:silexInstance.config.PROPERTIES_LABEL_AUTOPLAY, 		type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"parameters"},
				//{name:"loop", 				description:"auto replay ", 	type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"parameters"},
				{name:"showNavigation", 	description:silexInstance.config.PROPERTIES_LABEL_SHOW_UI,  type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:true, isRegistered:true, group:"parameters"},
				{name:"useHandCursor", description:silexInstance.config.PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER, type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:false, isRegistered:true, group:"attributes"}
		);
		//add infos
		this.editableProperties.unshift(
				{name:"libraryPath", description:silexInstance.config.PROPERTIES_LABEL_SOURCE_FOLDER, type:silexInstance.config.PROPERTIES_TYPE_URL, defaultValue:"", isRegistered:true, group:"parameters"},
				{name:"filesDesc", description:silexInstance.config.PROPERTIES_LABEL_DESCRIPTIONS, type:silexInstance.config.PROPERTIES_TYPE_ARRAY, defaultValue:"", isRegistered:true, group:"parameters"},
				{name:"captionTextField", description:silexInstance.config.PROPERTIES_LABEL_TEXT_PLAYER_NAME, type:silexInstance.config.PROPERTIES_TYPE_TEXT, defaultValue:"", isRegistered:true, group:"parameters"},
				{name:"showPlaylist", description:silexInstance.config.PROPERTIES_LABEL_SHOW_LIST, type:silexInstance.config.PROPERTIES_TYPE_BOOLEAN, defaultValue:"true", isRegistered:true, group:"parameters"},
				{name:"playlistX", description:silexInstance.config.PROPERTIES_LABEL_X_POSITION, type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:100, isRegistered:true, group:"parameters"},
				{name:"playlistY", description:silexInstance.config.PROPERTIES_LABEL_Y_POSITION, type:silexInstance.config.PROPERTIES_TYPE_NUMBER, defaultValue:100, isRegistered:true, group:"parameters"}
		);

		
		contener_mc.onRollOver = Utils.createDelegate(this, _onRollOver);
		contener_mc.onRollOut = Utils.createDelegate(this, _onRollOut);
		contener_mc.onRelease = Utils.createDelegate(this, _onRelease);
		contener_mc.onPress = Utils.createDelegate(this, _onPress);

		// UI init
		playlist_nav.mute_btn._visible = false;
		playlist_nav.unmute_btn._visible = false;
		//event
		playlist_nav.play_btn.onRelease = Utils.createDelegate(this, playMedia);
		playlist_nav.pause_btn.onRelease = Utils.createDelegate(this, pauseMedia);
		playlist_nav.stop_btn.onRelease = Utils.createDelegate(this, stopMedia);
		playlist_nav.prev_btn.onRelease = Utils.createDelegate(this, prevMedia);
		playlist_nav.next_btn.onRelease = Utils.createDelegate(this, nextMedia);
		
		//listener
		listListener_obj = new Object();
		listListener_obj.change = 		Utils.createDelegate(this, _listChange);
		listListener_obj.itemRollOut = 	Utils.createDelegate(this, _listItemRollOut);
		listListener_obj.itemRollOver = Utils.createDelegate(this, _listItemRollOver);
		listListener_obj.scroll = 		Utils.createDelegate(this, _listScroll);
		listListener_obj.draw = 		Utils.createDelegate(this, _listDraw);
		listListener_obj.hide = 		Utils.createDelegate(this, _listHide);
		listListener_obj.load = 		Utils.createDelegate(this, _listLoad);
		listListener_obj.move =			Utils.createDelegate(this, _listMove);
		listListener_obj.resize = 		Utils.createDelegate(this, _listResize);
		listListener_obj.reveal = 		Utils.createDelegate(this, _listReveal);
		listListener_obj.unload = 		Utils.createDelegate(this, _listUnload);
		//add listener
		playlist_lst.addEventListener("change",listListener_obj);		
		playlist_lst.addEventListener("itemRollOut",listListener_obj);	
		playlist_lst.addEventListener("itemRollOver",listListener_obj);	
		playlist_lst.addEventListener("scroll",listListener_obj);	
		playlist_lst.addEventListener("draw",listListener_obj);	
		playlist_lst.addEventListener("hide",listListener_obj);	
		playlist_lst.addEventListener("load",listListener_obj);	
		playlist_lst.addEventListener("move",listListener_obj);	
		playlist_lst.addEventListener("resize",listListener_obj);	
		playlist_lst.addEventListener("reveal",listListener_obj);	
		playlist_lst.addEventListener("unload",listListener_obj);	
		//init bool
		isPlaying_bool = false;
		isPlayInit_bool = false;
		//first selected
		_currentPlay_num = 0;	
		//accessor
		selectedIndex = _currentPlay_num;
		//redraw
		redraw();
	}

	/** redraw **/
	function redraw() {
		
		//playlist
		playlist_lst.move(playlistX, playlistY);
		//usehandcursor
		if (!useHandCursor) {
			contener_mc.useHandCursor = false;
		} else {
			contener_mc.useHandCursor = true;
		}
		//show nav
		if (showNavigation) {
			playlist_nav._visible = true;
		} else {
			playlist_nav._visible = false;
		}
		
		//nav
		if (isPlaying_bool) {
			playlist_nav.play_btn._visible = false;
			playlist_nav.pause_btn._visible = true;
		} else {
			playlist_nav.play_btn._visible = true;
			playlist_nav.pause_btn._visible = false;
		}
		//playlist
		if(showPlaylist){
			playlist_lst.visible = true;
		}else{
			playlist_lst.visible = false;
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
		contener_mc._width = intValue;
		__width = intValue;
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
		contener_mc._height = intValue;
		__height = intValue;
		//refresh
		redraw();
	}
	function get height():Number {
		return __height;
	}
	
	
	/**
	 * set/get autoPlay 
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set autoPlay(auto_bool:Boolean):Void {
		//stock voulme
		this._autoPlay_bool = auto_bool;
	}
	function get autoPlay():Boolean {
		//stock voulme
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
	 * set/get url 
	 * @param String
	 * @return  void|Number
	 */
	function get url():String {
		return privateUrl_str;
	}
	
	function set url(url_str:String):Void {
		//reinitialize 
		privateUrl_str = url_str;
		doLoadMedia(privateUrl_str);
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
	 * set/get libraryPath 
	 * @param String
	 * @return  void|Number
	 */
	function set libraryPath(url_str:String):Void {
		// '/' at the end
		if (url_str.charAt(url_str.length-1) != '/') {
			url_str += '/';
		}
		//reinitialize  
		_libraryPath_str = url_str;
		//listFiles
		listFiles();
	}
	function get libraryPath():String {
		return _libraryPath_str;
	}
	
	
	/**
	 * function set/get filesDesc
	 * @param Array
	 * @return  void|Array
	 */
	function set filesDesc(value_ar:Array):Void {
		//assign
		_filesDesc_array = value_ar;
		//listFiles
		listFiles();
	}	
	function get filesDesc():Array {
		return _filesDesc_array;
	}
	
	/**
	 * function set/get captionTextField
	 * @param String
	 * @return  void|String
	 */
	function set captionTextField(intValue:String):Void {
		//assign
		_captionTextField_str = intValue;
		//refresh
		redraw();
	}	
	function get captionTextField():String {
		return _captionTextField_str;
	}
	
	
	/**
	 * function set/get showPlaylist
	 * @param Boolean
	 * @return  void|Boolean
	 */
	function set showPlaylist(val_bool:Boolean):Void {
		//assign
		_showPlaylist_bool = val_bool;
		//refresh
		redraw();
	}	
	function get showPlaylist():Boolean {
		return _showPlaylist_bool;
	}
	
	/**
	 * function set/get playlistX
	 * @param Number
	 * @return  void|Number
	 */
	function set playlistX(val_int:Number):Void {
		//assign
		_playlistX_int = val_int;
		//refresh
		redraw();
	}	
	function get playlistX():Number {
		return _playlistX_int;
	}
	
	
	/**
	 * function set/get playlistY
	 * @param Number
	 * @return  void|Number
	 */
	function set playlistY(val_int:Number):Void {
		//assign
		_playlistY_int = val_int;
		//refresh
		redraw();
	}	
	function get playlistY():Number {
		return _playlistY_int;
	}
	
	
	
	/**list files **/
	function listFiles() {
		//audio desc
		getFilesDesc();
		//libraryPAth
		var urlPathImg:String = silexInstance.config.websiteFtpRelativeUrl+libraryPath;
		//var urlPathImg:String = libraryPath;
		//llist folder
		silexInstance.com.listFtpFolderContent(urlPathImg,Utils.createDelegate(this, handleListFiles));
	}
	
	/**
	  * handlelistfiles
	  */
	function handleListFiles(filesArray:Array) {
		_filesList_array = new Array();
		//boucle
		var l:Number = filesArray.length;
		//boucle
		for (var i = 2; i<l; i++) {
			var k:String = filesArray[i]['item name'];
			var extension = getExtension(k);
			//windows file
			if ( k != 'Thumbs.db' && in_array(extension, validExtension_array) ) {
				var obj:Object;
				if (_filesDesc_array[k] != undefined ) {
					obj = {label:_filesDesc_array[k], data:k};
				} else {
					obj = {label:k, data:k};
				}
				playlist_lst.addItem(obj);
				//Stock tous les fichiers
				_filesList_array.push(k);
			}
		}		
		//all infos stocked
		initList()
	}
	
	
	/** in_array function **/
	function in_array(element:String, table_array:Array){
		//length
		var l:Number = table_array.length;
		//boucle
		for(var i:Number = 0; i < l; i++){
			if(table_array[i] == element){
				return true;
			}
		}
		//not found
		return false;
	}
	
	/**
	 * Get file extension
	 * @param 	sring		   	file url
	 * @return 	string 			return extension
	 */
	private function getExtension( url:String ):String{
		//return extension form last '.'
		var ext:String =  url.substr( url.lastIndexOf(".")+1, url.length);	
		return ext.toLowerCase();
	}
	
	
	/** init after getting all infos **/
	function initList(){
		//all infos loaded
		if (autoPlay) {
			playMedia();
		}
		playlist_lst.selectedIndex = _currentPlay_num;
		//accessor object
		selectedItem = playlist_lst.getItemAt(_currentPlay_num);
	}
	
	
	//img desc
	function getFilesDesc() {
		//length
		var l:Number = _filesDesc_array.length;
		//infos desc
		for (var i = 0; i<l; i++) {
			var ligne:String = _filesDesc_array[i];
			var file:String = ligne.substr(0, ligne.lastIndexOf(":"));
			var desc:String = ligne.substr(ligne.lastIndexOf(":")+1, ligne.length);
			//desc
			if (desc == undefined) {
				desc = "";
			}
			//register 
			_filesDesc_array[file] = desc;
		}
	}
	
	
	/** show song **/
	function refreshText() {
		//playertext
		var playerText:Object = silexInstance.application.getPlayerByName(captionTextField);
		var label_str:String = playlist_lst.getItemAt(_currentPlay_num).label;
		var file_str:String = playlist_lst.getItemAt(_currentPlay_num).data;
		if (label_str != file_str) {
			playerText.htmlText = label_str+' ( '+file_str+' )';
		} else {
			playerText.htmlText = label_str;
		}
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
	
	function NEXT(){
		nextMedia();
	}
	 
	function PREVIOUS(){
		prevMedia();
	}
	
	
	/** actions media **/
	function playMedia(){
		//refresh textplayer
		refreshText();
	}
	
	/** pause media **/
	function pauseMedia(){
	}
	
	/** stopMEdia **/
	function stopMedia(){
	}
	
	
	/** previous media **/
	function prevMedia() {
		if (_currentPlay_num<=0) {
			_currentPlay_num = (_filesList_array.length-1);
		} else {
			_currentPlay_num -= 1;
		}
		
		//force load new sound
		isPlayInit_bool = false;
		//list refresh
		playlist_lst.selectedIndex = _currentPlay_num;
		//accessors
		selectedItem = playlist_lst.getItemAt(_currentPlay_num);
		selectedIndex = _currentPlay_num;	
		//redraw
		redraw();
		//play
		playMedia();

	}
	
	/** next media */
	function nextMedia() {
		//indice
		if (_currentPlay_num >= (_filesList_array.length-1)) {
			_currentPlay_num = 0;
			//loop end playlist
			/*if (!loop ) {
				stopMedia();
				return;
			}*/
		} else {
			_currentPlay_num += 1;
		}
		
		//force load new sound
		isPlayInit_bool = false;
		//list refresh
		playlist_lst.selectedIndex = _currentPlay_num;
		//accessors
		selectedItem = playlist_lst.getItemAt(_currentPlay_num);
		selectedIndex = _currentPlay_num;
		//redraw
		redraw();
		//play
		playMedia();

	}
	
	
	/**
	 * events
	 **/	 
	
	/**
	 * function _onRelease
	 * @return void
	 */
	function _onRelease():Void {
		//dispatch
		this.dispatch({type:silexInstance.config.UI_PLAYERS_EVENT_RELEASE, target:this});
	}
	
	/**
	 * function _onPress
	 * @return void
	 */
	function _onPress():Void {
		//dispatch
		this.dispatch({type:silexInstance.config.UI_PLAYERS_EVENT_PRESS, target:this});
	}
	
	/**
	 * function _onRollOver
	 * @return void
	 */
	function _onRollOver():Void {
		//dispatch 
		this.dispatch({type:silexInstance.config.UI_PLAYERS_EVENT_ROLLOVER, target:this});
	}
	
	/**
	 * function _onRollOut
	 * @return void
	 */
	function _onRollOut():Void {
		//dispatch 
		this.dispatch({type:silexInstance.config.UI_PLAYERS_EVENT_ROLLOUT, target:this});
	}
	
	
	
	/** events list component **/

	function _listChange(evt_obj:Object) {
		//list
		this.dispatch({type:"listChange", target:this});
		//current indice
		_currentPlay_num = evt_obj.target.selectedIndex;
		if(_currentPlay_num == undefined){
			_currentPlay_num = 0;
		}
		//accessors
		selectedItem = playlist_lst.getItemAt(_currentPlay_num);
		selectedIndex = _currentPlay_num;
		//force load new sound
		isPlayInit_bool = false;
		//play
		playMedia();
	}
	
	function _listItemRollOut(){	
		this.dispatch({type:"listItemRollOut", target:this});
	}
	
	function _listItemRollOver(){
		this.dispatch({type:"listItemRollOver", target:this});
	}
	
	function _listScroll(){
		this.dispatch({type:"listScroll", target:this});
	}
	
	function _listDraw(){
		this.dispatch({type:"listDraw", target:this});
	}
	
	function _listHide(){
		this.dispatch({type:"listHide", target:this});
	}
	
	function _listLoad(){
		this.dispatch({type:"listLoad", target:this});
	}
	
	function _listMove(){
		this.dispatch({type:"listMove", target:this});
	}
	
	function _listResize(){
		this.dispatch({type:"listResize", target:this});
	}
	
	function _listReveal(){
		this.dispatch({type:"listReveal", target:this});
	}
	
	function _listUnload(){
		this.dispatch({type:"listUnload", target:this});
	}
	
	
	/*** 
	  * loadMedia none in playlist 
	  **/
	public function loadMedia(url_str:String):Void {
		//stock url
		this.url = url_str;// => setter will call doLoadMedia
	}	
	/** none in playlist **/
	function doLoadMedia() {
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
		this._parent.localToGlobal(coordTL);

		return coordTL;
	}
	
	function getGlobalCoordBR() {
		// from global coords
		var coordBR:Object = {x:width+_x, y:height+_y};

		// to global
		this._parent.localToGlobal(coordBR);

		return coordBR;
	}
	//override PlayerBase method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object = new Object();
		res_obj.keywords = descriptionText;
		res_obj.description = descriptionText;
		//html 
		if (descriptionText){
			var htmlContent = '<div>';
			htmlContent += descriptionText;
			htmlContent += '<div>';
			//assign
			res_obj.htmlEquivalent = htmlContent;
		}
		return res_obj;
	}
}