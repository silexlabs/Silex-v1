/*
   Title:       NumberFormatter.as
   Description: defines the class "mx.data.formatters.NumberFormatter"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/



/**
	A Formatter for handling a variety of number formats.
	
  @class NumberFormatter
*/
class mx.data.formatters.NumberFormatter extends mx.data.binding.Formatter
{
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Controls how many digits AFTER the decimal point to display.  
  
	  @property	precision
	*/
	var precision : Number;
	
	var isInt:Boolean;
	
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		if ((requestedType == "String") || (requestedType == null))
		{
			var rawData = this.dataAccessor.getTypedValue();
			if( rawData.value != null ) {
				var strValue:String;
				if( this.precision > 0 ) {
					var perc:Number = isInt ? 1 : Math.pow( 10, this.precision );
					strValue = ( Math.round( rawData.value * perc ) / perc ).toString();
					// check to be sure that we have the correct format
					if( strValue.length > 0 ) {
						var index = strValue.lastIndexOf( '.' );
						var zCnt = 0;
						if( index < 0 ) {
							strValue += ".";
							zCnt = this.precision;
						}
						else
							zCnt = this.precision -( strValue.length- ( index +1 ));
						// add the zeros on
						strValue = strValue + "0000000000000000000000000000".substring( 0, zCnt );
					} // if
				}
				else
					strValue = Math.round( rawData.value ).toString(); // trunc to 0 percision
				return( new mx.data.binding.TypedValue( strValue, "String"));
			}
			else
				return( new mx.data.binding.TypedValue( "", "String" ));
		}
	}

	function getGettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if (newValue.typeName == "String")
		{
			if( newValue.value.length == 0 ) {
				return( this.dataAccessor.setTypedValue(new mx.data.binding.TypedValue (null, "Number")));
			}
			else {
				var convError = mx.data.types.Num.convertStringToNumber( isInt, newValue );
				var	result = this.dataAccessor.setTypedValue( newValue );
				return( convError == null ? result : convError );
			}
		}
		else
		{
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, "Number")];
		}
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return ["String"];
	}

}; // class mx.data.formatters.NumberFormatter
