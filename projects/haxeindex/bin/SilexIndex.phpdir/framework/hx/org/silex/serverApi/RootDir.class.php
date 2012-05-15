<?php

class org_silex_serverApi_RootDir {
	public function __construct(){}
	static $rootPath;
	static $rootUrl;
	static function getRootPath() {
		global $ROOTPATH;
		$ROOTPATH = ROOTPATH;
		return $ROOTPATH;
	}
	static function getRootUrl() {
		$goodUri = "";
		$tmp = _hx_explode("/", php_Web::getURI());
		$tmp->pop();
		$goodUri = $tmp->join("/");
		$portString = null;
		$portString = "";
		if(Std::string($_SERVER["SERVER_PORT"]) !== "80") {
			$portString = ":" . Std::string($_SERVER["SERVER_PORT"]);
		}
		return "http://" . $_SERVER["SERVER_NAME"] . $portString . $goodUri . "/";
	}
	function __toString() { return 'org.silex.serverApi.RootDir'; }
}
{
	require_once("rootdir.php");
	global $ROOTURL;
	global $ROOTPATH;
}
