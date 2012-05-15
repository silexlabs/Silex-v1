<?php

class tests_FiltersApplication {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("tests.FiltersApplication::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testApplicationOneFilter() {
		$GLOBALS['%s']->push("tests.FiltersApplication::testApplicationOneFilter");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 1);
		$result = $firstChain->applyFilters(3, _hx_anonymous(array()));
		utest_Assert::equals(4, $result, null, _hx_anonymous(array("fileName" => "FiltersApplication.hx", "lineNumber" => 18, "className" => "tests.FiltersApplication", "methodName" => "testApplicationOneFilter")));
		$GLOBALS['%s']->pop();
	}
	public function testApplicationTwoFilters() {
		$GLOBALS['%s']->push("tests.FiltersApplication::testApplicationTwoFilters");
		$製pos = $GLOBALS['%s']->length;
		$firstChain = new org_silex_filters_FilterChain();
		$firstChain->addFilter((isset($this->addOne) ? $this->addOne: array($this, "addOne")), 0);
		$firstChain->addFilter((isset($this->addTwo) ? $this->addTwo: array($this, "addTwo")), 1);
		$result = $firstChain->applyFilters(6, _hx_anonymous(array()));
		utest_Assert::equals(9, $result, null, _hx_anonymous(array("fileName" => "FiltersApplication.hx", "lineNumber" => 27, "className" => "tests.FiltersApplication", "methodName" => "testApplicationTwoFilters")));
		$GLOBALS['%s']->pop();
	}
	public function addOne($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersApplication::addOne");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value + 1;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function addTwo($value, $context) {
		$GLOBALS['%s']->push("tests.FiltersApplication::addTwo");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value + 2;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'tests.FiltersApplication'; }
}
