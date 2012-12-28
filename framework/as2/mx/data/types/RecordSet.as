class mx.data.types.RecordSet extends mx.data.binding.DataType
{
	function gettableTypes() : Array /* of String */
	{
		return ["RecordSet", "DataProvider", "Array"];
	}

	function getTypedValue( requestedType:String ):mx.data.binding.TypedValue {
		var result: mx.data.binding.TypedValue;
		// if we want just an array
		if( requestedType == "Array" ) {
			result = this.dataAccessor.getTypedValue();
			if( result.value != null ) {
				// set the page mode if we need to
				if( pgMode != null )
					result.value.setDeliveryMode( pgMode, pgSize, pgPrefetch );
				result.value = result.value.items;
			}
		}
		else {
		    // otherwise return the RecordSet object or null we asked for something we don't have
			result = this.dataAccessor.getTypedValue( requestedType );
			if( result.type == null )
				result.type = this.type;
				
			if( requestedType != null ) 
				result.typeName = requestedType;
			else
				result.typeName = this.type.name;
				
			// set the page mode
			if(( result.value != null ) && ( pgMode != null ))
				result.value.setDeliveryMode( pgMode, pgSize, pgPrefetch );
		}
		return( result );
	}
	
	function settableTypes() : Array /* of String */
	{
		return ["DataProvider", "RecordSet", "Object"];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		var result : Array = null;
		var value : mx.data.binding.TypedValue = new mx.data.binding.TypedValue();
		value.typeName = "RecordSet";
		if ((newValue.typeName == "RecordSet") || (newValue.typeName == "Object") || (newValue.typeName="DataProvider" ))
		{
			value.value = newValue.value;
			value.type = newValue.type;
		}
		else
		{
			return( [mx.data.binding.DataAccessor.conversionFailed(newValue, "RecordSet")]);
		}

		return this.dataAccessor.setTypedValue(value);
	}

	function validate()
	{
	}
	
	// set by authoring tool in validation options dialog
	var pgMode:String;
	var pgSize:Number;
	var pgPrefetch:Number;
}
