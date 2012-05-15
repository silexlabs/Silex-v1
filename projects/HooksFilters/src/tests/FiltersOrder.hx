package tests;

import utest.Assert;
import org.silex.filters.FilterChain;

class FiltersOrder
{
	public function new()
	{
		
	}
	
	public function testOrderInvert()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 1);
		firstChain.addFilter(double, 0);
		var result = firstChain.applyFilters(12, {});
		Assert.equals(25, result);
	}
	
	public function testOrder()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 0);
		firstChain.addFilter(double, 1);
		var result = firstChain.applyFilters(12, {});
		Assert.equals(26, result);
	}
	
	private function addOne(value : Int, context : {})
	{
		return value + 1;
	}
	
	private function double(value : Int, context : {})
	{
		return value*2;
	}
}