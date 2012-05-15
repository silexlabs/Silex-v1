/*
   Title:       Bool.as
   Description: defines the class "mx.data.encoders.Bool"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An encoder that encodes to string, and decodes to boolean.
	
  @class Bool
*/
class mx.data.encoders.Bool extends mx.data.binding.DataAccessor
{	
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		if ((requestedType == "Boolean") || (requestedType == null))
		{
			var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue("String");
			var result = null;
			if(( rawValue.value != null ) && ( rawValue.value.length > 0 )) {
				var strIndex = this.trueStrings.indexOf(String(rawValue.value));
				result = (strIndex!= -1);
			}
			return( new mx.data.binding.TypedValue( result, "Boolean" ));
		}
	}

	function getGettableTypes() : Array /* of String */
	{
		return ["Boolean"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if (newValue.typeName == "Boolean")
		{
			var result:String = "";
			if( newValue.value != null ) {
				var strings : String = newValue.value ? this.trueStrings : this.falseStrings;
				var stringsArray : Array = strings.split(",");
				result = stringsArray[0];
			}
			return( this.dataAccessor.setTypedValue( new mx.data.binding.TypedValue( result, "String")));
		}
		else
		{
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, "Boolean")];
		}
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return ["Boolean"];
	}

	// -----------------------------------------------------------------------------------------

	// settings that are defined by the developer
	var trueStrings: String;
	var falseStrings: String;
} // class mx.data.encoders.Bool