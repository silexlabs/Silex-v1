<?php

class Std {
	public function __construct(){}
	static function is($v, $t) {
		$GLOBALS['%s']->push("Std::is");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_instanceof($v, $t);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function string($s) {
		$GLOBALS['%s']->push("Std::string");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = _hx_string_rec($s, "");
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function int($x) {
		$GLOBALS['%s']->push("Std::int");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = intval($x);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseInt($x) {
		$GLOBALS['%s']->push("Std::parseInt");
		$製pos = $GLOBALS['%s']->length;
		if(!is_numeric($x)) {
			$matches = null;
			preg_match("/\\d+/", $x, $matches);
			{
				$裨mp = Std_0($matches, $x);
				$GLOBALS['%s']->pop();
				return $裨mp;
			}
		} else {
			$裨mp = Std_1($x);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function parseFloat($x) {
		$GLOBALS['%s']->push("Std::parseFloat");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = is_numeric($x) ? floatval($x) : acos(1.01);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function random($x) {
		$GLOBALS['%s']->push("Std::random");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = rand(0, $x - 1);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Std'; }
}
function Std_0(&$matches, &$x) {
		$GLOBALS['%s']->push('Std:lambda_0');
		$製pos = $GLOBALS['%s']->length;
	if(count($matches) === 0) {
		return null;
	} else {
		return intval($matches[0]);
	}
}
function Std_1(&$x) {
		$GLOBALS['%s']->push('Std:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	if(strtolower(_hx_substr($x, 0, 2)) === "0x") {
		return (int) hexdec(substr($x, 2));
	} else {
		return intval($x);
	}
}
