//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.rpc.Fault;

/**
  Contains a fault that occurred during a method invocation
  
  @tiptext	Contains a fault that occurred during method invocation
  @helpid	4493
*/
class mx.rpc.FaultEvent extends Object {

	/**
	  Constructs an instance of the fault with the specified code, message, and details

	  @param	f Fault the actual fault object of this event
	*/
	function FaultEvent( f:Fault ) {
		super();
		__fault = f;
	}

	/**
		Provides access to the fault that occurred.
		
		@tiptext	Fault that occurred during method invocation
		@helpid		4494
	*/
	function get fault():Fault {
		return( __fault );
	}

	private var __fault:Fault;
}