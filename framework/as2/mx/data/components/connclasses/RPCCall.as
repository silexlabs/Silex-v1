/*
   Title:       RPCCall.as
   Description: defines the class "mx.data.components.connclasses.RPCCall"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An abstract Flash Component that can invoke an RPC call of some kind. You can provide
	parameters and receive a result.

	You need to make a subclass of this class.
	
  @class RPCCall
*/
class mx.data.components.connclasses.RPCCall extends MovieClip
{
	[Bindable("readonly")]
	[ChangeEvent("result")]
	var results;

	[Bindable("writeonly")]
	var params;

	[Inspectable(defaultValue="false")]
	var suppressInvalidCalls : Boolean;

	[Inspectable(defaultValue="true")]
	var multipleSimultaneousAllowed : Boolean;

	// these are functions that are mixed-in by the events and bindings code
	var dispatchEvent:Function;
	var refreshAndValidate:Function;

	// private properties
	var callsInProgress : Number = 0;
			
	function RPCCall()
	{
		//trace("RPCCall constructor");
		
		// Make this object able to send events to listeners.
		mx.events.EventDispatcher.initialize(this);

		// !!@ temporary
		mx.data.binding.ComponentMixins.initComponent(this);
		
		// this component has no runtime visual appearance
		this._visible = false;
	}

	function bumpCallsInProgress(amount : Number)
	{
		callsInProgress += amount;
		notifyStatus("StatusChange", {callsInProgress: callsInProgress}); 
	}
	
	function notifyStatus(code: String, data)
	{
		var event = new Object();
		event.type = "status";
		event.code = code;
		event.data = data;
		this.dispatchEvent(event);
	}

	function setResult(r)
	{
		this.results = r;
		this.dispatchEvent({type: "result"});
	}
		
	function triggerSetup(needsParams: Boolean) : Boolean
	{
		//_global.__dataLogger.logData(this, "RPCCall Triggered");
		//_global.__dataLogger.nestLevel++;
		
		if (!multipleSimultaneousAllowed && (callsInProgress > 0))
		{	
			notifyStatus("CallAlreadyInProgress", callsInProgress);
			//_global.__dataLogger.nestLevel--;
			return false;
		}
		
		// Give the user a chance to tweak the parameters, or do any other preparations
		this.dispatchEvent({type: "send"});
		
		// Execute all the bindings to our parameters,
		// and see if the parameter list is valid.
		if (needsParams && !this.refreshAndValidate("params") && this.suppressInvalidCalls)
		{
			// The params were invalid, and we're supposed to suppress the call.
			notifyStatus("InvalidParams");
			//_global.__dataLogger.nestLevel--;
			return false;
		}

		return true;
	} 

	// onUpdate gets called when this component is being used as a live preview swf in Flash Authoring
	function onUpdate()
	{
		this._visible = true;
	}
};

