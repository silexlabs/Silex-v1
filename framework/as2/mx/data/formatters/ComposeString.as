/*
   Title:       ComposeString.as
   Description: defines the class "mx.data.formatters.ComposeString"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/



/**
	A printf-like formatter for transforming records into strings.
	
  @class ComposeString
*/
class mx.data.formatters.ComposeString extends mx.data.binding.DataAccessor
{
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  A template string, such as "As of <date>, your balance is <accountbalance>".  
  
	  @property	template
	*/
	var template : String;
	
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	function getGettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	// Format an Object, result is a String
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue();
		var result = mx.data.binding.Log.substituteIntoString(this.template, rawValue.value, null, rawValue.type);
		return new mx.data.binding.TypedValue(result, "String");
	}

}; // class mx.data.formatters.ComposeString
