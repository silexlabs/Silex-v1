/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

wysiwygNS.PopupManagerClass = function (popupWidth, popupHeight, popupUrl){
	this.PopupManagerClass(popupWidth, popupHeight, popupUrl);
}

/**
 * name space for wysiwyg
 */
var wysiwygNS;
if(!wysiwygNS){
	wysiwygNS = new Object();
}

wysiwygNS.PopupManagerClass.prototype = {
	
	/**
	 * Reference to the popup window
	 */
	popupWin : null,
	/**
	 * Popup window initial width
	 */
	popupWidth : null,
	/**
	 * Popup window initial height
	 */
	popupHeight : null,
	/**
	 * Popup window url
	 */
	popupUrl : null,
	/**
	 * Random popup window id
	 */
	popupRandomId : null,
	/**
	 * Constructor.
	 * @attribute	popupWidth	width of the popup which can be opened by the class
	 * @attribute	popupHeight	height of the popup which can be opened by the class
	 * @attribute	popupUrl	URL of the popup which can be opened by the class
	 */
	PopupManagerClass : function(popupWidth, popupHeight, popupUrl)
	{
		this.popupRandomId = Math.floor(Math.random()*9999).toString();
		this.popupWidth = popupWidth;
		this.popupHeight = popupHeight;
		this.popupUrl = popupUrl;
		window.onbeforeunload = delegate(this, this.__PopupManagerClass);
	},	
	
	/**
	 * Destructor.
	 * Destroy the popup and clean up.
	 */
	__PopupManagerClass : function()
	{
		this.removePopup();
	},
	
	/**
	 * Open the popup window or bring it to front.
	 */
	showPopup : function()
	{
			/*
			$str = "";
			for (var idx in $(window))
				$str += (idx+ " - ");
			alert($str);
			alert ( $(window).position);
			alert($(window).height());
			*/
		if (!this.popupWin)
		{
			// open popup
			var $config='toolbar=no, menubar=no, resizable=yes, directories=no, status=no, height='+this.popupHeight+', width='+this.popupWidth; // fullscreen=yes
			//alert("showPopup. url : " + this.popupUrl);
			this.popupWin = window.open (this.popupUrl, this.popupRandomId, config=$config);
			// position : TODO
			//$pos = $(window).position();
			//this.popupWin.moveTo(pos.left,pos.top + $(window).height);

			// be sure it has me. TODO: check this is useless!
//			if (!this.popupWin.opener)
	//		    this.popupWin.opener = self;
			
		}
		else
		{
			this.bringPopupToFront();
		}
	},
	/**
	 * Destroy the popup window.
	 */
	removePopup : function()
	{
		if (this.popupWin){
			this.popupWin.close();
			this.popupWin = null;
		}
	},
	
	/**
	 * bring the popup window to top.
	 */
	bringPopupToFront : function()
	{
		if (this.popupWin)
		{
			this.popupWin.focus();
		}
	},
	
	/**
	 * Resize the popup window.
	 */
	resizePopup : function()
	{
		trace("resizePopup not implemented yet");
	},
	/**
	 * Move the popup window.
	 */
	movePopup : function()
	{
		trace("movePopup not implemented yet");
	},
	
	/**
	 * callback called by popup when it is closed by user. removes reference to it
	 * */
	onPopupClosed : function(){
		//alert("onPopupClosed. this.popupWin : " + this.popupWin);
		this.popupWin = null;
	}
}