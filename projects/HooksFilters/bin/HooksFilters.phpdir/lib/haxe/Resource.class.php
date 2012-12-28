<?php

class haxe_Resource {
	public function __construct(){}
	static function cleanName($name) {
		$GLOBALS['%s']->push("haxe.Resource::cleanName");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = _hx_deref(new EReg("[\\\\/:?\"*<>|]", ""))->replace($name, "_");
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getDir() {
		$GLOBALS['%s']->push("haxe.Resource::getDir");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = dirname(__FILE__) . "/../../res";
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getPath($name) {
		$GLOBALS['%s']->push("haxe.Resource::getPath");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = haxe_Resource::getDir() . "/" . haxe_Resource::cleanName($name);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function listNames() {
		$GLOBALS['%s']->push("haxe.Resource::listNames");
		$�spos = $GLOBALS['%s']->length;
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
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = php_io_File::getContent(haxe_Resource::getPath($name));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getBytes($name) {
		$GLOBALS['%s']->push("haxe.Resource::getBytes");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = php_io_File::getBytes(haxe_Resource::getPath($name));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haxe.Resource'; }
}
