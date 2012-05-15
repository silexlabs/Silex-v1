<?php

class org_silex_htmlGenerator_Deeplink {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->publication = "";
		$this->layers = new _hx_array(array());
	}}
	public $publication;
	public $layers;
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
	static function parseURL($url) {
		$res = new org_silex_htmlGenerator_Deeplink();
		$url = _hx_array_get(_hx_explode("&", $url), 0);
		if(_hx_char_at($url, strlen($url) - 1) === "/") {
			$url = _hx_substr($url, 0, strlen($url) - 1);
		}
		if(_hx_char_at($url, 0) === "/") {
			$url = _hx_substr($url, 1, strlen($url) - 1);
		}
		$arr = _hx_explode("/", $url);
		$res->publication = $arr->shift();
		$res->layers = $arr;
		return $res;
	}
	function __toString() { return 'org.silex.htmlGenerator.Deeplink'; }
}
