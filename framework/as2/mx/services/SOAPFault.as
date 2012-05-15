// ----------
// SOAP Fault
// ----------
class mx.services.SOAPFault
{
    public var faultcode : String;
    public var faultstring : String;
    public var detail;
    public var element;
    public var faultNamespaceURI;
    public var faultactor;

    function SOAPFault(fcode, fstring, detail, element, faultNS, faultactor)
    {
        this.faultcode = fcode;
        this.faultstring = fstring;
        this.detail = detail;
        this.element = element;
        this.faultNamespaceURI = faultNS;
        this.faultactor = faultactor;
    }
}
