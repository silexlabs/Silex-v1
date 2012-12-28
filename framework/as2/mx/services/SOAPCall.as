// ------------------------------------------------------------
// SOAP Call and Response mechanism for Flash.
//
// Objects defined in this file: SOAPheader, SOAPParameter,
// SOAPFault, and SOAPCall.
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------

// ---------
// SOAP Call
//
// This class represents a *description* of a particular WSDL/SOAP operation.
// It contains all the information needed (style, parameters, etc) to invoke
// the operation in question, and an asyncInvoke() method which does just
// that.  Note : all the actual work of encoding/decoding and maintaining state
// for a given call is taken care of by the PendingCall class below.  This
// allows multiple active calls to the same remote operation.
// ---------

import mx.services.Log;
import mx.services.PendingCall;
import mx.services.SchemaVersion;
import mx.services.SOAPConstants;
import mx.services.SOAPFault;

/**
  @helpid 1743 
  @tiptext provides a SOAP call envelope
*/
class mx.services.SOAPCall
{
    // Concurrency values
    static var MULTIPLE_CONCURRENCY = 0;
    static var SINGLE_CONCURRENCY   = 1;
    static var LAST_CONCURRENCY     = 2;

    var operationName;
    public var targetNamespace:String;
    public var endpointURI:String;
    var parameters;
    var timeout;
    var version;
    public var schemaContext;
    var schemaVersion;
    public var soapConstants:SOAPConstants;
    var log:Log;
	/**
	  @helpid	1736
	  @tiptext  indicates if the decoding should be performed on an as needed basis
	*/
    var doLazyDecoding:Boolean;
	/**
	  @helpid	1735
	  @tiptext  indicates if the decoding should be performed
	*/
    var doDecoding:Boolean;
    public var operationStyle;
    public var useStyle;
    public var encodingStyle:String;
    public var actionURI:String;
    var wsdlOperation;
    var initialized:Boolean = false;
    var elementFormQualified:Boolean;
    var useLiteralBody:Boolean = false; // Are we using raw XML for the body?

    var currentlyActive:PendingCall;    // Currently active call
	/**
	  @helpid	1737
	  @tiptext  indicates what type of concurrency is allowed
	*/
    var concurrency:Number;         // My concurrency setting

    public var request:Object;

    // Placeholders for handlers
    var onResult:Function;
    var onFault:Function;

    public function SOAPCall(operationName : String, targetNamespace : String,
                             endpointURI : String, logObj : Log,
                             operationStyle : String, useStyle : String,
                             encodingStyle : String, soapAction : String,
                             soapVersion, schemaContext)
    {
        this.log = logObj;
        this.log.logInfo("Creating SOAPCall for " + operationName, Log.VERBOSE);
        this.log.logDebug("SOAPCall endpoint URI: " + endpointURI);

        this.operationName = operationName;
        this.targetNamespace = targetNamespace;
        this.endpointURI = endpointURI;
        this.parameters = new Array();
        this.concurrency = MULTIPLE_CONCURRENCY;

        // No explicit timeout value by default.  The user can set this, and
        // thus engage a timer for this # of milliseconds on each call.  If the
        // timer fires before the call returns, a fault will be generated.
        this.timeout = undefined;

        this.version = (soapVersion == undefined) ? SOAPConstants.DEFAULT_VERSION : soapVersion;
        this.schemaContext = schemaContext;
        var schemaVersion = schemaContext.schemaVersion;
        this.schemaVersion = (schemaVersion == undefined) ? SchemaVersion.getSchemaVersion(SchemaVersion.XSD_URI_2001) : schemaVersion;
        this.soapConstants = SOAPConstants.getConstants(this.version);

        // This switch controls whether we hand back fully decoded Arrays and
        // RowSets, or whether we "lazily" decode them as needed via a proxy object.
        // This is the default, can also be overridden on an individual call.
        this.doLazyDecoding = true;

        // Should we decode the body at all, or just hand back an array of its child nodes?
        // (note that we'll still process headers regardless)
        // This is the default, can also be overridden on an individual call.
        this.doDecoding = true;

        this.operationStyle = (operationStyle == undefined)
            ? SOAPConstants.DEFAULT_OPERATION_STYLE
            : operationStyle;

        this.useStyle = (useStyle == undefined)
            ? SOAPConstants.DEFAULT_USE
            : useStyle;

        this.encodingStyle = (encodingStyle == undefined)
            ? this.soapConstants.ENCODING_URI
            : encodingStyle;

        this.actionURI = ((soapAction == undefined) || (soapAction == ""))
            ? this.targetNamespace + "/" + this.operationName
            : soapAction;

        this.log.logInfo("Successfully created SOAPCall", Log.VERBOSE);
    }

    public function addParameter(soapParam)
    {
        this.parameters.push(soapParam);
    }

    public function invoke()
    {
        if (request == undefined) {
            // TODO : fault!
            return undefined;
        }

        return asyncInvoke(request, "onLoad");
    }

    //
    // asyncInvoke - create a new PendingCall object, set up its outgoing SOAP
    // envelope, and send it over the wire to our endpoint URI.  Return the
    // PendingCall so the user can define callback methods, etc.
    //
    public function asyncInvoke(args, callbackMethod)
    {
        // Create the callback descriptor we're going to hand back to the caller.
        var callback = new PendingCall(this);

        if (!initialized) {
            wsdlOperation.parseMessages();

            if (wsdlOperation.input.isWrapped) {
                operationStyle = SOAPConstants.WRAPPED_STYLE;
                targetNamespace = wsdlOperation.input.targetNamespace;
                elementFormQualified = wsdlOperation.input.isQualified;
            }

            if (wsdlOperation.wsdl.fault != undefined) {
                this.triggerDelayedFault(callback, wsdlOperation.wsdl.fault);
                return callback;
            }

            var inputParams = wsdlOperation.input.parameters;
            var numIn = inputParams.length;
            for (var i=0; i<numIn; i++)
            {
                addParameter(inputParams[i]);
            }

            var outputParams = wsdlOperation.output.parameters;
            var numOut = outputParams.length;
            for (var i=0; i<numOut; i++)
            {
                addParameter(outputParams[i]);
            }

            initialized = true;
        }

        this.log.logInfo("Asynchronously invoking SOAPCall: " + this.operationName);

        var startTime;
        if (this.log.level > Log.BRIEF)
            startTime = new Date();

        if (this.concurrency != MULTIPLE_CONCURRENCY && currentlyActive != undefined) {
            if (this.concurrency == SINGLE_CONCURRENCY) {
                // We need to throw a fault, so let them have a chance to set up
                // the fault handler first.
                var fault = new SOAPFault("ConcurrencyError", "Attempt to call method " + this.operationName + " while another call is pending.  Either change concurrency options or avoid multiple calls.");
                this.triggerDelayedFault(callback, fault);

                return callback;
            } else {
                // Concurrency is last, so cancel the last call and do the new one
                currentlyActive.cancel();
            }
        }

        // Keep track of the last active call....
        currentlyActive = callback;
        if (this.concurrency == SINGLE_CONCURRENCY)
            callback.isSingleCall = true;

        callback.encode();

        callback.callbackMethod = callbackMethod;   // Callback method

        // Populate parameters
        callback.setupParams(args);

        // prepare response object
        var response = new XML();
        response.ignoreWhite = true;
        response.callback = callback;
        response._startTimeMark = startTime;

        // create the async response mechanism
        response.onData = function(src)
        {
            var cb = this.callback;
			delete(this.callback); //Fix for bug#74567 - Circular reference causes memory leak

            if (cb.isSingleCall) {
                // We're done, so clear out the active marker
                cb.myCall.currentlyActive = undefined;
            }

            // If there's a timeout, cancel it, since we have data.
            if (cb.timerID != undefined) {
                clearInterval(cb.timerID);
                cb.timerID = undefined;
            }

            // If cancelled, stop here
            if (cb.cancelled)
                return;

            var logLevel = cb.log.level;

            if (logLevel > Log.BRIEF)
            {
                this._networkTimeMark = new Date();
                this._networkTime = Math.round(this._networkTimeMark - this._startTimeMark);
                cb.log.logInfo("Received SOAP response from network [" + this._networkTime + " millis]");
            }

            if (src != undefined)
            {
                this.parseXML(src);
                this.loaded = true;

                if (logLevel > Log.BRIEF)
                {
                    this._parseTimeMark = new Date();
                    this._parseTime = Math.round(this._parseTimeMark - this._networkTimeMark);
                    cb.log.logInfo("Parsed SOAP response XML [" + this._parseTime + " millis]");
                }
            }
            else
            {
                this.loaded = false;
            }

            cb.decode.call(cb, this.loaded, this, cb.callbackMethod);
        };

        callback.response = response;

        if (this.timeout != undefined) {
            callback.setTimeout(this.timeout);
        }

        // fire message
        callback.request.sendAndLoad(this.endpointURI, response, "POST");

        this.log.logInfo("Sent SOAP Request Message", Log.VERBOSE);

        // return the PendingCall object
        return callback;
    }

    private function triggerDelayedFault(callback, fault)
    {
        callback.fault = fault;
        callback.handleDelayedFault = function()
        {
            clearInterval(this.timerID);  // only once
            this.timerID = undefined;
            this.__handleFault(this.fault);
            this.onFault(this.fault);
        };

        callback["timerID"] = setInterval(function() { callback.handleDelayedFault(); }, 50);  // 5 ms
    }
}
