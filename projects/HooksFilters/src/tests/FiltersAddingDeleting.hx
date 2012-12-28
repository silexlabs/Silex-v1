package tests;

import utest.Assert;
import org.silex.filters.FilterChain;

class FiltersAddingDeleting
{
	static var fieldFunction = function(value : Int, context : Dynamic) { return value; };
	public function new()
	{
		
	}
	
	public function testAddingClosure()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 2);
		Assert.equals(1, untyped firstChain.filters.length);
	}
	
	public function testAddingFieldFunction()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(fieldFunction, 0);
		var result = firstChain.applyFilters(6, {});
		Assert.equals(1, untyped firstChain.filters.length);
	}
	
	public function testRemovingClosure()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 2);
		firstChain.removeFilter(addOne);
		Assert.equals(0, untyped firstChain.filters.length);
	}
	
	public function testRemovingFieldFunction()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(fieldFunction, 2);
		firstChain.removeFilter(fieldFunction);
		Assert.equals(0, untyped firstChain.filters.length);
	}
	
	private function addOne(value : Int, context : {})
	{
		return value + 1;
	}
	
	private function addTwo(value : Int, context : {})
	{
		return value + 2;
	}
}