// ------------------------------------------------------------
// WSDL CONSTANTS
// ------------------------------------------------------------
// Constants for Namespace URIs and the like used by the
// ActionScript WSDL Parser.
// ------------------------------------------------------------
// sneville@macromedia.com
// ------------------------------------------------------------
import mx.services.QName;

class mx.services.WSDLConstants
{
    static function getConstants(versionNumber:String)
    {
        // currently not supporting multiple versions
        var constants = new Object();

        constants.definitionsQName = new QName("definitions", WSDLConstants.WSDL_URI);
        constants.typesQName = new QName("types", WSDLConstants.WSDL_URI);
        constants.messageQName = new QName("message", WSDLConstants.WSDL_URI);
        constants.portTypeQName = new QName("portType", WSDLConstants.WSDL_URI);
        constants.bindingQName = new QName("binding", WSDLConstants.WSDL_URI);
        constants.serviceQName = new QName("service", WSDLConstants.WSDL_URI);
        constants.importQName = new QName("import", WSDLConstants.WSDL_URI);

        constants.documentationQName = new QName("documentation", WSDLConstants.WSDL_URI);
        constants.portQName = new QName("port", WSDLConstants.WSDL_URI);
        constants.soapAddressQName = new QName("address", WSDLConstants.WSDL_SOAP_URI);

        constants.bindingQName = new QName("binding", WSDLConstants.WSDL_URI);
        constants.soapBindingQName = new QName("binding", WSDLConstants.WSDL_SOAP_URI);
        constants.operationQName = new QName("operation", WSDLConstants.WSDL_URI);
        constants.soapOperationQName = new QName("operation", WSDLConstants.WSDL_SOAP_URI);
        constants.documentationQName = new QName("documentation", WSDLConstants.WSDL_URI);

        constants.soapBodyQName = new QName("body", WSDLConstants.WSDL_SOAP_URI);
        constants.inputQName = new QName("input", WSDLConstants.WSDL_URI);
        constants.outputQName = new QName("output", WSDLConstants.WSDL_URI);
        constants.parameterQName = new QName("part", WSDLConstants.WSDL_URI);

        return constants;
    }

    static var WSDL_URI = "http://schemas.xmlsoap.org/wsdl/";

    static var WSDL_SOAP_URI = "http://schemas.xmlsoap.org/wsdl/soap/";
    static var SOAP_ENVELOPE_URI = "http://schemas.xmlsoap.org/soap/envelope/";
    static var SOAP_ENCODING_URI = "http://schemas.xmlsoap.org/wsdl/soap/encoding/";

    static var HTTP_WSDL_URI = "http://schemas.xmlsoap.org/wsdl/http/";
    static var HTTP_SOAP_URI = "http://schemas.xmlsoap.org/soap/http";

    static var MACROMEDIA_SOAP_URI = "http://www.macromedia.com/soap/";

    static var DEFAULT_STYLE = "document";
}
