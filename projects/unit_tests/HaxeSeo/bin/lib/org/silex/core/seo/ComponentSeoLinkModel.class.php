<?php

class org_silex_core_seo_ComponentSeoLinkModel {
	public function __construct() {
		if( !php_Boot::$skip_constructor ) {
		$this->keys = new _hx_array(array("description", "title", "deeplink"));
		;
	}}
	public $description;
	public $title;
	public $deeplink;
	public $keys;
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
	function __toString() { return 'org.silex.core.seo.ComponentSeoLinkModel'; }
}
