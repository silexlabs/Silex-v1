// --------------
// SOAP Parameter
// --------------
import mx.services.SOAPConstants;

class mx.services.SOAPParameter
{
    public var name;
    public var schemaType;
    public var mode;
    public var qname;
    public var value;
    public var element;

    public function SOAPParameter(name, schemaType, mode, qname)
    {
        // Parameter localPart
        this.name = name;

        // Type
        this.schemaType = schemaType;

        // Mode: IN, OUT, or INOUT
        this.mode = (mode == undefined) ? SOAPConstants.MODE_IN : mode;

        // Namespace URI
        this.qname = qname;

        // also has the properties: value, element
    }
}
