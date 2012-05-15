/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;
import org.silex.core.UtilsHooks;
import org.silex.core.plugin.HookManager;
/**
 *
 * Name : AsFramePlayer.as
 * Package : org.silex.ui.players
 * Version : 1
 * Date :  2007-08-03
 * Author : lex@silex.tv
 */
class org.silex.ui.players.AsFramePlayer extends org.silex.ui.players.PlayerBase
{
	/**
	 * frame component
	 */
	var asframe:org.silex.ui.asframe.AsFrameBase;
	/**
	 * ref to UI
	 */
	var asframeUi:MovieClip;

	// __width and __height are used to store width an height while media may not be loaded yet
	var __width:Number;
	var __height:Number;
	
	private static var ASFRAME_TYPE_LOCATION:String = "location";
	
	private static var ASFRAME_TYPE_HTML_TEXT:String = "htmlText";
	
	private static var ASFRAME_TYPE_EMBEDDED_OBJECT:String = "embeddedObject";
	
	private var _asFrameType:String = "htmlText";
	
    /**
	 * function constructor
	 * @return void
	 */
     public function AsFramePlayer()
     {
     	super();
     	// inheritance
     	typeArray.push("org.silex.ui.players.AsFramePlayer");
		
		// hook to hide the frame when a dialog opens
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.addHook(UtilsHooks.DIALOG_START_HOOK_UID, Utils.createDelegate(this,minimizeCallback));
		hookManager.addHook(UtilsHooks.DIALOG_END_HOOK_UID, Utils.createDelegate(this,minimizeCallback));
     }
	/**
	 * function initialize
	 * @return void
	 */
	private function _initialize():Void{
		super._initialize();
			
		//availableEvents
/*		this.availableEvents.push(
			{modifier:"onLoadStart", 	description : "on Load Start"},
        );
*/
	

		//editableProperties
		this.editableProperties.push(
			{ name :"scale" , 			description:silexInstance.config.PROPERTIES_LABEL_SCALE, 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: ""	, isRegistered: false	, minValue:1,  	maxValue:5000, group:"attributes" },
			{ name :"width" ,			description:silexInstance.config.PROPERTIES_LABEL_WIDTH, 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue: undefined	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:silexInstance.config.PROPERTIES_LABEL_HEIGHT, 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: undefined	, isRegistered:true 	, minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"htmlText" , 			description:silexInstance.config.PROPERTIES_LABEL_FRAME_WIDGET_HTML_TEXT, 				type: silexInstance.config.PROPERTIES_TYPE_TEXT 		, defaultValue: this.playerContainer.htmlText	, isRegistered:true 	, group:"attributes" },
			{ name :"embededObject" ,	description:silexInstance.config.PROPERTIES_LABEL_FRAME_SWF_AS3, 				type: silexInstance.config.PROPERTIES_TYPE_URL 		, defaultValue: this.playerContainer.embededObject	, isRegistered:true 	, group:"attributes" },
			{ name :"location" , 			description:silexInstance.config.PROPERTIES_LABEL_FRAME_HTML_LOCATION, 				type: silexInstance.config.PROPERTIES_TYPE_URL 		, defaultValue: this.playerContainer.location	, isRegistered:true 	, group:"attributes" },
			{ name :"backgroundVisible" , 			description:silexInstance.config.PROPERTIES_LABEL_FRAME_IS_BACKGROUND_VISIBLE, 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: true	, isRegistered:true , group:"attributes" },
			{ name :"asFrameType", 		description:"PROPERTIES_DESCRIPTION_ASFRAMETYPE", 	type:silexInstance.config.PROPERTIES_TYPE_URL,	subType:"Enum",	values:"location,htmlText,embeddedObject",	 defaultValue:ASFRAME_TYPE_LOCATION, isRegistered:true, 	group:"attributes"}
		);	
		

		if (_asFrameType == undefined)
		{
			if (_embededObject != undefined)
			{
				this.asFrameType = ASFRAME_TYPE_EMBEDDED_OBJECT;
			}
			
			else if (_htmlText != undefined)
			{
				this.asFrameType = ASFRAME_TYPE_HTML_TEXT;

			}
			
			else
			{
				this.asFrameType = ASFRAME_TYPE_LOCATION;
			}
		}	
		
		//add listener for stage resize redrawing the frames
		silexInstance.application.addEventListener("resize", Utils.createDelegate(this, redraw));
		
	}
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set width( intValue:Number):Void
	{
		//layerInstance.registerPlayer(this);		
		//_parent._parent._parent._parent._visible = true;
		asframe._width = intValue;
		__width = intValue;
		


		
		
		redraw();
	}

	
	function get width ():Number {
		
		
		
		return __width;
	}
	
	/**
	 * function set/get height
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set height( intValue:Number):Void
	{
		
		asframe._height = intValue;
		__height = intValue;
		


		
		redraw();
	}
	
	function get height ():Number {

		return __height;
	
	}
	
	
	/**
	 * set/get scale
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set scale( numValue:Number):Void{
		asframe._xscale = numValue;
		asframe._yscale = numValue;
		width = asframe._width 
		height = asframe._height
		//refresh
		redraw()
	}
	
	function get scale():Number{
		return Math.round((asframe._xscale + asframe._yscale)/2);
	}
	
	/**
	 * function loadmedia
	 * @param 	string	media url 
	 * @return 	void
	 */
	public function loadMedia(url_str:String):Void{
	}
	
	/**
	 * function unloadMedia
	 * @return 	void
	 */
	public function unloadMedia():Void {
		super.unloadMedia();
		embededObject = "";
		location = "";
		htmlText = "";
		
		// remove delegates
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.removeHook(UtilsHooks.DIALOG_END_HOOK_UID, Utils.removeDelegate(this,minimizeCallback));
		hookManager.removeHook(UtilsHooks.DIALOG_END_HOOK_UID, Utils.removeDelegate(this,minimizeCallback));
		
		silexInstance.application.removeEventListener("resize", Utils.removeDelegate(this, redraw));
		
		if (asframeUi)
		{
			asframeUi.drag_btn.onRelease = asframeUi.drag_btn.onReleaseOutside = null;
			Utils.removeDelegate(this,stopDragAsFrameUi);
			asframeUi.drag_btn.onPress = null;
			Utils.removeDelegate(this, startDragAsFrameUi);
			asframeUi.minimize_btn.onRelease = null;
			Utils.removeDelegate(this, minimizeCallback)
		}
	}
	/**
	 * set/get isEditable
	 * @param 	Boolean		moderation or not
	 * @return  void|Boolean
	 */ 
	public function set isEditable(allowEdit:Boolean)
	{
		super.isEditable = allowEdit;
		if (allowEdit)
		{
			// attach UI
			attachAsFrameUi();
		}
		else
		{
			// remove UI
			removeAsFrameUi();
		}
	}
	
	//completely pointless, but without this setting and getting isEditable on the asframe player messes up. Maybe a quirk in the compiler A.S.
	public function get isEditable():Boolean{
		return super.isEditable;
		
	}
	function attachAsFrameUi() 
	{
		if (!asframeUi)
		{
			asframeUi = this.attachMovie("AsFrameUi", "asframeUi", getNextHighestDepth());
			asframeUi.drag_btn.onRelease = asframeUi.drag_btn.onReleaseOutside = Utils.createDelegate(this,stopDragAsFrameUi);
			asframeUi.drag_btn.onPress = Utils.createDelegate(this, startDragAsFrameUi);
			asframeUi.minimize_btn.onRelease = Utils.createDelegate(this, minimizeCallback);
			redraw();
		}
	}
	function minimizeCallback() 
	{
		asframe.isFrameVisible = !asframe.isFrameVisible;
	}
	function stopDragAsFrameUi() 
	{
		this.stopDrag();
		HookManager.getInstance().callHooks(UtilsHooks.DIALOG_END_HOOK_UID);
		dispatch({type:"stopAdminMove"});
	}
	function startDragAsFrameUi() 
	{
		HookManager.getInstance().callHooks(UtilsHooks.DIALOG_START_HOOK_UID);
		dispatch({type:"startAdminMove"});
		this.startDrag();
	}
	function removeAsFrameUi() 
	{
		if (asframeUi)
		{
			asframeUi.drag_btn.onRelease = asframeUi.drag_btn.onReleaseOutside = undefined;
			asframeUi.drag_btn.onPress = undefined;
			asframeUi.removeMovieClip();
		}
		asframeUi = undefined;
	}
	function redraw(b:Boolean)
	{
		super.redraw(b);
		asframe.redraw(b);
		if (asframeUi)
		{
			asframeUi._x = asframe._x;
			asframeUi._y = asframe._y;
		}
		
		//bug fix
		//hack to force embedded object to refresh
		//and resize when the frame is redrawn
		//I prefer to hack this class
		//rather than frame core classes
		asframe.checkChanges();
		embededObject = _embededObject;
	}
	
	// ------------------------------------------
	// proxy
	// ------------------------------------------
	private var _location:String;
	function get location():String
	{
		return _location;
	}
	function set location(val:String) 
	{
		_location = val;
		
		if (_asFrameType == ASFRAME_TYPE_LOCATION)
		{
			asframe.location = silexInstance.utils.revealAccessors(val,this);
		}
		
	}
	private var _htmlText:String;
	function get htmlText():String
	{
		return _htmlText;
	}
	function set htmlText(val:String) 
	{
		_htmlText = val;
		if (_asFrameType == ASFRAME_TYPE_HTML_TEXT)
		{
			asframe.htmlText = silexInstance.utils.revealAccessors(val,this);
		}
		
	}
	private var _embededObject:String;
	function get embededObject():String
	{
		return _embededObject;
	}
	function set embededObject(val:String) 
	{
		_embededObject = val;
		
		if ( _asFrameType == ASFRAME_TYPE_EMBEDDED_OBJECT)
		{
			asframe.embededObject = silexInstance.utils.revealAccessors(val,this);
		}
		
	}
	function get backgroundVisible():Boolean
	{
		return asframe.backgroundVisible;
	}
	function set backgroundVisible(val:Boolean) 
	{
		asframe.backgroundVisible = val;
	}
	
	public function set asFrameType(value:String):Void
	{
		_asFrameType = value;
		switch(_asFrameType)
		{
			case ASFRAME_TYPE_EMBEDDED_OBJECT:
			asframe.embededObject = silexInstance.utils.revealAccessors(_embededObject, this);
			break;
			
			case ASFRAME_TYPE_HTML_TEXT:
			asframe.htmlText = silexInstance.utils.revealAccessors(_htmlText, this);
			break;
			
			case ASFRAME_TYPE_LOCATION:
			asframe.location = silexInstance.utils.revealAccessors(_location, this);
			break;
		}
	}
	
	public function get asFrameType():String
	{
		return _asFrameType;
	}
	
	// **
	// override PlayerBase class :
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:asframe._x,y:asframe._y};
	
		// to global
		this.localToGlobal(coordTL);
		
		return coordTL;
	}
	
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:asframe._width+asframe._x,y:asframe._height+asframe._y};
	
		// to global
		this.localToGlobal(coordBR);
		
		return coordBR;
	}
	
	
	// **
	// override PlayerBase class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object){
		// back to local
		//this.layerInstance.globalToLocal(coord);
		_parent.globalToLocal(coord);
			
		// apply the new coordinates to the player
		_x=coord.x;
		_y = coord.y;
		//embededObject = this._embededObject;
		redraw();
	}
	function setGlobalCoordBR(coord:Object){
		// back to local
		_parent.globalToLocal(coord);
				
		// apply the new coordinates to the player
		width = coord.x - _x;
		height = coord.y - _y;
		//embededObject = this._embededObject;
		redraw();
	}
	
	

	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	 function getSeoData(url_str:String):Object {
		var res_obj:Object = super.getSeoData();
		var htmlContent:String = "";
		
		// html location 
		if (location != "")
		{
			var objTL:Object = getGlobalCoordTL();
			var objBR:Object = getGlobalCoordBR();
			res_obj.htmlEquivalent = '<iframe src="' + location + '" style="background-color:transparent; border-width:0" height="' + (objBR.y - objTL.y) + '" width="' + objBR.x - objTL.x + '"></iframe>';
		}
		// htmlText 
		if (htmlText && htmlText != "")
		{
			if (!res_obj.text) res_obj.text = "";
			res_obj.text += " "+htmlText;
		}
		
		return res_obj;
	}
}
