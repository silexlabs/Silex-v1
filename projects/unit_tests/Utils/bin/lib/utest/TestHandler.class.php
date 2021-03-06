<?php

class utest_TestHandler {
	public function __construct($fixture) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.TestHandler::new");
		$製pos = $GLOBALS['%s']->length;
		if($fixture === null) {
			throw new HException("fixture argument is null");
		}
		$this->fixture = $fixture;
		$this->results = new HList();
		$this->asyncStack = new HList();
		$this->onTested = new utest_Dispatcher();
		$this->onTimeout = new utest_Dispatcher();
		$this->onComplete = new utest_Dispatcher();
		$GLOBALS['%s']->pop();
	}}
	public $results;
	public $fixture;
	public $asyncStack;
	public $onTested;
	public $onTimeout;
	public $onComplete;
	public function execute() {
		$GLOBALS['%s']->push("utest.TestHandler::execute");
		$製pos = $GLOBALS['%s']->length;
		try {
			$this->executeMethod($this->fixture->setup);
			try {
				$this->executeMethod($this->fixture->method);
			}catch(Exception $蜜) {
				$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
				$e = $_ex_;
				{
					$GLOBALS['%e'] = new _hx_array(array());
					while($GLOBALS['%s']->length >= $製pos) {
						$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
					}
					$GLOBALS['%s']->push($GLOBALS['%e'][0]);
					$this->results->add(utest_Assertation::Error($e, utest_TestHandler::exceptionStack(null)));
				}
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
				$this->results->add(utest_Assertation::SetupError($e, utest_TestHandler::exceptionStack(null)));
			}
		}
		$this->checkTested();
		$GLOBALS['%s']->pop();
	}
	public function checkTested() {
		$GLOBALS['%s']->push("utest.TestHandler::checkTested");
		$製pos = $GLOBALS['%s']->length;
		if($this->asyncStack->length === 0) {
			$this->tested();
		} else {
			$this->timeout();
		}
		$GLOBALS['%s']->pop();
	}
	public $expireson;
	public function setTimeout($timeout) {
		$GLOBALS['%s']->push("utest.TestHandler::setTimeout");
		$製pos = $GLOBALS['%s']->length;
		$newexpire = haxe_Timer::stamp() + $timeout / 1000;
		$this->expireson = utest_TestHandler_0($this, $newexpire, $timeout);
		$GLOBALS['%s']->pop();
	}
	public function bindHandler() {
		$GLOBALS['%s']->push("utest.TestHandler::bindHandler");
		$製pos = $GLOBALS['%s']->length;
		utest_Assert::$results = $this->results;
		utest_Assert::$createAsync = (isset($this->addAsync) ? $this->addAsync: array($this, "addAsync"));
		utest_Assert::$createEvent = (isset($this->addEvent) ? $this->addEvent: array($this, "addEvent"));
		$GLOBALS['%s']->pop();
	}
	public function unbindHandler() {
		$GLOBALS['%s']->push("utest.TestHandler::unbindHandler");
		$製pos = $GLOBALS['%s']->length;
		utest_Assert::$results = null;
		utest_Assert::$createAsync = array(new _hx_lambda(array(), "utest_TestHandler_1"), 'execute');
		utest_Assert::$createEvent = array(new _hx_lambda(array(), "utest_TestHandler_2"), 'execute');
		$GLOBALS['%s']->pop();
	}
	public function addAsync($f, $timeout) {
		$GLOBALS['%s']->push("utest.TestHandler::addAsync");
		$製pos = $GLOBALS['%s']->length;
		if($timeout === null) {
			$timeout = 250;
		}
		if(null === $f) {
			$f = array(new _hx_lambda(array(&$f, &$timeout), "utest_TestHandler_3"), 'execute');
		}
		$this->asyncStack->add($f);
		$handler = $this;
		$this->setTimeout($timeout);
		{
			$裨mp = array(new _hx_lambda(array(&$f, &$handler, &$timeout), "utest_TestHandler_4"), 'execute');
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function addEvent($f, $timeout) {
		$GLOBALS['%s']->push("utest.TestHandler::addEvent");
		$製pos = $GLOBALS['%s']->length;
		if($timeout === null) {
			$timeout = 250;
		}
		$this->asyncStack->add($f);
		$handler = $this;
		$this->setTimeout($timeout);
		{
			$裨mp = array(new _hx_lambda(array(&$f, &$handler, &$timeout), "utest_TestHandler_5"), 'execute');
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	public function executeMethod($name) {
		$GLOBALS['%s']->push("utest.TestHandler::executeMethod");
		$製pos = $GLOBALS['%s']->length;
		if($name === null) {
			$GLOBALS['%s']->pop();
			return;
		}
		$this->bindHandler();
		Reflect::callMethod($this->fixture->target, Reflect::field($this->fixture->target, $name), new _hx_array(array()));
		$GLOBALS['%s']->pop();
	}
	public function tested() {
		$GLOBALS['%s']->push("utest.TestHandler::tested");
		$製pos = $GLOBALS['%s']->length;
		if($this->results->length === 0) {
			$this->results->add(utest_Assertation::Warning("no assertions"));
		}
		$this->onTested->dispatch($this);
		$this->completed();
		$GLOBALS['%s']->pop();
	}
	public function timeout() {
		$GLOBALS['%s']->push("utest.TestHandler::timeout");
		$製pos = $GLOBALS['%s']->length;
		$this->results->add(utest_Assertation::TimeoutError($this->asyncStack->length, new _hx_array(array())));
		$this->onTimeout->dispatch($this);
		$this->completed();
		$GLOBALS['%s']->pop();
	}
	public function completed() {
		$GLOBALS['%s']->push("utest.TestHandler::completed");
		$製pos = $GLOBALS['%s']->length;
		try {
			$this->executeMethod($this->fixture->teardown);
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				$this->results->add(utest_Assertation::TeardownError($e, utest_TestHandler::exceptionStack(2)));
			}
		}
		$this->unbindHandler();
		$this->onComplete->dispatch($this);
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
	static $POLLING_TIME = 10;
	static function exceptionStack($pops) {
		$GLOBALS['%s']->push("utest.TestHandler::exceptionStack");
		$製pos = $GLOBALS['%s']->length;
		if($pops === null) {
			$pops = 2;
		}
		$stack = haxe_Stack::exceptionStack();
		while($pops-- > 0) {
			$stack->pop();
		}
		{
			$GLOBALS['%s']->pop();
			return $stack;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'utest.TestHandler'; }
}
function utest_TestHandler_0(&$裨his, &$newexpire, &$timeout) {
	$製pos = $GLOBALS['%s']->length;
	if($裨his->expireson === null) {
		return $newexpire;
	} else {
		if($newexpire > $裨his->expireson) {
			return $newexpire;
		} else {
			return $裨his->expireson;
		}
	}
}
function utest_TestHandler_1($f, $t) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::unbindHandler@83");
		$製pos2 = $GLOBALS['%s']->length;
		{
			$裨mp = array(new _hx_lambda(array(&$f, &$t), "utest_TestHandler_6"), 'execute');
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_2($f, $t) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::unbindHandler@84");
		$製pos2 = $GLOBALS['%s']->length;
		{
			$裨mp = array(new _hx_lambda(array(&$f, &$t), "utest_TestHandler_7"), 'execute');
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_3(&$f, &$timeout) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::addAsync@113");
		$製pos2 = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_4(&$f, &$handler, &$timeout) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::addAsync@117");
		$製pos2 = $GLOBALS['%s']->length;
		if(!$handler->asyncStack->remove($f)) {
			$handler->results->add(utest_Assertation::AsyncError("method already executed", new _hx_array(array())));
			{
				$GLOBALS['%s']->pop();
				return;
			}
		}
		try {
			$handler->bindHandler();
			call_user_func($f);
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos2) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				$handler->results->add(utest_Assertation::AsyncError($e, utest_TestHandler::exceptionStack(0)));
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_5(&$f, &$handler, &$timeout, $e) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::addEvent@135");
		$製pos2 = $GLOBALS['%s']->length;
		if(!$handler->asyncStack->remove($f)) {
			$handler->results->add(utest_Assertation::AsyncError("event already executed", new _hx_array(array())));
			{
				$GLOBALS['%s']->pop();
				return;
			}
		}
		try {
			$handler->bindHandler();
			call_user_func_array($f, array($e));
		}catch(Exception $蜜) {
			$_ex_ = ($蜜 instanceof HException) ? $蜜->e : $蜜;
			$e1 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $製pos2) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				$handler->results->add(utest_Assertation::AsyncError($e1, utest_TestHandler::exceptionStack(0)));
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_6(&$f, &$t) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::exceptionStack@83");
		$製pos3 = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
}
function utest_TestHandler_7(&$f, &$t, $e) {
	$製pos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.TestHandler::exceptionStack@84");
		$製pos3 = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
}
