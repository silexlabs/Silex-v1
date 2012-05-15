//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  The DeltaItem class provides information about an individual operation 
  performed on a transfer object. For example the DeltaItem indicates if a 
  change made was for a property of the transfer object or a method call. It 
  also provides the original state of properties on a transfer object.  
  
  @author	Jason Williams
  @tiptext	Contains a single mutation event
  @helpid	1487
*/
class mx.data.components.datasetclasses.DeltaItem extends Object {
	
	/**
	  Constructs an instance of the DeltaItem using the kind, name and initializer specifed.
	  
	  @param	kind Number indicating what kind of delta item this is.  Valid values are:
	  			<li>DeltaItem.Property</li> - change to a property
				<li>DeltaItem.Method</li> - method invocation
	  @param	name String containing the name of the property or method
	  @param	init Object initializer containing the remaining properties based on the kind 
	  			specified. i.e. 
				  if kind is DeltaItem.Property the initializer must contain
				  {oldValue:..., newValue:...., curValue:..., message:"..."}
				  if kind is DeltaItem.Method the initializer must contain
				  {argList:Array..., message:"..."}
	  @param	owner Object that this delta item belongs to.
	*/
	function DeltaItem( kind:Number, name:String, init:Object, owner:Object ) {
		__name = name;
		__kind = kind;
		__owner = owner;
		if( kind == DeltaItem.Property ) {
			__oldValue = init.oldValue;
			__newValue = init.newValue;
			__curValue = init.curValue;
		}
		else
			__argList = init.argList;
		__message= init.message == undefined ? "" : init.message;
		__owner.addDeltaItem( this ); 
	}
	
	/**
	  Read only; If this mutation's kind is DeltaItem.Method this will be the argument list 
	  passed to the method call when the mutation occured.
	  
	  @tiptext	Returns arguments list
	  @helpid	1488
	*/
	function get argList():Array {
		return( __kind == Method ? __argList: null );
	}
	
	/**
	  Read only; Returns the reference to the delta this item belongs to.
	  
	  @tiptext	Returns reference to Delta container 
	  @helpid	1489
	*/
	function get delta():Object {
		return( __owner );
	}
	
	/**
	  Read only; Returns this mutation's kind.  It will be one of the following
	    <li>DeltaItem.Property</li>
	    <li>DeltaItem.Method</li>
		
	  @tiptext	Returns kind of DeltaItem
	  @helpid	1490
	*/
	function get kind():Number {
		return( __kind );
	}
	
	/**
	  Read-only; Returns the mutation's associated message.  This is generally used for a server side
	  response message to the update operation that was performed.
	  
	  @tiptext	Returns associated message
	  @helpid	1491
	*/
	function get message():String {
		return( __message );
	}
	
	/**
 	  Read-only; If this mutation's kind is DeltaItem.Method this will be the name of the 
	  method that was called to create the mutation. 
	  
	  @tiptext	Returns associated name
	  @helpid	1492
	*/
	function get name():String {
		return( __name );
	}
	
	/**
	  Read-only; If this is a server response this will be the current property value of the
	  server instance of the transfer object.
	  
	  @tiptext	Returns the current server value
	  @helpid	1493
	*/
	function get curValue():Object {
		return( __curValue );
	}
	
	/**
	  Read-only; If this mutation's kind is DeltaItem.Property this will be the new value 
	  of the property, i.e. the value the property was last set to. 
	  
	  @tiptext	Returns the new value
	  @helpid	1494
	*/
	function get newValue():Object {
		return( __kind == Property ? __newValue: null );
	}
	
	/**
	  Read-only; If this mutation's kind is DeltaItem.Property this will be the old value 
	  of the property, i.e. the value of the property before it was set. 
	  
	  @tiptext	Returns the original value
	  @helpid	1495
	*/
	function get oldValue():Object {
		return( __kind == Property ? __oldValue: null );
	}

	static var Property:Number = 0;
	static var Method:Number = 1;
	
	// ------ private members ---------
	
	private var __name:String; // property name or method name
	private var __kind:Number; // kind of delta item
	private var __argList:Array;
	private var __oldValue:Object;
	private var __newValue:Object;
	private var __curValue:Object;
	private var __message:String;
	private var __owner:Object;
}