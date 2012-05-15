//****************************************************************************
//Copyright (C) 2003-2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
The Delegate class creates a function wrapper to let you run a function in the context
of the original object, rather than in the context of the second object, when you pass a
function from one object to another.
*/

class mx.utils.Delegate extends Object
{
	/**
	Creates a functions wrapper for the original function so that it runs 
	in the provided context.
	@parameter obj Context in which to run the function.
	@paramater func Function to run.
	*/
	static function create(obj:Object, func:Function):Function
	{
		var f = function()
		{
			var target = arguments.callee.target;
			var func2 = arguments.callee.func;

			return func2.apply(target, arguments);
		};

		f.target = obj;
		f.func = func;

		return f;
	}

	function Delegate(f:Function)
	{
		func = f;
	}

	private var func:Function;

	function createDelegate(obj:Object):Function
	{
		return create(obj, func);
	}
}
