<?php

class org_silex_serverApi_RootDir {
	public function __construct(){}
	static $rootPath;
	static $rootUrl;
	static function getRootPath() {
		global $ROOTPATH;
		return $ROOTPATH;
		;
	}
	static function getRootUrl() {
		$goodUri = "";
		$tmp = _hx_explode("/", php_Web::getURI());
		$tmp->pop();
		$goodUri = $tmp->join("/");
		return (((("http://" . $_SERVER["SERVER_NAME"]) . ":") . $_SERVER["SERVER_PORT"]) . $goodUri) . "/";
		unset($tmp,$goodUri);
	}
	function __toString() { return 'org.silex.serverApi.RootDir'; }
}
{
	require_once("rootdir.php");
	global $ROOTURL;
	global $ROOTPATH;
	;
}
