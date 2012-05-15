/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
// EVENTS

//import mx.remoting.*;
//import mx.rpc.*;
//import mx.remoting.debug.NetDebug;
import org.silex.core.Utils;
import mx.events.EventDispatcher;

import mx.managers.DepthManager;

[Event("onLoadToolsManager")]

/**
 * This class manages the admin tools used in SILEX WYSIWYG
 * in the repository : /trunk/org/silex/core/ToolsManager.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-26
 * @mail : lex@silex.tv
 */
class org.silex.ui.ToolsManager extends mx.core.UIObject{
	var hasBeenShownAllready:Boolean=false;
	
	/**
	 * silex_ptr
	 * reference to silex main Api object (core.Api)
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * toolsLanguage
	 * current language for the tools
	 * used to determine the tools config file nmae
	 */
	var toolsLanguage:String;
	
	// UI
	// container for tools
	var toolsContainer_mc:MovieClip=null;
	
	// *****
	// workaround bug derived classes
	// toolbox to load one after another
	var toolsToLoad_array:Array; // array of toolboxes to load one after another
	var tools_mcl:MovieClipLoader; // movieclip loader
	// *****

	/**
	 * Constructor
	 * initialize reference to org.silex.core.Api, tools_mcl and toolsToLoad_array
	 */
	function ToolsManager(api:org.silex.core.Api){
		// api reference
		silex_ptr=api;
		
		// 
		toolsContainer_mc=silex_ptr.parent.createEmptyMovieClip("toolsContainer_mc",silex_ptr.parent.getNextHighestDepth());

		//eventDispatcher
		EventDispatcher.initialize(this);

		// workaround bug derived classes
		// toolbox to load one after another
		toolsToLoad_array=new Array;
		tools_mcl=new MovieClipLoader;
		var toolsMclListener_obj:Object=new Object;
		toolsMclListener_obj.onLoadInit=Utils.createDelegate(this,continueLoadingProcess);
		tools_mcl.addListener(toolsMclListener_obj);
	}
	function applicationResize() {
		// tools 
		silex_ptr.toolsManager.toolsContainer_mc._x=silex_ptr.application.stageRect.left;
		silex_ptr.toolsManager.toolsContainer_mc._y=silex_ptr.application.stageRect.top;

	}

	// *******************
	// load tool boxes
	function loadToolboxes(toolsLanguage_str:String){
	
		// default language = the one of the website
/*		if (toolsLanguage_str)
			toolsLanguage=toolsLanguage_str;
		else
			toolsLanguage=silex_ptr.config.adminLanguage;
			
		// default tool language file
		var toolsLanguageFile:String=silex_ptr.utils.revealAccessors(silex_ptr.config.toolsLanguageConfigFileName,{adminLanguage:toolsLanguage});
		
		// build files list
		var filesList:Array=new Array;
		filesList.push(toolsLanguageFile);
		filesList.push(silex_ptr.config.toolsConfigFileName);
		
		// call getDynData to load config files
		silex_ptr.com.getDynData(silex_ptr.config,filesList,Utils.createDelegate(this,doLoadToolboxes));
*/
		// do nothing
		doLoadToolboxes();
	}
		
	function doLoadToolboxes(result:Array){
		silex_ptr.application.overrideConfig(result);
		
		silex_ptr.com.listToolsFolderContent(silex_ptr.config.toolsFolderRelativePath,Utils.createDelegate(this,listToolsFolderContentCbk));

		// application events listener
		var applicationListener_obj:Object=new Object;
		applicationListener_obj.resize=Utils.createDelegate(this,applicationResize);
		silex_ptr.application.addEventListener("resize",applicationListener_obj);
		applicationResize();
	}
	function listToolsFolderContentCbk(folderContent_array:Array){
		for (var idx=0;idx<folderContent_array.length;idx++)
		{
			var tmpName_str:String=folderContent_array[idx][silex_ptr.config.itemNameField];
			var tmpType_str:String=folderContent_array[idx][silex_ptr.config.itemTypeField];
			
	
			if (tmpType_str=="file" && tmpName_str.substr(-4,4)==".swf")
			{// this is a file with swf extension
				var mcNameWithoutExt:String=tmpName_str.substring(0,tmpName_str.length-4);
				var temp_mc:MovieClip=toolsContainer_mc.createEmptyMovieClip(mcNameWithoutExt,toolsContainer_mc.getNextHighestDepth());
				// *****
				// workaround bug derived classes: toolbox are loaded one after another
				toolsToLoad_array.push({target:temp_mc,url:silex_ptr.config.initialToolsFolderPath+folderContent_array[idx][silex_ptr.config.itemNameField]});
				// *****
			}
		}
		continueLoadingProcess();
	}
	// *****
	// workaround bug derived classes
	// toolbox to load one after another
	function continueLoadingProcess(){
		if (toolsToLoad_array.length>0){
			var _obj:Object=toolsToLoad_array.shift();
			tools_mcl.loadClip(silex_ptr.rootUrl+_obj.url, _obj.target);
		}
		else{
			// end of loading process
			endLoadingProcess();
		}
	}
	// endLoadingProcess function
	// makes the container visible
	// NO: call tool.init();
	// NO: set initial positions of tool boxes
	function endLoadingProcess()
	{
		dispatchEvent({type:"onLoadToolsManager",target:this});
		toolsContainer_mc.swapDepths(silex_ptr.parent.getNextHighestDepth());
		toolsContainer_mc._visible=true;
		
		// display message
		silex_ptr.utils.alertSimple(silex_ptr.utils.revealAccessors(silex_ptr.config.MESSAGE_AUTH_SUCCESS,silex_ptr));

		// check latest SILEX version
		silex_ptr.com.getLatestSilexVersion(Utils.createDelegate(this,getLatestSilexVersionCallback));
		
		// in case we called loadToolboxes directly, not through showToolboxes(true)
		hasBeenShownAllready=true;
	}
	// show/hide tool boxes
	function showToolboxes(val)
	{
		toolsContainer_mc.swapDepths(silex_ptr.parent.getNextHighestDepth());
		if (hasBeenShownAllready==true)
		{// simply hide or show the tool boxes
			toolsContainer_mc._visible=val;
		}
		else
		{// we have to load the tool boxes
			if (val==true){
				hasBeenShownAllready=true;
				loadToolboxes();
				toolsContainer_mc._visible=false;
			}
		}
	}
	function unloadToolboxes(){
		for (var toolName_str:String in toolsContainer_mc){
			toolsContainer_mc[toolName_str].setDepthTo(DepthManager.kTop);
			tools_mcl.unloadClip(toolsContainer_mc[toolName_str]);
		}
		toolsToLoad_array=new Array;
		hasBeenShownAllready=false;
	}
	function reloadTools(toolsLanguage_str:String){
		unloadToolboxes();
		loadToolboxes(toolsLanguage_str);
	}
	function getLatestSilexVersionCallback(version:String) {
		
		silex_ptr.config.latestSilexVersion = version;

		// add version or tip
		if (version && version!=silex_ptr.config.version){
			// display message
			silex_ptr.utils.alertSimple(silex_ptr.utils.revealAccessors(silex_ptr.config.WARNING_OLD_VERSION_OF_SILEX,silex_ptr));
		}
	}
}