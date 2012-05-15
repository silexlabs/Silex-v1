//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.binding.Binding;
import mx.data.binding.ComponentMixins;
import mx.data.binding.DataType;
import mx.data.binding.TypedValue;
import mx.data.components.datasetclasses.DataSetDataProvider;
import mx.data.components.datasetclasses.DataSetError;
import mx.data.components.datasetclasses.DataSetIterator;
import mx.data.components.datasetclasses.Delta;
import mx.data.components.datasetclasses.DeltaImpl;
import mx.data.components.datasetclasses.DeltaItem;
import mx.data.components.datasetclasses.DeltaPacket;
import mx.data.components.datasetclasses.DeltaPacketConsts;
import mx.data.components.datasetclasses.DeltaPacketImpl;
import mx.data.to.ValueListIterator;
import mx.events.EventDispatcher;
import mx.utils.ClassFinder;
import mx.utils.Iterator;


[RequiresDataBinding(true)]

/**
  Fires just before an item is added to the collection. If the result property
  of this event is set to false the item will not be added to the collection.
  
  @tiptext	Dispatched before item is added
  @helpid	1496
*/
[Event("addItem")]

/**
  Fires after the items array has been set (loaded).
  
  @tiptext	Dispatched after items array is assigned
  @helpid	1497
*/
[Event("afterLoaded")]

/**
  Fires when the collection has changed in some way
  
  @tiptext	Dispatched when the items have been modified in some way
  @helpid	1498
*/
[Event("modelChanged")]

/**
  Fires when a DeltaPacket has been assigned to the DataSet that contains
  messages.  Typically this is returned from a Resolver in response to errors
  on the server.
  
  @tiptext	Dispatched when a DeltaPacket is assigned that contains messages
  @helpid	1499
*/
[Event("resolveDelta")]

/**
  Fires when an item is about to be removed. The listener to this event can
  stop the remove from occuring by setting the result property of the event
  to false.
  
  @tiptext	Dispatched before an item is to be removed
  @helpid	1500
*/
[Event("removeItem")]

/**
  Fires when the delta packet has been changed and is ready to be used.  This
  event will <i>only</i> fire when after a call is made to applyUpdates().
 
  @tiptext	Dispatched when the delta packet is ready to be used
  @helpid	1501
*/
[Event("deltaPacketChanged")]

/**
  Fires when the current iterator of the DataSet moves to a new position. This
  happens when methods like next(), previous(), last(), first(), setRange(), 
  removeRange() are called that manipulate the position of the iterator.
  
  @tiptext	Dispatched when the iterator's position is changed
  @helpid	1502
*/
[Event("iteratorScrolled")]

/**
  This event fires when a new transfer object is constructed using the createItem(...) method. 
  A listener can make any modifications to the item before it is added to the collection for management. 
  
  @helpid	1503
  @tiptext	Dispatched when a new item is constructed by the DataSet, before being added to the collection.
*/
[Event("newItem")]

/**
  This event fires when values of calculated fields for the current transfer object need to be determined.
  At this point the listener will perform the required calculation and set the value for the 
  calculated field, i.e. a field on the schema tab with its kind property equal to "calculated".
  This event is called for a given transfer object when a non-calculated (e.g. field with its kind property
  equal to "data") property of that transfer object is updated. For more information on the kind property see
  <b><i>Do not change the values of any of this dataset's non-calculated fields in this event, doing so
  will cause an endless loop.</i></b><br> You should only set the values of calculated field within the
  calcFields event
  
  @helpid	1506
  @tiptext	Dispatched when calculated fields should be updated
*/
[Event("calcFields")]

[IconFile("DataSet.png")]
/**
  The DataSet component is a facade for a specialized collection engine, its iterator, indexing capabilities, 
  and update management. The collection utilized by the DataSet is an implementation of the Collection that 
  manages mutation operations on transfer objects stored within the collection. These mutation operations can 
  be transmitted, translated, stored for later retrieval or undone. Items within the collection can be iterated 
  using filters, sorting, ranges, and random access.

  When used in conjunction with a Connector and Resolver the DataSet collection provides a client side implementation 
  of the J2EE Value List Handler (collection of transfer objects).  This implementation makes no restrictions on the 
  type of transfer objects in use and is assumed that the transfer objects will in fact be constructed by a transfer 
  object assembler allowing for a complex data model, that decouples the persistent store implementation dependencies 
  from the client.

  @class DataSet
  @tiptext Manages collection of transfer objects
  @helpid	1507
*/
dynamic class mx.data.components.DataSet extends MovieClip {

	/**
	  Constructs a new empty DataSet. 
	  
	  @author	Jason Williams
	  @throws	DataSetError
	  @example
	    var myDataSet: DataSet;
		try {
			myDataSet = new DataSet();
			myDataSet.schema = new XML( "&lt;properties&gt;&lt;property name=\"test\" type=\"string\" size=\"35\"/&gt;&lt;/properties&gt;" );
		}
		catch( dsError ) {
			if( dsError instanceof DataSetError ) {
				alert( dsError.messages[0] );
			}
		}
	*/
	function DataSet() {
		super();
		_loading= false;
		_eventDispatcher = new Object();
		EventDispatcher.initialize( _eventDispatcher );
		super_addBinding = ComponentMixins.prototype.addBinding;
		// fix for bug#   provides an object that can be used to encode/decode field values
		_fldValObj = new Object();
		_fldValObj.__schema = __schema;
		ComponentMixins.initComponent( _fldValObj );
		//end fix
		ComponentMixins.initComponent( this );
		__toProperties = new Object();
		_calcFields = new Object();
		_calcFields.__length__ = 0;
		initCollection(); // clears delta packet as well
		initIterators();
		_enableEvents = 0;
		_event = null;
		_itemClass = null;
		_hasDelta =0;
		_deltaPacket = null;
		_filterFunc = null;
		_visible = false; // don't let us get the focus
		_filtered = false;
		_srcSchema = null; // fix for bug #69970
		_defValues = new Object();
		// if these are set during onClip( construct ) keep them as is
		_name = _name == undefined ? "" : _name;
		__logChanges = __logChanges == undefined ? true: __logChanges;
		__readOnly = __readOnly == undefined ? false: __readOnly; 
		__itemClassName= __itemClassName == undefined ? "": __itemClassName;
		_trapProperties = false;
		buildSchema(); // builds schema XML from __schema info
		createProperties();
	}
	
	//------- properties ----------

	/**
	  Read-only; The current transfer object the default iterator is pointing to.
	  
	  @tiptext Gets the current transfer object
	  @helpid  1508
	  @example
	  		var emp:Employee = employees.currentItem;
	   		employees.removeItem();
			janitors.addItem( emp );
	*/
	public function get currentItem():Object {
		return( __curItem );
	}
	
	/**
	  Contains all of the mutation operations that have been made to this 
	  collection and its transfer objects. If no mutations have been made
	  this property will be null.
	  
	  @tiptext Returns or assigns changes
	  @helpid  1509
	  @example
		 // convert the delta packet into XML
		 var delta:DeltaPacket = eventObj.deltaPacket;
		 var dpCursor:Iterator = delta.getIterator();
		 var item:Delta=dpCursor.next();
		 while( dpCursor.hasNext()) {
		   // ...
		 }
	*/
	[Bindable]
	[ChangeEvent("deltaPacketChanged")]
	public function get deltaPacket():DeltaPacket {
		return( _deltaPacket );
	}
	
	public function set deltaPacket( dp:DeltaPacket ):Void {
		// if we have any outstanding transaction compare to see
		// if this is one of the packets we have been waiting for
		if( dp != null ) {
			// look through the delta packet and make any needed mods
			var dpi:Iterator = dp.getIterator();
			var d:Delta;
			var resPckt:Array= new Array();
			var dpInfo:Object =_dpIndexByTransId[ dp.getTransactionId() ];
			if( dpInfo != undefined ) {
				internalClearDeltaPacket( dp.getTransactionId());
				// get any errors
				while( dpi.hasNext()) {
					d= Delta( dpi.next());
					// if we can't locate it
					if( dpInfo.items[ d.getId()] == null ) {
						throw new DataSetError( "Couldn't resolve item with ID ["+d.getId()+ "] specified in deltaPacket ["+dp.getTransactionId()+ "]. Error for DataSet '"+_name+"'." );
					}
					applyResolvePacket( d, resPckt, dpInfo.items ); 
				} // while
				// if we had errors notify any listeners
				if( resPckt.length > 0 ) 
					internalDispatchEvent( "resolveDelta", { data:resPckt });
			} 
			else {
				var itm:Object;
				var oldLC:Boolean = __logChanges; // store off for later
				__logChanges = dp.logChanges() && __logChanges;
				_enableEvents--;
				var keyInfo:Object = dp.getKeyInfo();
				addSort( dp.getTransactionId(), keyInfo.keyList, keyInfo.options );
				try {
					// perform update 
					while( dpi.hasNext()) {
						d= Delta( dpi.next());
						switch( d.getOperation()) {
							case DeltaPacketConsts.Modified:
								//itm= _iterator.find( convertToRaw( d.getSource(), KeysOnly )); // convert only key values for search
								// convert to raw will only return a blank object.
								// we wouldn't be able to find it in iterator
								itm= convertToRaw( d.getSource(), KeysOnly );
								if( itm != null ) {
									var curItem= __curItem;
									try {
										__curItem=itm;
										var di:Object; //!!@@ bug in compiler here doesn't like DeltaItem;
										var cl:Array = d.getChangeList();
										for( var i:Number = 0; i<cl.length; i++ ) {
											di= cl[i];
											// update the item
											if( di.kind == DeltaItem.Property ) {
												var typeInfo=__toProperties[di.name].type;
												getField( di.name ).setTypedValue( new TypedValue( di.newValue, typeInfo.name, typeInfo ));
											}
											else
												this[di.name].apply( itm, di.argList );
										} // for
									}
									finally {
										__curItem= curItem;
									}
								}
							break; // modified
							
							case DeltaPacketConsts.Added:
								itm = convertToRaw( d.getSource( true ), All );
								itm = createItem( itm ); 
								addItem( itm );
							break;
							
							case DeltaPacketConsts.Removed:
								itm= convertToRaw( d.getSource(), KeysOnly );
								itm= _iterator.find( itm );
								if( itm != null ) 
									removeItem( itm );
							break;
						} // switch
						if( itm == null )
							_global.__dataLogger.logData( null, "Couldn't find the following item:", d.getSource());
					} // while
				}
				finally {
					applyUpdates();
					removeSort( dp.getTransactionId());
					_enableEvents++;
					__logChanges = oldLC;
					internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
				}
			}// not resolving a server returned packet
		} // was there something to do?
	}
	
	/**
	  DataProvider interface for this dataset. This property is added to support the 
	  UI controls like the list and data grid. 
	  
	  @tiptext Returns the DataProvider API
	  @helpid  1510
	  @example
		// hookup the data grid
		myGrid.dataProvider = myDataSet.dataProvider;
	*/
	[Bindable(type="DataProvider")]
	public function get dataProvider():Object { 
		return( new DataSetDataProvider( this ));
	}
	
	public function set dataProvider( dp:Object ):Void {
		if( dp != null ) {
			_loading = true;
			var oc:Boolean = __logChanges;
			try {
				__logChanges = false;
				// reset all current items
				initCollection();
				if(( dp.length > 0 ) && hasInvalidSchema())
					defaultSchema( dp.getItemAt( 0 ), true ); 
				// if the user wants to have an object created
				var create:Boolean = ( _itemClass != null ) || ( __itemClassName.length > 0 ) || ( _eventDispatcher.__q_newItem != undefined );
				var itm:Object;
				for( var i:Number=0; i<dp.length; i++ ) {
					itm = dp.getItemAt(i);
					itm = create ? createItem( itm ) : itm;
					// set default vals if the properties arent already set
					for( var j in __toProperties ) {
						var val1=_defValues[j];
						if( val1 != null && itm[j] == null )
							itm[j] = val1;
					}
	
					internalAddItem( itm, i, false, true ); // don't rebuild index, but, pipe the data
				}
				rebuildItemIndexById();
				initIterators();
				internalDispatchEvent( "afterLoaded" );
				internalDispatchEvent( "modelChanged", { eventName:"updateAll", firstItem:0, lastItem:length });
			}
			finally {
				__logChanges = oc;
				_loading= false;
			} // try..finally
		} // if
	}
	
	/**
	  Indicates if the default iterator is filtered. i.e. some of the transfer objects will
	  not show up during iteration.  This value is associated with the iterator, so an 
	  assignment of an iterator may change the value of this property.
	  
	  @helpid  1511
	  @tiptext Indicates if items are filtered
	*/
	public function get filtered():Boolean {
		return( _filtered );
	}
	
	public function set filtered( value:Boolean ):Void {
		if( _filtered != value ) {
			if( _iterator.setFiltered( value ) != 0 ) {
				__curItem = internalFirst();
				internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
			}
			_filtered = value;
		}
	}
	
	/**
	  Method used to filter the default iterator's view of this collection's transfer objects.
	  This method will get called for each item in the collection under the following conditions
	  when the filtered property is set to true:
	  	<li>The item has not been filtered previously</li>
	  	<li>A property of an item has been modified</li>
	  The filter method is associated with each iterator, so an assignment of an iterator may
	  change the value of this property.
	  
	  @helpid  1512
	  @tiptext Method used for filtering items
	*/
	public function get filterFunc():Function {
		return( _filterFunc );
	}
	
	public function set filterFunc( value:Function ):Void {
		if( _filterFunc != value ) {
			if( _iterator.setFilterFunc( value ) != 0 ) {
				__curItem = internalFirst();
				internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
			}
			_filterFunc = value;
		}
	}
	
	/**
	  Collection of transfer objects for this DataSet. 
  
      @tiptext Items of the collection
	  @helpid  1513
	  @example
		// Create a new collection of transfer objects with only two fields
		myDataSet.schema = new XML( "<fields..." ); // left intentionally incomplete
		var recData = new Array();
		for( var i:Number=0; i<100; i++ ) 
		  recDat[i]= {id:i, name:String("name"+i)};
		myDataSet.items = recData;
	*/
	[Bindable]
	public function get items():Array {
		return( __items );
	}
	
	public function set items( itms:Array ):Void {
		var oc:Boolean = __logChanges;
		_loading = true;
		try {
			__logChanges = false;
			// reset all current items
			initCollection();
			if(( itms.length > 0 ) && hasInvalidSchema())
				defaultSchema( itms[0] ); 
			// if the user wants to have an object created
			var create:Boolean = ( _itemClass != null ) || ( __itemClassName.length > 0 ) || ( _eventDispatcher.__q_newItem != undefined ); 
			var itm:Object;
			for( var i:Number=0; i<itms.length; i++ ) {
				itm = itms[i];
				itm = create ? createItem( itm ) : itm;
				// set default vals if the properties arent already set
				for( var j in __toProperties ) {
					var val=_defValues[j];
					if( val != null && itm[j] == null )
						itm[j] = val;
				}
				internalAddItem( itm, i, false, false ); // don't rebuild index or pipe the data
			}
			rebuildItemIndexById();
			initIterators();
			internalDispatchEvent( "afterLoaded" );
			internalDispatchEvent( "modelChanged", { eventName:"updateAll", firstItem:0, lastItem:length });
		}
		finally {
			__logChanges = oc;
			_loading= false;
		} // try..finally
	}
	
	/**
	  Used to construct an instance of the specified class during a createItem() call.
	  See addItem() and createItem() methods for more detail on how item creation works.
	  
	  @tiptext Object to create when assigning items
	  @helpid  1514
	*/
	[Inspectable(defaultValue="")]
	public function get itemClassName():String {
		return( __itemClassName );
	}
	
	public function set itemClassName( value:String ):Void {
		if(( __itemClassName != value ) && ( __items.length > 0 ))
			throw new DataSetError( "ItemClass can not be changed when there are already items in the collection. Error for DataSet '"+_name+"'." );
		__itemClassName = value;
		_itemClass = null;
	}
	
	/**
	  Total number of transfer objects viewable within this collection based on the
	  current iterator.
	  
	  @tiptext Currently viewable length of items in collection
	  @helpid  1515
	  @example
		// alert the user if there are not enough entries made
		if( myDataSet.length &lt; MIN_REQUIRED )
			alert( "Not enough entries have been made. You need at least "+MIN_REQUIRED );
	*/
	public function get length():Number {
		//return( getLength());
		return( _iterator.getLength());
	}
	
	/**
	  Indicates if changes should be tracked and recorded in the DeltaPacket.
	  
	  @tiptext Indicates if mutations on the collection are recorded
	  @helpid  1516
	  @example
	  	 myDataSet.logChanges = false;
		 myDataSet.clear();
		 myDataSet.logChanges = true;
	*/
	[Inspectable(defaultValue="true")]
	public function get logChanges():Boolean {
		return( __logChanges );
	}
	
	public function set logChanges( value:Boolean ):Void {
		__logChanges = value;
	}
	
	/**
	  List of all of the exposed properties for any transfer object within this collection.
	  This property provides the for in loop discoverability of the defined properties (fields) 
	  on this DataSet for each transfer object.
	
	  @tiptext List of schema specified 
	  @helpid  1517
	  @xample
			// loop through the properties (fields) here
			for( var i in myDataSet.properties ) {
			  trace( "field '"+i+ "' has value "+ myDataSet.properties[i].getAsString());
			}
	*/
	public function get properties():Object {
		return( __toProperties );
	}
	
	/**
  	  Indicates if this collection is updatable. Setting this property to true will 
	  prevent updates to this collection.
	  
	  @tiptext Indicates if the collection can be modified
	  @helpid  1518
	  @example
		// don't allow updates to this collection
		myDataSet.readOnly = true;
		// the following code will throw an exception
		myDataSet.price = 15;
	*/
	[Inspectable(defaultValue="false")]
	public function get readOnly():Boolean {
		return( __readOnly );
	}
	
	public function set readOnly( value:Boolean ) {
		__readOnly = value;
	}
	
	/**
	  Schema in XML format for this DataSet. The schema can be setup using the 
	  author time UI or this property at runtime. The schema has the following XML format:

		<pre>
		&lt?xml version="1.0"?&gt;
		  &lt;properties&gt;
			  &lt;property name=&quot;data&quot;&gt;
				  &lt;type name=&quot;Boolean&quot; value=&quot;test&quot; label=&quot;test2&quot; uicontrol=&quot;it&quot;&gt;
					  &lt;encoder className=&quot;mx.data.encoders.Boolean&quot;&gt;
						  &lt;settings falseStrings=&quot;false,no,non,nyet,f,n,0,nope&quot; trueStrings=&quot;true,yes,oui,da,t,y,1,yup&quot;/&gt;
					  &lt;/encoder&gt;
					  &lt;formatter className=&quot;mx.data.formatters.NumberFormatter&quot;&gt;
						  &lt;settings precision=&quot;2&quot; /&gt;
					  &lt;/formatter&gt;
					  &lt;kind className=&quot;mx.data.kinds.ForeignKey&quot;&gt;
						  &lt;settings dataset=&quot;this&quot; indexColumn=&quot;test&quot; /&gt;
					  &lt;/kind&gt;
					  &lt;validation className=&quot;mx.data.types.Num&quot;&gt;
						  &lt;settings int=&quot;0&quot; /&gt;
					  &lt;/validation&gt;
				  &lt;/type&gt;
			  &lt;/property&gt;
			  &lt;proeprty&gt; ... &lt;/property&gt;
				  ...
		  &lt;/properties&gt; 
		</pre>
				
	  @tiptext Returns or assigns schema in XML format
	  @helpid  1519
	*/
	public function get schema():XML {
		return( __schemaXML );
	}

	public function set schema( sch:XML ) {
		// going to expect it to be in the correct format
		if( sch.firstChild.nodeName != "properties" )
			throw new DataSetError( "First node of schema XML must be 'properties'" );
		
		__schema = new Object();
		__schema.elements = new Array();
		// build new schema
		var propList:Array = sch.firstChild.childNodes;
		var prop:XMLNode;
		var propType:XMLNode;
		for( var i in propList ) {
			prop=propList[i];
			if( prop.nodeName == "property" ) 
				__schema.elements.push( getSchemaObject( prop ));
		}
		__schemaXML = sch;
		_invalidSchema = false;
		createProperties();
	}
	
	/**
	  Indicates the selected index of the current iterator within the DataSet. 
	  
	  @tiptext	contains the current transfer object's index within the DataSet
	  @helpid	1520
	*/
	[Bindable]
	[ChangeEvent("iteratorScrolled","modelChanged")]
	public function get selectedIndex():Number {
		/* debug code
		var indx:Number=_iterator.getItemIndex( __curItem );
		trace( "dataset.getSelectedIndex()="+indx );
		return( indx );
		//*/
		return( _iterator.getItemIndex( __curItem ));
	}
	
	public function set selectedIndex( index:Number ):Void {
		var old_indx:Number=_iterator.getItemIndex( __curItem );
		
		if(old_indx == index) return;

		var item:Object = _iterator.getItemAt( index );
		if( item != null ) {
			__curItem = item;
			_iterator.find( item );
			internalDispatchEvent( "iteratorScrolled" );
		}
	}
	
	// ----------- public methods ---------------------
	
	/**
	  Used to override the default event that the binding is listening for.
	  
	  @param 	aBinding Binding that is being associated with this component
	*/
	function addBinding( aBinding:Binding ):Void {
		var bInfo:Object = null;
		if( aBinding.source.component == this ) {
			bInfo= aBinding.source;
			if( bInfo.property == "dataProvider" ) {
				Object( aBinding ).queueForExecute(); // Object cast for access to private method.
				bInfo.event = "NoEvent";
				bInfo= null; // stop looking for other changes to make
			}
		}
		if( aBinding.dest.component == this ) 
			bInfo= aBinding.dest;
			
		if( bInfo != null ) {
			var propName:String = bInfo.property;
			if(( propName != "deltaPacket" ) && ( propName != "items" ))
				bInfo.event = new Array( "iteratorScrolled", "modelChanged" );
		}
		super_addBinding( aBinding );
	}
	
	/**
	  Adds the event listener specified to this DataSet.
	  
	  @param	name String containing the name of the event to listen for
	  @param	handler Object/Function to fire when dispatching the event
	  @tiptext 	Adds a listener for the specified event
	  @helpid  	3958
	*/
	function addEventListener( name:String, handler ):Void {
		_eventDispatcher.addEventListener( name, handler );
	}
	
	/**
	  Creates a new ascending or descending index for the default iterator (iterator) using 
	  the specified properties for a transfer object. The new index is automatically assigned 
	  to the default iterator after it is created and stored in the indexes collection for 
	  later retrieval. 
	  @param name String containing the name of the index
	  @param propList Array containing a list of all of the property names to index
	  @param [options] Number integer value indicating what options are used for this index. 
	         This value must be one of the following (multiple values can be or'ed together): 
				<li>DataSetIterator.Descending</li>
				<li>DataSetIterator.Unique</li>
				<li>DataSetIterator.CaseInsensitive</li>
	
	  tiptext 	Sorts the items in the collection
	  helpid	1522
	  @example
	
		 myDataSet.addSort( "id", ["name", "id"], DataSetIterator.Unique );
		 // find the transfer object identified by "Bobby" and 105
		 if( myDataSet.find( [ "Bobby", 105 ] ))
			bkmkTeachersPet = myDataSet.iterator.clone();
		 else
			bkmkTeachersPet = null;
		 if( myDataSet.find( [ "Joey", 299 ] ))
			bkmkClassClown = myDataSet.iterator.clone();
		 else
			bkmkClassClown = null;
		 //Now go back to the Teacher's Pet transfer object
		 if( bkmkTeachersPet != null )
			myDataSet.iterator = bkmkTeachersPet;
	
		 //Now dump the iterators since we don't need them
		 bkmkTeachersPet = null;
		 bkmkClassClown = null;
		 myDataSet.addSort( "rank", ["classRank"], DataSetIteratorIndex.Descending | DataSetIteratorIndex.Unique | DataSetIteratorIndex.CaseInsensitive );
		 myDataSet.removeSort( "id" );
	*/
	public function addSort( name:String, propList:Array, options:Number ):Void {
		if( hasSort( name )) 
			throw new DataSetError( "Sort '"+ name +"' specified is already added.  Error for dataset '"+ _name+ "'." );
		// build field list
		var fld: Object = null;
		for( var i=0; i<propList.length; i++ ) {
			fld = __toProperties[propList[i]];
			if( fld == null )  
				throw new DataSetError( "Property '"+ propList[i] +"' not found in schema for DataSet '"+ _name+ "' can't build index." );
			addSortInfo( getField( fld.name ), name, i );
		} // for
		var newIterator:ValueListIterator= new DataSetIterator( name, this, _iterators[ DefaultIterator ]);
		newIterator.setFilterFunc( _filterFunc );
		newIterator.setFiltered( _filtered );
		newIterator.sortOn( propList, options );
		// if there are errors in the recordset index an exception will be raised
		_iterators[ name ] = newIterator;
		_iterator = newIterator;
		__curItem = _iterator.next();
		internalDispatchEvent( "modelChanged", { eventName:"sort" });
	}

	/**
	  Adds the specified transfer object to the collection for management. The location of the item depends 
	  on whether an index has been specified or is in use for the default iterator. If no index is in use the 
	  item specified will be added to the start of the collection. 
	  
	  @param 	[transferObj] Object transfer object to manage within this DataSet collection
	  @return	Boolean indicating if the item was added.
	  @tiptext	Adds the specified item to the collection
	  @helpid  	1523
	  @example
				myDataSet.addItem( myDataSet.createItem()); 
	*/
	public function addItem( transferObj:Object ):Boolean {
		if(( arguments.length > 0 ) && ( transferObj == null ))
			return( false );
		else
			return( addItemAt( length, transferObj ));
	}
	
	/**
	  Adds the specified transfer object to the collection for 
	  management at the specified location.
	  
	  @param	index Number contaning the desired position within the collection
	  @param 	transferObj Object transfer object to manage within this DataSet collection
	  @tiptext	Adds the specified item to the collection
	  @helpid 	1524
	  @example
				myDataSet.addItemAt( 10, myDataSet.createItem()); 
	*/
	public function addItemAt( index:Number, transferObj:Object ):Boolean {
		checkReadOnly();
		var result:Boolean= true;
		// if an object isn't specified create a default one
		if( transferObj == undefined )
			transferObj = createItem( null );
		else {
			// do we have this item already?
			var id:String = transferObj[ItemId];
			result= (( id == undefined ) || ( _itemIndexById[id] == undefined ));
		}
		if( result ) {
			//trace( "DataSet.addItemAt("+index+","+mx.data.binding.ObjectDumper.toString( transferObj )+ ")" );
			// if no schema has been specified then default it based on the transfer object created	
			if( hasInvalidSchema())
				defaultSchema( transferObj );

			var evt:Object = internalDispatchEvent( "addItem", { item:transferObj, result:true });
			result = ( evt == null ) || evt.result;
			if( result && ( index <= length )) {
				var id:String = internalAddItem( transferObj, index, true, false ); // rebuild index but don't pipe data
				// log change to the delta packet
				if( __logChanges )
					logAddItem( transferObj, false ); // data hasn't been piped
				evt ={ eventName:"addItems", firstItem:index, lastItem:index };
				resyncIterators( evt );
				var itm:Object =_iterator.find({__ID__:id }); // try to find the added item
				// move to the new item only if we can find it, i.e. it is in the current range
				if( itm != null )
					__curItem = itm;
				internalDispatchEvent( "modelChanged", evt ); 
				if(( _enableEvents < 0 ) && ( _event != null )) 
					_event.data.lastItem = index; // update the amount of items added
			} // if event allows
		} // if not here already.
		return( result );
	}
	
	/**
	  Dispatches the "deltaPacketChanged" event.  The purpose of this method is to notify listeners
	  that they should pickup the latest delta packet from this DataSet.<br>
	  <i>NOTE: if events are disable via disableEvents() this method does nothing</i>
	  
	  @tiptext	Notifies listeners DeltaPacket is ready
	  @helpid 	1525
	*/
	public function applyUpdates():Void {
		// if there are delta items
		if( _hasDelta > 0 ) {
			var dpTransId:String =getDPTransId();
			var indx:Number = 0;
			// if this is the first request for a dp
			if( _dpTransIdCount == 0 ) 
				_lastTransId = dpTransId;
			else
				indx = _dpIndexByTransId[_lastTransId].index;
			// update the transaction id list
			_dpIndexByTransId[ dpTransId ] = { index:_deltaItems.length, prevId:_lastTransId, items:_optDeltaItems };
			_dpTransIdCount++;
			_deltaPacket = new DeltaPacketImpl( this, dpTransId, getKeyInfo(), true, _srcSchema );
			for( var i in _optDeltaItems ) {
				_deltaPacket.addItem( _optDeltaItems[i] );
			}
			_lastTransId = dpTransId;
			// reset the optimized items
			_optDeltaItems = new Array();
			_hasDelta = 0;
			internalDispatchEvent( "deltaPacketChanged" );
		} 
		else
			_deltaPacket = null; 
	}
	
	/**
	  Clears the transfer objects from this collection that are visible by the current iterator. If logChanges 
	  is true then this operation will create remove entries in the delta packet for each item within the 
	  collection that is removed. 
	  
	  @tiptext	Clears the current viewable items from the collection
	  @helpid	1526
	  @example
				// delete all the transfer objects within this collection
				myDataSet.logChanges= true;
				myDataSet.clear();
	*/
	public function clear():Void {
		var itms:Array = new Array();
		var delItems:Array = new Array();
		var itm:Object;
		var id:Number;
		var len:Number = _iterator.getLength();
		for( var i:Number=0; i<__items.length; i++ ) {
			itm=__items[i];
			id=itm[ItemId];
			// if the current iterator can see it delete it
			if( _iterator.contains( itm )) {
				if( __logChanges )
					logRemoveItem( itm, false ); 
				delItems.push( itm[ItemId] );
			}
			else 
				itms.push( itm );
		} // for
		__items = itms;
		rebuildItemIndexById();
		var evt:Object = { eventName:"removeItems", firstItem:0, lastItem:len, removedIDs:delItems };
		resyncIterators( evt );
		__curItem = getCurrentItem();
		delete evt[items]; // remove for the dispatch
		internalDispatchEvent( "modelChanged", evt );
	}
	
	/**
	  Creates a transfer object that is not associated with this collection. If there are listeners 
	  for the newItem event this method will defer creation of a transfer object to those listeners, 
	  otherwise this method will create a new instance of a transfer object based on the class name 
	  specified in the itemClass property. 
	  
	  @param 	itemData Object [optional] data associated with the transfer object
	  @return 	Object newly constructed transfer object
	  @tiptext	Returns a newly initialized item
	  @helpid	1527
	  @example
		 myDataSet.createItem( new XML( "&lt;customer&gt;..." ));		  
		  
	*/
	public function createItem( itemData:Object ):Object {
		checkSchema();
		var item:Object = null;
		// get the constructor
		if( _itemClass == null ) {
			if( __itemClassName.length > 0 ) {
				_itemClass = ClassFinder.findClass( __itemClassName );
				if( _itemClass == null )
					throw new DataSetError( "Item class '"+ __itemClassName+ "' specified not found. Error for DataSet '"+_name+ "'." );
			}
			else
				_itemClass = Function( Object );
		} // if
		
		// create the default property values if not specified
		{
			if(itemData == null)
				_propCage = new Object();
			else
				_propCage = itemData;

			_trapProperties = true;
			try {
				var val:String;
				for( var i in __toProperties ) {
					val=_defValues[i];
					if( val != null && _propCage[i] == null )
						getField( i ).setTypedValue( new TypedValue( val, "String" )); // pipes data
				}
				itemData = _propCage;
			}
			finally {
				_trapProperties= false;
			}
		}


		// if we defaulted to object
		if( _itemClass == Object ) 
			item = itemData;
		else 
			item = new _itemClass();

		item.setPropertyData( itemData ); // does nothing if anonymous or doesn't implement TransferObject 
		internalDispatchEvent( "newItem", { item:item });
		return( item );
	}
	
	/**
	  Disables events for the dataset. After this method has been called, no events will be dispatched. 
	  Events can be re-enabled by calling the enableEvents() method. This method may be called multiple 
	  times, and enableEvents() must be called an equal number of times to re-enable the dispatching of 
	  events. 
	
	  @tiptext	Stops listeners from receiving DataSet events
	  @helpid	1528
	  @example
		 
		 if( !myDataSet.readOnly) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.last();
			while( myDataSet.hasPrevious()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.previous();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function disableEvents():Void {
		_enableEvents--;
	}
	
	/**
	  Provides pass through for data binding's event mechanism which will call on the real
	  internalDispatch method.
	  
	  @param	eventObj Object event to dispatch.
	*/
	public function dispatchEvent( eventObj: Object ):Void {
		internalDispatchEvent( eventObj.type, eventObj );
	}
	
	/**
	  Enables events for the dataset after disableEvents() has been called. While events are disabled, 
	  no events will be fired and no controls will be updated when changes are made or the dataset is 
	  scrolled to another record. enableEvents() must be called an equal or greater number of times than 
	  disableEvents() was called to re-enable events for the dataset. 
	
	  @tiptext	Allows listeners to receive DataSet events
	  @helpid	1529
	  @example
	
		 if( !myDataSet.readOnly) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.last();
			while( myDataSet.hasPrevious()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.previous();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function enableEvents():Void {
		if( _enableEvents < 0 )
			_enableEvents++;
			
		if( _enableEvents == 0 ) { 
			internalDispatchEvent( _event.type, _event.data );
			_event = null;
		}
	}
	
	/**
	  This method will find a transfer object with the specified properties within the collection, 
	  assign its proxy to the DataSet and return true. If the item can not be found no change to the 
	  DataSet proxy will be made and the method will return false.
	  If the current index is not unique then the transfer object found is non deterministic. If it is 
	  important to find the first or last occurrance of a tranfer object in a non-unique index use the 
	  findFirst() or findLast().
	  The values specified must be in the same order as the fields of the current index field list. e.g. 
	  If fields 2, 4, and 5 are the fields in the current index, the values specified should be ordered 
	  such that the first value in the array will be compared against the first field in the index's 
	  fields list (field2) and so on. Conversion of the data specified will be performed based on the 
	  underlying field's type and that specified in the array. e.g. If the value specified is ["05-02-02"], 
	  the underlying date field will be used to convert the value using the date's setAsString() method. If 
	  the actual value specified was [new Date().getTime()], then the date's setAsNumber() method would 
	  be used. 
	
	  @param	values Array of one or more field values that should be found within the current index.
	  @return	Boolean true if found false if not
	  @tiptext	Locates the specified transfer object within the current iterator
	  @helpid	1530
	  @example
	
		 var bkmkTeachersPet:DataSetIterator = null;
		 var bkmkClassClown:DataSetIterator = null;
		 myDataSet.addSort( "id", ["name", "id"] );
		 // find the transfer object identified by "Bobby" and 105
		 if( myDataSet.findFirst( [ "Bobby", 105 ] ))
			bkmkTeachersPet = myDataSet.iterator.clone( "teachersPet" );
	
		 if( myDataSet.findFirst( [ "Joey", 299 ] ))
			bkmkClassClown = myDataSet.iterator.clone( "classClown" );
		 //Now go back to the Teacher's Pet transfer object
		 if( bkmkTeachersPet != null )
			myDataSet.iterator = bkmkTeachersPet;
	
		 //Now dump the iterators since we don't need them
		 bkmkTeachersPet = null;
		 bkmkClassClown = null;
		 myDataSet.addSort( "rank", ["classRank"], DataSetIteratorIndex.Descending | DataSetIteratorIndex.Unique | DataSetIteratorIndex.CaseInsensitive );
		 myDataSet.removeSort( "id" );
	*/
	public function find( values:Array ):Boolean {
		var oldItem = _iterator.find( convertToRaw( values, KeysOnly ));
		if( oldItem != null ) {
			__curItem = oldItem;
			internalDispatchEvent( "iteratorScrolled" );
		}
		return( oldItem != null );
	}

	/**
	  This method will find the first transfer object with the specified properties within the collection, 
	  assign its transfer object proxy to the DataSet and return true. If the transfer object can not be 
	  found no change will be made to the DataSet and false will be returned.
	  The values specified must be in the same order as the fields of the current index field list. e.g. 
	  If fields 2, 4, and 5 are the fields in the current index, the values specified should be ordered 
	  such that the first value in the array will be compared against the first field in the index's fields 
	  list (field2) and so on. Conversion of the data specified will be performed based on the underlying 
	  field's type and that specified in the array. e.g. If the value specified is ["05-02-02"], the 
	  underlying date field will be used to convert the value using the date's setAsString() method. If 
	  the actual value specified was [new Date().getTime()], then the date's setAsNumber() method would 
	  be used. 
	  
	  @param	values Array of one or more field values that should be found within the current index.
	  @return	Boolean true if found or false if not
	  @helpid	1531
	  @tiptext	Locates the first occurance of the specified transfer object within the current iterator
	  @example
	
		 var bkmkTeachersPet:DataSetIterator = null;
		 var bkmkClassClown:DataSetIterator = null;
		 myDataSet.addSort( "id", ["name", "id"] );
		 // find the transfer object identified by "Bobby" and 105
		 if( myDataSet.findFirst( [ "Bobby", 105 ] ))
			bkmkTeachersPet = myDataSet.getItemID();
	
		 if( myDataSet.findFirst( [ "Joey", 299 ] ))
			bkmkClassClown = myDataSet.iterator.clone();
		 //Now go back to the Teacher's Pet transfer object
		 if( bkmkTeachersPet != null )
			myDataSet.iterator = bkmkTeachersPet;
	
		 //Now dump the iterators since we don't need them
		 bkmkTeachersPet = null;
		 bkmkClassClown = null;
		 myDataSet.addSort( "rank", ["classRank"], DataSetIteratorIndex.Descending | DataSetIteratorIndex.Unique | DataSetIteratorIndex.CaseInsensitive );
		 myDataSet.removeSort( "id" );
	*/
	public function findFirst( values:Array ):Boolean {
		var oldItem = _iterator.findFirst( convertToRaw( values, KeysOnly ));
		if( oldItem != null ) {
			__curItem = oldItem;
			internalDispatchEvent( "iteratorScrolled" );
		}
		return( oldItem != null );
	}

	/**
	  This method will find the last transfer object with the specified properties within the collection, 
	  assign its transfer object proxy to the DataSet and return true. If the transfer object can not be 
	  found false will be returned and no change to the DataSet will be made.
	  The values specified must be in the same order as the fields of the current index field list. e.g. 
	  If fields 2, 4, and 5 are the fields in the current index, the values specified should be ordered 
	  such that the first value in the array will be compared against the first field in the index's 
	  fields list (field2) and so on. Conversion of the data specified will be performed based on the 
	  underlying field's type and that specified in the array. e.g. If the value specified is ["05-02-02"], 
	  the underlying date field will be used to convert the value using the date's setAsString() method. 
	  If the actual value specified was [new Date().getTime()], then the date's setAsNumber() method would 
	  be used. 
	  
	  @param	values Array of one or more field values that should be found within the current index.
	  @return	Boolean true if found or false if not
	  @helpid	1532
	  @tiptext	Locates the last occurance of the specified transfer object within the current iterator
	  @example
	
		 var bkmkTeachersPet:DataSetIterator = null;
		 var bkmkClassClown:DataSetIterator = null;
		 myDataSet.addSort( "id", ["name", "id"] );
		 // find the transfer object identified by "Bobby" and 105
		 if( myDataSet.findFirst( [ "Bobby", 105 ] ))
			bkmkTeachersPet = myDataSet.getIterator();
	
		 if( myDataSet.findFirst( [ "Joey", 299 ] ))
			bkmkClassClown = myDataSet.getIterator();
		 //Now go back to the Teacher's Pet transfer object
		 if( bkmkTeachersPet != null )
			myDataSet.iterator = bkmkTeachersPet;
	
		 //Now dump the iterators since we don't need them
		 bkmkTeachersPet = null;
		 bkmkClassClown = null;
		 myDataSet.addSort( "rank", ["classRank"], DataSetIteratorIndex.Descending | DataSetIteratorIndex.Unique | DataSetIteratorIndex.CaseInsensitive );
		 myDataSet.removeSort( "id" );
	*/
	public function findLast( values:Array ):Boolean {
		var oldItem = _iterator.findLast( convertToRaw( values, KeysOnly ));
		if( oldItem != null ) {
			__curItem = oldItem;
			internalDispatchEvent( "iteratorScrolled" );
		}
		return( oldItem != null );
	}
	
	/**
	  Positions the default iterator on the first transfer object in the collection and assigns 
	  its proxy to the DataSet. 
	  
	  @tiptext	Moves to the first item in collection
	  @helpid	1533
	  @example
	
		 if( !myDataSet.readOnly ) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.first();
			while( myDataSet.hasNext()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.next();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function first():Void {
		var item:Object =internalFirst();
		if( __curItem != item ) {
			__curItem = item;
			internalDispatchEvent( "iteratorScrolled" );
		}
	}

	/**
	  Returns the identifier of the current transfer object within the collection. 
	  @param	index Number [optional] specifing the index of the item we want the ID for,
	  			if not specified gets the id for the current item.
	  @return 	String unique identifier for this item within this collection
	  @tiptext	Returns the unique id for the specified item.
	  @helpid	1534
	  @example
	
			var itemNo:Number = myDataSet.getItemID();
			displayStatusBarMsg( "Employee id("+ itemNo+ ")");
	*/
	public function getItemId( index:Number ):String {
		var id:String = "";
		if( getLength() > 0 ) 
			id = index == undefined ? __curItem[ ItemId ]: _iterator.getItemId( index ); 
		return( id );
	}

	/**
	  Returns a new iterator (iterator) for this DataSet. The new iterator will be
	  a clone of the current iterator/iterator.
	  
	  @return	ValueListIterator clone of the current iterator
	  @helpid	1535
	  @tiptext	Returns a clone of the current iterator
	  @example
	  		
			myCursor:ValueListIterator = myDataSet.getIterator();
			while( myCursor.hasNext()) {
				myCursor.next();
				//..
			}
	*/
	public function getIterator():ValueListIterator {
		var id:String = internalGetId();
		var result:ValueListIterator = new DataSetIterator( id, this, DataSetIterator( _iterator ));
		result.first();
		_iterators[ id ] = result;
		return( result );
	}

	/**
	  Total number of transfer objects viewable within this collection based on the
	  current iterator.
	  
	  @tiptext Currently viewable length of items in collection
	  @helpid  1536
	  @example
		// alert the user if there are not enough entries made
		if( myDataSet.getLength() &lt; MIN_REQUIRED )
			alert( "Not enough entries have been made. You need at least "+MIN_REQUIRED );
	*/
	public function getLength():Number {
		//return( _iterator.getLength());
		return items.length;
	}
	
	/**
	  Indicates whether or not the default iterator is at the end of the collection. 

	  @return	Boolean true if the default iterator is at the end of the collection
	  @tiptext	Indicates if iterator is at the end of the collection
	  @helpid	1537
	  @example
	
		 if( !myDataSet.readOnly) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.first();
			while( myDataSet.hasNext()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.next();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function hasNext():Boolean {
		return(( _iterator.getLength() > 0 ) && ( _iterator.hasNext() || ( _iterator.getCurrentItem() != null )));
	}

	/**
	  Indicates whether or not the default iterator is at the beginning of the collection. 

	  @return	Boolean	true if the default iterator is at the beginning of the collection
	  @tiptext	Indciates if iterator at the begining of the collection
	  @helpid	1538
	  @example
	
			 if( !myDataSet.readOnly ) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.first();
			while( myDataSet.hasNext()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.next();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
		
	*/
	public function hasPrevious():Boolean {
		return(( _iterator.getLength() > 0 ) && ( _iterator.hasPrevious() || ( _iterator.getCurrentItem() != null )));
	}
	
	/**
	  Returns true if the specified sort name is already in use.
	  
	  @param	name String containing the sort name to check for
	  @return	Boolean indicating if the sort name specified exists
	  @helpid	1539
	  @tiptext	Indicates if the sort exists
	*/
	public function hasSort( name:String ):Boolean {
		return( _iterators[ name ] != undefined );
	}
	
 	/**
	  Indicates if the dataset is empty i.e. length == 0. 

	  @return 	Boolean indicating if the collection is empty i.e. length == 0
	  @tiptext	Indicates if there are items in the collection
	  @helpid	1540
	  @example
	 
	  on( afterRemove ) {
		if( event.target.isEmpty())
		  delete_btn.setEnabled( false );
	  }            
			  
	*/
	public function isEmpty():Boolean {
		return( length == 0 );
	}

	/**
	  Clears the specified delta item from the current list.  This method is for use with the reconcile updates
	  event and allows the developer to remove a pending change should that change need to be discarded.
	  
	  @param	id String containing the id of the delta to remove
	  @return	Boolean indicating if the specified item could be removed.
	  @tiptext	Removes the specified delta from the current list.
	*/
	public function clearDelta( id: String ):Boolean {
		return( removeDelta( _optDeltaItems[ id ] ));
	}
	
	/**
	  Indicates if any modifications to this collection or any transfer object within the 
	  collection has changes pending that have not been collected by an access to the
	  deltaPacket property. 
	  
	  @return	Boolean	true if the dataset is currently in edit or insert mode.
	  @tiptext	Indicates if there are items in the DeltaPacket
	  @helpid	1541
	  @example
	
		save_btn.setEnabled( myDataSet.changesPending());
		
	*/
	public function changesPending():Boolean {
		return( _hasDelta > 0 );
	}
	
	/**
	  Moves the current iterator to the transfer object specified by the id.
	  
	  @param	id String containing the id of the desired transfer object
	  @return	Boolean true if the transfer object specified was found
	  @tiptext	moves the current iterator to the item with the specified id
	  @helpid	1542
	  @example
	  		var bookmark:String = myDataSet.getItemId();
			myDataSet.findFirst([customerName.text]);
			myDataSet.customer = "Changed";
			// go back to where we were
			myDataSet.locateById( bookmark );
	*/
	public function locateById( id:String ):Boolean {
		var oldItem = _iterator.find({ __ID__:id });
		if( oldItem != null ) {
			__curItem = oldItem;
			internalDispatchEvent( "iteratorScrolled" );
		}
		return( oldItem != null );
	}
	
	/**
	  Positions the default iterator on the last transfer object in the collection 
	  and assigns it proxy to the DataSet. 
	 
	  @tiptext 	Moves to the last item in the collection
	  @helpid	1543
	  @xample
		 if( !myDataSet.readOnly ) {
			// Disable events so events are firing and slow everything down
			myDataSet.disableEvents();
			myDataSet.last();
			while( myDataSet.hasPrevious()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.previous();
			}
			// notify everyone
			myDataSet.enableEvents();
		 }
	*/
	public function last():Void {
		_iterator.last(); // moves to eof
		var item:Object =_iterator.previous(); // gets last item
		_iterator.next(); // go back
		if( __curItem != item ) {
			__curItem = item;
			internalDispatchEvent( "iteratorScrolled" );
		}
	}

	/**
	  Loads all of the relevant data needed to restore this DataSet collection 
	  from a shared object. This will allow users to work when disconnected from 
	  the source data, should it be a network resource. To save a DataSet to a 
	  shared object use saveToSharedObj(). This method will overwrite any data or 
	  pending changes that might exist within this DataSet. NOTE: This method will 
	  use the instance name of the dataset to identify the data within the 
	  specified shared object. 

	  @param	name String containing the name of the shared object to create and store 
	  			the data in. The name can include forward slashes ( / ); for example, 
				work/addresses is a legal name. The following characters (as well as a space) 
				are not allowed in a shared object name: ~ % & \ ; : " ' , < > ? # 
	  @param	localPath [optional] String	localPath An optional string parameter that 
	  			specifies the full or partial path to the SWF file that created the shared 
				object. This string is used to determine where the object will be stored on 
				the user's computer. The default value is the full path. 
	  @helpid	1544
	  @tiptext	Retrieves the internal state of the DataSet from a shared object
	  @exceptions
	    DataSetError If the shared object was not present or there was a problem retrieving 
		the data from it.
	  @example
	
				try {
				  myDataSet.loadFromSharedObj( "webapp/customerInfo" );
				}
				catch( e ) {
				  // ...
				}
				
	*/
	public function loadFromSharedObj( objName:String, localPath:String ):Void {
		var dsData:Object = SharedObject.getLocal( objName, localPath );
		if( dsData.data.items != undefined ) {
			items = dsData.data.items;
			// fix for player bug, since storage of data does not keep instance info i.e. becomes anonymous
			var dil:Array = dsData.data.optDelta;
			_optDeltaItems= new Array();
			var td:Object;
			for( var i in dil ) { 
				td=dil[i];
				_optDeltaItems[td._id]= createDelta( td );
			}
			// now build out the deltaItems array this is also a fix for the player bug
			dil=dsData.data.delta;
			_deltaItems = new Array();
			for( var i:Number=0; i<dil.length; i++ ) {
				td=dil[i];
				var d;
				if( _optDeltaItems[td._id] == undefined ) {
					d=createDelta( td );
				}
				else 
					d=_optDeltaItems[td._id];
				_deltaItems.push( d );
			}
			// need to reset the items array for this
			var dpIndex=dsData.data.dpIndex;
//			trace( mx.data.binding.ObjectDumper.toString( dpIndex ));
			var itms;
			for( var i in dpIndex ) {
				itms =dpIndex[i].items;
				for( var j in itms )
					itms[j]= findDelta( j );
			}
			_dpIndexByTransId = dpIndex;
//			trace( mx.data.binding.ObjectDumper.toString( _dpIndexByTransId ));
			_lastTransId = dsData.data.lastTransId;
			_dpTransIdCount= dsData.data.transIdCount;
			_hasDelta = dsData.data.hasDelta;
		}
		else {
			throw new DataSetError("The shared object '" +objName+ "' was not present or there was a problem retrieving the data from it.");	
		}
	}
	
	/**
	  Positions the default iterator on the next item in the collection and assigns its 
	  proxy to the DataSet. If the default iterator is at the end of the collection this 
	  method will return null. 
	 
	  @tiptext	Moves to the next item in the collection
	  @helpid	1545
	  @example
	
		 if( !myDataSet.readOnly ) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.first();
			while( myDataSet.hasNext()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.next();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function next():Void {
		var item:Object = _iterator.next();
		if( item != null ) {
			// if we didn't move try again.
			if( item == __curItem )
				item = _iterator.next();
			// if we didn't move past the end	
			if( item != null ) {
				__curItem = item;
				internalDispatchEvent( "iteratorScrolled" );
			}
		}
	}

	/**
	  Moves to the previous item in the collection and assigns its proxy to the DataSet. 
	  If the default iterator is at the begining of the collection then this method will do nothing. 
	 
	  @tiptext	Moves to the previous item in the collection
	  @helpid	1546
	  @example
		 if( !myDataSet.readOnly ) {
			//Disable events so the dataset won't try to refresh controls and
			//slow everything down
			myDataSet.disableEvents();
			myDataSet.last();
			while( myDataSet.hasPrevious()) {
			   var price = myDataSet.price;
			   price = price * 0.5; //Everythings 50% off!
			   myDataSet.price = price;
			   myDataSet.previous();
			}
			//Tell the dataset it's time to update the controls now
			myDataSet.enableEvents();
		 }
	*/
	public function previous():Void {
		var item:Object = _iterator.previous();
		if( item != null ) {
			// if we didn't move try again.
			if( item == __curItem )
				item = _iterator.previous();
				
			// if we didn't move past the end	
			if( item != null ) {
				__curItem = item;
				internalDispatchEvent( "iteratorScrolled" );
			}
		}
	}

	/**
	  Inidcates when a property has been modified on this DataSet via data binding.  This method
	  is used to gather schema information that is passed via this method for the items and dataProvider
	  properties.  This data can then be passed on to any components that care about it, using the 
	  DeltaPacket interface, e.g.
	  			var typeInfo:Object = dp.getSource().getItemSourceSchema();
				
	  @param	propName String containing the name of the property
	  @param	subProp Boolean indicating if the property modified was not the root property, but rather
	  			a property some level underneath
	  @param	typeInfo Object containing the schema of the source's property
	*/
	public function propertyModified( propName:String, subProp:Boolean, typeInfo:Object ):Void {
		if(( propName == "dataProvider" ) || ( propName == "items" )) 
			_srcSchema= typeInfo;
	}
	
	/**
	  This method will clear all of the items in the collection <i>regardless</i> of what the
	  default or current iterator's view of this collection is.  If logChanges is true each
	  item removed will be logged as such in the delta packet.
	  
	  @helpid	1547
	  @tiptext	Remove all items from the DataSet regardless of current iterator settings
	*/
	public function removeAll():Void {
		var len:Number=__items.length;
		var delItems:Array = new Array();

		for( var i:Number=0; i<len; i++ ) {
			var itm=__items[i];
			if( __logChanges )
				logRemoveItem( __items[i], false );
			delItems.push(itm[ItemId]);
		}
		__items = new Array();
		_itemIndexById = new Array();
		var evt:Object ={ eventName:"removeItems", firstItem:0, lastItem:len, removedIDs:delItems };
		resyncIterators( evt );
		internalDispatchEvent( "modelChanged", evt );
	}
	
	/**
	  Removes the event listener specified from this DataSet.
	  
	  @param	name String containing the name of the event to listen for
	  @param	handler Object/Function to fire when dispatching the event
	  @tiptext	Removes the specified event listener
	  @helpid	1548
	*/
	public function removeEventListener( name:String, handler ):Void {
		_eventDispatcher.removeEventListener( name, handler );
	}
	
	/**
	  Removes the specified transfer object from the collection. This operation will be logged to 
	  the delta packet if logChanges is true. If the specified transfer object does not exist this
	  method will do nothing.
	  
	  @param	item Object [optional] transfer object that is to be removed from this collection.
	  			if not specified this method will remove the current item.
	  @return	Boolean indicating if the item was removed from the collection
	  @tiptext	Removes the specified item
	  @helpid	1549
	  @example
				var emp:Employee = myManagementDataSet.currentItem();
				myManagementDataSet.removeItem();
				// give him a promotion
				myJanitorDataSet.addItem( emp );
	*/
	public function removeItem( item:Object ):Boolean {
		if(( arguments.length > 0 ) && ( item == null ))
			return( false );
		
		if( item == null ) 
			item= __curItem;
		var index:Number = _itemIndexById[ item[ ItemId ]];
		if( index != undefined )
			return( internalRemoveItem( item ));
		else
			return( false );
	}
	
	/**
	  Removes the transfer object from the collection at the specified index. This operation will be 
	  logged to the delta packet if logChanges is true. If the specified transfer object does not exist 
	  this method will do nothing.
	  
	  @param	index Number index of the item to remove
	  @return	Boolean indicating if the item was removed from the collection
	  @tiptext	Removes the item at the specified index
	  @helpid	1550
	  @example
				var emp:Employee = myManagementDataSet.currentItem();
				myManagementDataSet.removeItemAt( 5 );
				// give him a promotion
				myJanitorDataSet.addItem( emp );
	*/
	public function removeItemAt( index:Number ):Boolean {
		return( internalRemoveItem( _iterator.getItemAt( index )));
	}
	
	/**
	  Removes the current range settings for the default iterator. 
	  
	  @helpid	1551
	  @tiptext	Removes the current iterator range
	*/
	public function removeRange():Void {
		_iterator.removeRange();
		__curItem = internalFirst();
		internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
	}

	/**
	  Removes the specified sort from this DataSet if it exists and is not reserved. 
	  Any iterators using this index will go back to the default ordering. 
	  
	  @param 	name String	containing the name of the index to remove
	  @helpid	1552
	  @tiptext	Removes the specified sort from the DataSet
	  @exceptions
	    DataSetError if any index name specified is not found or can't be removed
		//!!@@ update the spec for this exception and example
			
	*/
	public function removeSort( name:String ):Void {
		if( _iterators[ name ] != undefined ){ 
			if( name != DefaultIterator ) {
				if( _iterator.getId() == name ) {
					setIterator( _iterators[ DefaultIterator ]);
				} // if the current index is being removed
				// remove sort info from associated fields
				var sortInfo= _iterators[name].getSortInfo();
				for( var i:Number=0; i<sortInfo.keyList.length; i++ )
					removeSortInfo( getField( sortInfo.keyList[i]), name );
				delete _iterators[ name ]; 
			}
			else 
				throw new DataSetError( "The default index can not be removed.  Error on DataSet '"+ _name+ "'." );
		}
		else 
			throw new DataSetError( "Sort '"+ name+ "' specified does not exist.  Error on DataSet '"+ _name+ "'." );
	}

	/**
	  Moves the default iterator by the amount indicated by offset and assigns the 
	  transfer object proxy at that location to the DataSet. If offset is negative 
	  the iterator is moved to a previous item in the collection, if positive it is 
	  moved forward. If the offset would move the iterator beyond the begnining or end 
	  of the collection, the iterator will instead be positioned at the beginning or 
	  end of the collection. 
	  @param	offset Number integer containing the number of records to move 
	  			the iterator position by e.g. -1 move backward one record; 2 move 
				forward two records
	  @tiptext	Moves the iterator the amount specified
	  @helpid	1553
	  @example
	
		  myDataSet.first();
		  //Move to the item just before the last one
		  var itemsToSkip = myDataSet.length - 2;
		  myDataSet.skip( itemsToSkip ).price = myDataSet.amount * 10;
		  
	*/
	public function skip( offset:Number ):Object {
		var item:Object = _iterator.skip( offset );
		// did we fall of the end?
		if( item == null ) {
			if( offset > 0 )
				item = _iterator.previous();
			else
				item = _iterator.next();
		}
		if( __curItem != item ) {
			__curItem = item;
			internalDispatchEvent( "iteratorScrolled" );
		}
		return( this );
	}

	/**
	  Saves all of the relevant data needed to restore this DataSet collection from a 
	  shared object. This will allow users to work when disconnected from the source 
	  data, should it be a network resource. To restore a DataSet from a shared object 
	  use loadFromSharedObj(). This method will overwrite any data that might exist 
	  within the specified shared object for this DataSet. NOTE: This method will use 
	  the instance name of the dataset to identify the data within the specified shared 
	  object. 
	  @param	Name String containing name of the shared object to create and store 
	  			the data in. The name can include forward slashes ( / ); for 
				example, work/addresses is a legal name. The following characters 
				(as well as a space) are not allowed in a shared object 
				name: ~ % & \ ; : " ' , < > ? # 
				
	  @param	localPath [optional] String	localPath An optional string parameter 
	  			that specifies the full or partial path to the SWF file that created 
				the shared object. This string is used to determine where the object 
				will be stored on the user's computer. The default value is the full path. 
	  @helpid	1554
	  @tiptext	Saves the internal state of the DataSet to a shared object
	  @exceptions
				DataSetError If the shared object was not created or there was a problem flushing the data to it.
	  @example
	
				try {
				  myDataSet.saveToSharedObj( "webapp/customerInfo" );
				}
				catch( e ) {
				  // ...
				}
	*/
	public function saveToSharedObj( objName:String, localPath:String ):Void {
		var dsData:Object = SharedObject.getLocal( objName, localPath );
		if( dsData == null )
			throw new DataSetError( "Couldn't access specified shared object. Error for DataSet '"+_name+"'." );
		dsData.data.items= __items;
		dsData.data.optDelta= _optDeltaItems;
		dsData.data.delta= _deltaItems;
		dsData.data.dpIndex= _dpIndexByTransId;
		dsData.data.lastTransId= _lastTransId;
		dsData.data.transIdCount= _dpTransIdCount;
		dsData.data.hasDelta= _hasDelta;
		if( dsData.flush() == false )
			throw new DataSetError( "Couldn't save shared object not sufficient space or rights. Error for DataSet '"+_name+"'." );
	}
	
	/**
	  Assigns the DataSet's current iterator to the specified value.
	  
	  @param	newIterator ValueListIterator new iterator for the DataSet to use as its 
	  			current iterator.
	  @helpid	1555
	  @tiptext	Sets the current iterator of the DataSet to that specified 
	*/
	public function setIterator( newIterator:ValueListIterator ):Void {
		// check that the iterator specified is one from this DataSet
		if( _iterators[ newIterator.getId() ] == undefined )
			throw new DataSetError( "Can't assign foreign iterator '"+newIterator.getId()+ "' to DataSet '"+_name+"'." );
		_iterator = newIterator;
		__curItem = getCurrentItem();
		internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
	}
	
	/**
	  Sets the end points for the default iterator. This is only valid if a valid index 
	  has been set for the default iterator. Setting end points for the iterator defines 
	  a range for the iterator to operate within. Setting iterator end points is more 
	  efficient than using a filter if a grouping of values is desired. 

	  @param	startValues	Array of key values that represent the properties of the 
	  			first transfer object in the range
	  @param	endValues Array of key values that represent the properties of the 
	  			last transfer object in the range
	  @helpid	1556
	  @tiptext	Sets the current iterator range
	*/
	public function setRange( startValues:Array, endValues:Array ):Void {
		_iterator.setRange( convertToRaw( startValues, KeysOnly ), convertToRaw( endValues, KeysOnly ));
		__curItem = internalFirst();
		internalDispatchEvent( "modelChanged", { eventName:"filterModel" });
	}

	/**
	  Switches the index for the default iterator to the one specified, should it exist. 

	  @param	sortName Stirng containing the sort to use
	  @param	[options] Number integer value indicating what sort options to use
	  @tiptext	Uses the sort specified
	  @helpid	1557
	  @exceptions
	    DataSetError If the specified sort does not exist
	*/
	public function useSort( sortName:String, options:Number ):Void {
		if( !hasSort( sortName ))
			throw new DataSetError( "Sort specified '"+sortName+ "' does'nt exist for DataSet '"+_name+"'." );
		var itr:ValueListIterator =_iterators[ sortName ];
		if( options != undefined )
			itr.setSortOptions( options );
		itr.setFiltered( _filtered );
		itr.setFilterFunc( _filterFunc );
		_iterator = itr;
		first();
		internalDispatchEvent( "modelChanged", { eventName:"sort" });
	}
	
	// ------ mixing methods -------------------
	var getField:Function; // comes from mx.data.binding.ComponentMixins
	var refreshFromSources: Function; // comes from mx.data.binding.ComponentMixins
    // ------ static members -------------------
	private static var DefaultIterator:String = "__default__";
	private static var ItemId:String = "__ID__";
	private static var KeysOnly:Number = 0;
	private static var All:Number = 1;
	// ------ private members ------------------
	private var _fldValObj:Object;
	private var _defValues:Object;
	private var _loading:Boolean;
	private var _srcSchema:Object;
	private var _allowReslv:Boolean = false; // indicates to the __resolve that it should ignore requests
	private var _eventDispatcher:Object;
	private var _itemIndexById:Array; // hash by item id
	private var _enableEvents:Number;
	private var _event:Object;
	private var _filtered:Boolean;
	private var _filterFunc:Function;
	private var _optDeltaItems:Array; // optimized delta packet information
	private var _deltaItems:Array; // all delta items
	private var _deltaPacket:DeltaPacket;
	private var _dpIndexByTransId:Array; // list of all delta packets asked for
	private var _lastTransId:String; // index into delta items array to the item last included in a packet request
	private var _dpTransIdCount:Number;
	private var _itemClass:Function;
	private var _hasDelta:Number;
	private var _iterators:Array;
	private var _invalidSchema:Boolean;
	private var _propCage:Object;
	private var _trapProperties:Boolean;
	private var _calcFields:Object;
	private var __itemClassName:String;
	private var _iterator:ValueListIterator;
	private var __schemaXML:XML;
	private var __items:Array;
	private var __toProperties:Object;
	private var __readOnly:Boolean;
	private var __curItem:Object;
	private var __logChanges:Boolean;
	private var __schema:Object; // added by the author time UI
	private var super_addBinding:Function;
	// we must include the DateToNumber encoder otherwise it no workie unless specified by the user
	private var f:mx.data.encoders.DateToNumber;
	
	

	
	/**
	  Adds the proxy information to this DataSet allowing for mutations to be tracked 
	  on the transfer objects stored within its collection.
	  
	*/
	private function addProxy():Void {
		var propName:String;
		for( var i in __toProperties )  {
			propName= String( i );
			addProperty( propName, this[ "get_"+propName ], this[ "set_"+propName ]);
		}
	}
	
	/**
	  Hangs some sort information off of the field so that it can be used later to determine if an
	  iterator should be recalculated if this field is changed.
	  
	  @param	fld DataType field to add information to
	  @param	name String containing the name of the associated iterator
	  @param	index Number indicating the position within the iterator sort specification, 0 being 
	  			the primary position.
	*/
	private function addSortInfo( fld:DataType, name:String, index:Number ):Void {
		if( fld.sortInfo == null )
			fld.sortInfo = new Array();
		fld.sortInfo[ name ] = index;
	}
	
	/**
	  Collects messages from the delta specified, applies updates to existing items if there are no messages
	  and updates the current deltapacket based on the current operation.  For example
		   - Add and remove operations with errors will be added to the optimized delta packet, so they can 
		     be resent to the server.
		   - Modifications to existing items with errors can be ignored since these will result in new mods
		   - Updates existing items that do not have errors, in the case where key values have been updated
		     from the server.
	  
	  
	  @param	d Delta item within the packet that is currently being resolved
	  @param	resPckt Array of message objects
	  @param	transId String associated transaction id
	*/
	private function applyResolvePacket( d:Delta, resPckt:Array, dpItems:Array ):Void {
		var len:Number = resPckt.length;
		if( d.getMessage().length > 0 ) {
			resPckt.push( Object( d ));
		}
		else {
			var cl:Array = d.getChangeList();
			var cont:Boolean = true;
			var i:Number;
			for( i=0; ( i<cl.length ) && cont; i++ ) 
				cont = cl[i].message.length == 0;
			if( i < cl.length )
				resPckt.push( Object( d ));
		}
		// resolve the delta
		var hadMessage:Boolean = len != resPckt.length;
		// clear from the current item list
		switch( d.getOperation()) {
			case DeltaPacketConsts.Added:
				if( hadMessage ) 
					logAddItem( d.getSource(), true, d.getId()); // item has been piped
				else
					updateItem( d );
			break;
			
			case DeltaPacketConsts.Removed:
				if( hadMessage ) 
					logRemoveItem( d.getSource(), true, d.getId());
			break;
			
			case DeltaPacketConsts.Modified:
				if( !hadMessage ) 
					updateItem( d );
				else {
					var di:Delta = dpItems[ d.getId() ];
					_optDeltaItems[ d.getId() ] = di;
					_deltaItems.push( Object( di ));
					_hasDelta++;
				}
			break;
		} // switch
	}
	
	/**
	  Creates the XML schema representation of the author-time schema information.
	*/
	private function buildSchema():Void {
		if( hasInvalidSchema()) 
			__schemaXML = new XML( "<properties/>" );
		else {
			// build XML from type info
			var els:Object =__schema.elements;
			var el:Object;
			var schXML:String ="<properties>";
			for( var i:Number=0; i<els.length; i++ ) {
				el=els[i];
				if( isValidElement( el )) {
					// is this a date? does it have an encoder? if not add the standard one
					if(( el.type.name == "Date" ) && ( el.type.encoder == undefined )) { 
						el.type.encoder = { className:"mx.data.encoders.DateToNumber" };
					}
					schXML += "<property name=\""+ el.name +"\">" + getSchemaXML( "type", el.type )+ "</property>";
				}
			} // for each element
			schXML += "</properties>";
			__schemaXML = new XML( schXML );
		}
	}
	
	/**
	  Creates and returns a new delta instance from the anonymous object specified.
	  
	  @param	td Object containing the relevant properties for construction of a new Delta
	  @return	new delta instance
	*/
	private function createDelta( td:Object ):Delta {
		var d:Delta;
		var di:Object;
		var dii:Object;
		d=new DeltaImpl( td._id, td._source, td._op, td._message, td._accessCl );
		// add the delta items back in
		for( var j:Number=0;j<td._deltaItems.length; j++ ) {
			di=td._deltaItems[j];
			if( di.__kind == DeltaItem.Property )
				dii = { newValue:di.__newValue, oldValue:di.__oldValue, curValue:di.__curValue, message:di.__message };
			else
				dii = { argList:di.__argList };
			var t = new DeltaItem( di.__kind, di.__name, dii, Object( d ));
		} // for j
		return( d );
	}

	/**
	  Throws an exception if the DataSet is read-only.
	  
	*/
	private function checkReadOnly():Void {
		if( __readOnly )
			throw new DataSetError( "Can't modify a read only DataSet.  Error for '"+Object( this )._name +"'." );
	}
	
	/**
	  Throws an exception if the DataSet has not had any schema defined.
	*/
	private function checkSchema():Void {
		if( hasInvalidSchema())
			throw new DataSetError( "Schema has not been specified. Can't construct item. Error for DataSet '"+_name+ "'." );
	}
	
	/**
	  Creates the transfer object properties list exposed by the specified schema information currently found
	  in the __schema property.  If bindings currently exist this method should try to map the new properties to
	  any existing bindings that will support them.
	*/
	private function createProperties():Void {
		removeProxy();
		_allowReslv= true;
		_calcFields.__length__ = 0;
		__toProperties = new Object();
		var el:Object;
		for( var i:Number=0; i<__schema.elements.length; i++ ) {
			el=__schema.elements[i];
			if( isValidElement( el )) {
				__toProperties[el.name]= el;
				// if we have a default value move it to our default value list
				if( el.type.value != null ) {
					_defValues[el.name]= el.type.value;
					el.type.value = null;
				}
				if( getField( el.name ).kind.isCalculated ) {
					_calcFields[el.name]=el;
					_calcFields.__length__++;
				}
			}
		} // for
		addProxy();
		_allowReslv= ( __items.length > 0 );
	}
	
	/**
	  Converts the specified values into their raw representation, i.e. values that can be
	  compared against property values on transfer objects within this collection.
	  
	  @param	values Object/Array of values to use for conversion
	  @param	option Number indicating what to convert, valid values are KeysOnly and All 
	  @return	Object of the specified values converted
	*/
	private function convertToRaw( values:Object, option:Number ):Object {
		if( values instanceof Array ) {
			return( convertArrayToRaw( values )); // always KeysOnly
		}
		else {
			return( convertObjectToRaw( values, option ));
		}
	}
	
	/**
	  Converts the specified values into their raw representation, i.e. values that can be
	  compared against property values on transfer objects within this collection.
	  
	  @param	values Array of values to use for conversion
	  @param	option Number indicating what to convert, valid values are KeysOnly and All 
	  @return	Object of the specified values converted
	*/
	private function convertArrayToRaw( values ):Object {
		_trapProperties = true;
		_propCage= new Object();
		try {
			var sortInfo:Object = _iterator.getSortInfo();
			var fld:DataType;
			var typeInfo:Object;
			var value;
			for( var i:Number=0; i<sortInfo.keyList.length; i++ ) {
				if( i<values.length ) {
					fld = getField( sortInfo.keyList[i] ); // get field
					typeInfo = __toProperties[ sortInfo.keyList[i]].type;
					value=values[i];
					switch( typeof( value )) {
						case "string":
							fld.setAsString( value );
						break;
						
						case "boolean":
							fld.setAsBoolean( value );
						break;
						
						case "number":
							fld.setAsNumber( value );
						break;
						
						case "object":
							fld.setTypedValue( new TypedValue( value, typeInfo.name, typeInfo ));
						break;
					} // switch
				} // make sure we are within the values array length
			} // loop through all of the key fields in the current index
		}
		finally {
			_trapProperties = false;
		}
		return( _propCage );
	}
	
	/**
	  Converts the specified values into their raw representation, i.e. values that can be
	  compared against property values on transfer objects within this collection.
	  
	  @param	values Object of values to use for conversion
	  @param	option Number indicating what to convert, valid values are KeysOnly and All 
	  @return	Object of the specified values converted
	*/
	private function convertObjectToRaw( values, option:Number ):Object {
		_trapProperties = true;
		_propCage= new Object();
		try {
			//trace( "DataSet.convertObjectToRaw()"+option );			
			var sortInfo:Object = _iterator.getSortInfo();
			var propName:String;
			if( option == KeysOnly ) {
				for( var i=0; i<sortInfo.keyList.length; i++ ) {
					propName= sortInfo.keyList[i];
					setFieldValue( getField( propName ), values[propName], __toProperties[ sortInfo.keyList[i]].type );
				} // loop through all of the key fields in the current index
			}
			else {
				// All
				for( var i in __toProperties )
					setFieldValue( getField( i ), values[i], __toProperties[i].type );
			}
		}
		finally {
			_trapProperties = false;
		}
		return( _propCage );
	}

	/**
	  Returns an anonymous object that has the properties of dataset schema
	  as run through the data binding pipeline.
	  
	  @param	item Object containing the properties that need to be piped
	  @return	Object containing the properties on the DataSet 
	*/
	private function decodeItem( item:Object ):Object {
		var result:Object = new Object();
		var oldItem = __curItem;
		__curItem = item;
		try {
			for( var i in __toProperties ) {
				var temp =getField( i ).getTypedValue().value; 
				if(temp)
					result[i] = temp;
				else
					result[i] = item[i];
			}
		}
		finally {
			__curItem = oldItem;
		}
		return( result );
	}
	
	/**
	  Attempts to create schema for this DataSet by introspection of the specified 
	  object's properties.
	  
	  @param	obj Object to derive the schema from
	  @author	Jason Williams
	*/
	private function defaultSchema( obj:Object ):Void {
		var typ:String;
		var clsName:String;
		var props:String = "";
		for( var i in obj ) {
			typ=typeof( obj[i] );
			if( typ != "function" ) {
				typ = String( typ.charAt(0)).toUpperCase() + typ.substring( 1, typ.length );
				if( typ == "Boolean" )
					clsName= "Bool";
				else 
					clsName = typ.substring( 0, 3 );
				props = "<property name=\""+ i +"\"><type name=\""+ typ + "\" original=\"false\"><validation className=\"mx.data.types."+ clsName+"\"/></type></property>" + props; // reverse order
			}
		}
		schema = new XML( "<properties>"+props+"</properties>" );
	}
	
	/**
	  Decodes the specified value using the current schema and returns the decoded value
	  
	  @param	fieldName String containing the name of the property on the DataSet that has the
	  			appropriate pipeline for decoding the value specified
	  @param	value new value to decode
	  @return	newly decoded value
	*/
	private function decodeValue( fieldName:String, value ) {
		if(!__toProperties || !__toProperties[fieldName] ) return null;
		var typeInfo:Object = __toProperties[ fieldName ].type;
		var t:TypedValue = new TypedValue( value, typeInfo.name, typeInfo );
		if(t != null)	return t.value;
		else	return t;

/* r
		_fldValObj.__schema = __schema;
		_fldValObj[fieldName]= value;
		return( _fldValObj.getField( fieldName ).getTypedValue().value );
*/
	}
	
	/**
	  Encodes the specified value using the current schema and returns the decoded value
	  
	  @param	fieldName String containing the name of the property on the DataSet that has the
	  			appropriate pipeline for decoding the value specified
	  @param	value new value to encode
	  @return	newly Encoded value
	*/
	private function encodeValue( fieldName:String, value ) {
		if(!__toProperties || !__toProperties[fieldName] ) return null;
		var typeInfo:Object = __toProperties[ fieldName ].type;
		var t:TypedValue = new TypedValue( value, typeInfo.name, typeInfo );
		if(t) return t.value;
		return null;
/* r
		var typeInfo:Object = __toProperties[ fieldName ].type;
		_fldValObj.__schema = __schema;
		_fldValObj.getField( fieldName ).setTypedValue( new TypedValue( value, typeInfo.name, typeInfo ));
		return( _fldValObj[fieldName] );
*/

		
	}
	
	private function findDelta( id:String ):Delta {
		for( var i:Number=0; i<_deltaItems.length; i++ )
			if( _deltaItems[i]._id == id )
				return( _deltaItems[i] );
		return( null );
	}
	
	/**
	  Creates the specified event and dispatches it with the additional parameters specified attached 
	  to the event as properties.  If events have been disabled via disableEvent() this method will
	  return null, otherwise it will return the event <i>after</i> it has been dispatched.
	  
	  @param	type String containing the event type
	  @param	params Object containing the additional properties to attach to the event
	  @return	Object event as dispatched or null if not dispatched.
	*/
	private function internalDispatchEvent( type:String, params:Object ):Object {
		//trace( "DataSet.internalDispatchEvent("+type+","+mx.data.binding.ObjectDumper.toString( params )+ ")");		
		var result:Object= null;
		if( _enableEvents >= 0 ) {
			result= { type:type, target:this };
			if( params != undefined )
				for( var i in params )
					result[i] = params[i];
			_eventDispatcher.dispatchEvent( result ); 
		}
		else {
			if(( _event != null ) && ( _event.type == "modelChanged" )) {
				// sort and filter take precedence over any other operation
				if( type == "modelChanged" )
					if(( _event.data.eventName != "sort" ) && ( _event.data.eventName != "filter" ))
						_event.data = params;
			}
			else
				_event = { data:params, type:type }; // store off the event for later
		}
		return( result );
	}
	
	/**
	  Returns a new object instance that represents the specified item as it is to be viewed
	  by the outside world.
	  
	  @param	item Object current transfer object
	  @param	desiredTypes Object of strings specifying what type is required for a column
	  @return	Object containing the properties as they should appear to the outside world.	
	*/
	private function getDataProviderItem( item:Object, desiredTypes:Object ):Object {
		var result:Object = new Object();
		var fld:DataType;
		var oldItem= __curItem;
		var desType:String;
		var val;
		try {
			__curItem = item;
			for( var i in __toProperties ) {
				desType = desiredTypes[i];
				// if we didn't find the specification default to string
				if( desType == null )
					desType = "String";
				fld= getField( i );
				if(fld)
				{
					val=fld.getTypedValue( desType );
					if( val == null )
						val=fld.getTypedValue();
					result[i]=val.value;
				}
				else
					result[i] = item[i];
			} // for
		}
		finally {
			__curItem= oldItem;
		}
		return( result );
	}
	
	/**
	  Returns the editing data for the specified field, item, and desired types information.
	  
	  @param	fieldName String containing the field to extract the editing data for
	  @param	item Object transfer object to get the field data from
	  @param	desireTypes Object containing the desired types of editing data
	  @return	the editing data value
	*/
	private function getEditingData( fieldName:String, item:Object, desiredTypes:Object ) {
		var result;
		var oldItem= __curItem;
		var desType:String;
		try {
			__curItem = item;
			desType = desiredTypes[fieldName];
			// if we didn't find the specification default to string
			if( desType == null )
				desType = "String";
			var fld= getField( fieldName );
			var val=fld.getTypedValue( desType );
			if( val == null )
				val=fld.getTypedValue();
				
			result=val.value;
		}
		finally {
			__curItem= oldItem;
		}
		return( result );
	}
	
	
	/**
	  Returns the display value of the specified field at the given index.  This method
	  is used by the Data Provider API.
	  
	  @param	propName String containing the name of the property to access
	  @param	index Number index of the desired transfer object
	  @return	String containing the formatted display value
	*/
	private function getDisplayValue( propName:String, index:Number ):String {
		var oldItem= __curItem;
		var result:String = "";
		try {
			__curItem = __items[ index ];
			result = getField( propName ).getAsString();
		} 
		finally {
			__curItem = oldItem;
		}
		return( result );
	}
	
	/**
	  This method will resync the iterator to a point of getting an item from it
	  
	  @returns	Object transfer object potentially null, however all attempts are 
	  			made to avoid this.
	*/
	private function getCurrentItem():Object {
		var result:Object = _iterator.getCurrentItem();
		if( result == null ) {
			// are we at bof
			if( _iterator.hasNext()) {
				result = _iterator.next();
				_iterator.previous();
			}
			else {
				result = _iterator.previous();
				_iterator.next();
			}
		}
		return( result );
	}
	
	/**
	  Returns a re-mapped index number based on the current index that points to the
	  actual transfer object index within this dataset.
	  
	  @param	index Number externally visible index to be re-mapped into the current index
	  @return	Number containing the index within the DataSet's collection
	*/
	private function getInternalIndex( index:Number ):Number {
		var item:Object =_iterator.getItemAt( index );
		if( item == null )
			return( -1 );
		return( _itemIndexById[item[ ItemId ]]);
	}
	
	/**
	  This method returns the key information for a delta packet.  This method will be called to
	  provide appropriate key information for the items contained within the delta packet being
	  created. It will attempt to find a unique sorting, if an iterator with a unique sort is not found
	  it will use all properties as keys in the hopes that they will provide a unique way of identifing an item.
	  
	  @return	Object containing the keylist and options.
	*/
	private function getKeyInfo():Object {
		// search for an iterator with a unique sort
		var itr:DataSetIterator;
		var sortInfo:Object;
		for( var i in _iterators ) {
			itr = _iterators[i];
			sortInfo = itr.getSortInfo();
			if(( i != DefaultIterator ) && (( sortInfo.options & DataSetIterator.Unique ) == DataSetIterator.Unique )) 
				return({ options:sortInfo.options, keyList:sortInfo.keyList.slice(0)});
		}
		// use all properties
		var allProps:Array = new Array();
		for( var i in __toProperties )
			allProps.push( i );
		return({ options:DataSetIterator.Unique, keyList:allProps });
	}
	
	/**
	  Looks for an existing delta with the specified id, or creates one, adds it and
	  returns the delta along with the cloned source should one have been created.
	  
	  @param	id String containing the id of the transfer object
	  @return	Delta requested
	*/
	private function getModDeltaInfo( id:String ):Delta {
		var src:Object=null;
		var cpy:Object=null;
		var d:DeltaImpl =_optDeltaItems[ id ];
		// do we need to make a copy of the source to preserve it?
		if( d == undefined ) {
			src =__curItem;
			// if clone() isnt supported then do generic copy
			if( src.clone == undefined ) {
				var propData:Object = src.getPropertyData();
				if( propData != null )
					cpy= createItem( propData );
				else
					cpy = new Object();
					
			}
			else
				cpy = src.clone();
				
			// pipe the data properly
			var prop:Object;
			var el:Object;
			for( var i in src ) {
				prop= src[i];
				if( typeof( prop ) != "function" ) {
					// if the value being copied is defined in the schema then we need to pipe it
					// so that as it goes into the delta packet it has the desired "external" view
					el=__toProperties[i];
					cpy[i] = el == undefined ? prop : getField(i).getTypedValue( /*el.type.name*/ ).value;
				}
			}  // for
			
			d = new DeltaImpl( id, cpy, DeltaPacketConsts.Modified );
			_optDeltaItems[ id ]= d;
			_hasDelta++;
			_deltaItems.push( d );
		} // if d==undefined
		return( d );
	}
	
	/**
	  Returns the current value of the specified property.
	  
	  @param	name String containing the name of the desired property
	  @return	Value of the property specified.
	*/
	private function getPropertyValue( name:String ):Object {
		return( __curItem[name] );
	}
	
	/**
	  Returns a list of fields/properites of this DataSet that can be sent to the server, i.e.
	  it excludes fields that are calculated or virtual.
	  
	  @return	Object containing properties with the field information.
	*/
	private function getResolverFieldList():Object {
		var result:Object = new Object();
		for( var i in __toProperties )
			if(( _calcFields[i] == null ) && ( __toProperties[i].type.path == null ))
				result[i] = __toProperties[i];
		return( result );
	}
	
	/**
	  Reutrn's an application wide unique delta packet transaction identifier.  
	  This id is used with DeltaPackets to determine if a packet is a server 
	  response and change the handling accordingly.
	  
	  @return	String containing a unique id which includes the date and time and
	  			has the following format 47126228642:Thu Jun 19 23:43:25 GMT-0700 2003
	*/
	private function getDPTransId():String {
		return( internalGetId()+ ":"+ (new Date()).toString()); //!!@@ allow for user defined formatting of date
	}
	
	/**
	  Returns an object that represents the XML node specified.  Each node in the XML is converted to
	  an object with properties, where the value of the property is either the attribute value or an
	  object which represnts a sub node in the XML tree.
	  
	  @param	xmlInfo XMLNode containing the XML data to convert to an object
	  @return	Object representing the given XML data.
	*/
	private function getSchemaObject( xmlInfo:XMLNode ):Object {
		var result:Object = new Object();
		// collect attributes first
		var value:String;
		for( var i in xmlInfo.attributes )  {
			value = xmlInfo.attributes[i];
			if( i == "original" ) 
				result[i] = value == "false" ? false: true;
			else
				result[i] = value;
		}
		// collect sub nodes
		var cn:Array = xmlInfo.childNodes;
		var nd:XMLNode;
		for( var i:Number=0; i<cn.length; i++ )
			result[ cn[i].nodeName ]=getSchemaObject( cn[i] );
		return( result );
	}
	
	/**
	  Used to create XML string based on the nested object structure passed in.  Scalar properties on objects become
	  attributes and objects become sub nodes.
	  
	  @param	nodeName String containing the name of the node
	  @param	info Object sub object to explode into XML
	  @return	String containing an XML representation of the specified object structure.
	*/
	private function getSchemaXML( nodeName:String, info:Object ):String {
		var attrs:String ="";
		var item;
		// collect all attributes except "cls" first
		for( var i in info ) {
			item= info[i];
			if(( typeof( item ) != "object" ) && ( i != "cls" ))
				attrs += " "+i+"=\""+ item+ "\"";
		}
		var result:String= "<"+ nodeName+ attrs+ ">";
		// collect sub elements
		for( var i in info ) {
			item =info[i];
			if( typeof( item ) == "object" )
				result += getSchemaXML( i, item );
		}
		result += "</"+nodeName+">";
		return( result );
	}
	
	/**
	  Returns true if no custom schema has been specified for this DataSet.
	  
	  @return	Boolean indicating if the schema has been setup at runtime.
	*/
	private function hasInvalidSchema():Boolean {
		if( _invalidSchema == undefined ) {
			_invalidSchema= true;
			if( __schema.elements != null ) {
				var el:Array = __schema.elements;
				for( var i in el ) {
					if( el[i].type.original == false ) {
						_invalidSchema = false;
						return( _invalidSchema );
					} // if not provided to data binding via meta data
				} // for
			} // if has elements
		} // if not been called before
		return( _invalidSchema );
	}
	
	/**
	  Clears the collection items and the delta packet
	*/
	private function initCollection():Void {
		__items = new Array();
		_itemIndexById = new Array();
		internalClearDeltaPacket();
	}
		
	/**
	  Adds the item to the collection, assigns an id to it, and returns the new id.
	  
	  @param	item Object transfer object to add to the collection
	  @param	index Number containing the location of the item within
	  			the collection.
	  @param	rebuildIndx Boolean indicating if the index by id should be rebuilt, if
	  			many items are being added this improves performance.
	  @param	pipeData Boolean indicating if the values in item should be run through the data binding pipeline
	  			and the resulting object should be stored
	  @return	String containing the new id or empty string if not added
	*/
	private function internalAddItem( item:Object, index:Number, rebuildIndx:Boolean, pipeData:Boolean ):String {
		var id:String;
		if( item[ ItemId ] == null ) {
			id = internalGetId();
			item[ ItemId ] = id;
		}
		else
			id = item[ ItemId ];
		if( index >= __items.length )
			__items.push( item );
		else
			__items.splice( index, 0, item );
		// default any undefined properties
		_enableEvents--; // stop calcfields from getting fired
		var evt:Object = _event;
		_trapProperties = true;
		try {
			_propCage = item; // update the specified item
			var el:Object;
			for( var i in __toProperties ) {
				el= __toProperties[i];
				// if the item is being added outside of the items or dataProvider property (rebuildIndex == true),
				// then check to see if the item needs to be defaulted (is it null and not a calculated field).
				if( rebuildIndx && (( item[i] == null ) && ( _calcFields[i] == null ))) 
					getField( i ).setAsString( __toProperties[i].type.value ); 
				else
					if(( item[i] != null ) && pipeData ) {
						getField( i ).setTypedValue(new TypedValue( item[i], el.type.name, el.type ));
					}
			} // for
		}
		finally {
			_enableEvents++;
			_event = evt; // put the old event back
			_trapProperties = false;
		}
		// update calculated fields
		if( _calcFields.__length__ > 0 ) {
			__curItem = item;
			_loading =true;
			try {
				internalDispatchEvent( "calcFields" );
			}
			finally {
				_loading=false;
			}
		}
		_allowReslv= true;
		if( rebuildIndx ) 
			rebuildItemIndexById();
		return( id );
	}
	
	/**
	  Clears all of the current updates for this collection with the specified transaction id.

	  @param	transId [optional] String containing the packet's transaction id to clear, if none is specified this
	  			will clear <i>all</i> delta.
	*/
	private function internalClearDeltaPacket( transId:String ):Void {
		if(( transId == undefined ) || ( transId.length == 0 )) {
			_optDeltaItems = new Array();
			_deltaItems = new Array();
			_dpIndexByTransId = new Array();
			_lastTransId = "";
			_dpTransIdCount = 0;
			_hasDelta = 0;
		}
		else {
			// remove only those delta associated with the transaction id
			var info:Object= _dpIndexByTransId[ transId ];
			if( info != undefined ) {
				// get previous delta index
				var startIndex:Number = _dpIndexByTransId[info.prevId].index;
				startIndex = startIndex == info.index ? 0 : startIndex;
				var count:Number = info.index-startIndex;
				_deltaItems.splice( startIndex, count );
				// go through the list from the end and update the indexes by count items
				var curId:String= _lastTransId;
				while( curId != transId ) {
					info=_dpIndexByTransId[ curId ];
					curId = info.prevId;
					info.index -= count;
				}
				delete _dpIndexByTransId[ transId ];
				_dpTransIdCount--;
				if( _dpTransIdCount == 0 )
					_lastTransId = "";
			} // if
		} // if..else
	}

	/**
	  Returns a unique id within this collection.
	  
	  @return	String unique id for this item within this collection
	*/
	private function internalGetId():String {
		return( "IID"+ String( Math.round( Math.random() * 100000000000 )));
	}

	/**
	  Moves the current iterator to the first item and returns the first item
	  
	  @return	Object first transfer object 
	*/
	private function internalFirst():Object {
		_iterator.first(); // moves to bof
		var item:Object = _iterator.next(); // gets first item
		_iterator.previous(); // go back
		return( item );
	}

	/**
	  Removes the specified item from this collection should it exist.  If the specified item
	  exists within the collection this method will ask listeners of "removeItem" to verify that
	  the item can be removed, if so it will then remove it, log the change (if needed) and notify
	  listeners of the removal.
	  
	  @param	item transfer object to remove from the collection
	  @return	Boolean true if item was removed, false otherwise
	*/
	private function internalRemoveItem( item:Object ):Boolean {
		checkReadOnly();
		var index:Number = _itemIndexById[item[ItemId]];
		var result:Boolean= index != undefined;
		var evt:Object = internalDispatchEvent( "removeItem", { result:true, item:item });
		result= ( evt == null ) || evt.result;
		if( result ) {
			__items.splice( index, 1 );
			rebuildItemIndexById();
			// log change to the delta packet
			if( __logChanges ) 
				logRemoveItem( item, false ); // hasn't been piped
			
			evt = { eventName:"removeItems", firstItem:index, lastItem:index, removedIDs:new Array(item[ItemId])};
			resyncIterators( evt );
			_allowReslv= ( __items.length > 0 );
			__curItem = getCurrentItem();
			internalDispatchEvent( "modelChanged", evt );
			if(( _enableEvents < 0 ) && ( _event != null )) 
				_event.data.lastItem = index; // update the last item deleted
		} // if listeners allow
		return( result );
	}

	/**
	  Deletes all of the managed iterators and creates a new default iterator.
	*/
	private function initIterators():Void {
		var fltrFunc:Function = null;
		if( _iterators != undefined ) 
			fltrFunc= _iterators[ DefaultIterator ].getFilterFunc(); // if we have a default iterator get its filter function
		_iterators = new Array();
		_iterator = new DataSetIterator( DefaultIterator, this );
		_iterator.setFilterFunc( fltrFunc );
		_iterators[ DefaultIterator ] = _iterator;
		_iterator.first(); // move to bof
		__curItem = _iterator.next(); // get first item
	}
	
	/**
	  Returns is the specified element is valid and can be used.  If the element's name is the one of
	  the properties that is specified in meta data it will be invalid.
	  
	  @return	Boolean indicating if the specified element is valid.
	*/
	private function isValidElement( el:Object ):Boolean {
		return( el.type.original == false );
	}
	
	/**
	  Logs an add for the item.  
	  
	  <i><b>NOTE: This method does not check to see if logging is permitted it will 
	  log the add even if logChanges is false</b></i>
	  
	  @param	item Object transfer object to log the add for
	  @param	piped Boolean indicating if item specified has been run via the pipeline
	  @param	id Object containing the id of the item to log, if undefined then the item's id will be used
	*/
	private function logAddItem( item:Object, piped:Boolean, id:Object ):Void {
		if( id == undefined )
			id = item[ItemId];
		var d:Delta = new DeltaImpl( id, piped ? item: decodeItem( item ), DeltaPacketConsts.Added );
		_optDeltaItems[ id ] = d;
		_deltaItems.push( Object( d ));
		_hasDelta++;
	}
	
	/**
	  Logs a remove for the item.  
	  
	  <i><b>NOTE: This method does not check to see if logging is permitted it will 
	  log the remove even if logChanges is false</b></i>
	  
	  @param	item Object transfer object to log the remove for
	  @param	piped Boolean indicates if the item specified has been through the pipeline
	  @param	id Object containing the id of the item to log, if undefined then the item's id will be used
	*/
	private function logRemoveItem( item:Object, piped:Boolean, id:Object ):Void {
		// does it exist in the optimized list?
		if( id == undefined )
			id= item[ItemId];
		var q:Delta =_optDeltaItems[ id ];
		item = piped ? item: decodeItem( item );
		var orgItem:Object = q == undefined ? item : q.getSource();
		var d:Delta= new DeltaImpl( id, orgItem, DeltaPacketConsts.Removed );
		_deltaItems.push( Object( d ));
		if(( q != undefined ) && ( q.getOperation() == DeltaPacketConsts.Added )) {
			delete _optDeltaItems[ id ];
			_hasDelta--;
		}
		else {
			delete _optDeltaItems[ id ]; // !!@@ bug in player?
			_optDeltaItems[ id ]= d;
			_hasDelta++;
		}
	}
	
	/**
	  Rebuilds the item index, based on the modified items list.
	*/
	private function rebuildItemIndexById():Void {
		_itemIndexById = new Array();
		var itm:Object;
		for( var i:Number=0; i<__items.length; i++ ) {
			itm= __items[i];
			_itemIndexById[itm[ItemId]]=i;
		}
	}
	
	/**
	  Removes all of the previous proxy information from this DataSet instance.
	*/
	private function removeProxy():Void {
		var propName:String;
		for( var i in __toProperties ) {
			propName= __toProperties[i];
			delete this[ propName];
			delete this[ "get_"+propName ];
			delete this[ "set_"+propName ];
		} // for
	}
	
	/**
	  Resync's all of the iterators so that they will reflect the latest changes
	  to the collection.
	  
	  @param	info Object describing the action that occurred which requires a re-sync
	*/
	private function resyncIterators( info:Object ):Void {
		// notify all iterators 
		//trace( "DataSet.resyncIterators("+mx.data.binding.ObjectDumper.toString( info )+")");		
		for( var i in _iterators ) 
			_iterators[i].modelChanged( info );
	}
	
	/**
	  Sets the value for the specified field using the setAsXXX method on the field as appropriate
	  for the type of value given.
	  
	  @param	fld DataType
	  @param	value new value to use
	  @param	typeInf information that describes the schema type for this field
	*/
	private function setFieldValue( fld:DataType, value, typeInf:Object ):Void {
		switch( typeof( value )) {
			case "string":
				fld.setAsString( value );
			break;
			
			case "boolean":
				fld.setAsBoolean( value );
			break;
			
			case "number":
				fld.setAsNumber( value );
			break;
			
			case "object":
				fld.setTypedValue( new TypedValue( value, typeInf.name, typeInf ));
			break;
		} // switch
	}
	
	/**
	  Sets the specified property value for the current item in this DataSet.
	  
	  @param	name String containing the name of the property to set
	  @param	value Object new value for the property
	*/
	private function setPropertyValue( name:String, value:Object ):Void {
		// used for formatting values used in find requests
		if( _trapProperties ) {
			_propCage[name]=value;
		}
		else {
			// is this a calculated field?
			if( _calcFields[ name ] != undefined ) {
				__curItem[name]= value;
			}
			else {
				// standard processing
				checkReadOnly();
				var oldVal= __curItem[name];
				if( oldVal != value ) {
					if( __logChanges ) {
						// get the detla before any changes are made to the original
						var d:Delta = getModDeltaInfo( __curItem[ ItemId ] );
						__curItem[name]= value; // if no exceptions are thrown here we proceed.
						// we dont log against added items, but we do need to update them
						if( d.getOperation() == DeltaPacketConsts.Modified ) {
							// add the DeltaItem with the change
							var di:DeltaItem= d.getItemByName( name );
							if( di != null ) 
								oldVal = encodeValue( name, di.oldValue );
							// check to see if we can remove this delta item and the delta
							if( oldVal != value ) {
								var t = new DeltaItem( DeltaItem.Property, name, { oldValue:decodeValue( name, oldVal ), newValue:decodeValue( name, value ), message:"" }, Object( d )); 
							}
							else
								if( d.getChangeList().length == 1 )
									removeDelta( d );
								else {
									var arr:Array = d.getChangeList();
									if(arr)
									{
										var i_i:Number = 0;
										var i_di:DeltaItem;
										var b:Boolean = false;
										for(; i_i < arr.length; i_i++)
										{
											i_di = arr[i_i];
											if(i_di.name == name)
											{
												b = true;
												break;
											}
										}
										if(b)
											arr.splice(i_i, 1);

											
									}
								}
						}
						else
							d.getSource()[name]= decodeValue( name, value );
					} // if we are logging
					__curItem[name]=value;
				} // if there is a change
				// notify anyone of the change
				if( _calcFields.__length__ > 0 ) // fix for bug#70897
					internalDispatchEvent( "calcFields" );
			} // if not calculated
			if( !_loading ) {
				var indx:Number = _itemIndexById[__curItem[ItemId]];
				var evt:Object ={ eventName:"updateField", fieldName:name, firstItem:indx, lastItem:indx };
				// if we have a sort on the field or the field change may cause a filtering 
				// then give all iterators a chance
				var itrUpdated:Boolean = false; // indicates if an iterator has been updated 
				for( var i in _iterators )
					itrUpdated = _iterators[ i ].modelChanged( evt ) || itrUpdated;
				if( itrUpdated )
					internalDispatchEvent( "modelChanged", { eventName:"sort" });
				else
					internalDispatchEvent( "modelChanged", evt );
			} // if not loading
		} // if traping 
	}
	
	/**
	  Removes the associated sorting information for the sort name and field specified.
	  
	  @param	fld DataType with the sort information to be removed
	  @param	name String containing the name of the sort/iterator
	*/
	function removeSortInfo( fld:DataType, name:String ):Void {
		if( fld.sortInfo != null ) 
			delete fld.sortInfo[name];
	}
	
	/**
	  Removes the specified item from the delta items and optimized detla items lists
	  
	  @param	d Delta to be removed from the current delta items list
	  @return	Boolean returns true if the item was removed, false otherwise
	*/
	private function removeDelta( d:Delta ):Boolean {
		// loop through and find the delta specified
		var found:Boolean= false;
		var i:Number=0;
		while( !found && ( i<_deltaItems.length )) {
			found = _deltaItems[i] == d;
			i++;
		}
		if( found ) {
			_deltaItems.splice( --i, 1 );
			delete _optDeltaItems[ d.getId()];
			_hasDelta--; // fix for bug#69845 
		} // if
		return( found );
	}
	
	/**
	  Used to provide the marshalling of property and method access to the delta packet.
	  
	  @param	methodName String name of method being called
	  @return	Function that is to be called
	*/
	private function __resolve( methodName:String ):Function {
		var f:Function= null;
		if( _allowReslv ) {
			var propName = methodName.substring( 4 );
			if( methodName.substr( 0, 4 ) == "get_" ) {
				f = function() { return( this.getPropertyValue( propName )); };
			}
			else 
				if( methodName.substr( 0, 4 ) == "set_" ) {
					f= function() { this.setPropertyValue( propName, arguments[0]);	};
				} 
				else {
					arguments.shift();
					f = function() {
						this.__curItem[ methodName ].apply( this.__curItem, arguments ); // if no exception is thrown we continue
						var id:Number = this.__curItem[ this.ItemId ];
						if( this.__logChanges ) {
							var d:Delta= this.getModDeltaInfo( id );
							new DeltaItem( DeltaItem.Method, methodName, { argList:arguments, message:"" }, Object( d ));
						} // if logging
						// if the method call modified some values then notify everyone 
						var index:Number = this._itemIndexById[ id ];
						this.internalDispatchEvent( "modelChanged", { eventName:"updateItems", firstItem:index, lastItem:index });
					}; // function
				} // else
		} // if we are not initializing stuff
		return( f );
	}
	
	/**
	  This method updates an item within this dataset based on the delta specified.
	  
	  @param	d Delta containing the changes to make to the item
	*/
	private function updateItem( d:Delta ):Void {
		// update the current properties
		var id:Object = d.getId();
		var keys:Object;
		var obj:Object= null;
		var oldLC:Boolean = __logChanges;
		__logChanges = false;
		try {
			if( id == null )
				keys=d.getSource();
			else
				keys={ __ID__:id };
			obj=_iterator.find( keys );
			if( obj != null ) {
				var index:Number = _itemIndexById[obj[ItemId]];
				var cl:Array = d.getChangeList();
				var dItem:Object;//!!@@ compiler doesn't like DeltaItem
				var oldItem:Object = __curItem;
				try {
					__curItem= obj;
					for( var i:Number=0; i<cl.length; i++ ) {
						dItem=DeltaItem( cl[i] );
						getField( dItem.name ).setTypedValue( new TypedValue( dItem.curValue, __toProperties[dItem.name].type.name, __toProperties[dItem.name].type )); 
					} // for
				}
				finally {
					__curItem=oldItem;
				}
				internalDispatchEvent( "modelChanged", { eventName:"updateItems", firstIndex:index, lastIndex:index });
			} // if we found it
			else
				_global.__dataLogger.logData( null, "Couldn't find the following item:", d.getSource());
		}
		finally {
			__logChanges = oldLC;
		}
	}
	
}

/*
  ToDo:
  - update XPathAPI to support wrapping of attribute nodes
  - update FieldAccessor and test that schema is coming through as expected.
  - make sure the DeltaPacket is exposing everything via the pipeline
  - [done] create a DateToMillisec encoder
  - [done] As data in coming in via data provider pipe everything so dates and bools work as expected.
  - [done] add schema information to deltapacket when data provider or items property are set.
  - [done] when a date data type is used add the DateToMillisec encoder by default if none is specified.
  - [done] create a new swc that includes all of the utils classes, and add it to the classes library.
  - [done] remove the editField and rework the DataProvider API to accomodate.
  - add the shared proxy, one for each iterator that is returned by the getIterator() method.
  - reduce the number of calls to getSettableTypes() and in general look for short cuts in the pipeline.
  - change the ComponentMixin class to have initialize instead of initComponent.
  - we need mx.data.types.Dte!! 
  - [done] add locateById to support bookmarks outside of
  - [done] add a reset() to the iterator to remove filtering and sorting options.
  - [done] update spec for applyUpdates to make note of disableEvents() issue
  - [done] update the spec to indicate how clear and removeAll will work
  - [done] update spec to indicate that the filter is using a function now.
  - [done] update spec to include modelChanged and propsChanged event this will replace the following events
  	  a. afterAddItem
	  b. afterRemoveItem
	  c. change beforeAddItem->addItem
	  d. change beforeRemoveItem->removeItem
  - update spec to include reference to new TransferObject interface RE: itemClassName
  - [done] update spec for newItem.
  - [done] update spec for resolveErrors event in the deltapacket assignment
  - [done] work on hasValidSchema().
  - fix all !!@@ comments
  - [done] fix DataProvider API to use the current iterator to support filtering and sorting.
  - [done] migrate the DataProvider API onto a sub-class which will cache formatted TOs, figure out if we can create a proxy 
           that can be shared amongst all data representations.
  - [done] update component meta data and enhance addBinding code to manage multiple events when available.
  - [done] update all of the private members without accessor methods to have a single underscore.
  - [done] add return value for removeItem if item is removed (goes in spec)
  - [done] add return boolean for addItem if item is added (goes in spec).
  - [done] Change the addItem to make the current item reflect the added item.
  - [done] model changed -add/decide on event that will be dispatched for databinding when the fields need to be updated.
  - [done] get initSchema working!
  - [done] change all events to anonymous, 
  - [done] add a list for each delta item that puts them in the order they occurred to support undo
  - locate method, add option for using item id.
  - [done] create the findClass util class
  - [done] enableEvents
  - [done] disableEvents
  - [done] iterator clone need to finish this
  - [done] set iterator
  - [done] afterLoaded event
  - [done] afterAddItem, beforeAddItem event
  - [done] afterRemoveItem, beforeRemoveItem event
  - [done] iteratorScrolled event
  - [done] newItem event
  - [done] DataProvider interface 
  - [done] add method applyUpdates() 
  - [done] find 
  - [done] findFirst 
  - [done] findLast 
  - [done] Add modelChanged event (add to spec) look to see if this can replace the itemCountChanged
  - Update the binding.as code to support:
     [done] a) addBinding before setupListeners.
	 b) conditional execute will need the event information
	 [done] c) remove findSchema from DataType initialization code or ComponentMixins.
	 [done] d) add method for getting a default value from a DataType 
  
updateAll : The entire view needs refreshing, excluding scroll position
addItems : A series of items have been added
removeItems : A series of items have been deleted
updateItems : A series of items need refreshing
sort : The data has been sorted
updateField : A field within an item has be changed and needs refreshing
updateColumn : An entire field's definition within the dataProvider needs refreshing.
filterModel : The model has been filtered, and the view needs refreshing (reset scrollPosition)
schemaLoaded : the fields definition of the dataProvider has been declared

*/
