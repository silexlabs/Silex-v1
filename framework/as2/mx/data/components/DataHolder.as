/*
   Title:       DataHolder.as
   Description: defines the class "mx.data.components.DataHolder"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

[Event("data")] 

/**
	A component that just knows how to hold data.

  @class DataHolder
  @tiptext A component that holds any data you want
  @helpid	1558
*/
[RequiresDataBinding(true)]
[IconFile("DataHolder.png")]
class mx.data.components.DataHolder extends MovieClip
{
	// -----------------------------------------------------------------------------------------
	// 
	// Functions
	//
	// -----------------------------------------------------------------------------------------

	function DataHolder()
	{
		//trace("DataHolder constructor");
		//Debug.trace(this.__schema);
		this.addedProperties = new Object();

		// Make this object able to send events to listeners.
		mx.events.EventDispatcher.initialize(this);
		
		// Make sure this component is not visible
		this._visible = false;
		
		// Create property getter/setters for each
		// property in our schema.
		for (var i in Object(this).__schema.elements)
		{
			var name: String = Object(this).__schema.elements[i].name;
			this.addProp(name);
		}
		
		// Make the dataholder automagically create any property 
		// that is bound to. This is needed because our schema will not
		// usually be available at the time the constructor is run.
		this.superAddBinding = mx.data.binding.ComponentMixins.prototype.addBinding;
	}

	private function addProp(property)
	{
		//Debug.trace("DataHolder.addProp", property);
		if (this.addedProperties[property] == 1) return;
		this.addedProperties[property] = 1;

		var getter = function()
		{
			return this.getProp(property);
		};
		
		var setter = function(val)
		{
			this.setProp(property, val);
		};
			
		this.addProperty(property, getter, setter);
	}

	public function addBinding(binding: mx.data.binding.Binding)
	{
		//Debug.trace("DataHolder.addBinding");
		// Add getter/setters for any properties that are bound to
		if (binding.source.component == this)
		{
			this.addProp(binding.source.property);
		}
		if (binding.dest.component == this)
		{
			this.addProp(binding.dest.property);
		}
		
		this.superAddBinding(binding);
	}	
	
	private function getProp(property)
	{
		//Debug.trace("getProp", property);
		return this["___" + property];
	}

	private function setProp(property, val)
	{
		//Debug.trace("setProp", property, val);
		this["___" + property] = val;
		this.signalChanged(property);
	}
	
	public function propertyModified (property, directly)
	{
		if (!directly)
		{
			this.signalChanged(property);
			// if the property was directly changed, then we've already signaled the event
		}
	}
	
	private function signalChanged(property)
	{
		this.dispatchEvent({type: property});
	}

	// onUpdate gets called when this component is being used as a live preview swf in Flash Authoring
	public function onUpdate()
	{
		this._visible = true;
	}

	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	var superAddBinding:Function;
	var addedProperties:Object;
	
	// Initially we have a single bindable property "data".
	// The user can add more, via the schema panel, if desired.
	
	/**
  	  @tiptext The data contained in this component
	  @helpid  1559
	*/
	[Bindable]
	[ChangeEvent("data")]
	var data;

	// Following are declarations for functions we inherit from the event dispatcher mixin.
	/**
	* @private
	* @see mx.events.EventDispatcher
	*/
	var dispatchEvent:Function;

	/**
	* @see mx.events.EventDispatcher
	* @tiptext Adds a listener for an event
	* @helpid 3958
	*/
	var addEventListener:Function;

	/**
	* @see mx.events.EventDispatcher
	*/
	var removeEventListener:Function;
} // interface mx.data.components.DataHolder