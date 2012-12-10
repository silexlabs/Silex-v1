<?php

class org_silex_publication_ComponentModel {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->properties = new Hash();
		$this->actions = new HList();
	}}
	public $as2Url;
	public $html5Url;
	public $className;
	public $componentRoot;
	public $metaData;
	public $properties;
	public $actions;
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
	static $FIELD_PLAYER_NAME = "playerName";
	function __toString() { return 'org.silex.publication.ComponentModel'; }
}
