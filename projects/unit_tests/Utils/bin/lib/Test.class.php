<?php

class Test {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("Test::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function test_htmlEntitiesEncode_1() {
		$GLOBALS['%s']->push("Test::test_htmlEntitiesEncode_1");
		$製pos = $GLOBALS['%s']->length;
		$strIn = "<<>>&&\"\"";
		$strOut = StringTools::htmlEscape($strIn);
		utest_Assert::equals("&lt;&lt;&gt;&gt;&amp;&amp;\"\"", $strOut, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 65, "className" => "Test", "methodName" => "test_htmlEntitiesEncode_1")));
		$GLOBALS['%s']->pop();
	}
	public function test_htmlEntitiesDecode_1() {
		$GLOBALS['%s']->push("Test::test_htmlEntitiesDecode_1");
		$製pos = $GLOBALS['%s']->length;
		$strIn = "&lt;&lt;&gt;&gt;&amp;&amp;&quot;&quot;";
		$strOut = $strIn;
		$strOut1 = htmlspecialchars_decode($strIn);
		utest_Assert::equals("<<>>&&\"\"", $strOut1, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 82, "className" => "Test", "methodName" => "test_htmlEntitiesDecode_1")));
		$GLOBALS['%s']->pop();
	}
	static $seoFileExtension = ".seodata.xml";
	static $testFilePath = "../test_files/";
	static function main() {
		$GLOBALS['%s']->push("Test::main");
		$製pos = $GLOBALS['%s']->length;
		Test::init();
		Test::test();
		$GLOBALS['%s']->pop();
	}
	static function init() {
		$GLOBALS['%s']->push("Test::init");
		$製pos = $GLOBALS['%s']->length;
		require_once("../../../../silex_server/rootdir.php");
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library");
		$GLOBALS['%s']->pop();
	}
	static function test() {
		$GLOBALS['%s']->push("Test::test");
		$製pos = $GLOBALS['%s']->length;
		$runner = new utest_Runner();
		$runner->addCase(new Test(), null, null, null, null);
		utest_ui_Report::create($runner, null, null);
		$runner->run();
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Test'; }
}
