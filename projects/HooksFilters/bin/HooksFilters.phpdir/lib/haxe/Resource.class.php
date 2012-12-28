<?php

class haxe_Resource {
	public function __construct(){}
	static function cleanName($name) {
		$GLOBALS['%s']->push("haxe.Resource::cleanName");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_deref(new EReg("[\\\\/:?\"*<>|]", ""))->replace($name, "_");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getDir() {
		$GLOBALS['%s']->push("haxe.Resource::getDir");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = dirname(__FILE__) . "/../../res";
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getPath($name) {
		$GLOBALS['%s']->push("haxe.Resource::getPath");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = haxe_Resource::getDir() . "/" . haxe_Resource::cleanName($name);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function listNames() {
		$GLOBALS['%s']->push("haxe.Resource::listNames");
		$製pos = $GLOBALS['%s']->length;
		$a = php_FileSystem::readDirectory(haxe_Resource::getDir());
		if($a[0] === ".") {
			$a->shift();
		}
		if($a[0] === "..") {
			$a->shift();
		}
		{
			$GLOBALS['%s']->pop();
			return $a;
		}
		$GLOBALS['%s']->pop();
	}
	static function getString($name) {
		$GLOBALS['%s']->push("haxe.Resource::getString");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_io_File::getContent(haxe_Resource::getPath($name));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getBytes($name) {
		$GLOBALS['%s']->push("haxe.Resource::getBytes");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_io_File::getBytes(haxe_Resource::getPath($name));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haxe.Resource'; }
}
