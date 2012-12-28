//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.rpc.Responder;
import mx.remoting.Connection;
import mx.remoting.NetServices;
import mx.remoting.PendingCall;
import mx.remoting.Operation;
import mx.services.Log;

/**
	The Services object is a collection of methods that helps you create and use connections to services 
	using Flash Remoting. The Services object helps you create and use Connection objects.

	@tiptext Proxy for a remote service
	@helpid	4450
*/
dynamic class mx.remoting.Service extends Object
{
//#include "RemotingComponentVersion.as"
	
	/**
	  The connection can be passed or a gatewayURI string. If the connection is not passed a
	  connection will be created for the specified gatwayURI, if a connection with the same URI doesn't
	  already exist. Using the gatewayURI allows for the sharing of the connection.
	  
	  @param	gatewayURI	String containing the gateway that should be created or used from the current pool.
	  						if this parameter is blank "" and the conn parameter is null the Url for the service
							will default to that specified using the gatewayUrl value of the flashvars parameter 
							specified in the HTML page.
	  @param	logger	Log to send debugging messages to
	  @param	serviceName	String containing the name of the service to invoke the method on.
							
	  @param	conn	Connection this service should be associated with, if this value is null and the gatewayURI
	  					parameter is empty the gateway will be established using the gatewayUrl value of the 
						flashvars parameter specified in the HTML page 
	  @param	resp	Responder that will handle all of the call backs for the method calls made
	  @tiptext	Creates a new Service
	  @helpid	4451
	*/
	function Service( gatewayURI:String, logger:Log, serviceName:String, conn:Connection, resp:Responder )
	{
		super();

		log = logger;
		
		log.logInfo("Creating Service for " + serviceName, Log.VERBOSE);
		// fix for bug#87385
		if(( gatewayURI == "" ) && ( conn == null ))
			gatewayURI = NetServices.gatewayUrl;
			
		gatewayURI = NetServices.getHttpUrl(gatewayURI);

		if( conn == null )
		{
			conn = NetServices.getConnection(gatewayURI);
			if( conn == null )
			{
				log.logInfo("Creating gateway connection for " + gatewayURI, Log.VERBOSE);
				conn = NetServices.createGatewayConnection(gatewayURI, logger);
			}
		}
		__conn = conn;
		conn.updateConfig();
		_allowRes = true;
		__serviceName = serviceName;
		__responder = resp;

		log.logInfo("Successfully created Service", Log.VERBOSE);
	}

	/**
	  Read only accessor for the associated connection. This returns any existing connections 
	  that have been previously created with the given uri
	  
	  @return	Connection associated with this service
	  @tiptext	Returns associated connection
	  @helpid	4452
	*/
	function get connection():Connection
	{
		return( __conn );
	}

       /*
		This function gets called whenever somebody does "myService.methodName(parameters...)".
		A function "opFunc", which knows how to call the correct server method is constructed 
		and returned. 

		@param		methodName	String	String containing the method or property that was accessed in AS on this proxy.
       */
	function __resolve( methodName:String ):Function
	{
		if( _allowRes )
		{
                    //Register a function as a property on this Service so that __resolve is not called again.
		    var opFunc:Function = __makeOpFunc(methodName);
		    this[methodName] = opFunc;
		    return opFunc;
		}
		else
		{
		    return null;
		}
	}

	/*
        Creates and returns a function "myFunc" to handle calls to a service function. The function
		created is attached to a specific service.
		@param		name	String	The name of the method for this Operation.
	*/
	function __makeOpFunc(name:String):Function
	{
		var op = new Operation(name, this);

		//This method is accessed as serviceName.methodName(args) and automatically sends the request
		var myFunc = function ()
		{
		    op.invoke(arguments);
		    return op.send();
		};

		//This method is accessed using serviceName.methodName.send()
		//Users must have set up arguments for binding in the RemoteObject method tags.
		myFunc.send = function():PendingCall
		{
		    return op.createThenSend();
		};

		//This method is accessed using serviceName.methodName.setResponder(resp)
		myFunc.setResponder = function(resp:Responder):Void
		{
		    op.responder = resp;
		};

		myFunc.getRequest = function():Object
		{
		    return op.request;
		};

		myFunc.setRequest = function(val:Object):Void
		{
		    op.request = val;
		};

		//Register getter/setters for request property
		myFunc.addProperty("request", myFunc.getRequest, myFunc.setRequest);

		myFunc.operation = op;

		return myFunc;
	}

        /**
			Returns the the name of the service which can be a Java classname/JNDI 
			location or a ColdFusion component

			@return		The service name, such as a Java classname or JNDI location.
			@tiptext	Returns the name of the Service
			@helpid		4453
        */
	public function get name():String
	{
	    return __serviceName;
	}

	/**
		Responder associated with this service.

		@return		Responder Object The service-level Responder.
		@tiptext	Returns the associated responder
		@helpid		4454
	*/
	public function get responder():Responder
	{
	    return __responder;
	}

	private var __conn:Connection;
	private var __serviceName:String;
	private var __responder:Responder;
	private var _allowRes:Boolean = false;
	var log:Log;
}