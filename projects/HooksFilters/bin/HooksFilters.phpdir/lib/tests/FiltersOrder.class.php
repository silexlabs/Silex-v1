<?php

class tests_FiltersOrder {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("tests.FiltersOrder::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testOrderInvert() {
		$GLOBALS['%s']->push("tests.FiltersOrder::testOrderInvert");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 1);
		$firstChain->addFilter((isset($this->double) ? $this->double: array($this, "double")), 0);
		$result = $firstChain->applyFilters(12, _hx_anonymous(array()));
		utest_Assert::equals(25, $result, null, _hx_anonymous(array("fileName" => "FiltersOrder.hx", "lineNumber" => 19, "className" => "tests.FiltersOrder", "methodName" => "testOrderInvert")));
		$GLOBALS['%s']->pop();
	}
	public function testOrder() {
		$GLOBALS['%s']->push("tests.FiltersOrder::testOrder");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 0);
		$firstChain->addFilter((isset($this->double) ? $this->double: array($this, "double")), 1);
		$result = $firstChain->applyFilters(12, _hx_anonymous(array()));
		utest_Assert::equals(26, $result, null, _hx_anonymous(array("fileName" => "FiltersOrder.hx", "lineNumber" => 28, "className" => "tests.FiltersOrder", "methodName" => "testOrder")));
		$GLOBALS['%s']->pop();
	}
	public function addOne($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersOrder::addOne");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value + 1;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function double($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersOrder::double");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value * 2;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'tests.FiltersOrder'; }
}
