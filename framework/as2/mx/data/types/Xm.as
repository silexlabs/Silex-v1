class mx.data.types.Xm extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["XML"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["XML", "String"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		var result : Array = null;
		var value : mx.data.binding.TypedValue = new mx.data.binding.TypedValue();
		value.typeName = "XML";
		if (newValue.typeName == "XML")
		{
			value.value = newValue.value;
			value.type = newValue.type;
		}
		else if (newValue.typeName == "String")
		{
			var x: XML = new XML();
			x.ignoreWhite = (this.ignoreWhite == "true");
			x.parseXML(newValue.value);
			value.value = x;
		}
		else
		{
			result = [mx.data.binding.DataAccessor.conversionFailed(newValue, "XML")];
		}

		//Debug.trace("mx.data.types.Xm.setTypedValue", newValue, value);
		var result2 = this.dataAccessor.setTypedValue(value);
		if (result != null)
			return result;
		else
			return result2;
	}

	function validate()
	{
	}
	
	// author-time settings
	var ignoreWhite : String;
}
