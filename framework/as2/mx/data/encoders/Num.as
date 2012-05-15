/*
   Title:       Num.as
   Description: defines the class "mx.data.encoders.Num"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An encoder that encodes to string, and decodes to number.
	
  @class Num
*/
class mx.data.encoders.Num extends mx.data.binding.DataAccessor
{	
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var returnValue : mx.data.binding.TypedValue;
		if ((requestedType == "Number") || (requestedType == null))
		{
			var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue("String");
			var result = null;
			if(( rawValue.value != null ) && ( rawValue.value.length > 0 ))
				result= Number( rawValue.value );
			returnValue = new mx.data.binding.TypedValue (result, "Number");
		}
		return returnValue;
	}

	function getGettableTypes() : Array /* of String */
	{
		return ["Number", "Integer"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if(( newValue.typeName == "Number" ) || ( newValue.typeName == "Integer" ))
		{
			var result;
			if( newValue.value != null )
				result = newValue.value.toString();
			else
				result = "";
			return this.dataAccessor.setTypedValue(new mx.data.binding.TypedValue( result, newValue.typeName));
		}
		else
		{
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, newValue.typeName)];
		}
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return ["Number", "Integer"];
	}


} // class mx.data.encoders.Num