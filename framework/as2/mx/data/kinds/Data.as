/*
   Title:       Data.as
   Description: defines the class "mx.data.kinds.Data"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A default kind, that just passes all requests to a FieldAccessor
	
  @class Data
*/
class mx.data.kinds.Data extends mx.data.binding.DataAccessor // mx.data.binding.Kind
{
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var result : mx.data.binding.TypedValue;
		var rawResult = this.getFieldAccessor().getValue();
		var typeName: String = null;
		if( rawResult != null ) {
			if (rawResult instanceof Array)
			{
				typeName = "Array";
			}
			else if ((rawResult instanceof XMLNode) || (rawResult instanceof XMLNode))
			{
				typeName = "XML";
			}
			else
			{
				var t: String = typeof(rawResult);
				typeName = t.charAt(0).toUpperCase() + t.slice(1);
			}
			//if (requestedType != typeName) typeName = null;
		}
		else
			rawResult = null;
		result = new mx.data.binding.TypedValue(rawResult, typeName, null);
		//Debug.trace("mx.data.kinds.Data.getTypedValue", requestedType, result);
		return result;
	}

	function getGettableTypes() : Array /* of String */
	{
		return null;
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.kinds.Data.setTypedValue", newValue);
		this.getFieldAccessor().setValue(newValue.value, newValue); // added newValue param for bug #65229
		return null;
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return null;
	}

	// we create a new field accessor every time we want to look at the data,
	// because the data structure can change, and unfortunately the fieldAccessor
	// keeps references into the data structure. TODO: make it so you don't have
	// to create a new fieldAccessor each time, because it's probably a bit slow.
	private function getFieldAccessor()	: mx.data.binding.FieldAccessor
	{
		//Debug.trace("mx.data.kinds.Data.getFieldAccessor creating field accessor", this.property, this.location);
		return this.component.createFieldAccessor(this.property, this.location, false /* !!@ */);
	}

} // class mx.data.kinds.Data
