/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.ui.UiBase;	
import org.silex.core.Utils;

class org.silex.ui.authoring.ProxiComponent extends UiBase {

	// attributes

	//contener media
   	var contener_mc:MovieClip;
	var contenerVide_mc:MovieClip;

	// __width and __height are used to store width an height while media may not be loaded yet
	var __width:Number;
	var __height:Number;
	//getter/Setter
	var target_str:String;
	var allowResize_bool:Boolean;
	var _resize_array:Array;
	var allowRotation_bool:Boolean;
	var allowIcon_bool:Boolean;
	var _embedFont_bool:Boolean;	
	//label
	var _buttonLabel_str:String;
	var _labelOver_str:String;
	var _labelOut_str:String;
	var _labelRelease_str:String;
	var _labelPress_str:String;
	var _labelOpen_str:String;
	//once open icon
	var _fontOpen_str:String;
	var _targetOpen_str:String;
	//label
	var label_txt:TextField;
	//loader
	var	listenerLoader_obj:Object = null;
	var loaderMedia_mcl:MovieClipLoader = null;
	//accessors
	
	

	public function Proxi(){
		
	}
	
	
	/**
	 * function initialize
	 * @return void
	 */
	function _initialize() {
		super._initialize();
		//create contener global
		this.createEmptyMovieClip("contener_mc", this.getNextHighestDepth());
		
		//editableProperties
		this.editableProperties.unshift(   
			{ name :"width" ,			description:"the width", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:+5000, group:"attributes" },
			{ name :"height" , 			description:"the height", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: ""	, isRegistered:true 	, minValue:-5000,  	maxValue:+5000, group:"attributes" },
			{ name :"useHandCursor" , 	description:"show hand onRollover", 	type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"attributes" }
		);	
		
		this.editableProperties.push(
			{ name :"target",				description:"target",				type: silexInstance.config.PROPERTIES_TYPE_TEXT			, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"buttonLabel",			description:"label",				type: silexInstance.config.PROPERTIES_TYPE_TEXT		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"allowResize",			description:"allowResize",			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: true, isRegistered: true, group:"parameters"	},
			{ name :"resizeArray",			description:"list of resizables",	type: silexInstance.config.PROPERTIES_TYPE_ARRAY		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"allowRotation",		description:"allowRotation",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: true, isRegistered: true, group:"parameters"	},
			{ name :"editableProperties",	description:"editableProperties",	type: silexInstance.config.PROPERTIES_TYPE_ARRAY		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"availableMethods",		description:"availableMethods",		type: silexInstance.config.PROPERTIES_TYPE_ARRAY		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"availableEvents",		description:"availableEvents",		type: silexInstance.config.PROPERTIES_TYPE_ARRAY		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"allowResize",			description:"allowResize",			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: "", isRegistered: true, group:"parameters"	},
			{ name :"embedFonts" , 			description:"embed fonts", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true, group:"parameters" },
			{ name :"buttonLabel",			description:"label",				type: silexInstance.config.PROPERTIES_TYPE_TEXT		, defaultValue: "new button", isRegistered: true, group:"parameters"	},
			{ name :"targetOpen",			description:"load target when open",	type: silexInstance.config.PROPERTIES_TYPE_TEXT			, defaultValue: "", isRegistered: true, group:"parameters"	}
		);			
		
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
		//events
		initEvent();
		//redraw
		redraw();
		
		
	}
  	
	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		//usehandcursor
		if(!this.useHandCursor){
			contenerVide_mc.useHandCursor = false;
		}else{
			contenerVide_mc.useHandCursor = true;
		}
		//resize
		resizeElements();
		//alignElements
		alignElements();
		//label
		initEvent();
	}
	
	
	
	/**
	 * setEditable
	 * encapsulate set editable
	 * @param 	Boolean		moderation or not 
	 * @return  void
	 */
	public function setEditable(edit:Boolean):Void {
		super.setEditable(edit);
		if(!edit){
			contener_mc.onRelease = null;
			contener_mc.onPress = null;
			contener_mc.onRollOver = null;
			contener_mc.onRollOut = null;
		}else{
			contener_mc.onRelease	= 	Utils.createDelegate(this, _onRelease);
			contener_mc.onPress 	= 	Utils.createDelegate(this, _onPress);
			contener_mc.onRollOver = 	Utils.createDelegate(this, _onRollOver);
			contener_mc.onRollOut = 	Utils.createDelegate(this, _onRollOut);
		}
	}
	
	
	
	function resizeElements(){
		/*if( inArray('test', resizeArray)){
		}else{
		}
		
		if( inArray('carre', resizeArray)){
		}else{
		}*/
	}
	
	
	function alignElements(){
		
	}
	
	
	
	function inArray(element_str, tab_array) {
		for (var i in tab_array) {
			if (tab_array[i] == element_str) {
				return true;
			}
		}
		return false;
	};
	
	
	function initEvent(){
		//event
		contenerVide_mc.btn.onRelease 		= Utils.createDelegate(this, _onRelease);
		contenerVide_mc.btn.onPress 		= Utils.createDelegate(this, _onPress);
		contenerVide_mc.btn.onRollOver 		= Utils.createDelegate(this, _onRollOver);
		contenerVide_mc.btn.onRollOut 		= Utils.createDelegate(this, _onRollOut);

	}
	
	
	
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set width( intValue:Number):Void{
		__width = intValue;
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
		__height= intValue;
		redraw();
	}
	function get height ():Number{
		return __height;
	}
	
		
	/**
	 * set/get rotation
	 * @param 	Number		show/hide
	 * @return  void|Number
	 */ 
	 
	public function set rotation( rotationNumber:Number):Void{
		//if allowed
		if(allowRotation){
			this.contener_mc._rotation = rotationNumber;
			//refresh
			redraw();
		}
	}
	
	public function get rotation():Number{
		return this.contener_mc._rotation;
	}

	/**
	 * function set/get useHandcursor
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set useHandcursor( value_bool:Boolean):Void{
		contenerVide_mc.useHandCursor = value_bool;
		redraw();
	}
	
	function get useHandcursor ():Boolean{
		return contenerVide_mc.useHandCursor;
	}
	
	
	
	/**
	 * function set/get embedFonts
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */ 
	function set embedFonts( value_bool:Boolean):Void{
		_embedFont_bool = value_bool;
	}
	
	function get embedFonts ():Boolean{
		return _embedFont_bool;
	}
	
	
	/**
	 * function set/get target
	 * @param 	String		
	 * @return  void|String
	 */
	function set target( value_str:String):Void{
		//assign
		target_str = value_str;
		//load
		removeTarget()
		loadTarget(target_str);
		//redraw
		redraw();
	}
	
	function get target ():String{
		return target_str;
	}
		
	
	/**
	 * function set/get allowResize
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set allowResize( value_bool:Boolean):Void{
		allowResize_bool = value_bool;
		redraw();
	}
	
	function get allowResize ():Boolean{
		return allowResize_bool;
	}
	
	
	
	/**
	 * function set/get resizeArray
	 * @param 	Array		
	 * @return  void|Boolean
	 */
	function set resizeArray( value_ar:Array):Void{
		_resize_array = value_ar;
		redraw();
	}
	
	function get resizeArray ():Array{
		return _resize_array;
	}
	
	
	/**
	 * function set/get allowRotation
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set allowRotation( value_bool:Boolean):Void{
		allowRotation_bool = value_bool;
		redraw();
	}
	
	function get allowRotation ():Boolean{
		return allowRotation_bool;
	}
	
	
	/**
	 * function set/get labelNormal
	 * @param 	String		
	 * @return  void|String
	 */
	function set buttonLabel( value_str:String):Void{
		//assign
		_buttonLabel_str = value_str;
		//redraw
		redraw();
	}
	
	function get buttonLabel ():String{
		return _buttonLabel_str;
	}
	
	
	
	function get fontOpen ():String{
		return _fontOpen_str;
	}
	
	
	/**
	 * function set/get fontOpen
	 * @param 	String		
	 * @return  void|String
	 */
	function set targetOpen(value_str:String):Void{
		_targetOpen_str = value_str;
	}
	function get targetOpen():String{
		return _targetOpen_str ;
	}
	
	
	
	function selectIcon(isSelected:Boolean){
		if(_targetOpen_str != undefined){
			this.loaderMedia_mcl.loadClip(silexInstance.rootUrl+silexInstance.config.initialFtpFolderPath+silexInstance.config.websiteFtpRelativeUrl+ targetOpen, contener_mc.contenerVide_mc)
		}else{
			//texform
			//contenerVide_mc._text.label_str = labelOpen;
		}
	}
	
	
	
	/** loadTarget ***/
	function loadTarget(target:String){
		//remove last target
		removeTarget()
		//AttachMovie
		contenerVide_mc = contener_mc.attachMovie(target,'contenerVide_mc', contener_mc.getNextHighestDepth(),{proxiComponent:this});
		contenerVide_mc.onLoad = Utils.createDelegate(this, initTarget)
		contenerVide_mc.proxiComponent = this;
		//renitinialize events
		initEvent();		
		redraw();
		
	}
	
	/** remove target **/
	function removeTarget(){
		contenerVide_mc.removeMovieClip();
	}
	
	
	function initTarget(){
		//init label ?
		contenerVide_mc.gotoAndStop('rollout');
	}
	
	
	/**
	 * function _onRelease
	 * @return 	void
	 */
	function _onRelease():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_RELEASE ,target:this });
		//texform
		contenerVide_mc.gotoAndStop('release');
		redraw();
	}
	
	/**
	 * function _onPress
	 * @return 	void
	 */	
	function _onPress():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_PRESS ,target:this });		
		//
		contenerVide_mc.gotoAndStop('press');
		redraw();
	}
	
	/**
	 * function _onRollOver
	 * @return 	void
	 */
	function _onRollOver():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOVER ,target:this });		
		//texform
		contenerVide_mc.gotoAndStop('rollover');
		
		
		redraw();

	}
	
	/**
	 * function _onRollOut
	 * @return 	void
	 */	
	function _onRollOut():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOUT ,target:this });
		//textformat
		contenerVide_mc.gotoAndStop('rollout');
		
		
		redraw();

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
	 * function _onLoadStart
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadComplete (cible_mc:MovieClip):Void {	
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_COMPLETE ,target:this});
	}		
		
	/**
	 * function _onLoadInit
	 * @param	MovieClip   cible
	 * @return 	void
	 */
	function _onLoadInit (cible_mc:MovieClip):Void  {	 
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_LOAD_INIT ,target:this});
		initEvent();
		redraw();
		
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
	}
	
	
	
	// **
	// override abstract class :
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
	// override abstract class :
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
	
	//override abstract method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object=new Object;
		res_obj.keywords=descriptionText;
		res_obj.description=descriptionText;
		res_obj.htmlEquivalent=null;
		return res_obj;
	}
}