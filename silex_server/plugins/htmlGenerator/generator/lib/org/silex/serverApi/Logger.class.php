<?php

class org_silex_serverApi_Logger {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->loggerExtern = new logger();
	}}
	public $loggerExtern;
	public function getLogLevel($loggerName) {
		return $this->loggerExtern->getLogLevel($loggerName);
	}
	public function debug($message) {
		$this->loggerExtern->debug($message);
		return;
	}
	public function info($message) {
		$this->loggerExtern->info($message);
		return;
	}
	public function err($message) {
		$this->loggerExtern->err($message);
		return;
	}
	public function crit($message) {
		$this->loggerExtern->crit($message);
		return;
	}
	public function alert($message) {
		$this->loggerExtern->alert($message);
		return;
	}
	public function emerg($message) {
		$this->loggerExtern->emerg($message);
		return;
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
	function __toString() { return 'org.silex.serverApi.Logger'; }
}
