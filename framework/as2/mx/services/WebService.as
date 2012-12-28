// ------------------------------------------------------------
// WEB SERVICE APIs
// ------------------------------------------------------------
// Simple wrapper around WSDL, XML Schema, and SOAP libraries.
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------

// -----------------------------------------------------------------
// WEB SERVICE
// -----------------------------------------------------------------

import mx.services.Log;
import mx.services.Namespace;
import mx.services.SOAPCall;
import mx.services.WebServiceProxy;

/**
  @helpid 1742 
  @tiptext provide the entry point for calling a webservice
*/
dynamic class mx.services.WebService
{
    var _name : String;
    var _portName : String;
    var _description : String;
    var _proxyURI : String;
    var _endpointReplacementURI : String;
    var _timeout : Number;
    var gotWSDL : Boolean;
    var stub : WebServiceProxy;
    var __resolve:Function;

	/**
	  @helpid  1602
	  @tiptext	Creates a new instance of a WebService object
	*/
    public function WebService(wsdlLocation : String,
                               logObj : Log,
                               proxyURI : String,
                               endpointProxyURI : String,
                               serviceName : String,
                               portName : String)
    {
        Namespace.setup();

        // init to avoid resolution through __resolve
        this._name = serviceName;
        this._portName = portName;
        this._description = null;
        this._proxyURI = proxyURI;
        this._endpointReplacementURI = endpointProxyURI;
        this._timeout = -1;
        this.gotWSDL = false;
        this.stub = new WebServiceProxy(this, wsdlLocation, logObj);

        // Define __resolve for now, so we can queue invocations without
        // knowing anything about the service.  We'll remove this once the
        // WSDL gets parsed.
        this.__resolve = function(methodName)
        {
            return function()
            {
                return this.stub.invokeOperation(methodName, arguments);
            };
        };
    }

	/**
	  @helpid	1741
	  @tiptext  returns the specified SOAP call
	*/
    public function getCall(operationName) : SOAPCall
    {
        return this.stub.getCall(operationName);
    }

	/**
	  @helpid	1739
	  @tiptext  this method will be called once the WSDL has been parsed and the proxy created
	*/
    function onLoad(wsdl)
    {
        // this method will be called once the WSDL has been parsed and
        // the proxy created. It is meant to be overridden.
    }

	/**
	  @helpid	1740
	  @tiptext  this method will be called if the WSDL cannot be parsed and the proxy cannot be created
	*/
    function onFault(fault)
    {
        // this method will be called if the WSDL cannot be parsed and
        // the proxy cannot be created. It is meant to be overridden.
    }
}

