//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
Provides a default implementation of the Responder API.
Results and faults are sent to the trace output.
*/
class mx.rpc.DefaultResponder implements mx.rpc.Responder
{
	public function DefaultResponder(t:MovieClip)
	{
	    target = t;
	}

	function get target():MovieClip
	{
	    return __target;
	}

	function set target(t:MovieClip):Void
	{
	    __target = t;
	}

	function onResult( event:mx.rpc.ResultEvent ):Void
    {
        trace("RPC Result: " + event.result);
    }

	function onFault( event:mx.rpc.FaultEvent ):Void
    {
        trace("RPC Fault: " + event.fault.faultstring);
    }

    private var __target:MovieClip;
}