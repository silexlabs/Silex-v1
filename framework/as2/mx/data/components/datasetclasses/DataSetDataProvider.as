//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.DataSetIterator;

/**
  Provides the DataProvider API for the DataSet.  This is implemented as a separate
  class so that calls made to the API are known as DataProvider API calls.  This
  is required since the DataProvider does not support any formatting of 
*/
class mx.data.components.datasetclasses.DataSetDataProvider extends Object {
	
	/**
	  Construcs a new instance of the DataProvider API for the specified DataSet
	  
	  @param	aDataSet Object reference to the DataSet this DP API is representing
	*/
	function DataSetDataProvider( aDataSet:Object ) {
		super();
		_dataset = aDataSet;
	}
	
	//------ properties ---------
	
	/**
	  Read-only; returns the length of the items in the data provider.
	*/
	function get length():Number {
		if(( _dg != null ) && ( _dgInit != true )) {
			_dgInit = true;
			var col:mx.controls.gridclasses.DataGridColumn;
			for( var i in _dg.columns ) {
				col=_dg.columns[i];
				col.editable = col.editable && !isFieldReadOnly( col.columnName );
			}
		}
		return( _dataset.length );
	}
	
	//------- public members -------
	
	/**
	  Makes sure that the listener for this is actually listening to the DataSet.
	  It is the DataSet that will dispatch the modelChanged event.
	  
	  @param	eventName String containing the name of the desired event
	  @param	handler function or object that will handle the event specified
	*/
	public function addEventListener( eventName:String, handler ):Void {
		// fix for bug#70600
		_desiredTypes = handler.getBindingMetaData( "acceptedTypes" ); // make sure we know how it is expected
		if( handler instanceof mx.controls.DataGrid ) {
			if( _dataset.readOnly )
				handler.editable = false;
			else {
				_dg = handler;
				_dgInit = false;
			}
		}
		_dataset.addEventListener( eventName, handler );
	}
	
	/**
	  Adds the specified item to the collection for management
	  
	  @param	item Object transfer object to add to the collection
	*/
	public function addItem( item:Object ):Void {
		_dataset.addItem( item );
	}
	
	/**
	  Adds the specified transfer object to the collection for 
	  management at the specified location.
	  
	  @param	index Number contaning the desired position within the collection
	  @param 	transferObj Object transfer object to manage within this DataSet collection
	  @tiptext	Adds the specified item to the collection
	  @helpid 	3400
	  @example
				myDataSet.dataProvider.addItemAt( 10, myDataSet.createItem()); 
	*/
	public function addItemAt( index:Number, transferObj:Object ):Void {
		_dataset.addItemAt( index, transferObj ); // this will update our items array
	}
	
	/**
	  Changes one transfer object's property within this collection.
	  
	  @param 	index Number >= 0. The index of the item. Fails if out of range 
	  @param	fieldName String, the name of the field in the item to modify. Fails if non-existent. 
	  @param	newData Object - the new data to put in the dp. 
	  tiptext	Sets new value for specified field
	  helpid	3400
	  @eaxmple 
	    // Modify the "label" of the 3rd item.
		myDataSet.dataProvider.editField( 2, "notes", "here are some new notes." ); 
	*/
	public function editField( index:Number, fieldName:String, newData:Object ):Void {
		var oldItem:Object = _dataset.__curItem;
		try {
			_dataset.__curItem = _dataset._iterator.getItemAt( index );
			var desType:String = _desiredTypes[fieldName];
			if( desType == null )
				desType = "String";
			_dataset.getField( fieldName ).setTypedValue( new mx.data.binding.TypedValue( newData, desType )); 
		}
		finally {
			_dataset.__curItem = oldItem;
		}
	}
	
	/**
	  Returns the list of column names for the DataSet.
	  
	  tiptext	Returns array of property names
	  helpid 	3400
	  @return	Array of Strings containing the labels to use for a column heading
	*/
	public function getColumnNames():Array {
		var result:Array = new Array();
		for( var i in _dataset.properties ) 
			result.push( i );
		result.reverse();
		return( result );
	}
	
	/**
	  Returns The editable-formatted data to be used. This allows the model to provide different 
	  formats of data for editing than for displaying.
	  
	  @param	index Number. (index>=0) and (index<dp.length). The index of the item to retrieve. 
	  @param	fieldName String the name of the field being edited. 
	  tiptext	Returns the unformatted property value specified
	  helpid	3400
	  @example
	  	// getting an editable string for the price field
    	trace( myDataSet.getEditingData( 4, "price" ); 
	*/
	public function getEditingData( index:Number, fieldName:String ):Object {
		//return( _dataset._iterator.getItemAt( index )[ fieldName ] );
		return( _dataset.getEditingData( fieldName, _dataset._iterator.getItemAt( index ), _desiredTypes )); 
	}

	/**
	  Returns the display view of the transfer object at the specified index. 
	  
	  @param	index Number. (index>=0) and (index<ds.length). The index of the item to retrieve. 
	  @return	Object transfer object at the specified index within this collection or
	  			undefined if index is out of range. 
	  tiptext 	Returns the item at the specified location
	  helpid 	3400
	*/
	public function getItemAt( index:Number ):Object {
		if( index >= _dataset.length )
			return( null );
		var itm:Object = _dataset._iterator.getItemAt( index );
		if( itm != null )
			return( _dataset.getDataProviderItem( itm, _desiredTypes ));
		else
			return( null );
	}
	
	/**
	  Returns the identifier of the current transfer object within the collection. 
	  @param	index Number [optional] specifing the index of the item we want the ID for,
	  			if not specified gets the id for the current item.
	  @return 	Number unique identifier for this item within this collection
	  @tiptext	Returns the unique id for the specified item.
	  @helpid	3400
	  @example
	
			var itemNo:Number = myDataSet.getItemID();
			displayStatusBarMsg( "Employee id("+ itemNo+ ")");
	*/
	public function getItemID( index:Number ):String {
		return( _dataset.getItemId( index ));
	}
	
	/**
	  This method will clear all of the items in the collection <i>regardless</i> of what the
	  default or current iterator's view of this collection is.  If logChanges is true each
	  item removed will be logged as such in the delta packet.
	*/
	public function removeAll():Void {
		_dataset.removeAll();
	}
	
	/**
	  Removes the transfer object from the collection at the specified index. This operation will be 
	  logged to the delta packet if logChanges is true. If the specified transfer object does not exist 
	  this method will do nothing.
	  
	  @param	index Number index of the item to remove
	  @example
				var emp:Employee = myManagementDataSet.currentItem();
				myManagementDataSet.removeItemAt( 5 );
				// give him a promotion
				myJanitorDataSet.addItem( emp );
	*/
	public function removeItemAt( index:Number ):Void {
		_dataset.removeItemAt( index ); // this will update our items array
	}
	
	/**
	  Replaces the contents of the item at the index specified. This method will call
	  removeItemAt() and then addItemAt().  If logChanges is true this method will
	  create two entries in the delta packet. Depedning on the sorting specified for
	  the default or current iterator the item may not show up at the index specified.
	  
	  @param	index Number >= 0. The index of the item to change. 
	  @param	item Object the new transfer object to replace  
	  @example
		  // Change the fourth item.
		  myDataSet.replaceItemAt( 3, new Employee( "Bob", "Smith" )); 
	*/
	public function replaceItemAt( index:Number, item:Object ):Void {
		removeItemAt( index );
		addItemAt( index, item );
	}

	/**
	  Sorts the items within the DataSet collection by the specified fields and options
	  
	  @param	fieldNames a single field name or a list of field names in an array to sort
	  			the items in the collection by.
	  @param	options a string containing either "ASC" or "DESC", or a number containing the
	  			options to sort the collection with
	*/
	public function sortItemsBy( fieldNames, options ):Void {
		var sortName:String;
		var newOptions:Number = 0;
		// if player 6 style is specified convert it to player 7
		if( typeof( options ) == "string" ) 
			newOptions = ( options.toUpperCase() == "DESC" ) ? Array.DESCENDING : DataSetIterator.Ascending;
		else
			newOptions= options;
			
		if( typeof( fieldNames ) == "array" ) 
			sortName = fieldNames.join( "_" );
		else {
			sortName= fieldNames;
			fieldNames = new Array( fieldNames );
		}
		// check to see if we should add case insensitive
		for( var i in fieldNames ) {
			if( _dataset.properties[fieldNames[i]].type.name == "String" ) {
				newOptions |= Array.CASEINSENSITIVE;
				break;
			}
		}
//trace( "sortItemsBy("+fieldNames.join()+","+options+","+newOptions+")");				
		if( _dataset.hasSort( sortName ))
			_dataset.useSort( sortName, newOptions );
		else
			_dataset.addSort( sortName, fieldNames, newOptions );
	}
	
	//--- public properties -----
	//public var items:Array;
	
	//----- private members -----
	private var _dataset:Object;
	private var _desiredTypes:Object;
	private var _dg:mx.controls.DataGrid; // fix for bug#70600 & #69503
	private var _dgInit:Boolean; // fix for bug#70600 & #69503
	
	
	private function isFieldReadOnly( name:String ):Boolean {
		return( _dataset.properties[name].type.readonly == true );
	}
}