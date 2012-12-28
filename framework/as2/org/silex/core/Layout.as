/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.events.EventDispatcher;

import org.silex.adminApi.util.T;
import org.silex.core.LayoutHooks;
import org.silex.core.Utils;
import org.silex.core.plugin.HookManager;
import org.silex.link.HaxeLink;
import org.silex.ui.Layer;
import org.silex.util.EventDispatcherBase;

[Event("XMLLoaded")]
[Event("showContent")]
[Event("hideContent")]
[Event("showChild")] // dispatch from application::openSection - sectionName layoutFileName target(Layout)
[Event("hideChild")]

[Event("onDeeplink")] // thrown by org.silex.core.Deeplink: parentLayout_ptr.dispatchEvent({type:"onDeeplink",target:parentLayout_ptr,deeplinkName:sectionName});
//layoutLoaded :?:
//allAnimsEnded :?:

/**
 * This class represents a layout which is an object called silexLayout created at run time at the root of each layout.
 * Handle the loading process of the xml data.
 * In the repository : /trunk/core/Layout.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-26
 * @mail : lex@silex.tv
 */
class org.silex.core.Layout extends EventDispatcherBase{
	/**
	 * reference to silex main Api object (org.silex.core.Api)
	 */
	private var silex_ptr:org.silex.core.Api;

	//////////////////////////////
	// Group: layers
	/////////////////////////////
	var layers:Array;
	var layerContainers:Array;
	var defaultIcon/*:org.silex.ui.players.UiBase*/;
	
	//needs a rename and a getter!!! A.S.
	public var _parent:MovieClip;

	//////////////////////////////
	// Group: layouts
	/////////////////////////////
	var layoutFileName:String;
	var anims:Array;
	// container for the child layout
	var layoutContainer:MovieClip;
	// reference to the last opened child layout (a dynamically created movie clip contained in layoutContainer)
	var currentChildLayoutContainer:MovieClip;
	var currentChildLayoutContainerIndex:Number=0; // used to create container names
	
	/**
	 * Name of the page deep link.
	 * Used by silex.deeplinkManager::getCurrentPath.
	 * @see	org.silex.core.DeeplinkManager::getCurrentPath
	 */
	var deeplinkName:String;
	
	/**
	 * is content visible? set bay startAnimShow
	*/
	var isContentVisible:Boolean=false;
	/** 
	 * true if all players have loaded
	 */
	var haveAllPlayersLoaded=false;
	//////////////////////////////
	// Group: seo
	/////////////////////////////
	// keywords
	// description
	// isAutomaticSeoActive

	/**
	 * set by propeties tool box when a property has been changed
	 */
	var isDirty:Boolean=false;
	
	/**
	 * the icon which has opened the child layer if there is one
	 * used in UiBase and in ButtonBase
	 */
	var selectedIcon:MovieClip;
	
	//////////////////////////////
	// Group: xml data
	/////////////////////////////
	// xml file/section name
	var xmlFileName:String;
	var sectionName:String;
	var cleanSectionName:String; // wiki style section names: no accent, space, ... 
	var xmlLoaded_bool:Boolean=false;
	var initDone_bool:Boolean=false;

	//////////////////////////////
	// Group: model
	/////////////////////////////
	//haxe : org.silex.publication.LayerModel;
	var model:Object;
	
	//////////////////////////////
	// Group: dom(legacy, replaced by model)
	/////////////////////////////
	var dom:Object;
	var domOutOfContext:Object;
	/**
	 * Store the dynamic data.
	 * Used by DynDataManager class.
	 */
	var registeredVariables:Array;
	
	/*
	 * client data from db used by components and players
	 */
	var dbdata_obj:Object;

	/*
	 * Constructor.
	 * Called by org.silex.core.Application before layout first frame.
	 * Start the loading process of data.
	 */
	function Layout(api:org.silex.core.Api, parent:MovieClip, sectionName_str:String,layoutFileName_str:String,deeplinkName_str:String)
	{
		
		// hide before init
		parent._visible=false;
		
		// **
		// store Api reference
		//
		silex_ptr=api;
		
		// store reference to swf layout
		_parent=parent;
		
		//eventDispatcher
		EventDispatcher.initialize(this);
		
		// **
		// layout
		//
		layoutFileName=layoutFileName_str;
		
		/**
		 * array of the animations (preload, show, hide, transition, transitionClose)
		 * array of objects with the attributes {target_mc:target_mc, autoEndDetection_bool:autoEndDetection_bool}
		 */
		anims=new Array;

		// **
		// layers
		//
		layers=new Array;
		layerContainers=new Array;

		// **
		// xml file/section name
		//
		// store the section name
		sectionName=sectionName_str;

		// remove unwanted chars from file name
		cleanSectionName=silex_ptr.utils.cleanID(sectionName_str);
		
		// build default deeplink
		if (deeplinkName_str) 
			deeplinkName=deeplinkName_str;
		else
			deeplinkName=cleanSectionName;
		
/*		if (silex_ptr.config.USE_AMF_FILES.toLowerCase()=="true")
		{
			// **
			// AMF
			amfConnect();
//			silex_ptr.sequencer.doInNFrames(1, Utils.createDelegate(this,amfConnect));
		}
		else
		{
			// **
			// XML
			xmlConnect();
		}
*/	}
	function xmlConnect()
	{
		// build the file name
		xmlFileName=silex_ptr.config.id_site+"/"+cleanSectionName+".xml";


		// load xml data
		var xmlFileUrl_str:String = silex_ptr.config.initialContentFolderPath+xmlFileName;
		if (silex_ptr.config.ALLOW_CACHE_CONTROL.toLowerCase()!="false")
		{
			// allow cache control
			xmlFileUrl_str += "?rand="+Math.round(1000*Math.random());
		}
			
		//silex_ptr.sequencer.doInNFrames(10, function(){_xml.load(silex_ptr.rootUrl+xmlFileUrl_str);});
		var result_lv:LoadVars = new LoadVars(); 
		var send_lv:LoadVars = new LoadVars(); 
		result_lv.onData = Utils.createDelegate(this,xmlLoaded);
		send_lv.sendAndLoad(silex_ptr.rootUrl+xmlFileUrl_str, result_lv);
	}
	
	function amfConnect()
	{
		// build the file name
		xmlFileName=silex_ptr.config.id_site+"/"+cleanSectionName+silex_ptr.config.AMF_FILE_EXTENSION;
		// load AMF file
		var responder_obj:Object=new Object;
		responder_obj.silex_ptr = silex_ptr;
		// responder_obj.onResult = Utils.createDelegate(this,amfLoaded);
		// success
		responder_obj.onStatus = Utils.createDelegate(this,amfLoaded);
		// TO DO : 
		responder_obj.onError=function( fault)
		{
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
		}
		responder_obj.silex_ptr=silex_ptr;
			
		var xmlFileUrl_str:String = silex_ptr.utils.getRootUrl()+silex_ptr.config.initialContentFolderPath+xmlFileName;
//		var xmlFileUrl_str:String = silex_ptr.utils.getRootUrl()+silex_ptr.config.gatewayRelativePath; 
		if (silex_ptr.config.ALLOW_CACHE_CONTROL.toLowerCase()!="false")
		{
			// allow cache control 
			xmlFileUrl_str += "?rand="+Math.round(1000*Math.random());
		}
		var connection:NetConnection = new NetConnection();
		// error
		connection.onStatus = Utils.createDelegate(this,amfLoaded);
		connection.connect(xmlFileUrl_str);
		connection.call( "", responder_obj );
		// silex_ptr.utils.alertSimple("amfConnect");
	}
	/**
	 * Called by result_lv from xmlConnect function when xml string is loaded.
	 * Create the dom object corresponding to the xml data.
	 * Load layers objects in the registered layerContainers.
	 * Push the show anim in the sequencer.
	 */
	function xmlLoaded(src:String) {
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayoutHooks.XML_LOADED_START_HOOK_UID, arguments);
		
		if (src != undefined){
			//T.y("xml version : ", _xml.firstChild.firstChild.attributes.silexXmlVersion);
			if(src.indexOf("silexXmlVersion=\"2") != -1){
				// create the dom object corresponding to the xml data. use old dom system
				var xml = new XML();
				xml.ignoreWhite = true;
				xml.parseXML(src);
				dom = silex_ptr.xmlDom.xmlToObj(xml);
			}else {
				//use publication model system
				//convert as2 xml object to haxe xml object
				//T.y(HaxeLink.getHxContext().Xml.parse, _xml.toString() );
				var haxeXml = HaxeLink.getHxContext().org.silex.core.LayerHelper.parseXml(src);
				//T.y("haxeXml", haxeXml.toString());
				
				model = HaxeLink.getHxContext().org.silex.publication.LayerParser.xml2Layer(haxeXml);
				//T.y("model", model, model.subLayers.length);
			}
		}
		else{
			// silex_ptr.utils.alertSimple(silex_ptr.utils.revealAccessors(silex_ptr.config.MESSAGE_SECTION_DOES_NOT_EXIST,this));
	 		// create an empty dom object
			dom=new Object;
		}
		
		// xml loading process has ended
		xmlLoaded_bool=true;

		// load layers objects in the registered layerContainers
		for (var idx:Number=0;idx<layerContainers.length;idx++){
			// load the layer object in that layer
			loadRegisteredLayer(layerContainers[idx]);
		}
		
		// if init has been called allready
		if (initDone_bool==true){
			// push the show anim in the sequencer
			silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_SHOW].target_mc,Utils.createDelegate(this,endAnimShow),Utils.createDelegate(this,startAnimShow),anims[silex_ptr.constants.ANIM_NAME_SHOW].autoEndDetection_bool, deeplinkName + " - Show");
		// show after init
		_parent._visible=true;
		}
		
		// dispatch event
		dispatchEvent({type: silex_ptr.config.UI_PLAYERS_EVENT_XMLLOADED ,target:this});
		// hooks
		hookManager.callHooks(LayoutHooks.XML_LOADED_END_HOOK_UID, null);
	}
	function amfLoaded(resultObj:Object)
	{
		// silex_ptr.utils.alertSimple("amfLoaded "+initDone_bool);
		// call hooks
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(LayoutHooks.AMF_LOADED_START_HOOK_UID, arguments);
		
/*			var resString = "";
           for (var r:String in resultObj)
            {
               resString += r + " : " + resultObj[r]+ "\n";
            }
	_root.getURL("javascript:alert('"+resString+"');");
/**/
		if (resultObj)
		{
	 		// create the dom object corresponding to the xml data
			dom = resultObj;
		}
		else{
			silex_ptr.utils.alertSimple(silex_ptr.utils.revealAccessors(silex_ptr.config.MESSAGE_SECTION_DOES_NOT_EXIST,this));
	 		// create an empty dom object
			dom=new Object;
		}

		// xml loading process has ended
		xmlLoaded_bool = true;
		
		// load layers objects in the registered layerContainers
		for (var idx:Number=0;idx<layerContainers.length;idx++){
			// load the layer object in that layer
			loadRegisteredLayer(layerContainers[idx]);
		}
		
		// if init has been called allready
		if (initDone_bool==true){
			// push the show anim in the sequencer
			silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_SHOW].target_mc,Utils.createDelegate(this,endAnimShow),Utils.createDelegate(this,startAnimShow),anims[silex_ptr.constants.ANIM_NAME_SHOW].autoEndDetection_bool, deeplinkName + " - Show");
		}
		
		// dispatch event
		dispatchEvent({type: silex_ptr.config.UI_PLAYERS_EVENT_XMLLOADED ,target:this});
		// hooks
		hookManager.callHooks(LayoutHooks.AMF_LOADED_END_HOOK_UID, null);
	}
	/*
	 * Called by org.silex.core.Application AFTER layout first frame.
	 * Handle the anims.
	 */
	function init(){
		// silex_ptr.utils.alertSimple(" init "+xmlLoaded_bool);
		
		initDone_bool=true;

		// **
		// automatic anims registering
		// depending on flash IDE mode: normal, slide presentation or form application
		//
		// normal mode
		var layoutRoot_mc:MovieClip=_parent;
		// slide presentation mode
		if (_parent.presentation)
			layoutRoot_mc=_parent.presentation;
		// form application mode
		if (_parent.application)
			layoutRoot_mc=_parent.application;

		// register anims
		if(!(_parent.allowAutomaticAnimDetection == false))
		{
			if (layoutRoot_mc[silex_ptr.constants.ANIM_NAME_PRELOAD])
				registerAnim(layoutRoot_mc[silex_ptr.constants.ANIM_NAME_PRELOAD],silex_ptr.constants.ANIM_NAME_PRELOAD);
			if (layoutRoot_mc[silex_ptr.constants.ANIM_NAME_SHOW])
				registerAnim(layoutRoot_mc[silex_ptr.constants.ANIM_NAME_SHOW],silex_ptr.constants.ANIM_NAME_SHOW);
			if (layoutRoot_mc[silex_ptr.constants.ANIM_NAME_TRANSITION_CLOSE])
				registerAnim(layoutRoot_mc[silex_ptr.constants.ANIM_NAME_TRANSITION_CLOSE],silex_ptr.constants.ANIM_NAME_TRANSITION_CLOSE);
			if (layoutRoot_mc[silex_ptr.constants.ANIM_NAME_TRANSITION])
				registerAnim(layoutRoot_mc[silex_ptr.constants.ANIM_NAME_TRANSITION],silex_ptr.constants.ANIM_NAME_TRANSITION);
			if (layoutRoot_mc[silex_ptr.constants.ANIM_NAME_CLOSE])
				registerAnim(layoutRoot_mc[silex_ptr.constants.ANIM_NAME_CLOSE],silex_ptr.constants.ANIM_NAME_CLOSE);
		}
		// **
		// start preload anim
		silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_PRELOAD].target_mc,Utils.createDelegate(this,endAnimPreload),undefined,anims[silex_ptr.constants.ANIM_NAME_PRELOAD].autoEndDetection_bool, deeplinkName + " - Preload");
		// **
		// if xml has allready been loaded (local mode), push the show anim in the sequencer
		if (xmlLoaded_bool==true){
			silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_SHOW].target_mc,Utils.createDelegate(this,endAnimShow),Utils.createDelegate(this,startAnimShow),anims[silex_ptr.constants.ANIM_NAME_SHOW].autoEndDetection_bool, deeplinkName + " - Show");
		}
		// show after init
		_parent._visible=true;
		if (silex_ptr.config.USE_AMF_FILES.toLowerCase()=="true")
		{
			// **
			// AMF
			amfConnect();
//			silex_ptr.sequencer.doInNFrames(1, Utils.createDelegate(this,amfConnect));
		}
		else
		{
			// **
			// XML
			xmlConnect();
		}
	}
	/**
	 * Close the layout
	 */
	function close(){
		// TO DO : chexk isDirty property
	
		// dispatch event
		dispatchEvent({type:  silex_ptr.config.UI_PLAYERS_EVENT_CONTENT_HIDE_START ,target:this});
		
		// show close anim if there is one and unload
/*		if (anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc)
			silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc,Utils.createDelegate(this,unloadLayoutCallback));
		else
			unloadLayoutCallback();*/
			
		// close the child layouts
		closeChild();
			
		// show th close anim
		silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc,Utils.createDelegate(this,unloadLayoutCallback),undefined,anims[silex_ptr.constants.ANIM_NAME_CLOSE].autoEndDetection_bool, deeplinkName + " - Close");
	}
	/**
	 * close children and then start the close transition anim
	 */
	function closeChild(){

		// close the child layouts
		if (currentChildLayoutContainer){
			currentChildLayoutContainer.silexLayout.close();
			// show the transition close anim
			silex_ptr.sequencer.addItem(anims[silex_ptr.constants.ANIM_NAME_TRANSITION_CLOSE].target_mc,Utils.createDelegate(this,transitionCloseStop),Utils.createDelegate(this,transitionCloseStart),anims[silex_ptr.constants.ANIM_NAME_TRANSITION_CLOSE].autoEndDetection_bool, deeplinkName + " - Transition close");
		}
	}
	/**
	 * the tracition close anim is over
	 */
	function transitionCloseStop() {
		// no more current child
		currentChildLayoutContainer.removeMovieClip();
		currentChildLayoutContainer=null;
		// reset transition anim
		anims[silex_ptr.constants.ANIM_NAME_TRANSITION].target_mc.gotoAndPlay(1);		
	}
	/**
	 * the tracition close anim started
	 */
	function transitionCloseStart() {
		// dispatch event
		dispatchEvent({type:  "hideChild" ,target:this});
	}
	/**
	 * the close anim ended
	 */
	function unloadLayoutCallback() {
		isContentVisible=false;
		// unload after the anim ended
		if (anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc && anims[silex_ptr.constants.ANIM_NAME_CLOSE].autoEndDetection_bool){
			var remainingFramesBeforeUnload:Number = anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc._totalFrames - anims[silex_ptr.constants.ANIM_NAME_CLOSE].target_mc._currentFrame;
			silex_ptr.sequencer.doInNFrames(remainingFramesBeforeUnload, Utils.createDelegate(this, doUnloadLayoutCallback));
		}
		else if (anims[silex_ptr.constants.ANIM_NAME_CLOSE].autoRemoveLayoutAtEnd_bool)
			doUnloadLayoutCallback();
	}
	/**
	 * unload this layout now
	 */
	function doUnloadLayoutCallback(){
		// dispatch event
		dispatchEvent({type:  silex_ptr.config.LAYOUT_EVENT_HIDE_CONTENT,target:this});
// no, now called in the listener in applicaiton (layoutReadyForUnload) :		silex_ptr.application.layout_mcl.unloadClip(this._parent);
	}
	/**
	 * called by org.silex.core.Sequencer when preload anim ends
	 */
	function endAnimPreload() {
	}
	/**
	 * called by org.silex.core.Sequencer when show anim ends
	 */
	function startAnimShow() {

		// is content visible?
		isContentVisible=true;

		// dispatch event
		dispatchEvent({type: silex_ptr.config.UI_PLAYERS_EVENT_CONTENT_SHOW ,target:this});
	}
	/**
	 * called by org.silex.core.Sequencer when show anim ends
	 */
	function endAnimShow() {
	}
	/**
	 * has to be called on the 1st frame of a layout
	 * @param	target_mc			the animation
	 * @param	animName_str		the name of the animation, use the constants from org.silex.core.Constants::ANIM_NAME_*
	 * @param	autoEndDetection	should the sequencer skip to the next animation when the last frame is reached<br />optionnal, default: true
	 * @param	autoRemoveAtEnd		automatically unload the layout when the last frame of this animation is reached - only for ANIM_NAME_CLOSE animations<br />if false, do not forget to call doUnloadLayoutCallback() by yourself<br />optionnal, default: true
	 */
	function registerAnim (target_mc:MovieClip, animName_str:String, autoEndDetection:Boolean, autoRemoveLayoutAtEnd:Boolean) {
		// default values
		if (autoRemoveLayoutAtEnd == undefined)
			autoRemoveLayoutAtEnd = true;
			
		// add the animation to the array
		anims[animName_str] = { target_mc:target_mc, autoEndDetection_bool:autoEndDetection, autoRemoveLayoutAtEnd_bool:autoRemoveLayoutAtEnd };
		
		// initialize the animation
		target_mc.stop();
		target_mc._visible=false;
	}
	/**
	 * Called by the layout.
	 * The target is filled with a layer object.
	 * To be efficient, it has to be called on the 1st frame of a layout.
	 */
	function registerLayerContainer(layerContainer:MovieClip, layerName_str:String) {
		// silex_ptr.utils.alertSimple("registerLayerContainer "+xmlLoaded_bool+" - "+layerName_str);
		layerContainers.push(layerContainer);
		layerContainer.layerName=layerName_str;

		if (!layerContainer.container_mc)
			layerContainer.createEmptyMovieClip("container_mc",layerContainer.getNextHighestDepth());
		
		// load the layer object in that layer
		if (xmlLoaded_bool) {
//			loadRegisteredLayer(layerContainer);
			var refthis = this;
			silex_ptr.sequencer.doInNFrames(10, function () { refthis.loadRegisteredLayer(layerContainer) } );
		}
	}
	/**
	 * load the layer skin in the container
	 * update: this function now creates a layer skin movieclip directly, so no layer skins are loaded. This would need some refactoring
	 * but as the code is on it way out anyway I chose not to. A.S.
	 * @param	layerContainer	a container clip, usually a LayerSkinComponent (authoring component for Silex in the Flqsh IDE)
	 */
	function loadRegisteredLayer(layerContainer:MovieClip){
		/*
		//would be cleaner but doesn't work!!
		Object.registerClass("org.silex.ui.Layer", Layer);
		var layer = layerContainer.attachMovie("org.silex.ui.Layer", "aaaaaa", layerContainer.getNextHighestDepth());
		T.y("layer", layer);
		*/
		
		var layer :MovieClip = layerContainer.container_mc.createEmptyMovieClip("main", layerContainer.getNextHighestDepth());
		var classRef:Function = Layer;
		layer.__proto__ = classRef.prototype;
		classRef.apply(layer);
 
	}
	/**
	 * Called by the org.silex.ui.Layer class before all players have been initialized.
	 * Store the layer into layers array and retrieve the layer's name from layer container.
	 */
	function registerLayer(subLayer:org.silex.ui.Layer){
		//trace("registerLayer " + subLayer.name);
		// retrieve the layer's name from layer container 
		var ptr_mc:MovieClip=subLayer._parent;
		while (ptr_mc && !ptr_mc.layerName){
			ptr_mc=ptr_mc._parent;
		}
		if (ptr_mc.layerName){
			subLayer.name=ptr_mc.layerName;
		}
		
		//trace("subLayer.name " + subLayer.name);
			
		// store the layer into layers array
		layers.push(subLayer);
		var _obj:Object=new Object;
		_obj.allPlayersLoaded=Utils.createDelegate(this,registeredLayerAllPlayersLoaded);
		subLayer.addEventListener("allPlayersLoaded",_obj);
		if (dom) {
			//trace("dom exists, registerLayer using old system");
			//with dom, it's old system. Therefore the layer needs to initialize itself.
			subLayer.legacyInit();
		}else {
			var subLayerModel:Object = HaxeLink.getHxContext().org.silex.core.LayerHelper.getSubLayerModel(subLayer, model);
			var subLayerBuilder:Object = new HaxeLink.getHxContext().org.silex.core.SubLayerBuilder();
			subLayerBuilder.buildSubLayer(subLayer, subLayerModel, silex_ptr.rootUrl);
		}
	}
	
	/**
	 * Called by the org.silex.ui.Layer class after all players have been initialized.
	 * Check for deeplinks or default icons.
	 */
	function registeredLayerAllPlayersLoaded(ev:Object){
		//trace("registeredLayerAllPlayersLoaded "+ev.target);
		haveAllPlayersLoaded=true;

		// show after loading
		var ptr_mc:MovieClip=ev.target;
		while (ptr_mc && !ptr_mc.layerName){
			ptr_mc=ptr_mc._parent;
		}
		ptr_mc._visible=true;
		
		// check if deeplink target has been reached
		if(silex_ptr.deeplink.doApplyPath()==true){
			// check if a default icon should be opened
			if (defaultIcon!=undefined){
				defaultIcon.openIcon();
			}
		}
		dispatchEvent({type:  silex_ptr.config.LAYOUT_EVENT_ALL_PLAYERS_LOADED,target:this});
		
		silex_ptr.application.layoutLayersLoaded();
	}
	/**
	 * Called by the child layout component.
	 * The target will contain the child layouts.
	 * It has to be called on the 1st frame of a layout.
	 * org.silex.core.Application openSection can create one automatically at the layout root.
	 */
	function registerLayoutContainer(layoutContainer_mc:MovieClip){
		// silex_ptr.utils.alertSimple("registerLayoutContainer "+layoutContainer_mc);
		layoutContainer=layoutContainer_mc;
	}
	function registerDefaultIcon(player:org.silex.ui.players.PlayerBase) {
		// no more error since a context change can let a default icon appear/disappear
		/*
		if (defaultIcon)
		{
			// error
			// silex_ptr.utils.alert(silex_ptr.utils.revealAccessors(silex_ptr.config.WARNING_MULTIPLE_DEFAULT_ICON,{layout:this,player:player}));
		}
		*/
		defaultIcon=player;
	}
	function unRegisterDefaultIcon(player:org.silex.ui.players.PlayerBase) {
		if (defaultIcon==player) defaultIcon=undefined;
	}

}