<?php

class Reflect {
	public function __construct(){}
	static function hasField($o, $field) {
		$GLOBALS['%s']->push("Reflect::hasField");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_has_field($o, $field);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function field($o, $field) {
		$GLOBALS['%s']->push("Reflect::field");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_field($o, $field);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setField($o, $field, $value) {
		$GLOBALS['%s']->push("Reflect::setField");
		$製pos = $GLOBALS['%s']->length;
		$o->{$field} = $value;
		$GLOBALS['%s']->pop();
	}
	static function callMethod($o, $func, $args) {
		$GLOBALS['%s']->push("Reflect::callMethod");
		$製pos = $GLOBALS['%s']->length;
		if(is_string($o) && !is_array($func)) {
			{
				$裨mp = call_user_func_array(Reflect::field($o, $func), $args->蒼);
				$GLOBALS['%s']->pop();
				return $裨mp;
			}
		}
		{
			$裨mp = call_user_func_array(Reflect_0($args, $func, $o), Reflect_1($args, $func, $o));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function fields($o) {
		$GLOBALS['%s']->push("Reflect::fields");
		$製pos = $GLOBALS['%s']->length;
		if($o === null) {
			$裨mp = new _hx_array(array());
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		{
			$裨mp = Reflect_2($o);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function isFunction($f) {
		$GLOBALS['%s']->push("Reflect::isFunction");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = (is_array($f) && is_callable($f)) || _hx_is_lambda($f) || is_array($f) && _hx_has_field($f[0], $f[1]) && $f[1] !== "length";
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function compare($a, $b) {
		$GLOBALS['%s']->push("Reflect::compare");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = Reflect_3($a, $b);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function compareMethods($f1, $f2) {
		$GLOBALS['%s']->push("Reflect::compareMethods");
		$製pos = $GLOBALS['%s']->length;
		if(is_array($f1) && is_array($f1)) {
			$裨mp = $f1[0] === $f2[0] && $f1[1] == $f2[1];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		if(is_string($f1) && is_string($f2)) {
			$裨mp = _hx_equal($f1, $f2);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		{
			$GLOBALS['%s']->pop();
			return false;
		}
		$GLOBALS['%s']->pop();
	}
	static function isObject($v) {
		$GLOBALS['%s']->push("Reflect::isObject");
		$製pos = $GLOBALS['%s']->length;
		if($v === null) {
			$GLOBALS['%s']->pop();
			return false;
		}
		if(is_object($v)) {
			$裨mp = $v instanceof _hx_anonymous || Type::getClass($v) !== null;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		if(is_string($v) && !_hx_is_lambda($v)) {
			$GLOBALS['%s']->pop();
			return true;
		}
		{
			$GLOBALS['%s']->pop();
			return false;
		}
		$GLOBALS['%s']->pop();
	}
	static function deleteField($o, $f) {
		$GLOBALS['%s']->push("Reflect::deleteField");
		$製pos = $GLOBALS['%s']->length;
		if(!_hx_has_field($o, $f)) {
			$GLOBALS['%s']->pop();
			return false;
		}
		if(isset($o->蜿ynamics[$f])) unset($o->蜿ynamics[$f]); else unset($o->$f);
		{
			$GLOBALS['%s']->pop();
			return true;
		}
		$GLOBALS['%s']->pop();
	}
	static function copy($o) {
		$GLOBALS['%s']->push("Reflect::copy");
		$製pos = $GLOBALS['%s']->length;
		if(is_string($o)) {
			$GLOBALS['%s']->pop();
			return $o;
		}
		$o2 = _hx_anonymous(array());
		{
			$_g = 0; $_g1 = Reflect::fields($o);
			while($_g < $_g1->length) {
				$f = $_g1[$_g];
				++$_g;
				$o2->{$f} = Reflect::field($o, $f);
				unset($f);
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $o2;
		}
		$GLOBALS['%s']->pop();
	}
	static function makeVarArgs($f) {
		$GLOBALS['%s']->push("Reflect::makeVarArgs");
		$製pos = $GLOBALS['%s']->length;
		return array(new _hx_lambda(array(&$f), '_hx_make_var_args'), 'execute');
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Reflect'; }
}
function Reflect_0(&$args, &$func, &$o) {
		$GLOBALS['%s']->push('Reflect:lambda_0');
		$製pos = $GLOBALS['%s']->length;
	if(is_callable($func)) {
		return $func;
	} else {
		return array($o, $func);
	}
}
function Reflect_1(&$args, &$func, &$o) {
		$GLOBALS['%s']->push('Reflect:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	if(null === $args) {
		return array();
	} else {
		return $args->蒼;
	}
}
function Reflect_2(&$o) {
		$GLOBALS['%s']->push('Reflect:lambda_2');
		$製pos = $GLOBALS['%s']->length;
	if($o instanceof _hx_array) {
		return new _hx_array(array('concat','copy','insert','iterator','length','join','pop','push','remove','reverse','shift','slice','sort','splice','toString','unshift'));
	} else {
		if(is_string($o)) {
			return new _hx_array(array('charAt','charCodeAt','indexOf','lastIndexOf','length','split','substr','toLowerCase','toString','toUpperCase'));
		} else {
			return new _hx_array(_hx_get_object_vars($o));
		}
	}
}
function Reflect_3(&$a, &$b) {
		$GLOBALS['%s']->push('Reflect:lambda_3');
		$製pos = $GLOBALS['%s']->length;
	if($a === $b) {
		return 0;
	} else {
		if($a > $b) {
			return 1;
		} else {
			return -1;
		}
	}
}
