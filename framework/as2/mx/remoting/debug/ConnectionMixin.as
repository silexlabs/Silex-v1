//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.debug.events.*;
import mx.remoting.debug.commands.*;
import mx.remoting.debug.NetDebugConfig;

/**
  This class mixes in the needed functionality the the NetConnection class to 
  support debugging.
  
*/
class mx.remoting.debug.ConnectionMixin extends Object {
	
	//
	// NetConnection proxy setup
	//
	public static function initialize():Boolean {
		var proto = mx.remoting.Connection.prototype;
		var mixProto = ConnectionMixin.prototype;
		if (!proto.netDebugProxyFunctions) {
			proto.netDebugProxyFunctions = true;
			proto.realConnect = proto.connect;
			proto.realCall = proto.call;
			proto.realClose	= proto.close;
			proto.realAddHeader	= proto.addHeader;
			proto.connect = mixProto.netDebugProxyConnect;
			proto.call = mixProto.netDebugProxyCall;
			proto.close	= mixProto.netDebugProxyClose;
			proto.addHeader	= mixProto.netDebugProxyAddHeader;
			proto.attachDebug= mixProto.attachDebug;
			proto.sendDebugEvent= mixProto.sendDebugEvent;
			proto.sendServerEvent= mixProto.sendServerEvent;
			proto.sendClientEvent= mixProto.sendClientEvent;
			proto.addNetDebugHeader= mixProto.addNetDebugHeader;
			proto.updateConfig= mixProto.updateConfig;
			proto.getNetDebug= mixProto.getNetDebug;
			proto.isRealTime= mixProto.isRealTime;
			proto.setupRecordSet= mixProto.setupRecordSet;
			proto.setDebugId= mixProto.setDebugId;
			proto.getDebugId= mixProto.getDebugId;
			proto.getDebugConfig= mixProto.getDebugConfig;
			proto.trace= mixProto.trace;
			return( true );
		}
		return( false );
	}
	
	function attachDebug():Void	{
		if (!_attached) {
			_attached = true;
			_headerAdded = false;
			_configured = false;
			_config = new NetDebugConfig();
			mx.utils.ObjectCopy.copyProperties(_config, getNetDebug().getConfig());
			_protocol = "none";
			_id = String( getNetDebug().addNetConnection(NetConnection( this )));
		}
	}
	
	function sendDebugEvent(eventobj:Object):Boolean {
		// add a protocol entry
		eventobj.protocol = _protocol;
		// add a NetConnection instance id
		eventobj.debugId = _id;
		return( getNetDebug().onEvent(eventobj));
	}
	
	function sendServerEvent(eventobj:Object):Void {
		// set the Url
		eventobj.movieUrl = unescape(_root._url);
		if (!sendDebugEvent(eventobj)) {
			// can't report error in test movie
			//trace("NetConnection.sendServerEvent - Failed to sendDebugEvent");
		}
	}

	function sendClientEvent(eventobj:Object):Void {
		if (_config.m_debug && _config.client.m_debug) {
			if ((_config.client.http && _protocol == "http") ||
				(_config.client.rtmp && _protocol.substr(0,4) == "rtmp")) {			
				if (!sendDebugEvent(eventobj)) {
					// can't report error in test movie
					//trace("NetConnection.sendClientEvent - Failed to sendDebugEvent");
				}
			}
		}
	}
	
	function addNetDebugHeader():Void {
		if (!_headerAdded) {		
			_headerAdded = true;
			if (_config.m_debug && _config.app_server.m_debug && _protocol == "http") {	
				// add our debug header -- tells the server to send back debug info
				// avoid creating a client add header event
				realAddHeader("amf_server_debug", true, _config.app_server);
			} 
			else {	
				// config has been updated to turn off debugging, need to remove header
				realAddHeader("amf_server_debug", true, undefined);
			}
		}
	}

	function updateConfig(config:NetDebugConfig):Void {
		attachDebug();	
		if(( config == null ) && ( !_configured )){
			_configured = true;
			config = mx.remoting.debug.NetDebugConfig.getRealDefaultNetDebugConfig();
			//trace( "applied debug fix..." );
		}
		mx.utils.ObjectCopy.copyProperties(_config, config);
		_headerAdded = false;
	}
	
	function isRealTime():Boolean {
		return (_protocol.substr(0,4) == "rtmp");
	}
	
	function setupRecordSet():Void {
		attachDebug();
		_config.client.http = _config.client.recordset;
	}
	
	// Proxy functions
	function netDebugProxyConnect():Boolean {
		attachDebug();
		// process client side built in debug
		var proto = arguments[0].substr(0,4);
		if (proto == "http" || proto.substr(0,4) == "rtmp") {
			//check wether it's regular rtmp or rtmpT or rtmpS
			if (arguments[0].charAt(4) == ":")
				_protocol = proto;	
			else
				_protocol = arguments[0].substr(0,5);
		} else {
			// default to http
			_protocol = "http";
		}
		sendClientEvent(new NetDebugConnect(arguments));
		// start a realtime trace if necessary
		if (isRealTime()) {
			_connectString = arguments[0];
			getNetDebug().sendCommand(new StartRTMPTrace(arguments[0]));
			var ret = realConnect.apply(this, arguments);
			realCall("@getClientID", new mx.remoting.RTMPClientIDResponse(arguments[0], this));
			return( ret );	
		}
		// do the connect
		return (Boolean)(realConnect.apply(this, arguments));
	}
	
	function netDebugProxyCall():Boolean {
		attachDebug();
		sendClientEvent(new NetDebugCall(arguments));
		addNetDebugHeader();
		if (_config.app_server) {
			// Pass through the call with our wrapper response object
			arguments[1] = new mx.remoting.debug.NetDebugResponseProxy(this, arguments[1]);
			return (Boolean)(realCall.apply(this, arguments));
		} else {
			// No Server debug, just call through without inserting our proxy response object
			return (Boolean)(realCall.apply(this, arguments));
		}
	}
	
	function netDebugProxyClose():Boolean {
		attachDebug();
		sendClientEvent(new NetDebugClose());
		// stop realtime trace if necessary
		if (isRealTime()) {
			getNetDebug().sendCommand(new StopRTMPTrace(_connectString, _clientId));
		}
		var ret = realClose();
		getNetDebug().removeNetConnection(NetConnection( this ));
		return( ret );
	}
	
	function netDebugProxyAddHeader():Boolean {
		//trace( "netDebugProxyAddHeader()" );
		attachDebug();
		sendClientEvent(new NetDebugAddHeader(arguments));
		return (Boolean)(realAddHeader.apply(this, arguments));
	}
	
	//
	// Developer API
	//
	function setDebugId(id:String):Void	{
		attachDebug();
		_id = id;
	}
	
	function getDebugId():String {
		attachDebug();
		return( _id );
	}

	function trace(traceobj:Object):Void {
		attachDebug();
		if (_config.m_debug && _config.client.m_debug && _config.client.trace) {
			sendDebugEvent(new NetDebugTrace(traceobj));
		}
	}

	// Config access functions
	function getDebugConfig():NetDebugConfig {
		attachDebug();
		return( _config );
	}
	
	function getNetDebug():mx.remoting.debug.NetDebug {
		return( mx.remoting.debug.NetDebug.getNetDebug());
	}

	private var realConnect:Function;
	private var realCall:Function;
	private var realClose:Function;
	private var realAddHeader:Function;
	
	private var _config:NetDebugConfig;
	private static var _attached:Boolean=false;
	private var _id:String;
	private var _connectString:String;
	private var _clientId:String;
	private var _protocol:String;
	private var _headerAdded:Boolean;
	private var _configured:Boolean;
}
