import mx.services.SOAPFault;
import mx.services.WSDL;

class mx.services.WSDLDocument
{
    var bindingElements:Object;
    var portTypeElements:Object;
    var messageElements:Object;
    var serviceElements:Object;
    var targetNamespace:String;
    var xmlDoc:XML;

    function WSDLDocument(document:XML, wsdl:WSDL) {
        this.xmlDoc = document;

        var definitions = document.firstChild;
        var c = wsdl.constants;

        // check for malformed wsdl
        var defQName = definitions.getQName();
        if (!defQName.equals(c.definitionsQName))
        {
            wsdl.fault = new SOAPFault("Server", "Faulty WSDL format",
                                       "Definitions must be the first element in a WSDL document");
            return;
        }

        // get the targetNamespace for this WSDL
        this.targetNamespace = definitions.attributes.targetNamespace;

        this.bindingElements = new Object();
        this.portTypeElements = new Object();
        this.messageElements = new Object();
        this.serviceElements = new Object();

        var children = definitions.childNodes;
        for (var i = 0; i < children.length; i++) {
            var elemQName = children[i].getQName();
            var name = children[i].attributes.name;
            if (elemQName.equals(c.bindingQName)) {
                this.bindingElements[name] = children[i];
            } else if (elemQName.equals(c.portTypeQName)) {
                this.portTypeElements[name] = children[i];
            } else if (elemQName.equals(c.messageQName)) {
                this.messageElements[name] = children[i];
            } else if (elemQName.equals(c.serviceQName)) {
                this.serviceElements[name] = children[i];
            } else if (elemQName.equals(c.typesQName)) {
                // SPECIAL CASE - if <types> element, we parse the <schema>
                // elements underneath....
                wsdl.parseSchemas(children[i]);
            }
        }
    }

    function getBindingElement(name) {
        return this.bindingElements[name];
    }
    function getMessageElement(name) {
        return this.messageElements[name];
    }
    function getPortTypeElement(name) {
        return this.portTypeElements[name];
    }
    function getServiceElement(name) {
        return this.serviceElements[name];
    }
}
