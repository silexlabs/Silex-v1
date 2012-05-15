<?php

class org_silex_ui_components_ComponentAnimated extends org_silex_ui_components_ComponentBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $followMouse;
	public $easingDuration;
	public $clickable;
	public $useHandCursor;
	public $delay;
	public $imageUrl;
	public $label;
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
	function __toString() { return 'org.silex.ui.components.ComponentAnimated'; }
}
