<?php

class org_silex_serverApi_HookManager {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		org_silex_serverApi_HookManager::$externInstance = HookManager::getInstance();
	}}
	public function callHooks($hookName, $paramsArray) {
		org_silex_serverApi_HookManager::$externInstance->callHooks($hookName, php_Lib::toPhpArray($paramsArray));
	}
	public function addHook($hookName, $callBack) {
		org_silex_serverApi_HookManager::$externInstance->addHook($hookName, $callBack);
	}
	static $externInstance;
	static $managerInstance;
	static function getInstance() {
		if(org_silex_serverApi_HookManager::$managerInstance === null) {
			org_silex_serverApi_HookManager::$managerInstance = new org_silex_serverApi_HookManager();
		}
		return org_silex_serverApi_HookManager::$managerInstance;
	}
	function __toString() { return 'org.silex.serverApi.HookManager'; }
}
