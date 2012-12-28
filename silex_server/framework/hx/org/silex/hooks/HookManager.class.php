<?php

class org_silex_hooks_HookManager {
	public function __construct(){}
	static $hookChains;
	static function callHooks($chainID, $value) {
		if(org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->get($chainID)->callHooks($value);
		}
	}
	static function addHook($chainID, $hook, $priority) {
		if(!org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->set($chainID, new org_silex_hooks_HookChain());
		}
		org_silex_hooks_HookManager::$hookChains->get($chainID)->addHook($hook, $priority);
	}
	static function removeHook($chainID, $filter) {
		if(org_silex_hooks_HookManager::$hookChains->exists($chainID)) {
			org_silex_hooks_HookManager::$hookChains->get($chainID)->removeHook($filter);
		}
	}
	function __toString() { return 'org.silex.hooks.HookManager'; }
}
org_silex_hooks_HookManager::$hookChains = new Hash();
