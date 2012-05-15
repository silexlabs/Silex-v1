/*
   Title:       Formatter.as
   Description: defines the class "mx.data.binding.Formatter"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A Formatter is a DataAccessor that converts values between a "raw" form
	and a "formatted" form. A common usage is where the "raw" form is a
	datatype such as Number or Date, and the "formatted" form is a 
	human-readable character string.

	The return value from getTypedValue() is the formatted version of the raw data value
	that we fetch using this.dataAccessor.getTypedValue().

	The parameter to setTypedValue() is formatted data, which we unformat back into 
	a raw data value, then pass to this.dataAccessor.setTypedValue();

	@class Formatter
*/
class mx.data.binding.Formatter extends mx.data.binding.DataAccessor
{
} // interface mx.data.binding.Formatter
