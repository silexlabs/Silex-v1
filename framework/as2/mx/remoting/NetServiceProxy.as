//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

// Ensure that NetServiceProxy objects received via AMF messages get
// correctly deserialized into actionscript objects.

import mx.remoting.NetServiceProxyResponder;
import mx.remoting.Connection;

dynamic class mx.remoting.NetServiceProxy extends Object {

	/**
	  Contructs and instance of the proxy for the network client, local client
	  and service name specified.
	  
	  @param	nc Object network connection
	  @param	serviceName String containing the service to call
	  @param	client Object local client "responder"
	*/
	function NetServiceProxy(netC:Connection, servName:String, cli:Object) {
		super();
		if (netC != null) {
			// the constructor was called from ActionScript code
			nc = netC;
			serviceName = servName;
			client = cli;
		}
		// else - parameter is null, this probably means that 
		// this object has just been received as a typed object in an AMF message.
		// just leave the data alone. construction of this object
		// will be completed when _setParentService is called.
		_allowRes= true;
	}

	/**
	  Called by the player to initialize the data recieved from an AMF message
	  
	  @param	service Object
	*/
	function _setParentService(service:Object):Void  {
		nc = service.nc;
		client = service.client;
	}

	/**
	  This function gets called whenever somebody does "myService.methodName(parameters...)".
	  We construct and return the function "f", which knows how to call the correct server method. 
	  
	  @param	methodName String containing the method or property that was accessed in AS on
	  			this proxy.
	 */
	function __resolve( methodName:String ):Function {
		if( _allowRes ) {
			var f = function() {
				// did the user give a default client when he created this NetServiceProxy? 
				if (this.client != null)	{
					// Yes. Let's create a responder object.
					arguments.unshift(new NetServiceProxyResponder(this, methodName));
				}
				else {
					if (typeof(arguments[0].onResult) != "function") {
						mx.remoting.NetServices.trace("NetServices", "warning", 3, "There is no defaultResponder, and no responder was given in call to " + methodName);
						arguments.unshift(new NetServiceProxyResponder(this, methodName));
					}
				}
				if(typeof(this.serviceName) == "function")
					this.serviceName = this.servicename;
				arguments.unshift(this.serviceName + "." + methodName);
				return( this.nc.call.apply(this.nc, arguments));
			};
			return f;
		}
		else
			return null;
	}

	// Ensure that NetServiceProxy instances received via AMF messages get
	public static function registerNetServiceProxy():Boolean {
	    Object.registerClass( "NetServiceProxy", mx.remoting.NetServiceProxy );
		return true;
	}

	private static var init:Boolean = registerNetServiceProxy();
	public var nc:Connection;
	public var serviceName:String;
	public var client:Object;
	
	private var _allowRes:Boolean= false;
}
