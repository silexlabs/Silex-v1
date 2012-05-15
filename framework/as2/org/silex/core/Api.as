/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
//import mx.events.EventDispatcher;
//import net.alexisisaac.flide.Flide

import org.silex.core.Utils;

/**
 * This class handle the loading process and has references to singletons.
 * In the repository : /trunk/core/Api.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-19
 * @mail	lex@silex.tv
 */
class org.silex.core.Api /*extends mx.core.UIObject*/
{
	// **
	// Attributes
	// **
	
	/**
	 * true only if you use the whole SILEX server framework (Wysiwyg etc)
	 */
	var isSilexServer:Boolean=false;
	
	/**
	 * The object which contains the api singleton.
	 * It is the root of the silex server if isSilexServer is true.
	 */ 
	var parent:MovieClip;

	// constants and config variables
	/**
	 * Dynamic object which contains all the constants localized or configuration.
	 * If a variable is called on this object and does not exist, SILEX try to find the variable in the constants object before returning null.
	 * This is the process used to override the constants values.
	 */
	var config:Object;
	
	/**
	 * Static object.
	 * Contains the default - hard coded, constant values.
	 */
	var constants:org.silex.core.Constants;

	// org.silex.core classes
	/**
	 * Reference to the Authentication singleton.
	 * @see	Authentication
	 */
	var authentication:org.silex.core.Authentication;
	/**
	 * Reference to the Interpreter singleton.
	 * @see	Interpreter
	 */
	var interpreter:org.silex.core.Interpreter;
	/**
	 * Reference to the Filter singleton.
	 * @see	Filter
	 */
	var filter:org.silex.core.Filter;
	/**
	 * Reference to the Application singleton.
	 * @see	Application
	 */
	var application:org.silex.core.Application;
	/**
	 * Reference to the Sequencer singleton.
	 * @see	Sequencer
	 */
	var sequencer:org.silex.core.Sequencer;
	/**
	 * Reference to the Com singleton.
	 * @see	Com
	 */
	var com:org.silex.core.Com;
	/**
	 * Reference to the Deeplink singleton.
	 * @see	Deeplink
	 */
	var deeplink:org.silex.core.Deeplink;
	/**
	 * Reference to the DynDataManager singleton.
	 * @see	DynDataManager
	 */
	var dynDataManager:org.silex.core.DynDataManager;
	/**
	 * Reference to the Utils singleton.
	 * @see	Utils
	 */
	var utils:org.silex.core.Utils;
	/**
	 * Reference to the XmlDom singleton.
	 * @see	XmlDom
	 */
	var xmlDom:org.silex.core.XmlDom;
	/**
	 * Reference to the ToolsManager singleton.
	 * @see	ToolsManager
	 */
	//var toolsManager:org.silex.ui.ToolsManager;
	/**
	 * Reference to the HookManager singleton.
	 * @see	HookManager
	 */
	var hookManager:org.silex.core.plugin.HookManager;
		
	/**
	 * plugin holder clip. An empty movie clip added to clip that instanciates silex, where plugins can be loaded. 
	 * */
	public var pluginsContainer_mc:MovieClip;
	
	
	/**
	 * Root url of the application (read only).
	 */
	function get rootUrl():String{
		return utils.getRootUrl();
	}
	//static var _instance:Api;
	// entry point
	static function main(mc) {
		mc._parent.silexApi = new org.silex.core.Api(mc._parent,true);
	}	
	/**
	 * Constructor.
	 * Initialize all the framework's classes.
	 * Start the loading process (config, preload, layout, xml, ...).
	 */
	function Api(apiContainer_mc:MovieClip, argIsSilexServer:Boolean)
	{
		

		
		// starts wmode patch
		//TransparentWModePatch.getInstance();
		
		// store isSilexServer value (default is false)
		if (argIsSilexServer==true) isSilexServer=true;
		
		//eventDispatcher
		//EventDispatcher.initialize(this);

		// **
		// api container
		//
		// default value for the api container
		if (!apiContainer_mc) apiContainer_mc = _root;
		
		// store api container
		parent=apiContainer_mc;
		
		// **
		// global getSilex function
		if (!_global.getSilex)
			_global.getSilex=Utils.createDelegate(this,getSilexV1);

		
		// **
		// constants and config variables
		//
		constants=new org.silex.core.Constants;
		config=new Object;
		config.__resolve=Utils.createDelegate(this,getConfigData);


		// **
		// org.silex.core classes
		//
		utils=new org.silex.core.Utils(this);
		sequencer=new org.silex.core.Sequencer(this);

		xmlDom=new org.silex.core.XmlDom(this);
		com=new org.silex.core.Com(this);
		dynDataManager=new org.silex.core.DynDataManager(this);
		interpreter=new org.silex.core.Interpreter(this);
		filter=new org.silex.core.Filter(this);
		//toolsManager=new org.silex.ui.ToolsManager(this);
		hookManager=org.silex.core.plugin.HookManager.getInstance();
		authentication=new org.silex.core.Authentication(this);
		application=new org.silex.core.Application(this);
		deeplink=new org.silex.core.Deeplink(this,config.initialPath); // needs to be after application
		
		pluginsContainer_mc = parent.createEmptyMovieClip("pluginContainer_mc", parent.getNextHighestDepth());
		// context watcher
		config.watch("globalContext", Utils.createDelegate(this, globalContextChange));
	}
	/**
	 * method referenced by _global.getSilex()<br/>
	 * will return this
	 */
	function getSilexV1(target_mc:MovieClip) {
		return this;
	}

	/**
	 * Called when a property of config object is requested.
	 * Returns the corresponding property of _root (passed to flash by javascript).
	 * If it is undefined, then look in the constants.
	 * @param 	name_str		the name of the constant or config variable to retrieve
	 * @return					the value of the desired constant or config variable
	 */
	function getConfigData(name_str:String):Object{
		var res_obj:Object=_root[name_str];
		if (res_obj==undefined) res_obj=constants[name_str];

		return res_obj;
	}
	/**
	 * Callback function called when the global context of the website changes.
	 * Causes all layers to refresh.
	 * @param	oldVal	old value of the context
	 * @param	newVal	new value of the context
	 */
	function globalContextChange(prop, oldVal, newVal){
		// next frame, refresh all layers
		sequencer.addItem(null,Utils.createDelegate(application,application.refreshAllLayers));
		return newVal;
	}
}