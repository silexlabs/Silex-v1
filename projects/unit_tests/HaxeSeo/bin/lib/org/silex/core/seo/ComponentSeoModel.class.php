<?php

class org_silex_core_seo_ComponentSeoModel {
	public function __construct() {
		if( !php_Boot::$skip_constructor ) {
		$this->links = new _hx_array(array());
		$this->keys = new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "iconDeeplinkName", "iconPageName", "tags", "description", "urlBase", "xmlRootNodePath", "connectorName", "formName", "text"));
		;
	}}
	public $playerName;
	public $className;
	public $htmlEquivalent;
	public $iconIsIcon;
	public $iconDeeplinkName;
	public $iconPageName;
	public $tags;
	public $description;
	public $urlBase;
	public $xmlRootNodePath;
	public $connectorName;
	public $formName;
	public $text;
	public $keys;
	public $links;
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
	function __toString() { return 'org.silex.core.seo.ComponentSeoModel'; }
}
