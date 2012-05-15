/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * Name : Image.as
 * Package : ui.players
 * Version : 0.8
 * Date :  2007-08-03
 */
	 

import org.silex.ui.players.PlayerBase;
import org.silex.core.Utils;
[Event("onLoadStart")]
[Event("onLoadError")]
[Event("onLoadProgress")]
[Event("onLoadComplete")]
[Event("onLoadInit")]
class org.silex.ui.players.Image extends PlayerBase {

	//contener media
   	var contener_mc:MovieClip;
	var contenerVide_mc:MovieClip;
	//frame
	var frame_mc:MovieClip;
	var	_visibleFrame_bool:Boolean=false;
	//shadow
	var shadow_mc:MovieClip;
	//shadow bool
	var _shadow_bool:Boolean=false;
	var _shadowOffsetX_num:Number ;
	var _shadowOffsetY_num:Number ;
	//loader
	var	listenerLoader_obj:Object = null;
	var loaderMedia_mcl:MovieClipLoader = null;
	// __width and __height are used to store width an height while media may not be loaded yet
	var __width:Number;
	var __height:Number;
	//mask
	var mask_mc:String;
	//scalemode
	var scaleMode_str:String;
	/**
	 * step by which is incremented the alpha when we show the image
	 */
	var fadeInStep:Number;
	
	/* clickable
	 * if not clickable, onRelease, onRollOver... are not used
	 * workaround the fact that some swf may be over other and should not disturb roll over etc
	 */
	var _clickable:Boolean;
	function get clickable():Boolean{
		return _clickable; 
	}
	function set clickable(val:Boolean){
		if (val==true){
			//events buttons
			contener_mc.onRelease 	= Utils.createDelegate(this, _onRelease);
			contener_mc.onPress 	= Utils.createDelegate(this, _onPress);
			contener_mc.onRollOver  = Utils.createDelegate(this, _onRollOver);
			contener_mc.onRollOut 	= Utils.createDelegate(this, _onRollOut);
		}
		_clickable=val;
	}
	
	
	function get url():String{
		return privateUrl_str;
	}
	
	function set url(url_str:String){
		privateUrl_str=url_str;
		doLoadMedia();
	}


     /**
	  * constructor
	  * @return void
	  */
    public function Image()
	{
     	super();
     	// inheritance
     	typeArray.push("org.silex.ui.players.Image");
    }
	/**
	 * function initialize
	 * @return void
	 */
	private function _initialize():Void{
		super._initialize();
			
		//create contener global
		this.createEmptyMovieClip("contener_mc", this.getNextHighestDepth());
		contener_mc._alpha=0;
		//create shadow
		//shadow_mc = contener_mc.attachMovie("shadow","shadow_mc", contener_mc.getNextHighestDepth());
		//contener image
		contener_mc.createEmptyMovieClip("contenerVide_mc", contener_mc.getNextHighestDepth());	
		//context menu
		this.availableContextMenuMethods.push(
/*			{ fct :"changeScale", 	description :"100% scale", 			param : 100},
			{ fct :"toggleShadow", 	description :"toggle shadow", 		param : null}*/
		);
		
		//availableEvents
		this.availableEvents.push(
			{modifier:"onLoadStart", 	description : "on Load Start"},
			{modifier:"onLoadError",	description : "on Load Error"},
			{modifier:"onLoadProgress", description : "onLoadProgress"},			
		    {modifier:"onLoadComplete", description : "on Load Complete"},
			{modifier:"onLoadInit", 	description : "on Load Init"}
        );

		//editableProperties
		this.editableProperties.unshift(   
			{ name :"clickable" ,		description:"clickable", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN	, defaultValue: true, isRegistered:true, group:"parameters"	}
		)
		this.editableProperties.push(
			{ name :"scale" , 			description:"PROPERTIES_LABEL_SCALE", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: ""	, isRegistered: false	, minValue:1,  	maxValue:5000, group:"attributes" },
			{ name :"width" ,			description:"PROPERTIES_LABEL_WIDTH", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: "none"	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:"PROPERTIES_LABEL_HEIGHT", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"useHandCursor" , 	description:"PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER", 	type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"attributes" },
			{ name :"mask",				description:"PROPERTIES_LABEL_NAME_OF_MASK",				type: silexInstance.config.PROPERTIES_TYPE_REFERENCE, baseClass:"org.silex.ui.UiBase", defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"scaleMode",		description:"PROPERTIES_LABEL_SCALE_MODE",				type: silexInstance.config.PROPERTIES_TYPE_URL		, defaultValue: "none", isRegistered: true, group:"parameters"	},
			{ name :"visibleFrame_bool",			description:"PROPERTIES_LABEL_SHOW_LOADING",				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false, isRegistered: true, group:"parameters"	},
			{ name :"shadow" , 			description:"PROPERTIES_LABEL_SHOW_SHADOW", 					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false, isRegistered: true, group:"parameters"	},
			{ name :"shadowOffsetX" , 	description:"PROPERTIES_LABEL_SHADOW_X_POSITION", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: 10	, isRegistered: true	, minValue:-50,  	maxValue:50, group:"parameters" },
			{ name :"shadowOffsetY" , 	description:"PROPERTIES_LABEL_SHADOW_Y_POSITION", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: 10	, isRegistered: true	, minValue:-50,  	maxValue:50, group:"parameters" },	
			{ name :"_focusrect" , 		description:"PROPERTIES_LABEL_SHOW_FOCUS", 		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"tabChildren" , 	description:"PROPERTIES_LABEL_ENABLE_CHILDREN_TABULATION",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"fadeInStep" , 	description:"PROPERTIES_LABEL_FADE_IN_STEP", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: 100	, isRegistered: true	, minValue:.1,  	maxValue:100, group:"parameters" });
				
		//movieClip Loader
		this.loaderMedia_mcl = new MovieClipLoader();
		this.listenerLoader_obj = new Object();
		//listener events		
		this.listenerLoader_obj.onLoadStart		= Utils.createDelegate(this, _onLoadStart);
		this.listenerLoader_obj.onLoadProgress 	= Utils.createDelegate(this, _onLoadProgress);
		this.listenerLoader_obj.onLoadComplete 	= Utils.createDelegate(this, _onLoadComplete);
		this.listenerLoader_obj.onLoadInit		= Utils.createDelegate(this, _onLoadInit);
		this.listenerLoader_obj.onLoadError 	= Utils.createDelegate(this, _onLoadError);		
		//add Listener
		this.loaderMedia_mcl.addListener(this.listenerLoader_obj);			
		
	}

	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		//usehandcursor
		if(!this.useHandCursor){
			contener_mc.useHandCursor = false;
		}else{
			contener_mc.useHandCursor = true;
		}					
		//shadow position
		if(shadow){
			shadow_mc._width =  width;
			shadow_mc._height = height;
			shadow_mc._x = contener_mc.contenerVide_mc._x +  (shadowOffsetX); 
			shadow_mc._y = contener_mc.contenerVide_mc._y + (shadowOffsetY);					
		}
		//shadow
/*		if(shadow){
			shadow_mc._visible = true;
		}else{
			shadow_mc._visible = false;
		}*/
		//frame
		if (visibleFrame_bool==true){
			//frame_mc._width = width;
			//frame_mc._height = height;
			//adjust position
			frame_mc._x = contener_mc.contenerVide_mc._x + (width/2);
			frame_mc._y = contener_mc.contenerVide_mc._y + (height/2);
			//
			/*if(frame){
				frame_mc._visible = true;
			}else{
				frame_mc._visible = false;
			}*/
		}
	}
	
	
	
	/**
	 * context menu 
	 */
	 
	//changeScale
	function changeScale(scaleValue:Number){
		this.scale = scaleValue;
	}
	
	// change z-order
	function toggleShadow(){
		if( ! this.shadow){
			this.shadow = true;
		}else{
			this.shadow = false;
		}
	}
	
	
	/**
	 * set/get rotation
	 * @param 	Number		show/hide
	 * @return  void|Number
	 */ 
	 
	public function set rotation( rotationNumber:Number):Void{
		this.contener_mc._rotation = rotationNumber;
		//refresh
		redraw();
	}
	
	public function get rotation():Number{
		return this.contener_mc._rotation;
	}
	
	
	
	
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set width( intValue:Number):Void{
		
		// if the media is loaded, change its size
		if (contener_mc.contenerVide_mc.getBytesTotal()>0){
			contener_mc.contenerVide_mc._width = intValue;
		}
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
		// if the media is loaded, change its size
		if (contener_mc.contenerVide_mc.getBytesTotal()>0){
			contener_mc.contenerVide_mc._height = intValue;
		}
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
		this.contener_mc.contenerVide_mc._xscale = numValue;
		this.contener_mc.contenerVide_mc._yscale = numValue;
		width = this.contener_mc.contenerVide_mc._width 
		height = this.contener_mc.contenerVide_mc._height
		//refresh
		redraw()
	}
	
	function get scale():Number{
		return Math.round((this.contener_mc.contenerVide_mc._xscale + this.contener_mc.contenerVide_mc._yscale)/2);
	}
	
	/**
	 * set/get shadow
	 * display/hide shadow
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set shadow( value_bool:Boolean):Void{
		if (_shadow_bool != value_bool){
			//asign
			this._shadow_bool = value_bool;
			//show/hide
			if(this._shadow_bool){
				shadow_mc = contener_mc.attachMovie("shadow","shadow_mc", contener_mc.getNextHighestDepth());
				shadow_mc.swapDepths(contener_mc.contenerVide_mc);
				//shadow_mc._visible = true;		
			}else{
				shadow_mc.removeMovieClip();
				//shadow_mc._visible = false;
			}
			//redraw
			redraw();		
		}
	}
	
	function get shadow():Boolean{
		return this._shadow_bool;
	}
	/**
	 * set/get visibleFrame_bool
	 * display/hide loading
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set visibleFrame_bool( value_bool:Boolean):Void{
		if (_visibleFrame_bool != value_bool){
			//asign
			_visibleFrame_bool = value_bool;
			//show/hide
			if (_visibleFrame_bool==true){
				frame_mc = contener_mc.attachMovie("loading","frame_mc", contener_mc.getNextHighestDepth());
			}else{
				frame_mc.removeMovieClip();
			}
			//redraw
			redraw();		
		}
	}
	
	function get visibleFrame_bool():Boolean{
		return _visibleFrame_bool;
	}
	
	
	
	/**
	 * set/get shadowOffsetX
	 * decay shadow x
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set shadowOffsetX( value_num:Number):Void{
		this._shadowOffsetX_num = value_num;		
		//refresh
		redraw()
	}
	
	function get shadowOffsetX():Number{
		return this._shadowOffsetX_num;
	}
	
	
	/**
	 * set/get shadowOffsetY
	 * decay shadow Y
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set shadowOffsetY( value_num:Number):Void{
		this._shadowOffsetY_num = value_num;
		//refresh
		redraw()
	}
	
	function get shadowOffsetY():Number{
		return this._shadowOffsetY_num;
	}
	
	
	
	
	/**
	 * function set/get useHandcursor
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set useHandcursor( value_bool:Boolean):Void{
		contener_mc.contenerVide_mc.useHandCursor = value_bool;
	}
	
	function get useHandcursor ():Boolean{
		return contener_mc.contenerVide_mc.useHandCursor;
	}
	
			
	/**
	 * set/get _focusrect
	 * @param 	Boolean		focusrect player
	 * @return  void|Boolean
	 */ 
	public function set _focusrect(value_bool:Boolean):Void {
		this.contener_mc._focusrect = value_bool;			
	}
	
	public function get _focusrect():Boolean {
		return this.contener_mc._focusrect;		
	}
	
	/**
	 * set/get tabEnabled
	 * @param 	Boolean		tabEnabled player
	 * @return  void|Boolean
	 */ 
	public function set tabEnabled(value_bool:Boolean):Void {
		this.contener_mc.tabEnabled = value_bool;			
	}
	
	public function get tabEnabled():Boolean {
		return this.contener_mc.tabEnabled;		
	}

	
	/**
	 * set/get tabChildren
	 * @param 	Boolean		tabChildren player
	 * @return  void|Boolean
	 */ 
	public function set tabChildren(value_bool:Boolean):Void {
		this.contener_mc.tabChildren = value_bool;			
	}
	
	public function get tabChildren():Boolean {
		return this.contener_mc.tabChildren;		
	}
	
	/**
	 * set/get tabIndex
	 * @param 	Number		tabIndex player
	 * @return  void|Number
	 */ 
	public function set tabIndex(numValue:Number):Void {
		this.contener_mc.tabIndex = numValue;			
	}
	
	public function get tabIndex():Number {
		return this.contener_mc.tabIndex;		
	}
	/**
	 * set/get Mask
	 * @param 	String		player mask
	 * @return  void|String
	 */ 
	public function set mask(mc_name:String):Void {
		if(mc_name != ''){
			//get movieclip
			this.mask_mc = mc_name;			
			applyMask(mc_name);
		}else{
			deleteMask();
		}
	}
	
	public function get mask():String {
		return this.mask_mc;		
	}
	
	
	/** init mask **/
	public function initMask(){
		if(mask_mc != undefined){
			applyMask(mask);
		}else{
			deleteMask();
		}
	}
	
	/** apply mask **/
	public function applyMask(mc_name):Void{
		//get player
		var mask_mc:MovieClip = silexInstance.application.getPlayerByName(mc_name);
		//mask
		contener_mc.setMask(mask_mc);
	}
	
	/** unset mask **/
	public function deleteMask():Void{
		contener_mc.setMask(null);
	}
	
	
	
	/**
	 * set/get scaleMode
	 * @param 	String		scaleMode
	 * @return  void|String
	 */ 
	public function set scaleMode(scale_str:String):Void {
		if(scale_str != ''){
			//get movieclip
			this.scaleMode_str = scale_str;			
			doScaleMode(scale_str);
		}
	}
	
	public function get scaleMode():String {
		return this.scaleMode_str;		
	}
	
	//scalemode
	public function doScaleMode(){
		switch(scaleMode){
			case 'exactFit':
				doExactFit();
				break;
			case 'noScale':
				doNoScale();
				break;
			default:
				// ??????????????????????????????????????????????????????????
				this.silexInstance.application.removeEventListener('resize');
				// ??????????????????????????????????????????????????????????
				break;
		}
	}
	
	//exactfit
	public function doExactFit(){
		
		//stageRect
		var rectglobal:Object = silexInstance.application.stageRect;
		
		// excat fit
		var localTL:Object = {x:rectglobal.left,y:rectglobal.top}
		_parent.globalToLocal(localTL);		
		
		var localBR:Object = {x:rectglobal.right,y:rectglobal.bottom}
		_parent.globalToLocal(localBR);		
		
		width = localBR.x - localTL.x ;
		height = localBR.y - localTL.y ;
		_x = localTL.x;
		_y = localTL.y;

	}
	
	
	public function doNoScale(){
		
		var objP = contener_mc;
		
		// excat fit
		var localTL:Object = {x:objP._x ,y:objP._y}
		_parent.globalToLocal(localTL);		
		
		var localBR:Object = {x:objP._x + objP._width, y: objP._y + objP._height}
		_parent.globalToLocal(localBR);		
		
		width = localBR.x - localTL.x ;
		height = localBR.y - localTL.y ;
		_x = localTL.x;
		_y = localTL.y;
	}
	

	
	/**
	 * function _onLoadStart
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadStart(cible_mc:MovieClip):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_START ,target:this});
	}
	
	/**
	 * function _onLoadProgress
	 * @param	MovieClip	cible
	 * @param	Number		bytes loaded
	 * @param	Number		total bytes to load
	 * @return 	void
	 */
	function _onLoadProgress (cible_mc:MovieClip, nBytesLoaded:Number, nBytesTotal:Number):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_PROGRESS ,target:this, loaded:nBytesLoaded, total:nBytesTotal });
	}
	
	/**
	 * function _onLoadComplete
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadComplete (cible_mc:MovieClip):Void {	
		_visible = false;
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_COMPLETE ,target:this});
	}		
		
	function _onLoadInit (cible_mc:MovieClip):Void  {	 
		
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_INIT ,target:this});

		if (visibleFrame_bool==true){
			//hide frame
			frame_mc._visible = false;
			//Delete
			frame_mc.removeMovieClip();	
		}
		
		if (!__width) __width=		cible_mc._width;
		if (!__height) __height=	cible_mc._height;
		
		cible_mc._width=__width;
		cible_mc._height=__height;
		//refresh position

		redraw();
		
		_visible = true;
		visibleOutOfAdmin = visibleOutOfAdmin;
		
		if (layoutInstance.isContentVisible)
			playAnim();
		else
			contener_mc._alpha = 100;
	}
	var doFadeInContainerDelegated:Function;
	/** anim intro **/
	function playAnim()
	{
		contener_mc._alpha = 0;
		doFadeInContainerDelegated = Utils.createDelegate(this, doFadeInContainer);
		silexInstance.sequencer.addEventListener("onEnterFrame", doFadeInContainerDelegated);
/*		cible._alpha = 1;
		cible.onEnterFrame = function(){
				if(this._alpha < 99){
					this._alpha += 7;
				}else{
					delete this.onEnterFrame;
				}
		}
*/	}
	public function doFadeInContainer()
	{
		contener_mc._alpha += fadeInStep;
		if (contener_mc._alpha >= 100)
		{
			silexInstance.sequencer.removeEventListener("onEnterFrame", doFadeInContainerDelegated);
		}
	}
	
	/**
	 * function _onLoadError
	 * @param	MovieClip   cible
	 * @param	String		error code
	 * @param	Number		http status
	 * @return 	void
	 */
 	function _onLoadError (cible_mc:MovieClip,errorCode_str:String, HTTPStatus_str:Number):Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_ERROR ,target:this, error:errorCode_str, status:HTTPStatus_str });
		// frame
		if (visibleFrame_bool==true){
			//hide frame
			frame_mc._visible = false;
			//Delete
			frame_mc.removeMovieClip();		
		}
	}
	

	
	//all player loaded
	function _onAllPlayerLoaded(){
		//initmask
		initMask();
		//doScale
		doScaleMode()
	}
	
	//StageResize
	function _onResize() {	
		//scalemode
		doScaleMode();
		if (mask != undefined && mask != "")
		{
			mask = mask;
		}
	}
	
	/**
	 * function loadmedia
	 * @param 	string	media url 
	 * @return 	void
	 */
	public function loadMedia(url_str:String):Void{
		//stock url
		this.url = url_str; // => setter will call doLoadMedia
	}
	
	function doLoadMedia() {
		
		// reveal accessors
		var urlRevealed:String = silexInstance.utils.revealAccessors(privateUrl_str,this);
		var ext = urlRevealed.substr(-3);
		
		silexInstance.utils.loadMedia(urlRevealed,this.contener_mc.contenerVide_mc, ext, listenerLoader_obj);
		
		//appel MoviClipLoader
/*		if (urlRevealed.indexOf("http")==0 || urlRevealed.indexOf("file")==0)
			this.loaderMedia_mcl.loadClip(	urlRevealed,	this.contener_mc.contenerVide_mc);
		else
			this.loaderMedia_mcl.loadClip(	silexInstance.rootUrl+urlRevealed,	this.contener_mc.contenerVide_mc);
*/		//TODO : remplacer par methode globale
		//core.utils.loadMedia();
	}

	/**
	 * function unloadMedia
	 * @return 	void
	 */
	public function unloadMedia():Void {
		super.unloadMedia();
//		this.loaderMedia_mcl.unloadClip(this.contener_mc);
		silexInstance.utils.unLoadMedia(this.contener_mc);
	}
	
	
	// **
	// override PlayerBase class :
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:contener_mc.contenerVide_mc._x,y:contener_mc.contenerVide_mc._y};
	
		// to global
		contener_mc.localToGlobal(coordTL);
		
		return coordTL;
	}
	
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:contener_mc.contenerVide_mc._width+contener_mc.contenerVide_mc._x,y:contener_mc.contenerVide_mc._height+contener_mc.contenerVide_mc._y};
	
		// to global
		contener_mc.localToGlobal(coordBR);
		
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
		_x=coord.x;
		_y=coord.y;
	}
	function setGlobalCoordBR(coord:Object){
		// back to local
		contener_mc.globalToLocal(coord);
				
		// apply the new coordinates to the player
		width=coord.x;
		height=coord.y;
	}
	

	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	 function getSeoData(url_str:String):Object {
		var res_obj:Object = super.getSeoData();
		var htmlContent:String = "";
		
		// keywords
		//res_obj.text="";
		
		// html equivalent
		var ext:String =  this.privateUrl_str.substr( this.privateUrl_str.lastIndexOf(".") + 1, url.length).toLowerCase();
		switch(ext){				
			case 'swf':
				htmlContent = '<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version='+silexInstance.config.flashPlayerVersion+',0,0,0" width="'+width+'" height="'+height+'" >';
				htmlContent += '<param name="movie" value="' + url_str + this.privateUrl_str + '" /><param name="quality" value="best" /><param name="bgcolor" value="#' + silexInstance.config.bgColor + '" />';
				htmlContent += '<embed src = "' + url_str + this.privateUrl_str + '" quality = "best" bgcolor = "#' + silexInstance.config.bgColor + '" width = "' + width + '" height = "' + height + '" type = "application/x-shockwave-flash" pluginspage = "http://www.macromedia.com/go/getflashplayer" />';
				if (descriptionText)
					res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + descriptionText + "</a>";
				else
					res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + privateUrl_str + "</a>";			
				htmlContent += '</object>';
				break;
			case 'gif':
			case 'png':
			case 'jpg':
			default:
				htmlContent = '<img';
				//htmlContent += ' align =  " " ' ;
				if (descriptionText)
					res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + descriptionText + "</a>";
				else
					res_obj.htmlEquivalent += "alt : <a href='" + url_str + privateUrl_str + "'>" + privateUrl_str + "</a>";			
				//htmlContent += ' border = " "' ;
				//htmlContent += ' width = " '  + width + '"';
				//htmlContent += ' height = " ' + height + '"';
				//htmlContent += ' hspace = "" '  ;
				//htmlContent += ' ismap = "" ';
				//htmlContent += ' longdesc="'    + descriptionText + '"';
				htmlContent += ' name="' 	   + playerName + '"';
				htmlContent += ' src="' 	   + url_str + this.privateUrl_str	+ '"';
				//htmlContent += ' usemap = ""'; 
				//htmlContent += ' vspace = "" ';
				htmlContent += '>';		
				break;
		}
		//assign
		res_obj.htmlEquivalent = htmlContent;
		
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
		//htmlContent += ' align =  " " ' ;
		if (descriptionText)
			htmlContent += ' alt="' + descriptionText +'"';
		//htmlContent += ' border = " "' ;
		//htmlContent += ' width = " '  + width + '"';
		//htmlContent += ' height = " ' + height + '"';
		//htmlContent += ' hspace = "" '  ;
		//htmlContent += ' ismap = "" ';
		//htmlContent += ' longdesc="'    + descriptionText + '"';
		htmlContent += ' name="' 	   + playerName + '"';
		htmlContent += ' src="' 	   + url_str + this.privateUrl_str	+ '"';
		//htmlContent += ' usemap = ""'; 
		//htmlContent += ' vspace = "" ';
		htmlContent += '>';		
		//assign
		res_obj.htmlEquivalent = htmlContent;
		return res_obj;
	}
*/	
}