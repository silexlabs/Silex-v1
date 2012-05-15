class mx.services.PrefixedQName
{
    var prefix;
    var qname;
    var qualifiedName;
    
    function PrefixedQName(prefix, qname)
    {
        this.prefix = prefix;
        this.qname = qname;
        this.qualifiedName = prefix;
        if (prefix != "")
            this.qualifiedName += ":";
        this.qualifiedName += qname.localPart;
    }
}