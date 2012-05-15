class mx.data.types.Dte extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["Date"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["Date", "String"];
	}
	
	function getTypedValue( requestedType:String ):mx.data.binding.TypedValue {
		var result: mx.data.binding.TypedValue;
		if( requestedType == "String" ) {
			if( this.formatter != null ) {
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
			result = this.dataAccessor.getTypedValue( requestedType );
			if( result.type == null )
				result.type = this.type;
				
			if( result.typeName == null )
				result.typeName = this.type.name;
				
			if(( result.typeName != requestedType ) && ( requestedType != null )) 
				result = null;
		}
		return( result );
	}
	
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		if( newValue.value != null ) {
			if( newValue.typeName == "String" ) {
				if( newValue.value.length > 0 ) {
					if( this.formatter != null ) 
						return( this.formatter.setTypedValue( newValue ));
					else 
						return([mx.data.binding.DataAccessor.conversionFailed(newValue, "Date")]);
				}
				else {
					newValue.typeName = "Date";
					newValue.value = null;
				}
			} // if string
		} // if not null
		return( this.dataAccessor.setTypedValue( newValue ));
	}
}
