// -----------------------------------------------------------------
// WEB SERVICE PROXY (ACTIONSCRIPT SERVICE STUB)
// -----------------------------------------------------------------
import mx.services.Log;
import mx.services.PendingCall;
import mx.services.SOAPCall;
import mx.services.SOAPConstants;
import mx.services.SOAPFault;
import mx.services.WebService;
import mx.services.WSDL;

class mx.services.WebServiceProxy
{
    var log:Log;
    var service:WebService;
    var wsdl:WSDL;
    var wsdlURI:String;
    var _servicePortMappings;
    var activePort;
    var callQueue;

    var onFault : Function;

    public function WebServiceProxy(webservice : WebService, wsdlLocation : String, logObj : Log)
    {
        this.log = logObj;
        this.log.logInfo("Creating stub for " + wsdlLocation, Log.VERBOSE);

        // The proxy is not connected until WSDL has
        // asynchronously loaded, and if invocations occur before
        // the proxy is connected they will be queued and invoked
        // immediately after loading is complete.

        // Reference our public-facing service interface
        this.service = webservice;

        // Create a WSDL object from the WSDL URI:
        //   allow any "wsdlURL" value defined in the flashvars
        //   parameter in an HTML Object/Embed tag to override hardcoded
        //   wsdl and proxy settings in the movie
        // TODO : How to get flashvars in AS2?
        //if (wsdlURL != undefined)
        //{
        //    wsdlLocation = this.buildURL(wsdlURL);
        //}

        // Respect proxy settings.  If we have either a service-specific
        // proxy setting or a global proxyURL, adjust the target URL to go
        // through the proxy.  Use Flash Remoting style URLs for now.

        // TODO : How to get flashvars in AS2?
        //var myProxyURI = proxyURL;
        var myProxyURI;

        // Global setting trumps.  If no global, try the service.
        if (myProxyURI == undefined) {
            myProxyURI = this.service._proxyURI;
        }

        if (myProxyURI != undefined)
        {
            wsdlLocation = this.buildURL(myProxyURI) + "?target=" + escape(wsdlLocation);
        }

        this.wsdlURI = this.buildURL(wsdlLocation);

        // log objects, chained together
        var wsdlLog = new Log(this.log.level, "WSDL");
        wsdlLog._parentLog = this.log;
        wsdlLog.onLog = function(txt) { this._parentLog.onLog(txt); };

        // Create the WSDL object, which will cause the object
        // to attempt to load and parse the remote WSDL file
        // located at the wsdlURI location
        this.wsdl = new WSDL(this.wsdlURI, this, wsdlLog);

        // After the WSDL has been parsed, set up service/port
        // mappings and SOAPCall objects based upon it
        this.wsdl.onLoad = function()
        {
            this.serviceProxy.onWSDL();
        };

        this.log.logInfo("Created stub for " + this.wsdlURI, Log.VERBOSE);
    }

    function buildURL(url : String)
    {
        // if the URL does not contain a protocol ("http://" or "file://") then
        // assume that the value should be prepended with the host and port that
        // delivered the movie over HTTP. This allows different hosts on the same
        // domain to be proxy servers and SWF servers, and makes the flashVars
        // object/embed tag a bit more useful.
        var builtURL = url;

        if ((url.indexOf("http://") == -1) && (url.indexOf("https://") ==-1))
        {
            var firstSlashPos = _root._url.indexOf("/", 8);
            if (firstSlashPos != -1)
            {
                builtURL = _root._url.substring(0, firstSlashPos) + url;
            }
        }

        return builtURL;
    }

    function onWSDL()
    {
        var fault = this.wsdl.fault;

        if (fault == undefined)
        {
            // create SOAPCall instances for each operation in each port in each service
            var servicePortMappings = new Object();
            var wsdlServices = this.wsdl.services;
            var numPorts = 0;
            var defaultPortName = null;
            var defaultSvcName = null;
            for (var svcName in wsdlServices)
            {
                var portCallMappings = new Object();
                var wsdlPorts = this.wsdl.services[svcName].ports;
                for (var portName in wsdlPorts)
                {
                    var soapCalls = this.createCallsFromPort(wsdlPorts[portName]);
                    portCallMappings[portName] = soapCalls;
                    if (defaultPortName == undefined) {
                        defaultPortName = portName;
                        defaultSvcName = svcName;
                    }
                    numPorts++;
                }
                servicePortMappings[svcName] = portCallMappings;
            }
            this._servicePortMappings = servicePortMappings;

            // If serviceName / portName were set, respect them
            var svcName = this.service._name;
            var portName = this.service._portName;

            if (svcName == undefined && portName == undefined) {
                // If not, use the default one IF there is exactly one
                if (numPorts == 1) {
                    svcName = defaultSvcName;
                    portName = defaultPortName;
                } else if (numPorts == 0) {
                    fault = new SOAPFault("WSDL.NoPorts", "There are no valid services/ports in the WSDL file!");
                } else {
                    // Otherwise, we have multiple choices and don't know how to resolve them.
                    // Throw a fault.
                    fault = new SOAPFault("WSDL.MultiplePorts", "There are multiple possible ports in the WSDL file; please specify a service name and port name!");
                }
            }

            if (fault == undefined) {
                if (svcName == undefined) {
                    svcName = defaultSvcName;
                }
                if (portName == undefined) {
                    portName = defaultPortName;
                }

                var port = this.setPort(portName, svcName);
                if (port == undefined) {
                    return;
                }

                this.log.logInfo("Set active port in service stub: " + svcName + " : " + portName, Log.VERBOSE);

                // Set a flag indicating the WSDL has been successfully loaded.
                this.service.gotWSDL = true;

                // fire notification event that can be handled by optional developer code
                // "this" will be the WebService instance
                this.service.onLoad.call(this.service, this.wsdl.document);
            }
        }

        if (fault != undefined) {
            // fire error event that can be handled by developer code
            this.service.onFault.call(this.service, fault);
            this.log.logDebug("Service stub found fault upon receiving WSDL: " + fault.faultstring);
        }

        // Shut off the __resolve
        this.service.__resolve = function(operationName) {
            var callback = new PendingCall();
            callback.genSingleConcurrencyFault = function()
            {
                clearInterval(this.timerID);  // only once
                fault = new SOAPFault("Client.NoSuchMethod",
                                          "Couldn't find method '" + operationName + "' in service!");
                this.__handleFault(fault);
                this.onFault(fault);
            };

            callback["timerID"] = setInterval(function() { callback.genSingleConcurrencyFault(); }, 50);  // 5 ms

            return callback;
        };

        // now that the WSDL has been parsed and SOAPCalls created,
        // send any enqueued messages
        this.unEnqueueCalls(fault);
    }

    function setPort(portName : String, serviceName : String)
    {
        var svcName = (serviceName == undefined) ? this.service._name : serviceName;
        var service = this._servicePortMappings[svcName];
        if (service == undefined) {
            this.service.onFault(new SOAPFault("Client.NoSuchService", "Couldn't find service '" + svcName + "'"));
            return;
        }

        var newPort = this._servicePortMappings[svcName][portName];
        if (newPort == undefined) {
            this.service.onFault(new SOAPFault("Client.NoSuchPort",
                    "Couldn't find a matching port (service = '" + svcName + "', port = '" +
                    portName + "')"));
            return;
        }

        // When we set a new port, we remove all the functions we installed
        // earlier and apply a new set.
        // TODO : Make sure no operations in the new port will override
        //        the WebService's native methods
        for (var i in this.activePort) {
            this.service[i] = undefined;
        }

        for (var i in newPort) {
            this.service[i] = function() {
                return this.stub.invokeOperation(arguments.callee.name, arguments);
            };
            this.service[i].name = i;
        }

        this.activePort = newPort;

        this.service._name = svcName;
        this.service._description = this._servicePortMappings[svcName].description;

        return this.activePort;
    }

    function createCallsFromPort(wsdlPort)
    {
        var soapCalls = new Object();

        var binding = wsdlPort.binding;
        var portType = binding.portType;
        var operations = portType.operations;

        var endpointURI = wsdlPort.endpointURI;

        if (this.service._endpointReplacementURI != undefined) {
            // Replace host and port, but leave the rest alone.
            var i = endpointURI.indexOf("/", 7);  // First slash after "http://"
            endpointURI = this.service._endpointReplacementURI + endpointURI.substring(i);
        }

        var soapVersion;

        var schemaContext = this.wsdl.schemas;

        // Respect proxy settings.  If we have either a service-specific
        // proxy setting or a global proxyURL, adjust the target URL to go
        // through the proxy.  Use Flash Remoting style URLs for now.

        // Global setting trumps.  If no global, try the service.
        // TODO : how to get flashvars in AS2?
        //if (myProxyURI == undefined) {
        //    myProxyURI = proxyURL;
        //}

        var myProxyURI = this.service._proxyURI;

        if (myProxyURI != undefined) {
            myProxyURI = this.buildURL(myProxyURI);
        }

        var ops = this["waitingOps"];

        var operationName:String;

        for (operationName in operations)
        {
            var operation = operations[operationName];
            var soapAction = operation.actionURI;
            var style = operation.style;
            var enc = operation.inputEncoding; // assuming input and output follow the same encoding
            var use = enc.use;
            var targetNS = enc.namespaceURI;
            var encStyle = enc.encodingStyle;


            var soapLog = new Log(this.log.level, "SOAP");
            soapLog._parentLog = this.log;
            soapLog.onLog = function(txt) { this._parentLog.onLog(txt); };

            var opEndpointURI = endpointURI;
            if (myProxyURI != undefined)
            {
                opEndpointURI = myProxyURI + "?transport=SoapHttp&action=" +
                             escape(soapAction) + "&target=" + escape(endpointURI);
            }

            var sCall = ops[operationName];
            if (sCall != undefined)
            {
                delete ops[operationName];
            }
            else
            {
                sCall = new SOAPCall(operationName);
            }
            sCall.targetNamespace = targetNS;
            sCall.endpointURI = opEndpointURI;
            sCall.log = soapLog;
            sCall.operationStyle = style;
            sCall.useStyle = use;
            sCall.encodingStyle = encStyle;
            sCall.actionURI = soapAction;
            sCall.schemaContext = schemaContext;

            // Store the WSDL operation in the SOAPCall so that we can do an
            // as-needed parse later.
            sCall.wsdlOperation = operation;

            if (operation.description != undefined)
            {
                sCall.description = operation.description;
            }

            soapCalls[operationName] = sCall;

            this.log.logInfo("Made SOAPCall for operation " + operationName, Log.BRIEF);
        }

        return soapCalls;
    }

    function invokeOperation(operationName, args)
    {
        var soapCall;

        // if WSDL loading caused a fault, then return it
        if (this.wsdl.fault != undefined)
        {
            // if disconnected, simply queue -- would ideally re-check here (just try to get WSDL again?)
            if (this.wsdl.fault.faultcode == SOAPConstants.DISCONNECTED_FAULT_CODE)
            {
                soapCall = this.enqueueCall(operationName, args);
            }
            // otherwise report the fault via the onFault callback on the service
            else
            {
                this.service.onFault.call(this.service, this.wsdl.fault);
            }
        }

        // if the proxy hasn't completed initialization, queue the invocation
        else if ((this.wsdl.rootWSDL.xmlDoc == undefined) || (!this.wsdl.rootWSDL.xmlDoc.loaded))
        {
            soapCall = this.enqueueCall(operationName, args);
            this.log.logInfo("Queing call " + operationName);
        }

        else
        {
            soapCall = this.invokeCall(operationName, args);
            if (soapCall == undefined) {
                var fault = new SOAPFault("Client.NoSuchMethod",
                    "Couldn't find method '" + operationName + "' in service!");
                this.service.onFault.call(this.service, fault);
                return;
            }

            this.log.logInfo("Invoking call " + operationName);
        }

        return soapCall;
    }

    // Get a SOAPCall for the given operation name.
    // If the WSDL hasn't yet been loaded, we don't know whether
    // this will be a valid name or not, but we have to hand
    // the user back something so they can drop callbacks like
    // onResult and onFault on it.  In this case, make a temporary
    // object to hand back, and remember it so we can transfer
    // the callbacks or call onFault once we get the WSDL.
    function getCall(operationName)
    {
        if ((this.wsdl.rootWSDL.xmlDoc != undefined) && this.wsdl.rootWSDL.xmlDoc.loaded)
            return this.activePort[operationName];

        var queuedOps = this["waitingOps"];
        if (queuedOps == undefined) {
            queuedOps = new Object();
            this["waitingOps"] = queuedOps;
        }
        var thisOp = queuedOps[operationName];
        if (thisOp == undefined) {
            thisOp = new SOAPCall(operationName);
            queuedOps[operationName] = thisOp;
        }

        return thisOp;
    }

    function invokeCall(operationName : String, parameters)
    {
        var currentCall = this.activePort[operationName];

        if (currentCall == undefined)
            return;

        // Pass timeout value along if we have one
        if (this.service._timeout != -1) {
            currentCall.timeout = this.service._timeout;
        }

        var ret = currentCall.asyncInvoke(parameters, "onLoad");
        return ret;
    }

    function enqueueCall(operationName, args)
    {
        if (this.callQueue == undefined)
        {
            // Prepare a queue for disconnected invocations
            // (lazily, only used if needed)
            this.callQueue = new Array();
        }

        var promise = new Object();
        promise.operationName = operationName;
        promise.args = args;
        // This is a hack - we should really be returning proper PendingCall objects here....
        promise.cancel = function() {
            this.cancelled = true;
        };
        this.callQueue.push(promise);

        // return the promised call so that callback functions can be implemented on it:
        return promise;
    }

    // Deal with the queued calls - if a fault is passed, we'll simply call
    // onFault() for each call.  Otherwise we invoke each one.
    function unEnqueueCalls(fault)
    {
        var ops = this["waitingOps"];
        if (ops != undefined)
        {
            for (var name in ops) {
                var thisOp = ops[name];
                if (fault != undefined) {
                    // If we had a fault, just fault it and go on
                    thisOp.onFault(fault);
                    continue;
                }
                var soapCall = this.activePort[name];
                if (soapCall == undefined) {
                    // No such call!
                    thisOp.onFault(new SOAPFault("Client.NoSuchMethod",
                        "Couldn't find method '" + name + "' in service!"));
                    continue;
                }
            }
        }

        var q = this.callQueue;
        if (q != undefined)
        {
            var numCalls = q.length;
            for (var i=0; i<numCalls; i++)
            {
                var qcall = q[i];

                if (qcall.cancelled)
                    continue;

                if (fault != undefined) {
                    this.log.logInfo("Faulting previously queued call " + qcall.operationName);
                    qcall.onFault(fault);
                    continue;
                }

                this.log.logInfo("Invoking previously queued call " + qcall.operationName);

                // invoke
                var soapCall = this.invokeCall(qcall.operationName, qcall.args);
				// (be aware: the variable "soapCall" is of type mx.services.PendingCall!).

                if (soapCall == undefined) {
                    fault = new SOAPFault("Client.NoSuchMethod",
                        "Couldn't find method '" + qcall.operationName + "' in service!");
                    qcall.onFault(fault);
                    return;
                }

                // handle any callbacks implemented on the promise
                soapCall.originalPromise = qcall;
                
				// part of the workaround for flash bug #67922 - if you make a service call *before*
				// the WSDL fetch has completed, then the callback object ("pendingCall") is not
				// an object of class mx.services.PendingCall. The other part of the workaround 
				// is in mx.data.components.WebServiceConnector.as
                qcall.myCall = soapCall.myCall;
                
                soapCall.timerObj = qcall.timerObj;
                soapCall.onResult = function(result, response)
                {
                    this.originalPromise.request = this.request;
                    this.originalPromise.response = this.response;
                    this.originalPromise.onResult(result, response);
                };
                soapCall.onFault = function(faultReason)
                {
                    this.originalPromise.request = this.request;
                    this.originalPromise.response = this.response;
                    this.originalPromise.onFault(faultReason);
                };
                soapCall.__handleResult = function(result, response)
                {
                    this.originalPromise.request = this.request;
                    this.originalPromise.response = this.response;
                    this.originalPromise.__handleResult(result, response);
                };
                soapCall.__handleFault = function(faultReason)
                {
                    this.originalPromise.request = this.request;
                    this.originalPromise.response = this.response;
                    this.originalPromise.__handleFault(faultReason);
                };
                soapCall.onHeaders = function(headers, response)
                {
                    this.originalPromise.request = this.request;
                    this.originalPromise.response = this.response;
                    this.originalPromise.onHeaders(headers, response);
                };
            }
        }
    }
}
