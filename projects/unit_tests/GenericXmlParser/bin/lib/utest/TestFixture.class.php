<?php

class utest_TestFixture {
	public function __construct($target, $method, $setup, $teardown) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.TestFixture::new");
		$»spos = $GLOBALS['%s']->length;
		$this->target = $target;
		$this->method = $method;
		$this->setup = $setup;
		$this->teardown = $teardown;
		$GLOBALS['%s']->pop();
	}}
	public $target;
	public $method;
	public $setup;
	public $teardown;
	public function checkMethod($name, $arg) {
		$GLOBALS['%s']->push("utest.TestFixture::checkMethod");
		$»spos = $GLOBALS['%s']->length;
		$field = Reflect::field($this->target, $name);
		if($field === null) {
			throw new HException($arg . " function " . $name . " is not a field of target");
		}
		if(!Reflect::isFunction($field)) {
			throw new HException($arg . " function " . $name . " is not a function");
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
	function __toString() { return 'utest.TestFixture'; }
}
