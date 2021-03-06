<?php

class utest_Runner {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.Runner::new");
		$製pos = $GLOBALS['%s']->length;
		$this->fixtures = new _hx_array(array());
		$this->onProgress = new utest_Dispatcher();
		$this->onStart = new utest_Dispatcher();
		$this->onComplete = new utest_Dispatcher();
		$this->length = 0;
		$GLOBALS['%s']->pop();
	}}
	public $fixtures;
	public $onProgress;
	public $onStart;
	public $onComplete;
	public $length;
	public function addCase($test, $setup, $teardown, $prefix, $pattern) {
		$GLOBALS['%s']->push("utest.Runner::addCase");
		$製pos = $GLOBALS['%s']->length;
		if($prefix === null) {
			$prefix = "test";
		}
		if($teardown === null) {
			$teardown = "teardown";
		}
		if($setup === null) {
			$setup = "setup";
		}
		if(!Reflect::isObject($test)) {
			throw new HException("can't add a null object as a test case");
		}
		if(!$this->isMethod($test, $setup)) {
			$setup = null;
		}
		if(!$this->isMethod($test, $teardown)) {
			$teardown = null;
		}
		$fields = Type::getInstanceFields(Type::getClass($test));
		if($pattern === null) {
			$_g = 0;
			while($_g < $fields->length) {
				$field = $fields[$_g];
				++$_g;
				if(!StringTools::startsWith($field, $prefix)) {
					continue;
				}
				if(!$this->isMethod($test, $field)) {
					continue;
				}
				$this->addFixture(new utest_TestFixture($test, $field, $setup, $teardown));
				unset($field);
			}
		} else {
			$_g = 0;
			while($_g < $fields->length) {
				$field = $fields[$_g];
				++$_g;
				if(!$pattern->match($field)) {
					continue;
				}
				if(!$this->isMethod($test, $field)) {
					continue;
				}
				$this->addFixture(new utest_TestFixture($test, $field, $setup, $teardown));
				unset($field);
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function addFixture($fixture) {
		$GLOBALS['%s']->push("utest.Runner::addFixture");
		$製pos = $GLOBALS['%s']->length;
		$this->fixtures->push($fixture);
		$this->length++;
		$GLOBALS['%s']->pop();
	}
	public function getFixture($index) {
		$GLOBALS['%s']->push("utest.Runner::getFixture");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $this->fixtures[$index];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function isMethod($test, $name) {
		$GLOBALS['%s']->push("utest.Runner::isMethod");
		$製pos = $GLOBALS['%s']->length;
		try {
			{
				$裨mp = Reflect::isFunction(Reflect::field($test, $name));
				$GLOBALS['%s']->pop();
				return $裨mp;
			}
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function run() {
		$GLOBALS['%s']->push("utest.Runner::run");
		$製pos = $GLOBALS['%s']->length;
		$this->onStart->dispatch($this);
		{
			$_g1 = 0; $_g = $this->fixtures->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$h = $this->runFixture($this->fixtures[$i]);
				$this->onProgress->dispatch(_hx_anonymous(array("result" => utest_TestResult::ofHandler($h), "done" => $i + 1, "totals" => $this->length)));
				unset($i,$h);
			}
		}
		$this->onComplete->dispatch($this);
		$GLOBALS['%s']->pop();
	}
	public function runFixture($fixture) {
		$GLOBALS['%s']->push("utest.Runner::runFixture");
		$製pos = $GLOBALS['%s']->length;
		$handler = new utest_TestHandler($fixture);
		$handler->execute();
		{
			$GLOBALS['%s']->pop();
			return $handler;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->蜿ynamics[$m]) && is_callable($this->蜿ynamics[$m]))
			return call_user_func_array($this->蜿ynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'utest.Runner'; }
}
