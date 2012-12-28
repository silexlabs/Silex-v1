//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.Connection;
import mx.services.Log;

/**
	NetServices Class extends Object
	The NetServices object is a collection of methods that helps you create and use Connection Objects to 
	server side services using Flash Remoting.  

	 @class	NetServices
	 @tiptext A collection of mthods that help you create and use Connection Objects
	 @deprecated
	 @helpid	4459
*/

class mx.remoting.NetServices extends Object 
{
   //#include "RemotingComponentVersion.as"

	/**
		Sets the default URL that Flash Remoting uses when it executes the createGatewayConnection method,
		if no URL has been specified OR gatewayUrl has not been set
		@param		String	url		The default URL to be used in absence of any URL passed in createGatewayConnection or gatewayUrl is not defined
		@returns	nothing
		@tiptext	Sets the default Flash Remoting URL 
		@helpid	4460
	*/
	public static function setDefaultGatewayUrl(url:String):Void 
	{
		//trace("NetServices.setDefaultGatewayUrl " + url);
		defaultGatewayUrl = url;
	}
	
	/**
		User specified gatewayUrl. This over-rides the defaultGatewayUrl. If nothing is specified when
		invoking createGatewayConnection, the default gateway URL is picked up to create a connection.
		@param		String	url		The URL to be set as gateway
		@return		nothing
		@tiptext	user specified gateway URL
		@helpid	4461
	*/
	public static function setGatewayUrl(url:String):Void 
	{
		//trace("NetServices.setGatewayUrl " + url);
		gatewayUrl = url;
	}
	
	/**
	  Creates a Connection object, which is used to make connections to services on the application 
	  server. The Flash application only connects when you actually make a Flash Remoting service 
	  function call.
	  
	  @param	url		String containing the flash remoting gateway url
	  @return	Connection	object with
	  1. specified URL or
	  2. URL specified in the createDefaultGatewayURL if it is invoked prior to this method with a valid url
	  3. URL specified in the createGatewayURL if it it invoked prior to this method with a valid url 
	  @tiptext	creates a Connection object to a specified URL
	  @helpid	4462
	*/
	public static function createGatewayConnection(url:String, infoLogger:Log):Connection 
	{
		logger = infoLogger;
		if (url == undefined)
		{
			// Our first choice: the "gatewayURL" param that got passed to this .swf via the object/embed tag
			// The developer could also set "gatewayUrl" *before* including NetServices.as.
			url = gatewayUrl;
	
			if (url == undefined)
			{
				// our second choice: the default url that the developer said to use
				url = defaultGatewayUrl;		
			}
		}
		
		// See if we were able to find a gateway url to use	
		if (url == undefined)
		{
			// no url. no good.
			mx.remoting.NetServices.trace("NetServices", "warning", 4, "createGatewayConnection - gatewayUrl is undefined");
			logger.logInfo("NetServices: createGatewayConnection - gateway url <"+url+"> is undefined", Log.DEBUG);
			return null;
		}
	
		// We found a gateway URL. Create the NetConnection object and connect to the URL.
		var nc = new Connection();
		nc.connect(url);
	
		//trace("NetServices.createGatewayConnection " + nc);
		__sharedConnections[url] = nc;
		return nc;
	}
	
	/**
	  This method returns any existing connections that have been previously created with the given uri

	  @param	uri		String containing the location of the desired gateway
	  @return	Connection	object which was previously created with the specified uri
	  @tiptext	Returns existing connections
	  @helpid	4463
	*/
	public static function getConnection( uri:String ):Connection {
		return( __sharedConnections[uri] );
	}
	
	/**
	  Returns the hostname (and port) of the URL that contains the current .swf file.
	  there is no trailing "/". returns null if the url is not http://something.
	  example: if the swf url is http://my.foo.com:1234/some/thing/my.swf, this
	  function will return "http://my.foo.com:1234".
	  
	  @return	String containing the host and port name
	  @tiptext	Returns hostname and port of the URL containing the current .swf file
	  @helpid	4464
	*/
	public static function getHostUrl():String 
	{
		if (!NetServices.isHttpUrl(_root._url))
		{
			// this url doesn't start with "http://", I don't know what to do with it.
			mx.remoting.NetServices.trace("NetServices", "warning", 4, "createGatewayConnection - gatewayUrl is invalid");
//			logger.logInfo("NetServices: createGatewayConnection - gateway url <"+gatewayUrl+"> is invalid", Log.DEBUG);
			return null;
		}
		var firstSlashPos:Number = _root._url.indexOf("/", 8);
		if (firstSlashPos < 0)
		{
			// hmmm...
			mx.remoting.NetServices.trace("NetServices", "warning", 4, "createGatewayConnection - gatewayUrl is invalid");
			return null;
		}
		return _root._url.substring(0, firstSlashPos);
	}
	
	/*
		Checks the passed URL and returns a true if the URL passed starts with http/https
		
		@param		String  url	The url to be checked
		@return		Boolean	Returns true if the passed url starts with http/https
		@tiptext	checks whether the URL is "http/https"
	*/
	public static function isHttpUrl(url:String):Boolean {
		// return url.startsWith("http://") || url.startsWith("https://");
		return ((url.indexOf("http://") == 0) || (url.indexOf("https://") == 0));
	}
	
	/**
		Converts a relative URL to a full URL by prepending the host and port name, if the
		URL provided is a non-http one.
	    @return		String	a full URL
		@param		String	url		The URL to be converted
		@tiptext	converts a relative URL to a full URL
		@helpid	4465
	*/
	public static function getHttpUrl(url:String) : String {
	    if (!isHttpUrl(url))
	        url = getHostUrl() + url;

	    return url;
	}

	/*
		Sends a serializable ActionScript object as a client trace event to the Connection Debugger. 
		This trace event does not include connection information

		@param		String	who
		@param		String	severity
		@param		Number	number
		@param		String	message
		@tiptext
	*/
	public static function trace(who, severity, number, message):Void {
		//var fullMessage = who + " " + severity + " " + number + ": " + message;
		//trace(fullMessage);
		traceNetServices(who, severity, number, message);
	}
	
	
	public static var gatewayUrl:String = _root.gatewayUrl; // fix for bug#87385; changed from _global to _root 
	public static var defaultGatewayUrl:String;
	public static var traceNetServices:Function; // mixed in by NetDebug
	public static var logger:Log;
	
	private static var __sharedConnections:Array = new Array();
}

