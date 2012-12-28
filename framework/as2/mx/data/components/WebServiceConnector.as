/*
   Title:       WebServiceConnector.as
   Description: defines the class "mx.data.components.WebServiceConnector"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/


/**
	This event is fired just after the results property has been updated.
	
	@helpid	1703
	@tiptext Fired when results property is updated.
*/
[Event("result")] 

/**
	This event is fired when the component status has changed or there are errors.
	
	@helpid	1706
	@tiptext Fired when the status changes or on errors
*/
[Event("status")] 

/**
	This event is fired just before the call is made to the webservice, giving the user
	a chance to tweak the parameters before sending.
	
	@helpid	1705
	@tiptext Fired prior to the web service call
*/
[Event("send")] 

/**
	A Flash Component that can call a Web Service Method. You can provide
	parameters and receive a result.
	
  @class WebServiceConnector
  @tiptext	A component that calls a Web Service method
  @helpid	1711
  @codehint _wsc    
*/
[RequiresDataBinding(true)]
[IconFile("WebServiceConnector.png")]
class mx.data.components.WebServiceConnector extends MovieClip
{
	/**
	  @tiptext Result of the last successfull web service call
	  @helpid 1704
	*/
	[Bindable("readonly")]
	[ChangeEvent("result")]
	[WebServiceConnector]
	var results;

	/**
	  @tiptext Data that will be sent to the server
	  @helpid 1702
	*/
	[Bindable("writeonly")]
	var params;

	/**
	  @tiptext The URL of the WSDL file that defines a web service
	  @helpid 1710
	*/
	[Inspectable(defaultValue="",category="main-1",type="Web Service Url")]
	var WSDLURL : String;
	
	/**
	  @tiptext Name of an operation within the service defined by WSDLURL
	  @helpid 1701
	*/
	[Inspectable(defaultValue="",category="main-2",type="Web Service Operation")]
	var operation : String;
	
	// Timeout removed, because it doesn't work.
	/*
	  @tiptext How many seconds to wait for the server to respond
	  @helpid 4600
	*/
	//[Inspectable(name="timeout (seconds)",defaultValue="",category="other")]
	//var timeout : String; // should be a number, but we also need to allow ""
	
	/**
	  @tiptext If true, invalid data will not be sent; if false, invalid data is used
	  @helpid 1707
	*/
	[Inspectable(defaultValue="false",category="other")]
	var suppressInvalidCalls : Boolean;

	/**
	  @tiptext If true, the call will execute even a call is in progress; if false, not
	  @helpid 1700
	*/
	[Inspectable(defaultValue="true",category="other")]
	var multipleSimultaneousAllowed : Boolean;

	// these are functions that are mixed-in by the events and bindings code
	var refreshAndValidate:Function;

	// private properties
	var service;
	static var allServices : Array = new Array();
	var callsInProgress : Number = 0;
	var realWSDLURL: String;
	
	function setWSDLURL(url)
	{
		//trace("setWSDLURL " + url);
		this.realWSDLURL = url;
			
		// Find an existing webservice object, or create a new one.
		this.service = allServices[this.realWSDLURL];
		if (this.service == null)
		{
			_global.__dataLogger.logData(this, "Creating WebService object for <WSDLURL>", {WSDLURL: WSDLURL});
			this.service = new mx.services.WebService(this.realWSDLURL);

			allServices[this.realWSDLURL] = this.service;
			var f = function(fault)
			{	
				this.lastFault = fault;
			};
			this.service.onFault = f;
			this.service.lastFault = null;
		}
		else
		{
			_global.__dataLogger.logData(this, "Will use already-created WebService object for <WSDLURL>", {WSDLURL: WSDLURL});
		}
	}
	
	function getWSDLURL()
	{
		return this.realWSDLURL;
	}
		
	function WebServiceConnector()
	{
		//trace("WebServiceConnector constructor");
		
		// Make this object able to send events to listeners.
		mx.events.EventDispatcher.initialize(this);

		// !!@ temporary
		mx.data.binding.ComponentMixins.initComponent(this);
		
		// do the initialization for the WSDL URL that was defined at author-time (if there was one)
		if ((this.WSDLURL.length > 0) == true)
			this.setWSDLURL(this.WSDLURL);

		// Define getter/setter functions for the WSDLURL
		this.addProperty("WSDLURL", getWSDLURL, setWSDLURL);
		
		// this component has no runtime visual appearance
		this._visible = false;
	}
	
	/*
	function checkTimeout()
	{	
		if (this.timeout == "")
		{
			this.timeout = null;
		}
		else if (this.timeout != null)
		{
			var t = new Number(this.timeout);
			t = t.valueOf();
			if (t.toString() == "NaN") // for some reason, 't == Number.NaN' doesn't work!!
			{
				_global.__dataLogger.logData(this, "Timeout value '<timeout>' is not legal. Timeout will not be used.", {timeout: timeout});
				this.timeout = null;
			}
			else
			{
				this.timeout = t;
			}
		}
	}
	*/
	
	function notifyInfo()
	{
		notifyStatus("StatusChange", {callsInProgress: callsInProgress}); 
	}
	
	function bumpCallsInProgress(amount : Number)
	{
		callsInProgress += amount;
		notifyInfo();
	}

	function notifyStatus(code: String, data)
	{
		//trace("in notifyStatus, calling myDispatchEvent");
		//var event = new mx.data.components.WebServiceConnectorStatusEvent(this, code, data);
		//trace("in notifyStatus: " + event);
		//trace("in notifyStatus: " + mx.data.binding.ObjectDumper.toString(event));

		var event = new Object();
		event.type = "status";
		event.code = code;
		event.data = data;
		this.dispatchEvent(event);
	}

	function setResult(r, pendingCall)
	{
		//Debug.trace("setResult", pendingCall);
		if (Object(this).__schema.multiPartResult)
		{
			// The results messages from this webservice method has more than 1 part.
			// This is kind of unusual, but sometimes happens.
			// The problem: when mx.services.WebService gives a result (the parameter "r")
			// it uses the first part as the result. If you want the result to 
			// be an object containing all the parts, you have to do the following code....
			
			// But first, here's a workaround for bug #67922 - if you make a service call *before* 
			// the WSDL fetch has completed, then the callback object ("pendingCall") is not
			// an object of class mx.services.PendingCall. 
			if (typeof(pendingCall.getOutputParameters) != "function")
				pendingCall.getOutputParameters = mx.services.PendingCall.prototype.getOutputParameters;

			var resultsSchema = mx.data.binding.FieldAccessor.findElementType(Object(this).__schema, "results");
			var allResults = pendingCall.getOutputParameters();
			//Debug.trace(this, "allResults", allResults);

			var newResult = new Object();
			var resultsLen = allResults.length;
			for (var i=0; i<resultsLen; i++)
			{
				var oneResult = allResults[i];
				newResult[oneResult.name] = oneResult.value;
			}

			this.results = newResult;
			//Debug.trace(this, "results", results);
		}
		else
		{
			this.results = r;
		}
		this.dispatchEvent({type: "result"});
	}

	/**	
	@tiptext Calls the web service operation
	@helpid 1709
	*/
	
	function trigger()
	{
		_global.__dataLogger.logData(this, "WebService Triggered, <WSDLURL>, <operation>", {WSDLURL: WSDLURL, operation: operation});
		_global.__dataLogger.nestLevel++;
		if (this.service == null)
		{
			//trace("calling notifyStatus");
			notifyStatus("WebServiceFault", {faultcode: "No.WSDLURL.Defined",
				faultstring: "the WebServiceConnector component had no WSDL URL defined"});
			_global.__dataLogger.nestLevel--;
			return;
		}

		if (this.service.lastFault != null)
		{
			notifyStatus("WebServiceFault", this.service.lastFault);
			_global.__dataLogger.nestLevel--;
			return;
		}
		
		if (!multipleSimultaneousAllowed && (callsInProgress > 0))
		{	
			notifyStatus("CallAlreadyInProgress", callsInProgress);
			_global.__dataLogger.nestLevel--;
			return;
		}
		
		//checkTimeout();
		
		// You can use the royale proxy to get outside the browser sandbox
		// not needed for use in authoring.
		// !!@ make this a Inspectable component parameter.
		//var proxyURL = "http://localhost:9100/royale/flashproxy";
				
		// Could optionally handle wsdl loading and web service instantiation here 
		// but choosing not to do so in this case.

		// if any headers are needed, such as for security or transaction aspects,
		// they could be added here: stockService.setHeaders(headers)

		//trace("pt ... " + this.params.translationmode);
		
		// You can build the parameter list in any of these ways...		
		//this.params = {foo: "94103"};
		//this.params = ["94103"];
		//this.params = new Array(); this.params.push("02111");
		
		// Give the user a chance to tweak the parameters
		this.dispatchEvent({type: "send"});

		// Execute all the bindings to our parameters,
		// and see if the parameter list is valid.
		if (!this.refreshAndValidate("params") && this.suppressInvalidCalls)
		{
			// The params were invalid, and we're supposed to suppress the call.
			notifyStatus("InvalidParams");
			_global.__dataLogger.nestLevel--;
			return;
		}

		// make a copy of the parameter list, in correct parameter order.
		var args = new Array();

		if (this.params instanceof Array)
		{
			// this.params is an array with numerical indices.
			//trace("parameters is an array");
			for (var i = 0; i < this.params.length; i ++)
			{
				args.push(this.params[i]);
			}
			_global.__dataLogger.logData(this, "Parameters to <operation> will be sent in the order you've provided", 
				{WSDLURL: WSDLURL, operation: operation});
		}
		else
		{
			// this.params is an object with named fields. We'll
			// create a parameter list in the correct order.
			var paramSchema = mx.data.binding.FieldAccessor.findElementType(Object(this).__schema, "params");
			if (paramSchema != null)
			{
				//trace("param schema: " + mx.data.binding.ObjectDumper.toString(paramSchema));
				for (var i = 0; i < paramSchema.elements.length; i++)
				{
					var name = paramSchema.elements[i].name;
					args.push(this.params[name]);
				}
				_global.__dataLogger.logData(this, "Parameters  to <operation> will be sent in the order defined in the schema", 
					{WSDLURL: WSDLURL, operation: operation});
			}
			else
			{
				// !!@ what shall we do. We have no way of knowing the parameter order.
				// Possible fix - modify the WebService class so that it can accept
				// parameter lists in the form {foo: 123, bar: 987}.
				for (var i in this.params)
				{
					//trace("arg[" + i + "]=" + this.params[i]);
					args.push(this.params[i]);
				}
				_global.__dataLogger.logData(this, 
					"No schema information available - parameters to <operation> will be sent in a unknown order", 
					{WSDLURL: WSDLURL, operation: operation});
			}			
		}
		
		// do the method call
		_global.__dataLogger.logData(this, "Invoking <operation>(<params>)", 
			{WSDLURL: WSDLURL, operation: operation, params: args});
		/*
		if (this.timeout != null)
		{
			this.service._timeout = this.timeout * 1000;
			//trace("setting timeout = " + (this.timeout * 1000));
		}
		*/
		var callback = this.service.stub.invokeOperation(this.operation, args);

		if (callback == null)
		{
			if (this.service.lastFault != null)
			{
				notifyStatus("WebServiceFault", this.service.lastFault);
				this.service.lastFault = null;
			}
			else
			{
				notifyStatus("WebServiceFault", {faultcode: "Unknown.Call.Failure",
					faultstring: "WebService invocation failed for unknown reasons"});
			}
		}
		else
		{
			// Set up the callback object...
			this.bumpCallsInProgress(1);
			callback.WebServiceConnector = this;
			callback.onResult = function(result)
			{
				//trace("Web Service Result: " + mx.data.binding.ObjectDumper.toString(result));
				this.WebServiceConnector.setResult(result, this);
				this.WebServiceConnector.bumpCallsInProgress(-1);
			};
			callback.onFault = function(fault)
			{
				this.WebServiceConnector.notifyStatus("WebServiceFault", fault);
				this.WebServiceConnector.bumpCallsInProgress(-1);
			};
		}
		_global.__dataLogger.nestLevel--;
	} 

	// onUpdate gets called when this component is being used as a live preview swf in Flash Authoring
	function onUpdate()
	{
		this._visible = true;
	}

	// Following are declarations for functions we inherit from the event dispatcher mixin.
	/**
	* @private
	* @see mx.events.EventDispatcher
	*/
	var dispatchEvent:Function;

	/**
	* @see mx.events.EventDispatcher
	* @tiptext Adds a listener for an event
	* @helpid 3958
	*/
	var addEventListener:Function;

	/**
	* @see mx.events.EventDispatcher
	*/
	var removeEventListener:Function;
};

