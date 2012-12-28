/*
   Title:       Log.as
   Description: defines the class "mx.data.binding.Log"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	Receives informational data about things that happen in your code. 
	
  @class Log
*/
class mx.data.binding.Log
{
	// -----------------------------------------------------------------------------------------
	// 
	// Constants
	//
	// -----------------------------------------------------------------------------------------

	public static var NONE : Number = -1;
	public static var BRIEF : Number = 0;
	public static var VERBOSE : Number = 1;
	public static var DEBUG : Number = 2;

	public static var INFO : Number = 2;
	public static var WARNING : Number = 1;
	public static var ERROR : Number = 0;
	
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	private var level : Number;
	private var name : String;
	private var showDetails : Boolean = false;
	
	public var nestLevel = 0;
	
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Initializes a new Log object that can be passed as an optional argument to the WebService
	  constructor (see WebService API above).

	  @method	Log
	  @param	logLevel	[optional] must be one of the following, and if not set explicitly the
							level will default to Log.BRIEF:
							<ul>
							<li> Log.BRIEF: Primary lifecycle event and error notifications will be received 
							<li> Log.VERBOSE: All lifecycle event and error notifications will be received 
							<li> Log.DEBUG: Metrics and fine-grained events and errors will be received 
							</ul>
	  @param	logName		[optional] can be used to distniguish between multiple logs that
							are running simultaneously to the same output
	*/
	function Log (logLevel:Number, logName : String)
	{
		//trace("new Log");
		
		this.level = (logLevel == undefined)
			? Log.BRIEF
			: logLevel;
			
		this.name = (name == undefined)
			? ""
			: name;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Call this function to make a log entry.

	  @method	logInfo
	  @param	message		A message that needs to be written to the log
	*/
	function logInfo (msg : Object, level : Number)
	{
		if (level == undefined)
		{
			level = Log.BRIEF;
		}

		//if (level <= this.level)
		if (true)
		{
			this.onLog (this.getDateString() + " " + this.name + ": " + 
				mx.data.binding.ObjectDumper.toString(msg));
		}
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Call this function to make a log entry.

	  @method	logData
	  @param	data		A message that needs to be written to the log
	*/
	function logData (target: Object, message: String, info: Object, level : Number)
	{
		if (level == undefined)
		{
			level = Log.VERBOSE;
		}

		//if (level <= this.level)
		if (true)
		{
			var namestr = ((this.name.length > 0) ? (" " + this.name + ": ") : " ");
			var targetstr = ((target == null) ? "" : (target + ": "));
			if (targetstr.indexOf("_level0.") == 0) targetstr = targetstr.substr(8);
			var str = this.getDateString() + namestr + targetstr + substituteIntoString(message, info, 50);
			if (this.showDetails && (info != null))
			{
				str += "\n    " + mx.data.binding.ObjectDumper.toString(info);
			}
			else
			{
				for (var i = 0; i < this.nestLevel; i++)
				{
					str = "    " + str;
				}
			}
			this.onLog(str);
		}
	}

	// -----------------------------------------------------------------------------------------
	// Default version of onLog just trace()s the message.  Override to do
	// other stuff (write to db, network, file, etc)

	function onLog (message: String)
	{
	    trace(message);
	}

	// -----------------------------------------------------------------------------------------

	function getDateString ()
	{
		var d = new Date();
		return (d.getMonth()+1) + "/" + d.getDate() + " " + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds();
	}

	// -----------------------------------------------------------------------------------------

	public static function substituteIntoString(message: String, info: Object, maxlen: Number, rawDataType: Object) : String
	{
		var result : String = "";
		if (info == null) return message;
		var tokens : Array = message.split("<");
		if (tokens == null) return message;
		result += tokens[0];
		for (var i : Number = 1; i < tokens.length; i ++)
		{
			var items = tokens[i].split(">");
			var location : Array = items[0].split(".");
			var insert = info;
			var type = rawDataType;
			for (var j : Number = 0; j < location.length; j++)
			{
				var fieldName = location[j];
				if (fieldName != "")
				{
					type = mx.data.binding.FieldAccessor.findElementType(type, fieldName);
					//trace("FIELD " + fieldName + ", TYPE:::: " + mx.data.binding.ObjectDumper.toString(type));
					var fa = new mx.data.binding.FieldAccessor(null, null, insert, fieldName, type, null, null);
					insert = fa.getValue();
					//insert = insert[location[j]];
				}
			}
			if (typeof(insert) != "string") insert = mx.data.binding.ObjectDumper.toString(insert);
			if (insert.indexOf("_level0.") == 0) insert = insert.substr(8);
			if ((maxlen != null) && (insert.length > maxlen)) insert = insert.substr(0, maxlen) + "...";
			result += insert;
			
			result += items[1];
		}
		
		var temp = result.split("&gt;");
		result = temp.join(">");
		temp = result.split("&lt;");
		result = temp.join("<");
		return result;
	}
	
} // class mx.data.binding.Log