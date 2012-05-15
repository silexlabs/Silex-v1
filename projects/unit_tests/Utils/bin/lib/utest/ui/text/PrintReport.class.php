<?php

class utest_ui_text_PrintReport extends utest_ui_text_PlainTextReport {
	public function __construct($runner, $useTrace) {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("utest.ui.text.PrintReport::new");
		$»spos = $GLOBALS['%s']->length;
		if(null === $useTrace) {
			$useTrace = false;
		}
		$this->useTrace = $useTrace;
		parent::__construct($runner,(isset($this->_handler) ? $this->_handler: array($this, "_handler")));
		if(php_Lib::isCli()) {
			$this->newline = "\x0A";
			$this->indent = "  ";
		} else {
			$this->newline = "<br>";
			$this->indent = "&nbsp;&nbsp;";
		}
		$GLOBALS['%s']->pop();
	}}
	public $useTrace;
	public function _handler($report) {
		$GLOBALS['%s']->push("utest.ui.text.PrintReport::_handler");
		$»spos = $GLOBALS['%s']->length;
		if($this->useTrace) {
			$this->_trace($report->getResults());
		} else {
			$this->_print($report->getResults());
		}
		$GLOBALS['%s']->pop();
	}
	public function _trace($s) {
		$GLOBALS['%s']->push("utest.ui.text.PrintReport::_trace");
		$»spos = $GLOBALS['%s']->length;
		$s = str_replace("  ", $this->indent, $s);
		$s = str_replace("\x0A", $this->newline, $s);
		haxe_Log::trace($s, _hx_anonymous(array("fileName" => "PrintReport.hx", "lineNumber" => 66, "className" => "utest.ui.text.PrintReport", "methodName" => "_trace")));
		$GLOBALS['%s']->pop();
	}
	public function _print($s) {
		$GLOBALS['%s']->push("utest.ui.text.PrintReport::_print");
		$»spos = $GLOBALS['%s']->length;
		php_Lib::hprint($s);
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
	function __toString() { return 'utest.ui.text.PrintReport'; }
}
