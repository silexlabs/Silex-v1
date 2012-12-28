// ------------------------------------------------------------
// XML SCHEMA CONSTANTS
// ------------------------------------------------------------
// Constants for Namespace URIs and the like used by the 
// ActionScript XML Schema Parser.
// ------------------------------------------------------------
// sneville@macromedia.com
// gdaniels@macromedia.com
// ------------------------------------------------------------
import mx.services.QName;

class mx.services.SchemaVersion {
    public static var XML_SCHEMA_URI = "http://www.w3.org/2001/XMLSchema";
    public static var SOAP_ENCODING_URI = "http://schemas.xmlsoap.org/soap/encoding/";
    public static var XSD_URI_1999 = "http://www.w3.org/1999/XMLSchema";
    public static var XSD_URI_2000 = "http://www.w3.org/2000/10/XMLSchema";
    public static var XSD_URI_2001 = "http://www.w3.org/2001/XMLSchema";
    public static var XSI_URI_1999 = "http://www.w3.org/1999/XMLSchema-instance";
    public static var XSI_URI_2000 = "http://www.w3.org/2000/10/XMLSchema-instance";
    public static var XSI_URI_2001 = "http://www.w3.org/2001/XMLSchema-instance";
    public static var APACHESOAP_URI = "http://xml.apache.org/xml-soap";
    public static var CF_RPC_URI   = "http://rpc.xml.coldfusion";

    static var version1999;
    static var version2000;
    static var version2001;

    var xsdURI:String;
    var xsiURI:String;
    var schemaQName : QName;
    var allQName : QName;
    var complexTypeQName : QName;
    var elementTypeQName : QName;
    var importQName : QName;
    var simpleTypeQName : QName;
    var complexContentQName : QName;
    var sequenceQName : QName;
    var simpleContentQName : QName;
    var restrictionQName : QName;
    var attributeQName : QName;
    var extensionQName : QName;
    var nilQName : QName;

    static function getSchemaVersion(xsdURI:String) {
        if (xsdURI == XSD_URI_2001) {
            if (version2001 == undefined) {
                version2001 = new SchemaVersion(XSD_URI_2001, XSI_URI_2001);
            }
            return version2001;
        }
        if (xsdURI == SchemaVersion.XSD_URI_2000) {
            if (SchemaVersion.version2000 == undefined) {
                SchemaVersion.version2000 = new SchemaVersion(SchemaVersion.XSD_URI_2000,
                                                                SchemaVersion.XSI_URI_2000);
            }
            return SchemaVersion.version2000;
        }
        if (xsdURI == SchemaVersion.XSD_URI_1999) {
            if (SchemaVersion.version1999 == undefined) {
                SchemaVersion.version1999 = new SchemaVersion(SchemaVersion.XSD_URI_1999,
                                                                SchemaVersion.XSI_URI_1999);
            }
            return SchemaVersion.version1999;
        }
    }

    private function SchemaVersion(xsdURI:String, xsiURI:String) {
        this.xsdURI = xsdURI;
        this.xsiURI = xsiURI;

        // SUPPORTED ELEMENTS IN THE SCHEMA NAMESPACE:
        this.schemaQName = new QName("schema", xsdURI);
        this.allQName = new QName("all", xsdURI);
        this.complexTypeQName = new QName("complexType", xsdURI);
        this.elementTypeQName = new QName("element", xsdURI);
        this.importQName = new QName("import", xsdURI);
        this.simpleTypeQName = new QName("simpleType", xsdURI);
        this.complexContentQName = new QName("complexContent", xsdURI);
        this.sequenceQName = new QName("sequence", xsdURI);
        this.simpleContentQName = new QName("simpleContent", xsdURI);
        this.restrictionQName = new QName("restriction", xsdURI);
        this.attributeQName = new QName("attribute", xsdURI);
        this.extensionQName = new QName("extension", xsdURI);

        var nilStr = "nil";
        if (xsdURI == SchemaVersion.XSD_URI_1999)
            nilStr = "null";
        this.nilQName = new QName(nilStr, xsiURI);
    }
}
