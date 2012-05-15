//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
	 DataGlue class 
	 extends Object
	 The DataGlue ActionScript methods let you bind RecordSet objects to Flash components. 
	 The DataGlue object offers a way to format data records for use in a ListBox, ComboBox, 
	 or other UI components.
	 
	 @class	DataGlue
	 @tiptext Lets you bind RecordSet objects to Flash Components
	 @helpid	4447
*/

class mx.remoting.DataGlue extends Object {

//#include "RemotingComponentVersion.as"

	function DataGlue( dp:Object ) 
	{
		super();
		__dataProv = dp;
	}
	
	/* 
		Returns associated DataProvider that is being glued to the UI
		@return		Object	The dataProvider glued to the UI
	*/
	public function get dataProvider():Object {
		return( __dataProv );
	}
	
	/* 
		A string that defines how to format fields of a data record as labels, 
		which is the text that appears in the UI component. The format string is arbitrary text 
		that can contain record field names enclosed in pound signs (#)
		@param		String	A pound sign(#) enclosed string defining the format
		@return		String	The current formatter string being used
	*/
	public function get labelString():String {
		return( __labelStr );
	}
	
	public function set labelString( val:String ):Void {
		__labelStr = val;
	}
	
	/* 
		A format string that defines how to format fields of a data record as the data associated with the record
		@param		String	A string defining the format for fields in a record
		@return		String	string currently being used to format fields in a record
		@tiptext	returns/sets dataString
	*/
	public function get dataString():String {
		return( __dataStr );
	}
	
	public function set dataString( val:String ):Void {
		__dataStr = val;
	}
	
	/**
		Binds a data provider, such as a RecordSet object, to a data consumer, 
		such as a ListBox, and formats the data from the data provider for the consumer
		@param	Object	A Flash component, such as ListBox or ComboBox or other components supporting DataProvider objects
		@param	Object	A RecordSet or other object that implements the dataProvider interface
		@param	String	A format string that defines how to format fields of a data record as a label, which is the text that appears in the UI component. 
		@param	String	A format string that defines how to format fields of a data record as the data associated with the record
		@tiptext	Formats the values of the specified DataProviders based on given format strings
		@helpid		4448
	*/
	public static function bindFormatStrings(dataConsumer:Object, dp:Object, labelStr:String, dataStr:String):Void	{
		var proxy:DataGlue = new DataGlue(dp);
		proxy.labelString = labelStr;
		proxy.dataString = dataStr;
		proxy.getItemAt = DataGlue.prototype.getItemAt_FormatString;
		dataConsumer.dataProvider = proxy;
	}
	 
	/** 
		Binds a data provider, such as a RecordSet object, to a data consumer, such as a ListBox component, and formats the data using a function, which a user sepcifies
		@param		Object	 A Flash component, such as ListBox or ComboBox or other components supporting DataProvider objects
		@param		Object	 A RecordSet or other object that implements the dataProvider interface
		@param		Function A user-defined function that takes a data record as a parameter. This function must return an ActionScript object that contains the fields Label and Data
		@tiptext	Formats the values of the specified DataProviders based on provided custom function
		@helpid		4449
	*/
	public static function bindFormatFunction(dataConsumer:Object, dp:Object, formatFunc:Function): Void {
		var proxy = new DataGlue(dp);
		proxy.formatFunction = formatFunc;
		proxy.getItemAt = DataGlue.prototype.getItemAt_FormatFunction;
		dataConsumer.setDataProvider(proxy);
	}
	
	function addEventListener( eventName:String, listener ):Void {
		dataProvider.addEventListener( eventName, listener );
	}
	
	/* 
	    Returns number of records in a dataProvider
	    @return		Number	the length of the dataProvider
	*/
	function get length():Number {
		return( getLength());
	}
	
	/* 
	    Method to return the length of dataProvider
	    @return		Number	
	    @tiptext	returns length of dataProvider
	*/
	function getLength():Number {
		return( dataProvider.length );
	}
	
	/* 
		Formats and returns the fields in a record. The format string is arbitrary text 
		that can contain record field names enclosed in pound signs (#)
		@param		String	string defining the format
		@param		Object	record to be formatted
		@return		String	the formatted fields of a record
		@tiptext	returns a formatted string
	*/
	function format(formatString:String, item:Object ):String {
		var tokens:Array = formatString.split("#");
		var result:String = "";
		var tlen:Number = tokens.length;
		var nextTok:String;
		for (var i:Number = 0; i < tlen; i += 2) {
			result += tokens[i];
			nextTok = tokens[i+1];
			if( nextTok != undefined )
				result += item[nextTok];
		}	
		return result;
	}

	/* 
		Formats and returns an Object at a given index in dataProvider. The Object returned is a name-value pair of label, 
		data at a specified index.
		@param		Number index of the item	
		@return		Object	
		@tiptext	formats and returns the fields in a record at a given index
	*/
	private function getItemAt_FormatString( index:Number ):Object 
	{
		var item:Object = dataProvider.getItemAt(index);
		if(item == "in progress" || item==undefined)
			return( item );
		return({ label: format(labelString, item), data: (dataString == null) ? item : format(dataString, item) });
	}
	

	/* 
		Invokes the format function for specified index in the dataProvider which has downloaded and returns an Object.
		@param		Number index of the item  
		@return		Object	
		@tiptext	invokes the user-defined formatFunction for a specified index in the dataProvider
	*/
	private function getItemAt_FormatFunction(index:Number):Object {	
		var item:Object = dataProvider.getItemAt(index);
		if (item == "in progress" || item==undefined)
			return( item );
		return( formatFunction( item ));
	}
	
	/* 
		Returns the unique ItemID for a specified index in the DataProvider. Each record has a unique ID associated with it.
		When a record is deleted, its ID is retired and will never be used again in the same RecordSet object.
		@param		Number the index of the item for which ItemID has to be returned
		@return		String	
		@tiptext	Returns a unique ItemID for a specific item
	*/
	function getItemID(index:Number):String {
		return( dataProvider.getItemID(index));
	}
	
	/* 
	    Inserts a record at a specified index in the dataProvider. A number 0 or greater that indicates 
	    the position at which to insert the item (the index of the new item).
	    @param	Number index at which value is to be inserted
	    @tiptext	invokes the formatFunction for a specified index in the dataProvider
	*/
	function addItemAt(index:Number, value):Void {
		dataProvider.addItemAt(index, value);
	}
	
	/* 
	    Inserts a record at the end of the DataProvider 
	    @param	value
	    @tiptext	Inserts a value at the end of the dataProvider
	*/
	function addItem(value):Void	
	{ 
		dataProvider.addItem(value);
	}
	
	/* 
	    Removes the item at the specified index position. The dataProvider indices after the 
	    index indicated by the index parameter collapse by one. 
	    @param	Number index at which item has to be removed
	    @tiptext	removes an item at a given index
	*/
	function removeItemAt(index:Number):Void {
		dataProvider.removeItemAt(index);
	}
	
	/* 
	    Removes all records in the dataProvider. The length of the dataProvider hereafter becomes 0
	    @tiptext	removes all the items from a dataProvider
	*/
	function removeAll():Void {
		dataProvider.removeAll();
	}
	
	/* 
		Replaces the content of the record at the index specified by the index parameter.
	    @param		Number index at which item has to be replaced with a new value
	    @param		Object the new value
	    @tiptext	replaces an item at a given index with a new value
	*/
	function replaceItemAt(index:Number, itemObj:Object):Void {
		dataProvider.replaceItemAt(index, itemObj);
	}
	
	/* 
	    Sorts all records in the dataProvider without making a new copy. 
	    The sort key value for each record is the contents of the field identified by the field ID. 
	    The original order is not saved. 
	    @param		Array an array of all the records
	    @param		Number the option number according to which dataProvider has to be sorted
	    @tiptext	sorts a dataProvider according to spefied option
	*/
	function sortItemsBy(fieldNames:Array, optionFlags:Number):Void {
		dataProvider.sortItemsBy(fieldNames, optionFlags);
	}
	
	/* 
	    Sorts the dataProvider records on the basis of a user-supplied function. A number can be 
	    specified as an optionFlag which will sort the list in ascending or descending order.
	    @param		Function
	    @param		Number the option number according to which dataProvider has to be sorted
	    @tiptext	sorts a dataProvider according to spefied option
	*/
	function sortItems( compareFunc:Function, optionFlags:Number ):Void {
		dataProvider.sortItems(compareFunc, optionFlags);
	}
	
	public var getItemAt:Function;
	
	private var __dataProv:Object; //!!@Fix this to be the new interface
	private var __labelStr:String;
	private var __dataStr:String;
	private var formatFunction:Function;
	private var dataConsumer:Object;
}