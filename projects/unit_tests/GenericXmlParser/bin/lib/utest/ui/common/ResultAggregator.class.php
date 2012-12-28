<?php

class utest_ui_common_ResultAggregator {
	public function __construct($runner, $flattenPackage) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::new");
		$»spos = $GLOBALS['%s']->length;
		if($flattenPackage === null) {
			$flattenPackage = false;
		}
		if($runner === null) {
			throw new HException("runner argument is null");
		}
		$this->flattenPackage = $flattenPackage;
		$this->runner = $runner;
		$runner->onStart->add((isset($this->start) ? $this->start: array($this, "start")));
		$runner->onProgress->add((isset($this->progress) ? $this->progress: array($this, "progress")));
		$runner->onComplete->add((isset($this->complete) ? $this->complete: array($this, "complete")));
		$this->onStart = new utest_Notifier();
		$this->onComplete = new utest_Dispatcher();
		$this->onProgress = new utest_Dispatcher();
		$GLOBALS['%s']->pop();
	}}
	public $runner;
	public $flattenPackage;
	public $root;
	public $onStart;
	public $onComplete;
	public $onProgress;
	public function start($runner) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::start");
		$»spos = $GLOBALS['%s']->length;
		$this->root = new utest_ui_common_PackageResult(null);
		$this->onStart->dispatch();
		$GLOBALS['%s']->pop();
	}
	public function getOrCreatePackage($pack, $flat, $ref) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::getOrCreatePackage");
		$»spos = $GLOBALS['%s']->length;
		if($ref === null) {
			$ref = $this->root;
		}
		if($pack === null || $pack === "") {
			$GLOBALS['%s']->pop();
			return $ref;
		}
		if($flat) {
			if($ref->existsPackage($pack)) {
				$»tmp = $ref->getPackage($pack);
				$GLOBALS['%s']->pop();
				return $»tmp;
			}
			$p = new utest_ui_common_PackageResult($pack);
			$ref->addPackage($p);
			{
				$GLOBALS['%s']->pop();
				return $p;
			}
		} else {
			$parts = _hx_explode(".", $pack);
			{
				$_g = 0;
				while($_g < $parts->length) {
					$part = $parts[$_g];
					++$_g;
					$ref = $this->getOrCreatePackage($part, true, $ref);
					unset($part);
				}
			}
			{
				$GLOBALS['%s']->pop();
				return $ref;
			}
		}
		$GLOBALS['%s']->pop();
	}
	public function getOrCreateClass($pack, $cls, $setup, $teardown) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::getOrCreateClass");
		$»spos = $GLOBALS['%s']->length;
		if($pack->existsClass($cls)) {
			$»tmp = $pack->getClass($cls);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$c = new utest_ui_common_ClassResult($cls, $setup, $teardown);
		$pack->addClass($c);
		{
			$GLOBALS['%s']->pop();
			return $c;
		}
		$GLOBALS['%s']->pop();
	}
	public function createFixture($result) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::createFixture");
		$»spos = $GLOBALS['%s']->length;
		$f = new utest_ui_common_FixtureResult($result->method);
		if(null == $result->assertations) throw new HException('null iterable');
		$»it = $result->assertations->iterator();
		while($»it->hasNext()) {
			$assertation = $»it->next();
			$f->add($assertation);
		}
		{
			$GLOBALS['%s']->pop();
			return $f;
		}
		$GLOBALS['%s']->pop();
	}
	public function progress($e) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::progress");
		$»spos = $GLOBALS['%s']->length;
		$this->root->addResult($e->result, $this->flattenPackage);
		$this->onProgress->dispatch($e);
		$GLOBALS['%s']->pop();
	}
	public function complete($runner) {
		$GLOBALS['%s']->push("utest.ui.common.ResultAggregator::complete");
		$»spos = $GLOBALS['%s']->length;
		$this->onComplete->dispatch($this->root);
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
	function __toString() { return 'utest.ui.common.ResultAggregator'; }
}
