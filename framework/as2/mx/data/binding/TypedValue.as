/*
   Title:       TypedValue.as
   Description: defines the class "mx.data.binding.TypedValue"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A "TypedValue" object is a data value together with type information.
	
  @class TypedValue
	  @tiptext  a data value together with type information
	  @helpid 1590
*/
class mx.data.binding.TypedValue
{
	/**
	  @property	value
	  @tiptext  the data value of this object
	  @helpid 1586
	*/
	public var value;
	
	/**
	  @property	typeName;
	  @tiptext  the name of the DataType of the data value
	  @helpid 1587
	*/
	public var typeName: String;
	
	public var type; // a Schema
	public var getDefault:Boolean;

	/**
	  @method	TypedValue
	  @tiptext  constructor for the TypedValue class
	  @helpid 1588
	*/
	function TypedValue(value, typeName: String, type)
	{
		this.value = value;
		this.typeName = typeName;
		this.type = type;
	}
	
} // class mx.data.binding.TypedValue