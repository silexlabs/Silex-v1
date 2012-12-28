// WSDLOperation - a holder for a port type operation which can be looked
// up by name, but does not parse messages (and therefore schema types)
// until explicitly asked.

import mx.services.SOAPConstants;
import mx.services.WSDL;

class mx.services.WSDLOperation
{
    var name:String;
    var wsdl:WSDL;
    var document:XML;
    var input;
    var output;
    var inputMessage;
    var outputMessage;

    function WSDLOperation(name:String, wsdl:WSDL, document:XML) {
        this.name = name;
        this.wsdl = wsdl;
        this.document = document;

        // parsePortType() below will set inputMessage and outputMessage.
    }

    function parseMessages() {
        var wsdl = this.wsdl;
        this.input = wsdl.parseMessage(this.inputMessage,
                                       this.name,
                                       SOAPConstants.MODE_IN,
                                       this.document);
        this.output = wsdl.parseMessage(this.outputMessage,
                                        this.name,
                                        SOAPConstants.MODE_OUT,
                                        this.document);
    }
}
