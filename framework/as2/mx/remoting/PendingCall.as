//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.Service;
import mx.rpc.Responder;
import mx.rpc.ResultEvent;
import mx.rpc.FaultEvent;
import mx.rpc.Fault;

/**
	On each call to a Service Object a PendingCall Object is generated which manages 
	dispatching results recieved from the server via the associated service.  Once 
	constructed the caller should assign a responder that will process the invocation 
	results.

	@tiptext Manages dispatching results recieved from the associated service
	@helpid	4489

*/
class mx.remoting.PendingCall extends Object 
{
	/*
		Initializes a PendingCall object for a Service request. The PendingCall Object 
		is created with a reference to the requested Service. The PendingCall Object is 
		responsible for setting up the Responder and manage event handlers for 
		Result/Status. 

		@param		Service		srv		The Service on which request has been made
		@param		String		methodName	the method to be invoked
	*/
	function PendingCall(srv:Service,methodName:String) {
		super();
		__service = srv;
		__methodName = methodName;
	}
	
	
	/**
		Provides access to the associated responder
		@return		Responder object that will process the results of the call.
		@tiptext	The associated Responder for this PendingCall 
		@helpid	4490
	*/
	public function get responder():Responder {
		return( __responder );
	}
	
	public function set responder( res:Responder ):Void {
		__responder = res;
	}
	
	/*
		After successful invocation of a Service call, result is received and Handler method is invoked

		@param		result	The result returned after successful invocation of a Service call
		@tiptext	EventHandler for when a Result is received as a result of a Service call
	*/
	public function onResult( result ):Void 
	{
		// tell the result object what service it came from, if it wants to know.
		// (this call usually has no effect, except for NetServiceProxy and RecordSet).
		result.serviceName = result.serviceName;
		if (result != null)
		{
		    if (result instanceof mx.remoting.NetServiceProxy)
		    {
		        //Wrap NetServiceProxy result with new Services API to hide legacy "client" and "nc"
		        var serv = new Service(null, null, result.serviceName, __service.connection, __service.responder);
		        result = serv;
		    }
		    else if (result instanceof mx.remoting.RecordSet)
		    {
				var proxy = new mx.remoting.NetServiceProxy(__service.connection);
				result._setParentService(proxy);
				result.logger = __service.log;
		    }
		}
		
		if( __responder != null )
			__responder.onResult( new ResultEvent( result ) );

		if (__service.log != null){
			__service.log.logInfo(__service.name + "."+ __methodName+ "() returned "+ mx.data.binding.ObjectDumper.toString( result ));
		}
	}
	
	/*
		onStatus is invoked when an error is posted for a PendingCall. The information 
		object has the attributes like code, details, description and type. The method 
		then invokes a new Fault event with the information object attributes. 

		@param		result	Object The object containing details, description and other information of the status
		@tiptext	EventHandler for when a Result is received as a result of a Service call
	*/
	public function onStatus( status ):Void {
		
		if( __responder != null )
			__responder.onFault(new FaultEvent(new Fault(status.code, status.description, status.details, status.type)));

		if (__service.log != null){
			__service.log.logDebug("Service invocation failed.");
			__service.log.logDebug(__service.name + "."+ __methodName+ "() returned "+ mx.data.binding.ObjectDumper.toString( status ));
		}
	}

	public function get methodName():String{
		return __methodName;
	}

	public var onFault:Function;
	private var __responder:Responder;
	private var __service:Service;
	private var __methodName:String;

	//Ensure NetServiceProxy is loaded and registered
	private static var inited:Boolean = mx.remoting.NetServiceProxy.registerNetServiceProxy();
}