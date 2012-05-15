/*
   Title:       DataAccessor.as
   Description: defines the class "mx.data.binding.DataAccessor"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A DataAccessor is a object that gives get/set access to an underlying piece of data.
	The DataAccessor can transform or process the data any way it likes, during the 
	get/set operation. The underlying data is accessed by calling *another* DataAccessor, 
	therefore allowing you to have chains of these things. For example, you could set 
	up a chain like this:
	<blockquote>
	DataAccessor A formats data<br>
	DataAccessor B performs a key-to-value translation<br>
	DataAccessor C encodes data<br>
	DataAccessor D retrieves/stores actual data<br>
	</blockquote>
	When you call A.getTypedValue(), it calls B.getTypedValue() and formats the result.<br>
	When you call B.getTypedValue(), it calls C.getTypedValue() and translates the results.<br>
	When you call C.getTypedValue(), it calls D.getTypedValue() and decodes the results.<br>
	When you call D.getTypedValue(), it actually retrieves the stored data.<br>
	
  @class DataAccessor
*/
class mx.data.binding.DataAccessor
{
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Retrieves the current value of the data as a typed value.

	  @method		getAnyTypedValue
	  @parameter	suggestedTypes	an array of Strings, each of which is a type name. 
	  @return		the current value of the data. This value can be retrieved and processed
	  in any way you choose. The type will be the first type in "suggestedTypes" that we are 
	  capable of creating. If we can't get the value as any of the types, then we'll
	  just return whatever type we can.
	  @tiptext  Retrieves the current value of the data, given a list of suggested types.
	  @helpid 1592
	*/

	function getAnyTypedValue(suggestedTypes: Array /* of String */) : mx.data.binding.TypedValue
	{
		//Debug.trace("mx.data.binding.DataAccessor.getAnyTypedValue", suggestedTypes);
		// See if any of the requested types is available
		for (var i = 0; i < suggestedTypes.length; i++)
		{
			var result = this.getTypedValue(suggestedTypes[i]);
			if (result != null) return result;
		}
		
		// No luck. See if we can get the data in some other form, and convert it.
		var result = this.getTypedValue();
		//Debug.trace("mx.data.binding.DataAccessor.getAnyTypedValue, trying to convert to", suggestedTypes);
		for (var i = 0; i < suggestedTypes.length; i++)
		{
			var t: String = suggestedTypes[i];
			if (t == "String") return new mx.data.binding.TypedValue(String(result.value), t);
			if (t == "Number") return new mx.data.binding.TypedValue(Number(result.value), t);
			if (t == "Boolean") return new mx.data.binding.TypedValue(Boolean(result.value), t);
		}

		// We can't find a conversion we know how to do. Let the caller deal with it.
		//Debug.trace("mx.data.binding.DataAccessor.getAnyTypedValue, trying to convert to", suggestedTypes);
		return result;
	}

	/**
	  Sets the data to a new value, with additional conversion.

	  @method	setTypedValue
	  @param	newValue		A data value. Its type can be one of the type returned by getSettableTypes,
								or it can be any other type. In the latter case, we will make some extra
								attempts to convert the data to an acceptable form.
	  @returns	if the newValue was acceptable, then null is returned. Otherwise, we return 
				an array of error messages.
	  @tiptext  Sets the data to a new value, tries more type conversions if necessary.
	  @helpid 1593
	*/
	function setAnyTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue", newValue);
		var settableTypes = this.getSettableTypes();
		if ((settableTypes == null) || (-1 != mx.data.binding.DataAccessor.findString(newValue.typeName, settableTypes)))
		{
			//Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue, don't need to convert");
			return this.setTypedValue(newValue);
		}
		else
		{
			for (var i = 0; i < settableTypes.length; i++)
			{
				var t: String = settableTypes[i];
				if (t == "String")
				{
					//Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue, converting to String");
					return this.setTypedValue(new mx.data.binding.TypedValue(String(newValue.value), t));
				}
				if (t == "Number")
				{
					////Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue, converting to Number");
					var convertedValue = Number(newValue.value);
					var result = this.setTypedValue(new mx.data.binding.TypedValue(convertedValue, t));
					if (convertedValue.toString() == "NaN")
					{	
						return ["Failed to convert '" + newValue.value + "' to a number"];
					}
					else
					{
						return result;
					}
				}
				if (t == "Boolean")
				{
					//Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue, converting to Boolean");
					return this.setTypedValue(new mx.data.binding.TypedValue(Boolean(newValue.value), t));
				}
			}
		}
		//Debug.trace("mx.data.binding.DataAccessor.setAnyTypedValue, not converting");
		return this.dataAccessor.setTypedValue(newValue);
	}
	
	// -----------------------------------------------------------------------------------------
	/**
	  Retrieves the current value of the data as a typed value.

	  @method		getTypedValue
	  @parameter	requestedType	a string which is a type name, or null.
	  @return		the current value of the data, if we can produce it in the
	  requested type. If we can't get the value as the requested type, we return null.
	  If the requested type is null, then we return it as whatever type we like.
	*/
	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var result = this.dataAccessor.getTypedValue(requestedType);
		//Debug.trace("mx.data.binding.DataAccessor.getTypedValue", requestedType, result);
		return result;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Retrieves a list of types that getTypedValue can produce.

	  @method	getGettableTypes
	  @return	an Array of type names. When you call getTypedValue, we prefer that you request
	  from it a value of one of these types.
	  .
	*/
	function getGettableTypes() : Array /* of String */
	{
		return null;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Sets the data to a new value, of a given type.

	  @method	setTypedValue
	  @param	newValue		A data value. Its type should be one of the type returned by getSettableTypes.
	  @returns	if the newValue was acceptable, then null is returned. Otherwise, we return 
				an array of error messages.
	*/
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.binding.DataAccessor.setTypedValue", newValue);
		return this.dataAccessor.setTypedValue(newValue);
	}
	
	// -----------------------------------------------------------------------------------------

	/**
	  Retrieves a list of types that setTypedValue can accept.

	  @method	getSettableTypes
	  @return	an Array of type names. When you call setTypedValue, we prefer that call it with
	  a value of one of these types.
	  .
	*/
	function getSettableTypes() : Array /* of String */
	{
		return null;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Find the last DataAccessor object in the chain. This is the one that actually 
	  retrieves/stores data from/to its final destination.

	  @method	findLastAccessor
	  @return	a FieldAccessor object that actually reads/write data to storage
	*/
	function findLastAccessor() : mx.data.binding.DataAccessor
	{
		return (this.dataAccessor == null) ? this : this.dataAccessor.findLastAccessor();
	}

	// -----------------------------------------------------------------------------------------

	/**
		Initializes this object. This function should be called right after calling
		the constructor.

	  @method	setupDataAccessor
	  @param	component	a component
	  @param	property	the name of a property of the component
	  @param	location	a location, in the same form as described in the EndPoint class.
	*/
	function setupDataAccessor(component: Object, property: String, location: Object)
	{
		//Debug.trace("mx.data.binding.DataAccessor.setupDataAccessor");
		this.component = component;
		this.property = property;
		this.location = location;
		this.type = component.findSchema (property, location);
	}

	// -----------------------------------------------------------------------------------------

	/**
		Find out where a string appears in an Array of strings.

	  @method	findString
	  @param	str			a String
	  @param	arr			an array of strings
	  @return	-1 if str was not found in arr, the index of str if it was found.
	*/
	static function findString(str: String, arr: Array /* of String*/)
	{
		//Debug.trace("mx.data.binding.DataAccessor.findString", str, arr);
		var s = str.toLowerCase();
		for (var i = 0; i < arr.length; i++)
		{
			if (arr[i].toLowerCase() == s) return i;
		}
		//Debug.trace("mx.data.binding.DataAccessor.findString failed");
		return -1;
	}
	
	static function conversionFailed(newValue: mx.data.binding.TypedValue, target: String) : String
	{
		return "Failed to convert to " + target + ": '" + newValue.value + "'";
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
		The object which gives me access to the underlying data value.

	  @property dataAccessor
	*/
	public var dataAccessor: mx.data.binding.DataAccessor;
	public var type: Object;
	public var component: Object;
	public var property: String;
	public var location: Object;

} // class mx.data.binding.DataAccessor
