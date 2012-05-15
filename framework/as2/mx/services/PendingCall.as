// ------------------------------------
// PendingCall - this is the actual SOAP encoding/decoding code.
//
// Each PendingCall is an instance of an active SOAP interaction, containing
// a request and a response envelope and a pointer back to the associated
// SOAPCall (see above).
// ------------------------------------
import mx.services.ArrayProxy;
import mx.services.DataType;
import mx.services.Log;
import mx.services.PrefixedQName;
import mx.services.QName;
import mx.services.RowSetProxy;
import mx.services.SOAPCall;
import mx.services.SOAPConstants;
import mx.services.SOAPFault;
import mx.services.SOAPHeader;

/**
  @helpid	1746
  @tiptext	information regarding an outstanding call to a service
*/
class mx.services.PendingCall
{
	/**
	  @helpid	1727
	  @tiptext  current soap call
	*/
    var myCall:SOAPCall;
    var soapConstants:SOAPConstants;
    var log:Log;
    var doLazyDecoding:Boolean = true;
    var doDecoding:Boolean = true;
    var timeoutFunc:Function;
    var timerID:Number;
	/**
	  @helpid	1733
	  @tiptext  current SOAP request document
	*/
    var request:Object;
	/**
	  @helpid	1734
	  @tiptext  current SOAP result document
	*/
    var response:Object;
    var actionURI:String;
    var requestHeaders;
    var fault:SOAPFault;
    var responseHeaders;
    var bodyNode;
    var cancelled:Boolean = false;      // Have we been cancelled?

	/**
	  @helpid	1725
	  @tiptext  called when a fault occurs
	*/
    var onFault:Function;
	/**
	  @helpid	1726
	  @tiptext  called when results are ready
	*/
    var onResult:Function;
    var onHeaders:Function;
    var __handleResult:Function;
    var __handleFault:Function;

    var handleDelayedFault : Function;

    public function PendingCall(myCall) {
        this.myCall = myCall;
        this.soapConstants = myCall.soapConstants;
        this.log = myCall.log;

        // This switch controls whether we hand back fully decoded Arrays and
        // RowSets, or whether we "lazily" decode them as needed via a proxy object.
        this.doLazyDecoding = myCall.doLazyDecoding;

        // Should we decode the body at all, or just hand back an array of its child nodes?
        // (note that we'll still process headers regardless)
        this.doDecoding = myCall.doDecoding;
    };

    function setTimeout(timeoutMS)
    {
        this.timeoutFunc = function()
        {
            clearInterval(this.timerID);
            this.timerID = undefined;
            var fault = new SOAPFault("Timeout", "Timeout while calling method " + this.myCall.operationName + "!");
            this.onFault(fault);
        };

        this.timerID = setInterval(this, "timeoutFunc", timeoutMS);
    }

    function cancel()
    {
        // Clear any timeout
        if (this.timerID != undefined) {
            clearInterval(this.timerID);
        }

        // And mark us as cancelled so we don't react to events
        this.cancelled = true;
    }

    function encode()
    {
        this.log.logInfo("Encoding SOAPCall request", Log.VERBOSE);
        this.encodeHTTPRequest();
        this.encodeSOAPEnvelope();
    }

    function encodeHTTPRequest()
    {
        this.log.logDebug("Creating HTTP request object");

        // create an XML object to represent the request
        var request = new XML();
        request.ignoreWhite = true;
        request.contentType = this.soapConstants.contentType;
        request.xmlDecl = SOAPConstants.XML_DECLARATION;

        // add SOAPAction HTTP Header, composing one if it has not been set
        // NOTE: this method not available prior to Flash version 6,0,65:
        request.addRequestHeader("SOAPAction", "\"" + this.myCall.actionURI + "\"");

        // associate the XML request with this PendingCall
        this.request = request;
    }

    function encodeSOAPEnvelope()
    {
        this.log.logDebug("Encoding SOAP request envelope");

        var request = this.request;
        var schemaVersion = this.myCall.schemaVersion;

         // create the SOAPEnvelope in the Document
        var envQName = soapConstants.envelopeQName;
        var envelopeElement = request.createElement(SOAPConstants.SOAP_ENV_PREFIX + ":" + envQName.localPart);
        envelopeElement.attributes["xmlns:" + SOAPConstants.SOAP_ENV_PREFIX] = soapConstants.ENVELOPE_URI;
        envelopeElement.attributes["xmlns:" + SOAPConstants.XML_SCHEMA_PREFIX] = schemaVersion.xsdURI;
        envelopeElement.attributes["xmlns:" + SOAPConstants.XML_SCHEMA_INSTANCE_PREFIX] = schemaVersion.xsiURI;
        request.appendChild(envelopeElement);

        request["soapEnvelope"] = envelopeElement;

        // create a header element for each header node passed in as a parameter
        this.encodeSOAPHeader();

        // create a single body element for the method invocation
        this.encodeSOAPBody();
    }

    function encodeSOAPHeader()
    {
        var request = this.request;
        var envelope = this.request["soapEnvelope"];

        // each Header Entry in the array should contain a fully-qualified
        // XML Node in the element property
        var headerArray = this.requestHeaders;
        if (headerArray.length > 0)
        {
            var headerElement = request.createElement(SOAPConstants.SOAP_ENV_PREFIX + ":" + soapConstants.headerQName.localPart);
            envelope.appendChild(headerElement);

            var numHeaders = headerArray.length;
            for (var i=0; i<numHeaders; i++)
            {
                headerElement.appendChild(headerArray[i].element);
            }
            //MJR Fix for bug#74567 - Circular reference causes memory leak
			//this.request["soapHeader"] = headerElement;
        }
    }

    function encodeSOAPBody()
    {
        this.log.logDebug("Encoding SOAP request body");

        var request = this.request;
        var myCall = this.myCall;
        var operationName = myCall.operationName;
        var targetNamespace = myCall.targetNamespace;
        var constants = myCall.soapConstants;
        var envelope = request["soapEnvelope"];
		request["soapEnvelope"] = null; //MJR Fix for bug#74567 - Circular reference causes memory leak

        var bodyQName = constants.bodyQName;
        var bodyElement = request.createElement(SOAPConstants.SOAP_ENV_PREFIX + ":" + bodyQName.localPart);
        envelope.appendChild(bodyElement);

        // If we're using a literal body (i.e. we expect someone to give us an XML object), don't do
        // anything else here.  If we're not (i.e. we're using AS objects), then set up the operation
        // wrapper element.
        if (!myCall.useLiteralBody)
        {
            if (myCall.operationStyle != SOAPConstants.DOC_STYLE)
            {
                if (myCall.operationStyle == SOAPConstants.WRAPPED_STYLE &&
                    myCall.elementFormQualified)
                {
                    request["soapOperation"] = request.createElement(operationName);
                    request["soapOperation"].attributes["xmlns"] = targetNamespace;
                }
                else
                {
                    var elName = this.getStringFromQName(bodyElement, new QName(operationName, targetNamespace));
                    request.soapOperation = request.createElement(elName);
                    if (myCall.useStyle == SOAPConstants.USE_ENCODED) {
                        request.soapOperation.attributes[SOAPConstants.SOAP_ENV_PREFIX + ":encodingStyle"] = constants.ENCODING_URI;
                    }
                }

                bodyElement.appendChild(request.soapOperation);
            } else {
                request.soapOperation = bodyElement;
            }
        }
		//MJR Fix for bug#74567 - Circular reference causes memory leak
        //request.soapBody = bodyElement;
    }

	/**
	  @helpid	1738
	  @tiptext  adds the specified header to this call
	*/
    public function addHeader(headerElement)
    {
        this.log.logDebug("Adding header: " + headerElement.nodeName);

        if (this.requestHeaders == undefined) {
            this.requestHeaders = new Array();
        }

        this.requestHeaders.push(new SOAPHeader(headerElement));
    }

    // Utility function to return an active prefix for the given namespaceURI,
    // or create a new namespace mapping on the given node.
    function getOrCreatePrefix(node, namespaceURI, preferredPrefix)
    {
        if (namespaceURI == undefined || namespaceURI == "") {
            var defaultNS = node.getNamespaceForPrefix("");
            // If we want no namespace, the only way to get it is by changing the
            // default... So slap an xmlns="" on the node.
            if (defaultNS != undefined && defaultNS != "") {
                node.attributes["xmlns"] = "";
                node.registerNamespace("", "");
            }
            return "";
        }

        var prefix = node.getPrefixForNamespace(namespaceURI);
        var added = false;

        if (prefix == undefined)
        {
            if (preferredPrefix == undefined) {
                this.request.nscount++;
                prefix = "ns" + this.request.nscount;
            } else {
                prefix = preferredPrefix;
            }
            added = true;
        }
        if (added) {
            if (prefix != "") {
                node.attributes["xmlns:" + prefix] = namespaceURI;
            } else {
                node.attributes["xmlns"] = namespaceURI;
            }
            node.registerPrefix(prefix, namespaceURI);
        }

        return prefix;
    }

    function getStringFromQName(node, qname)
    {
        var prefix = this.getOrCreatePrefix(node, qname.namespaceURI);
        if (prefix != "") {
            return prefix + ":" + qname.localPart;
        } else {
            return qname.localPart;
        }
    }

    function encodeParam(paramName, paramType, parentNode, qname)
    {
        var paramElement;
        var request = this.request;
        var typeAttr = SOAPConstants.SCHEMA_INSTANCE_TYPE;

        if (paramType.typeType == DataType.ARRAY_TYPE)
        {
            if (this.myCall.useStyle == SOAPConstants.USE_ENCODED)
            {
                paramElement = request.createElement(SOAPConstants.SOAP_ENC_PREFIX + ":" + paramName);
                paramElement.attributes["xmlns:" + SOAPConstants.SOAP_ENC_PREFIX] = this.soapConstants.ENCODING_URI;
                parentNode.appendChild(paramElement);
                paramElement.nodeName = paramName;
                var arrType = paramType.arrayType;
                var arrayTypeAttr = SOAPConstants.ARRAY_TYPE_PQNAME;
                var typePrefix = this.getOrCreatePrefix(paramElement, arrType.namespaceURI);
                paramElement.attributes[arrayTypeAttr] = typePrefix + ":" + arrType.name; // dims added upon invocation
            }
            else
            {
                paramElement = request.createElement(paramName);
                parentNode.appendChild(paramElement);
                if (qname != undefined) {
                    paramElement.nodeName = this.getStringFromQName(paramElement, qname);
                }
            }
        }

        else
        {
            if (this.myCall.useStyle == SOAPConstants.USE_ENCODED)
            {
                var paramTagName = this.getStringFromQName(parentNode, new QName(paramName,
                                                                                 paramType.namespaceURI));
                paramElement = request.createElement(paramTagName);
                parentNode.appendChild(paramElement);

                paramElement.nodeName = paramName;
            }
            else
            {
                paramElement = request.createElement(paramName);
                parentNode.appendChild(paramElement);
                if (qname != undefined) {
                    paramElement.nodeName = this.getStringFromQName(paramElement, qname);
                }
            }
        }

        return paramElement;
    }

    function encodeParamValue(valueObj, valueType, elementNode, document)
    {
        var typeAttr = SOAPConstants.SCHEMA_INSTANCE_TYPE;

        if (valueType.typeType == DataType.ARRAY_TYPE)
        {
            // SOAP Array and literal array sequence types
            // handling only single-dimension arrays as input

            var arrayType = valueType.arrayType;
            var numMembers = valueObj.length;

            if (this.myCall.useStyle == SOAPConstants.USE_ENCODED &&
                valueType.isEncodedArray == true)
            {
                var thisType = valueType;
                var attr = "";
                var first = true;
                while (thisType.typeType == DataType.ARRAY_TYPE) {
                    var dims = thisType.dimensions;
                    if (dims.length > 1) {
                        for (var i = 0; i < dims.length; i++) {
                            if (i > 0) attr += ",";
                            attr += dims[i];
                        }
                    } else {
                        if (first) {
                            attr += "[" + numMembers + "]";
                            first = false;
                        } else {
                            attr += "[]";
                        }
                    }
                    thisType = thisType.arrayType;
                }
                elementNode.attributes[SOAPConstants.ARRAY_TYPE_PQNAME] = getStringFromQName(elementNode, valueType.qname) + attr;
                elementNode.attributes[typeAttr] = SOAPConstants.ARRAY_PQNAME;
            }

            for (var i=0; i<numMembers; i++)
            {
                var elName = this.getStringFromQName(elementNode, valueType.itemElement);
                var memberNode = document.createElement(elName);
                var typePrefix = elementNode.getPrefixForNamespace(arrayType.namespaceURI);
                elementNode.appendChild(memberNode);
                this.encodeParamValue(valueObj[i], arrayType, memberNode, document);
            }
            return;
        }

        if (this.myCall.useStyle == SOAPConstants.USE_ENCODED) {
            var dataTypeString;
            var writeDataType = true;

            // See if anyone has hung metadata off the object itself
            if (valueType == undefined)
                valueType = valueObj["__dataType"];

            if ((valueType == undefined) || (valueType.typeType == DataType.ANY_TYPE)) {
                var actualType = typeof valueObj;
                var actualDataType;
                if (actualType == "number") {
                    // TODO : Figure out if it's an int?
                    actualDataType = "double";
                } else if (actualType == "object") {
                    if (valueObj instanceof Date) {
                        actualDataType = "dateTime";
                        valueType = this.myCall.schemaVersion.dateTimeType;
                    } else {
                        valueType = DataType.objectType;
                        writeDataType = false;
                    }
                } else {
                    // Otherwise force it to string
                    actualDataType = "string";
                }
                var prefix = this.getOrCreatePrefix(elementNode, this.myCall.schemaVersion.xsdURI);
                dataTypeString = prefix + ":" + actualDataType;
            } else {
                if (!valueType.isAnonymous) {
                    var prefix = this.getOrCreatePrefix(elementNode, valueType.namespaceURI);
                    dataTypeString = prefix + ":" + valueType.name;
                }
            }

            if (writeDataType && dataTypeString != undefined) {
                elementNode.attributes[typeAttr] = dataTypeString;
            }
        }

        if (valueType.typeType == DataType.MAP_TYPE) {
            this.encodeMap(valueObj, elementNode, document);
        }
        else
        {
            if (valueType.partTypes != undefined)
            {
                // Complex Types
                for (var partName in valueType.partTypes)
                {
                    var partType = valueType.partTypes[partName];
                    var partObj = valueObj[partName];

                    var qname = new QName(partName, partType.namespace);

                    if (partType.isAttribute)
                    {
                        // var realType = partType.realType;
                        // For now, no type checking on attributes (assume strings)
                        elementNode.attributes[partName] = partObj;
                    }
                    else
                    {
                        var partNode = this.encodeParam(partName, partType.schemaType, elementNode, qname);
                        if (partObj != undefined)
                            this.encodeParamValue(partObj, partType.schemaType, partNode, document);
                    }
                }

                if (valueType.simpleValue != undefined) {
                    var valText = document.createTextNode(valueObj._value);
                    elementNode.appendChild(valText);
                }
                return;
            }

            if (valueType.typeType == DataType.DATE_TYPE)
            {
                // Date types get converted to the XML Schema date, time, or dateTime types
                var encodedDate = this.encodeDate(valueObj, valueType);
                var dateNode = document.createTextNode(encodedDate);
                elementNode.appendChild(dateNode);
                return;
            }

            if (valueType.typeType == DataType.OBJECT_TYPE)
            {
                for (var fieldName in valueObj) {
                    var fieldObj = valueObj[fieldName];
                    var fieldType = fieldObj.__dataType;
                    var fieldNode = this.encodeParam(fieldName, fieldType, elementNode);
                    this.encodeParamValue(fieldObj, fieldType, fieldNode, document);
                }
                return;
            }

            else
            {
                // Simple Types
                var valueNode = document.createTextNode(valueObj.toString());
                elementNode.appendChild(valueNode);
            }
        }
    }

    function setupBodyXML(bodyXML)
    {
        this.request.appendChild(bodyXML);
    }

    // -------------------------------------------------------
    // setupParams() takes an array of input objects and encodes
    // them into XML by using a corresponding array of
    // SOAPParameters (which contain schema type information)
    // -------------------------------------------------------
    function setupParams(inputParams)
    {
        var params = this.myCall.parameters;
        var numParams = params.length;
        for (var i=0; i<numParams; i++)
        {
            var param = params[i];
            var paramType = param.schemaType;
            var value;

            if (param.mode != SOAPConstants.MODE_OUT)
            {
                var paramElement = this.encodeParam(param.name, paramType, this.request.soapOperation, param.qname);

                if (inputParams instanceof Array)
                {
                    value = inputParams[i];
                }
                else
                {
                    // this is ony possible for those using SOAPCall directly rather than the WebService APIs:
                    value = inputParams[param.name];
                }
                var schemaType = paramType.schemaType;
                if (schemaType == undefined)
                    schemaType = paramType;

                this.encodeParamValue(value, schemaType, paramElement, this.request);
            }
        }
		this.request.soapOperation = null; //MJR Fix for bug#74567 - Circular reference causes memory leak
		_multiRefs = null; // JW Fix for bug#74567 - attechment of anything to XMLNode or XML will not allow GC cleanup
    }

    function encodeMap(obj, mapNode, document)
    {
        for (var item in obj) {
            var itemNode = document.createElement("item");
            var keyNode = document.createElement("key");
            itemNode.appendChild(keyNode);
            this.encodeParamValue(item, undefined, keyNode, document);

            var valueNode = document.createElement("value");
            itemNode.appendChild(valueNode);
            this.encodeParamValue(obj[item], undefined, valueNode, document);  // todo: define type?

            mapNode.appendChild(itemNode);
        }
    }

    function encodeDate(rawDate, dateType)
    {
        var s = new String();

        if (dateType.name == "dateTime" || dateType.name == "date")
        {
            s = s.concat(rawDate.getUTCFullYear(), "-");

            var n = rawDate.getUTCMonth()+1;
            if (n < 10) s = s.concat("0");
            s = s.concat(n, "-");

            n = rawDate.getUTCDate();
            if (n < 10) s = s.concat("0");
            s = s.concat(n);
        }

        if (dateType.name == "dateTime")
        {
            s = s.concat("T");
        }

        if (dateType.name == "dateTime" || dateType.name == "time")
        {
            var n = rawDate.getUTCHours();
            if (n < 10) s = s.concat("0");
            s = s.concat(n, ":");

            n = rawDate.getUTCMinutes();
            if (n < 10) s = s.concat("0");
            s = s.concat(n, ":");

            n = rawDate.getUTCSeconds();
            if (n < 10) s = s.concat("0");
            s = s.concat(n, ".");

            n = rawDate.getUTCMilliseconds();
            if (n < 10) s = s.concat("00");
            else if (n < 100) s = s.concat("0");
            s = s.concat(n);
        }

        s = s.concat("Z");

        return s;
    }

    function decode(assert, response, callbackMethod)
    {
        this.log.logInfo("Decoding SOAPCall response", Log.VERBOSE);

        var result;

        if (!assert)
        {
            var netFault = new SOAPFault();
            netFault.faultcode = "Server.Connection";
            netFault.faultstring = "Unable to connect to endpoint: " + this.myCall.endpointURI;
            netFault.faultactor = this.myCall.targetNamespace;
            this.fault = netFault;
            this.log.logDebug("No response received from remote service");
        }

        else
        {
            result = this.decodeSOAPEnvelope(response);

            if (this.log.level > Log.BRIEF)
            {
                this.response._decodeTimeMark = new Date();
                this.response._decodeTime = Math.round(this.response._decodeTimeMark - this.response._parseTimeMark);
                this.log.logInfo("Decoded SOAP response into result [" + this.response._decodeTime + " millis]");
            }
        }

        /* Callbacks:
         *  (1) onFault if fault exists OR
         *  (2) onHeader if header exists (NOTE: if callback does not exist and the header
         *      must be understood, a fault will occur and onHeader will not be called) AND
         *  (3) onResult if RPC method succeeded even if it returned void AND
         *  (4) Any user-defined callback regardless of whether the other callbacks were made
         */

        if (this.fault != undefined)
        {
            this.__handleFault(this.fault);

            this.onFault(this.fault, response);
            this.myCall.onFault(this.fault, response);
        }
        else
        {
            if (this.responseHeaders != undefined)
            {
                this.onHeaders(this.responseHeaders, response);
            }
            this.onResult(result, response);            // First our own result handler for this particular invocation
            this.myCall.onResult(result, response);     // Then call onResult on the SOAPCall too

            this.__handleResult(result);                // Do seekrit internal stuff (callbacks for Royale frameworks)
        }

        // and always call a user-defined callback regardless of other callbacks:
        this[callbackMethod](result, response);
    }

    function decodeSOAPEnvelope(response)
    {
        this.log.logDebug("Decoding SOAP response envelope");

        var result;
        var constants = this.soapConstants;
        var envelopeNode = response.firstChild;

        // check for Version mismatch
        if (envelopeNode.getNamespaceURI() != this.soapConstants.ENVELOPE_URI)
        {
            var versionFault = new SOAPFault();
            versionFault.faultcode = "VersionMismatch";
            versionFault.faultstring = "Request implements version: " + this.soapConstants.ENVELOPE_URI +
                                       " Response implements version " + envelopeNode.getNamespaceURI();
            this.fault = versionFault;
        }

        else
        {
            var soapenvPrefix = envelopeNode.getPrefixForNamespace(constants.ENVELOPE_URI);
            var xsiPrefix = envelopeNode.getPrefixForNamespace(this.myCall.schemaVersion.xsiURI);
            var xsdPrefix = envelopeNode.getPrefixForNamespace(this.myCall.schemaVersion.xsdURI);

            var headerPrefixedQName = new PrefixedQName(soapenvPrefix, constants.headerQName);
            var bodyPrefixedQName = new PrefixedQName(soapenvPrefix, constants.bodyQName);
            var faultPrefixedQName = new PrefixedQName(soapenvPrefix, constants.faultQName);

            var envelopeChildren = envelopeNode.childNodes;
            var numEnvChildren = envelopeChildren.length;
            for (var c=0; c<numEnvChildren; c++)
            {
                var envChildNode = envelopeChildren[c];

                // Headers
                if (envChildNode.nodeName == headerPrefixedQName.qualifiedName)
                {
                    this.responseHeaders = this.decodeSOAPHeaders(envChildNode);
                }

                // Body -- do not decode if a fault occurred while processing headers
                else if ((this.fault == undefined) && (envChildNode.nodeName == bodyPrefixedQName.qualifiedName))
                {
                    this.bodyNode = envChildNode; // Save for decoding multirefs
                    if (this.doDecoding) {
                        result = this.decodeSOAPBody(envChildNode, xsiPrefix);
                    } else {
                        result = envChildNode.childNodes;
                    }
                }
            }
        }
        return result;
    }

    function decodeSOAPHeaders(headerNode)
    {
        this.log.logDebug("Decoding SOAP response headers");

        var headers = new Array();
        var headerElements = headerNode.childNodes;
        var numHeaders = headerElements.length;
        for (var i=0; i<numHeaders; i++)
        {
            var headerElement = headerElements[i];
            var mustUnderstand = headerElement.attributes["mustUnderstand"];
            if (mustUnderstand == "1")
            {
                if (typeof(this["onHeader"]) != "function")
                {
                    var headerFault = new SOAPFault();
                    headerFault.faultcode = "MustUnderstand";
                    headerFault.faultstring = "No callback for header " + headerElement.nodeName;
                    this.fault = headerFault;
                    break;
                }
            }
            headers.push(headerElement);
        }
        return headers;
    }

    function decodeSOAPBody(bodyNode, xsiPrefix)
    {
        this.log.logDebug("Decoding SOAP response body");

        var result;
        var responseNode = bodyNode.childNodes[0];

        // Faults
        if (responseNode.getLocalName() == this.soapConstants.faultQName.localPart)
        {
            this.fault = this.decodeSOAPFault(responseNode);
        }

        // Result and Output Parameters
        else
        {
            if (this.myCall.useStyle == SOAPConstants.USE_ENCODED)
            {
                // set the returned values on the output parameters
                var responseChildren = responseNode.childNodes;
                var numResponseChildren = responseChildren.length;
                for (var i=0; i<numResponseChildren; i++)
                {
                    var resultNode = responseChildren[i];

                    //var outParam = this.getOutputParameterByName(resultNode.getLocalName());
                    // for now (SOAP 1.1) if encoded, just match resultNode to the first out param
                    var outParam = this.getOutputParameter(i);

                    var aresult = this.decodeResultNode(resultNode, outParam.schemaType);

                    outParam.value = aresult;

                    if (i == 0)
                    {
                        // make the first output be the result (most platforms support only one output)
                        result = aresult;
                    }
                }
            }

            else
            {
                // response node(s) are output parameters named by param.schemaType.name
                // TODO : This needs work
                var outParam = this.getOutputParameterByQName(responseNode.getQName());
                if (this.myCall.operationStyle == SOAPConstants.WRAPPED_STYLE)
                {
                    for (var ptname in outParam.schemaType.partTypes)
                    {
                        var part = outParam.schemaType.partTypes[ptname];
                        var aresult = this.decodeResultNode(responseNode.childNodes[0], part.schemaType);
                        result = aresult; // takes last one (iter is reversed)
                    }
                }
                else
                {
                    result = this.decodeResultNode(responseNode, outParam.schemaType);
                    outParam.value = result;
                }
            }
        }

        return result;
    }

    function decodeResultNode(resultNode, schemaType, preExistingResult)
    {
        var aresult;

        // if resultElement is a ref to another node, get the other node
        var id = resultNode.attributes.href;
        if (id != undefined)
        {
            resultNode = this.decodeRef(this.bodyNode, id);
            if (resultNode == undefined) {
                // TODO : Fault, no node matching ID
            }
        }

        var schemaVersion = this.myCall.schemaVersion;
        // If this is marked as xsi:nil, return null
        for (var attr in resultNode.attributes)
        {
            // Alas, need to search through this whole list to find an xsi:nil, because the
            // prefix might not be xsi.... (potentially very slow!)
            var qn = resultNode.getQNameFromString(attr);
            if (schemaVersion.nilQName.equals(qn)) {
                var attrVal = resultNode.attributes[attr];
                if (attrVal == "true" || attrVal == "1")
                    return null;
            }
        }

        if (schemaType == undefined || schemaType.typeType == DataType.ANY_TYPE) {
            schemaType = this.getTypeFromNode(resultNode);
        }

        if (schemaType.typeType == DataType.ARRAY_TYPE)
        {
            aresult = this.decodeArrayNode(resultNode, schemaType.arrayType);
        }

        else if (schemaType.typeType == DataType.COLL_TYPE)
        {
            aresult = this.decodeCollectionNode(resultNode, schemaType.arrayType, preExistingResult);
        }

        else if (schemaType.typeType == DataType.XML_TYPE)
        {
            aresult = resultNode;
        }

        else if (schemaType.typeType == DataType.MAP_TYPE)
        {
            aresult = this.decodeMap(resultNode);
        }

        else if (schemaType.typeType == DataType.ROWSET_TYPE)
        {
            aresult = this.decodeRowSet(resultNode);
        }

        else if (schemaType.typeType == DataType.QBEAN_TYPE)
        {
            aresult = this.decodeQueryBean(resultNode);
        }

        else if (schemaType.partTypes != undefined)
        {
            aresult = new Object();

            var i;
            for (i in schemaType.partTypes) {
                if (schemaType.partTypes[i].isAttribute) {
                    aresult[i] = resultNode.attributes[i];
                }
            }

            if (schemaType.simpleValue == undefined) {
                var children = resultNode.childNodes;
                for (i = 0; i < children.length; i++)
                {
                    var partNode = children[i];
                    var partName = partNode.getLocalName();
                    // TODO : we should be looking this up by QName to avoid collisions

                    // Match each child node up with a part.
                    var partType = schemaType.partTypes[partName];
                    if (partType == undefined)
                    {
                        // throw error
                    }

                    // Enable processing multiple copies of the same element (sequences)
                    var existing = aresult[partName];
                    aresult[partName] = this.decodeResultNode(partNode, partType.schemaType, existing);
                }
            } else {
                // This is a simple value, so decode it appropriately.
                aresult._value = this.decodeResultNode(resultNode, schemaType.simpleValue);
            }
        }

        else if (resultNode.childNodes.length == 0) {
            if (schemaType.typeType == DataType.STRING_TYPE)
                aresult = "";
            else
                aresult = null;
        }

        else if ((resultNode.childNodes.length == 1) && (resultNode.childNodes[0].nodeType == 3))
        {
            var outNode = resultNode.childNodes[0];
            var typeType = schemaType.typeType;

            if (schemaType.typeType == DataType.BOOLEAN_TYPE)
            {
                var val = outNode.nodeValue;
                if ((val.toLowerCase() == "true") || (val == "1")) {
                    aresult = true;
                } else {
                    aresult = false;
                }
            }

            else if (schemaType.typeType == DataType.DATE_TYPE)
            {
                aresult = this.decodeDate(outNode.nodeValue);
            }

            else if (schemaType.typeType == DataType.NUMBER_TYPE)
            {
                aresult = Number(outNode.nodeValue);
            }

            else
            {
                aresult = outNode.nodeValue;
            }
        }

        else {
            // Couldn't figure out what to do - just return the raw XML.
            aresult = resultNode;
        }

        return aresult;
    }

    // Get the XML node with the specified ID.  Right now this works relative
    // to a "root" node, which is always in fact the SOAP:Body.  On the first
    // call, we scan all immediate children of the root node, and record all
    // id-decorated ones in a map for quick lookup in the future.  Hang the map
    // off the root node for now.
    //
    // TODO : Walk the whole tree, not just immediate children (SOAP 1.2).
    // TODO : Hang this off the document, not the node, since ID's are unique.
    function decodeRef(rootNode, id)
    {
        id = id.substring(1);
		// removed attachement to rootNode of _multiRefs to fix bug#74567
        if (_multiRefs == null) {
            _multiRefs = new Object();
            var multiRefNodes = rootNode.childNodes;
            var numRefs = multiRefNodes.length;
            for (var i=0; i<numRefs; i++)
            {
                var refnode = multiRefNodes[i];
                var refid = refnode.attributes.id;
                if (refid != undefined)
                {
                     _multiRefs[refid] = refnode;
                }
            }
        }

        return _multiRefs[id];
    }

    function decodeArrayNode(node, arrayType)
    {
        return (this.myCall.useStyle == SOAPConstants.USE_LITERAL)
            ? this.decodeLiteralArrayNode(node, arrayType)
            : this.decodeSOAPArrayNode(node, arrayType);
    }

    function decodeLiteralArrayNode(node, arrayType)
    {
        if (this.doLazyDecoding) {
            return new ArrayProxy(node.childNodes, this, arrayType);
        }

        var arrayObj = new Array();
        var arrayMemberNodes = node.childNodes;
        var numMems = arrayMemberNodes.length;
        for (var i=0; i<numMems; i++)
        {
            arrayObj.push(this.decodeResultNode(arrayMemberNodes[i], arrayType));
        }
        return arrayObj;
    }

    function decodeCollectionNode(node, arrayType, arrayObj)
    {
        if (arrayObj == undefined) arrayObj = new Array();
        arrayObj.push(this.decodeResultNode(node, arrayType));
        return arrayObj;
    }

    function decodeSOAPArrayNode(node, arrayType)
    {
        var dimensions = new Array();
        var arrayTypeString = node.getAttributeByQName(this.soapConstants.soapencArrayTypeQName);
        if (arrayTypeString == undefined) {
            // If there's no arrayType, this factors down to the easy case...
            var ret = this.decodeLiteralArrayNode(node, arrayType);
            return ret;
        }

        var typeFromAttr = this.myCall.schemaContext.getTypeByQName(node.getQNameFromString(arrayTypeString));
        if (typeFromAttr != undefined) {
            arrayType = typeFromAttr;
        }

        var linearIdxHolder = new Array(1);
        linearIdxHolder[0] = 0;

        var arrayObj = decodeArrayContents(node.childNodes, linearIdxHolder, arrayType.dimensions, 0, arrayType);

        return arrayObj;
    }

    function decodeArrayContents(arrayMemberNodes, linearIdxHolder, dimensions, dimensionIdx, arrayType) {
        var thisDim = dimensions[dimensionIdx];
        var arr = new Array();
        if (dimensionIdx == dimensions.length - 1) {
            for (var i = 0; i < thisDim; i++) {
                arr[i] = this.decodeResultNode(arrayMemberNodes[linearIdxHolder[0]++], arrayType.arrayType);
            }
        } else {
            for (var i = 0; i < thisDim; i++) {
                arr[i] = this.decodeArrayContents(arrayMemberNodes, linearIdxHolder, dimensions,
                                                  dimensionIdx + 1, arrayType.arrayType);
            }
        }
        return arr;
    }

    // Custom deserialization for rowsets, which look like this:
    //
    // <rowSet>
    //   <fields>
    //     <field type="xsd:string">Field1</field>
    //     <field type="xsd:int">Field2</field>
    //   </fields>
    //   <data>
    //    <item>
    //     <d>a string</d>
    //     <d>52</d>
    //    </item>
    //   </data>
    // </rowSet>
    //
    // (That would decode into an Array with a single object {Field1 : "a string", Field2 : 52})
    //
    function decodeRowSet(rowSetNode) {
        var returnVal = new Array();

        var types = new Array();
        var fields = new Array();

        var descriptorNodes = rowSetNode.childNodes[0].childNodes;
        var numCols = descriptorNodes.length;
        // First child is array of names and types
        for (var i = 0; i < numCols; i++) {
            var node = descriptorNodes[i];
            var typeAttr = node.attributes["type"];
            if (typeAttr == undefined) return;
            var typeQName = node.getQNameFromString(typeAttr);
            if (typeQName == undefined) return;
            types[i] = this.myCall.schemaContext.getTypeByQName(typeQName);
            fields[i] = node.childNodes[0].nodeValue;
        }

        var itemNodes = rowSetNode.childNodes[1].childNodes;
        var numItems = itemNodes.length;

        if (this.doLazyDecoding) {
            return new RowSetProxy(this, itemNodes, types, fields);
        }

        // Next child is array of items, each of which is an array of fields
        for (var i = 0; i < numItems; i++) {
            returnVal[i] = this.decodeRowSetItem(itemNodes[i], types, fields);
        }

        return returnVal;
    }

    function decodeQueryBean(beanNode) {
        var returnVal = new Array();

        var fields = new Array();

        var colNode = beanNode.getElementsByLocalName("columnList")[0];
        if (colNode == undefined)
            return; // error

        var numCols = colNode.childNodes.length;
        for (var j = 0; j < numCols; j++) {
            var thisNode = colNode.childNodes[j];
            fields[j] = thisNode.childNodes[0].nodeValue;
        }

        var dataNode = beanNode.getElementsByLocalName("data")[0];
        if (dataNode == undefined)
            return; // error

        // This is an array of arrays - each array will contain
        // fields.length elements, which should be associated with
        // the fields of our result
        var data = this.decodeSOAPArrayNode(dataNode);
        for (var j = 0; j < data.length; j++) {
            var item = data[j];
            var resultItem = new Object();
            for (var f = 0; f < fields.length; f++) {
                resultItem[fields[f]] = item[f];
            }
            returnVal[j] = resultItem;
        }

        return returnVal;
    }

    function decodeRowSetItem(itemNode, types, fields) {
        var colNodes = itemNode.childNodes;
        var value = new Object();
        var numCols = types.length;
        for (var j = 0; j < numCols; j++) {
            var colNode = colNodes[j];
            value[fields[j]] = this.decodeResultNode(colNode, types[j]);
        }
        return value;
    }

    function decodeMap(node) {
        var returnVal = new Object();

        var itemNodes = node.childNodes;
        // Each node has a key and a value subnode
        for (var i = 0; i < itemNodes.length; i++) {
            var childNodes = itemNodes[i].childNodes;
            var _key;
            var _value;
            for (var j = 0; j < childNodes.length; j++) {
                var child = childNodes[j];
                if (child.nodeName == "key") {
                    _key = this.decodeResultNode(child);
                } else if (child.nodeName == "value") {
                    _value = this.decodeResultNode(child);
                } else {
                    // TODO : Fault here!
                }
            }
            returnVal[_key] = _value;
        }

        return returnVal;
    }

    function getTypeFromNode(node) {
        // TODO : Fix this not to care about the xsi: prefix (will be slower,
        // but correct)!
        var typeAttr = node.attributes["xsi:type"];
        if (typeAttr == undefined) return;
        var typeQName = node.getQNameFromString(typeAttr);
        if (typeQName == undefined) return;
        return this.myCall.schemaContext.getTypeByQName(typeQName);
    }

    function decodeDate(rawValue)
    {
        var d;

        var datePart;
        var timePart;

        var sep = rawValue.indexOf("T");
        var tsep = rawValue.indexOf(":");
        var dsep = rawValue.indexOf("-");
        if (sep != -1)
        {
            datePart = rawValue.substring(0, sep);
            timePart = rawValue.substring(sep+1);
        }
        else if (tsep != -1)
        {
            timePart = rawValue;
        }
        else if (dsep != -1)
        {
            datePart = rawValue;
        }

        if (datePart != undefined)
        {
            var year = datePart.substring(0, datePart.indexOf("-"));
            var month = datePart.substring(5, datePart.indexOf("-", 5));
            var day = datePart.substring(8, 10);
            d = new Date(Date.UTC(year, month - 1, day));
        } else {
            d = new Date();
        }

        if (timePart != undefined)
        {
            // check for timezone offset
            var tz = "Z";
            var hourOffset = 0;
            if (datePart.length > 10)
            {
                tz = datePart.substring(10);
            }
            else if (timePart.length > 12)
            {
                tz = timePart.substring(12);
            }
            if (tz != "Z")
            {
                var len = tz.length;
                hourOffset = tz.substring((len - 5), (len - 3));
                if (tz.charAt(len - 6) == '+')
                    hourOffset = 0 - hourOffset;
            }
            var hours = Number(timePart.substring(0, timePart.indexOf(":")));
            var minutes = timePart.substring(3, timePart.indexOf(":", 3));
            var seconds = timePart.substring(6, timePart.indexOf(".", 6));
            var millis = timePart.substr(9, 3);
            d.setUTCHours(hours, minutes, seconds, millis);
                d = new Date(d.getTime() + (hourOffset * 3600000));
        }

        return d;
    }

    function decodeSOAPFault(faultNode)
    {
        this.log.logDebug("SOAP: Decoding SOAP response fault");

        var fault = new SOAPFault();
        fault.element = faultNode;

        var faultChildren = faultNode.childNodes;
        var numFaultChildren = faultChildren.length;
        for (var i=0; i<numFaultChildren; i++)
        {
            var faultInfo = faultChildren[i];
            if (faultInfo.nodeName == "faultcode")
            {
                fault.faultcode = faultInfo.childNodes[0].toString();
            }
            else if (faultInfo.nodeName == "faultstring")
            {
                fault.faultstring = faultInfo.childNodes[0].toString();
            }
            else if (faultInfo.nodeName == "faultactor")
            {
                fault.faultactor = faultInfo.childNodes[0].toString();
            }
            else if (faultInfo.nodeName == "detail")
            {
                fault.detail = faultInfo;
            }
        }
        return fault;
    }

	/**
	  @helpid	1732
	  @tiptext  return the output parameter at the index specified
	*/
    function getOutputParameter(index)
    {
        return this.getOutputParameters()[index];
    }

	/**
	  @helpid	1731
	  @tiptext  return output parameter for the specified name
	*/
    function getOutputParameterByName(localName)
    {
        var params = this.getOutputParameters();
        var paramLen = params.length;
        for (var i=0; i<paramLen; i++)
        {
            var param = params[i];
            if (param.name == localName)
            {
                return param;
            }
        }
    }

    function getOutputParameterByQName(qname)
    {
        var params = this.getOutputParameters();
        var paramLen = params.length;
        for (var i=0; i<paramLen; i++)
        {
            var paramQName = params[i].qname;
            if (paramQName != undefined)
            {
                if (paramQName.localPart == qname.localPart &&
                    paramQName.namespaceURI == qname.namespaceURI)
                    return params[i];
            }
        }
    }

	/**
	  @helpid	1730
	  @tiptext  return all members of the parameters array that are either OUT or INOUT mode
	*/
    function getOutputParameters()
    {
        // return all members of the parameters array that are either OUT or INOUT mode
        var outputParams = new Array();
        var parameters = this.myCall.parameters;
        var paramLen = parameters.length;
        for (var i=0; i<paramLen; i++)
        {
            var param = parameters[i];
            if (param.mode != SOAPConstants.MODE_IN)
            {
                outputParams.push(param);
            }
        }
        return outputParams;
    }
	/**
	  @helpid	1729
	  @tiptext  returns a single output value
	*/
	
    function getOutputValue(index)
    {
        return this.getOutputValues()[index];
    }

	/**
	  @helpid	1728
	  @tiptext  returns values of the output parameters
	*/
    function getOutputValues()
    {
        // return the values of the output parameters rather than the
        // parameter objects themselves
        var outputValues = new Array();
        var allParams = this.myCall.parameters;
        var paramLen = allParams.length;
        for (var i=0; i<paramLen; i++)
        {
            var param = allParams[i];
            if (param.mode != SOAPConstants.MODE_IN)
            {
                outputValues.push(param.value);
            }
        }
        return outputValues;
    }


    function getInputParameter(index)
    {
        return this.getInputParameters()[index];
    }

    function getInputParameters()
    {
        // return all members of the parameters array that are either OUT or INOUT mode
        var inputParams = new Array();
        var parameters = this.myCall.parameters;
        var paramLen = parameters.length;
        for (var i=0; i<paramLen; i++)
        {
            var param = parameters[i];
            if (param.mode != SOAPConstants.MODE_OUT)
            {
                inputParams.push(param);
            }
        }
        return inputParams;
    }
	
	private var _multiRefs:Object; // JW fix for bug#74567
}
