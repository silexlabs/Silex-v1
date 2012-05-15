/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.dataConnectors.IContentConnector;
import mx.utils.Delegate;
import org.oof.OofBase;
/** Load an XML file and convert it recursively into an object for use by other Oof components.
 * Each XML node becomes an object with the following attributes :
 * - children: object which contains all children nodes, i.e. other objects with the same structure.
 * - attributes: object which contains one variable for each attribute of the XML instance
 * - key/value pairs: this is useful but redondant information. 
 * The children nodes have a reference to it directely in the root of the object, 
 * the reference has the name of the node and if there is several nodes with the same name, 
 * the reference is only the last node with this name.
 *
 * @author Ariel Sommeria-klein
 * @author lex@silex.tv
 **/
class org.oof.dataConnectors.XmlConnector extends OofBase implements IContentConnector{
 	private var _feed:XML = null;
	private var _allItems:Array = null;
	private var _urlBase:String = null;
	private var _whereClause:String = null;
	private var _orderBy:String = null;
	private var _count:Number = 0;
	private var _offset:Number = 0;
	
	var _getRecordsSuccessCallback:Function = null;
	var _getRecordsErrorCallback:Function = null;
	
	
    /**
	 * constructor
	 * @return void
	 */
	function XmlConnector(){
		super();
     	// inheritance
     	typeArray.push("org.oof.dataConnectors.XmlConnector");
	}

	function getAttributes(node:XMLNode):Object{
		var ret:Object = new Object();
		var hasAttributes:Boolean = false;
			for (var attributeName in node.attributes){
				hasAttributes = true;
				ret[attributeName] = node.attributes[attributeName];
			}
		if(hasAttributes)
			return ret;
		else 
			return null;
	}	

	/**
	 * parse a node of the loaded XML
	 * recursive function
	 * @return object which represent the node (all pairs key/value, a children object, and an attributes object)
	 */
	function parseNode(node:XMLNode):Object{
		var ret = new Object;
		ret.children =  new Array();
		var nodeLength = node.childNodes.length;
		for(var i = 0; i < nodeLength; i++){
			var child:XMLNode = node.childNodes[i];
			
//			if (child.nodeType == 1)
//				return child.nodeValue;
			
			if (child.nodeValue)
				return child.nodeValue;
			
			ret["nodeType"] = child.nodeType;
			ret["nodeName"] = child.nodeName;
			
			var childData:Object = parseNode(child);
			ret[child.nodeName] = childData;
			ret.children.push(childData);
		}
		ret.attributes = getAttributes(node);
		return ret;
	}
	function compareFunc(a:Object,b:Object):Number {
		var elemFromA = OofBase.getObjAtPath(a, _orderBy);
		var elemFromB = OofBase.getObjAtPath(b, _orderBy);
		var numElemFromA = parseFloat(elemFromA);
		if(!isNaN(numElemFromA)){
			elemFromA = numElemFromA;
		}
		var numElemFromB = parseFloat(elemFromB);
		if(!isNaN(numElemFromB)){
			elemFromB = numElemFromB;
		}
		
	   if ( elemFromA < elemFromB)
		 return( -1 );
	   else if ( elemFromA == elemFromB)
		 return( 0 );
	   else return( 1 ); 
	}
	
	function onLoadXml(success:Boolean){
		// find the root node
		var xmlRootNode:XMLNode = _feed.firstChild;
		var pathArray:Array = xmlRootNodePath.split("/");
		while (pathArray.length > 0) 
		{
			// find the next child node
			var nodeLength = xmlRootNode.childNodes.length;
			var child:XMLNode;
			for(var i = 0; i < nodeLength; i++){
				child = xmlRootNode.childNodes[i];
				if (child.nodeName == pathArray[0])
				{
					xmlRootNode = child;
				}
			}
			pathArray.shift();
		}
		//all went well with parsing. stock it for later
		var allItems = parseNode(xmlRootNode).children;

		//where clause
		//only where clause supported at the moment is a selection of ids. example: id IN (1,2,5)
//		var idString = _whereClause.substring(_whereClause.indexOf("("), _whereClause.indexOf(")")); // => 1, 2, 5
//		var split = idString.split(","); // => [1,2,3]
		
		//order by
		if((_orderBy != null) && (_orderBy != undefined) && (_orderBy != "")){
			allItems.sort(Delegate.create(this, compareFunc));
		}
		//offset
		if(_offset > 0){
			allItems.splice(0, _offset);
		}
		//count
		if(_count > 0){
			allItems.splice(_count);
		}
		
		//all went well with parsing. stock it for later
		_allItems = allItems;
/*		for (var prop:String in _allItems[0])
		{
		}
*/		_getRecordsSuccessCallback(_allItems);
	}
	
	/** function getRecords. select data from a datasource
	*@return void
	*/
	function getRecords(successCallback:Function, errorCallback:Function, formName:String, selectedFieldNames:Array, whereClause:String, orderBy:String, count:Number, offset:Number){
		_getRecordsSuccessCallback = successCallback;
		_getRecordsErrorCallback = errorCallback;
		_whereClause = whereClause;
		_orderBy = orderBy;
		_count = count;
		_offset = offset;
		_feed = new XML();
		_feed.ignoreWhite = true;
		_feed.onLoad = Delegate.create(this, onLoadXml);
		
		// reveal accessors in the url and form name
		var finalUrl:String = silexPtr.utils.revealAccessors(_urlBase + formName, this);
		if (!finalUrl)
			finalUrl = _urlBase + formName;

			
		// load the feed
		_feed.load(finalUrl);
		
	}
	
	/** function getIndividualRecords. get all values for a form from the database
	*@return void
	*/
	function getIndividualRecords(successCallback:Function, errorCallback:Function, formName:String, ids:Array){
		var wantedItems:Object = new Array();
		var len:Number = ids.length;
		for(var i = 0; i < len; i++){
			wantedItems.push(_allItems[ids[i]]);
		}
		if(wantedItems != null){
			successCallback(wantedItems);
		}else{
			errorCallback("item not found");
		}
		
	}
	/** function updateRecord
	*@return void
	*/
	function updateRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object, idRecord:Number){
		throw new Error(this + " updateRecord not implemented");
	}
	
	/** function createRecord
	*@return void
	*/
	function createRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object){
		throw new Error(this + " createRecord not implemented");
	}

	/** function deleteRecord
	*@return void
	*/
	function deleteRecord(successCallback:Function, errorCallback:Function, formName:String, idRecord:Number){
		throw new Error(this + " deleteRecord not implemented");
	}	

	/** property: xmlRootNodePath
	 * the path of the root node in the xml data returned by the server
	 * @example	The1stRoot/items if the xml is something like <xml><The1stRoot><items><item1>...
	 **/	
	[Inspectable(name="path of the XML root node", type=String, defaultValue="")]
	public var xmlRootNodePath:String = "";
	
	/** property: urlBase
	 * the rss connector adds the calling component's formName parameter to this
	 * to create the url that will be called. 
	 * example:
	 * put "http://youserver.com/rss.php?feedName=" here, and "news" in DataSelector's formName.
	 * and the connector will call "http://youserver.com/rss.php?feedName=news"
	 * 
	 * */	
	[Inspectable(name="url base", type=String]
	public function set urlBase(val:String){
		_urlBase = val;
	}

	
	public function get urlBase():String{
		return _urlBase;
	}
	
	/** 
	 * function: getSeoData
	 * return the seo data to be associated with this player
	 * @return	object with urlBase (string), xmlRootNodePath (string)
	 */
	function getSeoData(url_str:String):Object
	{
		var res_obj:Object=super.getSeoData(url_str);

		// gets components seo properties
		res_obj.urlBase = _urlBase;
		res_obj.xmlRootNodePath = xmlRootNodePath;

		return res_obj;
	}

}