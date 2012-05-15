import org.silex.filters.FilterChain;
import org.silex.filters.FilterManager;
import org.silex.hooks.HookChain;
import org.silex.hooks.HookManager;

//Imports for test
import tests.FiltersOrder;
import tests.FiltersApplication;
import tests.FiltersAddingDeleting;
import tests.HooksApplication;
import tests.HookManagerApplication;
import utest.Runner;
import utest.ui.Report;

import haxe.Resource;

using org.silex.filters.FilterManager;

class HooksFilters
{

	public function new()
	{
		
	}

	public static function main(): Void
	{
		var m: HooksFilters = new HooksFilters();
		var runner = new Runner();
		runner.addCase(new FiltersOrder());
		runner.addCase(new FiltersApplication());
		runner.addCase(new FiltersAddingDeleting());
		runner.addCase(new HooksApplication());
		runner.addCase(new HookManagerApplication());
		var report = Report.create(runner);
		runner.run();
	}
	
	private static function plusOne(value : Int, context : {})
	{
		return value + 1;
	}
	
	private static function double(value : Int, context : {})
	{
		return value*2;
	}
}