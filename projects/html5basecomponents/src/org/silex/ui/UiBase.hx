/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.ui;
import php.Web;

/**
*  This class implements UiBase for HTML5 version of components.
*/
class UiBase extends MovieClip
{
	private var playerName : String;
	private var descriptionText : String;
	private var tags : Array<Dynamic>;
	private var iconPageName : String;
	private var iconDeeplinkName : String;
	private var iconLayoutName : String;
	private var iconIsIcon : Bool;
	private var iconIsDefault : Bool;
	private var url : String;
	private var visibleOutOfAdmin : Bool;
	private var tooltipText : String;
	private var tabEnabled : Float;
	private var tabIndex : Int;
	
	private var __silex__layerPath__ : Array<String>;
	private var __silex__publicationName__ : String;
	//The interpreter (haXe/PHP for "static html") modifies this variable to reflect the action.
	private var __silex__actionshref__ : String;
	
	/**
	*  This function is called by the htmlGenerator engine to get the component's HTML representation.
	*/
	public function getHTML()
	{
		var res = "";
		var styleVisible = "visibility:visible;";
		
		//Visibility
		if(!this.visibleOutOfAdmin)
		{
			styleVisible = "visibility:hidden;";
		}
		
		//Icons take precedence over actions
		if (iconIsIcon && (iconDeeplinkName =="" || iconDeeplinkName == null))
		{
			// md lex, pretty url
			//res += "<a href='?/"+ __silex__publicationName__ + "/" + __silex__layerPath__.join("/") + "/" + this.iconPageName + "&amp;format=html&amp;selectedIcon=" + StringTools.urlEncode(this.__silex__layerPath__.join(".") + "." + this.playerName) + "'>";
			res += "<a href='?/"+ __silex__publicationName__ + "/" + __silex__layerPath__.join("/") + "/" + this.iconPageName;
			if (org.silex.htmlGenerator.Utils.siteEditor.getWebsiteConfig(__silex__publicationName__).get("defaultFormat") != "html")
				res += "&amp;format=html";
			res += "'>";
		} else if (iconIsIcon)
		{
			// md lex, pretty url
			//res += "<a href='?/" + __silex__publicationName__ + "/" + __silex__layerPath__.join("/") + "/" + this.iconDeeplinkName + "&amp;format=html&amp;selectedIcon=" + StringTools.urlEncode(this.__silex__layerPath__.join(".") + "." + this.playerName) + "'>";
			res += "<a href='?/" + __silex__publicationName__ + "/" + __silex__layerPath__.join("/") + "/" + this.iconDeeplinkName;
			if (org.silex.htmlGenerator.Utils.siteEditor.getWebsiteConfig(__silex__publicationName__).get("defaultFormat") != "html")
				res += "&amp;format=html'";
			res += ">";
		} else if(__silex__actionshref__ != null)
		{
			res += "<a href='" + this.__silex__actionshref__ + "'>";
		}
		
		res += "<div id='" + this.playerName + "' class='silex-comp-UiBase' style='-webkit-transform-origin: 0 0;-moz-transform-origin: 0 0; -webkit-transform: rotate(" + this.rotation + "deg);-moz-transform: rotate(" + this.rotation + "deg);position:absolute;left:" + this.x + "px;top:" + this.y + "px;width:" +this.width + "px;height:" + this.height +"px;" + styleVisible + "'>";
		res += this.returnHTML();
		res += "</div>";
		
		//Close the a tag that may have been opened of needed.
		if (iconIsIcon || __silex__actionshref__ != null)
		{
			res += "</a>";
		}

		return res;
	}
	
	/**
	*  This is a method called by UiBase.getHTML. Subclasses should override it to return their own HTML/
	*/
	public function returnHTML() : String
	{
		return "";
	}
	
	public function new() 
	{
		super();
	}
	
}