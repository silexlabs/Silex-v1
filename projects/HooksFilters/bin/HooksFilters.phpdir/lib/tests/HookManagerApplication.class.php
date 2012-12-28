<?php

class tests_HookManagerApplication {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("tests.HookManagerApplication::new");
		$�spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testApplicationOneHook() {
		$GLOBALS['%s']->push("tests.HookManagerApplication::testApplicationOneHook");
		$�spos = $GLOBALS['%s']->length;
		org_silex_hooks_HookManager::addHook("firstChain", (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		utest_Assert::raises(array(new _hx_lambda(array(), "tests_HookManagerApplication_0"), 'execute'), _hx_qtype("String"), null, null, _hx_anonymous(array("fileName" => "HookManagerApplication.hx", "lineNumber" => 18, "className" => "tests.HookManagerApplication", "methodName" => "testApplicationOneHook")));
		$GLOBALS['%s']->pop();
	}
	public function testApplicationTwoHooks() {
		$GLOBALS['%s']->push("tests.HookManagerApplication::testApplicationTwoHooks");
		$�spos = $GLOBALS['%s']->length;
		org_silex_hooks_HookManager::addHook("secondChain", (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		org_silex_hooks_HookManager::addHook("secondChain", (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		utest_Assert::raises(array(new _hx_lambda(array(), "tests_HookManagerApplication_1"), 'execute'), _hx_qtype("Int"), null, null, _hx_anonymous(array("fileName" => "HookManagerApplication.hx", "lineNumber" => 27, "className" => "tests.HookManagerApplication", "methodName" => "testApplicationTwoHooks")));
		$GLOBALS['%s']->pop();
	}
	public function testAddingTwoHooks() {
		$GLOBALS['%s']->push("tests.HookManagerApplication::testAddingTwoHooks");
		$�spos = $GLOBALS['%s']->length;
		$_hookTest = (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest"));
		$_hookTest2 = (isset($this->hookTest2) ? $this->hookTest2: array($this, "hookTest2"));
		org_silex_hooks_HookManager::addHook("testAddingTwoHooksChain", $_hookTest, 0);
		org_silex_hooks_HookManager::addHook("testAddingTwoHooksChain", $_hookTest2, 0);
		utest_Assert::equals(2, _hx_len(org_silex_hooks_HookManager::$hookChains->get("testAddingTwoHooksChain")->hooks), null, _hx_anonymous(array("fileName" => "HookManagerApplication.hx", "lineNumber" => 38, "className" => "tests.HookManagerApplication", "methodName" => "testAddingTwoHooks")));
		$GLOBALS['%s']->pop();
	}
	public function testRemovingHook() {
		$GLOBALS['%s']->push("tests.HookManagerApplication::testRemovingHook");
		$�spos = $GLOBALS['%s']->length;
		$_hookTest = (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest"));
		$_hookTest2 = (isset($this->hookTest2) ? $this->hookTest2: array($this, "hookTest2"));
		org_silex_hooks_HookManager::addHook("testRemovingHookChain", $_hookTest, 0);
		org_silex_hooks_HookManager::addHook("testRemovingHookChain", $_hookTest2, 0);
		org_silex_hooks_HookManager::removeHook("testRemovingHookChain", $_hookTest);
		utest_Assert::equals(1, _hx_len(org_silex_hooks_HookManager::$hookChains->get("testRemovingHookChain")->hooks), null, _hx_anonymous(array("fileName" => "HookManagerApplication.hx", "lineNumber" => 48, "className" => "tests.HookManagerApplication", "methodName" => "testRemovingHook")));
		$GLOBALS['%s']->pop();
	}
	public function testRemovingHookViaClosure() {
		$GLOBALS['%s']->push("tests.HookManagerApplication::testRemovingHookViaClosure");
		$�spos = $GLOBALS['%s']->length;
		$_hookTest = (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest"));
		$_hookTest2 = (isset($this->hookTest2) ? $this->hookTest2: array($this, "hookTest2"));
		org_silex_hooks_HookManager::addHook("testRemovingHookViaClosureChain", $_hookTest, 0);
		org_silex_hooks_HookManager::addHook("testRemovingHookViaClosureChain", $_hookTest2, 0);
		org_silex_hooks_HookManager::removeHook("testRemovingHookViaClosureChain", (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")));
		utest_Assert::equals(1, _hx_len(org_silex_hooks_HookManager::$hookChains->get("testRemovingHookViaClosureChain")->hooks), null, _hx_anonymous(array("fileName" => "HookManagerApplication.hx", "lineNumber" => 59, "className" => "tests.HookManagerApplication", "methodName" => "testRemovingHookViaClosure")));
		$GLOBALS['%s']->pop();
	}
	public function hookTest($value) {
		$GLOBALS['%s']->push("tests.HookManagerApplication::hookTest");
		$�spos = $GLOBALS['%s']->length;
		throw new HException($value);
		$GLOBALS['%s']->pop();
	}
	public function hookTest2($value) {
		$GLOBALS['%s']->push("tests.HookManagerApplication::hookTest2");
		$�spos = $GLOBALS['%s']->length;
		throw new HException($value);
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'tests.HookManagerApplication'; }
}
function tests_HookManagerApplication_0() {
		$GLOBALS['%s']->push('tests.HookManagerApplication:lambda_0');
		$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("tests.HookManagerApplication::testApplicationOneHook@18");
		$�spos2 = $GLOBALS['%s']->length;
		org_silex_hooks_HookManager::callHooks("firstChain", "An exception");
		$GLOBALS['%s']->pop();
	}
}
function tests_HookManagerApplication_1() {
		$GLOBALS['%s']->push('tests.HookManagerApplication:lambda_1');
		$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("tests.HookManagerApplication::testApplicationTwoHooks@27");
		$�spos2 = $GLOBALS['%s']->length;
		org_silex_hooks_HookManager::callHooks("secondChain", 12);
		$GLOBALS['%s']->pop();
	}
}
