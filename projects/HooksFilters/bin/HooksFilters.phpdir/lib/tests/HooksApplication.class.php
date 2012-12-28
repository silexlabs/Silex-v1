<?php

class tests_HooksApplication {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("tests.HooksApplication::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testApplicationOneHook() {
		$GLOBALS['%s']->push("tests.HooksApplication::testApplicationOneHook");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_hooks_HookChain();
		$firstChain->addHook((isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		utest_Assert::raises(array(new _hx_lambda(array(&$firstChain), "tests_HooksApplication_0"), 'execute'), _hx_qtype("String"), null, null, _hx_anonymous(array("fileName" => "HooksApplication.hx", "lineNumber" => 17, "className" => "tests.HooksApplication", "methodName" => "testApplicationOneHook")));
		$GLOBALS['%s']->pop();
	}
	public function testApplicationTwoHooks() {
		$GLOBALS['%s']->push("tests.HooksApplication::testApplicationTwoHooks");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_hooks_HookChain();
		$firstChain->addHook((isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		$firstChain->addHook((isset($this->hookTest) ? $this->hookTest: array($this, "hookTest")), 0);
		utest_Assert::raises(array(new _hx_lambda(array(&$firstChain), "tests_HooksApplication_1"), 'execute'), _hx_qtype("Int"), null, null, _hx_anonymous(array("fileName" => "HooksApplication.hx", "lineNumber" => 27, "className" => "tests.HooksApplication", "methodName" => "testApplicationTwoHooks")));
		$GLOBALS['%s']->pop();
	}
	public function testAddingTwoHooks() {
		$GLOBALS['%s']->push("tests.HooksApplication::testAddingTwoHooks");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_hooks_HookChain();
		$_hookTest = (isset($this->hookTest) ? $this->hookTest: array($this, "hookTest"));
		$_hookTest2 = (isset($this->hookTest2) ? $this->hookTest2: array($this, "hookTest2"));
		$firstChain->addHook($_hookTest, 0);
		$firstChain->addHook($_hookTest2, 0);
		utest_Assert::equals(2, _hx_len($firstChain->hooks), null, _hx_anonymous(array("fileName" => "HooksApplication.hx", "lineNumber" => 39, "className" => "tests.HooksApplication", "methodName" => "testAddingTwoHooks")));
		$GLOBALS['%s']->pop();
	}
	public function hookTest($value) {
		$GLOBALS['%s']->push("tests.HooksApplication::hookTest");
		$製pos = $GLOBALS['%s']->length;
		throw new HException($value);
		$GLOBALS['%s']->pop();
	}
	public function hookTest2($value) {
		$GLOBALS['%s']->push("tests.HooksApplication::hookTest2");
		$製pos = $GLOBALS['%s']->length;
		throw new HException($value);
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'tests.HooksApplication'; }
}
function tests_HooksApplication_0(&$firstChain) {
		$GLOBALS['%s']->push('tests.HooksApplication:lambda_0');
		$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("tests.HooksApplication::testApplicationOneHook@17");
		$製pos2 = $GLOBALS['%s']->length;
		$firstChain->callHooks("An exception");
		$GLOBALS['%s']->pop();
	}
}
function tests_HooksApplication_1(&$firstChain) {
		$GLOBALS['%s']->push('tests.HooksApplication:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("tests.HooksApplication::testApplicationTwoHooks@27");
		$製pos2 = $GLOBALS['%s']->length;
		$firstChain->callHooks(12);
		$GLOBALS['%s']->pop();
	}
}
