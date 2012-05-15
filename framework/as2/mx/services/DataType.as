import mx.services.QName;
import mx.services.SchemaVersion;

class mx.services.DataType
{
    var name:String;
    var typeType:Number;
    var namespaceURI:String;
    var qname:QName;
    var isAnonymous:Boolean;
    var deserializer;

    function DataType(name, typeType, xmlns, deserializer)
    {
        this.name = name;
        this.typeType = (typeType == undefined) ? DataType.OBJECT_TYPE : typeType;
        this.namespaceURI = (xmlns == undefined) ? SchemaVersion.XML_SCHEMA_URI : xmlns;
        this.qname = new QName(this.name, this.namespaceURI);
        this.isAnonymous = false;
        this.deserializer = deserializer;
    }

    // Other stuff I need to know about each partType:
    // - is this an element or attribute?
    // - is the form qualified/unqualified (using default as appropriate)
    // - minOccurs/maxOccurs (for elements)
    // - namespace (for references)
    // Solution - keep the elementDecl itself around, not just the DataType?
    //            but maybe call it partDecl so we can have attributes too...

    public static var NUMBER_TYPE = 0;
    public static var STRING_TYPE = 1;
    public static var OBJECT_TYPE = 2;
    public static var DATE_TYPE   = 3;
    public static var BOOLEAN_TYPE= 4;
    public static var XML_TYPE    = 5;
    public static var ARRAY_TYPE  = 6;  // An array with a wrapper element
    public static var MAP_TYPE    = 7;
    public static var ANY_TYPE    = 8;
    public static var COLL_TYPE   = 10; // A collection (no wrapper element, just maxOccurs)
    public static var ROWSET_TYPE = 11;
    public static var QBEAN_TYPE  = 12; // CF QueryBean

    // Anonymous object type (for writing ActionScript objects without schema)
    public static var objectType = new DataType("", DataType.OBJECT_TYPE, "");
}