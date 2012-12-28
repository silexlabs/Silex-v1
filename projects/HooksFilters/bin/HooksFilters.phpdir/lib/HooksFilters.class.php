<?php

class HooksFilters {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("HooksFilters::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	static function main() {
		$GLOBALS['%s']->push("HooksFilters::main");
		$製pos = $GLOBALS['%s']->length;
		$m = new HooksFilters();
		$runner = new utest_Runner();
		$runner->addCase(new tests_FiltersOrder(), null, null, null, null);
		$runner->addCase(new tests_FiltersApplication(), null, null, null, null);
		$runner->addCase(new tests_FiltersAddingDeleting(), null, null, null, null);
		$runner->addCase(new tests_HooksApplication(), null, null, null, null);
		$runner->addCase(new tests_HookManagerApplication(), null, null, null, null);
		$report = utest_ui_Report::create($runner, null, null);
		$runner->run();
		$GLOBALS['%s']->pop();
	}
	static function plusOne($value, $context) {
		$GLOBALS['%s']->push("HooksFilters::plusOne");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value + 1;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function double($value, $context) {
		$GLOBALS['%s']->push("HooksFilters::double");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $value * 2;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'HooksFilters'; }
}
