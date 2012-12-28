<?php

class utest_Assert {
	public function __construct(){}
	static $results;
	static function isTrue($cond, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::isTrue");
		$�spos = $GLOBALS['%s']->length;
		if(utest_Assert::$results === null) {
			throw new HException("Assert.results is not currently bound to any assert context");
		}
		if(null === $msg) {
			$msg = "expected true";
		}
		if($cond) {
			utest_Assert::$results->add(utest_Assertation::Success($pos));
		} else {
			utest_Assert::$results->add(utest_Assertation::Failure($msg, $pos));
		}
		$GLOBALS['%s']->pop();
	}
	static function isFalse($value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::isFalse");
		$�spos = $GLOBALS['%s']->length;
		if(null === $msg) {
			$msg = "expected false";
		}
		utest_Assert::isTrue($value === false, $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function isNull($value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::isNull");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "expected null but was " . utest_Assert::q($value);
		}
		utest_Assert::isTrue($value === null, $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function notNull($value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::notNull");
		$�spos = $GLOBALS['%s']->length;
		if(null === $msg) {
			$msg = "expected false";
		}
		utest_Assert::isTrue($value !== null, $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function is($value, $type, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::is");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "expected type " . utest_Assert::typeToString($type) . " but was " . utest_Assert::typeToString($value);
		}
		utest_Assert::isTrue(Std::is($value, $type), $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function notEquals($expected, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::notEquals");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "expected " . utest_Assert::q($expected) . " and testa value " . utest_Assert::q($value) . " should be different";
		}
		utest_Assert::isFalse(_hx_equal($expected, $value), $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function equals($expected, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::equals");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "expected " . utest_Assert::q($expected) . " but was " . utest_Assert::q($value);
		}
		utest_Assert::isTrue(_hx_equal($expected, $value), $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function match($pattern, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::match");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "the value " . utest_Assert::q($value) . "does not match the provided pattern";
		}
		utest_Assert::isTrue($pattern->match($value), $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function floatEquals($expected, $value, $approx, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::floatEquals");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "expected " . utest_Assert::q($expected) . " but was " . utest_Assert::q($value);
		}
		{
			$�tmp = utest_Assert::isTrue(utest_Assert::_floatEquals($expected, $value, $approx), $msg, $pos);
			$GLOBALS['%s']->pop();
			$�tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function _floatEquals($expected, $value, $approx) {
		$GLOBALS['%s']->push("utest.Assert::_floatEquals");
		$�spos = $GLOBALS['%s']->length;
		if(Math::isNaN($expected)) {
			$�tmp = Math::isNaN($value);
			$GLOBALS['%s']->pop();
			return $�tmp;
		} else {
			if(Math::isNaN($value)) {
				$GLOBALS['%s']->pop();
				return false;
			} else {
				if(!Math::isFinite($expected) && !Math::isFinite($value)) {
					$�tmp = ($expected > 0) == $value > 0;
					$GLOBALS['%s']->pop();
					return $�tmp;
				}
			}
		}
		if(null === $approx) {
			$approx = 1e-5;
		}
		{
			$�tmp = Math::abs($value - $expected) < $approx;
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getTypeName($v) {
		$GLOBALS['%s']->push("utest.Assert::getTypeName");
		$�spos = $GLOBALS['%s']->length;
		$�t = (Type::typeof($v));
		switch($�t->index) {
		case 0:
		{
			$GLOBALS['%s']->pop();
			return "[null]";
		}break;
		case 1:
		{
			$GLOBALS['%s']->pop();
			return "Int";
		}break;
		case 2:
		{
			$GLOBALS['%s']->pop();
			return "Float";
		}break;
		case 3:
		{
			$GLOBALS['%s']->pop();
			return "Bool";
		}break;
		case 5:
		{
			$GLOBALS['%s']->pop();
			return "function";
		}break;
		case 6:
		$c = $�t->params[0];
		{
			$�tmp = Type::getClassName($c);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case 7:
		$e = $�t->params[0];
		{
			$�tmp = Type::getEnumName($e);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case 4:
		{
			$GLOBALS['%s']->pop();
			return "Object";
		}break;
		case 8:
		{
			$GLOBALS['%s']->pop();
			return "Unknown";
		}break;
		}
		$GLOBALS['%s']->pop();
	}
	static function isIterable($v, $isAnonym) {
		$GLOBALS['%s']->push("utest.Assert::isIterable");
		$�spos = $GLOBALS['%s']->length;
		$fields = (($isAnonym) ? Reflect::fields($v) : Type::getInstanceFields(Type::getClass($v)));
		if(!Lambda::has($fields, "iterator", null)) {
			$GLOBALS['%s']->pop();
			return false;
		}
		{
			$�tmp = Reflect::isFunction(Reflect::field($v, "iterator"));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isIterator($v, $isAnonym) {
		$GLOBALS['%s']->push("utest.Assert::isIterator");
		$�spos = $GLOBALS['%s']->length;
		$fields = (($isAnonym) ? Reflect::fields($v) : Type::getInstanceFields(Type::getClass($v)));
		if(!Lambda::has($fields, "next", null) || !Lambda::has($fields, "hasNext", null)) {
			$GLOBALS['%s']->pop();
			return false;
		}
		{
			$�tmp = Reflect::isFunction(Reflect::field($v, "next")) && Reflect::isFunction(Reflect::field($v, "hasNext"));
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function sameAs($expected, $value, $status) {
		$GLOBALS['%s']->push("utest.Assert::sameAs");
		$�spos = $GLOBALS['%s']->length;
		$texpected = utest_Assert::getTypeName($expected);
		$tvalue = utest_Assert::getTypeName($value);
		$isanonym = $texpected === "Object";
		if($texpected !== $tvalue) {
			$status->error = "expected type " . $texpected . " but it is " . $tvalue . (utest_Assert_0($expected, $isanonym, $status, $texpected, $tvalue, $value));
			{
				$GLOBALS['%s']->pop();
				return false;
			}
		}
		$�t = (Type::typeof($expected));
		switch($�t->index) {
		case 2:
		{
			$�tmp = utest_Assert::_floatEquals($expected, $value, null);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		case 0:
		case 1:
		case 3:
		{
			if(!_hx_equal($expected, $value)) {
				$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_1($expected, $isanonym, $status, $texpected, $tvalue, $value));
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}break;
		case 5:
		{
			if(!Reflect::compareMethods($expected, $value)) {
				$status->error = "expected same function reference" . (utest_Assert_2($expected, $isanonym, $status, $texpected, $tvalue, $value));
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}break;
		case 6:
		$c = $�t->params[0];
		{
			$cexpected = Type::getClassName($c);
			$cvalue = Type::getClassName(Type::getClass($value));
			if($cexpected !== $cvalue) {
				$status->error = "expected instance of " . utest_Assert::q($cexpected) . " but it is " . utest_Assert::q($cvalue) . (utest_Assert_3($c, $cexpected, $cvalue, $expected, $isanonym, $status, $texpected, $tvalue, $value));
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
			if(Std::is($expected, _hx_qtype("String")) && !_hx_equal($expected, $value)) {
				$status->error = "expected '" . $expected . "' but it is '" . $value . "'";
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
			if(Std::is($expected, _hx_qtype("Array"))) {
				if($status->recursive || $status->path === "") {
					if(!_hx_equal(_hx_len($expected), _hx_len($value))) {
						$status->error = "expected " . _hx_len($expected) . " elements but they were " . _hx_len($value) . (utest_Assert_4($c, $cexpected, $cvalue, $expected, $isanonym, $status, $texpected, $tvalue, $value));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g1 = 0; $_g = _hx_len($expected);
						while($_g1 < $_g) {
							$i = $_g1++;
							$status->path = utest_Assert_5($_g, $_g1, $c, $cexpected, $cvalue, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value);
							if(!utest_Assert::sameAs($expected[$i], $value[$i], $status)) {
								$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_6($_g, $_g1, $c, $cexpected, $cvalue, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value));
								{
									$GLOBALS['%s']->pop();
									return false;
								}
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(Std::is($expected, _hx_qtype("Date"))) {
				if(!_hx_equal($expected->getTime(), $value->getTime())) {
					$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_7($c, $cexpected, $cvalue, $expected, $isanonym, $status, $texpected, $tvalue, $value));
					{
						$GLOBALS['%s']->pop();
						return false;
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(Std::is($expected, _hx_qtype("haxe.io.Bytes"))) {
				if($status->recursive || $status->path === "") {
					$ebytes = $expected;
					$vbytes = $value;
					if($ebytes->length !== $vbytes->length) {
						$GLOBALS['%s']->pop();
						return false;
					}
					{
						$_g1 = 0; $_g = $ebytes->length;
						while($_g1 < $_g) {
							$i = $_g1++;
							if(ord($ebytes->b[$i]) !== ord($vbytes->b[$i])) {
								$status->error = "expected byte " . ord($ebytes->b[$i]) . " but wss " . ord($ebytes->b[$i]) . (utest_Assert_8($_g, $_g1, $c, $cexpected, $cvalue, $ebytes, $expected, $i, $isanonym, $status, $texpected, $tvalue, $value, $vbytes));
								{
									$GLOBALS['%s']->pop();
									return false;
								}
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(Std::is($expected, _hx_qtype("Hash")) || Std::is($expected, _hx_qtype("IntHash"))) {
				if($status->recursive || $status->path === "") {
					$keys = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_9"), 'execute'))));
					$vkeys = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$keys, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_10"), 'execute'))));
					if($keys->length !== $vkeys->length) {
						$status->error = "expected " . $keys->length . " keys but they were " . $vkeys->length . (utest_Assert_11($c, $cexpected, $cvalue, $expected, $isanonym, $keys, $status, $texpected, $tvalue, $value, $vkeys));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g = 0;
						while($_g < $keys->length) {
							$key = $keys[$_g];
							++$_g;
							$status->path = utest_Assert_12($_g, $c, $cexpected, $cvalue, $expected, $isanonym, $key, $keys, $path, $status, $texpected, $tvalue, $value, $vkeys);
							if(!utest_Assert::sameAs($expected->get($key), $value->get($key), $status)) {
								$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_13($_g, $c, $cexpected, $cvalue, $expected, $isanonym, $key, $keys, $path, $status, $texpected, $tvalue, $value, $vkeys));
								{
									$GLOBALS['%s']->pop();
									return false;
								}
							}
							unset($key);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(utest_Assert::isIterator($expected, false)) {
				if($status->recursive || $status->path === "") {
					$evalues = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_14"), 'execute'))));
					$vvalues = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_15"), 'execute'))));
					if($evalues->length !== $vvalues->length) {
						$status->error = "expected " . $evalues->length . " values in Iterator but they were " . $vvalues->length . (utest_Assert_16($c, $cexpected, $cvalue, $evalues, $expected, $isanonym, $status, $texpected, $tvalue, $value, $vvalues));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g1 = 0; $_g = $evalues->length;
						while($_g1 < $_g) {
							$i = $_g1++;
							$status->path = utest_Assert_17($_g, $_g1, $c, $cexpected, $cvalue, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues);
							if(!utest_Assert::sameAs($evalues[$i], $vvalues[$i], $status)) {
								$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_18($_g, $_g1, $c, $cexpected, $cvalue, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues));
								{
									$GLOBALS['%s']->pop();
									return false;
								}
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(utest_Assert::isIterable($expected, false)) {
				if($status->recursive || $status->path === "") {
					$evalues = Lambda::harray($expected);
					$vvalues = Lambda::harray($value);
					if($evalues->length !== $vvalues->length) {
						$status->error = "expected " . $evalues->length . " values in Iterable but they were " . $vvalues->length . (utest_Assert_19($c, $cexpected, $cvalue, $evalues, $expected, $isanonym, $status, $texpected, $tvalue, $value, $vvalues));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g1 = 0; $_g = $evalues->length;
						while($_g1 < $_g) {
							$i = $_g1++;
							$status->path = utest_Assert_20($_g, $_g1, $c, $cexpected, $cvalue, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues);
							if(!utest_Assert::sameAs($evalues[$i], $vvalues[$i], $status)) {
								$GLOBALS['%s']->pop();
								return false;
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if($status->recursive || $status->path === "") {
				$fields = Type::getInstanceFields(Type::getClass($expected));
				$path = $status->path;
				{
					$_g = 0;
					while($_g < $fields->length) {
						$field = $fields[$_g];
						++$_g;
						$status->path = utest_Assert_21($_g, $c, $cexpected, $cvalue, $expected, $field, $fields, $isanonym, $path, $status, $texpected, $tvalue, $value);
						$e = Reflect::field($expected, $field);
						if(Reflect::isFunction($e)) {
							continue;
						}
						$v = Reflect::field($value, $field);
						if(!utest_Assert::sameAs($e, $v, $status)) {
							$GLOBALS['%s']->pop();
							return false;
						}
						unset($v,$field,$e);
					}
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}break;
		case 7:
		$e = $�t->params[0];
		{
			$eexpected = Type::getEnumName($e);
			$evalue = Type::getEnumName(Type::getEnum($value));
			if($eexpected !== $evalue) {
				$status->error = "expected enumeration of " . utest_Assert::q($eexpected) . " but it is " . utest_Assert::q($evalue) . (utest_Assert_22($e, $eexpected, $evalue, $expected, $isanonym, $status, $texpected, $tvalue, $value));
				{
					$GLOBALS['%s']->pop();
					return false;
				}
			}
			if($status->recursive || $status->path === "") {
				if($expected->index !== $value->index) {
					$status->error = "expected " . utest_Assert::q(Type::enumConstructor($expected)) . " but is " . utest_Assert::q(Type::enumConstructor($value)) . (utest_Assert_23($e, $eexpected, $evalue, $expected, $isanonym, $status, $texpected, $tvalue, $value));
					{
						$GLOBALS['%s']->pop();
						return false;
					}
				}
				$eparams = Type::enumParameters($expected);
				$vparams = Type::enumParameters($value);
				$path = $status->path;
				{
					$_g1 = 0; $_g = $eparams->length;
					while($_g1 < $_g) {
						$i = $_g1++;
						$status->path = utest_Assert_24($_g, $_g1, $e, $eexpected, $eparams, $evalue, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vparams);
						if(!utest_Assert::sameAs($eparams[$i], $vparams[$i], $status)) {
							$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_25($_g, $_g1, $e, $eexpected, $eparams, $evalue, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vparams));
							{
								$GLOBALS['%s']->pop();
								return false;
							}
						}
						unset($i);
					}
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}break;
		case 4:
		{
			if($status->recursive || $status->path === "") {
				$tfields = Reflect::fields($value);
				$fields = Reflect::fields($expected);
				$path = $status->path;
				{
					$_g = 0;
					while($_g < $fields->length) {
						$field = $fields[$_g];
						++$_g;
						$tfields->remove($field);
						$status->path = utest_Assert_26($_g, $expected, $field, $fields, $isanonym, $path, $status, $texpected, $tfields, $tvalue, $value);
						if(!_hx_has_field($value, $field)) {
							$status->error = "expected field " . $status->path . " does not exist in " . utest_Assert::q($value);
							{
								$GLOBALS['%s']->pop();
								return false;
							}
						}
						$e = Reflect::field($expected, $field);
						if(Reflect::isFunction($e)) {
							continue;
						}
						$v = Reflect::field($value, $field);
						if(!utest_Assert::sameAs($e, $v, $status)) {
							$GLOBALS['%s']->pop();
							return false;
						}
						unset($v,$field,$e);
					}
				}
				if($tfields->length > 0) {
					$status->error = "the tested object has extra field(s) (" . $tfields->join(", ") . ") not included in the expected ones";
					{
						$GLOBALS['%s']->pop();
						return false;
					}
				}
			}
			if(utest_Assert::isIterator($expected, true)) {
				if(!utest_Assert::isIterator($value, true)) {
					$status->error = "expected Iterable but it is not " . (utest_Assert_27($expected, $isanonym, $status, $texpected, $tvalue, $value));
					{
						$GLOBALS['%s']->pop();
						return false;
					}
				}
				if($status->recursive || $status->path === "") {
					$evalues = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_28"), 'execute'))));
					$vvalues = Lambda::harray(_hx_anonymous(array("iterator" => array(new _hx_lambda(array(&$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value), "utest_Assert_29"), 'execute'))));
					if($evalues->length !== $vvalues->length) {
						$status->error = "expected " . $evalues->length . " values in Iterator but they were " . $vvalues->length . (utest_Assert_30($evalues, $expected, $isanonym, $status, $texpected, $tvalue, $value, $vvalues));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g1 = 0; $_g = $evalues->length;
						while($_g1 < $_g) {
							$i = $_g1++;
							$status->path = utest_Assert_31($_g, $_g1, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues);
							if(!utest_Assert::sameAs($evalues[$i], $vvalues[$i], $status)) {
								$status->error = "expected " . utest_Assert::q($expected) . " but it is " . utest_Assert::q($value) . (utest_Assert_32($_g, $_g1, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues));
								{
									$GLOBALS['%s']->pop();
									return false;
								}
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			if(utest_Assert::isIterable($expected, true)) {
				if(!utest_Assert::isIterable($value, true)) {
					$status->error = "expected Iterator but it is not " . (utest_Assert_33($expected, $isanonym, $status, $texpected, $tvalue, $value));
					{
						$GLOBALS['%s']->pop();
						return false;
					}
				}
				if($status->recursive || $status->path === "") {
					$evalues = Lambda::harray($expected);
					$vvalues = Lambda::harray($value);
					if($evalues->length !== $vvalues->length) {
						$status->error = "expected " . $evalues->length . " values in Iterable but they were " . $vvalues->length . (utest_Assert_34($evalues, $expected, $isanonym, $status, $texpected, $tvalue, $value, $vvalues));
						{
							$GLOBALS['%s']->pop();
							return false;
						}
					}
					$path = $status->path;
					{
						$_g1 = 0; $_g = $evalues->length;
						while($_g1 < $_g) {
							$i = $_g1++;
							$status->path = utest_Assert_35($_g, $_g1, $evalues, $expected, $i, $isanonym, $path, $status, $texpected, $tvalue, $value, $vvalues);
							if(!utest_Assert::sameAs($evalues[$i], $vvalues[$i], $status)) {
								$GLOBALS['%s']->pop();
								return false;
							}
							unset($i);
						}
					}
				}
				{
					$GLOBALS['%s']->pop();
					return true;
				}
			}
			{
				$GLOBALS['%s']->pop();
				return true;
			}
		}break;
		case 8:
		{
			$�tmp = utest_Assert_36($expected, $isanonym, $status, $texpected, $tvalue, $value);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}break;
		}
		{
			$�tmp = utest_Assert_37($expected, $isanonym, $status, $texpected, $tvalue, $value);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function q($v) {
		$GLOBALS['%s']->push("utest.Assert::q");
		$�spos = $GLOBALS['%s']->length;
		if(Std::is($v, _hx_qtype("String"))) {
			$�tmp = "\"" . str_replace("\"", "\\\"", $v) . "\"";
			$GLOBALS['%s']->pop();
			return $�tmp;
		} else {
			$�tmp = Std::string($v);
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
	static function same($expected, $value, $recursive, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::same");
		$�spos = $GLOBALS['%s']->length;
		if(null === $recursive) {
			$recursive = true;
		}
		$status = _hx_anonymous(array("recursive" => $recursive, "path" => "", "error" => null));
		if(utest_Assert::sameAs($expected, $value, $status)) {
			utest_Assert::isTrue(true, $msg, $pos);
		} else {
			utest_Assert::fail(utest_Assert_38($expected, $msg, $pos, $recursive, $status, $value), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function raises($method, $type, $msgNotThrown, $msgWrongType, $pos) {
		$GLOBALS['%s']->push("utest.Assert::raises");
		$�spos = $GLOBALS['%s']->length;
		if($type === null) {
			$type = _hx_qtype("String");
		}
		try {
			call_user_func($method);
			$name = Type::getClassName($type);
			if($name === null) {
				$name = "" . $type;
			}
			if(null === $msgNotThrown) {
				$msgNotThrown = "exception of type " . $name . " not raised";
			}
			utest_Assert::fail($msgNotThrown, $pos);
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$ex = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
				$name = Type::getClassName($type);
				if($name === null) {
					$name = "" . $type;
				}
				if(null === $msgWrongType) {
					$msgWrongType = "expected throw of type " . $name . " but was " . $ex;
				}
				utest_Assert::isTrue(Std::is($ex, $type), $msgWrongType, $pos);
			}
		}
		$GLOBALS['%s']->pop();
	}
	static function allows($possibilities, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::allows");
		$�spos = $GLOBALS['%s']->length;
		if(Lambda::has($possibilities, $value, null)) {
			utest_Assert::isTrue(true, $msg, $pos);
		} else {
			utest_Assert::fail(utest_Assert_39($msg, $pos, $possibilities, $value), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function contains($match, $values, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::contains");
		$�spos = $GLOBALS['%s']->length;
		if(Lambda::has($values, $match, null)) {
			utest_Assert::isTrue(true, $msg, $pos);
		} else {
			utest_Assert::fail(utest_Assert_40($match, $msg, $pos, $values), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function notContains($match, $values, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::notContains");
		$�spos = $GLOBALS['%s']->length;
		if(!Lambda::has($values, $match, null)) {
			utest_Assert::isTrue(true, $msg, $pos);
		} else {
			utest_Assert::fail(utest_Assert_41($match, $msg, $pos, $values), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function stringContains($match, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::stringContains");
		$�spos = $GLOBALS['%s']->length;
		if($value !== null && _hx_index_of($value, $match, null) >= 0) {
			utest_Assert::isTrue(true, $msg, $pos);
		} else {
			utest_Assert::fail(utest_Assert_42($match, $msg, $pos, $value), $pos);
		}
		$GLOBALS['%s']->pop();
	}
	static function stringSequence($sequence, $value, $msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::stringSequence");
		$�spos = $GLOBALS['%s']->length;
		if(null === $value) {
			utest_Assert::fail((($msg === null) ? "null argument value" : $msg), $pos);
			{
				$GLOBALS['%s']->pop();
				return;
			}
		}
		$p = 0;
		{
			$_g = 0;
			while($_g < $sequence->length) {
				$s = $sequence[$_g];
				++$_g;
				$p2 = _hx_index_of($value, $s, $p);
				if($p2 < 0) {
					if($msg === null) {
						$msg = "expected '" . $s . "' after ";
						if($p > 0) {
							$cut = _hx_substr($value, 0, $p);
							if(strlen($cut) > 30) {
								$cut = "..." . _hx_substr($cut, -27, null);
							}
							$msg .= " '" . $cut . "'";
							unset($cut);
						} else {
							$msg .= " begin";
						}
					}
					utest_Assert::fail($msg, $pos);
					{
						$GLOBALS['%s']->pop();
						return;
					}
				}
				$p = $p2 + strlen($s);
				unset($s,$p2);
			}
		}
		utest_Assert::isTrue(true, $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function fail($msg, $pos) {
		$GLOBALS['%s']->push("utest.Assert::fail");
		$�spos = $GLOBALS['%s']->length;
		if($msg === null) {
			$msg = "failure expected";
		}
		utest_Assert::isTrue(false, $msg, $pos);
		$GLOBALS['%s']->pop();
	}
	static function warn($msg) {
		$GLOBALS['%s']->push("utest.Assert::warn");
		$�spos = $GLOBALS['%s']->length;
		utest_Assert::$results->add(utest_Assertation::Warning($msg));
		$GLOBALS['%s']->pop();
	}
	static function createAsync($f, $timeout) { return call_user_func_array(self::$createAsync, array($f, $timeout)); }
	public static $createAsync = null;
	static function createEvent($f, $timeout) { return call_user_func_array(self::$createEvent, array($f, $timeout)); }
	public static $createEvent = null;
	static function typeToString($t) {
		$GLOBALS['%s']->push("utest.Assert::typeToString");
		$�spos = $GLOBALS['%s']->length;
		try {
			$_t = Type::getClass($t);
			if($_t !== null) {
				$t = $_t;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		try {
			{
				$�tmp = Type::getClassName($t);
				$GLOBALS['%s']->pop();
				return $�tmp;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e2 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		try {
			$_t = Type::getEnum($t);
			if($_t !== null) {
				$t = $_t;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e3 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		try {
			{
				$�tmp = Type::getEnumName($t);
				$GLOBALS['%s']->pop();
				return $�tmp;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e4 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		try {
			{
				$�tmp = Std::string(Type::typeof($t));
				$GLOBALS['%s']->pop();
				return $�tmp;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e5 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		try {
			{
				$�tmp = Std::string($t);
				$GLOBALS['%s']->pop();
				return $�tmp;
			}
		}catch(Exception $�e) {
			$_ex_ = ($�e instanceof HException) ? $�e->e : $�e;
			$e6 = $_ex_;
			{
				$GLOBALS['%e'] = new _hx_array(array());
				while($GLOBALS['%s']->length >= $�spos) {
					$GLOBALS['%e']->unshift($GLOBALS['%s']->pop());
				}
				$GLOBALS['%s']->push($GLOBALS['%e'][0]);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return "<unable to retrieve type name>";
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'utest.Assert'; }
}
utest_Assert::$createAsync = array(new _hx_lambda(array(), "utest_Assert_43"), 'execute');
utest_Assert::$createEvent = array(new _hx_lambda(array(), "utest_Assert_44"), 'execute');
function utest_Assert_0(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_1(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_2(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_3(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_4(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_5(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "array[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_6(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_7(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_8(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$ebytes, &$expected, &$i, &$isanonym, &$status, &$texpected, &$tvalue, &$value, &$vbytes) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_9(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@285");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$�tmp = $expected->keys();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_10(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$keys, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@286");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$�tmp = $value->keys();
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_11(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$keys, &$status, &$texpected, &$tvalue, &$value, &$vkeys) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_12(&$_g, &$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$key, &$keys, &$path, &$status, &$texpected, &$tvalue, &$value, &$vkeys) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "hash[" . $key . "]";
	} else {
		return $path . "[" . $key . "]";
	}
}
function utest_Assert_13(&$_g, &$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$key, &$keys, &$path, &$status, &$texpected, &$tvalue, &$value, &$vkeys) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_14(&$c, &$cexpected, &$cvalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@307");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return $expected;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_15(&$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@308");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return $value;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_16(&$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_17(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "iterator[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_18(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_19(&$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_20(&$_g, &$_g1, &$c, &$cexpected, &$cvalue, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "iterable[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_21(&$_g, &$c, &$cexpected, &$cvalue, &$expected, &$field, &$fields, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return $field;
	} else {
		return $path . "." . $field;
	}
}
function utest_Assert_22(&$e, &$eexpected, &$evalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_23(&$e, &$eexpected, &$evalue, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_24(&$_g, &$_g1, &$e, &$eexpected, &$eparams, &$evalue, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vparams) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "enum[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_25(&$_g, &$_g1, &$e, &$eexpected, &$eparams, &$evalue, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vparams) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_26(&$_g, &$expected, &$field, &$fields, &$isanonym, &$path, &$status, &$texpected, &$tfields, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return $field;
	} else {
		return $path . "." . $field;
	}
}
function utest_Assert_27(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_28(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@423");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return $expected;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_29(&$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::sameAs@424");
		$�spos2 = $GLOBALS['%s']->length;
		{
			$GLOBALS['%s']->pop();
			return $value;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_30(&$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_31(&$_g, &$_g1, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "iterator[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_32(&$_g, &$_g1, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_33(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_34(&$evalues, &$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($status->path === "") {
		return "";
	} else {
		return " for field " . $status->path;
	}
}
function utest_Assert_35(&$_g, &$_g1, &$evalues, &$expected, &$i, &$isanonym, &$path, &$status, &$texpected, &$tvalue, &$value, &$vvalues) {
	$�spos = $GLOBALS['%s']->length;
	if($path === "") {
		return "iterable[" . $i . "]";
	} else {
		return $path . "[" . $i . "]";
	}
}
function utest_Assert_36(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	throw new HException("Unable to compare two unknown types");
}
function utest_Assert_37(&$expected, &$isanonym, &$status, &$texpected, &$tvalue, &$value) {
	$�spos = $GLOBALS['%s']->length;
	throw new HException("Unable to compare values: " . utest_Assert::q($expected) . " and " . utest_Assert::q($value));
}
function utest_Assert_38(&$expected, &$msg, &$pos, &$recursive, &$status, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($msg === null) {
		return $status->error;
	} else {
		return $msg;
	}
}
function utest_Assert_39(&$msg, &$pos, &$possibilities, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($msg === null) {
		return "value " . utest_Assert::q($value) . " not found in the expected possibilities " . $possibilities;
	} else {
		return $msg;
	}
}
function utest_Assert_40(&$match, &$msg, &$pos, &$values) {
	$�spos = $GLOBALS['%s']->length;
	if($msg === null) {
		return "values " . utest_Assert::q($values) . " do not contain " . $match;
	} else {
		return $msg;
	}
}
function utest_Assert_41(&$match, &$msg, &$pos, &$values) {
	$�spos = $GLOBALS['%s']->length;
	if($msg === null) {
		return "values " . utest_Assert::q($values) . " do contain " . $match;
	} else {
		return $msg;
	}
}
function utest_Assert_42(&$match, &$msg, &$pos, &$value) {
	$�spos = $GLOBALS['%s']->length;
	if($msg === null) {
		return "value " . utest_Assert::q($value) . " does not contain " . utest_Assert::q($match);
	} else {
		return $msg;
	}
}
function utest_Assert_43($f, $timeout) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::typeToString@663");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = array(new _hx_lambda(array(&$f, &$timeout), "utest_Assert_45"), 'execute');
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_44($f, $timeout) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::typeToString@674");
		$�spos = $GLOBALS['%s']->length;
		{
			$�tmp = array(new _hx_lambda(array(&$f, &$timeout), "utest_Assert_46"), 'execute');
			$GLOBALS['%s']->pop();
			return $�tmp;
		}
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_45(&$f, &$timeout) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::typeToString@664");
		$�spos2 = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
}
function utest_Assert_46(&$f, &$timeout, $e) {
	$�spos = $GLOBALS['%s']->length;
	{
		$GLOBALS['%s']->push("utest.Assert::typeToString@675");
		$�spos2 = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}
}
