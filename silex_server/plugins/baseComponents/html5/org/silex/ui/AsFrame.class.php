<?php

class org_silex_ui_AsFrame extends org_silex_ui_UiBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $clickable;
	public $scale;
	public $htmlText;
	public $embededObject;
	public $location;
	public $backgroundVisible;
	public function returnHTML() {
		return "<iframe frameborder='0' style='width:" . $this->width . "px;height:" . $this->height . "px;' src='" . $this->location . "'></iframe>";
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
	function __toString() { return 'org.silex.ui.AsFrame'; }
}
