// ------------------------------------------------------------
// XML SCHEMA PARSER
// ------------------------------------------------------------
// Reads a schema document, and converts it to a set of
// ActionScript object types. Two objects: XMLSchema and
// XMLSchemaParser.
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------
//
// SOME ISSUES / TODOS WITH THIS CODE:
//
// [1]
// We always refer to (and also serialize) sub-elements with just a localName,
// therefore we don't support:
// <element name="foo">
//   <complexType>
//     <sequence>
//       <element ref="otherns:bar" xmlns:otherns="some-other-namespace"/>
//       ...
//
// [2] (related to [1])
// We don't deal with name collisions - what happens when either an element/
// attribute name clashes with an ActionScript reserved word, or when we have
// both an element and an attribute (or an element in another ns) with the
// same name?  We should be mangling names when this occurs, and allowing
// the use of XPath expressions (i.e. "xpath(obj, '@attr')" or something) to
// differentiate.
//

////////////////////////////////////////////////////////////////////////////

import mx.services.DataType;
import mx.services.ElementDecl;
import mx.services.QName;
import mx.services.SchemaContext;
import mx.services.SchemaVersion;
//import mx.services.SOAPFault;

// -------------
// SCHEMA OBJECT
// -------------
class mx.services.Schema
{
    static function getSchemas(xmlDocument)
    {
        // this convenience method looks only to the root and immediate root child nodes
        // for schemas, and parses them. Intended to parse arbitrary documents, not schemas
        // embedded in documents (such as WSDL). Parsers of embedded docs must create their own
        // SchemaParsers and send the parser the schema element (the WSDL object does this).

        var schemas = new Array();

        // TODO : Implement if needed

        return schemas;
    }

    var targetNamespace;
    var rootElement;
    var context:SchemaContext;
    var schemaVersion:SchemaVersion;
    var types:Object;
    var elements:Object;
    var elementFormDefault;

    public function Schema(targetNamespace, rootElement, schemaContext)
    {
        this.targetNamespace = targetNamespace;
        this.rootElement = rootElement;
        this.context = schemaContext;
        this.schemaVersion = schemaContext.schemaVersion;

        this.types = new Object();
        this.elements = new Object();
    }

    public function registerType(dtype) {
        if (this.types[dtype.name] == undefined)
            this.types[dtype.name] = dtype;
    }

    public function registerElement(elementObj) {
        this.elements[elementObj.name] = elementObj;
    }

    public function parseType(localPart) {
        // could be dealing with an element in a type that references an as-yet unparsed type
        var unparsedTypeNode = this.rootElement.getElementsByReferencedName(localPart,
                                this.schemaVersion.complexTypeQName)[0];
        if (unparsedTypeNode != undefined)
        {
            return this.parseComplexType(unparsedTypeNode);
        }

        unparsedTypeNode = this.rootElement.getElementsByReferencedName(localPart,
                                this.schemaVersion.simpleTypeQName)[0];
        if (unparsedTypeNode != undefined)
        {
            return this.parseSimpleType(unparsedTypeNode);
        }
    }

    public function parseElement(name) {
        var unparsedElementNode = this.rootElement.getElementsByReferencedName(name,
                                this.schemaVersion.elementTypeQName)[0];
        if (unparsedElementNode != undefined)
        {
            var ret = this.parseElementDecl(unparsedElementNode);
            this.registerElement(ret);
            return ret;
        }
    }

    public function parseComplexType(typeNode, isAnonymous)
    {
        var typeObj = new DataType(); // Default data type for now

        var typeName = typeNode.attributes["name"];

        // We register the type object before parsing the inner content, so
        // that we catch any circular references while parsing.
        if (!isAnonymous) {
            typeObj.name = typeName;
            typeObj.namespaceURI = this.targetNamespace;
            typeObj.qname = new QName(typeName, this.targetNamespace);

            this.registerType(typeObj);
        } else {
            typeObj.isAnonymous = true;
        }

        var typeChildren = typeNode.childNodes;
        var numChildren = typeChildren.length;
        for (var i=0; i<numChildren && this.context.fault == undefined; i++)
        {
            var n = typeChildren[i];
            var nname = n.getQName();

            if (nname.equals(this.schemaVersion.allQName))
            {
                this.parseAll(n, typeObj);
            }
            else if (nname.equals(this.schemaVersion.complexContentQName))
            {
                this.parseComplexContent(n, typeObj);
            }
            else if (nname.equals(this.schemaVersion.simpleContentQName))
            {
                this.parseSimpleContent(n, typeObj);
            }
            else if (nname.equals(this.schemaVersion.sequenceQName))
            {
                this.parseSequence(n, typeObj);
            }
            else if (nname.equals(this.schemaVersion.attributeQName))
            {
                this.parseAttribute(n, typeObj);
            }
        }

        typeNode.parsed = 1;

        return typeObj;
    }

    public function parseSimpleType(typeNode, isAnonymous)
    {
        var typeObj = new DataType(); // Default data type for now

        var typeName = typeNode.attributes["name"];

        // We register the type object before parsing the inner content, so
        // that we catch any circular references while parsing.
        if (!isAnonymous) {
            typeObj.name = typeName;
            typeObj.namespaceURI = this.targetNamespace;
            typeObj.qname = new QName(typeName, this.targetNamespace);

            this.registerType(typeObj);
        } else {
            typeObj.isAnonymous = true;
        }

        var typeChildren = typeNode.childNodes;
        var numChildren = typeChildren.length;
        for (var i=0; i<numChildren; i++)
        {
            var n = typeChildren[i];
            var nname = n.getQName();

            if (nname.equals(this.schemaVersion.restrictionQName))
            {
                var baseTypeName = n.attributes.base;
                var baseQName = n.getQNameFromString(baseTypeName);
                var baseDataType = this.context.getTypeByQName(baseQName);

                typeObj.typeType = baseDataType.typeType;
            }
        }

        typeNode.parsed = 1;

        return typeObj;
    }

    public function parseAll(allNode, typeObj)
    {
        return this.parseSequence(allNode, typeObj);
    }

    function parseElementDecl(elementNode)
    {
        var elementObj = new ElementDecl();
        var dtype;

        if (elementNode.attributes.ref != undefined)
        {
            // This is a reference to another element, so go get that one's definition
            var refStr = elementNode.attributes.ref;
            var refQName = elementNode.getQNameFromString(refStr);
            var refDecl = this.context.getElementByQName(refQName);
            elementObj.name = refDecl.name;
            elementObj.schemaType = refDecl.schemaType;
            elementObj.form = refDecl.form;
            elementObj.namespace = refDecl.namespace;
            elementObj.minOccurs = elementNode.attributes.minOccurs;
            elementObj.maxOccurs = elementNode.attributes.maxOccurs;
            return elementObj;
        }

        var elementName = elementNode.attributes["name"];
        // TODO : complain if no name attribute?
        elementObj.name = elementName;

        if (elementNode.attributes.type != undefined)
        {
            var typeQName = elementNode.getQNameFromString(elementNode.attributes.type, true);
            dtype = this.context.getTypeByQName(typeQName);
        }
        else
        {
            var ctNode = elementNode.getElementsByQName(this.schemaVersion.complexTypeQName)[0];
            if (ctNode != null)
            {
                dtype = this.parseComplexType(ctNode, true);
            }
            else
            {
                var stNode = elementNode.getElementsByQName(this.schemaVersion.simpleTypeQName)[0];
                if (stNode != null)
                {
                    dtype = this.parseSimpleType(stNode, true);
                }
            }
        }

        elementObj.schemaType = dtype;
        elementObj.minOccurs = elementNode.attributes.minOccurs;
        elementObj.maxOccurs = elementNode.attributes.maxOccurs;

        var form = elementNode.attributes.form;
        if (form == undefined) {
            form = this.elementFormDefault;
        }
        elementObj.form = form;
        if (form == "qualified") {
            elementObj.namespace = this.targetNamespace;
        } else {
            elementObj.namespace = "";
        }

        return elementObj;
    }

    function parseAttribute(attrNode, typeObj)
    {
        var attrName = attrNode.attributes["name"];

        var attrObj = new Object();
        // TODO : complain if no name attribute?
        attrObj.name = attrName;

        var typeStr = attrNode.attributes.type;
        if (typeStr != undefined) {
            var typeQName = attrNode.getQNameFromString(typeStr, true);
            var dtype = this.context.getTypeByQName(typeQName);
            if (dtype != undefined) {
                if (typeObj.partTypes == undefined) {
                    typeObj.partTypes = new Object();
                }
                // Make a wrapper "type" to indicate this is an attribute
                var attrType = new Object();
                attrType.isAttribute = true;
                attrType.schemaType = dtype;
                // TODO : check for name collision, if so punt/mangle both names
                typeObj.partTypes[attrName] = attrType;
            }
        }
    }

    function parseSequence(sequenceNode, dtype)
    {
        // children are all elements that should become properties of the new object

        var objProps = sequenceNode.childNodes;
        var numProps = objProps.length;

        // preserve sequence order in the assoc. array by starting at the end
        for (var i=(numProps-1); i>-1; i--)
        {
            var objPropNode = objProps[i];
            var elDecl = this.parseElementDecl(objPropNode);

            var propDataType = elDecl;
//            propDataType.schemaType = elDecl.type;

            // SPECIAL CASE FOR .NET-STYLE "ARRAYS"
            // When we see a single subelement with maxOccurs "unbounded", we
            // represent the enclosing element/type as an array.  We should have
            // a switch to turn this off.
            if ((numProps == 1) && (elDecl.maxOccurs == "unbounded"))
            {
                // .NET-style ArrayOfSomething
                dtype.name = "array";
                dtype.typeType = DataType.ARRAY_TYPE;
                dtype.arrayType = propDataType.schemaType;
                dtype.itemElement = new QName(elDecl.name, elDecl.namespace);
            }
            else
            {
                if (elDecl.maxOccurs == "unbounded")
                {
                    var arrayType = new DataType("array", DataType.ARRAY_TYPE);
                    arrayType.arrayType = propDataType.schemaType;
                    propDataType = arrayType;
                    propDataType.itemElement = new QName(elDecl.name, elDecl.namespace);
                }

                if (dtype.partTypes == undefined)
                {
                    dtype.partTypes = new Object();
                }
                dtype.partTypes[elDecl.name] = propDataType;
            }
        }

        return dtype;
    }

    function parseSimpleContent(contentNode, typeObj)
    {
        var extensionNode = contentNode.firstChild;

        // Only supports 'extension' right now
        if (!extensionNode.getQName().equals(this.schemaVersion.extensionQName)) {
            return; // TODO : Fault
        }

        var baseTypeName = extensionNode.attributes.base;
        var baseQName = extensionNode.getQNameFromString(baseTypeName, true);
        var baseDataType = this.context.getTypeByQName(baseQName);

        if (typeObj.partTypes == undefined)
            typeObj.partTypes = new Object();

        // Store the base data type in a special field
        typeObj.simpleValue = baseDataType;

        // Get the attribute definitions inside the <extension> element
        var attrNodes = extensionNode.childNodes;
        for (var i = 0; i < attrNodes.length; i++) {
            this.parseAttribute(attrNodes[i], typeObj);
        }
    }

    function parseComplexContent(contentNode, typeObj)
    {
        var myChildren = contentNode.childNodes;
        var numChildren = myChildren.length;
        for (var i=0; i<numChildren && this.context.fault == undefined; i++)
        {
            var n = myChildren[i];
            var nname = n.getQName();

            if (nname.equals(this.schemaVersion.restrictionQName))
            {
                return this.parseRestriction(n, typeObj);
            }

            if (nname.equals(this.schemaVersion.extensionQName))
            {
                return this.parseExtension(n, typeObj);
            }
        }
    }

    function parseExtension(extensionNode, typeObj)
    {
        var baseTypeName = extensionNode.attributes.base;
        var baseQName = extensionNode.getQNameFromString(baseTypeName);

        var baseDataType = this.context.getTypeByQName(baseQName);

        // Fill in our type with everything from the parent type, then add
        // more below.
        typeObj.typeType = baseDataType.typeType;
        typeObj.partTypes = new Object();
        for (var f in baseDataType.partTypes) {
            typeObj.partTypes[f] = baseDataType.partTypes[f];
        }

        var myChildren = extensionNode.childNodes;
        var numChildren = myChildren.length;
        for (var i=0; i<numChildren && this.context.fault == undefined; i++)
        {
            var n = myChildren[i];
            var nname = n.getQName();

            if (nname.equals(this.schemaVersion.sequenceQName))
            {
                return this.parseSequence(n, typeObj);
            }
        }
    }

    function parseRestriction(restrictionNode, derivedType)
    {
        var baseTypeName = restrictionNode.attributes.base;
        var baseQName = restrictionNode.getQNameFromString(baseTypeName);

        var baseDataType = this.context.getTypeByQName(baseQName);

        derivedType.name = "derived" + baseDataType.name;
        derivedType.typeType = baseDataType.typeType;
        derivedType.namespaceURI = baseDataType.namespaceURI;
        if (baseDataType.typeType == DataType.ARRAY_TYPE) {
            // Keep track of encoding if Array
            derivedType.isEncodedArray = baseDataType.isEncodedArray;
            derivedType.itemElement = baseDataType.itemElement;
        }

        // supports only 'attribute' children of restriction element:
        var attrNodes = restrictionNode.getElementsByQName(this.schemaVersion.attributeQName);
        for (var i=0; i<attrNodes.length; i++)
        {
            var attrNode = attrNodes[i];
            var attrRef = attrNode.attributes.ref; // attribute in base element that this restr modifies
            if (attrRef.indexOf(":") != -1)
            {
                attrRef = attrRef.substring((attrRef.indexOf(":"))+1); // arrayType
            }

            for (var attr in attrNode.attributes)
            {
                var ln = attr;
                if (ln.indexOf(":") != -1)
                {
                    ln = ln.substring((ln.indexOf(":"))+1);
                }
                if (ln == attrRef)
                {
                    var attrRestriction = attrNode.attributes[attr];
                    var attrQName = attrNode.getQNameFromString(attrRestriction, true);
                    var typeRestriction = this.context.getTypeByQName(attrQName);
                    if (typeRestriction != undefined)
                    {
                        derivedType[ln] = typeRestriction[ln];
                        derivedType.name = typeRestriction.name;
                        derivedType.qname = typeRestriction.qname;
                        derivedType.namespaceURI = typeRestriction.namespaceURI;
                    }
                    else
                    {
                        derivedType[ln] = attrRestriction;
                    }
                }
            }
        }

        return derivedType;
    }
}
