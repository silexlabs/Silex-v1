/*
   Title:       ComponentMixins.as
   Description: defines additions to the class "mx.core.UIComponent"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	Defines component functionality related to DataBinding, These are properties
	and functions that are automatically added to any object that is the source
	or destination of a Binding (this is usually a UIComponent, but is not required to be).
	These functions do not affect normal component functionality,
	rather, they add functionality that is useful in conjunction with DataBinding.
	<p>These functions are only available on components that have already been included
	in a Binding, either as a source, a destination, or an index.

  @class ComponentMixins
  @tiptext Methods and properties that are available on any data-bound component
  @helpid 1560
*/
class mx.data.binding.ComponentMixins
{
	// -----------------------------------------------------------------------------------------
	// 
	// public Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  The Data schema for this component. This is automatically set for any components whose
	  schema is known by Flash at author-time. You may also set this property directly in
	  your actionscript code. <p>
	  A <strong>Schema</strong> is an ActionScript object, whose properties are a description of a
particular data type. The description contains information that is needed 
for type validation, type conversion, and other databinding-related operations.
A Schema object contains more-or-less the same information as is found
in the schema pane of the Component Inspector. See the documentation for 
the Component Inspector for more information.
A Schema object has the following fields - *all* fields are optional:
<blockquote><dl>
	<dt>name: String</dt><dd>the name of this type. This is ignored by databinding, except for one case: 
		the name "XML" indicates that the data is an XML object, rather than an ActionScript data structure. In
		this case, the category (below) must be "complex"</dd>
	<dt>category: String</dt><dd>This can be <ul>
		<li>"array" - the data is an array. The "elements" array (below) must contain exactly one item, which
			says what this is an array of.</li>
		<li>"attribute" - the data is an attribute that is attached to an XML node. This category can only appear
		if the type is describing a field inside an XML structure.</li>
		<li>"simple" - the data is a string, boolean, date, or number</li>
		<li>"complex" - the data is an object (either actionscript or XML). The "elements" array (below) 
		describes the fields of the object.</li>
		</ul>If category is omitted, it is assumed to be "simple" if elements is null, and "complex" otherwise.
		</dd>
	<dt>elements: Array of Element</dt><dd>if category = "complex", this is a list of all the fields
		of the object. if category = "array", this contains a single item. The schema for a component
		contains one element for each property. "Element" is described below.</dd>
	<dt>validation: ObjectSpec</dt><dd>describes a class of objects that will be created at runtime,
	to validate data, and do type conversion. The class must
		be a subclass of mx.data.binding.DataType. </dd>
	<dt>required: Boolean</dt><dd>if true, then null values are not valid</dd>
	<dt>readonly: Boolean</dt><dd>if true, then databinding will never write to this data</dd>
	<dt>format: ObjectSpec</dt><dd>describes a class of objects that will be created at runtime,
	to format data. The class must
		be a subclass of mx.data.binding.Formatter. </dd>
	<dt>value: Object</dt><dd>for use by the DataSet (Firefly) component</dd>
	<dt>label: String</dt><dd>for use by the DataSet (Firefly) component</dd>
	<dt>uicontrol: String</dt><dd>for use by the DataSet (Firefly) component</dd>
</dl></blockquote>
<p>Here are the fields of the <strong>Element</strong> object:
<blockquote><dl>
	<dt>name: String</dt><dd>the name of this field.</dd>
	<dt>type: Schema</dt><dd>the name of this field.</dd>
</dl></blockquote>
<p>The <strong>ObjectSpec</strong> object specifies how to create certain "helper" objects, as described above. The properties of this object are:<p>
	  <blockquote><dl>
		<dt>cls : class</dt><dd>an actionscript class.</dd>
		<dt>className : String</dt><dd>a string containing the name of an actionscript class</dd>
		<dt>settings : Object</dt><dd>an object whose properties are option settings for the created object</dd>
	  </dl></blockquote>
	  <p>
	  <code>cls</code> and <code>className</code> contain the same information, and you can give one or the other 
	  of these, <strong>but not both</strong>. 
	  The difference is that <code>cls</code> is an actual reference to a class, whereas <code>className</code> is the name of 
	  the class as a string. If you choose to give the class name as a string, you must also reference that class directly somewhere
	  in actionscript code - this reminds Flash to include a copy of the class in your SWF.

	  @example
<pre>
	  {elements: [{name: "dataProvider", type: {category: "array"}}, 
              {name: "selectedIndex", type: {validation: {className: "mx.data.types.Num", settings: {int: 0}}}}, 
              {name: "selectedIndices", type: {category: "array"}}, 
              {name: "selectedItem", type: {readonly: true}}, 
              {name: "selectedItems", type: {category: "array", readonly: true}}]}
</pre>
	For more examples, I recommend you take a look at the schema of any component in any Flash movie,
	for example with the following code:	
<pre>
		trace(mx.data.binding.ObjectDumper.toString(myComponent.__schema));
</pre>
	
	  @property __schema
	*/
	public var __schema : Object; /* DataSchema */
	public var __highPrioEvents : Object; 
	public var _eventDispatcher : Object; 
	public var _databinding_original_dispatchEvent : Function;
	public var dispatchEvent : Function;
	
	// -----------------------------------------------------------------------------------------
	// 
	// public Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Executes all the Bindings that have this component as the destination EndPoint. 
	  This causes the data to be completely up to date. This is a handy way to 
	  execute Bindings that have constant sources, or sources that do not emit
	  any 'data changed' event.
		
	  @method	refreshFromSources
	  @tiptext Execute all bindings that have this component as the destination
	  @helpid 1561
	*/
	public function refreshFromSources()
	{
		if (this.__refreshing != null) return;
		this.__refreshing = true;

		_global.__dataLogger.logData(this, "Refreshing from sources");
		_global.__dataLogger.nestLevel++;
		mx.data.binding.Binding.refreshFromSources(this, null, this.__bindings);
		_global.__dataLogger.nestLevel--;
		
		this.__refreshing = null;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Executes all the Bindings that have this object as the source EndPoint. 
	  This is a handy way to execute Bindings whose sources do not emit
	  a 'data changed' event.
		
	  @method	refreshDestinations
	  @tiptext Execute all bindings that have this component as the source
	  @helpid 1562
	*/
	public function refreshDestinations()
	{
		_global.__dataLogger.logData(this, "Refreshing Destinations");
		_global.__dataLogger.nestLevel++;
		mx.data.binding.Binding.refreshDestinations(this, this.__bindings);
		_global.__dataLogger.nestLevel--;
	}

	// -----------------------------------------------------------------------------------------

	/**
	  Checks to see if the data in the indicated property is valid. The validation is
	  based on the information in this component's __schema property.
	  For each field within the data, this function dispatches valid/invalid events as follows:<ul>

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

	  @method	validateProperty
	  @param	property	The name of a property of this component
	  @return	null, if the data is valid. Otherwise this is a array of descriptions of 
	  all the errors that were detected, including errors detected in fields of nested objects.
	  Each element of the array is an object containing these fields:<p>
  	  <dl>
		<dt>message : String</dt><dd>an error message</dd>
		<dt>field : String</dt><dd>[optional] name of the field or sub-field causing the error</dd>
	  </dl>
	  @tiptext Examine a selected property to see if has valid data
	  @helpid 1563
	  @example
<pre>
// Web service calls don't normally validate the data they receive,
// but we want to do it anyway. The webservicecall object will then
// emit a 'valid' or 'invalid' event, which we can then
// handle in any way we like.
_root.myWebServiceCall.addEventListener("result", function ()
{
	_root.myWebServiceCall.validateProperty("results");
});
</pre>
	*/
	public function validateProperty(property : String, initialMessages: Array) : Array
	{
		var messages : Array = null;

		var field : mx.data.binding.DataType = this.getField(property);
		if (field != null)
		{
			//Debug.trace("field non null");
			messages = field.validateAndNotify(null, null, initialMessages);
		}
		else
		{
			_global.__dataLogger.logData(this, "Can't validate property '<property>' because it doesn't exist", {property: property});
		}

		return messages;
	}

	// -----------------------------------------------------------------------------------------
	// 
	// non-public Functions
	//
	// -----------------------------------------------------------------------------------------

	public function addBinding(binding: mx.data.binding.Binding)
	{
		//trace("addbinding " + this);
		if (this.__bindings == undefined)
		{
			 this.__bindings = new Array();
		}
		this.__bindings.push(binding);
		
		// create and cache field objects for the endpoint(s) in this component
		var canBeSource : Boolean = false;
		if (binding.source.component == this)
		{
			this.getField(binding.source.property, binding.source.location);
			canBeSource = true;
		}
		if (binding.dest.component == this)
		{
			this.getField(binding.dest.property, binding.dest.location);
			canBeSource = Object(binding).is2way || canBeSource;
		}
		if (canBeSource)
		{
			var schema = binding.dest.component.findSchema(binding.dest.property, binding.dest.location);
			//Debug.trace("addBinding DEST", binding.dest.component, binding.dest.property, binding.dest.location, schema);
			if (schema.readonly)
			{
				binding.source.component.__setReadOnly(true);
			}
		}
	}

	/**
	  @method	initComponent
	  @tiptext  Add all the ComponentMixin functions to a component
	  @helpid 1573
	*/
	public static function initComponent(component)
	{
		//trace("ComponentMixins:initComponent " + component);
		var proto = mx.data.binding.ComponentMixins.prototype;

		if (component.refreshFromSources == undefined)
			component.refreshFromSources = proto.refreshFromSources;
		if (component.refreshDestinations == undefined)
			component.refreshDestinations = proto.refreshDestinations;
		if (component.validateProperty == undefined)
			component.validateProperty = proto.validateProperty;
		if (component.createFieldAccessor == undefined)
			component.createFieldAccessor = proto.createFieldAccessor;
		if (component.createField == undefined)
			component.createField = proto.createField;
		if (component.addBinding == undefined)
			component.addBinding = proto.addBinding;
		if (component.findSchema == undefined)
			component.findSchema = proto.findSchema;
		if (component.getField == undefined)
			component.getField = proto.getField;
		if (component.refreshAndValidate == undefined)
			component.refreshAndValidate = proto.refreshAndValidate;
		if (component.getFieldFromCache == undefined)
			component.getFieldFromCache = proto.getFieldFromCache;
		if (component.getBindingMetaData == undefined)
			component.getBindingMetaData = proto.getBindingMetaData;
		if (component.__setReadOnly == undefined)
			component.__setReadOnly = proto.__setReadOnly;
		if (component.__addHighPrioEventListener == undefined)
			component.__addHighPrioEventListener = proto.__addHighPrioEventListener;
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-public Properties
	//
	// -----------------------------------------------------------------------------------------

	private var __bindings : Array; /* of mx.data.binding.Binding */
	private var __refreshing;
	private var __fieldCache;

	// -----------------------------------------------------------------------------------------
	// 
	// NEW STUFF
	//
	// -----------------------------------------------------------------------------------------
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-public functions you might want to override
	//
	// -----------------------------------------------------------------------------------------
	
	/*
	  Get a FieldAccessor object corresponding to a specified location within
		the data of a property of this component. [in Beta 1, this function 
		was called GetFieldAccessor. I simply renamed it.]

	  @method				createFieldAccessor
	  @param	property	The name of a property of this component
	  @param	location	a location, in the same form as described in the EndPoint class.
      @param	mustExist	[optional] if this boolean is true, then we generate warning messages to the log
							if the field does not exist, or is null
	  @return				A FieldAccessor that gives access to the specified
							location of the specified property of this component.
	*/
	public function createFieldAccessor (property: String, location: Object, mustExist: Boolean) : mx.data.binding.FieldAccessor
	{
		return mx.data.binding.FieldAccessor.createFieldAccessor(this, property, location,
			mx.data.binding.FieldAccessor.findElementType(this.__schema, property), mustExist);
	};	

	// search my schema for a field
	public function findSchema (property: String, location: Object)
	{
		//Debug.trace("findSchema", property, location);
		if (typeof(location) == "string")
		{
			if (mx.data.binding.FieldAccessor.isActionScriptPath(String(location)))
			{
				// this is a Actionscript path,
				// turn it into an array
				location = location.split(".");
			}
			else
			{
				// if the location is an xpath, we don't know how to determine the type of the result
				return null;
			}
		}

		var type = mx.data.binding.FieldAccessor.findElementType(this.__schema, property);
		if (location != null)
		{
			// if location is an object with a path property, then we only want the path property.
			if (location.path != null) location = location.path;
			
			// the type must be an array of strings which represents a generic path
			if (!(location instanceof Array))
				return null;

			// drill down into the schema, to find the required location
			for (var i = 0; i < location.length; i++)
			{
				var item = location[i];
				type = mx.data.binding.FieldAccessor.findElementType(type, item);
			}
		}
		//Debug.trace("findSchema", property, location, type, this.__schema);
		return type;
	}

	public function createField (property: String, location: Object) : mx.data.binding.DataType
	{
		// find out what type this field is
		var type = this.findSchema(property, location);
		//trace(this + " createfield(" + property + "," + location + ") = " + mx.data.binding.ObjectDumper.toString(type));

		// create a DataType object for this field
		// (the datatype object will create a kind object, 
		// which will in turn maybe call createFieldAccessor.)
		var field;
		if (type.validation != null)
			field = mx.data.binding.Binding.getRuntimeObject(type.validation);
		else
			field = new mx.data.binding.DataType();

		field.setupDataAccessor(this, property, location);
		//Debug.trace("mx.data.binding.ComponentMixins.createField", field);
		return field;
	}

	static public function deepEqual(a, b) : Boolean
	{
		//Debug.trace("deepEqual", a, b);
		if (a == b) return true;
		if (typeof(a) != typeof(b)) return false;
		if (typeof(a) != "object") return false;
		
		var aFields = new Object();
		for (var i in a)
		{
			if (!deepEqual(a[i], b[i])) return false;
			aFields[i] = 1;		
		}
		for (var i in b)
		{
			if (aFields[i] != 1) return false;			
		}
		
		return true;
	}
	
	private function getFieldFromCache(property: String, location: Object) : mx.data.binding.DataType
	{
		for (var i in this.__fieldCache)
		{
			var f : mx.data.binding.DataType = this.__fieldCache[i];
			if ((f.property == property) && deepEqual(f.location, location))
			{
				//Debug.trace("found in cache", property, location);
				return f;
			}
		}
		
		//Debug.trace("not found in cache", property, location);
		return null;
	}
	
	/**
	  @method	getField
	  @tiptext  Get an object that gives access to a data field
	  @helpid 1574
	*/
	public function getField (property: String, location: Object) : mx.data.binding.DataType
	{
		// see if the field has already been created
		var f : mx.data.binding.DataType = getFieldFromCache(property, location);
		if (f != null) return f;
		
		// it hasn't so create it and add it to the cache
		f = this.createField(property, location);
		if (this.__fieldCache == null) this.__fieldCache = new Array();
		this.__fieldCache.push(f);
		return f;
	}

	public function refreshAndValidate(property: String) : Boolean
	{
		_global.__dataLogger.logData(this, "Refreshing and validating " + property);
		_global.__dataLogger.nestLevel++;
		var messages: Array = mx.data.binding.Binding.refreshFromSources(this, property, this.__bindings);
		messages = validateProperty(property, messages);
		_global.__dataLogger.nestLevel--;
		
		return (messages == null);
	}
	
	public function getBindingMetaData(name)
	{
		return this["__" + name];
	}
	
	public function __setReadOnly(setting)
	{
		// only change the value if the component appears to have such a property.
		if (Object(this).editable != undefined)
		{
			//Debug.trace("__setReadOnly: setting editable = false", this);
			Object(this).editable = !setting;
		}
	}

	// This function is a clone of EventDispatcher.addEventListener.
	// It adds the event to the component's high priority event queue.
	// It also gives the component a new dispatchEvent function that
	// knows how to dispatch high priority events.
	// The high prio event queue is simply a queue of event listeners
	// that is dispatched before all non-highprio listeners.
	public function __addHighPrioEventListener(event:String, handler): Void	
	{
		// We usually just want to add the highprio event queue to "this".
		// However, the dataset component doesn't dispatch its own events, it has
		// a helper object "_eventDispatcher". So in that case we'll add
		// the highprio event queue to the helper object.
		var obj = (this._eventDispatcher != undefined) ? this._eventDispatcher : this;
		
		// This code taken directly from addEventListener
		if (obj.__highPrioEvents == undefined) obj.__highPrioEvents = new Object;
		var queueName:String = "__q_" + event;
		if (obj.__highPrioEvents[queueName] == undefined)
		{
			obj.__highPrioEvents[queueName] = new Array();
		}
		_global.ASSetPropFlags(obj.__highPrioEvents, queueName,1);
		mx.events.EventDispatcher._removeEventListener(obj.__highPrioEvents[queueName], event, handler);
		obj.__highPrioEvents[queueName].push(handler);
		
		// Give the component a new dispatchEvent function that
		// knows how to dispatch high priority events.
		if (obj._databinding_original_dispatchEvent == undefined)
		{
			obj._databinding_original_dispatchEvent = obj.dispatchEvent;
			obj.dispatchEvent = function(eventObj:Object):Void
			{
				if (eventObj.target == undefined)
					eventObj.target = this;
				//Debug.trace("my dispatchEvent", eventObj.type, eventObj.target);
				
				this.dispatchQueue(this.__highPrioEvents, eventObj);
				this._databinding_original_dispatchEvent(eventObj);
			};
		}
	}

} // class mx.data.binding.ComponentMixins
