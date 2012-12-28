<?php
require_once dirname(__FILE__).'/../../../plugin_manager.extern.php';

class org_silex_serverApi_PluginManager {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->pluginManagerExtern = new plugin_manager();
	}}
	public $pluginManagerExtern;
	public function createActivePlugins($conf, $hookManager) {
		$this->pluginManagerExtern->createActivePlugins(php_Lib::associativeArrayOfHash($conf), Reflect::field(Type::getClass($hookManager), "externInstance"));
	}
	public function createPlugin($pluginName, $conf) {
		return $this->pluginManagerExtern->createPlugin($pluginName, php_Lib::associativeArrayOfHash($conf));
	}
	public function listActivatedPlugins($conf) {
		return new _hx_array($this->pluginManagerExtern->listActivatedPlugins(php_Lib::associativeArrayOfHash($conf)));
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
	function __toString() { return 'org.silex.serverApi.PluginManager'; }
}
