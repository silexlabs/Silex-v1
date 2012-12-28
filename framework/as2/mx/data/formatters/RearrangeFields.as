/*
   Title:       RearrangeFields.as
   Description: defines the class "mx.data.formatters.RearrangeFields"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/



/**
	A formatter for rearranging the fields of a data record, or an array of data records.
	
  @class RearrangeFields
*/
class mx.data.formatters.RearrangeFields extends mx.data.binding.DataAccessor
{
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  The list of fields  
  
	  @property	fields
	*/
	var fields : String;
	
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	function getGettableTypes() : Array /* of String */
	{
		return ["DataProvider"];
	}
	
	// Format an Array, result is a DataProvider
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		//Debug.trace("mx.data.formatters.RearrangeFields.getTypedValue", requestedType);
		// parse the remapping specifications
		var tokens = this.fields.split("'");
		for (var i = 1; i < tokens.length; i += 2)
		{
			var quotedThing = tokens[i];
			quotedThing = mx.data.binding.ObjectDumper.replaceAll(quotedThing, ";", "&xxsemixx&");
			quotedThing = mx.data.binding.ObjectDumper.replaceAll(quotedThing, "=", "&xxeqxx&");
			tokens[i] = quotedThing;
		}
		tokens = tokens.join("'").split(";");
		//trace("TOKENS:" + mx.data.binding.ObjectDumper.ToString(tokens));
		
		var fieldInfo = new Array;
		for (var i = 0; i < tokens.length; i++)
		{
			var items = tokens[i].split("=");
			var data = items[1];
			var dataTokens = data.split("'");
			if (dataTokens.length == 3)
			{
				var message = dataTokens[1];
				message = mx.data.binding.ObjectDumper.replaceAll(message, "&xxsemixx&", ";");
				message = mx.data.binding.ObjectDumper.replaceAll(message, "&xxeqxx&", "=");
				fieldInfo.push({name: items[0], message: message});
			}
			else
				fieldInfo.push({name: items[0], field: data});
		}
		//Debug.trace("fieldInfo", fieldInfo);
		
		// fetch the raw data
		var rawValue: mx.data.binding.TypedValue = this.dataAccessor.getTypedValue();
		var rawData = rawValue.value;
		var rawDataType = rawValue.typeName;
		//Debug.trace("mx.data.formatters.RearrangeFields.getTypedValue, value is", rawValue);

		var isDataProvider: Boolean = (rawDataType == "DataProvider");
		if ((rawData instanceof Array) || isDataProvider)
		{
			//Debug.trace("mx.data.formatters.RearrangeFields.getTypedValue, is dataprovider or array");
			var arrayItemType = rawValue.type.elements[0].type;
			//Debug.trace("mx.data.formatters.RearrangeFields.getTypedValue, arrayItemType", arrayItemType);
			var result = new Array();
			for (var i = 0; i < rawData.length; i++)
			{
				var input = isDataProvider ? rawData.getItemAt(i) : rawData[i];
				var output = new Object();
				
				for (var j = fieldInfo.length - 1; j >= 0; j--)
				{
					var f = fieldInfo[j];
					var outputData;
					//Debug.trace("mx.data.formatters.RearrangeFields.getTypedValue, value is", rawValue);

					if (f.message != null)
						outputData = mx.data.binding.Log.substituteIntoString(f.message, input, null, arrayItemType);
					else if (f.field == ".")
						outputData = input;
					else
					{
						var type = mx.data.binding.FieldAccessor.findElementType(rawValue.type.elements[0].type, f.field);
						//trace("new fa(" + mx.data.binding.ObjectDumper.ToString(input) + "," + type + ",,,,," + f.field + ")");
						var fa = new mx.data.binding.FieldAccessor(null, null, input, f.field, type, null, null);
						outputData = fa.getValue();
						//Debug.trace("outputData", outputData);
						//outputData = input[f.field];
					}
						
					if (f.name == ".")
						output = outputData;
					else
						output[f.name] = outputData;
				}
				result.push(output);
			}

			//trace("RAWDATA:" + mx.data.binding.ObjectDumper.ToString(rawData));
			//trace("RESULT:" + mx.data.binding.ObjectDumper.ToString(result));
			//Debug.trace(result);
			return new mx.data.binding.TypedValue(result, "DataProvider");
		}
	}

}; // class mx.data.formatters.RearrangeFields
