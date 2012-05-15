//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.DataSetError;
import mx.data.to.ValueListIterator;

/**
  The dataset cursor is a shared object amongst all of the indexes for a dataset.  It provides
  the cursoring functionality within an index and adjusts all of its data points based on the index
  it is currently assigned to.
  
  @author	Jason Williams
*/
class mx.data.components.datasetclasses.DataSetIterator extends Object implements ValueListIterator {
	
	/**
	  Constructs a cursor associated with the specified dataset.
	  
	  @param	id String containing the identifier for this cursor
	  @param	aDataSet Object collection to iterate
	  @param	source DataSetIterator [optional] used to make a copy from
	  @author	Jason Williams
	*/
	function DataSetIterator( id:String, aDataSet:Object, source:DataSetIterator ) {
		super();
		_id = id;
		_dataset = aDataSet;
		//_sortData = null;
		if( source == undefined ) 
			reset();
		else {
			// all values are to come from the source
			__filtered = source.__filtered;
			__filterFunc = source.__filterFunc;
			_options= source._options;
			_startBuff= source._startBuff;
			_endBuff= source._endBuff;
			_rangeOn= source._rangeOn;
			_curItemIndex = source._curItemIndex;
			_hasPrev = source._hasPrev;
			_hasNext = source._hasNext;
			_cloned= true;
			_bof = source._bof;
			_eof = source._eof;
			_index = source._index;
			_indexById= source._indexById;
			_keyList= source._keyList;
		}
	}
	
	// ----------- public methods -------------------
	
	/**
	  Returns if the specified item is within this iterator's view of the collection.
	  
	  @return	Boolean indicating if the item specfied can be iterated.
	*/
	public function contains( item:Object ):Boolean {
		var indx:Number= _indexById[item[ItemId]];
		if( _rangeOn )
			return(( indx != undefined ) && (( indx <= _eof ) && ( indx >= _bof )));
		else
			return( indx != undefined );
	}
	
	/**
	  Moves to the first transfer object in the collection and returns it.
	  
	  @return	Object first transfer object within the collection
	  @author	Jason Williams
	*/
	public function first():Object {
		return( resync( _bof -1 ));
	}
	
	/**
	  Finds an occurance of a Transfer Object with the specified property values using the current
	  sort.  If the sort in combination with the property values specified, does not uniquely identify 
	  a Transfer Object the transfer object returned is non-deterministic.
	  
	  <b><i>NOTE:This operation requires that a sort be applied to this iterator.</i></b>
	  
	  @param	propValues Object containing the property values in raw form
	  @return	Object transfer object found that matches the criteria specified, null if no match or no
	  			sort has been set.
	*/
	public function find( propValues:Object ):Object {
		var index:Number = findObject( propValues, FindIndexId );
		if( index < 0 )
			return( null );
		else {
			_curItemIndex = index;
			return( _index[index] );
		}
	}
	
	/**
	  Finds the first occurance of a Transfer Object with the specified property values using the current
	  sort.
	  
	  <b><i>NOTE:This operation requires that a sort be applied to this iterator.</i></b>
	  
	  @param	propValues Object containing the property values in raw form
	  @return	Object first transfer object found that matches the criteria specified, null if no match or no 
	  			sorting has been set.
	*/
	function findFirst( propValues:Object ):Object {
		var index:Number = findObject( propValues, FindFirstIndexId );
		if( index < 0 )
			return( null );
		else {
			_curItemIndex = index;
			return( _index[index] );
		}
	}
	
	/**
	  Finds the last occurance of a Transfer Object with the specified property values using the current
	  sort.
	  
	  <b><i>NOTE:This operation requires that a sort be applied to this iterator.</i></b>
	  
	  @param	propValues Object containing the property values in raw form
	  @return	Object last transfer object found that matches the criteria specified, null if no match or no 
	  			sorting has been set.
	*/
	function findLast( propValues:Object ):Object {
		var index:Number = findObject( propValues, FindLastIndexId );
		if( index < 0 )
			return( null );
		else {
			_curItemIndex = index;
			return( _index[index] );
		}
	}
	
	/**
	  Returns the current item of this iterator.
	  
	  @return	Object reference to the current item, maybe null if
	  			iterator is currently beyond the endpoints.
	*/
	public function getCurrentItem():Object {
		return( resync( _curItemIndex ));
	}
	
	/**
	  Returns the current item's index within this iterator's view
	  
	  @return	Number containing the current item index
	*/
	public function getCurrentItemIndex():Number {
		// the item index needs to be adjusted for eof and bof here
		var result:Number = _curItemIndex;
		if( result > _eof )
			result = _eof;
		if( result < _bof )
			result = _bof;
		return( result );
	}
	
	/**
	  Indicates if this iterator's view of the collection is filtered.
	  
	  @return	Boolean indicating if this iterator has a filtered view of
	  			it's associated collection.
	*/
	public function getFiltered():Boolean {
		return( __filtered );
	}
	
	/**
	  Returns the associated filter function for this iterator.  The filter function
	  must have the following signature:
	  
	  	function x( item:Object ):Boolean
	
	  The function must return true if the specified item should remain within the iterator's
	  view of the collection.
	  
	  @return	Function used to filter items from this iterator's view of the collection
	*/
	public function getFilterFunc():Function {
		return( __filterFunc );
	}
	
	/**
	  Returns the identifier for this cursor.
	  
	  @return	String containing the id of this cursor
	*/
	public function getId():String {
		return( _id );
	}
	
	/**
	  Returns the transfer object at the specified index.
	  
	  @param	index Number index of the item within this iterator's view of the collection
	  @return	Object transfer object at the specified index
	*/
	public function getItemAt( index:Number ):Object {
		var newPos:Number = index+_bof;
		if( newPos <= _eof ) {
			return( _index[ newPos ]);
		}
		else
			return( null );
	}
	
	/**
	  Returns the item id for the transfer object at the specified index.
	  
	  @param	index Number index of the desired transfer object's id
	  @return	String containing the id of the specified transfer object
	*/
	public function getItemId( index:Number ):String {
		return( _index[ _bof+ index ][ ItemId ]);
	}
	
	/**
	  Returns the index in this iterator's view of the collection for the specified
	  item.  This method will compensate for range offsets, i.e. if the beginning of
	  the range is at index 2 then if the item is at index 2 this method will return
	  0, that is the specified item is at the start of the current view.
	  
	  @param	item transfer object to return index for
	  @return	Number containing the index of the specified item
	*/
	public function getItemIndex( item:Object ):Number {
		return( _indexById[item[ItemId]] - _bof );
	}
	
	/**
	  Returns the current length of the items currently visible by this iterator.
	  
	  @return	Number containing the number of items this iterator can see.
	*/
	public function getLength():Number {
		if( isEmpty())
			return( 0 );
		else
			return( _eof-_bof +1 );
	}
	
	/**
	  Returns the current sorting information.  If this iterator is
	  not sorted then the information will be undefined
	  
	  @return	Object with keyList:Array and options:Number properties
	*/
	public function getSortInfo():Object {
		return({ options:_options, keyList:_keyList });
	}
	
	/**
	  Indicates if there are more items in the collection to iterate moving toward the end.
	  
	  @return	Boolean true if there are still items to iterate moving toward the end.
	  @author	Jason Williams
	*/
	public function hasNext():Boolean {
		return( _hasNext );
	}
	
	/**
	  Indicates if there are more items in the collection to iterate moving toward the begining
	  
	  @return	Boolean true if there are still items to iterate moving toward the begining.
	  @author	Jason Williams
	*/
	public function hasPrevious():Boolean {
		return( _hasPrev );
	}
	
	/**
	  Indicates if the cursor's record buffer is empty.
		
	  @return	Boolean indicating if there are no records in the current index for this cursor
	  @author	Jason Williams
	*/
	public function isEmpty():Boolean {
		return( _eof < 0 );
	}
	
	/**
	  Moves to the last item in the collection and returns the item proxy
	  at that location
	  
	  @return	Object transfer object proxy for the last item within the collection
	  @author	Jason Williams
	*/
	public function last():Object {
		return( resync( _eof +1 ));
	}
	
	/**
	  Keeps the local view of the items sync'd with the collection.
	  
	  @param	eventObj Object event describing what has changed in the collection.
	  @return	Boolean indicating if the change should send a notification to all listeners
	*/
	public function modelChanged( eventObj:Object ):Boolean {
		var result:Boolean = false;
		if(( _options == Default ) && !__filtered ) {
			// recollect the index info
			_index = _dataset.__items;
			_indexById = _dataset._itemIndexById;
			// if we have deleted and are past the end now...reset
			if(( eventObj.eventName == "removeItems" ) && ( _curItemIndex > ( _index.length -1 )))
				_curItemIndex--;
			result = eventObj.eventName != "updateField";
		}
		else 
			if( !_cloned ) {
				var itm:Object;
				if( eventObj.eventName == "removeItems" ) {
					var id:String;
					var ids:Array=eventObj.removedIDs;

					// special casing for removeAll
					if(eventObj.firstItem == 0 && eventObj.lastItem == _index.length)
						_index.splice(0, eventObj.lastItem);	
					else {
						for( var i:Number=0; i<ids.length; i++ ) {
							id=ids[i];
							_index.splice( _indexById[ id ], 1 );
						} // for
					}
					//trace("length " + _index.length );
					rebuildIndexById();
					result = true;
				}
				else
					if( eventObj.eventName == "addItems" ) {
						var itms:Array = _dataset.__items; // used for add
						// if we are filtered see if item will add
						for( var i:Number=eventObj.firstItem; i<=eventObj.lastItem; i++ ) {
							itm= itms[i];
							var idx:Number = i;
							if( !__filtered || __filterFunc( itm )) {
								if( _options != Default )
									idx =findObject( itm, FindInsertId );
								_index.splice( idx, 0, itm );
								rebuildIndexById();
								result = true;
							}
						} // for
					}
					else
						if( eventObj.eventName == "updateField" ) {
							// check if we need to move the associated item either by filter or by range
							//trace( _id+"keyList.length?"+_keyList.length+ " "+result );
							for( var i:Number=0; ( i<_keyList.length ) && !result; i++ ) 
								result = _keyList[i] == eventObj.fieldName;
							if( result ) {
								//trace( "modified a key field!" );
								itm =_dataset.__items[ eventObj.firstItem ];
								// remove it from the list and find its new location
								_index.splice( _indexById[itm[ItemId]], 1 );
								var indx:Number = findObject( itm, FindInsertId );
								_index.splice( indx, 0, itm );
								rebuildIndexById();
							}
						}
			} // if not a default index and not a clone
		
		if( result ) 
			recalcEndPoints();
		//trace( _id+".end.modelChanged("+eventObj.eventName+")?"+result);
		return( result );
	}
	
	/**
	  Sets this iterator view to filtered or unfiltered based on the specified parameter.
	  
	  @param	value Boolean indicating if the iterator should have a filtered view of
	  			it's associated collection.
	  @return	Number containing the total count of items effected by the filter setting
	*/
	public function setFiltered( value:Boolean ):Number {
		var count:Number= 0;
		if( __filtered != value ) {
			count = internalFilterItems( value );
			__filtered = value;
		} // if
		return( count );
	}
	
	/**
	  Sets the associated filter function for this iterator.  The filter function
	  must have the following signature:
	  
	  	function x( item:Object ):Boolean
	
	  The function must return true if the specified item should remain within the iterator's
	  view of the collection.
	  
	  @param	value Function that should be used to filter this iterator's view of the collection.
	  @return	Number containing the number of items effected by the filter settting
	*/
	public function setFilterFunc( value:Function ):Number {
		var count:Number=0;
		__filterFunc = value;
		if(( __filterFunc == null ) && ( __filtered ))
			return( internalFilterItems( false ));
		if( __filtered ) {
			internalFilterItems( false );
			count = internalFilterItems( true );
		}
		return( count );
	}

	/**
	  Returns the current item in the iterator then moves the current record pointer by the amount 
	  indicated by offset. If offset is negative the default cursor is moved to a previous record, 
	  if positive it is moved forward. If the offset would move the cursor beyond the begnining or 
	  end of the collection, the cursor will instead be positioned at the beginning or end of the 
	  collection.
	
	  @param 	offset Number containing the number of items to skip the cursor position by
			   	e.g. -1 move backward one item; 2 move forward two items
	  @author 	Jason Williams
	*/
	public function skip( offset:Number ):Object {
		return( resync( _curItemIndex+ offset ));
	}
	
	/**
	  Moves to the next transfer object in the collection and returns a proxy to it.
	  
	  @return 	Object transfer object proxy
	*/
	public function next():Object {
		return( skip( 1 ));
	}
	
	/**
	  Moves to the previous transfer object in the collection and returns a proxy to it.
	  
	  @return	Object transfer object proxy.
	*/
	public function previous():Object {
		return( skip( -1 ));
	}
	
	/**
	  Removes the current end points for this cursor under its associated index
	  
	  @author	Jason Williams
	*/
	public function removeRange():Void {
		if( _rangeOn ) {
			_rangeOn = false;
			recalcEndPoints();
		}
	}
	
	/**
	  To reset this iterator to its initialized state, i.e. it was just constructed.
	*/
	public function reset():Void {
		__filtered = false;
		__filterFunc = null;
		_options= Default;
		_startBuff= null;
		_endBuff= null;
		_rangeOn= false;
		_cloned= false;
		_index = _dataset.__items;
		_indexById = _dataset._itemIndexById;
		resetEndPoints();
		_curItemIndex = _bof;
		_hasPrev= false;
		_hasNext= _curItemIndex<_eof;
	}
	
	/**
	  Sets the end points for this cursor to traverse between.  This effectively sets a range
	  on the underlying record buffer such that only a subset of those records will be visible
	  via the cursor.
	  
	  @param	startValues Object of key value pairs that represent the first record in the range
	  @param	endValues Object of key value pairs that represent the last record in the range
	  @author	Jason Williams
	*/
	public function setRange( startValues:Object, endValues:Object ):Void {
		checkSort();
		resetEndPoints();
		_rangeOn=true;
		_startBuff= startValues;
		_endBuff= endValues;
		recalcEndPoints();
	}
	
	/**
	  Sets the options of the current sort for the iterator's traversal through the items.  
	  This method will do nothing if a sort has not been applied. 
	  
	  @param	options Number valid values are:
	  				 <i>DataSetIterator.Ascending</i>
	  				 <i>DataSetIterator.Descending</i>
	  				 <i>DataSetIterator.CaseInsensitive</i>
	  				 <i>DataSetIterator.Unique</i>
	*/
	public function setSortOptions( options:Number ):Void {
		//trace( "setSortOptions("+options+")");
		if( _options != Default ) {
			// if ascending then remove descending
			if((( options & Ascending ) == Ascending ) && (( _options & Descending ) == Descending ))
				_options = _options^Descending;
				
			_options = _options | ( hasNumericKey() ? Array.NUMERIC : 0 );
			_options = _options | options;
			internalSort();
			first();
			recalcEndPoints();
		} // options are not default
	}
	
	/**
	  Sets the new sort options for this cursor.  These are almost identical to those in use 
	  by the array.sortOn(). This method will allow the user to setup a sorting on mutiple 
	  properties and how that sorting is performed, i.e. case insensitive, by number etc.
	  
	  @param	propList Array of property (field) names to sort on.
	  @param	options Number a bitwise or of the following constants:
					 <li>DataSetIterator.CaseInsensitive</li>
					 <li>DataSetIterator.Descending</li>
					 <li>DataSetIterator.Default</li>
					 <li>DataSetIterator.Unique</li>
	  @author	Jason Williams
	*/
	public function sortOn( propList:Array, options:Number ):Void {
		_options = options == undefined ? Ascending : options;
		_keyList= propList;
		_rangeOn= false;
		_options |= hasNumericKey() ? Array.NUMERIC : 0;
		internalSort();
		first();
		recalcEndPoints();
	}
	
	// ----------- constants -----------------------------
	
	static var Ascending:Number = 32;
	static var CaseInsensitive:Number = Array.CASEINSENSITIVE;
	static var Descending:Number = Array.DESCENDING;
	static var Unique:Number = Array.UNIQUESORT;
	static var Default:Number = 0;
	static var FindInsertId:Number = 0;
	static var FindIndexId:Number = 1;
	static var FindFirstIndexId:Number = 2;
	static var FindLastIndexId:Number = 3;
	
	// ----------- private members -----------------------
	
	// have accessors
	private var __filterFunc:Function;
	private var __filtered:Boolean;
	// no accessors
	private var _keyList:Array;
	private var _curItemIndex:Number;
	private var _eof:Number;
	private var _bof:Number;
	private var _hasPrev:Boolean;
	private var _hasNext:Boolean;
	private var _index:Array;
	private var _indexById:Array;
	private var _options:Number;
	private var _rangeOn:Boolean;
	private var _startBuff:Object;
	private var _endBuff:Object;
	private var _id:String;
	private var _dataset:Object;
	private var _cloned:Boolean;
//	private var _sortData:Object;
	static private var ItemId:String = "__ID__";

	/**
	  Throws an exception if there is no sort defined for this iterator.
	*/
	private function checkSort() {
		if( _options == Default )
			throw new DataSetError( "Operation not applicable when no sort has been defined. Error for iterator '"+_id+"'." );
	}
	
	/**
	  Throws an exception if the specified value is a number.  This method is used to check the 
	  return value from the sortOn method of the array class.  If an error occurs in the sorting
	  a number will be returned.
	  
	  @param	a either the number 0 or an array
	*/
	private function checkError( a ):Void {
		if( typeof( a ) == "number" )
			throw new DataSetError( "Sort failed with the following error '"+ mx.utils.ErrorStrings.getPlayerError( a )+ "'" );
	}
	
	/**
	  Compares to values, a and b and returns -1, 0, or 1 depending on the
	  results of the comparision.  
	  
	  <i>NOTE:</i>null is concidered less than any non-null value.
	  
	  @param	a Object value to compare
	  @param	b Object value to compare against a
	  @return	Number 0 if a == b, -1 if a < b, 1 if a > b.
	*/
	function compareValues( a:Object, b:Object ):Number {
		if(( a == null ) && ( b == null ))
			return( 0 );
		if( a == null )
		  return( 1 );
		if( b == null )
		   return( -1 );
		if( a < b )
			return( -1 );
		else
			if( a > b )
				return( 1 );
			else
				return( 0 );
	}
	
	/**
	  Compares the two property lists and returns an integer value indicating how the
	  values compare: -1, 0, or 1
	  
	  @param	alist Object property list to compare
	  @param	blist Object property list to compare
	  @param	ci Boolean indicates if the comparision should be done case insensitive.
	  @return	Number 0 if alist == blist, -1 if alist<blist, 1 if alist>blist
	*/
	private function comparePropList( alist:Object, blist:Object, ci:Boolean ):Number {
		var idx:String;
		var result:Number = 0;
		var i:Number = 0;
		var a:Object;
		var b:Object;
		while(( result == 0 ) && ( i<_keyList.length )) {
			idx = _keyList[i];
			a= alist[idx];
			b= blist[idx];
			if( ci && ( typeof( a ) == "string" )) {
				a= a.toLowerCase();
				b= b.toLowerCase();
			}
			result = compareValues( a, b );
			i++;
		} // while
		return( result );
	}
	
	/**
	  Indicates if the keylist has a numeric key value in it
	  
	  @return	Boolean indicating if one of the keys is numeric
	*/
	private function hasNumericKey():Boolean {
		var item:Object= _index[0];
		for( var i:Number=0; i<_keyList.length; i++ )
			if( typeof(item[_keyList[i]]) == "number" )
				return( true );
		return( false );
	}
	
	/**
	  Filters the current index and stores off the original index in the event that it is 
	  sorted and we want to return to the unfiltered state with the sorting intact.
	  
	  @return	Number of the items in the array affected by the filtering
	*/
	private function filterIndex():Number {
		var tmp:Array = new Array();
		var itm:Object;
		var keep:Boolean = false;
		var result:Number=0;
		var indx:Number = 0;
		/* if we are sorted lets not loose the sort
		if(( _options != Default ) && ( _sortData == null ))
			_sortData = { indexById:_indexById, index:_index };
		*/	
		_indexById = new Array();
		for( var i:Number=0; i<_index.length; i++ ) {
			itm=_index[i];
			// if the filter function throws an exception keep item
			try {
				keep=__filterFunc( itm );
			}
			catch( e:Error ) { 
				keep=true;
			}
			if( keep ) {
				tmp.push( itm );
				_indexById[itm[ItemId]]= indx;
				indx++;
			}
			else
				result--;
		} // for
		_index = tmp;
		_cloned= false;
		return( result );
	}
	
	/**
	  Finds the specified oject within the current index and returns the index id if found or -1 if not.
	
	  @param	propInfo Object containing the properties to look for, if this contains the ID of the object
	  			its index will be returned should it be in this iterator's view of the collection
	  @param	mode Number containing the type of find to perform.  
					Valid values are 
						<li>DataSetIterator.FindInsertId</li> position the buffer should be inserted into
						<li>DataSetIterator.FindIndexId</li> position the buffer is found at
						<li>DataSetIterator.FindFirstIndexId</li> position the first occurrance of the buffer is found at
						<li>DataSetIterator.FindLastIndexId</li> position the last ocurrance of the buffer is found at
	  @return	Number containing the id of the existing transfer object or the insertion position within the index.
				if the kind parameter is DataSetIterator.FindInsertId the return value will be the location
				the specified record buffer should be placed.  if the kind parameter is 
				DataSetIterator.FindIndexId	the return value will be the current location of the 
				record buffer within the index or -1 if it can not be located.
	  @exceptions
	  	  DataSetError if in insert mode an we have duplicate key values
	*/
	private function findObject( propInfo:Object, mode:Number ):Number {
		var id:Number = propInfo[ItemId];
		if(( id != undefined ) && ( mode != FindInsertId )) {
			var indx:Number=_indexById[ id ];
			// if outside the range we can't find it
			if(( _rangeOn ) && (( indx > _eof ) || ( indx < _bof )))
				indx=-1;
			return( indx );
		}
		// if we need an index then check that we have one
		checkSort();
		// let's begin searching
		var found:Boolean = false;
		var inSearchMode:Boolean =( mode == FindIndexId )||( mode == FindFirstIndexId )||( mode == FindLastIndexId );
					
		var nonUnique:Boolean = ( _options & Unique ) != Unique; 
		var objFound:Boolean = false;
		var index:Number = 0;
		var lowerBound:Number = inSearchMode ? _bof : 0;
		var upperBound:Number = inSearchMode ? _eof : _index.length -1;
		var obj:Object = null;
		var dir:Number = 1;
		var desc:Boolean = ( _options & Descending ) == Descending; // do we have a descending index?
		var ci:Boolean = ( _options & CaseInsensitive ) == CaseInsensitive; 
		while( !objFound && ( lowerBound <= upperBound )) {
			index = Math.round(( lowerBound+ upperBound ) /2 );
			obj = _index[index];
			dir = comparePropList( propInfo, obj, ci );
			switch( dir ) {
				case -1: 
					if( desc )
						lowerBound = index +1;
					else
						upperBound = index -1;
				break;
				
				case 0:
					objFound = true;
					if( !nonUnique && ( mode == FindInsertId )) 
						throw new DataSetError( "Duplicate key specified. Error for index '"+ _id + "' on dataset '"+ _dataset._name +"'." );
					// if non unique then we need to move through the buffer to determine if the record we have found 
					// meets the criteria.
					if( nonUnique && inSearchMode ) {
						switch( mode ) {
							case FindIndexId:
								found = true;
							break;
						
							case FindFirstIndexId:
								found= index == lowerBound;
								var props = null;
								// start looking towards bof
								var objIndex = index -1;
								var match = true;
								while( match && !found && ( objIndex >= lowerBound )) {
									props = _index[ objIndex ];
									match = comparePropList( propInfo, props, ci ) == 0;
									if( !match || ( match && ( objIndex == lowerBound ))) { 
										found= true;
										index = objIndex + ( match ? 0:1 );
									} // if match
									objIndex--;
								} // while
							break;
							
							case FindLastIndexId:
								// if we where already at the edge case then we already found the last value
								found= index == upperBound;
								var props = null;
								// start looking towards eof
								var objIndex = index +1;
								var match = true;
								while( match && !found && ( objIndex <= upperBound )) {
									props = _index[ objIndex ];
									match = comparePropList( propInfo, props, ci ) == 0;
									if( !match || ( match && ( objIndex == upperBound ))) { 
										found= true;
										index = objIndex - ( match ? 0:1 );
									} // if match
									objIndex++;
								} // while
							break;
						} // switch
						
					}
					else
						found = true;
				break;
				
				case 1: 
					if( desc )
						upperBound = index -1;
					else
						lowerBound = index +1;
				break;
			} // switch
		} // while
		if( !found && inSearchMode )
			return( -1 );
		else
			if( desc )
				return(( dir < 0 ) ? index +1: index );
			else
				return(( dir > 0 ) ? index +1: index );
	}

	/**
	  Filters the items within this iterator's view of the collection.
	  
	  @param	value Boolean indicating if the items should be filtered or not.
	  @return	Number containing the number of items affected by the filter, if 
	  			items are removed this number will be negative, if added it will
				be positive.
	*/
	private function internalFilterItems( value:Boolean ):Number {
		var affItems:Number =0;
		if(( value ) && ( __filterFunc != null )) 
			affItems = filterIndex();
		else {
			unfilterIndex();
			 if( _options != Default )
				internalSort();
			affItems= _index.length;
		}
		recalcEndPoints();
		return( affItems );
	}
	
	/**
	  Sorts this iterator based on the specified items, current keyList, and options.
	  
	  @param	items Array of items to sort and update internal index for
	*/
	private function internalSort():Void {
		//trace( _id+".internalSort()" );
		//_sortData = null;
		var opt = ( _options & Ascending ) == Ascending ? _options^Ascending : _options;
		if( _cloned ) {
			_cloned=false;
			var sorted = _index.sortOn( Object( _keyList ), opt | Array.RETURNINDEXEDARRAY );
			checkError( sorted );
			var tmp:Array = new Array();
			for( var i:Number=0; i<sorted.length; i++ )
				tmp.push(_index[sorted[i]]);
			_index = tmp;
		}
		else {
			checkError( _index.sortOn( Object( _keyList ), opt ));
		}
		rebuildIndexById();
	}
	
	/**
	  Recalculates the index of this iterator.  This will reset bof and eof points as well
	  as update the current item pointer.
	  
	*/
	private function recalcEndPoints():Void {
//trace( _id+ ".begin.recalcEndPoints() bof-"+_bof+" eof-"+_eof );		
		resetEndPoints();
		if( _rangeOn ) {
			var desc:Boolean = ( _options & Descending ) == Descending; // do we have a descending index?
			var temp;
			if(desc) {
				temp = _startBuff;
				_startBuff = _endBuff;
				_endBuff = temp;
			}
			// attempt to find the appropriate range values
			_bof= findObject( _startBuff, FindFirstIndexId );
			// if we can't find one of the endpoints we have to fail both
			if( _bof >= 0 ) {
				_eof= findObject( _endBuff, FindLastIndexId );
				if( _eof < 0 ) {
					_bof = 0;
				}
			}
			else
			{
				_eof= _bof-1;
			}
			_curItemIndex= _bof -1;
			//trace( _id+ ".begin.recalcEndPoints() bof-"+_bof+" eof-"+_eof );		

		} // range on
		resync( _curItemIndex );
//trace( _id+ ".end.recalcEndPoints() bof-"+_bof+" eof-"+_eof );		
	}
	
	/**
	  Resets bof and eof based on the current index settings.
	*/
	private function resetEndPoints():Void {
		_eof = _index.length -1;
		_bof = 0;
	}
	
	/**
	  Rebuilds the index list of ids.
	*/
	private function rebuildIndexById():Void {
		_indexById= new Array();
		for( var i:Number=0; i<_index.length; i++ ) {
			_indexById[_index[i][ItemId]]=i;
		} // for
	}
	
	/**
	  This method ensures that the new index is within the bounds of this iterator.
	  
	  @param	newPos Number indicating the desired new position within the collection
	  @return	Object transfer object at the specified location or null if outside the 
	  			range
	  @author	Jason Williams
	*/
	private function resync( newPos:Number ):Object {
		if( _eof < _bof ) {
			// view of collection is empty
			_hasNext=false;
			_hasPrev=false;
			_curItemIndex = _eof;
			return( null );
		}

		if( newPos >= _eof ) {
			// we have attempted to move past the end
			_hasNext = false;
			_hasPrev = true;
			if( newPos == _eof ) {
				_curItemIndex = _eof;
				return( _index[ _eof ]);
			}
			else {
				_curItemIndex = _eof +1;
				return( null );
			}
		}

		if( newPos <= _bof ) {
			// we have attempted to move before the begining 
			_hasPrev= false;
			_hasNext= true;
			if( newPos == _bof ) {
				_curItemIndex = _bof;
				return( _index[_bof] );
			}
			else {
				_curItemIndex = _bof -1;
				return( null );
			}
		}
		
		_curItemIndex = newPos;
		_hasNext = true;
		_hasPrev = true;
		return( _index[ _curItemIndex ]);
	}
	
	/**
	  Returns the index to an unfiltered state by retrieving either the last state 
	  of the index or the items array from the dataset.
	*/
	private function unfilterIndex():Void {
		_index = _dataset.__items;
		_indexById = _dataset._itemIndexById;
		_cloned = true; // we just sort-a cloned our selves again
	}

}
