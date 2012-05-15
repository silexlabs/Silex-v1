/*
   Title:       ArrayForeignKey.as
   Description: defines the class "mx.data.kinds.ArrayForeignKey"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A kind that represents a foreign key into a data table that is an array or a dataprovider.
	
  @class ArrayForeignKey
*/
class mx.data.kinds.ArrayForeignKey extends mx.data.kinds.ForeignKeyAPI
{
	// properties that are set by the author
	public var dataComponent: String;
	public var dataProperty: String;
	public var dataLocation: String;
	public var indexColumn: String;

	// the array/dataprovider from which we get our data
	private var dataProviderField : mx.data.binding.DataType;
	
	// returns component.property.location[indexColumn == mycurrentvalue].dataColumn
	function getLookupValue(requestedType: String, dataColumn: String) : mx.data.binding.TypedValue
	{
		var dataProvider = this.dataProviderField.getTypedValue().value;
		var key = this.getTypedValue().value;
		var resultType: String = "String"; // !!@ Figure this out from the schema!
		
		var length: Number = dataProvider.length;
		for (var i: Number = 0; i < length; i++)
		{
			var record;
			if (dataProvider.getItemAt != null)
				record = dataProvider.getItemAt(i);
			else
				record = dataProvider[i];

			//Debug.trace("mx.data.kinds.ArrayForeignKey.getLookupValue record", record);
			if (record[this.indexColumn] == key)
			{
				//Debug.trace("mx.data.kinds.ArrayForeignKey.getLookupValue return", record[dataColumn]);
				return new mx.data.binding.TypedValue(record[dataColumn], resultType);
			}
		}
		
		return null;
	}
	
	function getLookupValueType() : String
	{
		return null;
	}
	
	function setLookupValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		return ["mx.data.kinds.ArrayForeignKey.setLookupValue not implemented"];
	}

	function getDataChangeInfo() : Object
	{
		var event: String = getFieldChangeEvent(this.dataProviderField.component, this.dataProviderField.property, this.dataProviderField.location);
		return {component: this.dataProviderField.component, event: event};
	}

	function setupDataAccessor(component: Object, property: String, location: Object)
	{
		super.setupDataAccessor(component, property, location);

		var comp = eval(this.dataComponent);
		//Debug.trace("mx.data.kinds.ArrayForeignKey.setup", this.dataComponent, comp, this.dataProperty, this.dataLocation, this.indexColumn);
		if (comp == null)
		{
			_global.__dataLogger.logData(component, 
				"Error: data array <comp> does not exist",
				{comp: this.dataComponent});
			return;
		}
		mx.data.binding.ComponentMixins.initComponent(comp);
					
		this.dataProviderField = comp.getField(this.dataProperty, stringToLocation(this.dataLocation)); 
	}

} // class mx.data.kinds.ArrayForeignKey
