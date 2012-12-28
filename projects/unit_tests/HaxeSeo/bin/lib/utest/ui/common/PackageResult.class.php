<?php

class utest_ui_common_PackageResult {
	public function __construct($packageName) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::new");
		$»spos = $GLOBALS['%s']->length;
		$this->packageName = $packageName;
		$this->classes = new Hash();
		$this->packages = new Hash();
		$this->stats = new utest_ui_common_ResultStats();
		$GLOBALS['%s']->pop();
	}}
	public $packageName;
	public $classes;
	public $packages;
	public $stats;
	public function addResult($result, $flattenPackage) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::addResult");
		$»spos = $GLOBALS['%s']->length;
		$pack = $this->getOrCreatePackage($result->pack, $flattenPackage, $this);
		$cls = $this->getOrCreateClass($pack, $result->cls, $result->setup, $result->teardown);
		$fix = $this->createFixture($result->method, $result->assertations);
		$cls->add($fix);
		$GLOBALS['%s']->pop();
	}
	public function addClass($result) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::addClass");
		$»spos = $GLOBALS['%s']->length;
		$this->classes->set($result->className, $result);
		$this->stats->wire($result->stats);
		$GLOBALS['%s']->pop();
	}
	public function addPackage($result) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::addPackage");
		$»spos = $GLOBALS['%s']->length;
		$this->packages->set($result->packageName, $result);
		$this->stats->wire($result->stats);
		$GLOBALS['%s']->pop();
	}
	public function existsPackage($name) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::existsPackage");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->packages->exists($name);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function existsClass($name) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::existsClass");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->classes->exists($name);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getPackage($name) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::getPackage");
		$»spos = $GLOBALS['%s']->length;
		if($this->packageName === null && $name === "") {
			$GLOBALS['%s']->pop();
			return $this;
		}
		{
			$»tmp = $this->packages->get($name);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getClass($name) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::getClass");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->classes->get($name);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function classNames($errorsHavePriority) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::classNames");
		$»spos = $GLOBALS['%s']->length;
		if($errorsHavePriority === null) {
			$errorsHavePriority = true;
		}
		$names = new _hx_array(array());
		if(null == $this->classes) throw new HException('null iterable');
		$»it = $this->classes->keys();
		while($»it->hasNext()) {
			$name = $»it->next();
			$names->push($name);
		}
		if($errorsHavePriority) {
			$me = $this;
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$me, &$names), "utest_ui_common_PackageResult_0"), 'execute'));
		} else {
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$names), "utest_ui_common_PackageResult_1"), 'execute'));
		}
		{
			$GLOBALS['%s']->pop();
			return $names;
		}
		$GLOBALS['%s']->pop();
	}
	public function packageNames($errorsHavePriority) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::packageNames");
		$»spos = $GLOBALS['%s']->length;
		if($errorsHavePriority === null) {
			$errorsHavePriority = true;
		}
		$names = new _hx_array(array());
		if($this->packageName === null) {
			$names->push("");
		}
		if(null == $this->packages) throw new HException('null iterable');
		$»it = $this->packages->keys();
		while($»it->hasNext()) {
			$name = $»it->next();
			$names->push($name);
		}
		if($errorsHavePriority) {
			$me = $this;
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$me, &$names), "utest_ui_common_PackageResult_2"), 'execute'));
		} else {
			$names->sort(array(new _hx_lambda(array(&$errorsHavePriority, &$names), "utest_ui_common_PackageResult_3"), 'execute'));
		}
		{
			$GLOBALS['%s']->pop();
			return $names;
		}
		$GLOBALS['%s']->pop();
	}
	public function createFixture($method, $assertations) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::createFixture");
		$»spos = $GLOBALS['%s']->length;
		$f = new utest_ui_common_FixtureResult($method);
		if(null == $assertations) throw new HException('null iterable');
		$»it = $assertations->iterator();
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
	public function getOrCreateClass($pack, $cls, $setup, $teardown) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::getOrCreateClass");
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
	public function getOrCreatePackage($pack, $flat, $ref) {
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::getOrCreatePackage");
		$»spos = $GLOBALS['%s']->length;
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
	function __toString() { return 'utest.ui.common.PackageResult'; }
}
function utest_ui_common_PackageResult_0(&$errorsHavePriority, &$me, &$names, $a, $b) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::classNames@64");
		$»spos2 = $GLOBALS['%s']->length;
		$as = $me->getClass($a)->stats;
		$bs = $me->getClass($b)->stats;
		if($as->hasErrors) {
			$»tmp = ((!$bs->hasErrors) ? -1 : (($as->errors === $bs->errors) ? Reflect::compare($a, $b) : Reflect::compare($as->errors, $bs->errors)));
			$GLOBALS['%s']->pop();
			return $»tmp;
		} else {
			if($bs->hasErrors) {
				$GLOBALS['%s']->pop();
				return 1;
			} else {
				if($as->hasFailures) {
					$»tmp = ((!$bs->hasFailures) ? -1 : (($as->failures === $bs->failures) ? Reflect::compare($a, $b) : Reflect::compare($as->failures, $bs->failures)));
					$GLOBALS['%s']->pop();
					return $»tmp;
				} else {
					if($bs->hasFailures) {
						$GLOBALS['%s']->pop();
						return 1;
					} else {
						if($as->hasWarnings) {
							$»tmp = ((!$bs->hasWarnings) ? -1 : (($as->warnings === $bs->warnings) ? Reflect::compare($a, $b) : Reflect::compare($as->warnings, $bs->warnings)));
							$GLOBALS['%s']->pop();
							return $»tmp;
						} else {
							if($bs->hasWarnings) {
								$GLOBALS['%s']->pop();
								return 1;
							} else {
								$»tmp = Reflect::compare($a, $b);
								$GLOBALS['%s']->pop();
								return $»tmp;
							}
						}
					}
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_ui_common_PackageResult_1(&$errorsHavePriority, &$names, $a, $b) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::classNames@84");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = Reflect::compare($a, $b);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_ui_common_PackageResult_2(&$errorsHavePriority, &$me, &$names, $a, $b) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::packageNames@98");
		$»spos2 = $GLOBALS['%s']->length;
		$as = $me->getPackage($a)->stats;
		$bs = $me->getPackage($b)->stats;
		if($as->hasErrors) {
			$»tmp = ((!$bs->hasErrors) ? -1 : (($as->errors === $bs->errors) ? Reflect::compare($a, $b) : Reflect::compare($as->errors, $bs->errors)));
			$GLOBALS['%s']->pop();
			return $»tmp;
		} else {
			if($bs->hasErrors) {
				$GLOBALS['%s']->pop();
				return 1;
			} else {
				if($as->hasFailures) {
					$»tmp = ((!$bs->hasFailures) ? -1 : (($as->failures === $bs->failures) ? Reflect::compare($a, $b) : Reflect::compare($as->failures, $bs->failures)));
					$GLOBALS['%s']->pop();
					return $»tmp;
				} else {
					if($bs->hasFailures) {
						$GLOBALS['%s']->pop();
						return 1;
					} else {
						if($as->hasWarnings) {
							$»tmp = ((!$bs->hasWarnings) ? -1 : (($as->warnings === $bs->warnings) ? Reflect::compare($a, $b) : Reflect::compare($as->warnings, $bs->warnings)));
							$GLOBALS['%s']->pop();
							return $»tmp;
						} else {
							if($bs->hasWarnings) {
								$GLOBALS['%s']->pop();
								return 1;
							} else {
								$»tmp = Reflect::compare($a, $b);
								$GLOBALS['%s']->pop();
								return $»tmp;
							}
						}
					}
				}
			}
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_ui_common_PackageResult_3(&$errorsHavePriority, &$names, $a, $b) {
	$»spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.ui.common.PackageResult::packageNames@118");
		$»spos2 = $GLOBALS['%s']->length;
		{
			$»tmp = Reflect::compare($a, $b);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
