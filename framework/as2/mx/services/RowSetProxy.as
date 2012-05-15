//////////////////////////////////////////////////////////////////
// RowSetProxy
//
// This class provides what looks like an Array (i.e. a DataProvider)
// to the outside, but provides "lazy deserialization".  When items
// are asked for, they are deserialized from the XML representation
// as requested, and then cached so each one is only decoded once.
//
import mx.services.PendingCall;

class mx.services.RowSetProxy extends Array
{
    var sCall:PendingCall;
    var xmlNodes;
    var types;
    var fields;
    var length;
    var views;

    public function RowSetProxy(sCall:PendingCall, xmlNodes, types, fields) {
        this.sCall = sCall;
        this.xmlNodes = xmlNodes;
        this.types = types;
        this.fields = fields;
        this.length = xmlNodes.length;
        this.views = new Array();
    }

    // The workhorse - when an item is requested which we haven't yet
    // decoded, we'll end up here.  If ths index is within range, we
    // decode the appropriate individual item, cache it, and return it.
    public function __resolve(index) {
        index = Number(index);
        if (index < 0 || index > this.length) {
            return undefined;
        }

        var ret = this.sCall.decodeRowSetItem(this.xmlNodes[index], this.types, this.fields);
        this[index] = ret;

        return ret;
    }

    public function getColumnNames() {
        return this.fields;
    }
}
