    //////////////////////////////////////////////////////////////////
    // ArrayProxy
    //
    // This class provides what looks like an Array to the outside,
    // but provides "lazy deserialization".  When items are asked for,
    // they are deserialized from the XML representation as requested,
    // and then cached so each one is only decoded once.
    //
class mx.services.ArrayProxy extends Array
{
    var xmlNodes;
    var sCall;
    var arrayType;
    
    public function ArrayProxy(xmlNodes, sCall, arrayType) {
        this.xmlNodes = xmlNodes;
        this.sCall = sCall;
        this.arrayType = arrayType;
        this.length = xmlNodes.length;
    }

    public function __resolve(index) {
        index = Number(index);
        var ret = this.sCall.decodeResultNode(this.xmlNodes[index], this.arrayType);
        this[index] = ret;
        return ret;
    }
}
