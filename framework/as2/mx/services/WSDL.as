// ------------------------------------------------------------
// WSDL PARSER
// ------------------------------------------------------------
// Parses a WSDL file in conjunction with the XML Schema
// Parser in order to produce a set of ActionScript objects
// that represent a set of services, ports, bindings,
// portTypes, operations, and messages.
//
// Used by the WebServices stub to generate SOAPCalls for
// operations.
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------
import mx.services.Log;
import mx.services.QName;
import mx.services.SchemaContext;
import mx.services.SOAPConstants;
import mx.services.SOAPFault;
import mx.services.SOAPParameter;
import mx.services.WebServiceProxy;
import mx.services.WSDLConstants;
import mx.services.WSDLDocument;
import mx.services.WSDLOperation;

class mx.services.WSDL
{
    var log:Log;
    var serviceProxy:WebServiceProxy;
    var wsdlURI:String;
    var wsdlDocs:Object;
    var constants:WSDLConstants;
    var schemas;
    var unresolvedImports:Number;
    var document;
    var startTime;
    var fault;
    var targetNamespace;
    var rootWSDL;
    var services;

    var onLoad:Function;

    function WSDL(wsdlURI, serviceProxy, logObj, wsdlVersion)
    {
        this.log = logObj;

        this.log.logInfo("Creating WSDL object for " + wsdlURI, Log.VERBOSE);

        // ok if this is undefined (means WSDL is being used for
        // something other than stub generation):
        this.serviceProxy = serviceProxy;

        this.wsdlURI = wsdlURI;

        // A collection of WSDLDocument (see above) instances for each imported
        // document (including the root) we pull in.
        this.wsdlDocs = new Object();

        var ver = (wsdlVersion == undefined) ? 0 : wsdlVersion;
        this.constants = WSDLConstants.getConstants(ver);

        // SCHEMA CONTEXT INITIALIZATION
        var schemaLog = new Log(this.log.level, "XMLSchema");
        schemaLog._parentLog = this.log;
        schemaLog.onLog = function(txt) { this._parentLog.onLog(txt); };
        this.schemas = new SchemaContext(schemaLog);

        // Always have the XSD + SOAP types available
        SchemaContext.RegisterStandardTypes(this.schemas);

        // How many unresolved imports do we have?  This is used to trigger
        // root processing when it goes to zero.
        this.unresolvedImports = 1;  // The root document...

        // Create the XML document instance for our root WSDL document
        var document = new XML();
        document.ignoreWhite = true;
        document.wsdl = this;
        document.location = wsdlURI;
        document.isRootWSDL = true;

        // remember this one for the WebService.onLoad(wsdl) callback
        this.document = document;

        // Remember when we started....
        this.startTime = new Date();

        // Go load this document into our universe.
        this.fetchDocument(document);

        this.log.logInfo("Successfully created WSDL object", Log.VERBOSE);
    }

    // Go get a particular WSDL/schema document.
    function fetchDocument(document) {
        document.onData = function(src)
        {
            if (src != undefined)
            {
                var start = new Date();
                this.wsdl.log.logInfo("Received WSDL document from the remote service", Log.VERBOSE);
                this.parseXML(src);
                this.loaded = true;
                var parseTime = Math.round((new Date()).getTime() - start.getTime());
                this.wsdl.log.logInfo("Parsed WSDL XML [" + parseTime + " millis]", Log.VERBOSE);
            }

            this.wsdl.parseDocument(this);
			delete(this.wsdl); //Fix for bug#74567 - Circular reference causes memory leak
        };

        // HTTP GET operation to retrieve WSDL document:
        document.load(document.location, "GET");
    }

    // We arrive here when the callback function above gets called, either with a
    // complete document or an error.
    function parseDocument(document)
    {
        if (!document.loaded)
        {
            this.fault = new SOAPFault(SOAPConstants.DISCONNECTED_FAULT_CODE,
                                "Could not load WSDL",
                                "Unable to load WSDL, if currently online, please verify " +
                                "the URI and/or format of the WSDL (" + this.wsdlURI + ")");
            this.log.logDebug("Unable to receive WSDL file");
        } else {
            this.unresolvedImports--;
            this.processImports(document);
        }

        if ((this.unresolvedImports == 0) || (this.fault != undefined)) {
            this.parseCompleted();
        }
    }

    function buildURL(locationURL, contextURL) {
        if (locationURL.substr(0, 7) == "http://" ||
            locationURL.substr(0, 8) == "https://") {
            return locationURL;
        }

        var lastSlash = contextURL.lastIndexOf("/");
        contextURL = contextURL.substr(0, lastSlash + 1);

        return contextURL + locationURL;
    }

    // Got a new WSDL/schema document.  Run through it, doing some very basic
    // consistency checking.  Create a WSDLDocument() instance for easy referencing
    // later, and go get all <import>s.


    function processImports(document) {
        var definitions = document.firstChild;
        var c = this.constants;

        // check for malformed wsdl / schema
        var defQName = definitions.getQName();
        if (!defQName.equals(c.definitionsQName))
        {
            if (defQName.localPart == "schema") {
                // Schema - register it (which will process schema imports) and return
                this.schemas.registerSchemaNode(definitions);
                return;
            } else {
                this.fault = new SOAPFault("Server", "Faulty WSDL format",
                                       "Definitions must be the first element in a WSDL document");

		var child = document.firstChild;
		if(child.nodeName == "soapenv:Envelope")
		{
			child = child.firstChild;
			if(child.nodeName == "soapenv:Body")
			{
				child = child.firstChild;
				if(child.nodeName == "soapenv:Fault")
				{
					var faultcode;
					var faultstring;
					var details;
					for (var aNode:XMLNode = child.firstChild; aNode != null; aNode = aNode.nextSibling) {
						if(aNode.nodeName == "faultcode")
							faultcode = aNode.firstChild;
						else if(aNode.nodeName == "faultstring")
							faultstring = aNode.firstChild;
						else if(aNode.nodeName == "detail")
							details = aNode.firstChild;
					}
					this.fault = new SOAPFault(faultcode, faultstring, details);
					
				}
			}
		}
		
                return;
            }
        }

        var targetNamespace = definitions.attributes.targetNamespace;

        // Create WSDLDocument, store for later reference by namespace.
        var wsdlDoc = new WSDLDocument(document, this);
        this.wsdlDocs[targetNamespace] = wsdlDoc;

        if (document.isRootWSDL) {
            this.targetNamespace = targetNamespace;
            this.rootWSDL = wsdlDoc;
        }

        var imports = definitions.getElementsByQName(c.importQName);
        if (imports != undefined) {
            for (var i = 0; i < imports.length; i++) {
                var location = imports[i].attributes.location;
                // Rationalize for relative URLs
                location = this.buildURL(location, document.location);

                var namespace = imports[i].attributes.namespace;
                this.importDocument(location, namespace);
            }
        }
    }

    // Import a document from the given location with the given namespaceURI.
    // Note that this increments this.unresolvedImports, which will delay processing
    // until all imports are loaded.
    function importDocument(location, namespaceURI) {
        var importDoc = new XML();
        importDoc.ignoreWhite = true;
        importDoc.wsdl = this;
        importDoc.namespace = namespaceURI;
        importDoc.location = location;
        this.unresolvedImports++;
        this.fetchDocument(importDoc);
    }

    // All documents have been loaded and pre-parsed, or theres been a fault.
    // Time to go grovel through the root document if no fault, and callback
    // interested parties with onLoad() in either case.
    function parseCompleted() {
        if (this.fault == undefined) {
            // Go get our services
            this.parseServices();
        }

        if (this.fault == undefined) {
            // At this point, our job is essentially done, and this.services is
            // filled in.  Note how long this took.
            var parseTime = Math.floor((new Date()).getTime() - this.startTime.getTime());
            //trace("WSDL parse took " + parseTime + "ms");
        }

        // invoke a callback to objects listening for WSDL to load and parse
        // (usually a web service proxy (defined in WebService.as) but can be anything)
        this.onLoad();
    }

    function parseServices()
    {
        this.log.logDebug("Parsing definitions");

        var c = this.constants;

        var serviceElements = this.rootWSDL.serviceElements;

        // create an associative array of services mapped to the service names
        if (serviceElements == undefined)
        {
            // No services?  Must be an error.
            this.fault = new SOAPFault("Server.NoServicesInWSDL",
                                "Could not load WSDL",
                                "No <wsdl:service> elements found in WSDL " +
                                "at " + this.wsdlURI + ".");
            this.log.logDebug("No <service> elements in WSDL file");
            return;
        }

        var services = new Object();
        for (var i in serviceElements)
        {
            var svc = this.parseService(serviceElements[i]);
            services[svc.name] = svc;
        }

        this.services = services;

        this.log.logDebug("Completed WSDL parsing");
    }

    // Parse schema elements - really this just registers the root elements
    // in a given target namespace, and sets up for full parsing when types/
    // elements are asked for.
    function parseSchemas(typesNode)
    {
        this.log.logDebug("Parsing schemas");

        var schemaNodes = typesNode.childNodes;
        var numSchemas = schemaNodes.length;
        for (var i=0; i<numSchemas; i++)
        {
            this.schemas.registerSchemaNode(schemaNodes[i]);
        }

        this.log.logDebug("Done parsing schemas.");
    }

    function parseService(serviceElement)
    {
        this.log.logDebug("Parsing service: " + serviceElement.nodeName);

        var service = new Object();
        service.ports = new Object();

        var c = this.constants;

        service.name = serviceElement.attributes.name;

        var portElements = serviceElement.childNodes;
        var portLen = portElements.length;

        for (var i=0; i < portLen && this.fault == undefined; i++)
        {
            var portElement = portElements[i];
            var portQName = portElement.getQName();

            if (portQName.equals(c.documentationQName))
            {
                service.description = portElement.firstChild;
            }

            else if (portQName.equals(c.portQName))
            {
                var port = new Object();

                // get this port's target URI
                for (var n=0; n<portElement.childNodes.length; n++)
                {
                    var addrNode = portElement.childNodes[n];
                    var addrQName = addrNode.getQName();
                    if (addrQName.equals(c.soapAddressQName))
                    {
                        port.endpointURI = addrNode.attributes.location;
                        break;
                    }
                }

                // use only SOAP bindings
                if (port.endpointURI != undefined)
                {
                    port.name = portElement.attributes.name;
                    var bindingQName = portElement.getQNameFromString(portElement.attributes.binding);
                    port.binding = this.parseBinding(bindingQName);

                    // add the port to the service's associative array of ports
                    service.ports[port.name] = port;
                }
            }
        }

        return service;
    }

    function parseBinding(bindingName)
    {
        this.log.logDebug("Parsing binding: " + bindingName);

        var binding = new Object();

        var c = this.constants;

        var doc = this.wsdlDocs[bindingName.namespaceURI];
        if (doc == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedNamespace",
                 "The WSDL parser had no registered document for the namespace '" +
                 bindingName.namespaceURI + "'");
            return;
        }

        var bindingElement = doc.getBindingElement(bindingName.localPart);
        if (bindingElement == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedBindingName",
                "The WSDL parser couldn't find a binding named '" + bindingName.localPart +
                "' in namespace '" + bindingName.namespaceURI + "'");
            return;
        }

        // get the portType that this binding addresses
        var portTypeQName = bindingElement.getQNameFromString(bindingElement.attributes.type);
        binding.portType = this.parsePortType(portTypeQName);

        // punt if something went wrong...
        if (this.fault != undefined)
            return;

        var bindingDetails = bindingElement.childNodes;
        var numBindDetails = bindingDetails.length;

        for (var n=0; n < numBindDetails; n++)
        {
            var bindDetail = bindingDetails[n];
            var bindDetailQName = bindDetail.getQName();

            // handle transport type (supports only soap/http for now)
            if (bindDetailQName.equals(c.soapBindingQName))
            {
                binding.style = bindDetail.attributes.style; // either rpc or document
                if (binding.style == undefined)
                {
                    // default to document per WSDl 1.1 spec
                    binding.style = WSDLConstants.DEFAULT_STYLE;
                }
                binding.transport = bindDetail.attributes.transport;
            }

            else if (bindDetailQName.equals(c.operationQName))
            {
                var operationName = bindDetail.attributes.name;
                var operation = binding.portType.operations[operationName];

                var opDetails = bindDetail.childNodes;
                var numOpDetails = opDetails.length;

                for (var b=0; b < numOpDetails; b++)
                {
                    var opDetail = opDetails[b];
                    var opDetailQName = opDetail.getQName();

                    if (opDetailQName.equals(c.soapOperationQName))
                    {
                        var action = opDetail.attributes.soapAction;
                        operation.actionURI = action;

                        var style = opDetail.attributes.style;
                        if (style == undefined) style = binding.style;
                        operation.style = style;
                    }

                    // handle input message encoding: use, namespace, and encoding style
                    else if (opDetailQName.equals(c.inputQName))
                    {
                        var encodingNode = opDetail.getElementsByQName(c.soapBodyQName)[0];
                        var encoding = new Object();
                        encoding.use = encodingNode.attributes.use;
                        encoding.namespaceURI = encodingNode.attributes.namespace;
                        if (encoding.namespaceURI == undefined)
                        {
                            encoding.namespaceURI = this.targetNamespace;
                        }
                        encoding.encodingStyle = encodingNode.attributes.encodingStyle;
                        operation.inputEncoding = encoding;

                        // NOTE: Do we want to support header elements on the input here?
                    }

                    // output message encoding
                    else if (opDetailQName.equals(c.outputQName))
                    {
                        var encodingNode = opDetail.getElementsByQName(c.soapBodyQName)[0];
                        var encoding = new Object();
                        encoding.use = encodingNode.attributes.use;
                        encoding.namespaceURI = encodingNode.attributes.namespace;
                        if (encoding.namespaceURI == undefined)
                        {
                            encoding.namespaceURI = this.targetNamespace;
                        }
                        encoding.encodingStyle = encodingNode.attributes.encodingStyle;
                        operation.outputEncoding = encoding;

                        // NOTE: Do we want to support header elements on the output here?
                    }
                }
            }
        }
        var bindingElements = document.getElementsByQName(c.bindingQName);
        for (var i=0; i < bindingElements.length; i++)
        {
            bindingElement = bindingElements[i];
            var bn = bindingElement.attributes.name;
            if (bindingName != bn) continue;
            binding.name = bn;
        }

        return binding;
    }

    function parsePortType(portTypeName, document)
    {
        this.log.logDebug("Parsing portType: " + portTypeName);

        var doc = this.wsdlDocs[portTypeName.namespaceURI];
        if (doc == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedNamespace",
                 "The WSDL parser had no registered document for the namespace '" +
                 portTypeName.namespaceURI + "'");
            return;
        }

        var portTypeElement = doc.getPortTypeElement(portTypeName.localPart);
        if (portTypeElement == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedPortTypeName",
                "The WSDL parser couldn't find a portType named '" + portTypeName.localPart +
                "' in namespace '" + portTypeName.namespaceURI + "'");
            return;
        }

        var portType = new Object();
        var c = this.constants;

        portType.name = portTypeElement.attributes.name;
        portType.operations = new Object(); // associative array of operations mapped to operation name

        var operationElements = portTypeElement.getElementsByQName(c.operationQName);
        var numOperations = operationElements.length;

        for (var i=0; i < numOperations; i++)
        {
            var operationElement = operationElements[i];
            var operation = new WSDLOperation(operationElement.attributes.name, this, document);

            var opMsgs = operationElement.childNodes;
            var numOpMsgs = opMsgs.length;

            for (var n=0; n<numOpMsgs; n++)
            {
                var msgElement = opMsgs[n];
                var msgElementQName = msgElement.getQName();

                if (msgElementQName.equals(c.documentationQName))
                {
                    operation.documentation = msgElement.childNodes[0];
                    continue;
                }

                var msgStr = msgElement.attributes.message;
                var msgQName = msgElement.getQNameFromString(msgStr);

                if (msgElementQName.equals(c.inputQName))
                {
                    operation.inputMessage = msgQName;
                }

                else if (msgElementQName.equals(c.outputQName))
                {
                    operation.outputMessage = msgQName;
                }
            }

            // NOTE: Do we want to support parameterOrder attribute?
            // NOTE: Do we want to check for common names among input and output in order to support inout?
            if (portType.operations[operation.name] != undefined) {
                this.fault = new SOAPFault("WSDL.OverloadedOperation", "The WSDL contains an overloaded operation (" + operation.name + ") - we do not currently support this usage.");
                return;
            }

            // add the operation to this portType's associative array of operations, mapped to operation name
            portType.operations[operation.name] = operation;
        }

        return portType;
    }

    function parseMessage(messageName, operationName, mode, document)
    {
        this.log.logDebug("Parsing message: " + messageName);

        var doc = this.wsdlDocs[messageName.namespaceURI];
        if (doc == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedNamespace",
                 "The WSDL parser had no registered document for the namespace '" +
                 messageName.namespaceURI + "'");
            return;
        }

        var messageElement = doc.getMessageElement(messageName.localPart);
        if (messageElement == undefined) {
            this.fault = new SOAPFault("WSDL.UnrecognizedMessageName",
                "The WSDL parser couldn't find a message named '" + messageName.localPart +
                "' in namespace '" + messageName.namespaceURI + "'");
            return;
        }

        var c = this.constants;
        var message = new Object();

        message.name = messageElement.attributes.name;

        // per WSDL 1.1 spec, if message is not named default to op Name plus suffix by mode:
        if (message.name == undefined)
        {
            if (mode == SOAPConstants.MODE_IN)
            {
                message.name = operationName + "Request";
            }
            else
            {
                message.name = operationName + "Response";
            }
        }

        this.log.logDebug("Message name is " + message.name);

        var messageParameters = messageElement.getElementsByQName(c.parameterQName);
        var numParameters = messageParameters.length;
        message.parameters = new Array(); // array of SOAPParameter objects
        for (var i=0; i<numParameters; i++)
        {
            var paramElement = messageParameters[i];
            var paramName = paramElement.attributes.name;

            // must have 'element' or 'type' attribute
            var paramSchemaType;
            // QName if an element
            var paramQName;

            if (paramElement.attributes.element != undefined)
            {
                var elementName = paramElement.attributes.element;
                var qname = paramElement.getQNameFromString(elementName);
                var elementObj = this.schemas.getElementByQName(qname);
                if (this.schemas.fault != undefined) {
                    this.fault = this.schemas.fault;
                    return;
                }
                if (elementObj == undefined) {
                    // Houston, we have a problem!
                    this.fault = new SOAPFault("WSDL.BadElement",
                                      "Element " + elementName + " not resolvable");
                    return;
                }
                paramSchemaType = elementObj.schemaType;
                paramQName = qname;

                // This is .NET-style "wrapped" mode IF:
                // 1) There is exactly one part in the message
                // 2) It's an element (see if statement above)
                // 3) The element name matches the operation name
                // 4) There are no attributes (NOT IMPLEMENTED YET)
                if ((numParameters == 1) && (operationName == qname.localPart))
                {
                    // Process the sub-elements as individual parameters
                    for (var subName in paramSchemaType.partTypes) {
                        var subType = paramSchemaType.partTypes[subName];
                        var subQName = new QName(subName, subType.namespace);
                        var soapParam = new SOAPParameter(subName, subType.schemaType, mode, subQName);
                        message.parameters.push(soapParam);
                        message.targetNamespace = qname.namespaceURI;
                    }
                    message.isWrapped = true;
                    if (elementObj.form == "qualified")
                        message.isQualified = true;

                    break;
                }
            }
            else
            {
                var typeName = paramElement.attributes.type;
                var qname = paramElement.getQNameFromString(typeName);
                paramSchemaType = this.schemas.getTypeByQName(qname);
                if (this.schemas.fault != undefined) {
                    this.fault = this.schemas.fault;
                    return;
                }
                if (paramSchemaType == undefined) {
                    this.fault = new SOAPFault("WSDL.BadType",
                                    "Type " + typeName + " not resolvable");
                    return;
                }
            }

            var soapParam = new SOAPParameter(paramName, paramSchemaType, mode, paramQName);
            message.parameters.push(soapParam);
        }

        return message;
    }
}
