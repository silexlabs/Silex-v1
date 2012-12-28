<?php

class php_Sys {
	public function __construct(){}
	static function args() {
		$GLOBALS['%s']->push("php.Sys::args");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Sys_0();
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getEnv($s) {
		$GLOBALS['%s']->push("php.Sys::getEnv");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = getenv($s);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function putEnv($s, $v) {
		$GLOBALS['%s']->push("php.Sys::putEnv");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = putenv($s . "=" . $v);
			$GLOBALS['%s']->pop();
			$裨mp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	static function sleep($seconds) {
		$GLOBALS['%s']->push("php.Sys::sleep");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = usleep($seconds * 1000000);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setTimeLocale($loc) {
		$GLOBALS['%s']->push("php.Sys::setTimeLocale");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = setlocale(LC_TIME, $loc) !== false;
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function getCwd() {
		$GLOBALS['%s']->push("php.Sys::getCwd");
		$製pos = $GLOBALS['%s']->length;
		$cwd = getcwd();
		$l = _hx_substr($cwd, -1, null);
		{
			$裨mp = $cwd . (php_Sys_1($cwd, $l));
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function setCwd($s) {
		$GLOBALS['%s']->push("php.Sys::setCwd");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = chdir($s);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function systemName() {
		$GLOBALS['%s']->push("php.Sys::systemName");
		$製pos = $GLOBALS['%s']->length;
		$s = php_uname("s");
		$p = null;
		if(($p = _hx_index_of($s, " ", null)) >= 0) {
			$裨mp = _hx_substr($s, 0, $p);
			$GLOBALS['%s']->pop();
			return $裨mp;
		} else {
			$GLOBALS['%s']->pop();
			return $s;
		}
		$GLOBALS['%s']->pop();
	}
	static function escapeArgument($arg) {
		$GLOBALS['%s']->push("php.Sys::escapeArgument");
		$製pos = $GLOBALS['%s']->length;
		$ok = true;
		{
			$_g1 = 0; $_g = strlen($arg);
			while($_g1 < $_g) {
				$i = $_g1++;
				switch(_hx_char_code_at($arg, $i)) {
				case 32:case 34:{
					$ok = false;
				}break;
				case 0:case 13:case 10:{
					$arg = _hx_substr($arg, 0, $i);
				}break;
				}
				unset($i);
			}
		}
		if($ok) {
			$GLOBALS['%s']->pop();
			return $arg;
		}
		{
			$裨mp = "\"" . _hx_explode("\"", $arg)->join("\\\"") . "\"";
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function command($cmd, $args) {
		$GLOBALS['%s']->push("php.Sys::command");
		$製pos = $GLOBALS['%s']->length;
		if($args !== null) {
			$cmd = php_Sys::escapeArgument($cmd);
			{
				$_g = 0;
				while($_g < $args->length) {
					$a = $args[$_g];
					++$_g;
					$cmd .= " " . php_Sys::escapeArgument($a);
					unset($a);
				}
			}
		}
		$result = 0;
		$output = "";
		system($cmd, $result);
		{
			$GLOBALS['%s']->pop();
			return $result;
		}
		$GLOBALS['%s']->pop();
	}
	static function hexit($code) {
		$GLOBALS['%s']->push("php.Sys::exit");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = exit($code);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function time() {
		$GLOBALS['%s']->push("php.Sys::time");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = microtime(true);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function cpuTime() {
		$GLOBALS['%s']->push("php.Sys::cpuTime");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = microtime(true) - $_SERVER['REQUEST_TIME'];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function executablePath() {
		$GLOBALS['%s']->push("php.Sys::executablePath");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = $_SERVER['SCRIPT_FILENAME'];
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function environment() {
		$GLOBALS['%s']->push("php.Sys::environment");
		$製pos = $GLOBALS['%s']->length;
		{
			$裨mp = php_Lib::hashOfAssociativeArray($_SERVER);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'php.Sys'; }
}
function php_Sys_0() {
		$GLOBALS['%s']->push('php.Sys:lambda_0');
		$製pos = $GLOBALS['%s']->length;
	if(array_key_exists("argv", $_SERVER)) {
		return new _hx_array(array_slice($_SERVER["argv"], 1));
	} else {
		return new _hx_array(array());
	}
}
function php_Sys_1(&$cwd, &$l) {
		$GLOBALS['%s']->push('php.Sys:lambda_1');
		$製pos = $GLOBALS['%s']->length;
	if($l === "/" || $l === "\\") {
		return "";
	} else {
		return "/";
	}
}
