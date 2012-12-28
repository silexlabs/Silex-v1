package org.silex.hooks;

/**
*  A HookChain is a set of functions to be called. It is known by its string-based ID.
*/
class HookChain
{
	/**
	*  Holds hooks ordered in the order they have to be called.
	*/
	private var hooks : Array<HookRecord>;
	
	/**
	*  Executes the chain of functions passing them the parameter.
    */
	public function callHooks(value : Dynamic) :Void
	{
		for(hookRecord in hooks)
		{
			hookRecord.hook(value);
		}
	}
	
	/**
	*  Adds a hook to the HookChain.
	*/
	public function addHook(hook : Hook, priority : Int) : Void
	{
		//Iterate over array to find a hook with priority >= priority
		for(i in 0...hooks.length)
		{
			if(hooks[i].priority >= priority)
			{
				//Found it so insert our filter BEFORE.
				hooks.insert(i, {priority: priority, hook: hook});
				return;
			}
		}
		//We did not find any hook with priority >= priority so insert it at end.
		hooks.push({priority: priority, hook: hook});
	}
	
	/**
	*  Removes a hook from the HookChain.
	*  Should take care of closures (use Reflect.compareMethods).
	*/
	public function removeHook(hook : Hook) : Void
	{
		for(hookRecord in hooks)
		{
			if(hookRecord.hook == hook || Reflect.compareMethods(hookRecord.hook, hook))
			{
				hooks.remove(hookRecord);
			}
		}
	}
	
	/**
	*  Constructor. Intializes hooks array.
	*/
	public function new()
	{
		hooks = new Array<HookRecord>();
	}
}

/**
*  Used in HookChain to hold a Hook (function to be called) and its priority.
*/
typedef HookRecord = {priority: Int , hook: Hook};