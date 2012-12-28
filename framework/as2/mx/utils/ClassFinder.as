/*
   Title:       Utils.as
   Description: defines the class "mx.utils.ClassFinder"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	A miscellanous collection of functions
	
  @class Utils
*/
class mx.utils.ClassFinder
{
	/**
		Find a class constructor by it's name.
		
		@param fullClassName String containing the name of the class to be searched.
		@return Function Constructor for the class.
	*/	
	public static function findClass(fullClassName : String) : Function
	{
		if (fullClassName == null) return null;
		var result = _global;
		var tokens = fullClassName.split(".");
		for (var i = 0; i < tokens.length; i++)
		{
			result = result[tokens[i]];
		}
		if (result == null)
		{
			_global.__dataLogger.logData(null, "Could not find class '<classname>'", 
				{classname: fullClassName}, mx.data.binding.Log.BRIEF);
		}

		return result;
	}

} // mx.utils.ClassFinder
