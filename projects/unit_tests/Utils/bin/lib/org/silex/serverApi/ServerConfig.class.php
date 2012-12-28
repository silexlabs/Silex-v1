<?php
require_once dirname(__FILE__).'/../../../server_config.extern.php';

class org_silex_serverApi_ServerConfig {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::new");
		$»spos = $GLOBALS['%s']->length;
		$this->serverConfigInstance = new server_config();
		$GLOBALS['%s']->pop();
	}}
	public $serverConfigInstance;
	public $silexServerIni;
	public $silexClientIni;
	public $adminWriteOk;
	public $adminReadOk;
	public $userWriteOk;
	public $userReadOk;
	public $sepCharForDeeplinks;
	public function getSilexServerIni() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getSilexServerIni");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Lib::hashOfAssociativeArray($this->serverConfigInstance->silex_server_ini);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getSilexClientIni() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getSilexClientIni");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Lib::hashOfAssociativeArray($this->serverConfigInstance->silex_client_ini);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getAdminWriteOk() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getAdminWriteOk");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new _hx_array($this->serverConfigInstance->admin_write_ok);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getAdminReadOk() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getAdminReadOk");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new _hx_array($this->serverConfigInstance->admin_read_ok);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getUserWriteOk() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getUserWriteOk");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new _hx_array($this->serverConfigInstance->user_write_ok);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getUserReadOk() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getUserReadOk");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = new _hx_array($this->serverConfigInstance->user_read_ok);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getSepCharForDeeplinks() {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getSepCharForDeeplinks");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->serverConfigInstance->sepCharForDeeplinks;
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getContentFolderForPublication($id_publication) {
		$GLOBALS['%s']->push("org.silex.serverApi.ServerConfig::getContentFolderForPublication");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->serverConfigInstance->getContentFolderForPublication($id_publication);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
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
	function __toString() { return 'org.silex.serverApi.ServerConfig'; }
}
