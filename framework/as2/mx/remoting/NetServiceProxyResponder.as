//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

// -----------------------------------------------------------------
// NetServiceProxyResponder
// This is the automatically-generated responder object that is used
// when a service is called and no responder object was given.
// -----------------------------------------------------------------

class mx.remoting.NetServiceProxyResponder extends Object {

	/**
	  Constructs a new instance of the netservices responder for the service
	  and method specified.
	  
	  @param	serv Object service that methods are to be called on
	  @param	method String containing the name of the method to invoke on the service
	*/
	function NetServiceProxyResponder( serv:Object, method:String ) {
		super();
		service = serv;
		methodName = method;
	}
	
	/**
	  This function gets called whenever an onResult is received from the server,
	  a result of a call that is being handled by our responder object.
	  
	  @param	result Object containing the data recieved from the server
	 */
	function onResult( result ):Void {
	
		var client = service.client;
	
		// tell the result object what service it came from, if it wants to know.
		// (this call usually has no effect, except for NetServiceProxy and RecordSet).
        if (result instanceof mx.remoting.NetServiceProxy || result instanceof mx.remoting.RecordSet)
        {
		    result._setParentService( service );
        }
	
		var func = methodName + "_Result";

		if (typeof(client[func]) == "function")
		{
			// there is an "xxx_Result" method supplied - call it.
			client[func].apply(client, [result]);
		}
		else if (typeof(client.onResult) == "function")
		{
			// there is an "onResult" method supplied - call it.
			client.onResult(result);
		}
		else
		{
			// nobody to call. Dump something to the output window.
			mx.remoting.NetServices.trace("NetServices", "info", 1, func + " was received from server: " + result);
		}
	}

	/**
	  This function gets called whenever an onStatus is received from the server
	  as a result of a call that is being handled by our responder object.
	  
	  @param	result Object containing the error information returned from the server
	*/
	function onStatus(result):Void {
		var client = service.client;
	
		var func = methodName + "_Status";
		if (typeof(client[func]) == "function")
		{
			// there is an "xxx_Status" method supplied - call it.
			client[func].apply(client, [result]);
		}
		else if (typeof(client.onStatus) == "function")
		{
			// there is an "onStatus" method supplied - call it.
			client.onStatus(result);
		}
		else if (typeof(_root.onStatus) == "function")
		{
			// there is an "onStatus" method at the root level - call it.
			_root.onStatus(result);
		}
		else if (typeof(_global.System.onStatus) == "function")
		{
			// there is an "onStatus" method at the global level - call it.
			_global.System.onStatus(result);
		}
		else
		{
			// nobody to call. Dump something to the output window.
			mx.remoting.NetServices.trace("NetServices", "info", 2, func + " was received from server: <" + result.level + "> " + result.description);
		}
	}
	
	var client:Object;
	var service:Object;
	var methodName:String;
}
