package tests;

import utest.Assert;
import org.silex.hooks.HookChain;

class HooksApplication
{
	public function new()
	{
		
	}
	
	public function testApplicationOneHook()
	{
		var firstChain = new HookChain();
		firstChain.addHook(hookTest, 0);
		Assert.raises(function() {
			firstChain.callHooks("An exception");
		}, String);
	}

	public function testApplicationTwoHooks()
	{
		var firstChain = new HookChain();
		firstChain.addHook(hookTest, 0);
		firstChain.addHook(hookTest, 0);
		Assert.raises(function() {
			firstChain.callHooks(12);
		}, Int);
	}
	
	public function testAddingTwoHooks()
	{
		var firstChain = new HookChain();
		var _hookTest = hookTest;
		var _hookTest2 = hookTest2;
		firstChain.addHook(_hookTest, 0);
		firstChain.addHook(_hookTest2, 0);
		Assert.equals(2, untyped firstChain.hooks.length);
	}
	
	private function hookTest(value : Dynamic)
	{
		throw value;
	}
	
	private function hookTest2(value : Dynamic)
	{
		throw value;
	}
}