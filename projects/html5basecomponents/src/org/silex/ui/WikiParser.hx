/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

//Note that this class is **NOT** a component but can be used by several of them.
//It is used to support wiki-style syntax when targetting HTML5.

package org.silex.ui;

import org.silex.htmlGenerator.Utils;

class WikiParser
{
	public static var lastId = 0;
	
	public static function transformToHTML(wikiCode : String)
	{
		var linksReg = ~/\[\[([^|]*)\|([^|]*)\]\]/g;
		var actionsReg = ~/\[\[([^]]+)\]\]/;
		
		//This is the string to be returned
		var str : String;
		str = wikiCode;
		
		//Actions management
		while(actionsReg.match(str))
		{
			//This is the array containing strings representing actions.
			//Note that the last element is indeed the text and not an action!
			//Also note that static HTML will only handle the first action.
			var actionsStr : Array<String>;
			actionsStr = actionsReg.matched(1).split("|");
			
			//Handling static HTML generation
			var wrapper : Xml;
			wrapper = Xml.createElement("a");
			wrapper.addChild(Xml.createPCData(actionsStr.pop()));
			wrapper.set("id", getNextId());

			var action : String;
			action = actionsStr[0].split(":")[0];
			var parameters : Array<String>;
			parameters = actionsStr[0].substr(actionsStr[0].indexOf(":")+1).split(",");
			//parameters = actionsStr[0].split(":")[1].split(",");
			
			switch(removeHTML(action).toLowerCase())
			{
				case "open":
				var url = removeHTML(parameters[0]);
				//Remove / if it's the first character
				if(url.substr(0, 1) == "/")
					url = url.substr(1);
				
				//Prepend the start layer if it's not already there
				var websiteStartSection : String = Utils.siteEditor.getWebsiteConfig(Utils.deeplink.publication).get("CONFIG_START_SECTION");
				if(url.split("/")[0] != websiteStartSection)
				{
					//Prepend start section's name.
					url = websiteStartSection + "/" + url;
				}
				//Preprend ?/publication's name and / and format=html
				url = "?/" + Utils.deeplink.publication + "/" + url + "&format=html";
				
				wrapper.set("href", url);
				
				str = StringTools.replace(str, actionsReg.matched(0), wrapper.toString());
				case "http":
					wrapper.set("href", "http:" + StringTools.htmlUnescape(removeHTML(parameters[0])));
					if(parameters.length>1)
					{
						wrapper.set("target", removeHTML(parameters[1]));
					} else
					{
						wrapper.set("target", "_blank");
					}

					str = StringTools.replace(str, actionsReg.matched(0), wrapper.toString());
				case "openurl":
					wrapper.set("href", StringTools.htmlUnescape(removeHTML(parameters[0])));
					if(parameters.length>1)
					{
						wrapper.set("target", removeHTML(parameters[1]));
					} else
					{
						wrapper.set("target", "_blank");
					}

					str = StringTools.replace(str, actionsReg.matched(0), wrapper.toString());
				case "mailto":
					wrapper.set("href", "mailto:" + removeHTML(parameters[0]));
					if(parameters.length>1)
					{
						wrapper.set("target", removeHTML(parameters[1]));
					}
				
					str = StringTools.replace(str, actionsReg.matched(0), wrapper.toString());
				default:
					wrapper.set("href", "#");
					str = StringTools.replace(str, actionsReg.matched(0), wrapper.toString());
			}
			
			//**TODO**: Register action for jsGenerator
			for(actionStr in actionsStr)
			{
				var parameters = new Array<String>();
				for(parameter in actionStr.split(":")[1].split(","))
				{
					parameters.push(StringTools.htmlUnescape(removeHTML(parameter)));
				}
				var action = 	{component : wrapper.get("id"),
								modifier : "onRelease",
								functionName : removeHTML(actionStr.split(":")[0].split(" ")[0]),
								parameters : parameters};
				//Add the action to the list of actions
				var actions = Reflect.field(Type.resolveClass("org.silex.htmlGenerator.JsCommunication"), "actions");
				Reflect.callMethod(actions, Reflect.field(actions, "push"), [action]);
			}
		}
		
		//Due to the iterative method used to manage images, it is important that the g flag is __not__ set.
		//Note that $1 is the URL of the image and
		//$2 is the "size string" (containing ? and spaces).
		var imagesReg = ~/{{([^}\?]*)([^}]*)}}/;
		//var str = linksReg.replace(wikiCode, "<a href='$1'>$2</a>");
		
		while(imagesReg.match(str))
		{
			var url = imagesReg.matched(1);
			//Remove unwanted spaces (those are accepted by SILEX)
			url = StringTools.trim(url);
			
			//Managing the size parameters
			var width = 0.0;
			var height = 0.0;
			//This string is going to be put inside the img tag.
			var htmlSizeStr = "";
			//This block is executed only if there's a "size string".
			if(imagesReg.matched(2) != "")
			{
				var cleanSize : String = StringTools.trim(StringTools.replace(imagesReg.matched(2), "?",""));
				width = Std.parseFloat(cleanSize.split("x")[0]);
				height = Std.parseFloat(cleanSize.split("x")[1]);
				htmlSizeStr = "width='" + width + "' height='" + height + "'";
			}
			
			if(url.split(".").pop().toLowerCase() != "swf")
			{
				str = imagesReg.replace(str, "<img src='" + url + "' " + htmlSizeStr + " />");
			}
			else
			{
				str = StringTools.replace(str, imagesReg.matched(0), '<object>
				<param name="movie" value="' + url + '">
				<embed src="' + url + '">
				</embed>
				</object>');
			}
		}
		
		return str;
	} 
	
	public static function getNextId() : String
	{
		return "wikiPseudoComp-" + WikiParser.lastId++;
	}
	
	
	//This function is used to remove html tags (the editor can sometime put some inside actions).
	private static function removeHTML(str : String) : String
	{
		if(str == null)
			return "";
		var reg = ~/<[^>]+>/g;
		return reg.replace(str, "");
	}
	
	private static function fallBackFlashToHTML(s : String)
	{
		/*
			                        rep(/<P ALIGN=\"(.*?)\">/gi,"<p style=\"text-align: $1;\">");
		171	
		172	                        // size="14" => size="14pt"
		173	                        //rep(/size=\"(.*?)\"/gi,"size=\"$1pt\"");
		174	
		175	                        // <font size="14   =>   <span style=\"font-size:14pt;
		176	                        rep(/<font size=\"(.*?)\">(.*?)<\/font>/gi,"<span style=\"font-size:$1pt;\">$2<\/span>");
		177	
		178	                        // example: [b] to <strong>
		179	                        rep(/<br>/gi,"<br />");
		180	                        rep(/\<b>/gi,"<strong>");
		181	                        rep(/\<\/b\>/gi,"</strong>");
		*/
		var p_reg = ~/<P ALIGN="(.*?)">/gi;
		var size_reg = ~/<font size="(.*?)">(.*?)<\/font>/gi;
		var br_reg = ~/<br>/gi;
		var b_reg = ~/<b>/gi;
		var bend_reg = ~/<\/b>/gi;
		
		s = p_reg.replace(s, "<p style=\"text-align: $1;\">");
	}
}