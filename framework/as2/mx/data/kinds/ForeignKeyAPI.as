/*
   Title:       ForeignKeyAPI.as
   Description: defines the interface "mx.data.kinds.ForeignKeyAPI"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	The API that the Lookup kind uses to talk to Foreign key fields

  @interface ForeignKeyAPI
*/
class mx.data.kinds.ForeignKeyAPI extends mx.data.kinds.Data
{
	function getLookupValue(requestedType: String, dataColumn: String) : mx.data.binding.TypedValue
	{
		return null;
	}
	
	function getLookupValueType() : String
	{
		return null;
	}

	function setLookupValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		return null;
	}
	
	function getDataChangeInfo() : Object
	{
		return null;
	}
	
	public static function stringToLocation(s: String) : Object
	{
		if (s == null) return null;

		var loc: Array = s.split(".");
		if (loc instanceof Array)
			return loc;
		else
			return [loc];
	}

	public static function getFieldChangeEvent(component, property, location) : String
	{
		var schema = component.findSchema (property, location);
		//Debug.trace("getDataChangeInfo....", component, property, schema);
		return (schema.event == null) ? property : schema.event;
	}

} // interface mx.data.kinds.ForeignKeyAPI
