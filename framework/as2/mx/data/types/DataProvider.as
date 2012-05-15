class mx.data.types.DataProvider extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["DataProvider"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["DataProvider", "Array", "String", "Object"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		var result : Array = null;
		var value : mx.data.binding.TypedValue = new mx.data.binding.TypedValue();
		value.typeName = "DataProvider";
		if (newValue.typeName == "DataProvider")
		{
			value.value = newValue.value;
			value.type = newValue.type;
		}
		else if (newValue.typeName == "Array")
		{
			value.value = mx.data.binding.FieldAccessor.wrapArray(
				newValue.value, newValue.type.elements[0].type, this.component.getBindingMetaData("acceptedTypes")[this.property]);
			value.type = newValue.type;
		}
		else if (newValue.typeName == "String")
		{
			value.value = newValue.value.split(",");
		}
		else if (newValue.typeName == "Object")
		{
			// assume it's a dataprovider already
			value.value = newValue.value;
			value.type = newValue.type;
			/*
			value.value = new Array();
			for (var i in newValue.value)
			{
				value.value.push({label: i, data: newValue[i]});
			}
			*/
		}
		else
		{
			result = [mx.data.binding.DataAccessor.conversionFailed(newValue, "DataProvider")];
		}

		// If we are assigning a dataprovider that does not have an "editField" function,
		// then the grid should be marked as non-editable.
		if (typeof(value.value.editField) != "function")
		{
			this.component.__setReadOnly(true);
		}
		
		//Debug.trace("mx.data.types.DataProvider.setTypedValue", newValue, value);
		var result2 = this.dataAccessor.setTypedValue(value);
		if (result != null)
			return result;
		else
			return result2;
	}

	function validate()
	{
	}
}
