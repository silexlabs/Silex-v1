/*
   Title:       Binding.as
   Description: defines the class "mx.data.binding.Binding"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

import mx.data.binding.EndPoint;
import mx.data.binding.Formatter;

/**
	Defines an association between two endpoints, a source and a destination.
	The Binding object listens for changes to the source endpoint, and copies the 
	data to the destination endpoint each time the source changes.

  @class Binding
  @tiptext An object that transfers data between 2 components
  @helpid 1564
  @codehint _bnd
*/
class mx.data.binding.Binding
{
	// -----------------------------------------------------------------------------------------
	// 
	// Published Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Initializes a new Binding object. Registers the Binding 
	  as a listener for the 'data changed' event of the source endpoint.
	  @method			Binding
	  @param	source	The source endpoint of the binding. This parameter is nominally of type
	  "EndPoint", but in fact it can be any actionscript object that has the required fields.
	  @param	dest	The destination endpoint of the binding. This
						must not be a constant. The 'event' field of the destination is only
						needed if the binding is 2-way.
	  @param	format	[optional] An object containing formatting information. The properties of this object are:<p>
	  <dl>
		<dt>cls : class</dt><dd>an actionscript class which implements the interface mx.data.binding.Formatter.</dd>
		<dt>className : String</dt><dd>a string containing the name of an actionscript class which implements the interface mx.data.binding.Formatter</dd>
		<dt>settings : Object</dt><dd>an object whose properties are option settings for the formatter</dd>
	  </dl>
	  <p>
	  <code>cls</code> and <code>className</code> contain the same information, and you can give one or the other of these, <strong>but not both</strong>. 
	  The difference is that <code>cls</code> is an actual reference to the class, whereas <code>className</code> is the name of 
	  the class as a string. If you choose to give the class name as a string, you must also reference that class directly somewhere
	  in actionscript code - this reminds Flash to include a copy of the class in your SWF. Examples:
	  <blockquote>
	  {cls: com.mycompany.MyFormatter, settings: {precision: 3, separator: ","}}<br>
	  {className: "com.mycompany.MyFormatter", settings: {precision: 3, separator: ","}}
	  </blockquote>
	  @param	is2way	[optional] A boolean which is true if the binding is bi-directional.
	  @return			The Binding object that was just created. You don't need to keep a reference to 
						this object - it will keep itself alive as long as needed.
						<p>Warning: after creating a Binding, do not modify the fields of the objects 
						that were passed as parameters to the constructor. The results will be unpredictable.
	  @tiptext Create a binding between 2 components
	  @helpid 1589
	  @example
<pre>
new Binding (
	{constant: "abc123"}, 
	{component: _root.Screen1.serviceCall1, property: "params", location: "password"});

foo = new Binding (
	{component: myServiceCall1, property: "results", event: "result"},
	{component: myDisplayText1, property: "text"},
	{cls: com.mycompany.SpecialFormatter},
	true);

src = new mx.data.binding.EndPoint();
src.component = myXmlDocument;
src.property = "results";
src.event = "result";
new mx.data.binding.Binding (src, {component: myComboBox, property: "dataProvider"});
src.location = "something"; // This line won't work! Do it *before* calling 'new Binding'

</pre>

	*/
	public function Binding (source : Object, dest : Object, format : Object, is2way : Boolean)
	{
		//trace ("new Binding()");
		//trace("NB-SOURCE: " + source.constant + "," + source.component + "," + 
		//	source.property + "," + source.location + "," + source.event);
		//trace("NB-DEST: " + dest.constant + "," + dest.component + "," + 
		//	dest.property + "," + dest.location + "," + dest.event);
		//trace("NB-FORMAT: " + format);
		//trace("NB-IS2WAY: " + is2way);
		
		//Debug.trace("new Binding", source);
		
		// Make this object able to send events to listeners.
		mx.events.EventDispatcher.initialize(this);
		
		var temp = this;
		temp.source = source;
		temp.dest = dest;
		temp.format = format;
		temp.is2way = is2way;
		//this.sub = sub;

		// See if this binding might be needed by screens
		registerBinding(this);
		
		// prepare nice-looking location for logging
		calcShortLoc(source);
		calcShortLoc(dest);

		_global.__dataLogger.logData(null, "Creating binding " + this.summaryString() + (is2way ? ", 2-way" : ""), {binding: this});
		_global.__dataLogger.nestLevel++;
		
		mx.data.binding.ComponentMixins.initComponent(dest.component);
		if (source.component != undefined)
			mx.data.binding.ComponentMixins.initComponent(source.component);

		dest.component.addBinding(this);
		if (source.component != undefined)
		{			
			source.component.addBinding(this); // lets component update binding
			setUpListener(source, false);
			if (this.is2way)
			{
				setUpListener(dest, true);
				setUpIndexListeners(source, false);
				setUpIndexListeners(dest, true);
			}
			else
			{
				setUpIndexListeners(source, false);
				setUpIndexListeners(dest, false);
			}
			
		}
		else
		{
			// Since the source is constant, it will never trigger itself. So let's do it once.
			execute();
		}
		_global.__dataLogger.nestLevel--;
	}
	// -----------------------------------------------------------------------------------------

	/**
	  Fetches the data from the source, formats it, and assigns it to the destination.
	  Validates the data and causes either a 'valid' or 'invalid' event to be emitted by
	  the destination and source components. Data is assigned to the destination even
	  if its invalid, unless the destination is read-only.
	  
	  @method	execute
	  @param	reverse		A boolean which is true if the binding is to be executed in the 
		reverse direction (dest -> source).
	  @return	any error messages that were generated as a result of the assignment. These are either
	  @tiptext Perform a tranfer of data from source to destination
	  @helpid 1565
		 
	*/
	public function execute (reverse : Boolean) : Array /* of String */
	{
		//trace("Binding.execute(" + this.num + "," + reverse + ")");
		
		// Figure out which end is the source, and which is the dest
		var src : EndPoint;
		var dst : EndPoint;
		if (reverse)
		{
			if (!this.is2way)
			{
				_global.__dataLogger.logData(null, 
					"Warning: Can't execute binding " + this.summaryString(false) + " in reverse, because it's not a 2 way binding", 
					{binding: this}, mx.data.binding.Log.BRIEF);
				return ["error"];
			}
			src = this.dest;
			dst = this.source;
		}
		else
		{
			src = this.source;
			dst = this.dest;
		}
		
		// Start a nested log entry		
		_global.__dataLogger.logData(null, "Executing binding " + this.summaryString(reverse), {binding: this});
		_global.__dataLogger.nestLevel++;

		// Set up the source field
		var sourceField;
		if (src.constant != undefined)
		{
			// create a DataAccessor-like wrapper object for the constant value
			sourceField = 
			{
				value: new mx.data.binding.TypedValue(src.constant, "String"),
				getAnyTypedValue: function() {return this.value;},
				getTypedValue: function() {return this.value;},
				getGettableTypes: function() {return ["String"];}
			};
		}
		else
		{
			sourceField = src.component.getField(src.property, src.location, true);
		}

		// We collect information in these vars, for outputting to the Log
		// !!@ this stuff is broken - fix it
		var unformattedValue;
		var formatterFrom;
		var formatInfo : String = "";

		// Set up the destination field
		var destField : mx.data.binding.DataType = dst.component.getField(dst.property, dst.location);

		// See if the binding has a formatter. If so, append the formatter to the front of the source field.
		if (this.format != null)
		{
			var formatter = getRuntimeObject(this.format);
			if (formatter != null)
			{
				//Debug.trace("mx.data.binding.Binding.execute. formatter =", formatter, reverse);
				//formatterFrom = "binding";
				//unformattedValue = value;
				//formatInfo = " (Value '<unformattedValue>' was formatted using <formatterFrom>'s settings";
				
				if (reverse)
				{
					formatter.setupDataAccessor(dst.component, dst.property, dst.location);
					formatter.dataAccessor = destField;
					destField = formatter;
				}
				else
				{
					formatter.setupDataAccessor(src.component, src.property, src.location);
					formatter.dataAccessor = sourceField;
					sourceField = formatter;
				}
			}
		}

		// Fetch the value from the source. If there's a formatter, then ask for raw data,
		// otherwise ask for the type(s) that the destination accepts.
		var okTypes = (this.format == null) ? destField.getSettableTypes() : null;
		var value : mx.data.binding.TypedValue = sourceField.getAnyTypedValue(okTypes);
		//Debug.trace("mx.data.binding.Binding.execute. okTypes =", okTypes, "value =", value);

		// We're now ready to do the assignment
		var returnData = new Object();
		//trace("destField.type:" + mx.data.binding.ObjectDumper.toString(destField.type));
		if (destField.type.readonly == true)
		{
			// We can't assign to the destination because its readonly
			_global.__dataLogger.logData(null, "Not executing binding because the destination is read-only", 
				null, mx.data.binding.Log.BRIEF);

			// Create an 'invalid' event, and make the destination component emit it.
			//trace("READONLY: " + dst.property + "," + dst.location);
			var ev = new Object();
			ev.type = "invalid";
			ev.property = dst.property;
			ev.location = dst.location;
			ev.messages = [{message: "Cannot assign to a read-only data field."}];
			dst.component.dispatchEvent(ev);
			
			// Save a copy of the event so that the source component can also emit it.
			returnData.event = ev;
		}
		else
		{		
			//if (value == null)
			//{
			//	_global.__dataLogger.logData(null, 
			//		"Binding " + this.summaryString(reverse) + " -- source data is null", 
			//		{binding: this}, mx.data.binding.Log.WARNING);
			//}
			
			_global.__dataLogger.logData(null, "Assigning new value '<value>' (<typeName>) " + formatInfo, 
				{value: value.value, typeName: value.typeName, unformattedValue: unformattedValue, formatterFrom: formatterFrom});
			
			// Here is where we actually do the assignment. the return
			// value is any type conversion errors that happened.
			var messages : Array = destField.setAnyTypedValue(value);
			
			// See if the data is valid. This will emit a 'valid' or 'invalid' event.
			destField.validateAndNotify(returnData, false, messages);

			// tell anyone who's interested that a binding has executed
			dst.component.dispatchEvent({type: "bindingExecuted", binding: this});
		}

		// If a valid/invalid event got generated, pass it on to the source component.
		if (returnData.event != null)
		{
			if (src.component != null)
			{
				var otherevent = new Object();
				otherevent.type = returnData.event.type;
				otherevent.property = src.property;
				otherevent.location = src.location;
				otherevent.messages = returnData.event.messages;
				otherevent.to = dst.component;
				src.component.dispatchEvent(otherevent);
				
				// hook for data console
				//var x = mx.data.binding.Binding;
				//trace("dispatching..." + otherevent.property);
				//x.dispatchEvent(otherevent);
			}
		}
		
		// Finish the nested log entry.
		_global.__dataLogger.nestLevel--;
		
		return returnData.event.messages;
	}


	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Functions
	//
	// -----------------------------------------------------------------------------------------
	
	
	/**
	  Queues the binding for execution at a safe time.

	  @method	queueForExecute
	  @return	none
		 
	*/
	private function queueForExecute(reverse)
	{
		//Debug.trace("Binding.queueForExecute()", _root.__databind_dispatch, _global.__databind_executeQueue);
		if (!this.queued)
		{
			if (_global.__databind_executeQueue == null)
			{
				_global.__databind_executeQueue = new Array();
			}
			if (_root.__databind_dispatch == undefined)
			{
				_root.createEmptyMovieClip("__databind_dispatch", -8888);
			}
			_global.__databind_executeQueue.push(this);
			this.queued = true;
			this.reverse = reverse;
			_root.__databind_dispatch.onEnterFrame = dispatchEnterFrame;
		}
		else
		{
			//_global.__dataLogger.logData(null, "Binding " + this.summaryString(reverse) + " not executed because it's already active", {binding: this});
		}
	}

	private static function dispatchEnterFrame()
	{
		//trace("dispatchEnterFrame");
		_root.__databind_dispatch.onEnterFrame = null;
		
		// Process all the bindings
		var i : Number = 0;
		while (i < _global.__databind_executeQueue.length)
		{
			var binding : mx.data.binding.Binding = _global.__databind_executeQueue[i];
			binding.execute(binding.reverse);
			i ++;
		}
		
		// clear out the list
		var b : mx.data.binding.Binding;
		while ((b = _global.__databind_executeQueue.pop()) != null)
		{
			b.queued = false;
			b.reverse = false;
		}
	}
	
	private function calcShortLoc(endpoint)
	{
		// !!@ should include indices in this...
		var temp = endpoint.location;
		if (temp.path != null) temp = temp.path;
		endpoint.loc = (temp instanceof Array) ? temp.join(".") : temp;
	}
	
	private function summaryString(reverse : Boolean)
	{
		var d : String = "<binding.dest.component>:<binding.dest.property>:<binding.dest.loc>";
		var s : String = "<binding.source.component>:<binding.source.property>:<binding.source.loc>";

		if (this.source.constant == null)
		{
			if (reverse == true)
			{
				return "from " + d + " to " + s;
			}
			else
			{
				return "from " + s + " to " + d;
			}		
		}
		else
		{
			return "from constant '<binding.source.constant>' to " + d;
		}
	}

	// -----------------------------------------------------------------------------------------

	public static function getRuntimeObject(info : Object, constructorParameter : Object)
	{
		//trace("getRuntimeObject: " + mx.data.binding.ObjectDumper.toString(info));
		if (info.cls == undefined)
		{
			info.cls = mx.utils.ClassFinder.findClass(info.className);
		}
		
		var result = new info.cls(constructorParameter);
		if (result == null)
		{
			_global.__dataLogger.logData(null, "Could not construct a formatter or validator - new <info.className>(<params>)", 
				{info: info, params: constructorParameter}, mx.data.binding.Log.BRIEF);
		}
		
		for (var j in info.settings)
		{
			result[j] = info.settings[j];
		}
				
		return result;
	}

	public static function refreshFromSources(component: Object, property: String, bindings : Array) : Array /* of String */
	{
		var result: Array = null;
		var i : Number;
		for (i = 0; i < bindings.length; i++)
		{
			var binding : mx.data.binding.Binding = bindings[i];
			var thisResult: Array = null;
			if ((binding.dest.component == component) && ((property == null) || (property == binding.dest.property)))
			{
				//!!@ binding.source.component.refreshFromSources();
				thisResult = binding.execute();
			}
			else if (binding.is2way && (binding.source.component == component) && 
				((property == null) || (property == binding.source.property)))
			{
				//!!@ binding.dest.component.refreshFromSources();
				thisResult = binding.execute(true);
			}
			
			if (thisResult != null)
			{
				result = (result == null) ? thisResult : result.concat(thisResult);
			}	
								
			// if the binding we just executed was queued for execution, we must remove
			// it from the queue. This will prevent duplicate work, and more importantly, it
			// prevents a wierd race condition in the DataSet component. 
			/*
			for (var j : Number = 0; j < _global.__databind_executeQueue.length; j++)
			{
				var queuedBinding : mx.data.binding.Binding = _global.__databind_executeQueue[j];
				if (binding == queuedBinding)
				{
					_global.__databind_executeQueue.splice(j, 1);
					trace("removing binding from global executeQueue");
					break;
				}
			}
			*/
		}

		return result;
	}

	public static function refreshDestinations(component: Object, bindings : Array)
	{
		var i : Number;
		for (i = 0; i < bindings.length; i++)
		{
			var binding : mx.data.binding.Binding = bindings[i];
			if (binding.source.component == component)
			{
				binding.execute();
				//!!@ binding.dest.component.refreshDestinations();
			}
			else if (binding.is2way && (binding.dest.component == component))
			{
				binding.execute(true);
				//!!@ binding.source.component.refreshDestinations();
			}
		}
		for (i = 0; i < component.__indexBindings.length; i++)
		{
			var info = component.__indexBindings[i];
			info.binding.execute(info.reverse);
		}
	}
	
	// Returns true if the player allows you call getters from setters. 
	// The best way to find out for sure is to try it!
	// This function returns true only if we are running on Player 7 (or newer) 
	// AND this swf was compiled for Player 7 (or newer).
	static function okToCallGetterFromSetter()
	{
		var setter = function(val)
		{ 
			// call the getter, and save the result in value2
			this.value2 = this.value;
		};
		var getter = function ()
		{ 
			// just return a constant value
			return 5;
		};
		// create a new object, and define getter/setter functions for the "value" property
		var x = new Object();
		x.addProperty("value", getter, setter);
		
		// call the setter function, which will call the getter and stash the result
		x.value = 0;
		
		// see if the value returned by the getter is the same when we call the getter directly
		// if so, this means that calling the getter from the setter works.
		var result = x.value2 == x.value;
		//Debug.trace("okToCallGetterFromSetter result", result);
		return result;
	}
	
	private function setUpListener(endpoint, reverse)
	{
		var listener = new Object();
		listener.binding = this;
		listener.property = endpoint.property;
		listener.reverse = reverse;
		listener.immediate = mx.data.binding.Binding.okToCallGetterFromSetter();
		listener.handleEvent = function (event)
		{
			_global.__dataLogger.logData(event.target, "Data of property '<property>' has changed. <immediate>.", this);
			if (this.immediate)
			{
				if (this.binding.executing != true)
				{
					this.binding.executing = true;
					this.binding.execute(this.reverse);
					this.binding.executing = false;
				}
			}
			else
			{
				// In the current swf, it appears as if you can't call getters from setters.
				// Since we may well be inside a setter *right now*,
				// and since you need to call getters in order to execute a binding,
				// it would be unwise to execute any bindings right now.
				// Instead, we'll wait until this frame has finished processing,
				// so we are sure that we're not inside any setters.
				this.binding.queueForExecute(this.reverse);
			}
		};
		//Debug.trace("setUpListener", endpoint.event, endpoint.component, endpoint.component.addEventListener);
		if (endpoint.event instanceof Array)
		{
			for (var i in endpoint.event)
			{
				endpoint.component.__addHighPrioEventListener(endpoint.event[i], listener);
			}
		}
		else
		{
			endpoint.component.__addHighPrioEventListener(endpoint.event, listener);
		}
		mx.data.binding.ComponentMixins.initComponent(endpoint.component);
	}
	
	/**	if there are components which are indexes for this endpoint,
		set up a listener so that we can re-evaluate the binding
		when the index changes.
	*/
	private function setUpIndexListeners(endpoint, reverse)
	{
		if (endpoint.location.indices != undefined)
		{
			for (var i = 0; i < endpoint.location.indices.length; i++)
			{
				var index = endpoint.location.indices[i];
				if (index.component != undefined)
				{
					setUpListener(index, reverse);
					if (index.component.__indexBindings == undefined)
					{
						index.component.__indexBindings = new Array();
					}
					index.component.__indexBindings.push({binding: this, reverse: reverse});
				}
			}
		}
	}

	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Properties
	//
	// -----------------------------------------------------------------------------------------

	public var source :	EndPoint;
	public var dest :		EndPoint;
	private var format :	Formatter;
	private var is2way :	Boolean;
	private var sub :		Array;
	
	private var queued : Boolean = false;
	private var reverse : Boolean = false;
	private var num : Number;
	private static var counter : Number = 0;
	private var dispatchEvent:Function;

	// -----------------------------------------------------------------------------------------
	// 
	// Bindable screens 
	//
	// -----------------------------------------------------------------------------------------

	private static var screenRegistry: Object = new Object();
	
	private static function copyBinding(b: mx.data.binding.Binding)
	{
		var result = new Object();
		result.source = copyEndPoint(b.source);
		result.dest = copyEndPoint(b.dest);
		result.format = b.format;
		result.is2way = b.is2way;
		return result;
	}

	private static function copyEndPoint(e: mx.data.binding.EndPoint)
	{
		var result = new Object();
		result.constant = e.constant;
		result.component = String(e.component);
		result.event = e.event;
		result.location = e.location;
		result.property = e.property;
		return result;
	}

	/*
	static function deepCopy(x)
	{
		if (typeof(x) != "object") return x;
		if (x instanceof Array) return x;
		if (x instanceof MovieClip) return x;
		var result = new Object();
		for (var i in x)
		{
			result[i] = deepCopy(x[i]);
		}
		return result;
	}
	*/
	
	// !!@ what about indexes !!
	
	// This function gets called from frame 0.9 of every screen movieclip,
	// from code that is inserted by the authoring tool (in MBuilder).
	// The id is unique to that movieclip. Multiple instances of the clip
	// will of course have the same id.
	static function registerScreen(screen, id)
	{
		//Debug.trace("registerScreen", screen, id);

		var symbol = screenRegistry[id];
		if (symbol == null)
		{
			// "screen" is the first instance of this screen to be registered.
			// This must be the instance that is statically authored onto the stage.
			// Just register its name and id.
			//Debug.trace("first instance");
			screenRegistry[id] = {symbolPath: String(screen), bindings: [], id: id};
			return;
		}
			
		// If the same instance is registering again, ignore it.	
		if (symbol.symbolPath == String(screen))
		{
			//Debug.trace("re-registering, ignored", screen, id);
			return;
		}

		// This is not the first instance of this screen. We must be a dynamically
		// created instance. Find all registered bindings that apply to the static 
		// instance, and replicate the binding as appropriate for this dynamic instance.
		var instancePath = String(screen);
		for (var i = 0; i < bindingRegistry.length; i++)
		{
			var b = bindingRegistry[i];
			var src = copyEndPoint(b.source);
			var dst = copyEndPoint(b.dest);
			var prefix = symbol.symbolPath + ".";
			var symbolContainsSource = (prefix == b.source.component.substr(0, prefix.length));
			var symbolContainsDest = (prefix == b.dest.component.substr(0, prefix.length));
			
			if (symbolContainsSource)
			{
				if (symbolContainsDest)
				{
					// Case 1: the source and dest of this binding are both inside the symbol screen
					//Debug.trace("Case 1", b.source.component, b.dest.component, symbol.symbolPath, symbol.id);

					src.component = eval(instancePath + src.component.substr(symbol.symbolPath.length));
					dst.component = eval(instancePath + dst.component.substr(symbol.symbolPath.length));
					var temp = new Binding(src, dst, b.format, b.is2way);
				}
				else
				{
					// Case 2: only the source of the binding is inside a symbol screen
					//Debug.trace("Case 2", b.source.component, b.dest.component, symbol.symbolPath, symbol.id);

					src.component = eval(instancePath + src.component.substr(symbol.symbolPath.length));
					dst.component = eval(dst.component);
					var temp = new Binding(src, dst, b.format, b.is2way);
				}
			}
			else // symbol does not contain source
			{
				if (symbolContainsDest)
				{
					// Case 3: only the dest of the binding is inside a symbol screen
					//Debug.trace("Case 3", b.source.component, b.dest.component, symbol.symbolPath, symbol.id);

					src.component = eval(src.component);
					dst.component = eval(instancePath + dst.component.substr(symbol.symbolPath.length));
					var temp = new Binding(src, dst, b.format, b.is2way);
				}
				else
				{
					// Case 4: neither source nor dest of this binding are inside this symbol screen
					//Debug.trace("Case 4", b.source.component, b.dest.component, symbol.symbolPath, symbol.id);
				}
			}
						
		}
	}		

	static var bindingRegistry: Array = new Array();
	
	static function registerBinding(binding)
	{
		var b = copyBinding(binding);
		//Debug.trace("registerBinding", b);
		bindingRegistry.push(b);
	}
	
	public static function getLocalRoot(clip)
	{
		//trace("Binding.getLocalRoot(" + clip + ")");
		var result;
		var url = clip._url;
		while (clip != null)
		{
			if (clip._url != url) break;
			result = clip;
			clip = clip._parent;
		}
		//trace("result = " + result);
		return result;
	}


}; // class Binding