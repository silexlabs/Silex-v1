<?php

class org_silex_serverApi_ComponentManager {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->componentManagerExtern = new ComponentManager();
	}}
	public $componentManagerExtern;
	public function getComponentDescriptors() {
		$tmp = $this->componentManagerExtern->getComponentDescriptors();
		$tmp = array_values($tmp);
		$res = new _hx_array(array());
		{
			$_g = 0; $_g1 = new _hx_array($tmp);
			while($_g < $_g1->length) {
				$el = $_g1[$_g];
				++$_g;
				$res->push(new org_silex_serverApi_ComponentDescriptor($el));
				unset($el);
			}
		}
		return $res;
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
	function __toString() { return 'org.silex.serverApi.ComponentManager'; }
}
