<?php

class org_silex_publication_ActionModel {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->parameters = new HList();
	}}
	public $functionName;
	public $modifier;
	public $parameters;
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
	function __toString() { return 'org.silex.publication.ActionModel'; }
}
