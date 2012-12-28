package tests;

import utest.Assert;
import org.silex.filters.FilterChain;

class FiltersApplication
{
	public function new()
	{
		
	}
	
	public function testApplicationOneFilter()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 1);
		var result = firstChain.applyFilters(3, {});
		Assert.equals(4, result);
	}
	
	public function testApplicationTwoFilters()
	{
		var firstChain = new FilterChain();
		firstChain.addFilter(addOne, 0);
		firstChain.addFilter(addTwo, 1);
		var result = firstChain.applyFilters(6, {});
		Assert.equals(9, result);
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