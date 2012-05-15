class mx.data.types.Num extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["Number", "Integer", "String"];
	}

	function getTypedValue( requestedType:String ):mx.data.binding.TypedValue {
		var result: mx.data.binding.TypedValue;
		if( requestedType == "String" ) {
			if( this.formatter != null ) {
				if( this.formatter instanceof mx.data.formatters.NumberFormatter ) 
					mx.data.formatters.NumberFormatter( this.formatter ).isInt = this.int;
					
				result = this.formatter.getTypedValue( requestedType );
			}
			else {
				result = this.dataAccessor.getTypedValue();
				if( result.value == null ) {
					result.value = "";
					result.typeName = "String";
				}
			}
		}
		else {
			if( requestedType == "Integer" )
				requestedType = "Number";
				
			result = this.dataAccessor.getTypedValue( requestedType );
			if( result.type == null )
				result.type = this.type;
				
			if( result.typeName == null )
				result.typeName = this.type.name;
				
			if(( result.typeName != requestedType ) && ( requestedType != null )) 
				result = null;
				
			if(( result.value != null ) && ( this.int ))
				result.value = Math.round( result.value );
		}
		return( result );
	}
	
	function settableTypes() : Array /* of String */
	{
		return ["Number", "Integer", "String", "Boolean", null];
	}
	
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if( newValue.value != null ) {
			if( newValue.typeName == "String" ) {
				if( this.formatter != null) 
					return( this.formatter.setTypedValue( newValue ));
				else {
					var	result;
					if( newValue.value.length == 0 ) {
						newValue.value = null;
						newValue.typeName = "Number";
						result = this.dataAccessor.setTypedValue( newValue );
					}
					else {
						var convError = convertStringToNumber( this.int, newValue );
						result = this.dataAccessor.setTypedValue( newValue );
					}
					return( convError == null ? result : convError );
				} // if has formatter
			} // if string
			else {
				// trunc it
				if( this.int )
					newValue.value = Math.round( newValue.value );
			}
		}
		return( this.dataAccessor.setTypedValue( newValue ));
	}
	
	public static function convertStringToNumber( isInt:Boolean, newValue:mx.data.binding.TypedValue ):Array {
		newValue.typeName = isInt ? "Integer" : "Number";
  		if( isInt )
			newValue.value = parseInt( newValue.value );
		else
			newValue.value = parseFloat( newValue.value );

		if( isNaN( newValue.value )) {
			newValue.value = 0;
			return([ mx.data.binding.DataAccessor.conversionFailed( newValue, isInt ? "Integer" : "Number" )]);
		}
		return( null );
	}

	var exceedsMaxError = "This number exceeds the maximum allowed value.";
	var lowerThanMinError = "This number is lower than the minimum allowed value.";
	var integerError = "This number must be an integer.";

	function validate(value)
	{		
		var n = Number(value);
		if ((this.maxValue != null) && (n > this.maxValue))
		{
			this.validationError(this.exceedsMaxError);
		}
		if ((this.minValue != null) && (n < this.minValue))
		{
			this.validationError(this.lowerThanMinError);
		}
		if (this.int && (n != Math.round(n)))
		{
			this.validationError(this.integerError);
		}
	}

	// settings that come from the author
	var minValue : Number;
	var maxValue : Number;
	var int: Boolean = false;
}
