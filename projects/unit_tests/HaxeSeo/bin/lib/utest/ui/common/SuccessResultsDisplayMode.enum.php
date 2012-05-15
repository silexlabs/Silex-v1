<?php

class utest_ui_common_SuccessResultsDisplayMode extends Enum {
	public static $AlwaysShowSuccessResults;
	public static $NeverShowSuccessResults;
	public static $ShowSuccessResultsWithNoErrors;
	public static $__constructors = array(0 => 'AlwaysShowSuccessResults', 1 => 'NeverShowSuccessResults', 2 => 'ShowSuccessResultsWithNoErrors');
	}
utest_ui_common_SuccessResultsDisplayMode::$AlwaysShowSuccessResults = new utest_ui_common_SuccessResultsDisplayMode("AlwaysShowSuccessResults", 0);
utest_ui_common_SuccessResultsDisplayMode::$NeverShowSuccessResults = new utest_ui_common_SuccessResultsDisplayMode("NeverShowSuccessResults", 1);
utest_ui_common_SuccessResultsDisplayMode::$ShowSuccessResultsWithNoErrors = new utest_ui_common_SuccessResultsDisplayMode("ShowSuccessResultsWithNoErrors", 2);
