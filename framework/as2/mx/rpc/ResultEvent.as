//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  Provides access to the result of the remote method invocation
  
  @tiptext	Provides access to the result of the remote method invocation
  @helpid	4501
*/
class mx.rpc.ResultEvent extends Object {

	/**
	  Constructs an instance of a result to mimic the WebServices result wrapper.
	  @param res The result
	*/
	function ResultEvent( res:Object ) {
		super();
		__result = res;
	}

	/**
	  Provides access to the result
	  
	  @tiptext 	Provides access to the result received from the method invocation
	  @helpid	4502
	*/
	function get result():Object {
		return __result;
	}

	private var __result:Object;
}