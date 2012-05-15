// ------------------------------------------------------------
// BASIC NAMESPACE SUPPORT FOR ACTIONSCRIPT XML OBJECTS
// http://www.w3.org/TR/REC-xml-names/
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------

import mx.services.PrefixedQName;
import mx.services.QName;

// ------------------------------------------------------------
// Update XMLNode prototype with namespace properties
// ------------------------------------------------------------
class mx.services.Namespace
{
    static var alreadySetup:Boolean = false;
    static var _doc = new XML();

    public static function setup() {
        if (alreadySetup)
            return;

        alreadySetup = true;

        var o = XMLNode.prototype;

        if (o.getQName == undefined) {
            o.getQName = function()
            {
                if (this.prefixedQName != undefined)
                {
                    return this.prefixedQName.qname;
                }
                else
                {
                    var name = this.nodeName;
                    var myPrefix = "";
                    var myPrefixIndex = name.indexOf(":");
                    if (myPrefixIndex != -1)
                    {
                        myPrefix = name.substring(0, myPrefixIndex);
                        name = name.substring(myPrefixIndex+1);
                    }
                    var myNS = this.getNamespaceForPrefix(myPrefix);
                    var myQN = new QName(name, myNS);
                    this.prefixedQName = new PrefixedQName(myPrefix, myQN);
                    return myQN;
                }
            };
        }

        if (o.setChildValue == undefined) {
            o.setChildValue = function(name, value)
            {
                var attr = this.attributes[name];
                if (attr != undefined) {
                    this.attributes[name] = value;
                    return;
                }
    
                var childNode = this.getElementsByLocalName(name)[0];
                if (childNode != undefined) {
                    childNode.firstChild.removeNode();
                    var node = this._doc.createTextNode(value);
                    childNode.appendChild(node);
                }
            };
        }

        if (o.setValue == undefined) {
            o.setValue = function(value)
            {
                trace("setting value to " + value);
                this.firstChild.removeNode();
                var node = this._doc.createTextNode(value);
                this.appendChild(node);
            };
        }
    
        if (o.getQualifiedName == undefined) {
            o.getQualifiedName = function()
            {
                return this.nodeName;
            };
        }
    
        if (o.getPrefix == undefined) {
            o.getPrefix = function()
            {
                if (this.prefixedQName != undefined)
                {
                    return this.prefixedQName.prefix;
                }
                else
                {
                    var name = this.nodeName;
                    var myPrefix = "";
                    var myPrefixIndex = name.indexOf(":");
                    if (myPrefixIndex != -1)
                    {
                        myPrefix = name.substring(0, myPrefixIndex);
                    }
                    return myPrefix;
                }
            };
        }
    
        if (o.getLocalName == undefined) {
            o.getLocalName = function()
            {
                if (this.prefixedQName != undefined)
                {
                    return this.prefixedQName.qname.localPart;
                }
    
                else
                {
                    var name = this.nodeName;
                    var myPrefixIndex = name.indexOf(":");
                    if (myPrefixIndex != -1)
                    {
                        name = name.substring(myPrefixIndex+1);
                    }
                    return name;
                }
            };
        }
    
        if (o.getNamespaceURI == undefined) {
            o.getNamespaceURI = function()
            {
                return (this.getQName()).namespaceURI;
            };
        }
    
        if (o.loadNSMappings == undefined) {
            // Call this once to translate all "xmlns" and "xmlns:prefix" attributes
            // into a namespace mapping cache which hangs off the node for future reference.
            o.loadNSMappings = function()
            {
                if (this.mappings == undefined)
                {
                    this.mappings = new Object();
                }
    
                for (var attrName in this.attributes)
                {
                    var isDefault = true;
    
                    if (attrName.indexOf("xmlns") == 0)
                    {
                        if (attrName.charAt(5) == ':')
                        {
                            isDefault = false;
                        }
                        else if (attrName.length != 5)
                        {
                            continue;
                        }
    
                        var ns = this.attributes[attrName];
                        if (isDefault)
                        {
                            // Default namespace prefix is "", but Flash can't handle
                            // that as a map key, so use something with illegal
                            // XML characters in it as a marker to avoid collisions.
                            this.mappings["<>defaultNamespace<>"] = ns;
                        }
                        else
                        {
                            this.mappings[attrName.substring(6)] = ns;
                        }
                    }
                }
            };
        }
    
        if (o.getPrefixForNamespace == undefined) {
            o.getPrefixForNamespace = function(namespaceURI)
            {
                var pfx;
    
                if ((namespaceURI == undefined) || (namespaceURI == ""))
                    return undefined;  // Can't be a prefix for empty namespace
    
                if (this.mappings == undefined)
                    this.loadNSMappings();
    
                for (var pfxName in this.mappings)
                {
                    var ns = this.mappings[pfxName];
                    if (ns == namespaceURI)
                    {
                        pfx = pfxName;
                        break;
                    }
                }
    
                if ((pfx == undefined) && (this.parentNode != undefined))
                {
                    pfx = this.parentNode.getPrefixForNamespace(namespaceURI);
                }
    
                if (pfx == "<>defaultNamespace<>")
                    pfx = "";
    
                return pfx;
            };
        }
    
        if (o.getNamespaceForPrefix == undefined) {
            o.getNamespaceForPrefix = function(prefix)
            {
                if (prefix == "")
                    prefix = "<>defaultNamespace<>";
    
                if (this.mappings == undefined)
                    this.loadNSMappings();
    
                var ns = this.mappings[prefix];
                if ((ns == undefined) && (this.parentNode != undefined))
                {
                    ns = this.parentNode.getNamespaceForPrefix(prefix);
                }
    
                return ns;
            };
        }
    
        if (o.getElementsByQName == undefined) {
            o.getElementsByQName = function(qname)
            {
                var elements = new Array();
    
                if ((this.getQName()).equals(qname))
                {
                    elements.push(this);
                }
    
                var numChildren = this.childNodes.length;
                for (var i=0; i<numChildren; i++)
                {
                    var subElement = this.childNodes[i];
                    // NOTE: No longer digging deeper than one level (big perf boost)
                    if ((subElement.getQName()).equals(qname))
                    {
                        elements.push(subElement);
                    }
                }
    
                return elements;
            };
        }
    
        if (o.getElementsByLocalName == undefined) {
            o.getElementsByLocalName = function(lname)
            {
                var elements = new Array();
                if (this.getLocalName() == lname)
                {
                    elements.push(this);
                }
    
                var numChildren = this.childNodes.length;
                for (var i=0; i<numChildren; i++)
                {
                    var subElement = this.childNodes[i];
                    // NOTE: No longer digging deeper than one level (big perf boost)
                    if (subElement.getLocalName() == lname)
                    {
                        elements.push(subElement);
                    }
                }
    
                return elements;
            };
        }
    
        if (o.getElementsByReferencedName == undefined) {
            // Find all elements underneath this one (inclusive) which have a "name"
            // attribute that matches the specified value.  If a qname is passed, only
            // return elements which match that qname.
            o.getElementsByReferencedName = function(nameValue, qname)
            {
                var elements = new Array();
                var nameAttribute = this.attributes["name"];
                if (nameAttribute == nameValue)
                {
                    var success = false;
                    if (qname != undefined) {
                        var myQName = this.getQName();
                        if (myQName.namespaceURI == qname.namespaceURI &&
                            myQName.localPart == qname.localPart)
                        {
                            success = true;
                        }
                    } else {
                        success = true;
                    }
    
                    if (success)
                        elements.push(this);
                }
                else
                {
                    var numChildren = this.childNodes.length;
                    for (var i=0; i<numChildren; i++)
                    {
                        var subElements = this.childNodes[i].getElementsByReferencedName(nameValue, qname);
                        var numSubs = subElements.length;
                        for (var n=0; n<numSubs; n++)
                        {
                            elements.push(subElements[n]);
                        }
                    }
                }
                return elements;
            };
        }
    
        if (o.getAttributeByQName == undefined) {
            o.getAttributeByQName = function(qn)
            {
                for (var attrName in this.attributes)
                {
                    var attrPrefix = "";
                    var attrLocalName = attrName;
                    var i = attrName.indexOf(":");
                    if (i != -1)
                    {
                        attrPrefix = attrName.substring(0, i);
                        attrLocalName = attrName.substring(i+1);
                    }
                    var attrNS = this.getNamespaceForPrefix(attrPrefix);
                    var attrQName = new QName(attrNS, attrLocalName);
                    if ((attrLocalName == qn.localPart) && (attrNS == qn.namespaceURI))
                    {
                        return this.attributes[attrName];
                    }
                }
            };
        }
    
        if (o.getQNameFromString == undefined) {
            // Translate a string representation of a QName (i.e. "tns:foo") into a
            // real QName by using the currently scoped namespace mappings.
            o.getQNameFromString = function(prefixedName, useDefault) {
                var i = prefixedName.indexOf(":");
                var prefix = "";
                if ((i == -1) && !useDefault) {
                    return new QName(prefixedName);
                } else {
                    prefix = prefixedName.substring(0, i);
                    prefixedName = prefixedName.substring(i+1);
                }
                return new QName(prefixedName, this.getNamespaceForPrefix(prefix));
            };
        }
    
        if (o.registerNamespace == undefined) {
            o.registerNamespace = function(prefix, namespaceURI)
            {
                if (this.mappings == undefined)
                {
                    this.loadNSMappings();
                }
    
                if (prefix == "")
                    prefix = "<>defaultNamespace<>";
    
                // prevent over-writing prefixes
                if (this.mappings[prefix] == undefined)
                {
                    this.mappings[prefix] = namespaceURI;
                }
            };
        }
    
        if (o.unregisterNamespace == undefined) {
            o.unregisterNamespace = function(prefix)
            {
                if (this.mappings != undefined)
                {
                    if (prefix == "")
                    {
                        prefix = "<>defaultNamespace<>";
                    }
                    this.mappings[prefix] = undefined;
                }
            };
        }
    
        // ------------------------------------------------------------
        // Update XML DOM prototype with namespace support
        // ------------------------------------------------------------

        o = XML.prototype;

        o.nscount = 0;

        o.getElementsByQName = function(qname)
        {
            return this.firstChild.getElementsByQName(qname);
        };

        o.getElementsByReferencedName = function(tname, qname)
        {
            var tnsIndex = tname.indexOf(":");
            var n = (tnsIndex != -1) ? tname.substring(tnsIndex+1) : tname;
            return this.firstChild.getElementsByReferencedName(n, qname);
        };

        o.getElementsByLocalName = function(lname)
        {
            return this.firstChild.getElementsByLocalName(lname);
        };
    }
}
