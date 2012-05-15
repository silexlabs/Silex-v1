<?php

class tests_FiltersAddingDeleting {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::new");
		$�spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testAddingClosure() {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::testAddingClosure");
		$�spos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 2);
		utest_Assert::equals(1, _hx_len($firstChain->filters), null, _hx_anonymous(array("fileName" => "FiltersAddingDeleting.hx", "lineNumber" => 18, "className" => "tests.FiltersAddingDeleting", "methodName" => "testAddingClosure")));
		$GLOBALS['%s']->pop();
	}
	public function testAddingFieldFunction() {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::testAddingFieldFunction");
		$�spos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter(tests_FiltersAddingDeleting::$fieldFunction, 0);
		$result = $firstChain->applyFilters(6, _hx_anonymous(array()));
		utest_Assert::equals(1, _hx_len($firstChain->filters), null, _hx_anonymous(array("fileName" => "FiltersAddingDeleting.hx", "lineNumber" => 26, "className" => "tests.FiltersAddingDeleting", "methodName" => "testAddingFieldFunction")));
		$GLOBALS['%s']->pop();
	}
	public function testRemovingClosure() {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::testRemovingClosure");
		$�spos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 2);
		$firstChain->removeFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")));
		utest_Assert::equals(0, _hx_len($firstChain->filters), null, _hx_anonymous(array("fileName" => "FiltersAddingDeleting.hx", "lineNumber" => 34, "className" => "tests.FiltersAddingDeleting", "methodName" => "testRemovingClosure")));
		$GLOBALS['%s']->pop();
	}
	public function testRemovingFieldFunction() {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::testRemovingFieldFunction");
		$�spos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter(tests_FiltersAddingDeleting::$fieldFunction, 2);
		$firstChain->removeFilter(tests_FiltersAddingDeleting::$fieldFunction);
		utest_Assert::equals(0, _hx_len($firstChain->filters), null, _hx_anonymous(array("fileName" => "FiltersAddingDeleting.hx", "lineNumber" => 42, "className" => "tests.FiltersAddingDeleting", "methodName" => "testRemovingFieldFunction")));
		$GLOBALS['%s']->pop();
	}
	public function addOne($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::addOne");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $value + 1;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function addTwo($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::addTwo");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $value + 2;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function fieldFunction($value, $context) { return call_user_func_array(self::$fieldFunction, array($value, $context)); }
	public static $fieldFunction = null;
	function __toString() { return 'tests.FiltersAddingDeleting'; }
}
tests_FiltersAddingDeleting::$fieldFunction = array(new _hx_lambda(array(), "tests_FiltersAddingDeleting_0"), 'execute');
function tests_FiltersAddingDeleting_0($value, $context) {
		$GLOBALS['%s']->push('tests.FiltersAddingDeleting:lambda_0');
		$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("tests.FiltersAddingDeleting::fieldFunction@8");
		$�spos = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return $value;
		}
		$GLOBALS['%s']->pop();
	}
}
