<?php

class utest_Dispatcher {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.Dispatcher::new");
		$»spos = $GLOBALS['%s']->length;
		$this->handlers = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $handlers;
	public function add($h) {
		$GLOBALS['%s']->push("utest.Dispatcher::add");
		$»spos = $GLOBALS['%s']->length;
		$this->handlers->push($h);
		{
			$GLOBALS['%s']->pop();
			return $h;
		}
		$GLOBALS['%s']->pop();
	}
	public function remove($h) {
		$GLOBALS['%s']->push("utest.Dispatcher::remove");
		$»spos = $GLOBALS['%s']->length;
		{
			$_g1 = 0; $_g = $this->handlers->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				if(Reflect::compareMethods($this->handlers[$i], $h)) {
					$»tmp = _hx_array_get($this->handlers->splice($i, 1), 0);
					$GLOBALS['%s']->pop();
					return $»tmp;
					unset($»tmp);
				}
				unset($i);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	public function clear() {
		$GLOBALS['%s']->push("utest.Dispatcher::clear");
		$»spos = $GLOBALS['%s']->length;
		$this->handlers = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}
	public function dispatch($e) {
		$GLOBALS['%s']->push("utest.Dispatcher::dispatch");
		$»spos = $GLOBALS['%s']->length;
		try {
			$list = $this->handlers->copy();
			{
				$_g = 0;
				while($_g < $list->length) {
					$l = $list[$_g];
					++$_g;
					call_user_func_array($l, array($e));
					unset($l);
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			if(($exc = $_ex_) instanceof utest__Dispatcher_EventException){
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $»spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			} else throw $»e;;
		}
		$GLOBALS['%s']->pop();
	}
	public function has() {
		$GLOBALS['%s']->push("utest.Dispatcher::has");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->handlers->length > 0;
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
	static function stop() {
		$GLOBALS['%s']->push("utest.Dispatcher::stop");
		$»spos = $GLOBALS['%s']->length;
		throw new HException(utest__Dispatcher_EventException::$StopPropagation);
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'utest.Dispatcher'; }
}
