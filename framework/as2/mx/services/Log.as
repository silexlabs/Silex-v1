// ------------------------------------------------------------
// WEB SERVICE LOGGING UTILITY
//
// log object that can optionally be passed to WebService,
// WebServiceProxy, WSDL, XMLSchema, and SOAP. These objects
// use log.logInfo or log.logDebug functions to report
// info to the log object, which then may call the onLog
// method that is presumed to be implemented by the Log creator
// (the app using the log).
//
// The WebServiceProxy object creates logs and chains them
// together, if a log was passed into the WebService constructor.
// ------------------------------------------------------------
// sneville@macromedia.com
// ------------------------------------------------------------
/**
  @helpid 1745 
  @tiptext contains logging data
*/
class mx.services.Log
{
    var level:Number;
    var name:String;
    
	/**
	  @helpid  1603
	  @tiptext	Creates a new instance of a Log object
	*/
    function Log(logLevel, name)
    {
        this.level = (logLevel == undefined)
            ? Log.BRIEF
            : logLevel;

        this.name = (name == undefined)
            ? ""
            : name;
    }

    // Level constants
    static var NONE:Number = -1;
    static var BRIEF:Number = 0;
    static var VERBOSE:Number = 1;
    static var DEBUG:Number = 2;

    function logInfo(msg, level)
    {
        if (level == undefined)
        {
            level = Log.BRIEF;
        }

        if (level <= this.level)
        {
            if (level == Log.DEBUG)
            {
                this.onLog(this.getDateString() + " [DEBUG] " + this.name + ": " + msg);
            }
            else
            {
                this.onLog(this.getDateString() + " [INFO] " + this.name + ": " + msg);
            }
        }
    }

    function logDebug(msg)
    {
        this.logInfo(msg, Log.DEBUG);
    }

    function getDateString()
    {
        var d = new Date();
        return (d.getMonth()+1) + "/" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
    }

	/**
      Default version of onLog just trace()s the message.  Override to do
      other stuff (write to db, network, file, etc)
	  
	  @helpid 	1724
	  @tiptext	used to handle logger output
	*/
    function onLog(message)
    {
        trace(message);
    }
}
