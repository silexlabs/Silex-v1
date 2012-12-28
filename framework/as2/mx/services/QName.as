// ------------------------------------------------------------
// QName and Prefixed QName Definitions
// What's in a Name? A rose by any other name...
// ------------------------------------------------------------
class mx.services.QName
{
    var localPart:String;
    var namespaceURI:String;

    public function QName(localPart, namespaceURI)
    {
        this.localPart = (localPart == undefined) ? "" : localPart;
        this.namespaceURI = (namespaceURI == undefined) ? "" : namespaceURI;
    }

    public function equals(qname)
    {
        return ((this.namespaceURI == qname.namespaceURI) && (this.localPart == qname.localPart));
    }
}
