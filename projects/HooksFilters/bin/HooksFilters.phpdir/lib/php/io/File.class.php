<?php

class php_io_File {
	public function __construct(){}
	static function getContent($path) {
		$GLOBALS['%s']->push("php.io.File::getContent");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = file_get_contents($path);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getBytes($path) {
		$GLOBALS['%s']->push("php.io.File::getBytes");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = haxe_io_Bytes::ofString(php_io_File::getContent($path));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function putContent($path, $content) {
		$GLOBALS['%s']->push("php.io.File::putContent");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = file_put_contents($path, $content);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function read($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::read");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileInput(fopen($path, php_io_File_0($binary, $path)));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function write($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::write");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileOutput(fopen($path, php_io_File_1($binary, $path)));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function append($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::append");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileOutput(fopen($path, php_io_File_2($binary, $path)));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function copy($src, $dst) {
		$GLOBALS['%s']->push("php.io.File::copy");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = copy($src, $dst);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stdin() {
		$GLOBALS['%s']->push("php.io.File::stdin");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileInput(fopen("php://stdin", "r"));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stdout() {
		$GLOBALS['%s']->push("php.io.File::stdout");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileOutput(fopen("php://stdout", "w"));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stderr() {
		$GLOBALS['%s']->push("php.io.File::stderr");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = new php_io_FileOutput(fopen("php://stderr", "w"));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getChar($echo) {
		$GLOBALS['%s']->push("php.io.File::getChar");
		$�spos = $GLOBALS['%s']->length;
		$v = fgetc(STDIN);
		if($echo) {
			echo($v);
		}
		{
			$GLOBALS['%s']->pop();
			return $v;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'php.io.File'; }
}
function php_io_File_0(&$binary, &$path) {
		$GLOBALS['%s']->push('php.io.File:lambda_0');
		$�spos = $GLOBALS['%s']->length;
	if($binary) {
		return "rb";
	} else {
		return "r";
	}
}
function php_io_File_1(&$binary, &$path) {
		$GLOBALS['%s']->push('php.io.File:lambda_1');
		$�spos = $GLOBALS['%s']->length;
	if($binary) {
		return "wb";
	} else {
		return "w";
	}
}
function php_io_File_2(&$binary, &$path) {
		$GLOBALS['%s']->push('php.io.File:lambda_2');
		$�spos = $GLOBALS['%s']->length;
	if($binary) {
		return "ab";
	} else {
		return "a";
	}
}
