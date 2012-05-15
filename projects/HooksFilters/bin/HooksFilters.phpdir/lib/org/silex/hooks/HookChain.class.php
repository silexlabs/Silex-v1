<?php

class org_silex_hooks_HookChain {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("org.silex.hooks.HookChain::new");
		$�spos = $GLOBALS['%s']->length;
		$this->hooks = new _hx_array(array());
		$GLOBALS['%s']->pop();
	}}
	public $hooks;
	public function callHooks($value) {
		$GLOBALS['%s']->push("org.silex.hooks.HookChain::callHooks");
		$�spos = $GLOBALS['%s']->length;
		$_g = 0; $_g1 = $this->hooks;
		while($_g < $_g1->length) {
			$hookRecord = $_g1[$_g];
			++$_g;
			$hookRecord->hook($value);
			unset($hookRecord);
		}
		$GLOBALS['%s']->pop();
	}
	public function addHook($hook, $priority) {
		$GLOBALS['%s']->push("org.silex.hooks.HookChain::addHook");
		$�spos = $GLOBALS['%s']->length;
		{
			$_g1 = 0; $_g = $this->hooks->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				if(_hx_array_get($this->hooks, $i)->priority >= $priority) {
					$this->hooks->insert($i, _hx_anonymous(array("priority" => $priority, "hook" => $hook)));
					{
						$GLOBALS['%s']->pop();
						return;
					}
				}
				unset($i);
			}
		}
		$this->hooks->push(_hx_anonymous(array("priority" => $priority, "hook" => $hook)));
		$GLOBALS['%s']->pop();
	}
	public function removeHook($hook) {
		$GLOBALS['%s']->push("org.silex.hooks.HookChain::removeHook");
		$�spos = $GLOBALS['%s']->length;
		$_g = 0; $_g1 = $this->hooks;
		while($_g < $_g1->length) {
			$hookRecord = $_g1[$_g];
			++$_g;
			if($hookRecord->hook === $hook || Reflect::compareMethods((isset($hookRecord->hook) ? $hookRecord->hook: array($hookRecord, "hook")), $hook)) {
				$this->hooks->remove($hookRecord);
			}
			unset($hookRecord);
		}
		$GLOBALS['%s']->pop();
	}
	public function __call($m, $a) {
		if(isset($this->$m) && is_callable($this->$m))
			return call_user_func_array($this->$m, $a);
		else if(isset($this->�dynamics[$m]) && is_callable($this->�dynamics[$m]))
			return call_user_func_array($this->�dynamics[$m], $a);
		else if('toString' == $m)
			return $this->__toString();
		else
			throw new HException('Unable to call �'.$m.'�');
	}
	function __toString() { return 'org.silex.hooks.HookChain'; }
}
