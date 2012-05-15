package org.silex.hooks;

class HookManager
{
	/**
	*  Holds hooksChains. The key is the Chain's ID.
	*/
	private static var hookChains : Hash<HookChain>;
	
	/**
	*  Initializes the hookChains variable.
	*/
	private static function __init__()
	{
		hookChains = new Hash<HookChain>();
	}
	
	/**
	*  Executes the specified chain with the given parameter.
	*  If the HookChain doesn't exists, does nothing.
	*/
	public static function callHooks(chainID : String, value : Dynamic) : Void
	{
		if(hookChains.exists(chainID))
		{
			hookChains.get(chainID).callHooks(value);
		}
	}
	
	/**
	*  Adds a hook to the HookChain.
	*  If the HookChain doesn't already exist, creates it.
	*/
	public static function addHook(chainID : String, hook : Hook, priority : Int) : Void
	{
		//If HookChain doesn't exist, creates it.
		if(!hookChains.exists(chainID))
		{
			hookChains.set(chainID, new HookChain());
		}
		
		hookChains.get(chainID).addHook(hook, priority);
	}
	
	/**
	*  Removes a hook from the HookChain.
	*  Should take care of closures (use Reflect.compareMethods).
	*/
	public static function removeHook(chainID : String, filter : Hook) : Void
	{
		if(hookChains.exists(chainID))
		{
			hookChains.get(chainID).removeHook(filter);
		}
	}
}