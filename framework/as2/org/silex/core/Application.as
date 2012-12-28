/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * This class represents an application. It has the top level functions such as start, saveSection, openSection, ...
 * Handle the loading process of the app.
 * In the repository : /trunk/core/Application.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-25
 * @mail : lex@silex.tv
 */


import org.silex.adminApi.util.T;
import org.silex.core.ApplicationHooks;
import org.silex.core.Constants;
import org.silex.core.Layout;
import org.silex.core.LibraryLoader;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
import org.silex.link.HaxeLink;
import org.silex.ui.Layer;
import org.silex.ui.UiBase;
import org.silex.ui.menu.ContextMenuItemWithKeyboardShortcut;
import org.silex.util.EventDispatcherBase;

[Event("configLoaded")]
[Event("preloadDone")]
[Event("layoutLoaded")]
[Event("playersLoaded")] // thrown by org.silex.ui.Layer and get by org.silex.core.Deeplink and toolbox.Players
[Event("allPlayersLoaded")] // thrown by org.silex.ui.Layer 
[Event("saved")]
[Event("unsaved")]
[Event("resize")]
[Event("onBgPress")]
[Event("onBgRelease")]
[Event("openSection")] // sectionName, layoutFileName, target(i.e. Layout), deeplinkName

[Event("saveLayoutDone")] //just for silex admin api. saved and unsaved should disappear
[Event("layoutAdded")]
[Event("layoutRemoved")]


class org.silex.core.Application extends EventDispatcherBase{
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * Used to store the stage position and size in _root coordinate system.
	 * Propeties: top,left,right,bottom.
	 */
	var stageRect:Object;
	/**
	 * Used to store the display region position and size in _root coordinate system.
	 * Propeties: top,left,right,bottom.
	 */
	var sceneRect:Object;
	
	/**
	 * Background clip.
	 */
	var bg_mc:MovieClip;
	
	/**
	 * Array of swf names.
	 * Each swf file should contain one font and will be loaded at start.
	 */
	var embeddedFonts:Array;
	
	//////////////////////////////////////
	// Group: layouts
	//////////////////////////////////////
	/**
	 * Layout loader.
	 * Used to unload layouts (in org.silex.core.Layout) and to monitor loading.
	 */
	public var layout_mcl:MovieClipLoader;
	/**
	 * Listener object for the layout loader.
	 */
	var layoutListener:Object;
	/**
	 * Container for the first layout of the website.
	 */
	var layoutContainer:MovieClip;
	
	/**
	 * Layouts array: contains references to the layouts.
	 */
	var layouts:Array;
	
	/**
	 * Index of the interval used for the screen saver (setInterval ActionScript function).
	 */
	var screenSaverIntervalIdx:Number=-1;
	/**
	 * mouse listener for the screen saver activity detection
	 */
	var screenSaverMouseListener:Object;
	
	/**
	 * preloads clips. Use for fonts, and for making sure a resource is available in the navigator cache before showing the publication
	 * */
	var _libraryLoader:LibraryLoader;
	
	//////////////////////////////////////
	// Group: screen saver modes
	//////////////////////////////////////
	static var SCREEN_SAVER_MODE_ON:String="SCREEN_SAVER_MODE_ON";
	static var SCREEN_SAVER_MODE_OFF:String="SCREEN_SAVER_MODE_OFF";
	static var SCREEN_SAVER_MODE_ACTIVE:String = "SCREEN_SAVER_MODE_ACTIVE";
	/**
	 * screen saver current mode
	 */
	var screenSaverMode:String=SCREEN_SAVER_MODE_OFF;
	
	/**
	 * Constructor.
	 * Initialize context menu to display the about item.
	 */
	function Application(api:org.silex.core.Api){
		
		// store Api reference
		silex_ptr=api;
		
		// if bg_mc does not already exist
		// in the swf, create it
		if (silex_ptr.parent.bg_mc == undefined)
		{
			initBackgroundMC();
		}
		else
		{
			bg_mc = silex_ptr.parent.bg_mc;
		}
		bg_mc.useHandCursor = false;
		//add click listeners
		bg_mc.onPress=Utils.createDelegate(this,bgPress);
		bg_mc.onRelease = Utils.createDelegate(this, bgRelease);
		
		
		// **
		// init layout loading
		//
		//container for the first layout and section
		layoutContainer=silex_ptr.parent.createEmptyMovieClip("layoutContainer",silex_ptr.parent.getNextHighestDepth());
		
		// listener for mcl
		layoutListener=new Object;
		layoutListener.onLoadError=Utils.createDelegate(this,layoutLoadedError);
		layoutListener.onLoadComplete=Utils.createDelegate(this,layoutLoadedComplete);
		layoutListener.onLoadStart = Utils.createDelegate(this, layoutStartedLoad);
		// in the layout		layoutListener.onLoadInit=Utils.createDelegate(this,layoutLoadedInit);
		
		// layout loader
		layout_mcl=new MovieClipLoader;
		layout_mcl.addListener(layoutListener);
	}
	
	/**
	 * Create the background movie clip
	 */
	private function initBackgroundMC():Void
	{
		//create background clip
		bg_mc = silex_ptr.parent.createEmptyMovieClip("backgroundMc", silex_ptr.parent.getNextHighestDepth());
		
		//draw it to make it clickable
		bg_mc.beginFill(0xFFFFFF, 0);
		bg_mc.moveTo(0, 0);
		bg_mc.lineTo(10, 0);
		bg_mc.lineTo(10, 10);
		bg_mc.lineTo(0, 10)
		bg_mc.lineTo(0, 0);
		bg_mc.endFill();
		
	}
	
	function layoutStartedLoad(target_mc : MovieClip)
	{
		layoutListener.target = target_mc;
	}
	//////////////////////////////////////
	// Group: background events
	//////////////////////////////////////
	function bgPress () {
		dispatchEvent({type:"onBgPress",target:this});
	}
	function bgRelease () {
		dispatchEvent({type:"onBgRelease",target:this});
	}
	
	function siteRefresh(){
		getURL("javascript:window.location.reload(false)");
	}
	function siteRefreshNoCache(){
		getURL("javascript:window.location.reload(true)");
	}
	/**
	 * Initialize context menu to display the about item.
	 */
	function initAfterConfigLoaded(){
		// get the language from user config
		if (silex_ptr.utils.isPartOf([System.capabilities.language],silex_ptr.config.AVAILABLE_LANGUAGE_LIST.split(","))){
			silex_ptr.config.language=System.capabilities.language;
		}
		else{
			if (silex_ptr.config.DEFAULT_LANGUAGE && silex_ptr.config.DEFAULT_LANGUAGE!=""){
				silex_ptr.config.language=silex_ptr.config.DEFAULT_LANGUAGE;
			}
		}
		// automatic language detection
		if (silex_ptr.config.ALLOW_AUTOMATIC_LANGUAGE_CHOICE!="false" && silex_ptr.utils.isPartOf([silex_ptr.config.language],silex_ptr.config.AVAILABLE_CONTEXT_LIST.split(",")))
		{
			if (!silex_ptr.config.globalContext)
				silex_ptr.config.globalContext = "";
			if (silex_ptr.config.globalContext != "")
				silex_ptr.config.globalContext += ",";
			silex_ptr.config.globalContext += silex_ptr.config.language;
		}
		
		// **
		// context menu
		// 
		if (!_root.menu) _root.menu=new ContextMenu();
		_root.menu.hideBuiltInItems();
		
		// about
		var aboutCaption_str:String=silex_ptr.utils.revealAccessors(silex_ptr.config.CONTEXT_MENU_ABOUT_CAPTION,silex_ptr.config);
		_root.menu.customItems.push(new ContextMenuItem(aboutCaption_str, Utils.createDelegate(this,aboutCallback)));
		
		// refresh
		var f5:Number = ContextMenuItemWithKeyboardShortcut.F5_ASCII;
		var caption:String = silex_ptr.config.CONTEXT_MENU_REFRESH_COMMAND;
		/*creates problems on mac. disable till we can get some multisystem tests		
		_root.menu.customItems.push(new ContextMenuItemWithKeyboardShortcut(caption, Utils.createDelegate(this,siteRefresh), f5, false));
		caption = silex_ptr.config.CONTEXT_MENU_REFRESH_NO_CACHE_COMMAND;
		_root.menu.customItems.push(new ContextMenuItemWithKeyboardShortcut(caption, Utils.createDelegate(this,siteRefreshNoCache), f5, true));
		*/		
		if (silex_ptr.config.ALLOW_LOGIN.toLowerCase()!="false"){
			// **
			// context menu
			// login/logout
			caption = silex_ptr.config.CONTEXT_MENU_LOGIN_CAPTION;
			_root.menu.customItems.push(new ContextMenuItemWithKeyboardShortcut(caption, Utils.createDelegate(this,loginCallback), "L", true));
			caption = silex_ptr.config.CONTEXT_MENU_LOGOUT_CAPTION;
			_root.menu.customItems.push(new ContextMenuItemWithKeyboardShortcut(caption, Utils.createDelegate(this,logoutCallback), "L", true));
			
			//flush logins 
			caption = silex_ptr.config.CONTEXT_MENU_FLUSH_LOGINS_CAPTION;
			_root.menu.customItems.push(new ContextMenuItem(caption, Utils.createDelegate(this,flushLoginsCallback)));
			
			//  auto login with autologin in get param
			if (silex_ptr.config.autologin == "1")
			{
				silex_ptr.sequencer.doInNFrames(100,Utils.createDelegate(this,loginCallback));
			}
			else if (silex_ptr.config.autologin != "0")
			{
				// **
				// auto login with cookie
				var storedLoginInfo = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME);
				if (storedLoginInfo.data.isLoggedIn == true)
				{
					// do not try to login if there is no record for this url
					if (getLoginInfoFromCookie())
						// login
						loginCallback();
				}
			}
		}
		refreshLoginMenuState();
		// **
		// stage, align and scale
		//
		// stage default values
		Stage.align="";
		Stage.scaleMode="noScale";
		
		// stage listener and resize
		var stageListener:Object = new Object();
		stageListener.onResize = Utils.createDelegate(this,stageResize);
		Stage.addListener(stageListener);
		// resize when a page has been opened (for Scroll mode)
		addEventListener("allPlayersLoaded", Utils.createDelegate(this, updateFlashStageSize));
		
		// scale mode
		setScaleMode(silex_ptr.config.scaleMode);
//		silex_ptr.config.scaleMode = silex_ptr.config.scaleMode.toLowerCase();
		
		// init the scene size
		stageResize();
		
		// **
		// bg color
		//
		if (silex_ptr.config.bgColor) setBgColor(silex_ptr.config.bgColor);
		
		// **
		// tracking
		//
		// google analytics
		/*		var trackerInit_str:String="";
		if (silex_ptr.config.googleAnaliticsAccountNumber!="")
		trackerInit_str+="silexJsObj.setTrackingCode('"+silex_ptr.config.googleAnaliticsAccountNumber+"');";
		if (silex_ptr.config.phpmyvisitesURL!="")
		trackerInit_str+="silexJsObj.setPhpmyvisites('"+silex_ptr.config.phpmyvisitesURL+"','"+silex_ptr.config.phpmyvisitesSiteNumber+"');";
		*/
		// tag current section
		//		trackerInit_str+="silexJsObj.tagCurrentSection();";
		// call javascript
		//		silex_ptr.com.jsCall(trackerInit_str);
		
		
		//  **
		// screen saver
		screenSaverInit();
		
		// **
		// mouse pointer
		silex_ptr.constants.mouse=(silex_ptr.config.mouse!="false");
		
		//fonts
		registerFonts();
		
	}
	////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: size of the flash object
	////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * pass the size and the resize mode of the publication to javascript<br />
	 * @param	newScaleMode	String, can be "noScale", "showAll", "scroll", "pixel", "noscale", "showall"
	 */
	function setScaleMode(newScaleMode:String)
	{
//		function setScaleMode(newScaleMode/*:String*/, newSiteWidth/*:Int*/, newSiteHeight/*:Int*/, flashStageWidth/*:Int*/, flashStageHeight/*:Int*/)

		// dispatch to javascript
		if (silex_ptr.config.ENABLE_DEEPLINKING!="false")
		{
			// build the call
			var jsCommand_str:String='silexNS.SilexApi.setScaleMode("'
					+newScaleMode+'",'
					+silex_ptr.config.layoutStageWidth+','
					+silex_ptr.config.layoutStageHeight+','
					+Stage.width+','
					+Stage.height+');';
		
			// call javascript
			silex_ptr.com.jsCall(jsCommand_str);
		}
	}
	/**
	 * pass the size of the Stage to javascript<br />
	 * pass the sceneRect to javascript<br />
	 */
	function updateFlashStageSize()
	{
		silex_ptr.sequencer.addItem(null,Utils.createDelegate(this,doUpdateFlashStageSize));
	}
	/**
	 * pass the size of the Stage to javascript<br />
	 * pass the sceneRect to javascript<br />
	 */
	function doUpdateFlashStageSize()
	{
		Utils.removeDelegate(this,doUpdateFlashStageSize);
		
		//	function updateFlashStageSize(flashStageWidth/*:Int*/, flashStageHeight/*:Int*/)
		// dispatch to javascript
		if (silex_ptr.config.ENABLE_DEEPLINKING!="false" && silex_ptr.config.scaleMode == "scroll")
		{
			// retrieve content size
			var contentSize:Object/*<width:Number><height:Number>*/ = getContentSize();
			
			// minimum value = config size
			var sceneWidth:Number = parseInt(silex_ptr.config.layoutStageWidth);
			if (contentSize.width < sceneWidth)
				contentSize.width = sceneWidth;
				
			var sceneHeight:Number = parseInt(silex_ptr.config.layoutStageHeight);
			if (contentSize.height < sceneHeight)
				contentSize.height = sceneHeight;
				
			
			// build the call
			var jsCommand_str:String='silexNS.SilexApi.updateFlashStageSize('
					+contentSize.width+','
					+contentSize.height+');';
		
			// call javascript
			silex_ptr.com.jsCall(jsCommand_str);
		}
		
	}
	/*
		case html w/h > flash w/h
		
						noScale				showAll				scroll				pixel
		html w/h		100% avail space	100% avail space	page h, 100% w		100% avail space
		flash w/h		scale 100%			100% avail space	scale 100%			scale 100%
		
		
		case html w/h < flash w/h
		
						noScale				showAll				scroll				pixel
		html w/h		page h/w			100% avail space	page h, site w		100% avail space
		flash w/h		scale 100%			100% avail space	scale 100%			100% avail space
	*/
	/**
	 * compute sceneRect in function of the scaleMode<br />
	 */
	function stageResize() 
	{
		// **
		// compute stage position and height in _root coordinate system
		// 
		stageRect=new Object;
		
		// X axis
		var stageCenterX:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_X); // silex.fla stage size
		var stageHalfWidth=Stage.width/2;
		stageRect.left=stageCenterX-stageHalfWidth;
		stageRect.right=stageCenterX+stageHalfWidth;
		
		// Y axis
		var stageCenterY:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_Y);
		var stageHalfHeight=Stage.height/2;
		stageRect.top=stageCenterY-stageHalfHeight;
		stageRect.bottom=stageCenterY+stageHalfHeight;
		
		// **
		// position of background and tools
		// 
		bg_mc._x=stageRect.left;
		bg_mc._width=Stage.width;
		bg_mc._y=stageRect.top;
		bg_mc._height=Stage.height;

		// **
		// scale mode case
		//
		switch(silex_ptr.config.scaleMode)
		{
			case "scroll":
				scaleNoScale(true,false);
				break;
			case "noScale":
			case "noscale":
				// get params from config
				var centerHorizontally:Boolean = (silex_ptr.config.centerHorizontally!="false" && silex_ptr.config.centerHorizontally!=false);
				var centerVertically:Boolean = (silex_ptr.config.centerVertically!="false" && silex_ptr.config.centerVertically!=false);
				// apply no scale
				scaleNoScale(centerHorizontally,centerVertically);
				break;
			case "pixel":
				scalePixel();
				break;
			case "showAll":
			case "showall":
				scaleShowAll();
				break;
		}
		// dispatchEvent
		dispatchEvent( { type:"resize", target:this } );
	}
	/**
	 * compute the content size<br />
	 * get the maximum height and width of all opened pages
	 * @return 	an object with "width" and "height" properties set
	 */
	function getContentSize() {
		var maxHeight:Number = silex_ptr.config.layoutStageHeight;
		var maxWidth:Number = silex_ptr.config.layoutStageWidth;
		// browse all layouts
		for (var idxLayout:Number = 0; idxLayout < layouts.length; idxLayout++) {
			var layout:Layout = layouts[idxLayout];
			// browse all layers
			for (var idxLayer:Number = 0; idxLayer < layout.layers.length; idxLayer++) {
				var layer:Layer = layout.layers[idxLayer];
				// browse all players
				for (var idxPlayer:Number = 0; idxPlayer < layer.players.length; idxPlayer++) {
					var playerInfo:Object = layer.players[idxPlayer];
					var player:UiBase = layer[layer.players[idxPlayer]._name].main;
					var playerBottom:Number = player.height + player._y;
					if (maxHeight < playerBottom){
						maxHeight = playerBottom;
					}
					var playerRight:Number = player.width + player._x;
					if (maxWidth < playerRight){
						maxWidth = playerRight;
					}
				}
			}
		}
		return {width:maxWidth, height:maxHeight};
	}
	/**
	 * reset js frame size (set the div size to 100%, since the flash object is 100% of the div)<br />
	 * used by org.silex.adminApi.PublicationModel
	 */
	function resetSilexWindowSize()
	{
		// dispatch to javascript
		var jsCommand_str:String='adjustSilexWindowSize(5,5,true,'+Stage.width+','+Stage.height+');';
		
		// call javascript
		if (silex_ptr.config.ENABLE_DEEPLINKING!="false")
			silex_ptr.com.jsCall(jsCommand_str);
	}
	function scalePixel()
	{
		
		// get scene size from config
		var sceneWidth:Number = parseInt(silex_ptr.config.layoutStageWidth);
		var sceneHeight:Number = parseInt(silex_ptr.config.layoutStageHeight);
		
		// compute scale to apply to the scene
		var sceneScaleX:Number=Stage.width/sceneWidth;
		var sceneScaleY:Number=Stage.height/sceneHeight;
		
		// apply scale
		var sceneScaleFactor:Number=Math.round(100*(Math.min(sceneScaleX,sceneScaleY)));
		
		if (sceneScaleFactor>100)
			scaleNoScale(true,true);
		else
			scaleShowAll();
	}
	/**
	 * Center layouts and content <=> compute offset to apply to the scene.
	 * layoutStageWidth and layoutStageHeight are read in config file
	 */
	function scaleShowAll() {
		
		// get scene size from config
		var sceneWidth:Number = parseInt(silex_ptr.config.layoutStageWidth);
		var sceneHeight:Number = parseInt(silex_ptr.config.layoutStageHeight);
		
		// compute scale to apply to the scene
		var sceneScaleX:Number=Stage.width/sceneWidth;
		var sceneScaleY:Number=Stage.height/sceneHeight;
		
		// apply scale
		var sceneScaleFactor:Number=Math.round(100*(Math.min(sceneScaleX,sceneScaleY)));
		layoutContainer._xscale=layoutContainer._yscale=sceneScaleFactor;
		
		// center
		var newSceneWidth=sceneWidth*sceneScaleFactor/100;
		var newSceneHeight=sceneHeight*sceneScaleFactor/100;
		var sceneCenterX:Number=newSceneWidth/2;
		var sceneCenterY:Number=newSceneHeight/2;
		var stageCenterX:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_X);
		var stageCenterY:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_Y);
		
		var offsetX:Number=stageCenterX-sceneCenterX;
		var offsetY:Number=stageCenterY-sceneCenterY;
		
		layoutContainer._x=offsetX;
		layoutContainer._y=offsetY;
		
		// **
		// compute sceneRect
		// 
		sceneRect=new Object;
		sceneRect.left=offsetX;
		sceneRect.top=offsetY;
		sceneRect.right=offsetX + newSceneWidth;
		sceneRect.bottom=offsetY + newSceneHeight;
		
	}
	/**
	 * Center layouts and content <=> compute offset to apply to the scene.
	 * layoutStageWidth and layoutStageHeight are read in config file, default is 800x600.
	 */
	function scaleNoScale(centerHorizontally:Boolean, centerVertically:Boolean) {
		
		// reset scales
		layoutContainer._xscale = layoutContainer._yscale = 100;

		// get scene size from config
		var sceneWidth:Number = parseInt(silex_ptr.config.layoutStageWidth);
		var sceneHeight:Number = parseInt(silex_ptr.config.layoutStageHeight);
		
		// compute sceneRect
		sceneRect = new Object;
		if (centerHorizontally == true)
		{
			// sceneCenter - stageCenter = offset vector (offset to apply to the scene)
			var sceneCenterX:Number=Math.round(sceneWidth/2);
			var stageCenterX:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_X);
			var offsetX= stageCenterX - sceneCenterX;
	
			// align center
			sceneRect.left = offsetX;
			sceneRect.right = sceneRect.left + sceneWidth;
		}
		else
		{
			// align left
			sceneRect.left = stageRect.left;
			sceneRect.right = sceneRect.left + sceneWidth;
		}
		if (centerVertically == true)
		{
			// sceneCenter - stageCenter = offset vector (offset to apply to the scene)
			var sceneCenterY:Number=Math.round(sceneHeight/2);
			var stageCenterY:Number=parseInt(silex_ptr.config.LOADER_STAGE_HALF_SIZE_Y);
			var offsetY=stageCenterY-sceneCenterY;

			// center
			sceneRect.top = offsetY;
			sceneRect.bottom = sceneRect.top + sceneHeight;
		}
		else
		{
			sceneRect.top = stageRect.top;
			sceneRect.bottom = sceneRect.top + sceneHeight;
			// align top
		}
		
		
		// update container position
		layoutContainer._x = sceneRect.left;
		layoutContainer._y = sceneRect.top;
	}
	/**
	 * Change bg_mc color.
	 * @param	color_str	the color to apply
	 * @example	FFFFFF for white
	 */
	function setBgColor(color_str:String){
		var _color:Color=new Color(bg_mc);
		_color.setRGB(parseInt(color_str,16));
		
		// change html page color
		//silex_ptr.com.jsCall("void(document.bgColor='#"+color_str+"')");
	}
	/**
	 * Callback function executed when the user select "about SILEX" in the context menu.
	 * Execute the command CONTEXT_MENU_ABOUT_COMMAND read in the config files
	 */
	function aboutCallback(){
		silex_ptr.interpreter.exec(silex_ptr.config.CONTEXT_MENU_ABOUT_COMMAND);
	}
	/**
	 * Build the context menu for SILEX.
	 * Login, logout and about menus.
	 */
	function refreshLoginMenuState(){
		var isLoggedIn:Boolean = silex_ptr.authentication.isLoggedIn();
		
		var storedLoginInfo = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME);
		var enableFlushLogins:Boolean = false;
		if(storedLoginInfo.data.loginArray != null){
			enableFlushLogins = true;
		}
		
		var len = _root.menu.customItems.length;
		for(var i = 0; i < len; i++){
			var item = _root.menu.customItems[i];
			if(item.caption.indexOf("login ") != -1) //the " " is important because otherwise we catch "flush logins"
				item.enabled = !isLoggedIn;
			if(item.caption.indexOf("logout") != -1)
				item.enabled = isLoggedIn;
			if(item.caption.indexOf("flush logins") != -1)
				item.enabled = enableFlushLogins;
		}
	}
	/**
	 * Callback function executed when the user select "login" in the context menu.
	 * Check if the user has  a login + password stored in the cookie and eventually open a login dialog.
	 * @see	org.silex.core.Utils::promptPassword
	 */
	function loginCallback(){
		//look for stored password and login in the cookie if no info is passed directly 
		var info:Object = getLoginInfoFromCookie();
		//look in the cookie set by the manager
		if (info == undefined)
			info = getManagerLoginInfoFromCookie();
		//look in the flashvars or config
		if (info == undefined && silex_ptr.config.login_str != undefined && silex_ptr.config.pass_str != undefined)
			info = silex_ptr.config;
		// use the object with pasword and login properties, or prompt for login and password
		if (info == undefined)
		{
			silex_ptr.utils.promptPassword(silex_ptr.config.PROMPT_LOGIN_PASS,Utils.createDelegate(this,promptPasswordCallback));
		}
		else
			silex_ptr.authentication.login(info.login_str, info.pass_str,Utils.createDelegate(this,authenticationCallback));
	}
	/**
	 * retrieve login info from cookie
	 * @return	an object with the properties url, login_str and pass_str
	 */
	function getLoginInfoFromCookie():Object
	{
		var storedLoginInfo:SharedObject = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME);
		if(storedLoginInfo.data.loginArray){
			for(var i = 0; i < storedLoginInfo.data.loginArray.length; i++){		
				var info = storedLoginInfo.data.loginArray[i];
				if(info.url == _level0._url){
					return info;
				}
			}
		}
		return undefined;
	}
	/**
	 * retrieve login info from the cookie set by the manager
	 * @return	an object with the properties url, login_str and pass_str
	 */
	function getManagerLoginInfoFromCookie():Object
	{
		var storedLoginInfo:SharedObject = SharedObject.getLocal(silex_ptr.config.MANAGER_SHARED_OBJECT_NAME, "/");
		//_root.getURL("http://google.com/?q="+storedLoginInfo.data + " - " + storedLoginInfo.data.userdata + " - " + storedLoginInfo.data.lastSavedDate, "_blank");
		if (storedLoginInfo && storedLoginInfo.data && storedLoginInfo.data.userdata && storedLoginInfo.data.userdata.login)
		{
			return storedLoginInfo.data.userdata;
		}
		return undefined;
	}
	/**
	 * Callback function executed when the user select "flush login" in the context menu.
	 */
	function flushLoginsCallback() {
		var storedLoginInfo:SharedObject = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME);
		//		var _str:String = "x---x";
		/*		for (var prop:String in storedLoginInfo.data)
		{
		storedLoginInfo.data[prop] = undefined;
		//			_str += prop + "-";
		}
		//		_root.getURL(_str, "_blank");
		//		storedLoginInfo.data.loginArray = null;
		//		storedLoginInfo.data.toolsPostionsArray = new Array;
		//		storedLoginInfo.data = new Object;
		storedLoginInfo.flush();
		*/		storedLoginInfo.clear();
		storedLoginInfo.flush();
		refreshLoginMenuState();
		
		if (silex_ptr.authentication.isLoggedIn)
		{
			storedLoginInfo = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME+"-"+silex_ptr.authentication.currentLogin);
			storedLoginInfo.clear();
			storedLoginInfo.flush();
		}
	}
	/**
	 * Callback function executed when the user select "login" in the context menu and do not have a login + password stored in the cookie.<br />
	 * Called by the promptPassword dialog function opened by the loginCallback function.<br />
	 * @see	org.silex.core.Application::loginCallback
	 * @see	org.silex.core.Utils::promptPassword
	 * @param	login_str	the user login
	 * @param	pass_str	the user password
	 */
	function promptPasswordCallback(login_str,pass_str) {
		silex_ptr.authentication.login(login_str,pass_str,Utils.createDelegate(this,authenticationCallback));
		// display message
		silex_ptr.utils.alertSimple(silex_ptr.utils.revealAccessors(silex_ptr.config.MESSAGE_PLEASE_WAIT_WHILE_CHECKING_LOGIN_PASS,{login:login_str,pass:pass_str}),1500);
	}
	/**
	 * Callback function executed when the result of the authentication is arrived.<br />
	 * dispatch event / hook for the wysiwyg : wysiwygLoginSuccess - with the "login" attribute set to the user name<br />
	 * @param	success	the state of the authentication. true if it succeded and false otherwise.
	 */
	function authenticationCallback(success:Boolean) {
		//silex_ptr.toolsManager.showToolboxes(success);
		silex_ptr.config.globalContext = silex_ptr.config.AVAILABLE_CONTEXT_LIST;
		refreshLoginMenuState();
		if (success)
		{
			// dispatch event / hook for the wysiwyg
			dispatchEvent( { type:"wysiwygLoginSuccess", target:this } );
			silex_ptr.com.silexOnStatus({ type:"wysiwygLoginSuccess",login:silex_ptr.authentication.currentLogin});
		}
	}
	/**
	 * Callback function executed when the user select "logout" in the context menu.<br />
	 */
	function logoutCallback(){
		silex_ptr.authentication.logout();
		//silex_ptr.toolsManager.showToolboxes(false);
		//setEditable(false)  for each player
		for (var idxLayout:Number=0;idxLayout<layouts.length;idxLayout++){
			for (var idxLayer:Number=0;idxLayer<layouts[idxLayout].layers.length;idxLayer++)
				layouts[idxLayout].layers[idxLayer].setEditable(false);
		}
	}
	
	/**
	 * Start the loading process.<br />
	 * Call com.getDynData.<br />
	 * All _root properties of type number or string are considered as params passed to Flash by javascript.<br />
	 */
	function start() {
		
		// layouts array
		layouts=new Array;
		
		// bgColor
		silex_ptr.parent.bgColor_mc._visible=false;
		
		// store all strings and numbers into the websitInfo object
		var websiteInfo:Object=new Object;
		for (var propName_str:String in _root){
			// is it of type number or string
			if (typeof(_root[propName_str])=="string" || typeof(_root[propName_str])=="number"){
				websiteInfo[propName_str]=_root[propName_str];
			}
		}
		
		// get the admin language from website config
		silex_ptr.config.adminLanguage = silex_ptr.config.SILEX_ADMIN_DEFAULT_LANGUAGE
		
		// extract files list
		// remove blank spaces before and after ","
		_root.config_files_list=silex_ptr.utils.replace(_root.config_files_list,", ",",");
		_root.config_files_list=silex_ptr.utils.replace(_root.config_files_list," ,",",");
		// split the list
		var filesList:Array;
		
		// init conf files list
		if (_root.config_files_list && _root.config_files_list!="")
			filesList = _root.config_files_list.split(",");
		else
			filesList = new Array;
		
		// adds language file
		if (_root.forceLanguageFile)
		{
			if (_root.forceLanguageFile != "" && _root.forceLanguageFile != "none")
			{
				// add the desired language file
				filesList.push(_root.forceLanguageFile);
			}
			else
			{
				// do not add any language file (cd-r case)
			}
		}
		else
		{
			// add the appropriate language file
			filesList.push(silex_ptr.utils.revealAccessors(silex_ptr.config.languageConfigFileName,silex_ptr.config));
		}
		
		
		
		/*
		// insert website conf file
		if (filesList.toString().indexOf(silex_ptr.constants.initialContentFolderPath+websiteInfo.id_site+"/"+silex_ptr.constants.CONFIG_WEBSITE_CONF_FILE)==-1){
		filesList.push(silex_ptr.constants.initialContentFolderPath+websiteInfo.id_site+"/"+silex_ptr.constants.CONFIG_WEBSITE_CONF_FILE);
		}
		*/
		
		// call getDynData to load config files
		silex_ptr.com.getDynData(websiteInfo,filesList,Utils.createDelegate(this,dynDataLoaded));
	}
	/**
	 * Override constants and config variables.
	 * Init the Constant class with these constants.
	 * Continue the loading process (preload files).
	 */
	function dynDataLoaded(result:Array) {
		var isConfFileFound:Boolean=false;
		
		if (result)
		{
			// **
			// overrides constants and config
			// 
			isConfFileFound=overrideConfig(result);
			// if config file is not found
			// - if we are in widget mode, the config was loaded from widget.php
			// - otherwise the website does not exist => refresh for the php to handle the 404 page
			//			if (isConfFileFound == false && silex_ptr.config.widgetMode != "true")
			if (isConfFileFound == false)
			{
				// call getDynData to load config files
				openWebsite(silex_ptr.config.id_site);
				/*				if (layouts[0])
				layouts[0].close();
				silex_ptr.sequencer.addItem(null,Utils.createDelegate(this,siteRefresh));
				*/
				// -------------------
				return;
				// -------------------
				
				// This website does not exist yet
				var _mc:MovieClip = this.silex_ptr.utils.alert(silex_ptr.utils.revealAccessors(silex_ptr.config.MESSAGE_WEBSITE_DOES_NOT_EXIST, silex_ptr.config));
				
				// put window in 0,0 since the size of the scene is about to be changed (in function of the data read in conf files)
				_mc._x=_mc._y=0;
			}
			// **
			// init app
			// after config has been loaded
			//silex_ptr.sequencer.doInNFrames(20,Utils.createDelegate(this,initAfterConfigLoaded));
			initAfterConfigLoaded();
			
			// dispatch event
			dispatchEvent({type:"configLoaded",target:this});
			preload();
		}
		else{
			silex_ptr.utils.alert("error loading conf files ("+result.toString()+")");
		}
	}
	
	/**
	 * with layer skins fonts registered themselves. Here the font list is available on the silex config.
	 * TODO sort this out once layer_skins are completely deprecated
	 * */
	private function registerFonts():Void{
		var fontNames:Array = silex_ptr.config.FONTS_LIST.split("@");
		for(var i:Number = 0; i < fontNames.length; i++){
			registerEmbeddedFont(fontNames[i]);
		}
		
	}
	/**
	 * starts the preload of the files defined in the publication's PRELOAD_FILES_LIST
	 * asynchronous
	 * */
	private function preload(){
		// call hooks
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(ApplicationHooks.PRELOAD_START_HOOK_UID, arguments);
		
		// fill the the preloadFilesList array
		var preloadFilesListLocal:Array;
		if (silex_ptr.config.preload_files_list && silex_ptr.config.preload_files_list != ""){
			// remove blank spaces before and after ","
			silex_ptr.config.preload_files_list=silex_ptr.utils.replace(silex_ptr.config.preload_files_list,", ",",");
			silex_ptr.config.preload_files_list=silex_ptr.utils.replace(silex_ptr.config.preload_files_list," ,",",");
			silex_ptr.config.preload_files_list=silex_ptr.utils.replace(silex_ptr.config.preload_files_list,"\r",",");
			// split the list
			preloadFilesListLocal = silex_ptr.config.preload_files_list.split(",");
			var numPreloadFiles:Number = preloadFilesListLocal.length;
			//add root url 
			for(var i:Number = 0; i < numPreloadFiles; i++){
				preloadFilesListLocal[i] = silex_ptr.rootUrl + preloadFilesListLocal[i]; 
			}
			_libraryLoader = new LibraryLoader(preloadFilesListLocal, silex_ptr.sequencer);
			_libraryLoader.addEventListener(LibraryLoader.EVENT_LIBRARY_LOAD_DONE, Utils.createDelegate(this, preloadFilesDone));
			_libraryLoader.start();
		}
	}
	/** 
	 * Override constants and config variables.
	 */
	function overrideConfig(result:Array):Boolean{
		var isConfFileFound:Boolean=false;
		// enumarate each file
		for (var idx:Number=0;idx<result.length;idx++){
			// enumarate each line of the file
			for (var line_num:Number=0;line_num<result[idx].length;line_num++){
				// if there is a variable and its value and no ";" as first char
				if (result[idx][line_num].charAt(0)!=";" && result[idx][line_num].indexOf("=",1)>0){
					var _lv:LoadVars=new LoadVars;
					_lv.onData(result[idx][line_num]);
					
					// copy each variable into config object
					for (var propName_str:String in _lv){
						if (propName_str!="" && propName_str!="\n" && propName_str!="\r" && propName_str!="loaded"){
							silex_ptr.config[propName_str]=_lv[propName_str];
							
							if (propName_str=="layerSkinUrl"){
								// if the conf.txt file was loaded, then layerSkinUrl is set (at least)
								isConfFileFound=true;
							}
						}
					}
				}
			}				
		}
		return isConfFileFound;
	}

	/**
	 * Callback executed when all files have been loadded, with errors or not.
	 * call hooks<br />
	 */
	function preloadFilesDone() {
		
		// call hooks
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(ApplicationHooks.PRELOAD_END_HOOK_UID, arguments);
		
		// dispatch event
		dispatchEvent( { type:"preloadDone", target:this } );
		this.silex_ptr.com.silexOnStatus( { type:"preloadDone" } );
		
		// open the CONFIG_START_SECTION xml file in the initialLaytouFile layout file
		openSection(silex_ptr.config.CONFIG_START_SECTION,silex_ptr.config.initialLayoutFile,null,silex_ptr.config.CONFIG_START_SECTION);
		
		// initialize deeplinks
		//		if (silex_ptr.config.initialPath)
		//			silex_ptr.deeplink.currentPath=silex_ptr.config.initialPath;
	}
	/** 
	 * Close current website and open an other website on the same server.
	 */
	function openWebsite(idsite:String){
		if (layouts[0])
			layouts[0].close();
		/*silex_ptr.config.id_site=*///_root.id_site=idsite;
		/*		silex_ptr.deeplink.changeWebsite(idsite);
		silex_ptr.sequencer.addItem(null,Utils.createDelegate(this,siteRefresh));*/
		getURL("javascript:window.location="+silex_ptr.rootUrl+"?/"+idsite);
	}
	/**
	 * Start the loading process of a section.<br />
	 * call hooks, use silex_ptr.utils.cleanID(event.hookData[0]) in the hooks in order to retrieve the XML page name<br />
	 * @param sectionName_str	section name that will give us the name of the xml file containing the data
	 * @param layoutFile		layout swf file (does not contain the path to the layout folder of the website)
	 * @param targetLayout		org.silex.core.Layout object in which to open the section (load the layout)
	 * @return					true if the section loading could be started
	 */
	function openSection(sectionName_str:String,layoutFileName_str:String,targetLayout:org.silex.core.Layout,deeplinkName:String):Boolean{
		// call hooks
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(ApplicationHooks.OPENSECTION_START_HOOK_UID, arguments);
		
		
		// check inputs
		if (!arguments[0] || !sectionName_str || !layoutFileName_str || !deeplinkName || sectionName_str=="" || layoutFileName_str==""){
			return false;
		}
		
		// build the layout file name
		var layoutFileUrl_str:String=silex_ptr.config.layoutFolderPath+layoutFileName_str;
		
		// store section name in the listener
		layoutListener.sectionName=sectionName_str;
		layoutListener.deeplinkName=silex_ptr.utils.cleanID(deeplinkName);
		layoutListener.layoutFileName=layoutFileName_str;
		
		// get the layer's container and load the next layout
		if (!targetLayout){
			// case of the first layout: open in the application layout container
			// hide  while loading
			//layoutContainer._visible=false;
			// start loading the layout
			layout_mcl.loadClip(silex_ptr.rootUrl+layoutFileUrl_str,layoutContainer);
		}
		else{
			var targetClip:MovieClip;
			// create a layout container if needed
			if (!targetLayout.layoutContainer) 
				targetLayout.layoutContainer = targetLayout._parent.createEmptyMovieClip("layoutContainer", targetLayout._parent.getNextHighestDepth());
			
			// use the layout's layout container 
			targetClip = targetLayout.layoutContainer;
			
			// close current child layout
			if (targetLayout.currentChildLayoutContainer)
			{
				// is the layout loaded or is it still loading?
				if (targetLayout.currentChildLayoutContainer.silexLayout)
				{
					if (!targetLayout.currentChildLayoutContainer.silexLayout.isContentVisible)
					{
						//silex_ptr.utils.alertSimple("content is not visible yet");
						return false;
					}
					if (!targetLayout.currentChildLayoutContainer.silexLayout.haveAllPlayersLoaded)
					{
						//silex_ptr.utils.alertSimple("players are still loading"); 
						// no because it would freez when a media is missing: return false;
					}
					//silex_ptr.utils.alertSimple("close now "+targetLayout.currentChildLayoutContainer.silexLayout.deeplinkName); 
					targetLayout.currentChildLayoutContainer.silexLayout.addEventListener(silex_ptr.config.LAYOUT_EVENT_HIDE_CONTENT,Utils.createDelegate(this, layoutReadyForUnload));
					targetLayout.currentChildLayoutContainer.silexLayout.close();
				}
				else
				{
					// could not open section because a layout is still loading
					//silex_ptr.utils.alertSimple("could not open section because a layout is still loading");
					return false;
				}
				// bug in the sequencer: layout_mcl.unloadClip(targetLayout.currentChildLayoutContainer);
			}
			else
			{
				// for the first child layout only
				
				// start transition
				silex_ptr.sequencer.addItem(targetLayout.anims[silex_ptr.config.ANIM_NAME_TRANSITION]);
				
				// event
				targetLayout.dispatchEvent({type:"showChild",deeplinkName:silex_ptr.utils.cleanID(deeplinkName),cleanSectionName:silex_ptr.utils.cleanID(sectionName_str),sectionName:sectionName_str,layoutFileName:layoutFileName_str,target:targetLayout});
			}
			
			// check if the new layout is the same layout swf file as the previous one
			// DO NOT WORK, PROBABLY BECAUSE LAYOUT WAS LOADED WITH A MOVIE CLIP LOADER
			/*			if (targetLayout.currentChildLayoutContainer.silexLayout.layoutFileName == layoutFileName_str)
			{
			silex_ptr.utils.alertSimple(targetLayout.currentChildLayoutContainer.silexLayout.toString());				
			// duplicate the container
			targetLayout.currentChildLayoutContainer=targetLayout.currentChildLayoutContainer.duplicateMovieClip(
			"layout"+(targetLayout.currentChildLayoutContainerIndex++).toString(),
			targetLayout.currentChildLayoutContainer.getNextHighestDepth());
			
			silex_ptr.utils.alertSimple(targetLayout.currentChildLayoutContainer.toString()
			+ " - "+"layout"+(targetLayout.currentChildLayoutContainerIndex).toString()
			+ " - "+"layout"+(targetLayout.currentChildLayoutContainerIndex).toString());
			
			targetLayout.currentChildLayoutContainer.silexLayout = undefined;
			
			layoutLoadedComplete(targetLayout.currentChildLayoutContainer);
			//silex_ptr.sequencer.doInNFrames(10,layoutListener.onLoadComplete,targetLayout.currentChildLayoutContainer);
			}
			else
			*/			{
				// create a new container
				targetLayout.currentChildLayoutContainer=targetClip.createEmptyMovieClip("layout"+targetLayout.currentChildLayoutContainerIndex++,targetClip.getNextHighestDepth());
				// hide  while loading
				//targetLayout.currentChildLayoutContainer._visible=false;
				
				// start loading the layout
				layout_mcl.loadClip(silex_ptr.rootUrl+layoutFileUrl_str,targetLayout.currentChildLayoutContainer);
			}
		}
		// event
		dispatchEvent({type:"openSection", sectionName:sectionName_str, deeplinkName:silex_ptr.utils.cleanID(deeplinkName),cleanSectionName:silex_ptr.utils.cleanID(sectionName_str),layoutFileName:layoutFileName_str,target:targetLayout});
		//targetLayout.dispatchEvent({type:"showChild",sectionName:sectionName_str,layoutFileName:layoutFileName_str,target:targetLayout});
		
		// 
		hookManager.callHooks(ApplicationHooks.OPENSECTION_END_HOOK_UID, null);
		
		
		// 
		return true;
	}
	/**
	 * Callback/listener called when the layout dispatch a "hideContent"
	 * @param 
	 */
	function layoutReadyForUnload(event:Object)
	{
		event.target.removeEventListener(silex_ptr.config.LAYOUT_EVENT_HIDE_CONTENT,Utils.removeDelegate(this, layoutReadyForUnload));
		layout_mcl.unloadClip(event.target._parent);
	}
	/**
	 * Called by layout_mcl when a layout is not loaded correctly.
	 * handle error
	 * @param target_mc		movie clip in which the section (the layout) was supposed to be loaded
	 * @param errorCode		A string that explains the reason for the failure, either "URLNotFound" or "LoadNeverCompleted".
	 */
	function layoutLoadedError(target_mc:MovieClip, errorCode:String){
		// handle error
		silex_ptr.utils.alert(silex_ptr.utils.revealAccessors(silex_ptr.config.ERROR_LOADING_LAYOUT,{layoutFileName:layoutListener.layoutFileName,error:errorCode}));
		
		// ?? to remove ??
		// layoutLoadedComplete(target_mc);
		// layoutLoadedInit(target_mc);
	}
	/**
	 * Called by layout_mcl when a layout is loaded BEFORE 1st frame.
	 * create silexLayout object at the root of this layout and starts the xml loading process
	 * @param target_mc	movie clip in which the section (the layout) is loaded
	 */
	function layoutLoadedComplete(target_mc:MovieClip){
		
		// workaround bug when layoutLoadedInit is called before layoutLoadedComplete because an other layout was preloaded
		layoutListener.target=target_mc;
		
		// create silexLayout object
		if(target_mc.silexLayout == null)
			createSilexLayout(target_mc);
		
		silex_ptr.sequencer.doInNFrames(1,Utils.createDelegate(this, layoutLoadedInitNew),target_mc);
	}
	function createSilexLayout(target_mc : MovieClip)
	{
		target_mc.silexLayout = new org.silex.core.Layout(silex_ptr, target_mc, layoutListener.sectionName, layoutListener.layoutFileName, layoutListener.deeplinkName);
	}
	/**
	 * Called by layout_mcl when a layout is loaded AFTER 1st frame.
	 * @param target_mc	movie clip in which the section (the layout) is loaded
	 */
	function layoutLoadedInit(target_mc:MovieClip) {
	}
	
	/**
	 * the same as layoutLoadedInit, except you are SURE it is called after layoutLoadedComplete.
	 * */
	function layoutLoadedInitNew(target_mc:MovieClip) {
		Utils.removeDelegate(this, layoutLoadedInitNew);
		
		// call hooks
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(ApplicationHooks.LAYOUTINIT_START_HOOK_UID, arguments);
		
		// workaround bug when layoutLoadedInit is called before layoutLoadedComplete because an other layout was preloaded
		if (layoutListener.target != target_mc)
		{
			//silex_ptr.sequencer.doInNextFrame(Utils.createDelegate(this, layoutLoadedInit),target_mc);
			return;
		}
		
		// initialize the layout created in layoutLoadedComplete
		target_mc.silexLayout.init();
		
		// workaround bug when layoutLoadedInit is called before layoutLoadedComplete because an other layout was preloaded
		// layoutListener.sectionName=undefined;
		// layoutListener.layoutFileName = undefined;
		layoutListener.target = undefined;
		
		registerLayout(target_mc.silexLayout);
		
		// show after loading
		//target_mc._visible=true;
		
		// dispatch event
		dispatchEvent( { type:"layoutLoaded", target:target_mc.silexLayout } );
		// hooks
		hookManager.callHooks(ApplicationHooks.LAYOUTINIT_END_HOOK_UID, null);
	}
	/**
	 * Called by layoutLoadedInit.
	 * Add the layout to layouts array and set its onUnload function.
	 * @param silexLayout	the layout to register
	 */
	function registerLayout(silexLayout:org.silex.core.Layout) {
		layouts.push(silexLayout);
		silexLayout._parent.onUnload=function(){
			_global.getSilex(this).application.unRegisterLayout(this.silexLayout);
		}
	}
	/**
	 * Called by the layout parent at onUnload. see registerLayout
	 * Remove the layout from the layouts array and unset its onUnload function.
	 * @param silexLayout	the layout to unregister
	 */
	function unRegisterLayout(silexLayout:org.silex.core.Layout) {
		for (var idx:Number=0;idx<layouts.length;idx++){
			if (layouts[idx]==silexLayout)
				layouts.splice(idx,1);
		}
		silexLayout._parent.onUnload=undefined;
		//note: can't use constant because of scope of this. no silex_ptr
		dispatchEvent( { type:"layoutRemoved", target:this } );
		
	}
	
	/**
	 * called by layout when layer is ready, in Layout.registeredLayerAllPlayersLoaded
	 * */
	function layoutLayersLoaded():Void{
		//trace("layoutLayersLoaded");
		dispatchEvent( { type:silex_ptr.config.APP_EVENT_LAYOUT_ADDED, target:this } );
	}
	/**
	 * Find the layout object (silexLayout) at the root of the layout Relative a given MovieClip.
	 * @param target_mc	the movie clip of which we want to find the layout object
	 * @return the root of the layout Relative a target_mc
	 */
	function getLayout(target_mc:MovieClip):org.silex.core.Layout{
		// loop on target_mc parents
		var ptr_mc:MovieClip=target_mc;
		while(ptr_mc){
			//This is a hack around THE Chrome bug (where first frame of Layout SWF could be ran before layoutLoadedComplete)
			if(ptr_mc == layoutListener.target && ptr_mc.silexLayout == null)
			{
				createSilexLayout(ptr_mc);
			}
			// is there a silexLayout object?
			if (ptr_mc.silexLayout){
				return ptr_mc.silexLayout;
			}
			ptr_mc=ptr_mc._parent;
		}
		// here, no silexLayout object was found
	}
	/**
	 * Callback function executed when a save operation is done.
	 * @param	error_str	the description of the error. null if no error occured.
	 */
	function saveDone (error_str:String) {
		if (error_str && error_str!=""){
			// handle error while saving
			this.silex_ptr.utils.alert(silex_ptr.utils.revealAccessors(silex_ptr.config.ERROR_PAGE_SAVE_ERROR,{error:error_str}));
			dispatchEvent("unsaved");
		}
		else{
			dispatchEvent("saved");
		}
	}
	
	/**
	 * save a layout. Duplicates function from save, used by SilexAdminApi
	 * */
	function saveLayout(layout:Layout):Void{
		// call hooks
		var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(ApplicationHooks.SAVE_LAYOUT_START_HOOK_UID, arguments);
		
		var xmlString:String = null; 
		var layerXml:XML = null; 
		var USE_V3_FILE_FORMAT:Boolean = true;
		if(USE_V3_FILE_FORMAT){
			//build new layout model, using Haxe class:
			var LayerModelBuilder:Object = new HaxeLink.getHxContext().org.silex.core.LayerModelBuilder();
			//T.y("LayerModelBuilder" , LayerModelBuilder);
			var layerModel:Object = LayerModelBuilder.buildLayerModel(layout);
			
			//T.y("LayerParser" , HaxeLink.getHxContext().org.silex.publication.LayerParser.layer2XML);
			
			// if INDENT_LAYER_XML_FILE is set to true, converts layer to XML string with indent
			// if set to false,  converts layer to XML string without indent
			xmlString = HaxeLink.getHxContext().org.silex.publication.LayerParser.layer2XMLString(layerModel,silex_ptr.config.INDENT_LAYER_XML_FILE.toLowerCase()=="true");

			//T.y("xmlString", xmlString);
		}else{
			// build layout dom
			silex_ptr.dynDataManager.buildLayoutDom(layout);			
			xmlString = silex_ptr.xmlDom.objToXml(layout.dom);
		}
		
		
		var sectionName:String=silex_ptr.utils.cleanID(layout.sectionName);
		var xmlFileName:String=layout.xmlFileName;
		
		// html tags
		var seoData_obj:Object=getSeoData(layout);
		
		// write xml
		// note: last param of writeSectionData is dom object itself. This screws up sometimes, so don't send it anymore
		silex_ptr.com.writeSectionData(xmlString, xmlFileName, sectionName, seoData_obj, Utils.createDelegate(layout,saveLayoutDone), null);
		
		// set layout as clean
		layout.isDirty=false;
		hookManager.callHooks(ApplicationHooks.SAVE_END_HOOK_UID, null);		
	}
	
	/**
	 * Callback function executed when a save layout operation is done.
	 * Note: The this object of this function, as defined in the createDelegate call in saveLayout, is the layout object. 
	 * This is because we need the layout in the relevant events.
	 * @param	error_str	the description of the error. null if no error occured.
	 */
	function saveLayoutDone (error_str:String) {
		silex_ptr.application.dispatchEvent({target:silex_ptr.application, type:"saveLayoutDone", errorMessage:error_str, layout:this});
	}	
	/**
	 * Build an indexable object for seo, search engine, rss.
	 * @return an object with the properties title (string), link (string), pubDate (Date) and content (array of objects returned by ui.players.UiBase::getSeoData)
	 */
	function getSeoData(layout:org.silex.core.Layout):Object {
		// **
		// layout hand written keywords
		
		// **
		// automatic keywords
		// layoutPath used for href
		var layoutPath:String=silex_ptr.deeplink.getLayoutPath(layout).join("/");;
		// relative path : if path = a/b/c then relative path = ../../../
		var nSlashes:Number=layoutPath.split("/").length-1;
		
		var layoutRelativePath:String="../../";
		for (var idx:Number=0;idx<nSlashes;idx++) layoutRelativePath+="../";
		
		// res_obj to store result
		var res_obj:Object=new Object;
		res_obj.title=layout.sectionName;
		res_obj.deeplink=layoutPath;
		res_obj.pubDate=(new Date()).toString();
		res_obj.urlBase=silex_ptr.utils.getRootUrl()+silex_ptr.config.id_site+"/";
		
		// browse all players
		res_obj.content=new Array;
		for (var layerIdx:Number=0;layerIdx<layout.layers.length;layerIdx++){
			for (var playerIdx:Number=0;playerIdx<layout.layers[layerIdx].players.length;playerIdx++){
				// retrieve the player reference
				var playerName_str:String=layout.layers[layerIdx].players[playerIdx]._name;
				var player/*:org.silex.ui.UiBase*/=layout.layers[layerIdx][playerName_str].main;
				// get the tags
				var playerSeoData:Object=player.getSeoData(layoutRelativePath);
				if (playerSeoData && (playerSeoData.text || playerSeoData.tags || playerSeoData.description || playerSeoData.links || playerSeoData.htmlEquivalent || playerSeoData.className))
					res_obj.content.push(playerSeoData);
			}
		}
		return res_obj;
	}
	
	/**
	 * Use org.silex.ui.UiBase::playerName to retrieve the player named playerName_str in the players tool box.
	 * @param playerName_str	the name of the player to find
	 * @return the player named playerName_str in the players tool box
	 */
	function getPlayerByName(playerName_str:String)/*:org.silex.ui.UiBase*/{
		// parse the org.silex.core.Layout objects
		var layout_ptr:org.silex.core.Layout=layoutContainer.silexLayout;
		while (layout_ptr){
			// parse the ui.Layer objects
			for (var layerIdx:Number=0; layerIdx<layout_ptr.layers.length;layerIdx++){
				// parse the players array ({_name:...,type:...})
				for (var playerIdx=0;playerIdx<layout_ptr.layers[layerIdx].players.length;playerIdx++){
					// check if it is the targeted player
					var player=layout_ptr.layers[layerIdx][layout_ptr.layers[layerIdx].players[playerIdx]._name].main;
					if (player.playerName==playerName_str){
						return player;
					}
				}
			}
			// next layout object
			layout_ptr=layout_ptr.currentChildLayoutContainer.silexLayout;
		}
		// no player was found
		return null;
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: fonts
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Store all fonts in silex_ptr.config.embeddedFont array.
	 */
	function registerEmbeddedFont(fontName_str:String){
		if (!silex_ptr.config.embeddedFont)
			silex_ptr.config.embeddedFont=[];
		else{
			// check if it is allready registered
			for (var idx:Number=0;idx<silex_ptr.config.embeddedFont.length;idx++){
				if (silex_ptr.config.embeddedFont[idx]==fontName_str){
					// this font is allready registerd
					return;
				}
			}
		}
		silex_ptr.config.embeddedFont.push(fontName_str);
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: screen saver
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	/**
	 * Initialize the screen saver system.
	 */
	function screenSaverInit(){
		if (screenSaverIntervalIdx>=0){
			// interval
			clearInterval(screenSaverIntervalIdx);
			screenSaverIntervalIdx=-1;
			// screen saver mode
			screenSaverMode=SCREEN_SAVER_MODE_OFF;
			
			// mouse
			Mouse.removeListener(screenSaverMouseListener);
			delete screenSaverMouseListener;
		}
		if (parseFloat(silex_ptr.config.screenSaverDelay)>0){
			// interval
			screenSaverIntervalIdx=setInterval(Utils.createDelegate(this,screenSaverActivate),parseFloat(silex_ptr.config.screenSaverDelay)*1000);
			// screen saver mode
			screenSaverMode=SCREEN_SAVER_MODE_ON;
			// mouse
			screenSaverMouseListener=new Object;
			screenSaverMouseListener.onMouseDown=screenSaverMouseListener.onMouseMove=screenSaverMouseListener.onMouseUp=screenSaverMouseListener.onMouseWheel=Utils.createDelegate(this,screenSaverSignal);
			Mouse.addListener(screenSaverMouseListener);
		}
	}	
	/**
	 * Turn back to normal mode because activity has been detected.
	 * Called by screenSaverSignal.
	 * @see	org.silex.core.Application::screenSaverSignal
	 */
	function screenSaverDeactivate(){
		
		// initialize again
		screenSaverInit();
		
		if (silex_ptr.authentication.isLoggedIn()==false){
			// execute commands (separated with "|")
			var commands_array:Array=silex_ptr.config.screenSaverDeactivateCommands.split("|");
			for (var idx:Number=0;idx<commands_array.length;idx++)
				silex_ptr.interpreter.exec(silex_ptr.utils.revealAccessors(commands_array[idx],silex_ptr),layouts[0]);
		}
	}
	/**
	 * Turn into screen saver mode because there was no activity for a certain amount of time.
	 * Only if user is not logged in.
	 * Called by the system (setInterval callback).
	 */
	function screenSaverActivate(){
		
		// screen saver mode
		screenSaverMode=SCREEN_SAVER_MODE_ACTIVE;
		
		// interval
		clearInterval(screenSaverIntervalIdx);
		screenSaverIntervalIdx=-1;
		
		if (silex_ptr.authentication.isLoggedIn()==false){
			// execute commands (separated with "|")
			var commands_array:Array=silex_ptr.config.screenSaverActivateCommands.split("|");
			for (var idx:Number=0;idx<commands_array.length;idx++)
				silex_ptr.interpreter.exec(silex_ptr.utils.revealAccessors(commands_array[idx],silex_ptr),layouts[0]);
		}
		else{
			silex_ptr.utils.alertSimple(silex_ptr.config.MESSAGE_SCREEN_SAVER_LOGGED_IN);
		}
	}
	/**
	 * Delay the screen saver activation because activity is detected.
	 * Called by SILEX when activity is detected.
	 */
	function screenSaverSignal(){
		if (screenSaverMode==SCREEN_SAVER_MODE_ON){
			screenSaverInit();
		}
		else if (screenSaverMode==SCREEN_SAVER_MODE_ACTIVE){
			screenSaverDeactivate();
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Group: layers
	////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	/**
	 * Called by org.silex.core.Api.config object (watch on globalContext).
	 */
	function refreshAllLayers(){
		for (var idxLayout:Number=0;idxLayout<layouts.length;idxLayout++){
			for (var idxLayer:Number=0;idxLayer<layouts[idxLayout].layers.length;idxLayer++)
				layouts[idxLayout].layers[idxLayer].refresh();
		}
	}
	/**
	 * Check if one of the target's child layout is dirty, 
	 * @param	targetLayout	the layout to be checked
	 * @return true if targetLayout has changed. null otherwise.
	 */
	function isAChildDirty(targetLayout:org.silex.core.Layout):Boolean{
		// working index
		var layoutIdx:Number=0;
		// go to the target in the layouts array
		while (layouts[layoutIdx]){
			if (layouts[layoutIdx]==targetLayout)
				break;
			layoutIdx++;
		}
		// for all children, check if it is dirty
		layoutIdx++;
		while (layouts[layoutIdx]){
			if (layouts[layoutIdx].isDirty==true)
				return layouts[layoutIdx];
			layoutIdx++;
		}
		return null;
	}
}