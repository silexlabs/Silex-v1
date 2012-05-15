//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.Connection;
import mx.remoting.NetServiceProxy;
import mx.remoting.NetServices;
import mx.remoting.RsDataFetcher;
import mx.data.DataRange;
import mx.data.PageableList;
import mx.remoting.RecordSetIterator;
import mx.utils.Iterator;

/**
  Record sets created on an application server usually consist of database query
  results. In a RecordSet object, individual records are identified by an index number.
  the index starts at zero. Whenever 
  a record set is sorted 
  a record is added to a record set
  a record deleted from the record set
  the index changes. 
  
  Each field of the record is represented by a field in the object. For a RecordSet
  object that originated from an application server, the field names are the same as
  the names of the fields as defined by the server-side record set. For local RecordSet
  objects, the field names are as defined in the original call to the new RecordSet()
  function.
   
   @tiptext	Contains database query results
   @helpid	4455
 */
class mx.remoting.RecordSet extends Object implements PageableList {
	
//#include "RemotingComponentVersion.as"

	/**
	  If a RecordSet object is received from a server via the AMF protocol, then
	  there will be a field called "serverInfo" already existing when the constructor is called
	  by the AMF deserializer. The fields are:
	 	totalCount: int
	 	columnNames: array of string
		initialData: array of array of field
		id: string
		version: int
		cursor: int
		serviceName: string
	  
	  If the RecordSet is being created by the normal "new RecordSet()" call, then
	  "serverInfo" will not exist.
 	 NOTE: the server counts records starting from number 1, but we count starting from 0.
	  
 	 @param	columnNames	Array of strings with the names of the columns for this recordset.
 	 @tiptext	Creates a RecordSet with the specified column names
 	 @helpid	4456
	*/
	function RecordSet(columnNames:Array) {	
		super();
		mx.events.EventDispatcher.initialize( this );
		_items = new Array();
		uniqueID=0;
		if (mTitles != null) {
			// we've already been constructed.
			// this should happen only when the object is a
			// shared object that's being reloaded into memory.
			return;
		}
	
		// serverinfo comes back in different case among the servers ... making it the same (mixed case)
		if (serverInfo == null) {
			if (serverinfo != null) {
				serverInfo = serverinfo;
			}
		}
	
		if (serverInfo == null)	{
			// there's no server information - we're done
			mTitles = columnNames;
			return;
		}
	
		// this RecordSet came from a server.
		if (serverInfo.version != 1) {
			NetServices.trace("RecordSet", "warning", 100, "Received incompatible RecordSet version from server");
			return;
		}
	
		// set up the initial contents of the RecordSet
		mTitles = serverInfo.columnNames;
		mRecordsAvailable = 0;
		//this.mHighWater = 0;
		setData((serverInfo.cursor == null) ? 0 : (serverInfo.cursor - 1), serverInfo.initialData);
	
		if (serverInfo.initialData.length != serverInfo.totalCount)
		{
			mRecordSetID = serverInfo.id;
			// we haven't yet got all the data
			// RED FLAG: "Id" is in mixed case
			if (mRecordSetID != null)
			{
				// if id is non-null, there are more records still on the server.
				// this therefore is a server-associated RecordSet
				serviceName = (serverInfo.serviceName == null) ? "RecordSet" : serverInfo.serviceName;
	
				// initialize other fields
				mTotalCount = serverInfo.totalCount;
				mDeliveryMode = "ondemand";
				mAllNotified = false;
				mOutstandingRecordCount = 0;
			}
			else
				NetServices.trace("RecordSet", "warning", 102, "Missing some records, but there's no RecordSet id");
		}
		
		serverInfo = null;
	}

	/**
	 Inserts a record into the RecordSet object at the end. 
	 
	 @param		item	Object the record to add.
	 @tiptext	Adds the specified item at the end of a RecordSet
	 @helpid	4457
	*/
	function addItem( item:Object ):Void {
		addItemAt( length, item );
	}
	
	/**
	  Inserts a record into the RecordSet object at the specified index.
	
	  @param	index	Number	the index at which the record is to be inserted
	  @param	item	Object	the record to add.
	  @tiptext	Adds an item in the RecordSet at a specified index
	  @helpid	4458
	*/
	function addItemAt( index:Number, item:Object ):Void 
	{
		var addItemFlag:Boolean = true;

		if((index<length) && (index >= 0)) 
			items.splice(index, 0, item);
		else
			if( index== length )
				items[index]=item;
		  	else 
			{
				addItemFlag = false;
				NetServices.trace("Cannot add an item outside the bounds of the RecordSet");
				return;
			}
		if(addItemFlag)
			item.__ID__ = uniqueID++;
		updateViews( "addItems", index, index);
	}
	

	/**
	  Adds the specified listener to the list of listeners for given event.
	  
	  @param	event String containing the name of the event to listener for
	  @param	listener Object/Function that will listen to the spceified event
	  @tiptext	Adds the specified listener for the given event
	  @helpid	4504
	*/
	function addEventListener(event:String, listener ):Void {
		// functionality provided by EventDispatcher mixin
	}
	
	/**
	 Remove all records from the RecordSet. 
	
	 @tiptext	Removes all the items from a RecordSet
	 @helpid	4459
	*/
	function clear():Void 
	{
		if( checkLocal()) 
              return;

		var len:Number = items.length;
		
		items.splice( 0 );
		uniqueID = 0;
		updateViews( "removeItems", 0, len );
	}
	
	/**
		Indicates if the RecordSet contains the specified record or not.
	 
		@param		item	Object	checks whether the record exists in the RecordSet.
		@return		Boolean	true if the record exists in the RecordSet otherwise false.
		@tiptext	Indicates if the specified item is contained in a RecordSet
		@helpid	4460
	*/
	function contains( itmToCheck:Object ):Boolean 
	{
		if(isObjectEmpty(itmToCheck))
			return false;

		var itemAtIndex:Object;
		var retStatus:Boolean;
		for(var i=0; i<items.length; i++)
		{
			itemAtIndex = items[i];
			retStatus = true;
			for(var t in itmToCheck)
			{
				if(itmToCheck[t] != itemAtIndex[t])
				{
					retStatus = false;
					break;
				}
			} 
			if(retStatus)
				return true;
		} 
		return false;
	}
	
	/**
	 Returns the names of all the columns of a RecordSet object as an array of strings.
	 The array is either the same array that you passed into the RecordSet constructor,
	 or the equivalent array for an application server-associated RecordSet object.
	
	 @return	Array of strings (columNames).
	 @tiptext	Returns an array of column names in a RecordSet
	 @helpid	4461
	*/
	function getColumnNames():Array {
		return( mTitles );
	}

	/**
	 Returns the names of all the columns of a RecordSet object as an array of strings.
	 The array is either the same array that you passed into the RecordSet constructor,
	 or the equivalent array for an application server-associated RecordSet object.
	
	 @return	Array	an array of strings (columNames).
	 @tiptext	Column names in a RecordSet
	 @helpid	4462
	*/
	function get columnNames():Array {
		return( getColumnNames());
	}
	
	/**
	 Returns the number of records in the local RecordSet.
	
	 @return	Number	length of the local RecordSet.
	 @tiptext	Number of items currently downloaded from the server
	 @helpid	4463
	*/
	function getLocalLength():Number {
		return( items.length );
	}
	
	/**
	 Returns the number of records in the RecordSet.
	
	 @return	Number	length of the RecordSet.
	 @tiptext	Total number of items available in a RecordSet
	 @helpid	4464
	*/
	function getLength():Number {
		if (mRecordSetID != null) {
			// a server-associated RecordSet
			//trace("RecordSet.getLength from server: " + mTotalCount);
			return( mTotalCount );
		}
		else {
			// a local RecordSet
			//trace("RecordSet.getLength: " + items.length);
			return( items.length );
		}
	}

	/**
	 Returns a new instance of RecordSetIterator for the RecordSet in use.
	
	 @return	RecordSetIterator	a new instance of iterator for the RecordSet in use.
	 @tiptext	Returns an iterator for a RecordSet
	 @helpid	4465
	*/
	function getIterator():Iterator
	{
		var rsIterator = new RecordSetIterator(this);
		return(rsIterator);
	}

	/**
	 Returns the number of records in the RecordSet.
	
	 @return	Number	The length of the RecordSet.
	 @tiptext	Returns the number of records in a RecordSet
	 @helpid	4466
	*/
	function get length():Number {
		return( getLength());
	}

	/**
 	 Returns a record if the index is valid and the record has downloaded completely.
	 If the requested record index number is less than zero or greater than the largest
	 record index number, it returns null. If the index number is valid but the requested
	 record has not yet been downloaded, it returns the string "in progress". Remember that
	 RecordSet object index changes when records sorted/deleted/added.
	
	 @param		index	Number The record number to retrieve.
	 @return	Object	a record to be inserted
	 @tiptext	Returns an item at a specified index in a RecordSet
	 @helpid	4467
	*/
	function getItemAt(index:Number):Object {
		// trace("RecordSet.getItemAt(" + index + ")");
		// It is server associated. See if the index is valid. 
		if ((index < 0) || (index >= this.length)) {
			return( null );
		}
		// RED FLAG "Id"
		if (mRecordSetID == null) {
			// this is not a server-associated RecordSet
			//trace("RecordSet.getItemAt not server-associated");
			return( items[index] );
		}
	
		// let the paging lookahead code have a look at this request.
		// (even if the record is in memory we might still want to request a download of the page)
		requestRecord(index);
	
		var result = items[index];
		if (result == 1) 
		  return( "in progress" );
		//trace("RecordSet.getItemAt(" + index + ") returning " + result);
		return( result );
	}

	/**
	 Returns a unique ID corresponding to the record, at the specified index.
	 The RecordSet object assigns each record a unique ID. The ID is not part
	 of the record; it is a separate item that is associated with the record
	 internally within the RecordSet object. Unlike a record index, its ID will
	 not change when the RecordSet object is sorted or when records are added or
	 deleted. When a record is deleted, its ID is retired and will never be used
	 again in this RecordSet object.
	
	 @param		index	Number the index number of the record.
	 @return	Object	a unique identification (ID) corresponding to the record, at the specified index. Returns null if the index is out of range.
	 @tiptext	Returns the ID corresponding to the record at a specified index
	 @helpid	4468
	*/
	function getItemID( index:Number ):Object {
		return( items[index].__ID__ );
	}
	
	/**
	 Returns an array of all records of the RecordSet.
	
	 @return	Array	an array of all records.
	 @tiptext	Provides access to local items of the RecordSet
	 @helpid	4469
	*/
	function get items():Array {
		return( _items );
	}
	
	function initialize( info:Object ):Void {
		// nothing to do here
	}
	
	//-------------------------------------------------------------
	// public data Manipulation functions
	//-------------------------------------------------------------
	
	/**
	 Creates a new RecordSet object by calling the filterFunction method once for
	 each record in the RecordSet object and consolidating all the records, for which the
	 filterFunction method returns true, into a new RecordSet object. The order
	 of the records in the new RecordSet object is the same as their order in the
	 original RecordSet object. The order in which the original RecordSet object is
	 traversed during the filtering process is not defined.

		If used on a RecordSet object that is not fully-populated, only the currently
	 available records are filtered. The new RecordSet object does not inherit the
	 original RecordSet object's list of views, nor any association with a server-side
	 RecordSet object. 
	
	 @param		filterFunction	Function an ActionScript function that takes one or two
	 parameters and returns true or false . The first parameter is a single 
	 record from the RecordSet object.The second, optional, parameter is a 
	 context value that the function uses to determine whether to include 
	 the record in the result. The function must return true if the record
	 should be included in the result RecordSet object. 

	 @param		context		a context value supplied by the caller. This value is the second parameter to the filter function.
	 @return	RecordSet	a new RecordSet object that contains a reference, not a copy, to all the records that were selected by the filterFunction function.
	 @tiptext	Returns a filtered RecordSet based on the specified filter function
	 @helpid	4470
	*/
	function filter(filterFunction:Function, context):RecordSet {
		if(checkLocal()) 
		  return null;
	
		// create a new, empty RecordSet
		var result:RecordSet = new RecordSet(mTitles);
	
		// loop over all the records in the current RecordSet
		// find the ones that the the filter function approves of,
		// and add it to the result
		var rcount:Number = length;
		for(var i:Number = 0; i < rcount; i++) {
			var item:Object = getItemAt(i);
			if ((item != null) && (item != 1) && filterFunction(item, context))	{
				result.addItem(item);
			}
		}
	
		//trace("RecordSet.filter: " + NetServices.objectToString(result));
		return( result );
	}

	/**
	 Sorts all the records using a user-specified compare function. The sort method sorts
	 all the records in place, without making a new copy. The order is determined by the
	 user-supplied compareFunction function. The original order is not remembered. 
	
	 @param	compareFunc Function an ActionScript comparison function that determines the sorting order. 
	 Given the arguments A and B, the comparison function returns a value as follows: 
	 -1 if A appears before B in the sorted sequence. 
	 0 if A = B. 
	 1 if A appears after B in the sorted sequence. 
	 
	 @param	optionFlags	Number one or more numbers or strings, separated by the | (bitwise OR) operator, 
	 that change the behavior of the sort from the default. The following values are acceptable for option: 
	 1 or Array.CASEINSENSITIVE 
	 2 or Array.DESCENDING 
	 4 or Array.UNIQUESORT 
	 8 or Array.RETURNINDEXEDARRAY 
	 16 or Array.NUMERIC 

	 @tiptext	Sorts items based on a specified compare function
	 @helpid	4471
	*/
	function sortItems( compareFunc:Function, optionFlags:Number ):Void {
		if( checkLocal())
			return;
		
		items.sort( compareFunc, optionFlags );
		updateViews( "sort" );
	}
	
	/**
	 Sorts all records in the RecordSet object without making a new copy. The sort key value for each
	 record is the contents of the field identified by the field ID. The original order is not saved.
	
	 @param		fieldNames	Array fieldNames on which sorting needs to be done.
	 @param		optionFlags	Number one or more numbers or strings, separated by	the | (bitwise OR) operator, 
	 that change the behavior of the sort from the default. The following values are acceptable for option : 
	 1 or Array.CASEINSENSITIVE 
	 2 or Array.DESCENDING 
	 4 or Array.UNIQUE 
	 8 or Array.RETURNINDEXEDARRAY 
	 16 or Array.NUMERIC 
	 
	 @tiptext	Sorts items based on fields specified
	 @helpid	4472
	*/
	
	function sortItemsBy( fieldNames:Array, order :String, optionFlags:Number ):Void {
		if( checkLocal())
			return;

		if (typeof(order)=="string") 
		{
			items.sortOn(fieldNames);
			if (order.toUpperCase()=="DESC") 
			{
				items.reverse();
			}
		} 
		else 
		{
			items.sortOn(fieldNames, optionFlags);
		}
		updateViews( "sort" );
	}
	
	/**
	 Sorts all the records using a user-specified compare function. The sort method sorts 
	 all the records in place, without making a new copy. The order is determined 
	 by the user-supplied compareFunction function. The original order is not remembered.

	 @param	compareFunc	Function	an ActionScript comparison function that determines	the sorting order. Given the arguments A and B, the comparison function returns a value as follows: 
	 -1 if A appears before B in the sorted sequence.
	 0 if A = B. 
	 1 if A appears after B in the sorted sequence. 

	 @tiptext	Sorts items with the specified compare function
	 @helpid	4473
	*/
	function sort(compareFunc:Function):Void {
		if (checkLocal()) 
		  return;
	
		items.sort(compareFunc);
		updateViews( "sort" );
	}


	//-------------------------------------------------------------
	// public data delivery functions
	//-------------------------------------------------------------
	
	/**
	 Determines whether a RecordSet object is empty or not.
	 
	 @return	Boolean		returns true if the RecordSet is empty otherwise false.
	 @tiptext	Indicates if there are any items in a RecordSet
	 @helpid	4474
	*/
	function isEmpty():Boolean {
		return( items.length == 0 );
	}
	
	/**
	 Determines whether a RecordSet object is local or associated with an application server
	 and records remain to be retrieved from the application server. This method is functionally
	 identical to the RecordSet.isFullyPopulated method.
	
	 @return	Boolean returns true if the RecordSet object is local and false if records remain to be retrieved from the application server.
	 @tiptext	Indicates if this RecordSet is server associated
	 @helpid	4475
	*/
	function isLocal():Boolean {
		return( mRecordSetID == null );
	}

	/**
	 Determines whether a RecordSet object is fully populated, that is, has all its records. Local
	 RecordSet objects are always fully populated. RecordSet objects provided by application servers
	 are fully populated after all of their records have been downloaded from the application server.
	
	 @return	Boolean		returns true if the RecordSet object is fully populated or false if the RecordSet object is not fully populated.
	 @tiptext	Indicates if a server associated RecordSet has had all items downloaded
	 @helpid	4476
	*/
	function isFullyPopulated():Boolean {
		return( isLocal());
	}
	

	/**
	 Returns the number of records available on the server. 
	 
	 @return	Number length of the RecordSet at the server side. 
	 @tiptext	Total number of items at the server for server associated RecordSets
	 @helpid	4477
	*/
	function getRemoteLength():Number {
		if( isLocal())
			return( mRecordsAvailable );
		else
			return( mTotalCount );
	}

	/**
	 Returns the number of records that have been downloaded from the server. The count does not
	 include records that have been requested but not yet arrived. For local RecordSet objects,
	 this will always return the same value as the getLocalLength method.
	
	 @return	Number	length of the RecordSet which either equal to getLocalLength or getRemoteLength.
	 @tiptext	Total number of items downloaded from the server 
	 @helpid	4478
	*/
	function getNumberAvailable():Number {
		if (isLocal())
			return( getLength());
		else
			return( mRecordsAvailable );
	}
	
	/**
	 Replaces a record in the RecordSet object at the specified index. The record's contents are replaced 
	 with the contents of the record parameter. The record's ID does not change. When you use the 
	 replaceItemAt method, avoid the following conditions: 
	 1. Index out of range. 
	 2. The record parameter is not an object. 
	 3. The record parameter has unknown or missing fields. 
	 4. The RecordSet object is associated with an application server and not fully populated yet. 
	
	 @param		index	Number the index number of the record.
	 @param		item	Object the record which will replace the existing record at the specified index.
	 @tiptext	Replaces an item at the specified index
	 @helpid	4479
	*/
	function replaceItemAt( index:Number, item:Object ):Void {
		if (index>=0 && index<=length) {
			var tmpID = getItemID(index);
			items[index] = item;
			items[index].__ID__ = tmpID;
			updateViews( "updateItems", index, index );
		}
	}
	
	/**
	 Removes all records from the record set. Do not use the removeAll method, when the RecordSet
	 object is associated with an application server and not fully populated yet.
	
	 @return	Void
	 @tiptext	Removes all the items from a RecordSet
	 @helpid	4480
	*/
	function removeAll():Void {
		clear();
	}
	
	/**
	 Removes the record at the specified index in the RecordSet. The associated record ID is never used again in the RecordSet object.
	 When you use the removeItemAt method, avoid the following conditions: 
	 1. Index out of range. 
	 2. The RecordSet object is associated with an application server and not fully populated yet.
	
	 @param		index	Number the index number of the record.
	 @return	Object	The removed record
	 @tiptext	Removes an item from the specified index
	 @helpid	4481
	*/
	function removeItemAt( index: Number ):Object {
		var result:Object = _items[index];
		_items.splice( index, 1 );
		var rItems:Array = [_items[index]];
		var rIDs:Array = [getItemID(index)];
		dispatchEvent({type:"modelChanged", eventName:"removeItems", firstItem:index, lastItem:index, removedItems:rItems, removedIDs:rIDs});
		return( result );
	}

	/**
	  Removes the specified listener from the list of listeners for given event.
	  
	  @param	event String containing the name of the event
	  @param	listener Object/Function that will listen to the spceified event
	  @tiptext	Removes the specified listener for the given event
	  @helpid	4503
	*/
	function removeEventListener( event:String, listener ):Void {
		// functionality provided by EventDispatcher mixin
	}

	function requestRange( range:DataRange ):Number {
		var index:Number = range.getStart();
		var lastIndex:Number= range.getEnd();
		return( internalRequestRange( index, lastIndex ));
	}

	/**
	 Changes the delivery mode of a record set associated with an application server.
	 At any time, a RecordSet object associated with an application server is operating 
	 in a particular data-delivery mode. The new mode setting takes effect immediately,
	 except that pending application server requests are allowed to complete. You can
	 change mode settings and delivery mode parameters.
	
	 @param		mode				String				Identifies the delivery mode. The options are ondemand (default), fetchall, and page. 
	 @param		pagesize			Number (Optional)	In page mode, what the page size is in fetchall mode, how many records to fetch in each server request. The default is 25.
	 @param		numPrefetchPages	Number(Optional)	In page mode, the number of pages to prefetch. The default is 0, fetch only the required page.
	 @tiptext	Sets the delivery mode for server associated RecordSets
	 @helpid	4482
	*/
	
	function setDeliveryMode(mode:String, pagesize:Number, numPrefetchPages:Number):Void {
		//trace("RecordSet.setDeliveryMode(" + mode + "," + pagesize + "," + numPrefetchPages + ")");
		mDeliveryMode = mode.toLowerCase();
		stopFetchAll();
		
		//fix for 88084
		if (pagesize == null || pagesize <=0) 
		{
			// deduce the page size from our views...
			// !!@ doc note: you must up at least one view (via setDataProvider) before doing setDeliveryMode
			// !!@ doc note: if there are multiple views, we use the pagesize of the first view 
			// !!@ doc note: if the listbox gets resized, you must call setDeliveryMode again
			//pagesize = this.views[0].getRowCount();
			//if (pagesize == null)
			pagesize = 25;
		}
		
		switch( mDeliveryMode ) {
			case "ondemand":
			break;
			
			case "page":
				if (numPrefetchPages == null)
					numPrefetchPages = 0;
		
				mPageSize = pagesize;
				mNumPrefetchPages = numPrefetchPages;
				// !!@ doc note: 0 is ok for numPrefetchPages, it means fetch only the current page.
			break;
			
			case "fetchall":
				stopFetchAll();
				startFetchAll(pagesize);
			break;
			
			default:
				NetServices.trace("RecordSet", "warning", 107, "SetDeliveryMode: unknown mode string");
			break;
		}
	}

	/**
	  Replaces one field of a record with a new value specified. When you use the editField method, avoid the following conditions: 
	  Index out of range
	  The RecordSet object is associated with an application server and not fully populated yet
	  Unknown field name. The fieldName parameter does not equal a valid column name
	
	 @param		index		Number	The index number of the record.
	 @param		fieldName	String	The field name to replace.
	 @param		value		(any dataType)	The new value to insert into the field.
	 @tiptext	Sets the value of the specified field for an item at a given index
	 @helpid	4483
	*/
	function editField (index : Number, fieldName : String , value):Void 
	{
		changeFieldValue(index,fieldName,value);
	}	


	/**
	 
	 Returns the specified fieldName of a record at the specified index in the RecordSet.
	
	 @param		index	Number	the index of the item
	 @param		fieldName	String	the name of the field to edit
	 @return	Object	an Object containing the field data from the record
	 @tiptext	Returns the specified field data from an item at a specified index
	 @helpid	4484
	
	*/
	function getEditingData (index:Number, fieldName:String):Object
	{
		return items[index][fieldName];
	}

	/**
	 Replaces one field of a record with a new value. When you use the setField method, avoid the following conditions: 
	 Index out of range. The RecordSet object is associated with an application server and not fully populated yet. 
	 Unknown field name. The fieldName parameter does not equal a valid column name
	
	 @param	Number	The index number of the record.
	 @param	String	The field name to replace.
	 @param	(any dataType)	The new value to insert into the field.
	 @tiptext	Sets the value of the specified field for an item at a given index
	 @helpid	4485
	*/
	function setField (index : Number, fieldName : String , value):Void 
	{
		changeFieldValue(index,fieldName,value);
	}	

	private function changeFieldValue(index : Number, fieldName : String , value):Void 
	{
		if (checkLocal()) return;

		if (index<0 || index>=getLength()) {
			return;
		}
		
		items[index][fieldName] = value;
		updateViews( "updateItems", index, index);
	}
	
	//returns true if Object has no attrubutes
	private function isObjectEmpty(objToCheck:Object)
	{	
		var emptyFlag:Boolean = true;
		for(var i in objToCheck)
		{
			emptyFlag = false;
			return emptyFlag;
		}
		return emptyFlag;
	}
	
	//reads an array and returns an object
	private function arrayToObject(anArray:Array):Object {
		if (mTitles == null) {
			NetServices.trace("RecordSet", "warning", 105, "getItem: titles are not available");
			return( null );
		}
	
		var result:Object = new Object();
		var alen:Number = anArray.length;
		var title:String;
		for (var i:Number = 0; i < alen; i++) {
			title=mTitles[i];
			if (title == null)
				title = "column" + i + 1;
			result[title] = anArray[i];
		}
		return( result );
	}

	private function checkLocal():Boolean{
		if (isLocal())
			return( false );
		else {
			NetServices.trace("RecordSet", "warning", 108, "Operation not allowed on partial recordset");
			return( true );
		}
	}

	private function getRecordSetService():NetServiceProxy {
		if (mRecordSetService == null) 
		{
			if (gateway_conn == null) 
			{
				// _setParentService never got called. this will only happen if:
				//  - RecordSet is not the top-level return value, or
				//  - NetServiceProxyResponder is not in use (i.e. there is a developer-supplied response object 
				//    for the service call that returned this RecordSet
				
				gateway_conn = mx.remoting.NetServices.createGatewayConnection();
			}
			else 
			{
				// A parent netconnect has been supplied. If necessary,
				// make a new netconnection, so we can have separate debug flags
				if (_global.netDebugInstance != undefined) {
					gateway_conn = gateway_conn.clone();
				}
			}
			
			if (_global.netDebugInstance != undefined) {
				gateway_conn.setupRecordSet();
				gateway_conn.setDebugId("RecordSet " + mRecordSetID);
			}
	
			mRecordSetService = gateway_conn.getService(serviceName, this);
			if (mRecordSetService == null) {
				NetServices.trace("RecordSet", "warning", 101, "Failed to create RecordSet service");
				mRecordSetService = null; // so we don't get a flood of error messages
			}
		}
		
		return( mRecordSetService );
	}
	
	private function internalRequestRange( index:Number, lastIndex:Number ):Number {
		//trace("RecordSet.internalRequestRecordRange(" + index + "," + lastIndex + ")");
		var highestRequested:Number = -1;
		// make sure indices are valid
		if (index < 0)
			index = 0;
			
		if (lastIndex >= getRemoteLength())
			lastIndex = getRemoteLength() - 1;
	
		// find sequences of null entries to request
		// we could also just make a bunch of individual requests, but this seems 
		// cleaner. the server should be able to handle either case efficiently.
		var first:Number; // this is the index of the first null entry in a group
		var last:Number;
		while (index <= lastIndex) {
			while ((index <= lastIndex) && (items[index] != null))
				index++;

			first = index;
			while ((index <= lastIndex) && (items[index] == null)) {
				mOutstandingRecordCount++;
				items[index] = 1;
				index++;
			}
			last = index - 1;
	
			if (first <= last) 
			{
				logger.logInfo( " Fetching records from index ["+first+"] to index ["+last+"]");
				getRecordSetService().getRecords(mRecordSetID, first + 1, last - first + 1);
				highestRequested = last;
				updateViews("fetchRows", first, last);
			}
		}
		return( highestRequested );
	}
	
	private function removeItems( index:Number, len:Number):Void {
		var itemIDs:Array = new Array();
		for (var i:Number=0; i<len; i++) {
			itemIDs.push(getItemID(index+i));
		}
		var oldItems:Array = items.splice(index, len);
		//updateViews( "removeItems", index, index+len, oldItems, itemIDs );
		dispatchEvent({type:"modelChanged", eventName:"removeItems",
					  		firstItem:index, lastItem:index+len-1,
							removedItems:oldItems, removedIDs:itemIDs});
	}

	//-------------------------------------------------------------
	// Responses from the RecordSet service
	//-------------------------------------------------------------
	
	// this function is where all our data comes in from the RecordSet service
	private function getRecords_Result(info:Object):Void {
		//trace("RecordSet.getRecords_Result(), start=" + info.Cursor +
		//	", id=" + info.id + ", data=" + info.Page);
	
		setData(info.Cursor - 1, info.Page);
		mOutstandingRecordCount -= info.Page.length;
		// !!@ assert (this.mOutstandingRecordCount) >= 0
		updateViews("updateItems", info.Cursor - 1, info.Cursor - 1 + info.Page.length - 1);
	
		if ((mRecordsAvailable == mTotalCount) && !mAllNotified) {
			updateViews("allRows");
			mRecordSetService.release();
			mAllNotified = true;
			mRecordSetID = null;
			mRecordSetService = null;
		}
	}
	
	private function release_Result():Void {
		// ignore this
	}

	private function requestOneRecord(index):Void 
	{
		if (items[index] == null) 
		{
			if(mDeliveryMode == "ondemand")
				logger.logInfo(" INFO: Fetching Record ["+index+"]");

			getRecordSetService().getRecords(mRecordSetID, index + 1, 1);
			mOutstandingRecordCount++;
			items[index] = 1;
			updateViews("fetchRows", index, index);
		}
	}
	
	private function requestRecord(index:Number):Void {
		if (mDeliveryMode != "page") 
		{
			// fetchall, ondemand or unknown
			requestOneRecord(index);
			// !!@ if in fetchall mode, should start fetching from here, and wrap around to 1 later on
		}
		else {
			// we're in page mode
			// !!@ there is probably a better algorithm, but messier
			// the current algorithm works fine if records are always fetched in increasing index order
			// but goes wierd if not.
		
			// See if we need to prefetch the next N+1 pages, starting at index
			// (its N+1 because we always prefetch *the current page* as well
			// as any requested other pages)
			var firstIndex:Number = int(index / mPageSize) * mPageSize;
			var lastIndex:Number = firstIndex + (mPageSize * (mNumPrefetchPages + 1)) - 1;
			internalRequestRange(firstIndex, lastIndex);
		}
	}

	private function _setParentService(service:NetServiceProxy):Void {
		gateway_conn = service.nc;
	}

	private function setData(start:Number, dataArray:Array):Void {
		//trace("setData " + start + "," +dataArray.length);
		var datalen:Number = dataArray.length;
		var index:Number;
		var rec:Object;
		for (var i:Number = 0; i < datalen; i++) {
			index = i + start;
			rec = items[index];
			if ((rec != null) && (rec != 1)) {
				// why are we getting this data! we already have it
				NetServices.trace("RecordSet", "warning", 106, "Already got record # " + index);
			}
			else
				mRecordsAvailable += 1;
	
			items[index] = arrayToObject(dataArray[i]);
			items[index].__ID__ = uniqueID++;
		}
	}

	private function startFetchAll(pagesize:Number):Void {
		//trace("RecordSet.startFetchAll()");
		if( mDataFetcher != null )
			mDataFetcher.disable();
		mDataFetcher = new mx.remoting.RsDataFetcher(this, pagesize);
	}
	
	private function stopFetchAll():Void {
		//trace("RecordSet.stopFetchAll()");
		mDataFetcher.disable();
		mDataFetcher = null;
	}

	private function updateViews(event:String, first:Number, last:Number): Void {
		dispatchEvent({type:"modelChanged", eventName: event, firstItem:first, lastItem:last});
	}
	
	// Ensure that RecordSets received via AMF messages get
	private static function registerRecordSet():Boolean {
		Object.registerClass( "RecordSet", mx.remoting.RecordSet );
		return( true );
	}
	
	// server-associated RecordSet only
	public var serverInfo:Object; // attached by the player
	public var serverinfo:Object; // attached by the player
	public var serviceName:String; 

	//-------------------------------------------------------------
	// private definitions
	//-------------------------------------------------------------

	private static var init:Boolean = registerRecordSet();
	private var dispatchEvent:Function; // mixed in by the EventDispatcher
	// all RecordSets have these fields
	private var mTitles:Array;
	private var uniqueID:Number;
	private var _items: Array;

	// server-associated RecordSet only
	private var mRecordSetID:Number; // - if non-null, then this is a server associated RecordSet
	private var mRecordSetService:NetServiceProxy;
	private var mTotalCount:Number;
	private var mRecordsAvailable:Number;
	private var mDeliveryMode:String;
	private var gateway_conn:Connection;
	private var mDataFetcher:RsDataFetcher;

	// only if deliverymode = "page"
	private var mPageSize:Number;
	private var mNumPrefetchPages:Number;
	private var mAllNotified:Boolean;
	private var mOutstandingRecordCount:Number;
	var logger:mx.services.Log;
}


