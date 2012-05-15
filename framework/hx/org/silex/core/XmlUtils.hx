/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * This class gathers XML utilities
 * 
 * @author Raphael Harmel
 * @version 1.0
 * @date   2011-01-19
 * 
 */

package org.silex.core;

class XmlUtils
{
	// indent default value: used at each new indent
	static inline var INDENT_STRING:String = "\t";

	/**
	*  This method takes an XML, removes white spaces, indent & comments, and then return the XML.
	*  For now it just calling the equivalent recursive method.
	*  It is better to have two methods for recursive algorithms, one to initialise recursion, the other for recursion
	*/
	public static function cleanUp(xml:Xml) : Xml
	{
		// duplicate input xml to avoid changing input xml data
		var xmlCopy:Xml = Xml.parse(xml.toString()).firstElement();
		
		// return value
		// if xml is not null, call cleanUpRecursive
		if (xmlCopy != null)
		{
			return cleanUpRecursive(xmlCopy);
		}
		// else return input xml (returning null creates type conflicts
		else
		{
			return xml;
		}
	}
	
	/**
	*  This method takes an XML, removes white spaces, indent & comments, and then return the XML. To be called by cleanUp(xml) and not directly.
	*/
	private static function cleanUpRecursive(xml:Xml) : Xml
	{
		var whiteSpaceValues:Array<String> = ["\n","\r","\t"];
		var childData:Xml = null;
		var child:Xml = null;
		// create root element
		var cleanedXml:Xml = null;


		// depending on the xml root node type, create cleanedXml with the corresponding type 
		switch (xml.nodeType)
		{
			case Xml.Document:
				cleanedXml = Xml.createDocument();
			
			case Xml.Element:
				cleanedXml = Xml.createElement(xml.nodeName);
				for (attrib in xml.attributes())
				{
					cleanedXml.set(attrib, xml.get(attrib));
				}
		}

		// iterate on all children
		for ( child in xml ) {
			// case child node is element ie. a child node but not data
			switch (child.nodeType)
			{
				// case child node is element: recursive loop on elements
				case Xml.Element:
				childData = cleanUpRecursive(child);
				cleanedXml.addChild(childData);
					
				// case child node is Comment, do not add it to the cleanedXml
				//   => not working for PHP target, issue sent to Haxe mailing list, cf. workaround below
				case Xml.Comment:

				// case child node is CData or PCData
				default:
				// set noValue to child's nodeValue
				var nodeValue:String = child.nodeValue;

				//  if value is Comment, do not add it to the cleanedXml => workaround as issue with Haxe getting Xml.Comment type
				if ( (nodeValue.substr(0,4) == '<!--') && (nodeValue.substr(-3) == '-->') )
				{
					nodeValue = '';
				}		

				// removes ramaning white spaces, ie. text formatting (uneeded spaces)
				nodeValue = StringTools.ltrim(nodeValue);
				
				// value is cleaned in case it is not "real" value but indenting (\n and \t)
				// remove white spaces, ie. text formatting (indent and carrier return)
				for (whiteSpace in whiteSpaceValues)
				{
					nodeValue = StringTools.replace(nodeValue, whiteSpace, "");
				}

				// if cleaned value is not empty, add it to the cleanedXml
				if (nodeValue != "")
				{
					var duplicatedXml : Xml;
					duplicatedXml = null;
					switch(child.nodeType)
					{
						case Xml.PCData:
							duplicatedXml = Xml.createPCData(nodeValue);
						case Xml.CData:
							duplicatedXml = Xml.createCData(nodeValue);
					}

					cleanedXml.addChild(duplicatedXml);
				}
			}
		}

		return cleanedXml;
	}
	
	/**
	*  This method takes an XML String (indented or not), and returns the cleaned XML.
	*/
	public static function stringIndent2Xml(xmlString:String) : Xml
	{
		var xml:Xml = Xml.parse(xmlString);
		return cleanUp(xml);
	}
	
	/**
	*  This method takes an XML object and returns the indented string equivalent.
	*/
	public static function xml2StringIndent(xml:Xml) : String
	{
		var firstElement:Xml = xml.firstElement();
		// return value
		return xml2StringIndentRecursive(firstElement, "");
	}
	
	/**
	*  This method takes an XML object and returns the indented string equivalent. to be called by xml2StringIndent(xml) and not directly.
	*/
	private static function xml2StringIndentRecursive(xml:Xml,indentationLevel:String='') : String
	{
		// return value
		var toReturn = "";

		// indent and create node
		toReturn += indentationLevel + "<" + xml.nodeName;

		// add attributes
		for (attrib in xml.attributes())
		{
			toReturn += " " + attrib + "=\"" + xml.get(attrib) + "\"";
		}
		toReturn += ">";
		
		var firstChild:Xml = xml.firstChild();
		if (firstChild != null)
		{
			switch (firstChild.nodeType)
			{
				// case child node is CData: format value to CData
				case Xml.CData:
					toReturn += "<![CDATA[" + firstChild.nodeValue + "]]>";
				// case child node is PCData: add value
				case Xml.PCData:
					//toReturn += firstChild.nodeValue; => not used as converts html entities to unwanted characters
					toReturn += firstChild;
				// case child node is element: recursive loop on elements
				case Xml.Element:
					toReturn += "\n";
					// recursive loop
					var element:Xml;
					for (element in xml)
					{
						// recursive call
						toReturn += xml2StringIndentRecursive(element,indentationLevel+INDENT_STRING);
					}
					toReturn += indentationLevel;
				// impossible case
				default:
			}
		}
		// close node
		toReturn += "</" + xml.nodeName + ">\n";

		return toReturn;
	}
	
	/**
	*  This method takes an XML object and returns the equivalent Dynamic.
	* 
	* input:	a Xml
	* output:	a dynamic
	* 
	*/
	public static function Xml2Dynamic(xml:Xml, oofLegacyWorkaround:Bool = false) : Dynamic
	{
		// set start node & remove white spaces
		var firstElement:Xml = cleanUp(xml);

		// call recursive loop
		var generatedXml:Dynamic = xml2DynamicRecursive(firstElement,firstElement.nodeName.toLowerCase() == 'rss', oofLegacyWorkaround);

		return generatedXml;
	}

	/**
	*  This method takes an XML object and returns the equivalent Dynamic.
	*  To be called by xml2StringIndent(xml) and not directly.
	* 
	* input:	a Xml
	* output:	a dynamic
	* 
	*/
	private static function xml2DynamicRecursive(xml:Xml, isRss:Bool, oofLegacyWorkaround:Bool) : Dynamic
	{
		// return value
		var xmlAsDynamic:Dynamic = null;
		var whiteSpaceValues:Array<String> = ["\n","\r","\t"];

		// value (ie. the first child, hopefully !)
		if (xml.firstChild() != null)
		{
			// if type is PCData, return value
			// in that case, no attributes values and children informations are returned
			if (xml.firstChild().nodeType == Xml.PCData || xml.firstChild().nodeType == Xml.CData)
			{
				var nodeStrValue : String;
				nodeStrValue = "";
				for(node in xml)
				{
						nodeStrValue += node.nodeValue;
				}
				
				return nodeStrValue;
			}
		}
		
		// attributes
		var attributes:Dynamic = null;
		var attribHash:Hash<Dynamic> = new Hash<Dynamic>();
		var attributes:Dynamic = null;
		for (attrib in xml.attributes())
		{
			// store attribute data
			Reflect.setField(xmlAsDynamic.attributes, attrib, xml.get(attrib));
		}
			
		// children
		// children information are added directly to xmlAsDynamic (used to simplify xml access with an accessor)
		var childData:Dynamic = null;
		// nodeValues is an Array used to store the values of the children having the same nodeName.
		// assumption is that in this case, all the children have the same nodeName
		// TODO => assumption not correct as not working with RSS format => to be corrected
		var nodeValues:Array<Dynamic> = new Array<Dynamic>();
		var processedNodeNames:Array<Dynamic> = new Array<String>();
		var processed:Bool = false;
		var iteration:Int = 0;
		// iterate on all children
		for( child in xml ) {
			// case child node is element ie. a child node but not data
			if (child.nodeType == Xml.Element)
			{
				// checks if the child's nodeName has already been processed
				for (name in processedNodeNames)
				{
					if (child.nodeName == name)
					{
						processed = true;
						// exit for loop
						break;
					}
				}
				
				// if this child's nodeName has not already been processed
				if (!processed)
				{
					// adds the child's nodeName to processedNodeNames
					processedNodeNames.push(child.nodeName);
					
					// Check how many iterations are existing with the same child's nodeName
					iteration = 0;
					for ( currentChild in xml )
					{
						if (child.nodeName == currentChild.nodeName)
						{
							// recursive call. Resulting Dynamic is stored in childData
							childData = xml2DynamicRecursive(currentChild,isRss,oofLegacyWorkaround);

							// childData is pushed to nodeValues Array
							nodeValues.push(childData);

							iteration++;
						}
					}
					// if there are multiple child having the same node name, or if xml is a Rss and nodeName is item, add nodeValues array
					if ( (iteration != 1) || (isRss && (child.nodeName=='item')) )
					{
						// normal functionning
						if (!oofLegacyWorkaround)
						{
							// Xml2Dynamic's child.nodeName field is setted to nodeValues' array 
							Reflect.setField(xmlAsDynamic, child.nodeName, nodeValues);
						}
						// oof Legacy Workaround
						else
						{
							// Xml2Dynamic is setted to nodeValues' array 
							var i:Int = 0;
							// for each value in nodeValues add it to xmlAsDynamic with the key as number but converted to string
							for (elt in nodeValues)
							{
								Reflect.setField(xmlAsDynamic, Std.string(i), elt);
								i++;
							}

						}
					}
					// if there is only one child having the same node name, add childData (no array)
					else
					{
						// Xml2Dynamic's child.nodeName field is setted to childData value 
						Reflect.setField(xmlAsDynamic, child.nodeName, childData);
					}
					// reset nodeValues array
					nodeValues = new Array<String>();
				}
			}
		}
		// add childData to children array: this is done in XmlConnector.as, but is it really neccesary ?
		//    => it creates a gigantic Dynamic with multiple times the same information 
		//xmlAsDynamic.children = children;
		
		return xmlAsDynamic;
	}

}
