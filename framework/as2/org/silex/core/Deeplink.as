/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;
import mx.events.EventDispatcher;
/* listen to
org.silex.core.Application 
[Event("layoutLoaded")]
[Event("playersLoaded")]
[Event("allPlayersLoaded")]
*/


/*
 * events
 */
//[Event("urlChanged")]
//[Event("followDeepLink")]
/**
 * This class handles the deeplinks : when to change the deeplink through javascript and when to open pages corresponding to the html deeplink value.
 * In the repository : /trunk/core/Deeplink.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-25
 * @mail : lex@silex.tv
 */
class org.silex.core.Deeplink extends mx.core.UIObject{
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * Array corresponding to the path of the currently displayed page.
	 * @example	[start,silex,home]
	 */
	var deeplink_array:Array;

	/**
	 * String corresponding to the path of the currently displayed page or the page which is openning.
	 * Corresponds to deeplink_array.
	 * @example	start/silex/home
	 */
	function get currentPath():String{
		return getCurrentPath().join("/");
	}
	function set currentPath(newPath_str:String){
		applyPath(newPath_str);
	}
	/**
	 * Reflects the hash value, i.e. javascript's silexJsObj.currentHashValue and html hash value.
	 */
	var currentHashValue:String = "";
	/**
	 * Reflects the html page title.
	 */
	var currentPageTitle:String="";
	/**
	 * Constructor.
	 * @param	api					reference to silex main Api object (org.silex.core.Api)
	 * @param	initialPath			string corresponding to the path of the page to be displayed at start
	 * @param	initialPageTitle	string corresponding to the title of the page to be displayed at start
	 */
	function Deeplink(api:org.silex.core.Api,initialPath:String,initialPageTitle:String){
		
		// store Api reference
		silex_ptr=api;

		//eventDispatcher
		EventDispatcher.initialize(this);
		
		// current path
		if (initialPath) currentPath=initialPath;
		else currentPath="";
		
		// init currentHashValue with javascript currentHashValue
		currentHashValue=initialPath;
		currentPageTitle=initialPageTitle;

		// listen to layoutLoaded event to update url hash
		var listener_obj:Object=new Object;
/*		listener_obj.onBgRelease=Utils.createDelegate(this,checkHash);
		silex_ptr.application.addEventListener("onBgRelease",listener_obj);
/**/	listener_obj.playersLoaded=Utils.createDelegate(this,checkHash);
		silex_ptr.application.addEventListener("playersLoaded",listener_obj);
		listener_obj.allPlayersLoaded=Utils.createDelegate(this,checkHash);
		silex_ptr.application.addEventListener("allPlayersLoaded",listener_obj);
/**/
		listener_obj.layoutLoaded=Utils.createDelegate(this,checkHash);
		silex_ptr.application.addEventListener("layoutLoaded",listener_obj);
/**/	}
	/**
	 * Check if javascript's url hash need to be updated.
	 */
	function checkHash() {
		var currentPath_str:String=currentPath;
		if (currentHashValue!=currentPath_str && deeplink_array.length==0){
			setHash(currentPath_str);
		}
	}
	/**
	 * Update javascript and silex currentHashValue.
	 */
	function setHash(newHashValue) {
		// call javascript
		var params:String="'"+silex_ptr.utils.addslashes(newHashValue)+"'";
		if (currentPageTitle) params+=",'"+silex_ptr.utils.addslashes(currentPageTitle)+"'";
		var jsCommand_str:String="silexJsObj.changeSection("+params+");";
		
		if (silex_ptr.config.ENABLE_DEEPLINKING!="false")
			silex_ptr.com.jsCall(jsCommand_str);
		//_root.getURL("javascript:"+jsCommand_str);
		
		// update currentHashValue
		currentHashValue=newHashValue;
		
		// debug
	}
	/**
	 * Change the current website name.
	 * Ask javascript to display a different website name after the "#".
	 * @param	id_site	new name
	 */
	function changeWebsite(id_site:String){
		var jsCommand_str:String="silexJsObj.changeWebsite('"+id_site+"');";
		silex_ptr.com.jsCall(jsCommand_str);
	}
	/**
	 * Build the current path from the opened pages.
	 * Parse all the org.silex.core.Layout objects of the application.
	 * @return	the path of the displayed page
	 */
	function getCurrentPath():Array{
		var layout_ptr:org.silex.core.Layout=silex_ptr.application.layoutContainer.silexLayout;
		// parse the org.silex.core.Layout objects
		var res_array:Array=new Array;
		while (layout_ptr){
			// store page name
			res_array.push(layout_ptr.deeplinkName);
			// store last page title for javascript
			currentPageTitle=layout_ptr.sectionName;
			// next layout object
			layout_ptr=layout_ptr.currentChildLayoutContainer.silexLayout;
		}
		return res_array;
	}
	/**
	 * Parse the org.silex.core.Layout objects until a specific layout.
	 * Used to get a layout path.
	 * Used by org.silex.core.Application::save().
	 * @return	the path of the page opened on the layout
	 */
	function getLayoutPath(targetLayout_ptr:org.silex.core.Layout):Array{
		// parse the org.silex.core.Layout objects until a specific layout
		var layout_ptr:org.silex.core.Layout=silex_ptr.application.layoutContainer.silexLayout;
		var res_array:Array=new Array;
		while (layout_ptr){
			// store page name
			res_array.push(layout_ptr.deeplinkName);
			// if this was the target, let's stop parsing
			if (layout_ptr==targetLayout_ptr)
				break;
			// next layout object
			layout_ptr=layout_ptr.currentChildLayoutContainer.silexLayout;
		}
		return res_array;
	}
	/**
	 * Build the deeplink array with the section names that need to be applied (remove those which are already opened).
	 * Open the first section which has to be opened.
	 * @param	path_str	the targeted path
	 */
	function applyPath(path_str:String) {
		
		// replaced by a call from org.silex.core.Layout.registerLayer() : 
		// silex_ptr.sequencer.addEventListener("onEnterFrame",this);

		// build the deeplink_array
		deeplink_array=path_str.split("/");
		// clean the array
		var idx:Number=0;
		while(deeplink_array && idx<deeplink_array.length){
			if (!deeplink_array[idx] || deeplink_array[idx]=="")
				deeplink_array.splice(idx,1);
			else idx++;
		}
		// apply new path
		doApplyPath();
	}
	/**
	 * Check if a deeplink has to be reached and reset deeplink_array if we reachd the target.
	 * @return true if the deeplink target has been reached
	 */
	function doApplyPath():Boolean{
		if (!deeplink_array || deeplink_array.length==0) return true;
		
		// parse the org.silex.core.Layout objects
		var parentLayout_ptr:org.silex.core.Layout=null;
		var layout_ptr:org.silex.core.Layout=silex_ptr.application.layoutContainer.silexLayout;
		var deeplinkIdx_num:Number=0;
		while (layout_ptr){
			// check page name
			if (deeplink_array[deeplinkIdx_num]!=layout_ptr.deeplinkName){
				// open the section
				parentLayout_ptr.dispatchEvent({type:"onDeeplink",target:parentLayout_ptr,deeplinkName:deeplink_array[deeplinkIdx_num],/*deprecated - for compatibility : */cleanSectionName:deeplink_array[deeplinkIdx_num]});
				//openSection(sectionName_str,null,parentLayout_ptr);
				// break so that deeplink_array will contain all the subsections
				break;
			}
			// next layout object
			deeplinkIdx_num++;
			parentLayout_ptr=layout_ptr;
			layout_ptr=layout_ptr.currentChildLayoutContainer.silexLayout;
		}
		// is path fully displayed (reached target)?
		if (deeplinkIdx_num==deeplink_array.length){
			// yes => empty the deeplink_array
			deeplink_array=new Array;
			// silex_ptr.sequencer.removeEventListener("onEnterFrame",this);
			return true;
		}
		else{
			// try to open next deeplink in the deepest layout
			parentLayout_ptr.dispatchEvent({type:"onDeeplink",target:parentLayout_ptr,deeplinkName:deeplink_array[deeplinkIdx_num],/*deprecated - for compatibility : */cleanSectionName:deeplink_array[deeplinkIdx_num]});
			return false;
		}
	}
/*	replaced by a call from org.silex.core.Layout.registerLayer()
	function onEnterFrame () {
		// dispatch event
		//dispatchEvent({type:"newLayer",target:this});
		doApplyPath();
	}*/
}