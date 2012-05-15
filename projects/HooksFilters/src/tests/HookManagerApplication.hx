package tests;

import utest.Assert;
import org.silex.hooks.HookChain;

using org.silex.hooks.HookManager;

class HookManagerApplication
{
	public function new()
	{
		
	}
	
	public function testApplicationOneHook()
	{
		"firstChain".addHook(hookTest, 0);
		Assert.raises(function() {
			"firstChain".callHooks("An exception");
		}, String);
	}

	public function testApplicationTwoHooks()
	{
		"secondChain".addHook(hookTest, 0);
		"secondChain".addHook(hookTest, 0);
		Assert.raises(function() {
			"secondChain".callHooks(12);
		}, Int);
	}
	
	public function testAddingTwoHooks()
	{
		var _hookTest = hookTest;
		var _hookTest2 = hookTest2;
		"testAddingTwoHooksChain".addHook(_hookTest, 0);
		"testAddingTwoHooksChain".addHook(_hookTest2, 0);
		Assert.equals(2, untyped org.silex.hooks.HookManager.hookChains.get("testAddingTwoHooksChain").hooks.length);
	}
	
	public function testRemovingHook()
	{
		var _hookTest = hookTest;
		var _hookTest2 = hookTest2;
		"testRemovingHookChain".addHook(_hookTest, 0);
		"testRemovingHookChain".addHook(_hookTest2, 0);
		"testRemovingHookChain".removeHook(_hookTest);
		Assert.equals(1, untyped org.silex.hooks.HookManager.hookChains.get("testRemovingHookChain").hooks.length);
	}
	
	public function testRemovingHookViaClosure()
	{
		var _hookTest = hookTest;
		var _hookTest2 = hookTest2;
		"testRemovingHookViaClosureChain".addHook(_hookTest, 0);
		"testRemovingHookViaClosureChain".addHook(_hookTest2, 0);
		"testRemovingHookViaClosureChain".removeHook(hookTest);
		
		Assert.equals(1, untyped org.silex.hooks.HookManager.hookChains.get("testRemovingHookViaClosureChain").hooks.length);
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