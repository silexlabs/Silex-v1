/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.dataConnectors.RssConnector;
import mx.utils.Delegate;

/** Communicate with the OOF/Silex Excel scripts. Works only for reading at the moment 
 *
 * @author Ariel Sommeria-klein
 * @author lex@silex.tv
 **/
class org.oof.dataConnectors.ExcelConnector extends RssConnector{

	private var _excelFilePath:String = null;
	private var _combineItemsFrom:String = null;
	
    /**
	 * constructor
	 * @return void
	 */
	function ExcelConnector(){
		super();
		_className = "org.oof.dataConnectors.ExcelConnector";
     	// inheritance
     	typeArray.push(_className);
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
		
		var url:String = _urlBase + "?file_name=" + _excelFilePath + "&get_values=" + selectedFieldNames + "&combine_items_from=" + _combineItemsFrom;
		// reveal accessors in the url and form name
		var finalUrl:String = silexPtr.utils.revealAccessors(url, this);
		if (!finalUrl){
			finalUrl = _urlBase + formName;
		}
		
		// load the feed
		_feed.load(finalUrl);
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

	/** property: excelFilePath
	 * 
	 * */	
	[Inspectable(name="excelFilePath", type=String, defaultValue="test.xlsx")]
	public function set excelFilePath(val:String){
		_excelFilePath = val;
	}

	
	public function get excelFilePath():String{
		return _excelFilePath;
	}		

	/** property: combineItemsFrom
	 * 
	 * */	
	[Inspectable(name="combine items from", type=String, defaultValue="rows")]
	public function set combineItemsFrom(val:String){
		_combineItemsFrom = val;
	}

	
	public function get combineItemsFrom():String{
		return _combineItemsFrom;
	}		

}