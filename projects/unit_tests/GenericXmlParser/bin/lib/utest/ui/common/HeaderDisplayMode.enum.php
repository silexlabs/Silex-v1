<?php

class utest_ui_common_HeaderDisplayMode extends Enum {
	public static $AlwaysShowHeader;
	public static $NeverShowHeader;
	public static $ShowHeaderWithResults;
	public static $__constructors = array(0 => 'AlwaysShowHeader', 1 => 'NeverShowHeader', 2 => 'ShowHeaderWithResults');
	}
utest_ui_common_HeaderDisplayMode::$AlwaysShowHeader = new utest_ui_common_HeaderDisplayMode("AlwaysShowHeader", 0);
utest_ui_common_HeaderDisplayMode::$NeverShowHeader = new utest_ui_common_HeaderDisplayMode("NeverShowHeader", 1);
utest_ui_common_HeaderDisplayMode::$ShowHeaderWithResults = new utest_ui_common_HeaderDisplayMode("ShowHeaderWithResults", 2);
