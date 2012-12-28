<?php

class haxe_Resource {
	public function __construct(){}
	static function cleanName($name) {
		return _hx_deref(new EReg("[\\\\/:?\"*<>|]", ""))->replace($name, "_");
	}
	static function getDir() {
		return dirname(__FILE__) . "/../../res";
	}
	static function getPath($name) {
		return haxe_Resource::getDir() . "/" . haxe_Resource::cleanName($name);
	}
	static function listNames() {
		$a = php_FileSystem::readDirectory(haxe_Resource::getDir());
		if($a[0] === ".") {
			$a->shift();
		}
		if($a[0] === "..") {
			$a->shift();
		}
		return $a;
	}
	static function getString($name) {
		return php_io_File::getContent(haxe_Resource::getPath($name));
	}
	static function getBytes($name) {
		return php_io_File::getBytes(haxe_Resource::getPath($name));
	}
	function __toString() { return 'haxe.Resource'; }
}
