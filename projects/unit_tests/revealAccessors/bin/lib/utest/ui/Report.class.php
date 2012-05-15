<?php

class utest_ui_Report {
	public function __construct(){}
	static function create($runner, $displaySuccessResults, $headerDisplayMode) {
		$GLOBALS['%s']->push("utest.ui.Report::create");
		$»spos = $GLOBALS['%s']->length;
		$report = null;
		if(!php_Web::$isModNeko) {
			$report = new utest_ui_text_PrintReport($runner, null);
		} else {
			$report = new utest_ui_text_HtmlReport($runner, null, true);
		}
		if(null === $displaySuccessResults) {
			$report->displaySuccessResults = utest_ui_common_SuccessResultsDisplayMode::$ShowSuccessResultsWithNoErrors;
		} else {
			$report->displaySuccessResults = $displaySuccessResults;
		}
		if(null === $headerDisplayMode) {
			$report->displayHeader = utest_ui_common_HeaderDisplayMode::$ShowHeaderWithResults;
		} else {
			$report->displayHeader = $headerDisplayMode;
		}
		{
			$GLOBALS['%s']->pop();
			return $report;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'utest.ui.Report'; }
}
