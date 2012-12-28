/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.core.component;
import flash.Lib;
import flash.MovieClip;
//import flash.MovieClipLoader;
import haxe.io.Error;
import haxe.Log;
import org.silex.publication.ComponentModel;
import org.silex.core.component.ComponentUtil;

/**
 * encapsulates loading and configuring a component. 
 * Use only once and discard.
 * 3 possibilities:
 * - the component is contained in a lib that is already loaded. It is added and configured synchronously.
 * - the component is contained in a lib that is not yet loaded. The lib is loaded(asynchronously), and then the component is added (synchronously)
 * - the component is not in a lib, as in we have no lib in the model. The component is added using a movie clip loader. This is the system that is used with 
 * components without component descriptors.
 * note: to load the component from a lib, the component's "export for actionscript" symbol name must be in the model as metaDta/className. It is called "className"
 * because "symbol name" is too Flash-centric, and sometime in the future we will want non visual components, and it will really be a class that will be instanciated.
 * @author Ariel Sommeria-klein sommeria.ariel (at) gmail.com
 */

class ComponentLoader 
{
	private var _model:ComponentModel;
	private var _hostClip:MovieClip;
	private var _componentInstanceName:String;
	private var _depth:Int;
	private var _serverRootUrl:String;
	
	/**
	 *  
	 * @param	hostClip
	 * @param	model
	 * @param depth 
	 * @param serverRootUrl used to resolve relative urls
	 *  
	 *  */
	public function new(hostClip:MovieClip, model:ComponentModel, depth:Int, serverRootUrl:String) 
	{
		_model = model;
		_hostClip = hostClip;
		_depth = depth;
		_serverRootUrl = serverRootUrl;
	}

	/**
	*  use a full table of properties on a component. This is very DOM specific, so this is shipped out to its own function
	*  copy the properties into a Hash so that they can be modified before application to the object without messing with the model
	*  This is necessary to avoid looking for each property if it can be set "as is" or not 
	*  properties can either apply directly to component root, or apply to a subClip. property path must be indicated with "." separator, eg : tf.font
	*  */
	private function applyProperties(componentRoot:MovieClip, properties:Hash<Dynamic>):Void{
		var propertiesCopy:Hash<Dynamic> = new Hash<Dynamic>();
		for (propertyName in _model.properties.keys()) {
			propertiesCopy.set(propertyName, _model.properties.get(propertyName));
		}
		//flash.Lib.trace("applyProperties " + properties.get("playerName"));
		
		//set dom specific properties first, and remove them to avoid them being used twice
		componentRoot._x = propertiesCopy.get("x");
		propertiesCopy.remove("x");
			
		componentRoot._y = propertiesCopy.get("y");
		propertiesCopy.remove("y");
			
		componentRoot._xscale = propertiesCopy.get("xscale");
		propertiesCopy.remove("xscale");
			
		componentRoot._yscale = propertiesCopy.get("yscale");
		propertiesCopy.remove("yscale");
			
		componentRoot._alpha = propertiesCopy.get("alpha");
		propertiesCopy.remove("alpha");
			
		componentRoot._rotation = propertiesCopy.get("rotation");
		propertiesCopy.remove("rotation");
			
		ComponentUtil.sizeComponent(componentRoot, propertiesCopy.get("width"), propertiesCopy.get("height"));
		propertiesCopy.remove("width");
		propertiesCopy.remove("height");
		
		//everything that is left can be set "as is"

		for (propertyName in propertiesCopy.keys()) {
								
			var propertyValue:Dynamic = propertiesCopy.get(propertyName);
			if(propertyName.indexOf(".") != -1){

				var split = propertyName.split(".");
				var simplePropertyName:String = split.pop();
				var subClip:MovieClip = componentRoot; 
				for(subClipName in split){
					subClip = Reflect.field(subClip, subClipName);
				}
				//flash.Lib.trace("subClip" + subClip + ", simplePropertyName" + simplePropertyName);
				Reflect.setField(subClip, simplePropertyName, propertyValue);	
				
			}else{
				Reflect.setField(componentRoot, propertyName, propertyValue);			
			}
			//flash.Lib.trace("setting" + propertyName + ", " +  propertyValue);
		}
		
		
	}
	
	/**
	*  on uibase we have a "layerInstace". if not uibase, we need to find the layer by looking in the clip hierarchy.
	*  recognize Layer by presence of "initLayer" function. Cheap hack, hopefully temporary. A.S.
	*  */
	private function findLayerInstance(componentRoot:MovieClip):MovieClip{
		var nextUp:MovieClip = componentRoot;
		while(nextUp._parent != null){
			nextUp = nextUp._parent;
			if(nextUp.initLayer){
				return nextUp;
			}
		}
		return null;
		
	}
	/**
	 * initializes the component. 
	 *  if componentRoot is specified, it uses that as root of the component, not the passed clip. If none is given, it looks for a "main", and it has one of those, uses that
	 *  this should disappear soon
	 *  
	 * calls the doBeforeConfig function if the component has one
	 * sets the properties
	 * sets the actions
	 * calls the doAfterConfig function if the component has one
	 * @param	component
	 */	
	private function initComponent(component:MovieClip):Void {
		//flash.Lib.trace("initComponent" + component + Std.string(_model));
		
		var componentRoot:MovieClip = null;
		if(_model.componentRoot != null){
			componentRoot = Reflect.field(component, _model.componentRoot);
		}else{
			if(component.main != null){
				componentRoot = component.main;
			}
		}
		
		if(componentRoot.doBeforeConfig){
			componentRoot.doBeforeConfig();
		}
		
		applyProperties(componentRoot, _model.properties);
		
		for (actionModel in _model.actions.iterator()) {
			var untypedAction:Dynamic = {};
			untypedAction.functionName = actionModel.functionName;
			untypedAction.modifier = actionModel.modifier;
			untypedAction.parameters = new Array();
			for (parameter in actionModel.parameters.iterator()) {
				untypedAction.parameters.push(parameter);
			}
			componentRoot.actions.push(untypedAction);
			//flash.Lib.trace("untypedAction" + Std.string(untypedAction));
			
		}
		
		var layerInstance:MovieClip = findLayerInstance(componentRoot);
		//flash.Lib.trace("layerInstance" + layerInstance);
		layerInstance.registerPlayer(componentRoot);		
		if(componentRoot.doAfterConfig){
			componentRoot.doAfterConfig();
		}
		
	}
	
	/**
	 * if the host clip is a SubLayer and has a players array, create a "component load info" object, an untyped object containing information about the component
	 * that was just added. 
	 *  somehow sometimes this is called before the layer constructor is executed. 
	 */
	private function registerComponent():Void {
		//flash.Lib.trace("registerComponent" + _hostClip + _hostClip.players + _componentInstanceName);
		if (_hostClip.players) {
			var componentLoadInfo:Dynamic = {};
			componentLoadInfo._name = _componentInstanceName;
			componentLoadInfo.type = LegacyPlayerTypes.COMPONENT;
			componentLoadInfo.mediaUrl = _model.as2Url;
			componentLoadInfo.className = _model.className;
			componentLoadInfo.label = _model.properties.get(ComponentModel.FIELD_PLAYER_NAME);
			_hostClip.players.push(componentLoadInfo);
		}
	}
	
	/**
	 * initializes the component and also maintains the legacy model where the SubLayer has a "players" array.
	 * @param	target_mc
	 */
	private function onComponentLoadInit(target_mc:MovieClip) {
		//flash.Lib.trace("onComponentLoadInit");
		initComponent(target_mc);
	}
	
	private function onLoadError(target_mc:MovieClip, errorCode:String, httpStatus:Float ) {
		 trace("onLoadError" + target_mc + errorCode + httpStatus);
		// Log.trace("load error");
		 var hookManager:Dynamic = Lib._global.org.silex.core.plugin.HookManager.getInstance();
		 hookManager.callHook("componentLoadError");
	}
	
	/**
	 * returns a string containing a random whole number. Use as instance name to avoid collisions.
	 * @return
	 */
	private function generateInstanceName():String {
		return Std.string(Math.round(Math.random() * 1000000));
	}
	
	/**
	*  checks if an url is relative, and if it is, adds the server root url
	*  might be updated for accessors or stuff like that in the future
	*  this is a separate function because strictly speaking it does not belong in this class and it would be good to find a better home for it
	*  */
/*	private function resolveUrl(url:String, serverRootUrl:String):String{
		if(url.indexOf("http://") == -1){
			return serverRootUrl + url;
		}else{
			return url;
		}
	}
	/**
	 * load a component into a host movie clip.
	 * a movie clip loader loads into an empty clip or eventually overwrites an existing one. Use this merthod to create a container in a host clip.
	 * the container has a random instance name to avoid collisions and is added at the next available highest depth
	 */
	public function load():Void {
		
		trace("load in " + _hostClip + ", class " +  _model.className + ", as2url : " +  _model.as2Url + " at depth" + _depth);
	
		_componentInstanceName = generateInstanceName();
		
		//registering must be done right at beginning, because a SubLayer needs to count its contained components to know when they are all loaded
		registerComponent();
		
//		var movieClipLoader:MovieClipLoader = new MovieClipLoader();
		var listener:Dynamic = { onLoadInit:onComponentLoadInit, onLoadError:onLoadError };
//		movieClipLoader.addListener(listener);
		var componentContainer:MovieClip = _hostClip.createEmptyMovieClip(_componentInstanceName, _depth);
//		var fullUrl:String = resolveUrl(_model.as2Url, _serverRootUrl);
//		movieClipLoader.loadClip(fullUrl, componentContainer);	

		var silexInstance:Dynamic = Lib._global.getSilex();
		
		silexInstance.utils.loadMedia(_model.as2Url,componentContainer, "swf", listener);

	}
	
}