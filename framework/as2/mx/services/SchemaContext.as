// --------------
// SCHEMA CONTEXT
// --------------
// A SchemaContext is a container for Schemas, indexed by targetNamespace.
// You can load up a SchemaContext with schemas from, for instance, a WSDL
// document, and then use it to reference types and elements by QName.
import mx.services.DataType;
import mx.services.Log;
import mx.services.QName;
import mx.services.Schema;
import mx.services.SchemaVersion;
import mx.services.SOAPConstants;
import mx.services.SOAPFault;

class mx.services.SchemaContext
{
    static function RegisterSchemaTypes(schemaObj, schemaVersion)
    {
        var schemaNS = schemaVersion.xsdURI;

        // BOOLEAN BUILT-IN TYPE
        schemaObj.registerType(new DataType("boolean", DataType.BOOLEAN_TYPE, schemaNS));

        // STRING AND NAME BUILT-IN TYPES
        schemaObj.registerType(new DataType("string", DataType.STRING_TYPE, schemaNS));

        // NUMERIC BUILT-IN TYPES
        schemaObj.registerType(new DataType("decimal", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("integer", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("negativeInteger", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("nonNegativeInteger", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("positiveInteger", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("nonPositiveInteger", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("long", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("int", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("short", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("byte", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("unsignedLong", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("unsignedInt", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("unsignedShort", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("unsignedByte", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("float", DataType.NUMBER_TYPE, schemaNS));
        schemaObj.registerType(new DataType("double", DataType.NUMBER_TYPE, schemaNS));

        // DATE BUILT-IN TYPES
        schemaObj.registerType(new DataType("date", DataType.DATE_TYPE, schemaNS));

        var dateTimeType = new DataType("dateTime", DataType.DATE_TYPE, schemaNS);
        schemaVersion.dateTimeType = dateTimeType;   // Save for later
        schemaObj.registerType(dateTimeType);

        schemaObj.registerType(new DataType("time", DataType.DATE_TYPE, schemaNS));

        // BINARY TYPES ADDED FOR COMPREHENSIVENESS
        // Actually using these would require some custom code from a developer
        schemaObj.registerType(new DataType("base64Binary", DataType.OBJECT_TYPE, schemaNS));
        schemaObj.registerType(new DataType("hexBinary", DataType.OBJECT_TYPE, schemaNS));

        schemaObj.registerType(new DataType("token", DataType.STRING_TYPE, schemaNS));
        schemaObj.registerType(new DataType("normalizedString", DataType.STRING_TYPE, schemaNS));

        // THE ANY TYPE
        schemaObj.registerType(new DataType("anyType", DataType.ANY_TYPE, schemaNS));

        // TYPES SPECIFIC TO PARTICULAR SCHEMA VERSIONS
        if (schemaNS == SchemaVersion.XSD_URI_1999) {
            schemaObj.registerType(new DataType("timeInstant", DataType.DATE_TYPE, schemaNS));
        }
    }

    static function RegisterStandardTypes(schemaObj)
    {
        RegisterSchemaTypes(schemaObj, SchemaVersion.getSchemaVersion(SchemaVersion.XSD_URI_1999));
        RegisterSchemaTypes(schemaObj, SchemaVersion.getSchemaVersion(SchemaVersion.XSD_URI_2000));
        RegisterSchemaTypes(schemaObj, SchemaVersion.getSchemaVersion(SchemaVersion.XSD_URI_2001));

        // SOAP-ENCODING TYPES
        schemaObj.registerType(new DataType("string", DataType.STRING_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("int", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("integer", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("long", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("short", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("byte", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("decimal", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("float", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("base64", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("double", DataType.NUMBER_TYPE, SchemaVersion.SOAP_ENCODING_URI));
        schemaObj.registerType(new DataType("boolean", DataType.BOOLEAN_TYPE, SchemaVersion.SOAP_ENCODING_URI));

        var soapArray = new DataType("Array", DataType.ARRAY_TYPE, SchemaVersion.SOAP_ENCODING_URI);
        soapArray.arrayType = new DataType("any", DataType.ANY_TYPE, SchemaVersion.SOAP_ENCODING_URI);
        soapArray.arrayDimensions = 1; // single-dimension by default
        soapArray.isEncodedArray = true; // Encoded
        soapArray.itemElement = new QName("item"); // Default item element name
        schemaObj.registerType(soapArray);

        // Apache Map type
        schemaObj.registerType(new DataType("Map", DataType.MAP_TYPE, SchemaVersion.APACHESOAP_URI));

        // Our RowSet type
        schemaObj.registerType(new DataType("RowSet", DataType.ROWSET_TYPE, SchemaVersion.APACHESOAP_URI));
        
        // ColdFusion QueryBean
        schemaObj.registerType(new DataType("QueryBean", DataType.QBEAN_TYPE, SchemaVersion.CF_RPC_URI));
    }


    var log:Log;
    var schemas:Object;
    var schemaVersion;
    var unresolvedImports:Number;
    var fault : SOAPFault;

    function SchemaContext(logObj)
    {
        this.log = logObj;
        this.schemas = new Object();
    }

    function registerSchemaNode(rootElement, document)
    {
        var qname = rootElement.getQName();
        if (qname.localPart != "schema")
            return;  // TODO : fault with an "unknown type system" error

        var schemaVersion = SchemaVersion.getSchemaVersion(qname.namespaceURI);
        if (schemaVersion == undefined)
            return; // TODO : "unknown schema version"

        this.schemaVersion = schemaVersion;

        if ((rootElement.getQName()).equals(schemaVersion.schemaQName))
        {
            var namespaceURI = rootElement.attributes.targetNamespace;
            this.processImports(rootElement, schemaVersion, document);
            return this.registerNamespace(namespaceURI, rootElement);
        } else {
            // TODO : Fault with a "bad schema node" error
        }
    }

    function processImports(rootElement, schemaVersion, document) {
        var imports = rootElement.getElementsByQName(schemaVersion.importQName);
        if (imports != undefined) {
            for (var i = 0; i < imports.length; i++) {
                var location = imports[i].attributes.schemaLocation;
                // We can only import if we know where to import from...
                // Eventually might want to have a library of known namespaces
                // so we can confirm imports of XSD, SOAPENC, etc.
                if (location != undefined) {
                    // Rationalize for relative URLs
                    location = this.buildURL(location, document.location);

                    var namespace = imports[i].attributes.namespace;
                    this.importDocument(location, namespace);
                }
            }
        }
    }

    // Import a document from the given location with the given namespaceURI.
    // Note that this increments this.unresolvedImports, which will delay processing
    // until all imports are loaded.
    function importDocument(location, namespaceURI) {
        var importDoc = new XML();
        importDoc.ignoreWhite = true;
        importDoc.schemaContext = this;
        importDoc.namespace = namespaceURI;
        importDoc.location = location;
        this.unresolvedImports++;
        this.fetchDocument(importDoc);
    }

    function fetchDocument(document) {
        document.onData = function(src)
        {
            if (src == undefined)
            {
                this.fault = new SOAPFault(SOAPConstants.DISCONNECTED_FAULT_CODE,
                                    "Could not load imported schema",
                                    "Unable to load schema, if currently online, please verify " +
                                    "the URI and/or format of the schema at (" + this.schemaURI + ")");
                this.log.logDebug("Unable to receive WSDL file");
            } else {
                this.unresolvedImports--;
                this.registerSchemaNode(document.firstChild, document);
            }
        };

        // HTTP GET operation to retrieve WSDL document:
        document.load(document.location, "GET");
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

    function registerNamespace(namespaceURI, rootElement) {
        this.log.logInfo("Registering schema namespace: " + namespaceURI, Log.VERBOSE);

        if (this.schemas[namespaceURI] != undefined) {
            this.log.logInfo("Duplicate namespace!");
            return;
        }

        var schemaHolder = new Schema(namespaceURI, rootElement, this);

        this.schemas[namespaceURI] = schemaHolder;

        // Default for efd is "unqualified", only set it if "qualified"
        var efd = rootElement.attributes.elementFormDefault;
        if (efd != undefined && efd == "qualified") {
            schemaHolder.elementFormDefault = "qualified";
        }
        return schemaHolder;
    }

    function registerType(dtype)
    {
        var namespaceURI = dtype.namespaceURI;

        var schemaHolder = this.schemas[namespaceURI];
        if (schemaHolder == undefined)
            schemaHolder = this.registerNamespace(namespaceURI);

        if (schemaHolder.types[dtype.name] == undefined)
            schemaHolder.types[dtype.name] = dtype;
    }

    function registerElement(elemObj)
    {
        var namespaceURI = elemObj.namespaceURI;
        var schemaHolder = this.schemas[namespaceURI];
        if (schemaHolder == undefined)
            schemaHolder = this.registerNamespace(namespaceURI);

        if (elemObj.form == undefined)
            elemObj.form = schemaHolder.elementFormDefault;

        schemaHolder.elements[elemObj.name] = elemObj;
    }

    function getElementByQName(elQName)
    {
        var schemaHolder = this.schemas[elQName.namespaceURI];
        if (schemaHolder != undefined)
        {
            var elementObj = schemaHolder.elements[elQName.localPart];
            if (elementObj == undefined) {
                elementObj = schemaHolder.parseElement(elQName.localPart);
                if (elementObj == undefined) {
                    // TODO : Fatal fault!
                }
            }
            return elementObj;
        }
    }

    function getTypeByQName(typeQName)
    {
        var schemaHolder = this.schemas[typeQName.namespaceURI];
        if (schemaHolder != undefined)
        {
            var localPart = typeQName.localPart;
            var dimIndex = localPart.indexOf("[");
            if (dimIndex != -1)
            {
                // return an array type of the requested type with the specified dimensions

                var ln = localPart.substring(0, dimIndex);
                var arrayType = this.getTypeByQName(new QName(ln, typeQName.namespaceURI));

                var dimString = localPart.substring(dimIndex);
                var startIdx = 0;
                while (startIdx != -1) {
                    var dimensions = new Array();

                    startIdx++;

                    var nextComma = dimString.indexOf(",", startIdx);
                    while (nextComma != -1) {
                        // collect this dimension
                        var thisDim = Number(dimString.substring(startIdx, nextComma));
                        dimensions.push(thisDim);
                        startIdx = nextComma + 1;
                        nextComma = dimString.indexOf(",", startIdx);
                    }
                    // last dimension ends with "]" instead of ","
                    var closeBracket = dimString.indexOf("]", startIdx);
                    if (closeBracket == -1) {
                        // TODO : fault, bad arrayType string
                    }
                    if (closeBracket == startIdx) {
                        dimensions.push(-1); // no fixed index, use 'em all
                    } else {
                        var lastDim = Number(dimString.substring(startIdx, closeBracket));
                        dimensions.push(lastDim);
                    }

                    var nextType = new DataType(arrayType.name, DataType.ARRAY_TYPE, arrayType.namespaceURI);
                    nextType.isEncodedArray = true;
                    nextType.arrayType = arrayType;
                    nextType.itemElement = new QName("item");
                    nextType.dimensions = dimensions;
                    arrayType = nextType;

                    startIdx = dimString.indexOf("[", closeBracket);
                }

                return arrayType;
            }

            var returnType = schemaHolder.types[localPart];
            if (returnType != undefined)
                return returnType;

            returnType = schemaHolder.parseType(localPart);
            if (returnType == undefined) {
                // TODO : Fatal fault!
            }

            return returnType;
        }
    }

    function getType(qualifiedName, node)
    {
        var prefix = "";
        var localPart = qualifiedName;
        var n = qualifiedName.indexOf(":");
        if (n != -1)
        {
            prefix = qualifiedName.substring(0, n);
            localPart = qualifiedName.substring(n+1);
        }

        var namespaceURI = node.getNamespaceForPrefix(prefix);
        return this.getTypeByQName(localPart, namespaceURI, node);
    }
}