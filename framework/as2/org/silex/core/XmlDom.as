/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * XmlDom class deals with xml files.
 * XML FORMAT USED FOR THE COMMUNICATION WITH FLASH, SERIALISATION, ETC.
 * 
 * 
 * 
 * <object><property id='var1'><string>aaaaaaaaaaa</string></property><property id='var2'><string name=\"testName2\">bbbbbbbbbb</string></property></object>
 * <object><property id="param2"><string>commandParam2</string></property><property id="param1"><string>commandParam1</string></property></object>
 * <string>stringCommandParam1</string>
 * <object><property id='success'><bool>false</bool></property><property id='message'><string>Dummy error</string></property></object>
 * 
 * DATA TYPES 
 * http://www.python.org/doc/2.4.4/lib/types.html
 * Numeric types -- int, float, long
 * Sequence Types -- str
 * bool
 * list, dict
 * 
 * illegal characters
 * &lt;     <
 * &gt;     >
 * &amp;     &
 * &apos;     '
 * &quot;     "
 * 
 * @author	lex@silex.tv
 */
import org.silex.core.XmlDomHooks;
import org.silex.core.plugin.HookManager;

class org.silex.core.XmlDom
{
	/**
	 * reference to silex main Api object (org.silex.core.Api)
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * TABS constant for XML files
	 * "\t" for easy read xml or "" for production mode
	 */
	public static var XML_TAB_CHAR:String = "";
	
	/**
	 * CR constant for XML files
	 * "\n" for easy read xml or "" for production mode
	 */
	public static var XML_CR_CHAR:String = "";

	
	/** 
	 * Current silex xml version. Used for compatibility with previous versions.
	 * 1 = escaped string and no version info.
	 * 2 = current version.
	 */
	var version:Number=2;
	/**
	 * Constructor.
	 */
	function XmlDom(api:org.silex.core.Api) {
		// store Api reference
		silex_ptr=api;
	}
    /**
     * convert xml string to an ActionScript object
     * @param	_xml	the xml string
     * @return	an ActionScript object
     */
	static function xmlToSimplePath(_xml:XML):Object
	{
        if (!_xml || !_xml.hasChildNodes())
            return null;

		_xml.ignoreWhite=true;

		// start parsing with the first property tag
        var elem:XMLNode=_xml.firstChild;
		
        // do the parsing
        return doXmlToSimplePath(elem)
	}
	/**
	 * Recursive function which does the conversion from xml to object.
	 * @param	elem				the xml object to convert
	 * @return	Object
	 * @example	doXmlToSimplePath of <xml><node id="FR">xxx</node><MENU02 text="a text"></MENU02></xml> is {FR:{value:"xxx",MEN02:{@text:"a text"}}}
	 */
    private static function doXmlToSimplePath(elem:XMLNode):Object
	{
		// case of a leaf
		if (elem.nodeType == 3)
		{
			return elem.nodeValue;
		}
		
		// case of a node
		var res:Object = new Object;
		var prop:String;
		var idx:Number;
		
		// attributes
		for (prop in elem.attributes)
		{
			res["@"+prop] = elem.attributes[prop];
		}
		
		// children
		for (idx=0;idx<elem.childNodes.length;idx++)
		{
			// retrieve the child name: the id attribute or the node name or "value" by default
			var childName:String = "value";
			if (elem.childNodes[idx].attributes.id && elem.childNodes[idx].attributes.id!="")
				childName = elem.childNodes[idx].attributes.id;
			else
				if (elem.childNodes[idx].nodeName)
					childName = elem.childNodes[idx].nodeName;
					
			res[childName] = doXmlToSimplePath(elem.childNodes[idx]);
		}
		return res;
	}
	/**
	 * Remove the <![CDATA[ ]]> from a string.
	 * @param	_str	the string
	 * @return	the new string
	 */
	public function removeCDATA(_str:String):String{
		_str=silex_ptr.utils.replace(_str,"<![CDATA[","");
		_str=silex_ptr.utils.replace(_str,"]]>","");
		//_str=silex_ptr.str_replace(_str,"%3C%21%5BCDATA%5B","");
		//_str=silex_ptr.str_replace(_str,"%5D%5D%3E","");
		return _str;
	}
	/**
	 * Add the <![CDATA[ ]]> to a string.
	 * @param	_str	the string
	 * @return	the new string
	 */
	public function addCDATA(_str:String):String{
		_str="<![CDATA["+_str;
		_str+="]]>";
		return _str;
	}
	/**
     * Convert an object to xml.
	 * @param	objToConvert	ActioinScript object
	 * @return	The corresponding XML
	 */
    public function objToXml(objToConvert:Object):String{
        var strRes:String="";
		
        // call the recursive function
        if (objToConvert)
            strRes=doObjToXml(objToConvert,"",version.toString());
			
        return '<?xml version="1.0" encoding="UTF-8"?>'+strRes;
	}
	/**
     * Convert an object to xml.
	 * Recursive function.
	 * @param	objToConvert	ActioinScript object
	 * @param	tab				string containing tab characters to add at the beginning of the lines - XML formating
	 * @param	silexXmlVersion	Current silex xml version
	 * @return	The corresponding XML
	 */
    private function doObjToXml(objToConvert,tab:String,silexXmlVersion:String):String{
        // strRes : the result xml string
        var strRes:String="";
		if (!tab) tab="";
    
        // compute the result
        // in function of the type of the object to be converted
        switch (getType(objToConvert)){
			case "string":
				if (silexXmlVersion>1)
					strRes=tab+'<string silexXmlVersion="2">'+escapeHTML(objToConvert)+"</string>"+XML_CR_CHAR;
				else
					strRes=tab+"<string>"+escapeHTML(objToConvert)+"</string>"+XML_CR_CHAR;
				break;
            
        	case "boolean":
	            // strRes="<boolean>"+str(objToConvert).lower()+"</boolean>"
				if (silexXmlVersion>1)
					strRes=tab+"<"+objToConvert.toString()+' silexXmlVersion="2"/>'+XML_CR_CHAR;
				else
					strRes=tab+"<"+objToConvert.toString()+"/>"+XML_CR_CHAR;
				break;
            
	        case "number":
				if (silexXmlVersion>1)
					strRes=tab+'<number silexXmlVersion="2">'+objToConvert.toString()+"</number>"+XML_CR_CHAR;
				else
					strRes=tab+"<number>"+objToConvert.toString()+"</number>"+XML_CR_CHAR;
				break;
	            
	        case "array":
	            strRes=tab+"<array>"+XML_CR_CHAR
	            for (var objIndex:Number=0;objIndex<objToConvert.length;objIndex++){
	                //strRes+=tab+XML_TAB_CHAR+"<property id=\""+str(objIndex)+"\">"+XML_CR_CHAR
					if (silexXmlVersion>1)
						strRes+=tab+XML_TAB_CHAR+'<property silexXmlVersion="2">'+XML_CR_CHAR;
					else
						strRes+=tab+XML_TAB_CHAR+"<property>"+XML_CR_CHAR;
	                strRes+=doObjToXml(objToConvert[objIndex], tab+XML_TAB_CHAR+XML_TAB_CHAR );
	                strRes+=tab+XML_TAB_CHAR+"</property>"+XML_CR_CHAR;
				}
	            strRes+=tab+"</array>"+XML_CR_CHAR;
				break;

	        case "object":
	            strRes=tab+"<object>"+XML_CR_CHAR;
	            for (var objId in objToConvert){
					if (silexXmlVersion>1)
						strRes+=tab+XML_TAB_CHAR+"<property id=\""+objId+'" silexXmlVersion="2">'+XML_CR_CHAR;
					else
						strRes+=tab+XML_TAB_CHAR+"<property id=\""+objId+"\">"+XML_CR_CHAR;
	                strRes+=doObjToXml( objToConvert[objId], tab+XML_TAB_CHAR+XML_TAB_CHAR);
	                strRes+=tab+XML_TAB_CHAR+"</property>"+XML_CR_CHAR;
				}
	            strRes+=tab+"</object>"+XML_CR_CHAR;
				break;
		}
        return strRes;
	}
	/**
	 * Retrieve the type of an object. It adds the array type to the ActionScript operator typeof.
	 * @param	objToConvert
	 * @return	a string for the object type: array, object, number, boolean or string
	 */
	private function getType(objToConvert:Object):String{
		if (objToConvert instanceof Array) return "array";
		if (objToConvert instanceof MovieClip) return "object";
		if (objToConvert instanceof Button) return "object";
		if (objToConvert instanceof TextField) return "object";
		if (objToConvert instanceof String) return "string";
/*		does not work properly : 
		if (objToConvert instanceof Number) return "number";
		if (objToConvert instanceof Boolean) return "boolean";
		if (objToConvert instanceof Function) return "object";
		if (objToConvert instanceof Object) return "object";
		//if (objToConvert instanceof ) return "";
*/		return typeof(objToConvert);
	}
	/**
	 * Escape a string to be outputed in an XML file
	 * @param	_str	the string to escape
	 * @return	a string formated to be outputed in an XML file
	 */
	private function escapeHTML(_str:String):String{
		//return escape(_global.getSilex().utils.getRawTextFromHtml(_str));
		return addCDATA(/*escape*/(_str));
	}
    /**
     * convert xml string to an ActionScript object
     * @param	_xml	the xml string
     * @return	an ActionScript object
     */
    public function xmlToObj(_xml:XML):Object {
        var hookManager:HookManager = HookManager.getInstance();
		hookManager.callHooks(XmlDomHooks.XML_TO_OBJ_START_HOOK_UID, arguments);
        if (!_xml || !_xml.hasChildNodes())
            return null;

		_xml.ignoreWhite=true;

		// start parsing with the first property tag
        var elem:XMLNode=_xml.firstChild;
		
		var silexXmlVersion:Number=1;
		if (elem.firstChild.attributes.silexXmlVersion){
			// store version
			silexXmlVersion=parseInt(elem.firstChild.attributes.silexXmlVersion);
			// first xml tag is xml => use the first child
			//elem=elem.firstChild;
		}
        // do the parsing
		var ret:Object = doXmlToObj(elem, silexXmlVersion);
		hookManager.callHooks(XmlDomHooks.XML_TO_OBJ_END_HOOK_UID, ret);
        return ret;
	}
	/**
	 * Recursive function which does the conversion from xml to object.
	 * @param	elem				the xml object to convert
	 * @param	silexXmlVersion		silex xml version
	 * @return	ActionScript object
	 */
    private function doXmlToObj(elem:XMLNode,silexXmlVersion:Number):Object{
        // case of a leaf node
		switch (elem.nodeName){
			// ------------------------------------------------------------------------
			// Simple type
        	case "boolean":
				// returns a boolean
				return (elem.firstChild.nodeValue=="true");
        	case "true":
				// returns a boolean
				return true;
        	case "false":
				// returns a boolean
				return false;

        	case "string":
				// returns a string
				// not useful to unescape here : dictRes=self.unescapeHtmlentities(str(elem.firstChild.nodeValue))
				if (elem.firstChild){
					if(silexXmlVersion>1)
						return elem.firstChild.nodeValue;
					else
						return unescape(elem.firstChild.nodeValue);
				}
				else
					return "";

			case "number":
				// return a number 
				return parseFloat(elem.firstChild.nodeValue);
			
			// ------------------------------------------------------------------------
			// Complex type with children properties
			case "object":
				// return  an Obj
				var _obj:Object=new Object;
				var _xmlnode:XMLNode=elem.firstChild;
				while (_xmlnode)
				{
					_obj[_xmlnode.attributes["id"]]=doXmlToObj(_xmlnode.firstChild,silexXmlVersion);
					_xmlnode=_xmlnode.nextSibling;
				}
				return _obj;
				
			case "array":
				// return  an array
				var _array:Object=new Array;
				var _xmlnode:XMLNode=elem.firstChild;
				while (_xmlnode)
				{
					_array.push(doXmlToObj(_xmlnode.firstChild,silexXmlVersion));
					_xmlnode=_xmlnode.nextSibling;
				}
				return _array;
	
			default:
				// problem ?
				return null;
		}
	}
}