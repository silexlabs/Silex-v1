//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  Contains the error details from a fault that occurred during a method invocation
  
  @tiptext	Contains the details of a fault that occurred during a method invocation
  @helpid	4495
*/
class mx.rpc.Fault extends Object {

	/**
	  Constructs an instance of the fault with the specified code, message, and details

	  @param	code String containing the fault code
	  @param	msg String containing the fault message
	  @param	detail String containing any details associted with the fault
	  @param	type String containing the name of the exception class that was thrown on the server
	*/
	function Fault( code:String, msg:String, detail:String, type:String ) {
		super();
		__faultcode = code;
		__faultstring = msg;
		__detail = detail;
		__type = type;
	}

	/**
	  Provides access to the fault code provided by the remote service
	
	  @tiptext	Provides access to the fault code provided by the remote service
	  @helpid	4496
	*/
	function get faultcode():String {
		return( __faultcode );
	}

	/**
	  Provide access to the description of the fault by the remote service
	  
	  @tiptext 	Provide access to the description of the fault by the remote service
	  @helpid	4497
	*/
	function get faultstring():String {
		return( __faultstring );
	}

	/**
	  Provides access to the detail information provided by the remote service
	  
	  @tiptext	Provides access to the detail information provided by the remote service
	  @helpid	4498
	*/
	function get detail():String {
		return( __detail );
	}

	/**
	  Provides access to the description of the error provided by the remote service
	  
	  @tiptext	Provides access to the description of the error provided by the remote service
	  @helpid	4499
	*/
	function get description():String {
	    if (__description == null)
	    {
	        if (__faultstring.indexOf(":") > -1)
	        {
	            __description = __faultstring.substring(__faultstring.indexOf(":") + 1);
                //trim off any leading spaces
                var st = 0;
                while (__description.indexOf(' ', st) == st) ++st;
                if (st > 0) __description = __description.substring(st);
	        }
	        else
	        {
	            __description = __faultstring;
	        }
	    }
	    return __description;
	}

	/**
	  Provides access to the type information provided by the remote service.
	  
	  @tiptext	Provides access to the type information provided by the remote service
	  @helpid	4500
	*/
	function get type():String {
		return( __type );
	}

	private var __detail:String;
	private var __description:String;
	private var __faultcode:String;
	private var __faultstring:String;
	private var __type:String;
}