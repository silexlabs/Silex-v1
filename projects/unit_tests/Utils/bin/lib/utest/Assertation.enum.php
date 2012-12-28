<?php

class utest_Assertation extends Enum {
	public static function AsyncError($e, $stack) { return new utest_Assertation("AsyncError", 6, array($e, $stack)); }
	public static function Error($e, $stack) { return new utest_Assertation("Error", 2, array($e, $stack)); }
	public static function Failure($msg, $pos) { return new utest_Assertation("Failure", 1, array($msg, $pos)); }
	public static function SetupError($e, $stack) { return new utest_Assertation("SetupError", 3, array($e, $stack)); }
	public static function Success($pos) { return new utest_Assertation("Success", 0, array($pos)); }
	public static function TeardownError($e, $stack) { return new utest_Assertation("TeardownError", 4, array($e, $stack)); }
	public static function TimeoutError($missedAsyncs, $stack) { return new utest_Assertation("TimeoutError", 5, array($missedAsyncs, $stack)); }
	public static function Warning($msg) { return new utest_Assertation("Warning", 7, array($msg)); }
	public static $__constructors = array(6 => 'AsyncError', 2 => 'Error', 1 => 'Failure', 3 => 'SetupError', 0 => 'Success', 4 => 'TeardownError', 5 => 'TimeoutError', 7 => 'Warning');
	}
