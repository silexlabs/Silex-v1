/*
   Title:       Encoder.as
   Description: defines the class "mx.data.binding.Encoder"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An Encoder is a DataAccessor that transforms values between two datatypes: 
	1. a "private" datatype used for storing data internally. For example if
	the data is an xml document, then the data is always stored as a string, possibly with special
	formatting for datatypes such as date or numbers.
	2. a "public" datatype that we wish to use in code such as databinding, or developer-written actionscript code,
	For example, a public datatype might be Date or Number.
		
	The parameter to setTypedValue() is data in the "public" form, which we encode into 
	the private form, then pass to this.dataAccessor.setTypedValue();

	The return value from getTypedValue() is data that we fetch using 
	this.dataAccessor.getTypedValue(), then decode into the "public" form.

  @class Encoder
*/

class mx.data.binding.Encoder extends mx.data.binding.DataAccessor
{
} // class mx.data.binding.Encoder
