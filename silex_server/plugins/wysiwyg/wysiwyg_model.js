/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


/**
 * Name space for silex Api
 */
var silexNS;
if(!silexNS)
	silexNS = new Object;

/**
 * name space for wysiwyg
 */
var wysiwygNS;
if(!wysiwygNS){
	wysiwygNS = new Object();
}

/**
 * class for managing the wysiwyg model. This is the part that is in JS, some is straight in AS2. This separation is handled automatically by SilexAdminAdpi.
 * note on construction: it would be nice in the setters to compare state and see that maybe it's not necessary to refresh, but that's not possible, because
 * sometimes the model is out of date: for example if the user closes the popup, isToolBoxVisible stays to true, and we cannot set it to false because
 * it has bad side effects, for example when switching back to div mode. So ideally this should be fixwed, but at the moment isn't
 */
wysiwygNS.WysiwygModelClass = function ()
{
	this.WysiwygModelClass();
};

wysiwygNS.WysiwygModelClass.prototype = {
	/**
	 * event called on set zoom
	 * DEPRECATED
	 */
//	EVENT_ZOOM_CHANGED : "EVENT_ZOOM_CHANGED",
	
	/**
	 * event called when wysiwyg visibility changed
	 */
	EVENT_WYSIWYG_VISIBILITY_CHANGED : "EVENT_WYSIWYG_VISIBILITY_CHANGED",
	
	/**
	 * event called when tool box visibility changed
	 */
	EVENT_TOOL_BOX_VISIBILITY_CHANGED : "EVENT_TOOL_BOX_VISIBILITY_CHANGED",
	
	/**
	 * event called when tool box DisplayMode changed
	 */
	EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED : "EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED",
	
	/**
	 * display mode for the tool box. in a div. public
	 */
	TOOLBOX_DISPLAY_MODE_DIV : 0,
	
	/**
	 * display mode for the tool box. in a popup. public
	 */
	TOOLBOX_DISPLAY_MODE_POPUP : 1,
	
	/**
	 * is the wysiwyg visible. private
	 */
	isWysiwygVisible : true,
	/**
	 * is the tool box visible. private
	 */
	isToolBoxVisible : false,
	/**
	 * the zoom on the stage. private
	 * DEPRECATED
	 */
//	zoom : 100,

	/**
	 * the tool box display mode. private, access using getter and setter. use TOOLBOX_DISPLAY_MODE_XXX constants 
	 */
	toolBoxDisplayMode: 0,
	
	/**
	 * save the wysiwyg div HTML so we can reload when switching from pop-up to div
	 */
	wysiwygDiv: null,
	
	/**
	 * Constructor
	 */
	WysiwygModelClass : function ()
	{
		/**
		 * unnecessary at the moment, but just in case the constants change in the future
		 */
		this.toolBoxDisplayMode = this.TOOLBOX_DISPLAY_MODE_DIV;
		
		
	},
	
	/**
	 * apply the model to the different elements
	 */	
	refresh : function()
	{
		var spaceTakenFromBottom = 0;
		//view menu
		if(this.isWysiwygVisible){
			$("#viewMenuContent").css( { "height": "35px",  "bottom": "0px" } );
			spaceTakenFromBottom += 35;
		}else{
			$("#viewMenuContent").css( { "height": "0px",  "bottom": "0px" } );
		}
		//tool box
		var showPopup = false;
		var showToolBoxDiv = false;
		if(this.isWysiwygVisible && this.isToolBoxVisible){
			if(this.toolBoxDisplayMode == this.TOOLBOX_DISPLAY_MODE_DIV){
				showToolBoxDiv = true;
			}else{
				showPopup = true;
			}
		}
		//alert("this.isWysiwygVisible : " + this.isWysiwygVisible + ", this.isToolBoxVisible : " + this.isToolBoxVisible + ", this.toolBoxDisplayMode : " + this.toolBoxDisplayMode);
		//alert("showPopup : " + showPopup + ", showToolBoxDiv : " + showToolBoxDiv);
		if (showPopup) {
			wysiwygNS.popupManager.showPopup();
		}else{ 
			wysiwygNS.popupManager.removePopup();
		}
		if(showToolBoxDiv){
				$("#toolBoxContent").css( { "height": "290px", "bottom": spaceTakenFromBottom + "px" } );
				
				spaceTakenFromBottom += 290;
		}else{
			
			
			$("#toolBoxContent").css( { "height": "0px", "bottom": "0px" } );
			$("#toolBoxContent").html("");
		}		
		
		//silex stage
		//note: window.size not a standard function, is defined above
		$('#silexScene').css( { "height":($(window).height() - spaceTakenFromBottom) + "px", "top":"0px"} );
		
		//zoom
/*		NO : bug of the vertical scroll wich disappears (noScale mode) and disturbs the silexNS.SilexApi::resize method
		availableWidth = $('#silexScene').width();
		newWidth = availableWidth * this.zoom / 100;
		availableHeight = $('#silexScene').height();
		newHeight = availableHeight * this.zoom / 100;
		$('#silex').css( { "width": newWidth + "px", "height": newHeight + "px"} );
*/		
		// redraw all tools - no because it creates a loop
		// silexNS.HookManager.callHooks({type:"refreshWorkspace"});
	},
	
/*	getZoom : function(){
		return this.zoom;
	},
	*/
	/**
	 * zoom the silex stage
	 * @param {Number} value The percentage to zoom at. 100 is normal, less is smaller, more is bigger. When at more than 100% scroll
	 * bars appear allowing the user to manipulate the position 
	 * DEPRECATED
	 */
/*	setZoom : function (value)
	{
		this.zoom = value;
		this.refresh();
		silexNS.SilexAdminApi.dispatchEvent({targetName:"wysiwygModel", type:this.EVENT_ZOOM_CHANGED});
	},
*/	
	/**
	 * get the visibility of the wysiwyg
	 * @returns Boolean
	 */
	getWysiwygVisibility : function (){
		return this.isWysiwygVisible;
	},
	
	/**
	 * set the visibility of the wysiwyg
	 * @param {Boolean} value
	 */
	setWysiwygVisibility : function (value){
		this.isWysiwygVisible = value;
		this.refresh();
		silexNS.SilexAdminApi.dispatchEvent({targetName:"wysiwygModel", type:this.EVENT_WYSIWYG_VISIBILITY_CHANGED});
	},	
	
	/**
	 * get the visibility of the tool box
	 * @returns Boolean
	 */
	getToolBoxVisibility : function (){
		return this.isToolBoxVisible;
	},
	
	/**
	 * set the visibility of the tool box
	 * @param {Boolean} value
	 */
	setToolBoxVisibility : function (value){
		this.isToolBoxVisible = value;
		this.refresh();
		silexNS.SilexAdminApi.dispatchEvent({targetName:"wysiwygModel", type:this.EVENT_TOOL_BOX_VISIBILITY_CHANGED});
		
		// redraw all tools
		silexNS.HookManager.callHooks({type:"refreshWorkspace"});
	},

	/**
	 * get the DisplayMode of the tool box
	 * @returns Boolean
	 */
	getToolBoxDisplayMode : function (){
		return this.toolBoxDisplayMode;
	},
	
	/**
	 * set the DisplayMode of the tool box
	 * @param {Boolean} value
	 */
	setToolBoxDisplayMode : function (value){
		var previousDisplayMode = this.toolBoxDisplayMode;
		this.toolBoxDisplayMode = value;
		
		
		
		if ( $("#toolBoxContent").html() != "")
		{
			this.wysiwygDiv = $("#toolBoxContent").html();
		}
		else
		{
			wysiwygNS.initToolBox();
			this.wysiwygDiv = $("#toolBoxContent").html();
			//wysiwygNS.alreadyLoaded = 
		}
		
		if (value == this.TOOLBOX_DISPLAY_MODE_POPUP)
		{
			$("#toolBoxContent").html("");
			
		}
		
		else if (value == this.TOOLBOX_DISPLAY_MODE_DIV)
		{
			if ( $("#toolBoxContent").html() == "")
			{
				silexNS.SilexAdminApi.callApiFunction("historyManager", "flush", null);
				$("#toolBoxContent").html(this.wysiwygDiv);
				var toolBox = $('#toolBox')[0];
				silexNS.SilexAdminApi.addEventListener(toolBox);
			}
		}
		
		//this.refresh();
		
		silexNS.SilexAdminApi.dispatchEvent({targetName:"wysiwygModel", type:this.EVENT_TOOL_BOX_DISPLAY_MODE_CHANGED});
	},
	
	/**
	* called when the user logs out, to clean selection
	*/
	logout : function (){
		silexNS.SilexAdminApi.callApiFunction("components", "select", []);
		silexNS.SilexAdminApi.callApiFunction("layers", "select", []);
		silexNS.SilexAdminApi.callApiFunction("layouts", "select", []);
		silexNS.SilexAdminApi.callApiFunction("historyManager", "flush", null);
	}
	
	
};	
