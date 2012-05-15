/*
   Title:       Dat.as
   Description: defines the class "mx.data.formatters.Dte"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Jason Williams, Mark Shepherd
   Version:     1.0
*/

/**
	A formatter for Date values.
	
  @class Dte
*/
class mx.data.formatters.Dte extends mx.data.binding.DateBase
{
	function setupDataAccessor(component: Object, property: String, location: Object)
	{
		super.setupDataAccessor(component, property, location);
		this.dataFormatter = new mx.utils.StringFormatter( format, "M,D,Y,H,N,S",
			mx.data.binding.DateBase.extractTokenDate, mx.data.binding.DateBase.infuseTokenDate );
	}

	function internalToExternal(rawValue)
	{
		if( rawValue != null )
			return dataFormatter.formatValue( rawValue );
		else
			return( "" );
	}

	function externalToInternal(value)
	{
		if(( value != null ) && ( value.length > 0 )) {
			var result: Date;
			if( value.toLowerCase() == "now" )
				result = new Date();
			else {
			 	result = new Date(0, 0, 0, 0, 0, 0); // exclude current time fix for bug#69845
				dataFormatter.extractValue ( value, result );
			}
			return( result );
		}
		else
			return( null );
	}
	
	function externalTypeName()
	{
		return "String";
	}

	function internalTypeName()
	{
		return "Date";
	}

	// -----------------------------------------------------------------------------------------

	// settings that are defined by the developer
	var format: String; // e.g. "MM/DD/YYYY HH:NN:SS"
	
	// private date
	var dataFormatter: mx.utils.StringFormatter;

} // class mx.data.formatters.Dte