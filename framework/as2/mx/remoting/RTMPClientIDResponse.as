//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.remoting.debug.commands.AddRTMPClient;

/**
  responder class for getting RTMP client id
*/
class mx.remoting.RTMPClientIDResponse extends Object {
	
	function RTMPClientIDResponse(cs:String, nc:Object) {
		super();
		_connectString = cs;
		_nc = nc;
	}
	
	function onResult(cid:Number):Void {
		_nc._clientId = cid;
		mx.remoting.debug.NetDebug.getNetDebug().sendCommand(new AddRTMPClient(_connectString, cid));
	}
	
	private var _nc:Object;
	private var _connectString:String;
}