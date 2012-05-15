//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.rpc.Responder;

/**
	This is a responder object that relays result and fault calls to a corresponding 
	function on the specified object.

	@tiptext Dispatches results from a method invocation to user defined methods
	@helpid	4491	
*/
class mx.rpc.RelayResponder extends Object implements Responder {
	
	/**
	  Constructs an instance of the relay that will call the specified methods 
	  for result or fault on a given object. 
	  
	  @param	resp	Object	Object that will handle the fault or result calls
	  @param	resultFunc	String	String containing the name of the function to call, when result is recieved.
	  @param	faultFunc	String	containing the name of the function to call, when a fault is recieved.
	  @tiptext	Creates a new RelayResponder
	  @helpid	4492
	*/
	function RelayResponder( resp:Object, resultFunc:String, faultFunc:String ) {
		super();
		__obj = resp;
		__onFault = faultFunc;
		__onResult = resultFunc;
	}
	
	/*
	   When a fault in recieved, Fault Handler is called. onFault dispatches the fault message.
	   @param	fault Object  contains information of the fault recieved. This includes specified code, message, and details
	*/
	function onFault( fault:mx.rpc.FaultEvent ):Void {
		__obj[ __onFault ]( fault );
	}
	
	/*
	  Result Handler is called when a result is recieved. onResult dispatches the result message 
	  
	  @param	result reference to the result after successfult method invocation
	*/
	function onResult( result:mx.rpc.ResultEvent ):Void {
		__obj[ __onResult ]( result );
	}
	
	private var __obj:Object;
	private var __onFault:String;
	private var __onResult:String;
}
