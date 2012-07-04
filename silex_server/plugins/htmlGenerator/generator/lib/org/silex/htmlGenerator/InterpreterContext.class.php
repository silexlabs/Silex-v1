<?php

class org_silex_htmlGenerator_InterpreterContext {
	public function __construct(){}
	static $components;
	static $websiteConfig;
	function __toString() { return 'org.silex.htmlGenerator.InterpreterContext'; }
}
org_silex_htmlGenerator_InterpreterContext::$components = new Hash();
