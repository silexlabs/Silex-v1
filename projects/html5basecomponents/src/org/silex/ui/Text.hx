/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.ui;

/**
 * ...
 * @author Benjamin Dasnois
 */

/**
*  This class implements the Text component in HTML5
*/
class Text extends UiBase
{
	private var html : Bool;
	private var htmlText : String;
	private var embedFonts : Bool;
	private var cssUrl : String;
	private var scrollBar : Bool;
	private var typeWriterEffectSpeed : Float;
	private var scrollbarWidth : Float;
	private var selectable : Bool;
	private var multiline : Bool;
	private var textColor : String;
	private var textHeight : Float;
	private var autoSize : String;
	private var border : Bool;
	private var borderColor : String;
	private var antiAliasType : String;
	private var background : Bool;
	private var backgroundColor : String;
	private var condenseWhite : Bool;
	private var maxChars : Float;
	private var mouseWheelEnabled : Bool;
	private var password : Bool;
	private var restrict : String;
	private var wordWrap : Bool;
	private var textFormat : Array<Dynamic>;
	
	public function new() 
	{
		super();
	}
	
	public override function returnHTML() : String
	{
		var textToRet : String;
		var scrollBars = "";
		if (this.html)
		{
			var tmp = StringTools.htmlUnescape(htmlText);
			//tmp = "<rootnode>" + tmp + "</rootnode>";
			try
			{
				textToRet = WikiParser.transformToHTML(fromFlashToHTML(Xml.parse("<rootnode>" +tmp+ "</rootnode>").firstElement()).toString());
			} catch(e : Dynamic)
			{
				textToRet = WikiParser.transformToHTML(fallBackFlashToHTML(tmp));
			}
		} else
		{
			textToRet = htmlText;
		}
		if (this.scrollBar)
			scrollBars = "overflow:auto;";
		else
			scrollBars = "overflow:hidden;";
		return "<div style='" + scrollBars + "width:" +this.width + "px;height:" + this.height +"px;' debug='" + Std.string(html) + "'>" + textToRet + "</div>";
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
				// the default value for the p tags "margin" style is 1.2em
				// we do not want margins, but when a text is empty, we still want the line to have a height !=0 
				// so we put min-height:1.2em which means that the text line is a least the height of the font
				resultingNode.set("style", "margin:0.2em; min-height:1.2em");
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
					//Transforming "_sans" to "sans-serif" is needed for HTML
					var fontFamily = node.get(attr);
					if(fontFamily == '_sans') fontFamily = "sans-serif";
					resultingNode.set("style", resultingNode.get("style") + ";" + "font-family:" + fontFamily);
					fontFamily = null;
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
				var value = cn.nodeValue;
				//value = StringTools.replace(value, " ", "&nbsp;");
				resultingNode.addChild(Xml.createPCData(value));
				value = null;
			} else if(cn.nodeType == Xml.Element)
			{
				resultingNode.addChild(fromFlashToHTML(cn));
			}
		}
		
		return resultingNode;
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
		var font_reg = ~/<font face="(.*?)" size="(.*?)" color="(.*?)" letterspacing="(.*?)" kerning="(.*?)">(.*?)<\/font>/gi;
		var br_reg = ~/<br>/gi;
		var b_reg = ~/<b>/gi;
		var bend_reg = ~/<\/b>/gi;
		
		s = p_reg.replace(s, "<p style=\"text-align: $1;\">");
		s = size_reg.replace(s, "<span style=\"font-size:$1pt;\">$2</span>");
		s = font_reg.replace(s, "<span style=\"font-size:$2pt;font-color:$3\">$6</span>");
		s = br_reg.replace(s, "<br />");
		s = b_reg.replace(s, "<strong>");
		s = bend_reg.replace(s, "</strong>");
		
		return s;
	}
}