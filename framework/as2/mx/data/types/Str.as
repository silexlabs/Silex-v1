class mx.data.types.Str extends mx.data.binding.DataType
{
	function getTypedValue( requestedType:String ):mx.data.binding.TypedValue {
		var value:mx.data.binding.TypedValue = super.getTypedValue( requestedType );
		if(( value.value == null ) && ( requestedType == "String" ))
			value.value = "";
		return( value );
	}
	
	function gettableTypes() : Array /* of String */
	{
		return ["String"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["String"];
	}

	var tooLongError = "This string is longer than the maximum allowed length.";
	var tooShortError = "This string is shorter than the minimum allowed length.";

	function validate(value)
	{
		//Debug.trace("mx.data.types.Str.validate", value);
		var val : String = String(value);
		
		if ((this.maxLength != null) && (val.length > this.maxLength))
		{
			this.validationError(this.tooLongError);
		}

		if ((this.minLength != null) && (val.length < this.minLength))
		{
			this.validationError(this.tooShortError);
		}
	}

	// validator settings that come from the author
	var minLength: Number;
	var maxLength: Number;
}
