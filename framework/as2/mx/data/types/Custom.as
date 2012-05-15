/*
   Title:       Custom.as
   Description: defines the class "mx.data.types.Custom"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A datatype which is validated by a user-specified class.

  @class Custom
*/
class mx.data.types.Custom extends mx.data.binding.DataType
{	
	function gettableTypes() : Array /* of String */
	{
		return null;
	}

	function settableTypes() : Array /* of String */
	{
		return null;
	}

	function validate(value)
	{
		Setup();
		//Debug.trace("mx.data.types.Custom.validate");
		validator.validate(value);
	}

	// parameter provided by author
	var classname : String;

	// the developer-provided validator object
	private var validator;

	private function Setup()
	{
		// we can't do this work when the constructor is called,
		// because our settings (i.e. classname) are not available at that time.
		
		if (this.validator == null)
		{	
			var cls = mx.utils.ClassFinder.findClass(this.classname);
			this.validator = new cls();
			if (this.validator == null)
			{
				_global.__dataLogger.logData(null, 
					"Error: can't create custom validator class '<classname>'", this);
			}
			this.validator.field = this;
		}
	}

} // class mx.data.types.Custom
