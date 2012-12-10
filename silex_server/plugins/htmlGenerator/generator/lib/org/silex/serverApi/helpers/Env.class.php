<?php

class org_silex_serverApi_helpers_Env {
	public function __construct(){}
	static $pathSeparator;
	static function getIncludePath() {
		return get_include_path();
	}
	static function setIncludePath($newIncludePath) {
		set_include_path($newIncludePath);
	}
	static function getPathSeparator() {
		return PATH_SEPARATOR;
	}
	function __toString() { return 'org.silex.serverApi.helpers.Env'; }
}
