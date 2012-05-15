<?php

class haxe_io_Bytes {
	public function __construct($length, $b) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("haxe.io.Bytes::new");
		$»spos = $GLOBALS['%s']->length;
		$this->length = $length;
		$this->b = $b;
		$GLOBALS['%s']->pop();
	}}
	public $length;
	public $b;
	public function get($pos) {
		$GLOBALS['%s']->push("haxe.io.Bytes::get");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = ord($this->b[$pos]);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function set($pos, $v) {
		$GLOBALS['%s']->push("haxe.io.Bytes::set");
		$»spos = $GLOBALS['%s']->length;
		$this->b[$pos] = chr($v);
		$GLOBALS['%s']->pop();
	}
	public function blit($pos, $src, $srcpos, $len) {
		$GLOBALS['%s']->push("haxe.io.Bytes::blit");
		$»spos = $GLOBALS['%s']->length;
		if($pos < 0 || $srcpos < 0 || $len < 0 || $pos + $len > $this->length || $srcpos + $len > $src->length) {
			throw new HException(haxe_io_Error::$OutsideBounds);
		}
		$this->b = substr($this->b, 0, $pos) . substr($src->b, $srcpos, $len) . substr($this->b, $pos+$len);
		$GLOBALS['%s']->pop();
	}
	public function sub($pos, $len) {
		$GLOBALS['%s']->push("haxe.io.Bytes::sub");
		$»spos = $GLOBALS['%s']->length;
		if($pos < 0 || $len < 0 || $pos + $len > $this->length) {
			throw new HException(haxe_io_Error::$OutsideBounds);
		}
		{
			$»tmp = new haxe_io_Bytes($len, substr($this->b, $pos, $len));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function compare($other) {
		$GLOBALS['%s']->push("haxe.io.Bytes::compare");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->b < $other->b ? -1 : ($this->b == $other->b ? 0 : 1);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function readString($pos, $len) {
		$GLOBALS['%s']->push("haxe.io.Bytes::readString");
		$»spos = $GLOBALS['%s']->length;
		if($pos < 0 || $len < 0 || $pos + $len > $this->length) {
			throw new HException(haxe_io_Error::$OutsideBounds);
		}
		{
			$»tmp = substr($this->b, $pos, $len);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function toString() {
		$GLOBALS['%s']->push("haxe.io.Bytes::toString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->b;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getData() {
		$GLOBALS['%s']->push("haxe.io.Bytes::getData");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->b;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->»dynamics[$m]) && is_callable($this->»dynamics[$m]))
			return call_user_func_array($this->»dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call «'.$m.'»');
	}
	static function alloc($length) {
		$GLOBALS['%s']->push("haxe.io.Bytes::alloc");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new haxe_io_Bytes($length, str_repeat(chr(0), $length));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function ofString($s) {
		$GLOBALS['%s']->push("haxe.io.Bytes::ofString");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new haxe_io_Bytes(strlen($s), $s);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function ofData($b) {
		$GLOBALS['%s']->push("haxe.io.Bytes::ofData");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new haxe_io_Bytes(strlen($b), $b);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return $this->toString(); }
}
