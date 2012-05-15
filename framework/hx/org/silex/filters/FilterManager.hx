package org.silex.filters;

class FilterManager
{
	/**
	*  Holds filterChains. The key is the Chain's ID.
	*/
	private static var filterChains : Hash<FilterChain>;
	
	/**
	*  Initializes the filterChains variable.
	*/
	private static function __init__()
	{
		filterChains = new Hash<FilterChain>();
	}
	
	/**
	*  Filters the given value and returns it modified.
	*  If the ChainFilter doesn't exist, returns the unmodified value.
	*/
	public static function applyFilters(value : Dynamic, context : Dynamic, chainID : String) : Dynamic
	{
		if(filterChains.exists(chainID))
		{
			return filterChains.get(chainID).applyFilters(value, context);
		} else
		{
			return value;
		}
	}
	
	/**
	*  Adds a filter to the FilterChain.
	*  If the FilterChain doesn't already exist, creates it.
	*/
	public static function addFilter(chainID : String, filter : Filter, priority : Int) : Void
	{
		//If FilterChain doesn't exist, creates it.
		if(!filterChains.exists(chainID))
		{
			filterChains.set(chainID, new FilterChain());
		}
		
		filterChains.get(chainID).addFilter(filter, priority);
	}
	
	/**
	*  Removes a filter from the FilterChain.
	*  Should take care of closures (use Reflect.compareMethods).
	*/
	public static function removeFilter(chainID : String, filter : Filter) : Void
	{
		if(filterChains.exists(chainID))
		{
			filterChains.get(chainID).removeFilter(filter);
		}
	}
}