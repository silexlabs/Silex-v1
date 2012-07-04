<?php

class org_silex_publication_SubLayerModel {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->id = "";
		$this->zIndex = 0;
		$this->components = new HList();
	}}
	public $id;
	public $zIndex;
	public $components;
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
	function __toString() { return 'org.silex.publication.SubLayerModel'; }
}
