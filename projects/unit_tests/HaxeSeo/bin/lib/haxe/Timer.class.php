<?php

class haxe_Timer {
	public function __construct(){}
	static function measure($f, $pos) {
		$GLOBALS['%s']->push("haxe.Timer::measure");
		$»spos = $GLOBALS['%s']->length;
		$t0 = haxe_Timer::stamp();
		$r = call_user_func($f);
		haxe_Log::trace(haxe_Timer::stamp() - $t0 . "s", $pos);
		{
			$GLOBALS['%s']->pop();
			return $r;
		}
		$GLOBALS['%s']->pop();
	}
	static function stamp() {
		$GLOBALS['%s']->push("haxe.Timer::stamp");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Sys::time();
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'haxe.Timer'; }
}
