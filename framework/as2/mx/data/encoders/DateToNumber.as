/*
   Title:       DateToNumber.as
   Description: defines the class "mx.data.encoders.DateToNumber"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Version:     1.0
*/

/**
  An encoder that encodes to number, and decodes to a Date.
	
  @class DateToNumber
*/
class mx.data.encoders.DateToNumber extends mx.data.binding.DataAccessor
{	
	function getTypedValue( requestedType: String ) : mx.data.binding.TypedValue {
		var returnValue : mx.data.binding.TypedValue;
		if(( requestedType == "Date" ) || ( requestedType == null )) {
			var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue( "Number" );
			var result:Date;
			if( rawValue.value != null )
				result = new Date( rawValue.value );
			else
				result = null;
			returnValue = new mx.data.binding.TypedValue( result, "Date" );
		}
		return returnValue;
	}

	function getGettableTypes() : Array /* of String */	{
		return ["Date"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if( newValue.typeName == "Date" ) {
			var value:Date;
			if( newValue.value != null )
				value = newValue.value.getTime();
			else
				value = null;
			return( this.dataAccessor.setTypedValue( new mx.data.binding.TypedValue( value, "Number" )));
		}
		else
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, "Date")];
	}
	
	function getSettableTypes() : Array /* of String */	{
		return ["Date"];
	}


} // class mx.data.encoders.Num