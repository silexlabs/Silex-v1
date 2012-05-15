/*
   Title:       Custom.as
   Description: defines the class "mx.data.formatters.Custom"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/



/**
	A Formatter which is implemented via a user-defined class.
	
  @class Custom
*/
class mx.data.formatters.Custom extends mx.data.binding.DataAccessor
{
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	public var classname : String;

	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Properties
	//
	// -----------------------------------------------------------------------------------------

	private var formatter : Function;

	// -----------------------------------------------------------------------------------------
	// 
	// Published Functions (== overrides of Formatter class)
	//
	// -----------------------------------------------------------------------------------------

	function getGettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	// Format something, result is a String
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		//Debug.trace("mx.data.formatters.Custom.getTypedValue", requestedType);
		Setup();
		var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue();
		var result: String = this.formatter.format(rawValue.value);
		return new mx.data.binding.TypedValue(result, "String");
	}

	// Unformat a string, result is an object
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.formatters.Custom.setTypedValue", newValue);
		if (newValue.typeName == "String")
		{
			Setup();
			var rawValue: Object = this.formatter.unformat(newValue.value);
			var result: Array;
			if (!rawValue) // !!@ need a better way to get error messages back from Unformat.
			{
				result = [mx.data.binding.DataAccessor.conversionFailed(newValue, this.classname)];
			}
			var result2 = this.dataAccessor.setTypedValue(new mx.data.binding.TypedValue (rawValue));
			if (result)
				return result;
			else
				return result2;
		}
		else
		{
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, "String")];
		}		
	}
	
	function getSettableTypes() : Array /* of String */
	{
		//Debug.trace("mx.data.formatters.Custom.getSettableTypes");
		return ["String"];
	}
    
   	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Functions
	//
	// -----------------------------------------------------------------------------------------

	private function Setup()
	{
		// we can't do this work when the constructor is called,
		// because our settings (i.e. classname) are not available at that time.
		
		if (this.formatter == null)
		{	
			var cls = mx.utils.ClassFinder.findClass(this.classname);
			this.formatter = new cls();
			if (this.formatter == null)
			{
				_global.__dataLogger.logData(null, 
					"Error: can't create custom formatter class '<classname>'", this);
			}
		}
	}

}; // class mx.data.formatters.Custom
