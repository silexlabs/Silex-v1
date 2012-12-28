/*
   Title:       XMLConnector.as
   Description: defines the class "mx.data.components.XMLConnector"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	This event is fired just after the results property has been updated.
	
	@helpid	1716
	@tiptext Fired when results property is updated.
*/
[Event("result")] 

/**
	This event is fired when the component status has changed or there are errors.
	
	@helpid	1719
	@tiptext Fired when the status changes or on errors
*/
[Event("status")] 

/**
	This event is fired just before the call is made to the webservice, giving the user
	a chance to tweak the parameters before sending.
	
	@helpid	1718
	@tiptext Fired prior to the web service call
*/
[Event("send")] 

/**
	A Flash Component that can send and receive XML documents. You can provide
	parameters and receive a result.
	
  @class XMLConnector
  @tiptext A component that sends and receives XML documents
  @helpid 1723
  @codehint _xmlc  
*/
[RequiresDataBinding(true)]
[IconFile("XMLConnector.png")]
class mx.data.components.XMLConnector extends mx.data.components.connclasses.RPCCall
{
	/**
	  @tiptext Result of the last HTTP operation
	  @helpid 1717
	*/
	[Bindable("readonly")]
	[ChangeEvent("result")]
	var results: XML;

	/**
	  @tiptext Data that will be sent to the server
	  @helpid 1715
	*/
	[Bindable("writeonly")]
	var params: XML;

	/**
	  @tiptext Will data be sent, or received, or both?
	  @helpid 1713
	*/
	// direction is either 'send', 'receive', or '<anything else>'
	[Inspectable(defaultValue="send/receive",enumeration="send,receive,send/receive",category="other")]
	var direction : String;

	/**
	  @tiptext If true, invalid data will not be sent; if false, invalid data is used
	  @helpid 1720
	*/
	[Inspectable(defaultValue="false",category="other")]
	var suppressInvalidCalls : Boolean;

	/**
	  @tiptext If true, the call will execute even if a call is in progress; if false, not
	  @helpid 1714
	*/
	[Inspectable(defaultValue="true",category="other")]
	var multipleSimultaneousAllowed : Boolean;

	/**
	  @tiptext Set to true to ignore white space
	  @helpid 4700
	*/
	[Inspectable(defaultValue="true",category="other")]
	var ignoreWhite : Boolean;

	/**
	  @tiptext The URL that is used when doing HTTP operations
	  @helpid 1722
	*/
	[Inspectable(defaultValue="",category="main")]
	var URL : String;

	function XMLConnector()
	{
		//trace("XMLConnector constructor");
	}

	/**
	  @tiptext Initiates an HTTP request that sends and/or receives XML data
	  @helpid 1721
	*/
	function trigger()
	{
		_global.__dataLogger.logData(this, "XMLConnector Triggered, <URL>", this);
		_global.__dataLogger.nestLevel++;
		
		if (this.triggerSetup(this.direction != "receive"))
		{	
			if (this.params != null)
			{
				if (this.direction == "receive")
				{
					_global.__dataLogger.logData(this, "Warning: direction is 'receive', but params are non-null: <params>",
						this, mx.data.binding.Log.WARNING);
				}
				else
				{			
					if (!(this.params instanceof XML))
					{
						notifyStatus("Fault", {faultcode: "XMLConnector.Not.XML", faultstring: "params is not an XML object"});
						return;
					}
					
					if (this.params.status != 0)
					{
						notifyStatus("Fault", {faultcode: "XMLConnector.Parse.Error",
							faultstring: "params had XML parsing error " + this.params.status});
						return;
					}
				}
			}
			else
			{
				if (this.direction != "receive")
				{
					notifyStatus("Fault", {faultcode: "XMLConnector.Params.Missing",
						faultstring: "Direction is 'send' or 'send/receive', but params are null"});
					return;
				}
			}

			var p = this.params;
			if ((p == null) || (this.direction == "receive"))
			{
				p = new XML();
			}

			var result = new XML();
			result.ignoreWhite = this.ignoreWhite;
			result.xmlconnector = this;
			result.needData = (this.direction != "send");
			result.onData = function(data)
			{
				//trace("result.onData -- " + data);

				if (this.needData)
				{								
					if (data == undefined)
					{
						// oops - we were expecting some data!
						this.xmlconnector.notifyStatus("Fault", {faultcode: "XMLConnector.No.Data.Received",
							faultstring: "Was expecting data from the server, but none was received"});
					}
					else
					{
						this.parseXML(data);

						if (this.status != 0)
						{
							this.xmlconnector.notifyStatus("Fault", {faultcode: "XMLConnector.Results.Parse.Error",
								faultstring: "received data had an XML parsing error " + this.status});
						}
						else
						{				
							this.xmlconnector.setResult(this);
							//this.validateProperty("results");
						}						
					}
				}

				this.xmlconnector.bumpCallsInProgress(-1);
			};
			
			_global.__dataLogger.logData(this, "Invoking XMLConnector <me.URL>(<params>)", {me: this, params: p});
			p.contentType = "text/xml";
			p.sendAndLoad(this.URL, result);
			bumpCallsInProgress(1);
		}
		
		_global.__dataLogger.nestLevel--;
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

