/*
   Title:       DateBase.as
   Description: defines the class "mx.data.binding.DateBase"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A base class for formatters/encoders
	
  @class DateBase
*/
class mx.data.binding.DateBase extends mx.data.binding.DataAccessor
{
	function internalToExternal(rawValue)
	{
		return null;
	}

	function externalToInternal(value)
	{
		return null;
	}
	
	function externalTypeName()
	{
		return null;
	}
	
	function internalTypeName()
	{
		return null;
	}

	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var returnValue;
		if ((requestedType == externalTypeName()) || (requestedType == null))
		{
			var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue();
			var result = internalToExternal(rawValue.value);
			returnValue = new mx.data.binding.TypedValue (result, externalTypeName());
		}
		//Debug.trace("mx.formatters.DateBase.getTypedValue", requestedType, returnValue);
		return returnValue;
	}

	function getGettableTypes() : Array /* of String */
	{
		return [externalTypeName()];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if ((newValue.typeName == externalTypeName()) || (newValue.typeName == null))
		{
			var rawValue = externalToInternal(newValue.value);
			var result: Array;
			if (!rawValue)
			{
				result = [mx.data.binding.DataAccessor.conversionFailed(newValue, internalTypeName())];
			}
			var result2 = this.dataAccessor.setTypedValue(new mx.data.binding.TypedValue (rawValue, internalTypeName()));
			if (result)
				return result;
			else
				return result2;
		}
		else
		{
			return [mx.data.binding.DataAccessor.conversionFailed(newValue, internalTypeName())];
		}		
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return [externalTypeName()];
	}
		
	static function extractTokenDate ( value, tokenInfo ) 
	{
		var result = "";
		if( value != null ) {
			switch( tokenInfo.token ) {
				case 'M':
					var month = value.getMonth() +1; // zero based
					if( month < 10 )
						result += "0";
					result += month.toString();
				break;
				
				case 'Y':
					var year = value.getFullYear().toString();
					if( tokenInfo.end - tokenInfo.begin < 3 )
						result = year.substr( 2 );
					else
						result = year;
				break;
				
				case 'D':
					var day = value.getDate();
					if( day < 10 )
						result += "0";
					result += day.toString();
				break;
				
				case 'H':
					var hours = value.getHours();
					if( hours < 10 )
						result += "0";
					result += hours.toString();
				break;
				
				case 'N':
					var mins = value.getMinutes();
					if( mins < 10 )
						result += "0";
					result += mins.toString();
				break;
				
				case 'S':
					var sec = value.getSeconds();
					if( sec < 10 )
						result += "0";
					result += sec.toString();
				break;
			} // switch
		}
		return( result );
	}
	
	static function infuseTokenDate ( tkData, tk, value )
	{
		if( tkData.length > 0 )
			switch( tk.token ) {
				case 'M':
					value.setMonth(Number( tkData ) -1); // zero based
				break;
				
				case 'D':
					value.setDate(Number( tkData ));
				break;
				
				case 'Y':
					value.setYear(Number( tkData ));
				break;
				
				case 'H':
					value.setHours(Number( tkData ));
				break;
				
				case 'N':
					value.setMinutes(Number( tkData ));
				break;
				
				case 'S':
					value.setSeconds(Number( tkData ));
				break;
			} // switch
	}

} // class mx.data.binding.DateBase
