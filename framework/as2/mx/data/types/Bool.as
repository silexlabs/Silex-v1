class mx.data.types.Bool extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["Boolean"];
	}

	function settableTypes() : Array /* of String */
	{
		return ["Number", "Boolean", "String"];
	}
	
	function getTypedValue( requestedType:String ):mx.data.binding.TypedValue {
/*		var result= super.getTypedValue( requestedType );
		// did we get the type we asked for?
		if( result != null )
			if(( requestedType == "String" ) && ( result.value == null ))
				result = new mx.data.binding.TypedValue( "", "String" );
		return( result );
*/		
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
		var value = null;
		if( newValue.value != null ) {
			if(( newValue.typeName == "Boolean" ) || ( newValue.typeName == "Number" ))
				value = Boolean( newValue.value );
			else {
				if( newValue.typeName == "String" ) {
					if( newValue.value.length > 0 ) {
						if( this.formatter != null ) 
							return( this.formatter.setTypedValue( newValue ));
						else {
							var strVal:String =newValue.value.toLowerCase();
							value = strVal == "true";
							if( !value && ( strVal != "false" )) {
								var num:Number = Number( strVal );
								if( isNaN( num ))
									return([mx.data.binding.DataAccessor.conversionFailed(newValue, "Boolean")]);
								else
									value = Boolean( num );
							}
						} // else..if formatter != null
					}
				} // if its a string
				else
					return([mx.data.binding.DataAccessor.conversionFailed(newValue, "Boolean")]);
			}
		} // if not null
		return( this.dataAccessor.setTypedValue( new mx.data.binding.TypedValue( value, "Boolean" )));
	}
}
