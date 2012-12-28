<?php

class org_silex_hooks_HookManager {
	public function __construct(){}
	static $hookChains;
	static function callHooks($chainID, $value) {
		$GLOBALS['%s']->push("org.silex.hooks.HookManager::callHooks");
		$»spos = $GLOBALS['%s']->length;
		if(org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->get($chainID)->callHooks($value);
		}
		$GLOBALS['%s']->pop();
	}
	static function addHook($chainID, $hook, $priority) {
		$GLOBALS['%s']->push("org.silex.hooks.HookManager::addHook");
		$»spos = $GLOBALS['%s']->length;
		if(!org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->set($chainID, new org_silex_hooks_HookChain());
		}
		org_silex_hooks_HookManager::$hookChains->get($chainID)->addHook($hook, $priority);
		$GLOBALS['%s']->pop();
	}
	static function removeHook($chainID, $filter) {
		$GLOBALS['%s']->push("org.silex.hooks.HookManager::removeHook");
		$»spos = $GLOBALS['%s']->length;
		if(org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->get($chainID)->removeHook($filter);
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'org.silex.hooks.HookManager'; }
}
{
	org_silex_hooks_HookManager::$hookChains = new Hash();
}
