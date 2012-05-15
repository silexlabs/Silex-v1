//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.DeltaPacket;
import mx.utils.Iterator;
import mx.utils.IteratorImpl;

/**
  Implements the DeltaPacket interface allowing clients to access the changes
  made to the associated DataSet collection and its transfer objects.
  
  @tiptext	Contains collection of changes 
  @helpid	3600
  @author	Jason Williams
*/
class mx.data.components.datasetclasses.DeltaPacketImpl extends Object implements DeltaPacket {
	
	/**
	  Constructs an instance of the DeltaPacket with the specified data and
	  source.
	  
	  @param	src Object source of this delta packet
	  @param	id String containing the unique transaction id for this 
	  			delta packet
	  @param	keyInfo Object containing the 
	  @param	log Boolean indicating if this packet of changes should be logged when applied to a dataset
	  @param	conSch Object containing the connector schema used when setting the items property of the dataset
	*/
	function DeltaPacketImpl( src:Object, id:String, keyInfo:Object, log:Boolean, conSch:Object ) {
		super();
		_deltaPacket= new Array();
		_optimized = true;
		_source = src;
		_keyInfo = keyInfo == undefined ? null : keyInfo;
		_transId = id;
		_log = log == undefined ? false : log;
		_timestamp= new Date();
		_confInfo = conSch;
	}
	
	// -------- public members --------------
	
	/**
	  Adds the specified delta item to the delta packet
	  
	  @param	item Object delta to add to this delta packet
	*/
	public function addItem( item:Object ):Boolean {
		if( item instanceof mx.data.components.datasetclasses.Delta ) {
			item._owner = this; // setup the reference to us
			_deltaPacket.push( item );
			return( true );
		}
		else
			return( false );
	}
	
	/**
	  Clears this delta packet of all changes.
	*/
	public function clear():Void {
		_deltaPacket = new Array();
	}
	
	/**
	  Returns if the specified item exists in the 
	*/
	public function contains( item:Object ):Boolean {
		var found:Boolean = false;
		var i:Number =0;
		while( !found && ( i<_deltaPacket.length )) {
			found = _deltaPacket[i] == item;
			i++;
		}
		return( found );
	}
	
	/**
	  Reutrns an iterator for this collection.
	  
	  @return	Iterator
	  @tiptext	Returns an iterator of the changes
	  @helpid	3600
	*/
	public function getIterator():Iterator {
		return( new IteratorImpl( this ));
	}
	
	/**
	  Used by the iterator to extract an item from this collection
	  
	  @param	index Number containing the desired item within the collection
	  @return	Object item from the collection at the specified position
	*/
	function getItemAt( index:Number ):Object {
		return( _deltaPacket[ index ]);
	}
	
	/**
	  Returns the schema associated with the source component of this delta packet's source 
	  component. e.g. XMLConnector's schema in the scenario
	*/
	function getConfigInfo( info:Object ):Object {
		return( _confInfo );
	}
	
	/**
	  Returns the key information about this delta packet's items.  This information
	  is used during the resolve process between a component and the delta packet. 
	  
	  @return	Object containing key property information for the items descibed in
	  			this delta packet.
	*/
	function getKeyInfo():Object {
		return( _keyInfo );
	}
	
	/**
	  Returns the number of delta within this delta packet.
	  
	  @return	Number containing the number of delta or changes contained.
	*/
	function getLength():Number {
		return( _deltaPacket.length );
	}
	
	/**
	  Returns the source of this DeltaPacket.
	  
	  @return	Object source of this DeltaPacket i.e. which DataSet
	  			did it come from.
	  @tiptext	Returns originating component
	  @helpid	3600
	*/
	public function getSource():Object {
		return( _source );
	}

	/**
	  Returns the transaction id of this DeltaPacket.
	  
	  @return	String transaction id for this delta packet
	  @tiptext	Returns associated transaction id
	  @helpid	3600
	*/
	public function getTransactionId():String {
		return( _transId );
	}
	
	/**
	  Returns the date and time when this DeltaPacket was created.
	  
	  @return	Date containing the date and time this delta packet was created.
	  @tiptext	Returns the time stamp when the DeltaPacket was created
	  @helpid	3600
	*/
	public function getTimestamp():Date {
		return( _timestamp );
	}
	
	/**
	  Indicates if there are any Delta contained within this packet.
	  
	  @return	Boolean true if there are no items in the packet, false otherwise.
	*/
	public function isEmpty():Boolean {
		return( _deltaPacket.length == 0 );
	}
	
	//!!@@ fix
	public function removeItem( item:Object ):Boolean {
		return( false );
	}
	
	/**
	  Returns if the application of this delta packet should 
	  be logged.
	  
	  @return	Boolean indicating if the changes of this packet should
	  			be logged when applied.
	  @tiptext	Returns if changes should be logged when applied
	  @helpid	3600
	*/
	public function logChanges():Boolean {
		return( _log );
	}
	
	// -------- private members ----------
	
	private var _deltaPacket:Array;
	private var _source:Object;
	private var _optimized:Boolean;
	private var _transId:String;
	private var _log:Boolean;
	private var _timestamp:Date;
	private var _keyInfo:Object;
	private var _confInfo:Object;
	
}