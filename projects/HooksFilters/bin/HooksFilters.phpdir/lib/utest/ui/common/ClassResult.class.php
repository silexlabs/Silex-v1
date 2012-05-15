<?php

class utest_ui_common_ClassResult {
	public function __construct($className, $setupName, $teardownName) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::new");
		$�spos = $GLOBALS['%s']->length;
		$this->fixtures = new Hash();
		$this->className = $className;
		$this->setupName = $setupName;
		$this->hasSetup = $setupName !== null;
		$this->teardownName = $teardownName;
		$this->hasTeardown = $teardownName !== null;
		$this->methods = 0;
		$this->stats = new utest_ui_common_ResultStats();
		$GLOBALS['%s']->pop();
	}}
	public $fixtures;
	public $className;
	public $setupName;
	public $teardownName;
	public $hasSetup;
	public $hasTeardown;
	public $methods;
	public $stats;
	public function add($result) {
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::add");
		$�spos = $GLOBALS['%s']->length;
		if($this->fixtures->exists($result->methodName)) {
			throw new HException("invalid duplicated fixture result");
		}
		$this->stats->wire($result->stats);
		$this->methods++;
		$this->fixtures->set($result->methodName, $result);
		$GLOBALS['%s']->pop();
	}
	public function get($method) {
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::get");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $this->fixtures->get($method);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function exists($method) {
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::exists");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = $this->fixtures->exists($method);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function methodNames($errorsHavePriority) {
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::methodNames");
		$�spos = $GLOBALS['%s']->length;
		if($errorsHavePriority === null) {
			$errorsHavePriority = true;
		}
		$names = new _hx_array(array());
		if(null == $this->fixtures) throw new HException('null iterable');
		$�it = $this->fixtures->keys();
		while($�it->hasNext()) {
			$name = $�it->next();
			$names->push($name);
		}
		if($errorsHavePriority) {
			$me = $this;
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$me, &$names), "utest_ui_common_ClassResult_0"), 'execute'));
		} else {
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$names), "utest_ui_common_ClassResult_1"), 'execute'));
		}
		{
			$GLOBALS['%s']->pop();
			return $names;
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->�dynamics[$m]) && is_callable($this->�dynamics[$m]))
			return call_user_func_array($this->�dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'utest.ui.common.ClassResult'; }
}
function utest_ui_common_ClassResult_0(&$errorsHavePriority, &$me, &$names, $a, $b) {
		$GLOBALS['%s']->push('utest.ui.common.ClassResult:lambda_0');
		$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::methodNames@54");
		$�spos2 = $GLOBALS['%s']->length;
		$as = $me->get($a)->stats;
		$bs = $me->get($b)->stats;
		if($as->hasErrors) {
			{
				$�tmp = utest_ui_common_ClassResult_2($�this, $a, $as, $b, $bs, $errorsHavePriority, $me, $names);
				$GLOBALS['%s']->pop();
				return $�tmp;
			}
		} else {
			if($bs->hasErrors) {
				{
					$GLOBALS['%s']->pop();
					return 1;
				}
			} else {
				if($as->hasFailures) {
					{
						$�tmp = utest_ui_common_ClassResult_3($�this, $a, $as, $b, $bs, $errorsHavePriority, $me, $names);
						$GLOBALS['%s']->pop();
						return $�tmp;
					}
				} else {
					if($bs->hasFailures) {
						{
							$GLOBALS['%s']->pop();
							return 1;
						}
					} else {
						if($as->hasWarnings) {
							{
								$�tmp = utest_ui_common_ClassResult_4($�this, $a, $as, $b, $bs, $errorsHavePriority, $me, $names);
								$GLOBALS['%s']->pop();
								return $�tmp;
							}
						} else {
							if($bs->hasWarnings) {
								{
									$GLOBALS['%s']->pop();
									return 1;
								}
							} else {
								{
									$�tmp = Reflect::compare($a, $b);
									$GLOBALS['%s']->pop();
									return $�tmp;
								}
							}
						}
					}
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_ui_common_ClassResult_1(&$errorsHavePriority, &$names, $a, $b) {
		$GLOBALS['%s']->push('utest.ui.common.ClassResult:lambda_1');
		$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.ClassResult::methodNames@74");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$�tmp = Reflect::compare($a, $b);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_ui_common_ClassResult_2(&$�this, &$a, &$as, &$b, &$bs, &$errorsHavePriority, &$me, &$names) {
		$GLOBALS['%s']->push('utest.ui.common.ClassResult:lambda_2');
		$�spos = $GLOBALS['%s']->length;
	if(!$bs->hasErrors) {
		return -1;
	} else {
		if($as->errors === $bs->errors) {
			return Reflect::compare($a, $b);
		} else {
			return Reflect::compare($as->errors, $bs->errors);
		}
	}
}
function utest_ui_common_ClassResult_3(&$�this, &$a, &$as, &$b, &$bs, &$errorsHavePriority, &$me, &$names) {
		$GLOBALS['%s']->push('utest.ui.common.ClassResult:lambda_3');
		$�spos = $GLOBALS['%s']->length;
	if(!$bs->hasFailures) {
		return -1;
	} else {
		if($as->failures === $bs->failures) {
			return Reflect::compare($a, $b);
		} else {
			return Reflect::compare($as->failures, $bs->failures);
		}
	}
}
function utest_ui_common_ClassResult_4(&$�this, &$a, &$as, &$b, &$bs, &$errorsHavePriority, &$me, &$names) {
		$GLOBALS['%s']->push('utest.ui.common.ClassResult:lambda_4');
		$�spos = $GLOBALS['%s']->length;
	if(!$bs->hasWarnings) {
		return -1;
	} else {
		if($as->warnings === $bs->warnings) {
			return Reflect::compare($a, $b);
		} else {
			return Reflect::compare($as->warnings, $bs->warnings);
		}
	}
}
