<?php

class org_silex_serverApi_RootDir {
	public function __construct(){}
	static $rootPath;
	static $rootUrl;
	static function getRootPath() {
		$GLOBALS['%s']->push("org.silex.serverApi.RootDir::getRootPath");
		$»spos = $GLOBALS['%s']->length;
		global $ROOTPATH;
		$ROOTPATH = ROOTPATH;
		{
			$»tmp = $ROOTPATH;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getRootUrl() {
		$GLOBALS['%s']->push("org.silex.serverApi.RootDir::getRootUrl");
		$»spos = $GLOBALS['%s']->length;
		$goodUri = "";
		$tmp = _hx_explode("/", php_Web::getURI());
		$tmp->pop();
		$goodUri = $tmp->join("/");
		$portString = null;
		$portString = "";
		if(Std::string($_SERVER["SERVER_PORT"]) !== "80") {
			$portString = ":" . Std::string($_SERVER["SERVER_PORT"]);
		}
		{
			$»tmp = "http://" . $_SERVER["SERVER_NAME"] . $portString . $goodUri . "/";
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'org.silex.serverApi.RootDir'; }
}
{
	require_once("rootdir.php");
	global $ROOTURL;
	global $ROOTPATH;
}
