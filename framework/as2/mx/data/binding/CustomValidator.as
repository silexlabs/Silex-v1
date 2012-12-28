/*
   Title:       CustomValidator.as
   Description: defines the class "mx.data.binding.CustomValidator"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	This defines a class that must be the parent of
	classes used by the Custom Validator.

	@class CustomValidator
*/
class mx.data.binding.CustomValidator
{
	// This function is called whenever we want
	// you to validate a value. If you find any problems,
	// call this.validationError with an appropriate message.
	// You must override this function.
	public function validate(value)
	{
	}
	
	private function validationError(message)
	{
		this.field.validationError(message);
	} 
	
	var field;
	
} // mx.data.binding.CustomValidator
