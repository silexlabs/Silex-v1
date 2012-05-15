<?php

class php_io_File {
	public function __construct(){}
	static function getContent($path) {
		$GLOBALS['%s']->push("php.io.File::getContent");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = file_get_contents($path);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getBytes($path) {
		$GLOBALS['%s']->push("php.io.File::getBytes");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = haxe_io_Bytes::ofString(php_io_File::getContent($path));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function putContent($path, $content) {
		$GLOBALS['%s']->push("php.io.File::putContent");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = file_put_contents($path, $content);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function read($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::read");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileInput(fopen($path, php_io_File_0($binary, $path)));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function write($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::write");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileOutput(fopen($path, php_io_File_1($binary, $path)));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function append($path, $binary) {
		$GLOBALS['%s']->push("php.io.File::append");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileOutput(fopen($path, php_io_File_2($binary, $path)));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function copy($src, $dst) {
		$GLOBALS['%s']->push("php.io.File::copy");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = copy($src, $dst);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stdin() {
		$GLOBALS['%s']->push("php.io.File::stdin");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileInput(fopen("php://stdin", "r"));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stdout() {
		$GLOBALS['%s']->push("php.io.File::stdout");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileOutput(fopen("php://stdout", "w"));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function stderr() {
		$GLOBALS['%s']->push("php.io.File::stderr");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = new php_io_FileOutput(fopen("php://stderr", "w"));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getChar($echo) {
		$GLOBALS['%s']->push("php.io.File::getChar");
		$製pos = $GLOBALS['%s']->length;
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
		$製pos = $GLOBALS['%s']->length;
	if($binary) {
		return "rb";
	} else {
		return "r";
	}
}
function php_io_File_1(&$binary, &$path) {
		$GLOBALS['%s']->push('php.io.File:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	if($binary) {
		return "wb";
	} else {
		return "w";
	}
}
function php_io_File_2(&$binary, &$path) {
		$GLOBALS['%s']->push('php.io.File:lambda_2');
		$製pos = $GLOBALS['%s']->length;
	if($binary) {
		return "ab";
	} else {
		return "a";
	}
}
