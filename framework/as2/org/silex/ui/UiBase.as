/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 *
 * Name : UiBase.as
 * Package : ui
 * Version : 0.8
 * Date :  2007-08-03
 */

import org.silex.adminApi.util.T;
import org.silex.core.LayoutHooks;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
import org.silex.ui.LayerHooks;
import org.silex.util.EventDispatcherMovieClip;

/* listen to
core.Authentication
[Event("loginSuccess")]
[Event("logout")]
[Event("loginError")]

core.Application 
[Event("XMLLoaded")]
[Event("showContent")]
[Event("hideContent")]
[Event("onUnload")]

core.Layout
[Event("onDeeplink")]

ui.players.UiBase
[Event("onRelease")]
*/
[Event("loginSuccess")]
[Event("logout")]
[Event("loginError")]

[Event("XMLLoaded")]
[Event("showContent")]
[Event("hideContent")]
[Event("onUnload")]
[Event("onDeeplink")]

// defined in sub classes but common to all players
[Event("onPress")]
[Event("onRelease")]
[Event("onRollOver")]
[Event("onRollOut")]
[Event("onMouseMove")]

class org.silex.ui.UiBase extends EventDispatcherMovieClip implements org.silex.ui.Interface {

	//silex 
	/**
	 * reference to silex api used in Silex components
	 */
	var silexInstance:org.silex.core.Api;
	/**
	 * reference to silex api used in Oof components
	 */
//	static private var silexPtr:org.silex.core.Api;
	// layout
	var layoutInstance/*:org.silex.core.Layout*/=null;
	//layer parent
	var layerInstance:MovieClip = null;
	//contener player
	var playerContainer:MovieClip = null;
	
	/**
	 * the id of the interval dispatching the tooltip hooks
	 */
	var toolTipInterval:Number;
	/**
	 * determine if the component is currently displaying a tooltip
	 */
	var isDisplayingTooltip:Boolean;
	
	//arrays
	/**
	 * typeArray	array of strings - each element is the classes name of the object and its parents
	 * @example		for a video player in Silex, it will be the array ["org.silex.ui.UiBase","org.silex.ui.players.PlayerBase","org.silex.ui.players.Video"]
	 */
	public var typeArray:Array;
	/**
	 * editable properties
	 */
	var editableProperties:Array = null;		
	/**
	 * available actions (i.e. methods)
	 */
    var availableMethods:Array = null;
    /**
     * available events
     */
    var availableEvents:Array = null;
	/**
	 * available methods in the context menu
	 */
	var availableContextMenuMethods = null;
    /**
     * actions array
     */
	var actions:Array = null;    

	/**
	 * default value for width and height
	 */
	static var defaultSize:Number = 100;
	
	//others properties used by interface
	var playerName:String;
	var alternateText:String;
	var descriptionText:String;
	var tags:Array;
	// setter getter below - var visibleOutOfAdmin:Boolean = true; //displayed or not out of moderation	

	// temporary visiblility : _visible = visibleOutOfAdmin && temporarilyVisible
	var temporarilyVisible:Boolean = true;
	var temporarilyVisibleInAdminMode:Boolean = true;
	
	var _isEditable:Boolean; //used by set/get isEditable
	var selected:Boolean ;
	var focus:Boolean;
	//url
	var privateUrl_str:String = null;
	
	/**
	 * workaround "initialize is called several times"
	 */
	var _onLoadOccuredFlag;
	var _initializeOccuredFlag=false;
	var _initBeforeRegisterOccuredFlag=false;
	var _registerWithSilexOccuredFlag=false;
	var _initAfterRegisterOccuredFlag=false;
	
	private var _constructorCount:Number = 0;
	private var _onLoadCount:Number = 0;
	////////////////////////////
	// Group: tooltip
	////////////////////////////
	//var playerTip:org.silex.core.Tooltip = null;
	var playerTip = null;
	var tooltip_str:String = null;
	
	////////////////////////////
	// Group: taken from UIObject/UiComponent 
	////////////////////////////
	// whether the component needs to be drawn
	private var invalidateFlag:Boolean = false;

	// list of functions used by doLater()
	var methodTable:Array;

	// these hold the actual values for the getter-setters
	var __width:Number;
	var __height:Number;
	
	//Is the component selected by the wysiwyg?
	var isSelected : Boolean;
	
	//is an optionnal preview movieClip, displayed in admin
	//but hidden when the component is on the stage
	var preview:MovieClip;
	
		
	////////////////////////////
	// Group: methods
	////////////////////////////
    /**
	 * function constructor
	 * @return void
	 */
     public function UiBase()
     {
     	super();
		
		//retrieve the reference to an optionnal preview
		//movie clip on the stage, then hide it
		preview = _parent.preview;
		preview.unloadMovie();
		
		//T.y("constructor" , this);
		_constructorCount++;

		
     	// inheritance
     	typeArray = ["org.silex.ui.UiBase"];
     	
		 
		silexInstance = _global.getSilex(this);

		__width = _width;
		__height = _height;
		// all ccmponents have 100% scaling
		_xscale = 100;
		_yscale = 100;
		
		// layout
		layoutInstance=silexInstance.application.getLayout(this);
		//layer 
		layerInstance = _parent._parent;
		playerContainer = _parent;
		//editableProperties
		editableProperties = new Array(); 
		//availableMethods
		availableMethods = new Array();
		//availablevents
	   	availableEvents = new Array();
		//availablevents
	   	availableContextMenuMethods = new Array();	
	   	//actions 
	   	actions = new Array();
		
		//tooltip 
		playerTip = attachMovie('it.sephiroth.tooltip','tooltip', getNextHighestDepth());
		
		//editable
		_isEditable = false;
		//visible true by default
		visibleOutOfAdmin = true;
		
		// hide while the 1st frame is did not execute yet - could not use onLoad (image component bug) nor doLater (text component bug) nor doAfterConfig (image component bug).. No comment
		_parent._visible=false;
		var refthis = this;
		silexInstance.sequencer.doInNFrames(1,function (){refthis._parent._visible=true;});

		
//		silexInstance.sequencer.doInNFrames(5,Utils.createDelegate(this,_onLoad));
		//doLater(Utils.createDelegate(this, _onLoad));

		invalidate();
    }
	/**
	 * function _populateProperties. load all editable properties for Silex
	 * @return void
	 */
	function _populateProperties(){

		//center media /stage dimension
		var defaultX:Number = silexInstance.application.stageRect.right + silexInstance.application.stageRect.left; 
		var defaultY:Number = silexInstance.application.stageRect.bottom + silexInstance.application.stageRect.top;		
		//editableProperties for every player
		editableProperties.push (
			{ name :"playerName" ,		description:"PROPERTIES_LABEL_PLAYER_NAME", 					type: silexInstance.config.PROPERTIES_TYPE_URL		, defaultValue: playerContainer.name_str				, 	isRegistered:true, group:"attributes" },
			{ name :"descriptionText" , description:"PROPERTIES_LABEL_SEO_DESCRIPTION", 		type: silexInstance.config.PROPERTIES_TYPE_TEXT		, defaultValue: ""					, 	isRegistered:true, group:"parameters" },
			{ name :"tags" , description:"PROPERTIES_LABEL_SEO_TAGS", 		type: silexInstance.config.PROPERTIES_TYPE_ARRAY		, defaultValue: []					, 	isRegistered:true, group:"parameters" },
			{ name :"width" ,			description:"PROPERTIES_LABEL_WIDTH", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER		, defaultValue:"100"	, isRegistered:true 	, minValue:0,  	maxValue:5000, group:"attributes" },
			{ name :"height" , 			description:"PROPERTIES_LABEL_HEIGHT", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: "100"	, isRegistered:true 	, minValue:0,  	maxValue:5000, group:"attributes" },
			{ name :"iconPageName" , 	description:"PROPERTIES_LABEL_ICON_NAME_OF_TARGETED_PAGE",						type: silexInstance.config.PROPERTIES_TYPE_URL, 			defaultValue: "new page name"	, isRegistered:true, group:"navigation"  },
			{ name :"iconDeeplinkName" , 	description:"PROPERTIES_LABEL_ICON_DEEPLINK_OF_TARGETED_PAGE",						type: silexInstance.config.PROPERTIES_TYPE_URL, 			defaultValue: ""	, isRegistered:true, group:"navigation"},
			{ name :"iconLayoutName" ,	description:"PROPERTIES_LABEL_ICON_NAME_OF_LAYOUT",		type: silexInstance.config.PROPERTIES_TYPE_URL,	 		defaultValue:layoutInstance.layoutFileName		, isRegistered:true, group:"navigation" },
			{ name :"iconIsIcon" , 		description:"PROPERTIES_LABEL_ICON_IS_ICON", 					type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN, 			defaultValue: false		, 	isRegistered:true, group:"navigation" },
			{ name :"iconIsDefault" , 	description:"PROPERTIES_LABEL_ICON_IS_DEFAULT_ICON", 			type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN, 			defaultValue: false		, 	isRegistered:true, group:"navigation"  },
			{ name :"_alpha" , 			description:"PROPERTIES_LABEL_OPACITY", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 	, defaultValue: 100					, 	isRegistered:true,	minValue:0,  		maxValue:100, group:"attributes" },
			{ name :"_x" , 				description:"PROPERTIES_LABEL_X_POSITION", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 	, defaultValue: defaultX			, 	isRegistered:true,	minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"_y" , 				description:"PROPERTIES_LABEL_Y_POSITION", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER 	, defaultValue: defaultY			, 	isRegistered:true,	minValue:-5000,  	maxValue:5000, group:"attributes" },
			{ name :"_rotation" , 		description:"PROPERTIES_LABEL_ROTATION", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER 	, defaultValue: 0					, 	isRegistered:true,	minValue:0, 		maxValue:359, group:"attributes" },
			{ name :"url" ,				description:"PROPERTIES_LABEL_URL", 						type: silexInstance.config.PROPERTIES_TYPE_URL 		, defaultValue: playerContainer.media_str	, isRegistered:true, group:"attributes"	},
			{ name :"visibleOutOfAdmin" , 		description:"PROPERTIES_LABEL_IS_VISIBLE", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN	, defaultValue: true				, 	isRegistered:true, group:"attributes" },
			{ name :"tooltipText" , 	description:"PROPERTIES_LABEL_TOOLTIP", 					type: silexInstance.config.PROPERTIES_TYPE_TEXT	 	, defaultValue: undefined , isRegistered:true, group:"parameters"  },
			{ name :"tabEnabled" , 	description:"PROPERTIES_LABEL_ENABLE_TABULATION",		type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN 		, defaultValue: false	, isRegistered:true, group:"others" },
			{ name :"tabIndex" , 		description:"PROPERTIES_LABEL_TABULATION_INDEX", 	type: silexInstance.config.PROPERTIES_TYPE_NUMBER 		, defaultValue: 1		, isRegistered:true , minValue:1,  	maxValue:5000, group:"others" }
		);
		if (playerContainer.isEditable != undefined) setEditable(playerContainer.isEditable);
	}
	/**
	 * function _populateEvents. load all events for Silex
	 * @return void
	 */
	function _populateEvents(){
		//availableEvents
		availableEvents.push(
			{modifier:"loginSuccess", 		description : "dispatched when login occurs"},
			{modifier:"loginError", 		description : "dispatched when login failed"},
			{modifier:"logout", 		description : "dispatched when logout occures"},
			{modifier:"onPress", 		description : "on mouse press"},
			{modifier:"onRelease",		description : "on mouse release"},
			{modifier:"onPress", 		description : "on mouse press"},			
		    {modifier:"onRollOut", 		description : "on mouse rollout"},	
			{modifier:"onRollOver", 		description : "on mouse rollover"},			
			{modifier:"onMouseMove", 		description : "on mouse move"},
			{modifier:"XMLLoaded", 		description : "on XML loaded"},
			{modifier:"showContent", 	description : "show Content"},
			{modifier:"hideContent", 	description : "hide Content"},
			{modifier:"onUnload", 		description : "on Unload"},
			{modifier:"onDeeplink", 	description : "on Deeplink"}
        );
	}
	
	
	
	/**
	 * function _populateMethods. load all events for Silex
	 * @return void
	 */
	function _populateMethods(){
		
	}
	/**
	 * function _populateContextMenu. (right click)
	 * @return void
	 */
	function _populateContextMenu(){
		// defines contextMenu
/*		availableContextMenuMethods.push(
                { fct :"rotatePlayer",     description :silexInstance.config.UI_PLAYERS_CONTEXT_MENU_LABEL_RESET_ROTATION,         	param : 0},
                { fct :"changeZOrder",     description :silexInstance.config.UI_PLAYERS_CONTEXT_MENU_LABEL_ZORDER_DOWN,    			 	param : "down"},
                { fct :"changeZOrder",     description :silexInstance.config.UI_PLAYERS_CONTEXT_MENU_LABEL_ZORDER_UP,     				param : "up"},
                { fct :"changeZOrder",     description :silexInstance.config.UI_PLAYERS_CONTEXT_MENU_LABEL_ZORDER_TO_BOTTOM,     		param : "background"},
                { fct :"changeZOrder",     description :silexInstance.config.UI_PLAYERS_CONTEXT_MENU_LABEL_ZORDER_TO_TOP,         	param : "foreground"}
        );
*/		// init
		menu = _root.menu;
	}
		
	/** function _initialize. kept for legacy reasons. should be eliminated soon
	 * @return void
	 */
	function _initialize():Void{
		if (_initializeOccuredFlag) return;
		_initializeOccuredFlag = true;
		//T.y("_initialize", _visible , this);
	}
	
	/**
	 * function _initBeforeRegister. 
	 * @return void
	 */
	function _initBeforeRegister(){
		//T.y("_initialize" , this);
		if (_initBeforeRegisterOccuredFlag) return;
		_initBeforeRegisterOccuredFlag = true;
		
		if (!_initializeOccuredFlag)
			_initialize();
	}
	
	function _registerWithSilex(){
		//trace(this + "_registerWithSilex");
		if (_registerWithSilexOccuredFlag) return;
		_registerWithSilexOccuredFlag = true;
		
		//("ui.players.UiBase _registerWithSilex ");
	    //register Silex variable for editableProperties
		//count objects in array
		if (silexInstance.isSilexServer==true){ // only in SILEX
			var len:Number = editableProperties.length;
			for (var i:Number = 0; i < len; i++)
			{
				//get type 
				var type_str:String = getASType(editableProperties[i].type);
				//if registerable
				if(editableProperties[i].isRegistered){
					//if not Register silex variable
					if(!silexInstance.dynDataManager.registerVariable(this, editableProperties[i].name,type_str)){
						//if not null apply defaults value
						if( editableProperties[i].defaultValue != undefined && editableProperties[i].defaultValue.toString() != ""){ 
							//T.y("setting default ", editableProperties[i].name, editableProperties[i].defaultValue);
							this[editableProperties[i].name] = editableProperties[i].defaultValue;
						}
					}
				}else{
					if( editableProperties[i].defaultValue != ""){ 
						this[editableProperties[i].name] = editableProperties[i].defaultValue;
						
						}
				}
			}
		}
		
		//actions register 
		silexInstance.dynDataManager.registerVariable(this,"actions","array");
		//register player in his layer
		layerInstance.registerPlayer(this);		
		
		
	}
	
	/**
	 * function _initAfterRegister. 
	 * @return void
	 */
	function _initAfterRegister(){
		//T.y("_initAfterRegister" , this);
		if (_initAfterRegisterOccuredFlag) return;
		_initAfterRegisterOccuredFlag = true;
		//eventlistener layout
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_XMLLOADED,	Utils.createDelegate(this,_XMLLoaded));
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE_START,	Utils.createDelegate(this,_hideContentStart));
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE,	Utils.createDelegate(this,_hideContent));
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_SHOW,	Utils.createDelegate(this,_showContent));
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_CHILD_HIDE,	Utils.createDelegate(this,_hideChild));
		layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_CHILD_SHOW,	Utils.createDelegate(this,_showChild));

		silexInstance.authentication.addEventListener( "loginSuccess",	Utils.createDelegate(this, dispatch));
		silexInstance.authentication.addEventListener( "loginError",	Utils.createDelegate(this, dispatch));
		silexInstance.authentication.addEventListener( "logout",	Utils.createDelegate(this, dispatch));
	}

	 
	 /**
	  * deprecated!! 
	  * This is still used in the components, so it is called at the end of doAfterConfig. But it should disappear!
	  */
	 public function _onLoad(){
		 _onLoadCount++;
		 //T.y("_onLoad" , this);
		 
	 }	
	 
	 public function doBeforeConfig():Void{
		 //T.y("doBeforeConfig" , this);
		 try {_populateProperties();}catch (e:Error){}
		 try {_populateEvents();}catch (e:Error){}
		 try {_populateContextMenu();}catch (e:Error){}
		 try {_initBeforeRegister();}catch (e:Error){}
		 
	 }	 
	
	/**
	* the component is either configured by the component loader with the v3 model, or by the layer calling _registerWithSilex. In any case this method must be called afterwards
	*/
	public function doAfterConfig():Void{
		//T.y("doAfterConfig" , this);
		_initAfterRegister();
		
		//once all players are loaded
		layerInstance.addEventListener('allPlayersLoaded', Utils.createDelegate(this,_onAllPlayerLoaded));
		//stage resize
		silexInstance.application.addEventListener('resize', Utils.createDelegate(this,_onResize))

		// start if content is allready visible
		if (layoutInstance.isContentVisible == true){
			_showContent();
		}
		
		//legacy call to _onLoad. this is deprecated, don't count on it for new devs
		if (_onLoadOccuredFlag) return;
		_onLoadOccuredFlag = true;
		_onLoad();
		
		redraw();
		dispatch( { type: silexInstance.config.UI_PLAYERS_EVENT_ONLOAD , target:this } );
	}
	
	function _onAllPlayerLoaded(){
		
	}
	
	function _onResize(){
	}
	
	/**
	 * events 
	 */
	 function _XMLLoaded(){
		 //dispatch
		 dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_XMLLOADED, target:this });
	 }
	 
	 
	 function _hideContentStart(){
		 //dispatch
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE_START, target:this });
	 }
	 
	 function _hideContent(){
		 //dispatch
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE, target:this });
		  //on unload
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_UNLOAD, target:this });
		  //Remove listener
		  unloadMedia();
		  onUnload();
	}
	 
	 
	 function _showContent(){
		 //dispatch
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CONTENT_SHOW, target:this });
	 }
	function _showChild(){
		 //dispatch
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CHILD_SHOW, target:this });
	 }
	function _hideChild(){
		 //dispatch
		  dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_CHILD_HIDE, target:this });
	 }
	 
	 
	 
	 

	 
	/**
     * initContextMenu
     * push item in contextmenu 
     */
    function initContextMenu(){
	   
	   // init context menu
		if (!menu) menu = _root.menu.copy();
		if (!menu) menu = new ContextMenu;
        menu.hideBuiltInItems();
        // parse all items of availableContextMenuMethods
        var len:Number = availableContextMenuMethods.length;
        for (var i:Number = 0; i<len; i++){
            //test si method exists ?
            if(availableContextMenuMethods[i].fct){
                // adds a reference to the player (this) in the item
                availableContextMenuMethods[i].player_ptr=this;
                // build a ContextMenuItem object based on the item
                var menuItem_cmi:ContextMenuItem = new ContextMenuItem(availableContextMenuMethods[i].description,Utils.createDelegate(availableContextMenuMethods[i],execContextMenuMethod));
                //push item in context menu
                menu.customItems.push( menuItem_cmi );
            }
        }
    }
    
	function removeContextMenu() {
		menu = _root.menu.copy();
	}
	
	function addContextMenu(){		
		
		for( var eachProp in  menu.builtInItems) {
			var propName = eachProp;
			var propValue = menu.builtInItems[propName];
			propValue.enabled = true;
		}	
	}
	
    
    
    function execContextMenuMethod(){
        //appel fct
		if( this["param"] != null){
       		 this["player_ptr"][this["fct"]](this["param"]);
		}else{
			this["player_ptr"][this["fct"]]();
		}
		//_global.getSilex(this).utils.alert("execContextMenuMethod" + this + silexInstance);
		//somehow silexInstance undefined here. use global
		_global.getSilex(this).application.onComponentChanged();
    }
	 
	 
	 
	//rotation 
	function rotatePlayer(angle:Number):Void{
		rotation = angle;
	}
	 
	// change z-order
	function changeZOrder(positionZ:String):Void{
		//players
		var l:Number = layerInstance.players.length;
		//get player indice position
		var indice:Number = null;
		for(var i:Number =0; i<l; i ++){
			if( layerInstance.players[i]._name == playerContainer._name){
				indice = i;
			}
		}
		//if indice found
		if(indice != null){
			//action to do
			switch(positionZ){
				case 'down':
					//if player not the last
					if(indice != l){
						var temp:Object = layerInstance.players[indice];
						//insert position +2
						layerInstance.players.splice(indice+2, 0, temp );
						//delete indice
						layerInstance.players.splice(indice,1);						
					}					
					break;
					
				case 'up':
					////if player not the first
					if( indice >= 1 ){
						var temp:Object = layerInstance.players[indice];
						//delete indice
						layerInstance.players.splice(indice,1);	
						//insert position +2
						layerInstance.players.splice(indice-1, 0, temp );						
					}
					break;
					
				case 'background':
					//players
					if( indice != l ){
						var temp:Object = layerInstance.players[indice];
						//Delete
						layerInstance.players.splice(indice,1);
						//push last
						layerInstance.players.push(temp);
					}
					break;
					
				case 'foreground':
					//players
					if( indice != 0 ){
						var temp:Object = layerInstance.players[indice];
						//Delete
						layerInstance.players.splice(indice,1);
						//push last
						layerInstance.players.unshift(temp);
					}
					break;						
			}
			//Refresh
			layerInstance.refresh();
		}
	}
	
	/*
	 * animation when player is set to editable
	 */
	
	function animation(){
		 attachMovie('animation', 'animation', getNextHighestDepth() );
		 animation.play();
	}
	
	
	
	/**
	 * function getAsType
	 * @return String
	 */
    function getASType(type_str:String):String
	{
		switch(type_str)
		{
			case "rich text":
			case "coordinates":
			case "text":
			case "color":
				return "string";
			case "boolean":
				return "boolean";
			case "number":			
				return "number";
		}
		return "string";
	}
	
	

	
   /**
	* function dispatch
	* @return void
	*/
   public function dispatch(eventObject:Object):Void{
		//T.y("dispatch", eventObject, _isEditable, actions.length);
		//dispatch Event
		dispatchEvent(eventObject);
		//if not editable
		if(!_isEditable){
			//silex interpreter
			//boucle actions
		    var len:Number = actions.length;
			for (var i:Number = 0; i<len; i++){
				//object in array
				var obj:Object = actions[i];
				//T.y("action", obj);
				//if modifier == event
				if( actions[i].modifier == eventObject.type){
					//T.y("action exec!", actions[i]);
					//silex command
					var function_str:String = actions[i].functionName ;
					var command_str:String=function_str;
					//parameters in a string
					if (actions[i].parameters && actions[i].parameters.length>0){
						var parameters_str:String = actions[i].parameters.toString();
						// format the text with accessors etc
						//parameters_str=silexInstance.utils.revealAccessors(parameters_str,this);
						parameters_str=silexInstance.utils.revealWikiSyntax(parameters_str);
						command_str+=":"  + parameters_str;
					}
					//silex interpreter
					silexInstance.interpreter.exec( command_str  ,this);
				}					
			}
		}
	}

	
	
	function get url():String{
		return privateUrl_str;
	}
	
	function set url(url_str:String){
		privateUrl_str=url_str;		
	}
	
	
	/**
	* tooTip
	*/
	function get tooltipText():String{
		return tooltip_str;
	}
	
	function set tooltipText(value_str:String){

		tooltip_str = value_str;		
	}
	
	/**
	 * setVisible
	 * deprecated!!! in google chrome sometimes this is called and we don't know why. So in the end we just get rid of the function
	 * 
	 * player visible or not on scene
	 * encapsulate set isVisible
	 * @param 	Boolean		show/hide
	 * @return  void
	 */ 
	/*
	public function setVisible(showIt:Boolean):Void {
		T.y("set setVisible", showIt, _visible, this);
		isVisible = showIt;			
	}
	*/
	// **
	// Icons variables
	private var _iconIsIcon:Boolean=false;
	private var _iconIsDefault:Boolean=false;
	var iconPageName:String;
	var iconDeeplinkName:String;
	var iconLayoutName:String;
	var iconListener:Object;

	/**
	 * set/get iconIsIcon
	 * indicate if the player is an icon, i.e. if it is part of the navigation menu
	 * @param 	Boolean
	 * @return  void|Boolean
	 */ 
	function get iconIsIcon():Boolean
	{
		return _iconIsIcon;
	}
	function set iconIsIcon(isIcon_bool:Boolean)
	{
		if (_iconIsIcon==isIcon_bool){
			// nothing changed => do nothing
			return;
		}
		_iconIsIcon=isIcon_bool;

		if (_iconIsIcon==true)
		{// iconIsIcon is set to true
			iconListener=new Object;
			iconListener.onRelease=Utils.createDelegate(this,openIcon);
			iconListener.onDeeplink=Utils.createDelegate(this,openIconOnDeeplink);
			//release
			addEventListener( silexInstance.config.UI_PLAYERS_EVENT_RELEASE, iconListener);
			layoutInstance.addEventListener( silexInstance.config.UI_PLAYERS_EVENT_DEEPLINK, iconListener);
		}
		else
		{// iconIsIcon is set to false
			// supress the listener
			if (iconListener)
			{
				removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_RELEASE, iconListener);
				layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_DEEPLINK, iconListener);
				iconListener=null;
				
			}
		}
	}
	function get iconIsDefault():Boolean{
		return _iconIsDefault;
	}
	function set iconIsDefault(isDefault:Boolean){
		//trace("set iconIsDefault " + isDefault + ", this : " + this + ", layout : " + layoutInstance);
		if (isDefault!=_iconIsDefault){
			if (isDefault==true){
				layoutInstance.registerDefaultIcon(this);
			}
			else{
				layoutInstance.unRegisterDefaultIcon(this);
			}
			_iconIsDefault=isDefault;
		}
	}
	/**
	 * openIconOnDeeplink
	 * check if the deeplink corresponds to this icon
	 * - core.Layout::onDeeplink event
	 */ 
	function openIconOnDeeplink(ev) {
		if(!iconIsIcon){
			return;
		}
		var acceptedDeepLinkName:String = null;
		if(iconDeeplinkName && iconDeeplinkName.length > 0){
			acceptedDeepLinkName = iconDeeplinkName;
		}else{
			//no deeplink is specified, so use the icon page name
			acceptedDeepLinkName = iconPageName;
		}
		//clean id:
		acceptedDeepLinkName = silexInstance.utils.cleanID(acceptedDeepLinkName);
		// does the deeplink corresponds to this icon?
		if (ev.deeplinkName == acceptedDeepLinkName){
			
			//dispatch
			dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_DEEPLINK, target:this });

			// do open
			openIcon();
		}
	}
	/**
	 * openIcon
	 * check if the icon may open a page and eventually call doOpenIcon to open it
	 */ 
	function openIcon()
	{
		// is it initialized?
		//if (iconPageName==undefined || iconLayoutName==undefined)
		//	return;
			
		// 
		if (!_isEditable){
			var dirtyChildLayout=silexInstance.application.isAChildDirty(layoutInstance);
			if (dirtyChildLayout && silexInstance.authentication.isLoggedIn()){
				silexInstance.utils.confirm(silexInstance.utils.revealAccessors(silexInstance.config.QUIT_DIRTY_PAGE_WARNING,dirtyChildLayout),Utils.createDelegate(this,openIconConfirmCallback));
			}
			else{
				doOpenIcon();
			}
		}
	}
	function openIconConfirmCallback(doIt:Boolean){
		if (doIt) doOpenIcon();
	}
	/**
	 * doOpenIcon
	 * open the page associated with this icon
	 * - media::onRelease event
	 * - core.Layout::onDeeplink event
	 */ 
	function doOpenIcon()
	{
		var revealedPageName:String = silexInstance.utils.revealAccessors(iconPageName, this);
		var revealedDeeplinkName:String = revealedPageName;
		if (iconDeeplinkName != undefined && iconDeeplinkName != "") revealedDeeplinkName = silexInstance.utils.revealAccessors(iconDeeplinkName, this);
		var revealedLayoutName:String = silexInstance.utils.revealAccessors(iconLayoutName, this);
		
		if (iconPageName!=undefined && iconLayoutName!=undefined && layoutInstance!=undefined && revealedLayoutName!="" && revealedPageName!="" && revealedDeeplinkName!="")
		{
			silexInstance.application.openSection(revealedPageName, revealedLayoutName, layoutInstance, revealedDeeplinkName);
		}
		else
		{
			return;
		}
		
		// unselect selected icon of the layout
		if(layoutInstance.selectedIcon)
			layoutInstance.selectedIcon.selectIcon(false);

		// store selected icon in layout
		layoutInstance.selectedIcon=this;
		
		// call selectIcon for derived classes
		selectIcon(true);
	}
	/**
	 * selectIcon
	 * called by openIcon and core.application::openSection
	 * to be overriden by sub classes - mark the media as selected?
	 */
	function selectIcon(isSelected:Boolean){
	}


	/**
	 * set/get rotation
	 * @param 	Number		show/hide
	 * @return  void|Number
	 */ 
	 
	public function set rotation( rotationNumber:Number):Void{
		_rotation = Math.round(rotationNumber);
	}
	
	public function get rotation():Number{
		return _rotation;
	}
		
	/**
	 * setEditable
	 * encapsulate set editable
	 * @param 	Boolean		moderation or not 
	 * @return  void
	 */
	public function setEditable(edit:Boolean):Void {
		isEditable= edit;			
	}
	 
	 
	/**
	 * set/get isEditable
	 * @param 	Boolean		moderation or not
	 * @return  void|Boolean
	 */ 
	public function set isEditable(allowEdit:Boolean):Void {
		//T.y("set isEditable", allowEdit, _visible, temporarilyVisibleInAdminMode, visibleOutOfAdmin, temporarilyVisible, this);
		_isEditable = allowEdit;
		if( !_isEditable){
			//assign visibility out of moderation defined by visible 
			removeContextMenu()
			//
			_visible = visibleOutOfAdmin && temporarilyVisible;	
		}else{
			_visible = temporarilyVisibleInAdminMode;
			//show contextmenu 
			initContextMenu();
			//anim 
			animation();
		}
	}	
	
	public function get isEditable():Boolean{
		return _isEditable;
	}
	
	
	/**
	 * set/get isVisible
	 * visibility used by tool boxes
	 * @param 	Boolean		show/hide
	 * @return  void|Boolean
	 */ 
	public function set isVisible(showIt:Boolean):Void {
		//T.y("set isVisible", showIt, _visible, this);
		_visible = showIt;
		temporarilyVisible = showIt;
	}
	
	public function get isVisible():Boolean{
		return _visible;
	}
	/**
	 * set/get visibleOutOfAdmin
	 * visibility when out of admin mode
	 * @param 	Boolean		show/hide
	 * @return  void|Boolean
	 */ 
	var _visibleOutOfAdmin:Boolean=true;
	public function set visibleOutOfAdmin(showIt:Boolean):Void {
		//T.y("set visibleOutOfAdmin", showIt, _visible, temporarilyVisibleInAdminMode, visibleOutOfAdmin, temporarilyVisible, this);
		
		_visibleOutOfAdmin=showIt;		
		if(_isEditable==true)
			_visible=temporarilyVisibleInAdminMode;
		else
			_visible=_visibleOutOfAdmin && temporarilyVisible;

	}
	
	public function get visibleOutOfAdmin():Boolean{
		return _visibleOutOfAdmin;
	}
	
		
	/**
	 * implementations interface 
	 * @param 	Boolean		focus true|false
	 * @return  void
	 */	
	public function setFocus(getFocusOrLooseIt:Boolean):Void {
			if(getFocusOrLooseIt){
				focus = true;
			}else{
				focus = false;
			}
	}
	
	/**
	 * implementations interface 
	 * @param 	Boolean		selected true|false
	 * @return  void
	 */
	public function setSelected(selectItOrDeselectIt:Boolean):Void {
			if(selectItOrDeselectIt){
				selected = true;
			}else{
				selected = false;
			}
	}
	
	/**
	 * implementations interface 
	 * @param 	String		media Url
	 * @return  void
	 */
	public function loadMedia(url:String):Void{
		//TODO : use methode globale
		//core.utils.loadMedia();
	}
	
	
	
	/**
	 * implementations interface 
	 * @return  void
	 */
	public function unloadMedia():Void
	{
/*		//once all players are loaded
		layerInstance.removeEventListener('allPlayersLoaded', Utils.removeDelegate(this,_onAllPlayerLoaded));
		//stage resize
		silexInstance.application.removeEventListener('resize', Utils.removeDelegate(this,_onResize))

		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_XMLLOADED,	Utils.removeDelegate(this,_XMLLoaded));
		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE_START,	Utils.removeDelegate(this,_hideContentStart));
		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_HIDE,	Utils.removeDelegate(this,_hideContent));
		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_CONTENT_SHOW,	Utils.removeDelegate(this,_showContent));
		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_CHILD_HIDE,	Utils.removeDelegate(this,_hideChild));
		layoutInstance.removeEventListener( silexInstance.config.UI_PLAYERS_EVENT_CHILD_SHOW,	Utils.removeDelegate(this, _showChild));				
		
		
		silexInstance.authentication.removeEventListener( "loginSuccess",	Utils.removeDelegate(this, dispatch));
		silexInstance.authentication.removeEventListener( "loginError",	Utils.removeDelegate(this, dispatch));
		silexInstance.authentication.removeEventListener( "logout",	Utils.removeDelegate(this, dispatch));
*/	}
	
	
	/** events **/
	
	/**
	 * function _onRelease
	 * @return 	void
	 */
	function _onRelease():Void {
	
		//if a tooltip is displayed by the component
		if (isDisplayingTooltip == true)
		{
			//hide it
			hideTooltip();
		}
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_RELEASE ,target:this });
	}
	
	/**
	 * function _onPress
	 * @return 	void
	 */	
	function _onPress():Void {
	
		//if a tooltip is displayed by the component
		if (isDisplayingTooltip == true)
		{
			//hide it
			hideTooltip();
		}
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_PRESS ,target:this });
	}
	
	/**
	 * function _onRollOver
	 * @return 	void
	 */
	function _onRollOver():Void{
		onMouseMove = _onMouseMove;
		
		clearInterval(toolTipInterval);
		//if the tooltip text is not null, we set an interval
		if (tooltipText != undefined && tooltipText != null && tooltipText != '' && isEditable == false && isDisplayingTooltip == false)
		{
			toolTipInterval = setInterval(Utils.createDelegate(this, displayToolTip), silexInstance.config.TOOLTIP_DELAY);
		}
		else
		{
			hideTooltip();
		}
	
		
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOVER ,target:this });
	}
	
	/**
	 * calls a hook intercepted by the tooltip plugin and clear the tooltip interval
	 */
	function displayToolTip():Void
	{
		if (isDisplayingTooltip == false)
		{
			Utils.removeDelegate(this, displayToolTip);
			isDisplayingTooltip = true;
			var hookManager:HookManager = HookManager.getInstance();
			hookManager.callHooks(LayerHooks.COMPONENT_SHOW_TOOLTIP, { text:tooltipText } );
		}
		
	}
	
	/**
	 * calls a hook intercepted by the tooltip plugin to hide the tooltip and clear the tooltip interval
	 */
	function hideTooltip():Void
	{
		isDisplayingTooltip = false;
		//stop the tooltip interval
		clearInterval(toolTipInterval);
	}
	
	/**
	 * function _onRollOut
	 * @return 	void
	 */	
	function _onRollOut():Void {
		
		//if a tooltip is displayed by the component
		if (isDisplayingTooltip == true)
		{
			//hide it
			hideTooltip();
		}
		
		
		onMouseMove = undefined;
		//tooltip remove
		if(playerTip != null ){
			//playerTip.removeTip();
			 playerTip.hide(300)
		}
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOUT ,target:this });
	}
	
	
	/**
	 * function _onMouseMove
	 * @return 	void
	 */
	function _onMouseMove():Void {
		
		//if a tooltip is displayed by the component
		if (isDisplayingTooltip == true)
		{
			//hide it
			hideTooltip();
		}
		//if(true)silexInstance.utils.alert("_onMouseMove");
		//dispatch
		dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_MOUSEMOVE ,target:this });
	}
	
	
	private var _className:String = null;
		

	/* getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	function getSeoData(url_str:String):Object {
		var res_obj:Object = new Object;
		var linkLayerName:String = "";
		var linkDeeplink:String = "";

		// keywords
		//res_obj.text="test";
		
		// name
		res_obj.playerName = playerName;
		
		// class Name
		_className = typeArray[typeArray.length - 1];
		res_obj.className = _className;
		
		// tags
		if (tags)
			res_obj.tags=tags;
		
		// description
		if (descriptionText)
			res_obj.description=descriptionText;
		
		// links
		if (iconIsIcon) {
			res_obj.iconIsIcon = 'true';
			res_obj.iconPageName = iconPageName;
			res_obj.iconDeeplinkName = iconDeeplinkName;
			res_obj.links = new Array;
			linkLayerName = silexInstance.utils.cleanID(iconPageName);
			if ( (iconDeeplinkName == null) || (iconDeeplinkName == "") )
			{
				linkDeeplink = silexInstance.utils.cleanID(iconPageName);
			}
			else
			{
				linkDeeplink = silexInstance.utils.cleanID(iconDeeplinkName);
			}

		//res_obj.href+="<u>debug</u><br>layoutRelativePath="+layoutRelativePath+"<br>layoutPath="+layoutPath+"<br>iconPageName="+silex_ptr.utils.cleanID(player.iconPageName)+"<br>";
			// YES : res_obj.href+="<a href='"+layoutRelativePath+silex_ptr.config.id_site+"/"+layoutPath+"/"+silex_ptr.utils.cleanID(player.iconPageName)+"'><H2>"+player.iconPageName+"</H2><br>"+res_obj.description+"<br>";
			//// YES : v1beta4
			/*
			res_obj.href+="<a href='./"+silex_ptr.utils.cleanID(player.iconPageName)+"/'><H2>"+player.iconPageName+"</H2><br>"+res_obj.description+"<br>";
			if (_obj.htmlEquivalent) res_obj.href+=_obj.htmlEquivalent;
			res_obj.href+="</a><br>";
			*/
			//res_obj.links.push({link:silexInstance.utils.cleanID(iconDeeplinkName),title:iconPageName,description:descriptionText});
			res_obj.links.push({title:linkLayerName,link:linkLayerName,deeplink:linkDeeplink,description:descriptionText});
		}
		else
		{
			res_obj.iconIsIcon = 'false';
		}
		
		// html equivalent
		// res_obj.htmlEquivalent=descriptionText;
		
		// context
		res_obj.context = getUiContext();
		
		return res_obj;
	}
	
	
	
	/////////////////////////////////////////
	// UIComponent methods
	// available for 
	// * ActionScript
	// * SILEX (commands)
	/////////////////////////////////////////
    
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:_x,y:_y};
	
		// to global
		_parent.localToGlobal(coordTL);
		
		return coordTL;
	}
	
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:width+_x,y:height+_y};
	
		// to global
		_parent.localToGlobal(coordBR);
		
		return coordBR;
	}
	
	
	// **
	// override abstract class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object){
		// back to local
		_parent.globalToLocal(coord);
		
		// apply the new coordinates to the player
		_x = coord.x;
		_y = coord.y;
	}
	function setGlobalCoordBR(coord:Object){
	
		// back to local
		_parent.globalToLocal(coord);
		
		// apply the new coordinates to the player
		width=coord.x - _x;
		height=coord.y - _y;
	}
	
	function set width (val:Number) {
		if (val == undefined) val = defaultSize;
		setSize(val,height);
	}
	
	function set height (val:Number) {
		if (val == undefined) val = defaultSize;
		setSize(width,val);
	}
	/* getUiContext
	 * retrieve the context of this object 
	 * use the layer's players array
	 */
	function getUiContext():Array{
		var l:Number = layerInstance.players.length;
		for(var i:Number =0; i<l; i ++){
			if( layerInstance.players[i]._name == playerContainer._name){
				return layerInstance.players[i].contextAccepted.join(",");
			}
		}
		return null;
	}
	


/**
* width of object
*/
	function get width():Number
	{
		return __width;
	}

/**
* height of object
*/
	function get height():Number
	{
		return __height;
	}


/**
*  Queues a function to be called later
*
* @param	obj	Object that contains the function
* @param	fn	Name of function on Object
*/
	function doLater(obj:Object, fn:String):Void
	{
		if (methodTable == undefined)
		{
			methodTable = new Array();
		}
		methodTable.push({obj:obj, fn:fn});
		onEnterFrame = doLaterDispatcher;
	}

	// callback that then calls queued functions
	function doLaterDispatcher(Void):Void
	{
		delete onEnterFrame;

		// invalidation comes first
		if (invalidateFlag)
		{
			redraw();
		}

		// make a copy of the methodtable so methods called can requeue themselves w/o putting
		// us in an infinite loop
		var __methodTable:Array = methodTable;
		// new doLater calls will be pushed here
		methodTable = new Array();

		// now do everything else
		if (__methodTable.length > 0)
		{
			var m:Object;
			while((m = __methodTable.shift()) != undefined)
			{
				m.obj[m.fn]();
			}
		}
	}


/**
* mark component so it will get drawn later
* @tiptext Marks an object to be redrawn on the next frame interval
* @helpid 3966
*/
	function invalidate(Void):Void
	{
		invalidateFlag = true;
		onEnterFrame = doLaterDispatcher;
	}


/**
* redraws object if you couldn't wait for invalidation to do it
*
* @param bAlways	if False, doesn't redraw if not invalidated
* @tiptext Redraws an object immediately
* @helpid 3971
*/
	function redraw(bAlways:Boolean):Void
	{
		if (invalidateFlag || bAlways)
		{
			invalidateFlag = false;
			draw();
			dispatchEvent({ type:"draw"});
		}
	}

/**
* @private
* draw the object.  Called by redraw() which is called explicitly or
* by the system if the object is invalidated.
* Each component should implement this method and make subobjects visible and lay them out.
* Most components do the layout by calling their size() method.
*/
	function draw(Void):Void
	{
	}

/**
* move the object
*
* @param	x	left position of the object
* @param	y	top position of the object
* @param	noEvent	if true, doesn't broadcast "move" event
*
* @tiptext Moves the object to the specified location
* @helpid 3970
*/
	function move(x:Number, y:Number, noEvent:Boolean):Void
	{
		var oldX:Number = _x;
	  	var oldY:Number = _y;

		_x = x;
		_y = y;
		trace("component moved");
		if (noEvent != true)
		{
			dispatchEvent({type:"move", oldX:oldX, oldY:oldY});
		}
	}

/**
* size the object
*
* @param	w	width of the object
* @param	h	height of the object
* @param	noEvent	if true, doesn't broadcast "resize" event
*
* @tiptext Resizes the object to the specified size
* @helpid 3976
*/
	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		var oldWidth:Number = __width;
	  	var oldHeight:Number = __height;

		__width = w;
		__height = h;

		if (noEvent != true)
		{
			dispatchEvent({type:"resize", oldWidth:oldWidth, oldHeight:oldHeight});
		}
	}
	

}
