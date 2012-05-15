// ------------------------------------------------------------
// SOAP Constants for SOAP 1.1 and SOAP 1.2
// ------------------------------------------------------------
// Constants for Namespace URIs and the like used by the 
// SOAP RPC mechanism.
// ------------------------------------------------------------
// sneville@macromedia.com
// ------------------------------------------------------------
import mx.services.QName;

class mx.services.SOAPConstants
{
    static var soap11Constants;
    static var soap12Constants;


    static function getConstants(versionNumber)
    {
        // ECMA uses "0" to represent SOAP v1.1 -- support both 0 and 1.1
        if (versionNumber < 2)
        {
            if (soap11Constants == undefined) {
                soap11Constants = new SOAPConstants();
                soap11Constants.setSOAP11();
            }
            return soap11Constants;
        }
        else
        {
            if (soap12Constants == undefined) {
                soap12Constants = new SOAPConstants();
                soap12Constants.setSOAP12();
            }
            return soap12Constants;
        }
    }

    private static var newline: String = "\n";
    
    public static var DEFAULT_VERSION = 0;
    public static var XML_DECLARATION = "<?xml version=\"1.0\" encoding=\"utf-8\"?>" + newline;

    public static var RPC_STYLE = "rpc";
    public static var DOC_STYLE = "document";
    public static var WRAPPED_STYLE = "wrapped";
    public static var USE_ENCODED = "encoded";
    public static var USE_LITERAL = "literal";
    public static var DEFAULT_OPERATION_STYLE = SOAPConstants.RPC_STYLE;
    public static var DEFAULT_USE = SOAPConstants.USE_ENCODED;

    public static var SOAP_ENV_PREFIX = "SOAP-ENV";
    public static var SOAP_ENC_PREFIX = "soapenc";
    public static var XML_SCHEMA_PREFIX = "xsd";
    public static var XML_SCHEMA_INSTANCE_PREFIX = "xsi";
    public static var XML_SCHEMA_URI = "http://www.w3.org/2001/XMLSchema";
    public static var XML_SCHEMA_INSTANCE_URI = "http://www.w3.org/2001/XMLSchema-instance";

    public static var SCHEMA_INSTANCE_TYPE = SOAPConstants.XML_SCHEMA_INSTANCE_PREFIX + ":type";
    public static var ARRAY_PQNAME = SOAPConstants.SOAP_ENC_PREFIX + ":Array";
    public static var ARRAY_TYPE_PQNAME = SOAPConstants.SOAP_ENC_PREFIX + ":arrayType";

    public static var MODE_IN = 0;
    public static var MODE_OUT = 1;
    public static var MODE_INOUT = 2;

    public static var DISCONNECTED_FAULT_CODE = "Client.Disconnected";


    var contentType:String;
    var ENVELOPE_URI:String;
    var ENCODING_URI:String;
    var envelopeQName:QName;
    var headerQName:QName;
    var bodyQName:QName;
    var faultQName:QName;
    var actorQName:QName;
    var soapencArrayQName:QName;
    var soapencArrayTypeQName:QName;
    var soapencRefQName:QName;

    private function setSOAP11()
    {
        this.contentType = "text/xml; charset=utf-8";
        this.ENVELOPE_URI = "http://schemas.xmlsoap.org/soap/envelope/";
        this.ENCODING_URI = "http://schemas.xmlsoap.org/soap/encoding/";
        setupConstants();
    }

    private function setSOAP12()
    {
        this.contentType = "application/soap+xml; charset=utf-8";
        this.ENVELOPE_URI = "http://www.w3.org/2002/12/soap-envelope";
        this.ENCODING_URI = "http://www.w3.org/2002/12/soap-encoding";
        setupConstants();
    }

    private function setupConstants()
    {
        // if these localPart definitions change in future SOAP versions, pull them
        // out into the version-specific SOAPConstants prototypes
        envelopeQName = new QName("Envelope", ENVELOPE_URI);
        headerQName = new QName("Header", ENVELOPE_URI);
        bodyQName = new QName("Body", ENVELOPE_URI);
        faultQName = new QName("Fault", ENVELOPE_URI);
        actorQName = new QName("Actor", ENVELOPE_URI);

        soapencArrayQName = new QName("Array", ENCODING_URI);
        soapencArrayTypeQName = new QName("arrayType", ENCODING_URI);
        soapencRefQName = new QName("multiRef", ENCODING_URI);
    }

}