/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This connector connects to a remote url and expects an RSS feed. It then parses it into objects useable by the 
 * Data Selector.
 * .
* @author Ariel Sommeria-klein
 * */
import org.oof.dataConnectors.IContentConnector;
import mx.utils.Delegate;
import org.oof.OofBase;
/** TODO
* support multiple selectors as users
* caching
*/
class org.oof.dataConnectors.RssConnector extends OofBase implements IContentConnector{
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
	function RssConnector(){
		super();
		_className = "org.oof.dataConnectors.RssConnector";
      	// inheritance
     	typeArray.push(_className);
	}
				
	function getAttributes(node:XMLNode){
		var ret:Array = new Array();
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
	 * parse a node of the loaded RSS
	 * recursive function
	 * @return Array which represent the node
	 */
	function parseNode(node:XMLNode):Array{
		var ret = new Array();
		var nodeLength = node.childNodes.length;
		for(var i = 0; i < nodeLength; i++){
			var child:XMLNode = node.childNodes[i];
			var childNodeLength = child.childNodes.length;
			switch(childNodeLength){
				case 0:
					break;
				case 1:
						//child.firstChild.nodeValue : based on the assumption that this always exists. We'll see...
					ret[child.nodeName] = child.firstChild.nodeValue;
					break;
				default:
					ret[child.nodeName] = parseNode(child);
					break;
			}
			var attributes:Array = getAttributes(child);
			if(attributes != null){
				if(ret[child.nodeName] == null){
					ret[child.nodeName] = new Object();
				}
				ret[child.nodeName].attributes = attributes;
			}
		}
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
		var channel:XMLNode = _feed.firstChild.firstChild;
		
		//get items from channel
		var itemNodes:Array = new Array();
		var len = channel.childNodes.length;
		for(var i = 0; i < len; i++){
			var node:XMLNode = channel.childNodes[i];
			if(node.nodeName == "item"){
				itemNodes.push(node);
			}
		}
			
		//construct Array from items
		var allItems = new Array();
		var allItemsLen = itemNodes.length;

		for(var i in allItems){
			for(var j in allItems[i]){
			}
		}
		
		//where clause
		//only where clause supported at the moment is a selection of ids. example: id IN (1,2,5)
		var idString = _whereClause.substring(_whereClause.indexOf("("), _whereClause.indexOf(")")); // => 1, 2, 5
		var split = idString.split(","); // =>

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
			
		for(var i = 0; i < allItemsLen; i++){
			var item = parseNode(itemNodes[i]);
			item["id"] = i;
			allItems.push(item);
		}
		
		//all went well with parsing. stock it for later
		_allItems = allItems;
		_getRecordsSuccessCallback(allItems);

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
			var copiedItem:Object = _allItems[ids[i]];
			wantedItems.push(copiedItem);
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

	/** property: urlBase
	 * the rss connector adds the calling component's formName parameter to this
	 * to create the url that will be called. 
	 * example:
	 * put "http://youserver.com/rss.php?feedName=" here, and "news" in DataSelector's formName.
	 * and the connector will call "http://youserver.com/rss.php?feedName=news"
	 * 
	 * */	
	[Inspectable(name="url base", type=String, defaultValue="")]
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
		//res_obj.xmlRootNodePath = xmlRootNodePath;

		return res_obj;
	}

}