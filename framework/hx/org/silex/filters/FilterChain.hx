package org.silex.filters;

/**
*  A FilterChain is a set of functions used to filter a value. It is known by its string-based ID.
*/
class FilterChain
{
	/**
	*  Holds filters ordered in the order they have to be called.
	*/
	private var filters : Array<FilterRecord>;
	
	/**
	*  Filters the given value and returns it modified. If there's no filter in FilterChain, returns the unmodified value.  
    *  Note that every filter will be called with the LAST version of the value.
    *  So it will never get the original one if it has already been modified.
    */
	public function applyFilters(value : Dynamic, context : Dynamic) : Dynamic
	{
		for(filterRecord in filters)
		{
			value = filterRecord.filter(value, context);
		}
		
		return value;
	}
	
	/**
	*  Adds a filter to the FilterChain.
	*/
	public function addFilter(filter : Filter, priority : Int) : Void
	{
		//Iterate over array to find a filter with priority >= priority
		for(i in 0...filters.length)
		{
			if(filters[i].priority >= priority)
			{
				//Found it so insert our filter BEFORE.
				filters.insert(i, {priority: priority, filter: filter});
				return;
			}
		}
		//We did not find any filter with priority >= priority so insert it at end.
		filters.push({priority: priority, filter: filter});
	}
	
	/**
	*  Removes a filter from the FilterChain.
	*  Should take care of closures (use Reflect.compareMethods).
	*/
	public function removeFilter(filter : Filter) : Void
	{
		for(filterRecord in filters)
		{
			if(filterRecord.filter == filter || Reflect.compareMethods(filterRecord.filter, filter))
			{
				filters.remove(filterRecord);
			}
		}
	}
	
	/**
	*  Constructor. Intializes filters.
	*/
	public function new()
	{
		filters = new Array<FilterRecord>();
	}
}

/**
*  Used in FilterChain to hold a Filter (filtering function) and its priority.
*/
typedef FilterRecord = {priority: Int , filter: Filter};