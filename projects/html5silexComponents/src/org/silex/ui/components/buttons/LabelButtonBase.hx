/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.ui.components.buttons;

import org.silex.htmlGenerator.Utils;

/**
*  ##LabelButton Implementation
*  This is the implementation for HTML5 of the LabelButton component.
*  Note that sometimes the text will look differently (particularly in regards to a elements 
*  since the user agent's style sheet can't be disabled).
*/
class LabelButtonBase extends ButtonBase
{
	//Component's properties
	private var centeredHoriz : Bool;
	private var buttonLabelNormal : String;
	private var buttonLabelSelect : String;
	private var buttonLabelOver : String;
	private var buttonLabelPress : String;
	private var autoSize : Bool;
	private var wordWrap : Bool;
	
	//###Constructor
	public function new()
	{
		super();

		//Now setting default values.
		this.centeredHoriz = false;
		this.buttonLabelNormal = "label";
		this.buttonLabelSelect = "<b>label</b>";
		this.buttonLabelOver = "<u>label</u>";
		this.buttonLabelPress = "<b>label</b>";
		this.autoSize = true;
		this.wordWrap = false;
		
		//####Adding our CSS
		//This CSS is used mainly to manage different labels depending on the state.
		Utils.addCssRule(".labelButton:hover .labelButtonNormal", "display: none;");
		Utils.addCssRule(".labelButton:hover .labelButtonSelect", "display: none;");
		Utils.addCssRule(".labelButton:hover .labelButtonOver", "display: block;");
		Utils.addCssRule(".labelButton:hover .labelButtonPress", "display: none;");
		                                       
		Utils.addCssRule(".labelButton .labelButtonNormal", "display: block;");
		Utils.addCssRule(".labelButton .labelButtonSelect", "display: none;");
		Utils.addCssRule(".labelButton .labelButtonOver", "display: none;");
		Utils.addCssRule(".labelButton .labelButtonPress", "display: none;");

		//Reflowing while the user is active on the element doesn't work correctly.
		//Should only be possible when using JS.
		//That's why it's deactivated at that time.
		/*
		Utils.addCssRule(".labelButton:active > .labelButtonNormal", "display: none;");
		Utils.addCssRule(".labelButton:active > .labelButtonSelect", "display: none;");
		Utils.addCssRule(".labelButton:active > .labelButtonOver", "display: none;");
		Utils.addCssRule(".labelButton:active > .labelButtonPress", "display: block;");
		*/
	}
	
	//###returnHTML
	public override function returnHTML()
	{
		//Those variables hold the markup for each state.
		var normal : String;
		var select : String;
		var over : String;
		var press : String;

		//Defining markups for each state.
		try
		{
			normal = "<div class='labelButtonNormal'>" + wikiStyle(fromFlashToHTML(Xml.parse("<rootnode>" + StringTools.htmlUnescape(this.buttonLabelNormal) + "</rootnode>").firstElement()).toString()) + "</div>";
		} catch(e : Dynamic)
		{
			normal = "<div class='labelButtonNormal'>" + wikiStyle(fallBackFlashToHTML(StringTools.htmlUnescape(this.buttonLabelNormal))) + "</div>";
		}
		try
		{
			select = "<div class='labelButtonSelect'>" + wikiStyle(fromFlashToHTML(Xml.parse("<rootnode>" + StringTools.htmlUnescape(this.buttonLabelSelect) + "</rootnode>").firstElement()).toString()) + "</div>";
		} catch(e : Dynamic)
		{
			select = "<div class='labelButtonSelect'>" + wikiStyle(fallBackFlashToHTML(StringTools.htmlUnescape(this.buttonLabelSelect))) + "</div>";
		}
		try
		{
			over = "<div class='labelButtonOver'>" + wikiStyle(fromFlashToHTML(Xml.parse("<rootnode>" + StringTools.htmlUnescape(this.buttonLabelOver) + "</rootnode>").firstElement()).toString()) + "</div>";
		} catch(e : Dynamic)
		{
			over = "<div class='labelButtonOver'>" + wikiStyle(fallBackFlashToHTML(StringTools.htmlUnescape(this.buttonLabelOver))) + "</div>";
		}
		try
		{
			press = "<div class='labelButtonPress'>" + wikiStyle(fromFlashToHTML(Xml.parse("<rootnode>" + StringTools.htmlUnescape(this.buttonLabelPress) + "</rootnode>").firstElement()).toString()) + "</div>";
		} catch(e : Dynamic)
		{
			press = wikiStyle(fallBackFlashToHTML(StringTools.htmlUnescape(this.buttonLabelPress))) + "</div>";
		}

		//Define style depending on properties' values.
		var style : String;
		style = "";
		
		//Handle centeredHoriz
		if(this.centeredHoriz)
		{
			style += "text-align: center;";
		}
		
		//If it is the selectedIcon simply output the "selected" label.
		if(!Utils.isSelectedIcon(this))
			return "<div class='labelButton' style='" + style + "'>"+ normal + select + over + press + "</div>";
		else
			return "<div class='selectedLabelButton' style='" + style + "'>" + select + "</div>";
	}
	
	/**
	*  This function transforms Flash 'pseudo-html' to HTML code and returns it as a Xml.
	*/
	public static function fromFlashToHTML(node : Xml)
	{
		var resultingNode : Xml;
		//trace(node.nodeType);
		switch(node.nodeName.toLowerCase())
		{
			case "textformat":
				resultingNode = Xml.createElement("span");
			case "p":
				resultingNode = Xml.createElement("p");
				resultingNode.set("style", "margin:0px");
			case "font":
				resultingNode = Xml.createElement("span");
			case "b":
				resultingNode = Xml.createElement("span");
				resultingNode.set("style", "font-weight:bold");
			case "u":
				resultingNode = Xml.createElement("span");
				resultingNode.set("style", "text-decoration:underline");
			case "i":
				resultingNode = Xml.createElement("span");
				resultingNode.set("style", "font-style:italic");
			case "li":
				resultingNode = Xml.createElement("li");
			default:
				resultingNode = Xml.createElement("span");
		}
		for (attr in node.attributes())
		{
			switch(attr.toLowerCase())
			{
				case "align":
					resultingNode.set("style", resultingNode.get("style") + ";" + "text-align:" + node.get(attr));
				case "face":
					resultingNode.set("style", resultingNode.get("style") + ";" + "font-family:" + node.get(attr));
				case "size":
					resultingNode.set("style", resultingNode.get("style") + ";" + "font-size:" + node.get(attr) + "px");
				case "color":
					resultingNode.set("style", resultingNode.get("style") + ";" + "color:" + node.get(attr));
				case "letterspacing":
				default:
					null;
			}
		}
		for (cn in node)
		{
			if (cn.nodeType == Xml.CData || cn.nodeType == Xml.PCData)
			{
				resultingNode.addChild(Xml.createPCData(cn.nodeValue));
			} else if(cn.nodeType == Xml.Element)
			{
				resultingNode.addChild(fromFlashToHTML(cn));
			}
		}
		
		return resultingNode;
	}
	
	public static function wikiStyle(str : String) : String
	{
		var linksReg = ~/\[\[([^|]*)\|([^|]*)\]\]/g;
		str = linksReg.replace(str, "<a href='$1'>$2</a>");
		
		return str;
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
		s = size_reg.replace(s, "<span style=\"font-size:$1pt;\">$2</span>");
		s = br_reg.replace(s, "<br />");
		s = b_reg.replace(s, "<strong>");
		s = bend_reg.replace(s, "</strong>");
		
		return s;
	}
}