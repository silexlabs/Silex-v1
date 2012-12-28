//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.NetServiceProxy;


/**
	Connection Class extends NetConnection
	Manages a bidirectional connection between the Flash Player and the Flash Remoting service.
	The Service methods use the Connection object to invoke methods on servers and return results. 
	@tiptext	Manages connection between the Flash Player and the Flash Remoting service
	@helpid		4436
*/
class mx.remoting.Connection extends NetConnection 
{
	
//#include "RemotingComponentVersion.as"

	function Connection() {
		super();
	}
	
	/**
		Creates a Flash Remoting service object, which allows access to application server functions
		@param		serviceName			String containing the name of the service to call
		@param		client				Object	responder for method call results and status
		@return		NetServiceProxy		instance of the proxy for the network client, local client and service name specified.
		@tiptext	Returns a proxy to the specified service
		@helpid		4437
	*/
	public function getService(serviceName:String, client:Object):NetServiceProxy 
	{
		var result:NetServiceProxy = new NetServiceProxy(this, serviceName, client);
		return( result );
	}

	/**
		Defines a set of credentials to be presented to the server on all subsequent requests. SetCredentials can be called more than once. 
		@param		userId		String containing the user id to use
		@param		password	String containing the user password to use
		@tiptext	Specifies the security credentials used for connecting to a service
		@helpid		4438
	*/
	public function setCredentials(userId:String, password:String ):Void  
	{
		addHeader("Credentials", false, {userid: userId, password: password});
	}

	/**
		  Creates a new NetConnection, similar to the old connection except it doesn't have the headers.
		  @return		Connection	Object	The Connection created
		  @tiptext		Creates a copy of this connection but without current headers
		  @helpid		4439
	*/
	public function clone():Connection 
	{
		var nc = new Connection();
		nc.connect(uri);
		return( nc );
	}
	
	/**
	  Retrieves the Connection object's debug identifier. Note:this method will only return a value if the 
	  NetDebug.initialize() method has been previously called.
	  
	  @return	Number containing the ID
	  @tiptext	Returns assigned debug id
	  @helpid	4440
	*/
	public function getDebugId():String {
		return( null );
	}
	
	/**
	  Returns the current debug configruation. Note: this method will only return a value if the 
	  NetDebug.initialize() method has been previously called.
	  
	  @return	NetDebugConfig current debug configuration values
	  @tiptext	Returns the current debug configuration
	  @helpid 	4503
	*/
	public function getDebugConfig()/*:mx.remoting.debug.NetDebugConfig*/ {
		// provided by ConnectionMixin
		return( null );
	}
	
	/**
		this Connection object's debug identifier. Note:this method will only return a value if the 
		NetDebug.initialize() method has been previously called.
		@tiptext	Sets this Connection object's debug identifier
		@helpid 	4441
	*/
	public function setDebugId( id:String ):Void {
		// provided by ConnectionMixin
	}
	
	/**
	  Attaches debug methods and updates the configuration
	*/
	public function updateConfig():Void {
		// provided by ConnectionMixin
	}
	
	public var setupRecordSet:Function; // provided by ConnectionMixin
	
	/**
	   Invokes a command or method on the server. You must create a server-side function to execute the remote method
	   
	   @param	remoteMethod String
	   @param	resultObject String
	   @tiptext	Invokes command or method on the server
	   @helpid	4442
	*/
	public function call( /*remoteMethod:String, resultObject:Object, [p1..pn]*/ ):Void {
		super.call.apply( super, arguments /*remoteMethod:String, resultObject:Object, [p1..pn]*/ );
	}
	
	/**
	  Makes the URL previously specified with connect() into a null value, thereby removing the connection 
	  configuration for the remote gateway. Subsequent attempts to call Flash Remoting MX using the 
	  Connection object fail. After using the Connection.close method, you must call connect() to define a new URL. 
	  
	  @tiptext	Removes the connection configuration for the remote gateway
	  @helpid	4443
	*/
	public function close():Void {
		super.close();
	}
	
	/**
	  Defines the Flash Remoting URL that is used during Flash Remoting service function calls. This method 
	  does not communicate with the server. When Flash Remoting MX executes a service function call, it makes 
	  an HTTP or HTTPS connection to the application servers. This connection only persists until the results 
	  of the call are returned to the Flash application. 

	  @param	url String containing the url of the gateway to connect to
	  @tiptext	Configures the connection information for access to the specified gateway
	  @helpid	4444
	*/
	public function connect( url:String ): Boolean {
		return( super.connect( url ));
	}
	
	/**
	  Adds a context header to the Action Message Format (AMF) packet structure. This header is included with 
	  every AMF packet sent over this connection. This method is used by the Connection.setCredentials method; 
	  you do not normally use it directly in Flash applications. 
	  
	  @param	name String containing the name of the header to add
	  @param	mustUnderstand indicates if the server is required to understand and process this header
	  @param	obj Object containing the values for the header
	  @tiptext	Adds a header to the connection which will be sent with any subsequent request
	  @helpid	4445
	*/
	public function addHeader( name:String, mustUnderstand:Boolean, obj:Object ):Void {
		super.addHeader( name, mustUnderstand, obj );
	}
	
	/**
	  Sends a client trace message associated with the Connection to the Net Connection Debugger (NCD). The 
	  trace message includes the connection's Debug ID. Note:this method will only return a value if the 
	  NetDebug.initialize() method has been previously called
	  
	  @param	traceObj Object that will be sent to the NetConnection Debugger
	  @tiptext	Sends client trace message to the NetConnection Debugger
	  @helpid	4446
	*/
	public function trace( traceObj:Object ):Void {
		// provided by ConnectionMixin
	}
	
	
	// url related
	public var uri:String;

	/*
	  Appends a suffix to the existing URL and connects to it.
	  @param	urlSuffix String containing the url suffix to append
	*/
	private function AppendToGatewayUrl(urlSuffix:String):Void {
		__urlSuffix = urlSuffix;
		if (__originalUrl == null) 
		{
			__originalUrl = uri;
		}
		var u = __originalUrl + urlSuffix;
		connect(u);
	}
	
	/*
		 Method to replace the existing URL with a new one and connect to it.
		 @param		newUrl		String containing the new url from the server
	*/
	private function ReplaceGatewayUrl(newUrl:String):Void {
		connect(newUrl);
	}
	
	/*
		 Called by the player when a RequestPersistentHeader is recieved from the server
		 @param		info	Object containing the name mustUnderstand and data properties
	*/
	private function RequestPersistentHeader(info:Object ):Void 
	{
		//trace("NetConnection_RequestPersistentHeader(" + objectToString(info) + ")");
		addHeader(info.name, info.mustUnderstand, info.data);
	}
	

	private var __originalUrl:String;
	private var __urlSuffix:String;
}