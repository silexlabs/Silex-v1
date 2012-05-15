//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
  The AutoTrigger kind is just like the Data kind, except that
  it calls the component's 'trigger' function anytime a
  new value is set.
  
*/
class mx.data.kinds.AutoTrigger extends mx.data.kinds.Data 
{
	// This function gets called every time databinding assigns
	// a new value to this field.
	function setTypedValue(newValue: mx.data.binding.TypedValue) : Array /* of String */
	{
		// First, let the superclass actually set the value
		var result: Array = super.setTypedValue(newValue);
		
		// If that succeeded, then trigger the component.
		if (result == null)
		{
			this.component.trigger();
		}
		
		return result;
	}

	// This function gets called once, when we are created.
	function setupDataAccessor(component: Object, property: String, location: Object)
	{	
		// First, let the superclass do its thing
		super.setupDataAccessor(component, property, location);
		
		// If it doesn't already have one, override the 
		// component's 'trigger' function with our own version.
		if (component.__orig__trigger == undefined)
		{
			component.__orig__trigger = component.trigger;
			
			// The only purpose of our trigger function is to prevent
			// recursive calls to trigger, which would otherwise
			// happen when the component calls "this.refreshFromSources".
			component.trigger = function ()
			{
				if (this.__inTrigger != true)
				{
					this.__inTrigger = true;
					this.__orig__trigger();
					this.__inTrigger = false;
				}
			};
		}
	}
}
