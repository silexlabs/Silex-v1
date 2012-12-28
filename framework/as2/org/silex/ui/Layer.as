/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * Name : Layer.as
 * Package : ui
 * Version : 0.8
 * Date :  2007-08-09
 */


import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
import org.silex.ui.LayerHooks;
import org.silex.util.EventDispatcherMovieClip;
import org.silex.adminApi.util.T;
import org.silex.ui.UiBase;

[Event("playersLoaded")] // thrown when players are loaded
[Event("allPlayersLoaded")] // thrown when players and components are loaded

 
class org.silex.ui.Layer extends EventDispatcherMovieClip{
	
	//array of players
	var players:Array = null;
	
	var nRegisteredPlayers=0;

	private static var TYPE_COMPONENT:String = "Component";
	
	//silex instance
	var silexInstance/*:org.silex.core.Api*/ = null;	
	
	/**
	 * name
	 * used by toolbox.Layers
	 * set by core.Layout::registerLayer
	 */
	 var name:String="";
	
	

	// dejavu : allPlayersLoaded has to be dispatched only one time
	var dejavu:Boolean = false;	

	/**
	 * function construct
	 * @return void
	 */
	public function Layer(){
		// players
		this.players = new Array();
		//silex instance
		this.silexInstance =_global.getSilex(this);
		// register layer
		this.silexInstance.application.getLayout(this).registerLayer(this);
		//T.y("Layer con" + this);
		
	}
		
	
	/**
	 * this works with the v2 file format. It must be called when this file format is detected in the Layout's register Layer
	 */
	function legacyInit() {	
		//register players
		this.silexInstance.dynDataManager.registerVariable(this, "players","array");
		//initlayer
		initLayer();
	}	

	/**
	 * initialize players in array players
	 * @return void
	 */
	function initLayer():Void{
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayerHooks.INIT_START_HOOK_UID, arguments);
		
		//attachMovie
		var l:Number = players.length;
		//T.y("initLayer", l);
		if (l > 0)
		{
			//1ast in array is the highest
			for (var i:Number = l-1; i>= 0; i--){
				if (isInContext(players[i])){
					loadPlayer(players[i]);
				}
				else{
					///////////////////////
					// register this clip as out of context
					silexInstance.dynDataManager.registerClipOutOfContext(this,players[i]._name);
					nRegisteredPlayers++;
				}
			}
		}
		else
		{
			// here there is 0 player in the layer
			doOnAllPlayersLoaded();
		}
		// hooks
		hookManager.callHooks(LayerHooks.INIT_END_HOOK_UID, null);
	} 
	
	/*
	 * registerPlayer
	 * called by UiBase
	 * called when an error occurred while downloading a component
	 */
	function registerPlayer(player/*:org.silex.ui.UiBase*/) {
		//T.y("registerPlayer", player, nRegisteredPlayers, dejavu);
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayerHooks.REGISTER_PLAYER_START_HOOK_UID, arguments);
		
		nRegisteredPlayers++;
		
		if (!dejavu && nRegisteredPlayers>=players.length){
			doOnAllPlayersLoaded();
		}
		// hooks
		hookManager.callHooks(LayerHooks.REGISTER_PLAYER_END_HOOK_UID, null);
	}
	
	/**
	* does the dispatching of the various allPlayersLoaded events. and later calls onPlayersLoaded
	* du code putain de dégueulasse! A.S.
	*/
	private function doOnAllPlayersLoaded():Void{		
		//trace("doOnAllPlayersLoaded");
		dejavu=true;
		silexInstance.sequencer.doInNextFrame(Utils.createDelegate(this,onPlayersLoaded));
		silexInstance.sequencer.doInNextFrame(Utils.createDelegate(this, dispatchEvent), { type: "allPlayersLoaded", target:this} );
		silexInstance.sequencer.doInNextFrame(Utils.createDelegate(silexInstance.application,silexInstance.application.dispatchEvent),{type: "allPlayersLoaded",target:silexInstance.application});
	}
	
	
	function onPlayersLoaded() {
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayerHooks.ALL_PLAYERS_LOADED_START_HOOK_UID, arguments);

		dispatchEvent({type: "playersLoaded",target:this});
		silexInstance.application.dispatchEvent({type: "playersLoaded",target:this});
		// hooks
		hookManager.callHooks(LayerHooks.ALL_PLAYERS_LOADED_END_HOOK_UID, null);
	}
	
	/**
	 * When loading a component returns an http error, we instantiate a default error component
	 * instead ansd dispatch an error hook
	 * @param	cible_mc
	 * @param	errorCode_str
	 * @param	HTTPStatus_str
	 */
	function componentDownloadError(cible_mc:MovieClip, errorCode_str:String, HTTPStatus_str:Number)
	{
		players.shift();
		
		HookManager.getInstance().callHooks(LayerHooks.COMPONENT_LOAD_ERROR, cible_mc);
		
		var componentLoadInfo:Object = { _name:silexInstance.config.ERROR_COMPONENT_NAME,
		type:TYPE_COMPONENT, mediaUrl:silexInstance.config.ERROR_COMPONENT_URL,
		label:silexInstance.config.ERROR_COMPONENT_LABEL,
		className:silexInstance.config.ERROR_COMPONENT_CLASSNAME };
		players.unshift(componentLoadInfo);		
		loadPlayer(componentLoadInfo);
	}
	/**
	 * initialization of component in 3 steps: before config, configuration, and after config
	 * */
	public static function initComponent(componentRoot:UiBase):Void{
		//T.y("initComponent", componentRoot, componentRoot.doBeforeConfig);
		componentRoot.doBeforeConfig();
		componentRoot._registerWithSilex();
		componentRoot.doAfterConfig();		
	}
	
	/**
	 * listener for the init of loading a component, used in loadPlayer
	 * can(t be inline because uses legacyInitComponent
	 * */
	private function onComponentLoadInit(cible_mc:MovieClip) {
		//trace("onComponentLoadInit");
		//trace(cible_mc.main);
		initComponent(cible_mc.main);
	}			
	
	/**
	 * quick string replace function...
	 * */
	private function stringReplace(block:String, find:String, replace:String):String
	{
		return block.split(find).join(replace);
	} 
	/**
	* loads a player/component, depending on the load info. 
	*  		
	*/
	function loadPlayer(loadInfo:Object):Void{
		//T.y("loadPlayer", loadInfo);
		
		
		if(loadInfo.type != "Component"){
			//temp code, converts old player type to equivalent component. A.S.
			loadInfo.mediaUrl = "plugins/baseComponents/as2/org.silex.ui.players." + loadInfo.type + ".swf";
			loadInfo.type = "Component";
		}
		
		//replace oof components from meida by equivalent in plugins
		if(loadInfo.mediaUrl.indexOf("media/components/oof/") != -1){
			loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/oof/", "plugins/oofComponents/as2/");
			//trace("loadInfo.mediaUrl" + loadInfo.mediaUrl);
			loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "cmp.", "");
			//trace("loadInfo.mediaUrl" + loadInfo.mediaUrl);
		}
		
		//replace media component url by plugin url 
		else if (loadInfo.mediaUrl.indexOf("media/components/") != -1) {
				if (loadInfo.mediaUrl.indexOf("media/components/SRTPlayer.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/SRTPlayer.cmp.swf", "plugins/silexComponents/as2/SRTPlayer/SRTPlayer.swf");
				}
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/label_button.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/label_button.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/label_button2.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/label_button2.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton2.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/label_button3.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/label_button3.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton3.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/label_button4.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/label_button4.cmp.swf", "plugins/silexComponents/as2/labelButton/labelButton4.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/futurist_button.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/futurist_button.cmp.swf", "plugins/silexComponents/as2/futuristButton/futuristButton.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/scale9_button1.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/scale9_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/scale9Button1.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/simple_flash_button1.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/simple_flash_button1.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton1.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/simple_flash_button2.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl, "media/components/buttons/simple_flash_button2.cmp.swf", "plugins/silexComponents/as2/simpleFlashButton/simpleFlashButton2.swf");
				}
				
		
				
				else if (loadInfo.mediaUrl.indexOf("plugins/silexComponents/as2/simpleFlashButton/button.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl,"plugins/silexComponents/as2/simpleFlashButton/button.swf", "plugins/silexComponents/as2/labelButton/button.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/Geometry.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl,"media/components/Geometry.cmp.swf", "plugins/baseComponents/as2/Geometry.swf");
				}
				
				else if (loadInfo.mediaUrl.indexOf("media/components/buttons/button.cmp.swf") != -1)
				{
					loadInfo.mediaUrl = stringReplace(loadInfo.mediaUrl,"media/components/buttons/button.cmp.swf", "plugins/silexComponents/as2/labelButton/button.swf");
				}
	
		}
		
		
		//trace("loadInfo.mediaUrl " + loadInfo.mediaUrl);
		
		//movieclip loader
    	var loaderComponent_mcl:MovieClipLoader = new MovieClipLoader();

		var listenerLoader_obj:Object = new Object();

		//error
		listenerLoader_obj.onLoadError = Utils.createDelegate(this, componentDownloadError);

		listenerLoader_obj.onLoadInit = Utils.createDelegate(this, onComponentLoadInit);

		//create movieClip container
		var contener:MovieClip = this.createEmptyMovieClip( loadInfo._name , this.getNextHighestDepth() );		
		silexInstance.utils.loadMedia(loadInfo.mediaUrl + "?name_str=" + loadInfo.label, contener, "swf", listenerLoader_obj);
			
	}
	
	/**
	 * TODO : Improve sort algorithme
	 * refresh players array
	 * change z order if needed
	 * @return 	void 			return extension
	 */
	public function refresh():Void{
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayerHooks.REFRESH_START_HOOK_UID, arguments);
		
		//players length
		var l:Number = players.length;
		for (var i:Number = l-1; i >= 0; i-- ){
			//player object
			var playerObj:Object = players[i];
			//player instance
			var player:MovieClip =  this[players[i]._name];
						
			//if on scene
			if(player != undefined){
				if (isInContext(playerObj)){
					//change z order
					player.swapDepths( this.getNextHighestDepth());	
				}
				else{

					// register this clip as out of context
					silexInstance.dynDataManager.registerClipOutOfContext(this,players[i]._name);

					// remove player
					player.main.unloadMedia();
					player.removeMovieClip();
				}
			}else{
				if (isInContext(playerObj)){

					// register this clip as out of context
					silexInstance.dynDataManager.unRegisterClipOutOfContext(this,players[i]._name);
					loadPlayer(playerObj);
				}
				else{
					// do not create player
				}
			}
			
		}
		// dispatch event on next frame
		silexInstance.sequencer.doInNextFrame(Utils.createDelegate(this,onPlayersLoaded));
		// hooks
		hookManager.callHooks(LayerHooks.REFRESH_END_HOOK_UID, null);
	}

	function isInContext(player_obj:Object):Boolean{
		if (player_obj.contextAccepted==undefined){
			player_obj.contextAccepted=new Array("*");
			return true;
		}
/*		if (player_obj.contextRejected==undefined){
			player_obj.contextRejected=new Array;
			return true;
		}*/
		// if the player contextAccepted array is included in global context but not the contextRejected
		
		for (var idx:Number=0;idx<player_obj.contextAccepted.length;idx++){
			if (silexInstance.utils.isPartOf(player_obj.contextAccepted[idx].split(","),silexInstance.config.globalContext.split(","))==true){
				return true;
			}
		}
		return false;
	}
}