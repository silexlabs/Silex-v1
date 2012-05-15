/*
   Title:       Lookup.as
   Description: defines the class "mx.data.kinds.Lookup"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A kind that knows how to lookup a field in a dataset.
	
  @class Lookup
*/
class mx.data.kinds.Lookup extends mx.data.binding.DataAccessor
{
	// the foreign key field that we are associated with
	private var fkAccessor : mx.data.kinds.ForeignKeyAPI;
	
	// properties that are set by the author
	public var foreignKey: String;
	public var dataColumn: String;
		
	private static function getSiblingLocation(property: String, location, siblingName: String) : Object
	{
		var result: Object = new Object;
		if (location == null)
		{
			result.property = siblingName;
			// leave result.location null
		}
		else
		{
			result.property = property;
			if (typeof(location) == "string")
			{
				_global.__dataLogger.logData(null, 
					"Error: can't find sibling '<sib>' of <property>:<location> because location is an xpath",
					{property: property, location: location, sib: siblingName});
			}
			else if (location instanceof Array)
			{
				
				location.pop();
				location.push(siblingName);
			}
			else // we assume its's an indexed location
			{
				location.path.pop();
				location.path.push(siblingName);
			}
		}
		
		return result;	
	}

	function setupDataAccessor(component: Object, property: String, location: Object)
	{
		//Debug.trace("mx.data.kinds.Lookup.setupDataAccessor", component, property, location);
		super.setupDataAccessor(component, property, location);
		var fkLocation = getSiblingLocation(property, location, this.foreignKey);
		var fkField: mx.data.binding.DataType = 
			component.getField(fkLocation.property, fkLocation.location, true);
		//Debug.trace("mx.data.kinds.Lookup.setupDataAccessor got field", fkField, component, fkLocation.property, fkLocation.location);
		var fk = fkField.kind;
		this.fkAccessor = fk;
		if (!(fk instanceof mx.data.kinds.ForeignKeyAPI))
		{
			_global.__dataLogger.logData(component, 
				"Error: expected, but did not find, a ForeignKey field at <property>:<location>",
				{property: fkLocation.property, location: fkLocation.location});
		}

		// make a listener that can signal that the lookup field has changed		
		var listener = new Object();
		listener.component = component;
		listener.property = property;
		listener.location = location;
		listener.event = mx.data.kinds.ForeignKeyAPI.getFieldChangeEvent(component, property, location);
		listener.handleEvent = function (event)
		{
			// A field that affects the Lookup field has changed.
			// gGnerate a changedEvent for the Lookup field
			var ev = new Object();
			ev.type = this.event;
			ev.property = this.property;
			ev.location = this.location;
			//Debug.trace("Lookup field changed", ev);
			this.component.dispatchEvent(ev);
		};

		// attach the listener to the change event of the source data 
		var info = this.fkAccessor.getDataChangeInfo();
		//Debug.trace("this.fkAccessor.getDataChangeInfo", info);
		info.component.addEventListener(info.event, listener);

		// attach the listener to the change event of the foreign key field
		var event = mx.data.kinds.ForeignKeyAPI.getFieldChangeEvent(component, fkLocation.property, fkLocation.location);
		component.addEventListener(event, listener);
	}

	function getTypedValue(requestedType: String) : mx.data.binding.TypedValue
	{
		var result: mx.data.binding.TypedValue = this.fkAccessor.getLookupValue(requestedType, this.dataColumn);
		//Debug.trace("mx.data.kinds.Lookup.getTypedValue result", requestedType, result);
		return result;
	}

	function getGettableTypes() : Array /* of String */
	{
		return [this.fkAccessor.getLookupValueType()];
	}

	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		//Debug.trace("mx.data.kinds.Lookup.setTypedValue", newValue);
		return this.fkAccessor.setLookupValue(newValue.value);
	}
	
	function getSettableTypes() : Array /* of String */
	{
		return [this.fkAccessor.getLookupValueType()];
	}
	
	/*
	private function setUpListener(endpoint)
	{
		var listener = new Object();
		listener.binding = this;
		listener.property = endpoint.property;
		listener.reverse = reverse;
		listener.handleEvent = function (event)
		{
			_global.__dataLogger.logData(event.target, "Data of property '<property>' has changed", this);
			this.binding.queueForExecute(this.reverse);
		}
		endpoint.component.addEventListener(endpoint.event, listener);
		mx.data.binding.ComponentMixins.initComponent(endpoint.component);
	}
	*/
	
} // class mx.data.kinds.Lookup

