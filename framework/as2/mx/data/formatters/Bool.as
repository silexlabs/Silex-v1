/*
   Title:       Bool.as
   Description: defines the class "mx.data.formatters.Bool"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A formatter for Boolean values.
	
  @class Bool
*/
class mx.data.formatters.Bool extends mx.data.binding.DataAccessor
{

	// Format a boolean, result is a string
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var returnValue;
		if ((requestedType == "String") || (requestedType == null))
		{
			var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue("Boolean");
			if( rawValue.value != null )
				returnValue = new mx.data.binding.TypedValue( rawValue.value ? trueString : falseString, "String" );
			else
				returnValue = new mx.data.binding.TypedValue( "", "String" );
		}
		//Debug.trace("mx.data.formatters.Bool.getTypedValue", requestedType, returnValue);
		return returnValue;
	}

	function getGettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	// Unformat a string, result is a boolean
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.formatters.Bool.setTypedValue", newValue);
		if( newValue.typeName == "String" )
		{
			var rawValue;
			if( newValue.value.length > 0 ) {
				rawValue = (-1 != this.trueString.indexOf(String(newValue.value)));
				var result: Array;
				if (!rawValue)
				{
					// if its not one of the true strings, it better be one of the false strings
					if (-1 == this.falseString.indexOf(String(newValue.value)))
						result = [mx.data.binding.DataAccessor.conversionFailed(newValue, "Boolean")];
				}
			}
			else
				rawValue = null;
			var result2 = this.dataAccessor.setTypedValue(new mx.data.binding.TypedValue (rawValue, "Boolean"));
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
		//Debug.trace("mx.data.formatters.Bool.getSettableTypes");
		return ["String"];
	}

	// -----------------------------------------------------------------------------------------

	// settings that are defined by the developer
	var trueString: String;
	var falseString: String;

} // class mx.data.formatters.Bool