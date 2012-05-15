/*
   Title:       Dat.as
   Description: defines the class "mx.data.encoders.Dte"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An encoder for Date values.
	
  @class Dat
*/
class mx.data.encoders.Dte extends mx.data.binding.DateBase
{
	function setupDataAccessor(component: Object, property: String, location: Object)
	{
		super.setupDataAccessor(component, property, location);
		this.dataEncoder = new mx.utils.StringFormatter( format, "M,D,Y,H,N,S",
			mx.data.binding.DateBase.extractTokenDate, mx.data.binding.DateBase.infuseTokenDate );
	}

	function internalToExternal(value)
	{
		if(( value != null ) && ( value.length > 0 )) {
			var date: Date = new Date( 0, 0, 0, 0, 0, 0 ); // exclude current time fix for bug#69845
			dataEncoder.extractValue ( value, date );
			return date;
		}
		return( null );
	}

	function externalToInternal(date)
	{
		if( date != null )
			return dataEncoder.formatValue( date );
		else
			return( "" );
	}

	function externalTypeName()
	{
		return "Date";
	}

	function internalTypeName()
	{
		return "String";
	}

	// -----------------------------------------------------------------------------------------

	// settings that are defined by the developer
	var format: String; // e.g. "MM/DD/YYYY HH:NN:SS"
	
	// private date
	var dataEncoder: mx.utils.StringFormatter;

} // class mx.data.encoders.Dte