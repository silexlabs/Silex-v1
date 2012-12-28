/*
   Title:       DataType.as
   Description: defines the class "mx.data.binding.DataType"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	The base class for all data type objects. 
	
	A data type object is a facade which gives value-added read/write access to a 
	data field. Functionality includes:
	- validation: inspect the data to see if it's a valid value for this datatype
	- conversion: convert a piece of data to/from this datatype
	- formatting: parameterized conversion to/from string
	- encoding: parameterized conversion to/from internal data representation

	By default, a data field is simply a property of a certain component. Optionally, the data 
	field may be a specific sub-field within that property, identified by a location path.

  @class DataType
	  @tiptext  Provides get/set access to a field of a component property
	  @helpid 1591
*/

class mx.data.binding.DataType extends mx.data.binding.DataAccessor
{
	
	// -----------------------------------------------------------------------------------------
	// 
	// public Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Initializes a new DataType object. This would normally be called from 
	  within Component.createField().
	  
	  @method				DataType constructor
	*/
	public function DataType()
	{
		this.errorArray = null;
	}
	
	function setupDataAccessor(component: Object, property: String, location: Object)
	{	
		super.setupDataAccessor(component, property, location);

		// figure out the schema for this object
		this.type = component.findSchema(property, location);

		// create the kind object
		if (this.type.kind != undefined)
		{
			// create the kind object, using info in the schema...
			this.kind = mx.data.binding.Binding.getRuntimeObject(this.type.kind);
		}
		else
		{
			this.kind = new mx.data.kinds.Data();
		}
		this.kind.setupDataAccessor(component, property, location);

		// The Kind object is the initial element of the dataAccessor chain
		this.dataAccessor = this.kind;
		
		if (this.type.encoder != undefined)
		{
			// create the encoder object, using info in the schema...
			this.encoder = mx.data.binding.Binding.getRuntimeObject(this.type.encoder);
			this.encoder.setupDataAccessor(component, property, location);
			
			// link the object into the dataAccessor chain
			this.encoder.dataAccessor = this.dataAccessor;
			this.dataAccessor = this.encoder;
		}
		
		if (this.type.formatter != undefined)
		{
			// create the formatter object, using info in the schema...
			this.formatter = mx.data.binding.Binding.getRuntimeObject(this.type.formatter);
			this.formatter.setupDataAccessor(component, property, location);

			// the formatter is just another way to access our DataAccessor chain
			this.formatter.dataAccessor = this.dataAccessor;
		}
		
		// !!@ do we want to do validation any time we set the value?
		// if so, we should link a validating DataAccessor into the dataAccessor chain
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// public Functions inherited from DataAccessor
	//
	// -----------------------------------------------------------------------------------------

	// -----------------------------------------------------------------------------------------
	// 
	// public cover functions for various get/set typed values
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Gets the current value, converted to a Boolean
	  
	  @method		GetAsBoolean
	  @return		the current value, expressed as a Boolean
	  @tiptext  Gets the current value, as a Boolean
	  @helpid 1575
	*/
	public function getAsBoolean() : Boolean
	{
		var result = this.getAnyTypedValue(["Boolean"]);
		return result.value;
	}

	/**
	  Gets the current value, converted to a Number
	  
	  @method		getAsNumber
	  @return		the current value, expressed as a Number
	  @tiptext  Gets the current value, as a Number
	  @helpid 1576
	*/
	public function getAsNumber() : Number
	{
		var result = this.getAnyTypedValue(["Number"]);
		return result.value;
	}

	/**
	  Gets the current value, converted to a String.
	  
	  @method		getAsString
	  @return		the current value, expressed as a String
	  @tiptext  Gets the current value, as a String
	  @helpid 1577
	*/
	public function getAsString() : String
	{
		var result = this.getAnyTypedValue(["String"]);
		return result.value;
	}

	/**
	  Sets the current value. The new value is given as a Boolean, 
	  but will be converted to, and stored as, the appropriate internal type.
	  
	  @method		setAsBoolean
	  @param		newValue	the new value, given as a Boolean
	  @tiptext  Sets the current value, from a Boolean
	  @helpid 1578
	*/
	public function setAsBoolean(newValue: Boolean)
	{
		this.setAnyTypedValue(new mx.data.binding.TypedValue(newValue, "Boolean"));
	}

	/**
	  Sets the current value. The new value is given as a Number, 
	  but will be converted to, and stored as, the appropriate internal type.
	  
	  @method		setAsNumber
	  @param		newValue	the new value, given as a Number
	  @tiptext  Sets the current value, from a Number
	  @helpid 1579
	*/
	public function setAsNumber(newValue: Number)
	{
		this.setAnyTypedValue(new mx.data.binding.TypedValue(newValue, "Number"));
	}

	/**
	  Sets the current value. The new value is given as a String, 
	  but will be converted to, and stored as, the appropriate internal type.
	  
	  @method		setAsString
	  @param		newValue	the new value, given as a String
	  @tiptext  Sets the current value, from a String
	  @helpid 1580
	*/
	public function setAsString(newValue: String)
	{
		this.setAnyTypedValue(new mx.data.binding.TypedValue(newValue, "String"));
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-public functions
	//
	// -----------------------------------------------------------------------------------------


	/**
	  Records a validation error. You should call this function from "validate" each time
	  you detect an error. It's ok to detect and report multiple errors in a single "validate" 
	  call. If "validate" doesn't report any errors, this means the data is valid.
	  
	  @method					validationError
	  @param	errorMessage	An string containing an error message
	*/
	function validationError(errorMessage : String)
	{
		// This function is called when a validation error occured.
		// Store a queue of all validation errors in this.errorArray.

		if (this.errorArray == null)
			this.errorArray = new Array();
		this.errorArray.push(errorMessage);
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-public functions you should override
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Validates the data value. You should override this function in a subclass of DataType.
	  Call "validationError" if you find any errors. Have fun and be safe.
	  
	  @method					validate
	*/
	function validate(value)
	{
	}

	// -----------------------------------------------------------------------------------------
	// 
	// Jason - these are all the functions from Firefly Field classes. 
	// I have categorized them according to our new class breakdown.
	// I don't know quite what the API should be. It could look 
	// something like this for formatter/encoder/kind:
	//
	// firefly version 1
	//	var f = component.getField("BattingAvg");
	//  f.setPrecision(3);
	//  f.setLookupDataSet(xxx);
	//
	// matador:
	//	var f = component.getField("BattingAvg");
	//	f.formatter.precision = 3;
	//  f.kind.lookupDataSet = xxx;
	// 
	// For schema access, maybe we do f.schema.defaultValue
	//
	// note also there are a few other questions below .. 
	// -----------------------------------------------------------------------------------------

	// -- schema access
	// defaultData
	// getDefaultValue
	// getCharacterRestrict
	// getType

	// -- formatter access
	// getTextAlign
	// get/setPrecision - applies when datatype = number
	// get/setCurrencySymbol - applies when datatype = money
	// setDisplayValues - applies when datatype = boolean
	
	// -- encode/decode access
	// setDataValues - applies when datatype = boolean
	// setDataFormat - applies when datatype = date
	// convertToForeign - runs the encoder
	// convertToNative - runs the decoder

	// -- validator access
	// getSize - applies when datatype - string
	
	// -- kind access
	// getLookupInfo - applies when kind = lookup
	// setLookupDataSet - applies when kind = lookup
	// refresh - applies when kind = lookup
	// getPath - applies when kind = "X"
	// isCalculated - replaced by "GetKind"
	// isLookup - replaced by "GetKind"

	// -- these methods are specific to fields of the dataset component
	// getIndex
	// getIndexMap
	// getPrimaryIndexName
	// getRecordData
	// isIndexed

	// -- specific to the DateTime datatype
	// getAsDateTime 
	// setAsDateTime 	
	
	// -- where do these things happen?
	// input masking
	// 
	
	// -----------------------------------------------------------------------------------------
	// 
	// public Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  The list of errors that were generated by the function "validate". Each element
	  of the array is an object containing these fields:<p>
  	  <dl>
		<dt>message : String</dt><dd>an error message</dd>
		<dt>field : String</dt><dd>[optional] name of the field or sub-field causing the error</dd>
	  </dl>
   
	  @property errorArray
	*/
	public var errorArray;

	/**
	  You can use the properties schema, kind, formatter, and encoder to access
	  the different helper objects of this field. Some or all of them may be null.
   
	  @property schema,kind,formatter,encoder
	*/
	public var type: Object;

	/**
	  @property kind
	  @tiptext  The kind object for this field
	  @helpid 1581
	*/
	public var kind : mx.data.binding.DataAccessor;

	/**
	  @property formatter
	  @tiptext  The formatter object for this field
	  @helpid 1582
	*/
	public var formatter : mx.data.binding.Formatter;

	/**
	  @property encoder
	  @tiptext  The encoder object for this field
	  @helpid 1583
	*/
	public var encoder : mx.data.binding.DataAccessor;
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Properties
	//
	// -----------------------------------------------------------------------------------------

	//public var dataAccessor; // inherited from DataAccessor
	public var sortInfo; // used by DataSet	
	private var id;
	
	// -----------------------------------------------------------------------------------------
	// 
	// New
	//
	// -----------------------------------------------------------------------------------------

	/**
	  @method	getTypedValue
	  @tiptext  Get the value of this field, as a specified DataType
	  @helpid 1584
	*/
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		//Debug.trace("-1-mx.data.binding.DataType.getTypedValue", this.type, requestedType);
		// If a String was requested, and we have a formatter, then use it.
		var result: mx.data.binding.TypedValue;
		
		if ((requestedType == "String") && (this.formatter != null))
		{
			//trace(1);
			result = this.formatter.getTypedValue(requestedType);
		}
		else
		{
			//trace(2);
			// let our dataAccessor chain try to give us something of the desired value
			result = this.dataAccessor.getTypedValue(requestedType);
			//Debug.trace( "-2-mx.data.binding.DataType.getTypedValue", result );
			if (result.type == null)
			{
				result.type = this.type;
			}
			if (result.typeName == null)
			{
				result.typeName = this.type.name;
			}
			//Debug.trace( "-3-mx.data.binding.DataType.getTypedValue", result );
		}
		if ((result.typeName != requestedType) && (requestedType != null)) {
			result = null;
		}
		else if(!requestedType && result.typeName == "XML" &&  result.type.name == "String") 
		{
			// bug# 79142 : special casing for XML and string.
			// if there was no requestedType passed check against the type.name
			result = null;
		}
		//Debug.trace("-4-mx.data.binding.DataType.getTypedValue", requestedType, result);
		return result;
	}
	
	function getGettableTypes() : Array /* of String */
	{
		var result = new Array();
		var gettableTypes = this.gettableTypes();
		if (gettableTypes != null)
			result = result.concat(gettableTypes);
		if (this.type.name != null)
			result = result.concat(this.type.name);
		if (this.formatter != null)
			result = result.concat(this.formatter.getGettableTypes());

		if (result.length == 0)
			return null;
		else
			return result;
	}

	/**
	  @method	setTypedValue
	  @tiptext  Set the value of this field
	  @helpid 1585
	*/
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.binding.DataType.setTypedValue", newValue);
		if ((newValue.typeName == "String") && 
			(this.formatter != null))
		{
			return this.formatter.setTypedValue(newValue);
		}
		else
		{
			var settableTypes = this.dataAccessor.getSettableTypes();
			if ((settableTypes == null) || (-1 != mx.data.binding.DataType.findString(newValue.typeName, settableTypes)))
			{
				return this.dataAccessor.setTypedValue(newValue);
			}
			else
			{
				return ["Can't set a value of type " + newValue.typeName];
			}
		}
	}

	function getSettableTypes() : Array /* of String */
	{
		//Debug.trace("mx.data.binding.DataType.getSettableTypes");

		var result = new Array();
		var settableTypes = this.settableTypes();
		if (settableTypes != null)
			result = result.concat(settableTypes);
		if (this.type.name != null)
			result = result.concat(this.type.name);
		if (this.formatter != null)
			result = result.concat(this.formatter.getSettableTypes());
			
		//Debug.trace("mx.data.binding.DataType.getSettableTypes result", result);
		
		if (result.length == 0)
			return null;
		else
			return result;
			
	}

	function gettableTypes(): Array /* of String */
	{
		return this.dataAccessor.getGettableTypes();;
	}

	function settableTypes(): Array /* of String */
	{
		return this.dataAccessor.getSettableTypes();
	}
	
		/**
	  Validates the data in the field, and optionally dispatches the resulting valid/invalid events, as follows:<ul>

	  <li>If the value is null, and the field <strong>is not</strong> required, 
	  we return null and don't dispatch any events.</li>

	  <li>If the value is null, and the field <strong>is</strong> required, 
	  we return some errors, and dispatch an "invalid" event.</li>

	  <li>If the value is non-null and the field's type <strong>does not</strong> have a validator defined for it,
	  we return null and don't dispatch any events</li>

	  <li>If the value s non-null and a validator <strong>does</strong> exist, then we run the validator, 
	  dispatch either a "valid" or "invalid" event, 
	  and return null (for valid) or an array of messages (for invalid).</li>
	  </ul>
	  
	  Validation only applies to fields which have type information available. 
	  Fields that are objects with child elements will try to validate each child field 
	  (and so on, recursively). Each individual field will dispatch a "valid" or "invalid" event if necessary.
  
	  @method	validateAndNotify
	  @param	returnData		[optional] if this field is non-null, and if we cause an event
								to be dispatched, then returnData.event will be set to a copy 
								of that event. This is provided so you can look at the event yourself.
	  @param	noEvent			if true, we do not dispatch any events. If false, we DO dispatch 
								either a "valid" or an "invalid" event.
      @param	initialMessages1
      @return					an Array of error messages. The array contains all errors detected
								either by this field, or by any sub-fields that are validatable.
								This array has the same structure as the "errorArray" property 
								of the class mx.data.binding.DataType.
	*/
	
	public function validateAndNotify(returnData : Object, noEvent: Boolean, initialMessages: Array) : Array
	{					
		var sendEvent : Boolean = false;
		
		this.errorArray = null;
		for (var i in initialMessages)
		{
			this.validationError(initialMessages[i]);
			sendEvent = true;
		}
		
		var val : mx.data.binding.TypedValue = this.getTypedValue();
		if ((val.value == null) || (val.value == ""))
		{
			if (this.type.required == false)
			{
				//trace("DataType.getValidator() - " + this.fieldName + " not required");
				_global.__dataLogger.logData(this.component, 
					"Validation of null value succeeded because field '<property>/<m_location>' is not required", this);
			}
			else
			{
				//trace("FieldAccessor.getValidator() - " + this.fieldName + " MISSING");
				var loc: String = (this.location == null) ? "" : (":" + String(this.location));
				this.validationError("Required item '" + this.property + loc + "' is missing");
				sendEvent = true;
			}
		}
		else
		{
			this.validate(val.value);
			sendEvent = true;
		}

		if (sendEvent && (noEvent != true))
		{		
			var event = new Object();
			event.type = (this.errorArray == null) ? "valid" : "invalid";
			event.property = this.property;
			event.location = this.location; // !!@ need a more printable version of this
			event.messages = this.errorArray;
			//Debug.trace("sendevent", event);
			this.component.dispatchEvent(event);

			returnData.event = event;
		}
		return this.errorArray;
	}
}

