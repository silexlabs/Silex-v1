//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.components.datasetclasses.Delta;
import mx.data.components.datasetclasses.DeltaItem;
import mx.data.components.datasetclasses.DeltaPacketConsts;

/**
  Delta implementation which handles a list of DeltaItems.
  
  @tiptext	Contains list of changes to an item
  @helpid	3500
*/
class mx.data.components.datasetclasses.DeltaImpl extends Object implements Delta {
	
	/**
	  Initializes an instance of a Delta.
	  
	  @param	id Object that identifies this Delta within the DeltaPacket
	  @param	curSrc Object source transfer object reference in its current state
	  @param	msg String [optional] message to associate with this delta item
	  @param	acl Boolean [optional] indicates that access to the change list is permitted
	  			at all times.
	*/
	function DeltaImpl( id:Object, curSrc:Object, op:Number, msg:String, acl:Boolean ) {
		super();
		_deltaItems= new Array();
		_id = id;
		_source = curSrc;
		_op = op;
		_message = msg == undefined ? "": msg;
		_accessCl = acl == undefined ? false: acl;
	}
	
	/**
	  Adds the specified item to the delta item list or replaces an existing one found
	  with the same name.
	  
	  @tiptext	Adds the specified DeltaItem
	  @helpid	3500
	  @param	item DeltaItem to add to the list
	*/
	public function addDeltaItem( item:DeltaItem ):Void {
		var i:Number= getItemIndexByName( item.name );
		if(( i < 0 ) || ( item.kind == DeltaItem.Method ))
			_deltaItems.push( item );
		else {
			// replace it
			_deltaItems.splice( i, 1 );
			_deltaItems.splice( i, 0, item );
		}
	}
	
	/**
	  Returns the unique id for this delta.
	  
	  @return	Object containing the id which relates this delta back to the
	  			associated transfer object.
	  @tiptext	Returns the unique id for this delta
	  @helpid	3500
	*/
	public function getId():Object {
		return( _id );
	}
	
	/**
	  Returns the associated operation for this Delta. Valid values are
		<li>DeltaPacketConst.Added</li>
		<li>DeltaPacketConst.Removed</li>
		<li>DeltaPacketConst.Modified</li>
		
	  @return	Number indicating which operation occurred for this Delta.
	  @tiptext	Returns the associated operation
	  @helpid	3500
	*/
	public function getOperation():Number {
		return( _op );
	}
	
	/**
	  Returns the list of changes for the associated transfer object.
	  
	  @return	Array of DeltaItems associated with this Delta
	  @tiptext	Returns list of mutations
	  @helpid	3500
	*/
	public function getChangeList():Array {
		if(( _op != DeltaPacketConsts.Added ) || _accessCl )
			return( _deltaItems );
		else
			return( null );
	}
	
	/**
	  Returns the DeltaItem with the specified name if it can be found in the list,
	  if the item can not be found null is returned
	  
	  @return	DeltaItem with the specified name or null if not found
	  @tiptext	Returns the specified DeltaItem
	  @helpid	3500
	*/
	public function getItemByName( name:String ):DeltaItem {
		var index:Number = getItemIndexByName( name );
		if( index >= 0 )
			return( _deltaItems[ index ]);
		else
			return( null );
	}
	
	/**
	  Returns the source object that this DeltaImpl has recorded changes for.
	  
	  @return	Object source of the changes
	  @tiptext	Returns the associated source object
	  @helpid	3500
	*/
	public function getSource():Object {
		var result:Object = _source;
		if(( _op == DeltaPacketConsts.Added ) && ( arguments.length > 0 )) {
			// the caller has asked for a copy to avoid inadvertent modifications
			if( _source.clone == undefined ) {
				result= new Object();
				var prop:Object;
				for( var i in _source ) {
					prop=_source[i];
					if( typeof( prop ) != "function" )
						result[i]=prop;
				} // for
			}
			else
				result = _source.clone();
		}
		return( result );
	}
	
	/**
	  Returns any message associated with this Delta.
	  
	  @return	String containing the associated message or "" if not defined
	  @tiptext	Returns the associated message
	  @helpid	3500
	*/
	public function getMessage():String {
		return( _message );
	}
	
	/**
	  Returns a reference to the DeltaPacket for this Delta.
	  
	  @return	Object reference to the DeltaPacket for this Delta
	  @tiptext	Returns reference to the DeltaPacket
	  @helpid 	3500
	*/
	public function getDeltaPacket():Object {
		return( _owner );
	}
	
	//----- private members --------
	
	private var _deltaItems:Array; // contains an ordered list of delta items
	private var _id:Object; // unique id for this delta
	private var _source:Object; // source transfer object
	private var _op:Number;
	private var _message:String;
	private var _owner:Object; 
	private var _accessCl:Boolean;
	
	/**
	  Returns the index of a delta item in the list with the specified name, or -1 if 
	  it isn't found.
	  
	  @return	Number index of delta item within the list or -1 if not found.
	*/
	private function getItemIndexByName( name:String ):Number {
		var di:DeltaItem;
		if(( _op == DeltaPacketConsts.Modified ) || _accessCl )
			for( var i:Number=0; i<_deltaItems.length; i++ ) {
				di= _deltaItems[i];
				if( di.name == name )
					return( i );
			}
		return( -1 );
	}
}