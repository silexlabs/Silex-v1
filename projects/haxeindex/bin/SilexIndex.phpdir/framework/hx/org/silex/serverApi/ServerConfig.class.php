<?php
require_once dirname(__FILE__).'/../../../server_config.extern.php';

class org_silex_serverApi_ServerConfig {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->serverConfigInstance = new server_config();
	}}
	public function getContentFolderForPublication($id_publication) {
		return $this->serverConfigInstance->getContentFolderForPublication($id_publication);
	}
	public function getSepCharForDeeplinks() {
		return $this->serverConfigInstance->sepCharForDeeplinks;
	}
	public function getUserReadOk() {
		return new _hx_array($this->serverConfigInstance->user_read_ok);
	}
	public function getUserWriteOk() {
		return new _hx_array($this->serverConfigInstance->user_write_ok);
	}
	public function getAdminReadOk() {
		return new _hx_array($this->serverConfigInstance->admin_read_ok);
	}
	public function getAdminWriteOk() {
		return new _hx_array($this->serverConfigInstance->admin_write_ok);
	}
	public function getSilexClientIni() {
		return php_Lib::hashOfAssociativeArray($this->serverConfigInstance->silex_client_ini);
	}
	public function getSilexServerIni() {
		return php_Lib::hashOfAssociativeArray($this->serverConfigInstance->silex_server_ini);
	}
	public $sepCharForDeeplinks;
	public $userReadOk;
	public $userWriteOk;
	public $adminReadOk;
	public $adminWriteOk;
	public $silexClientIni;
	public $silexServerIni;
	public $serverConfigInstance;
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
	static $__properties__ = array("get_silexServerIni" => "getSilexServerIni","get_silexClientIni" => "getSilexClientIni","get_adminWriteOk" => "getAdminWriteOk","get_adminReadOk" => "getAdminReadOk","get_userWriteOk" => "getUserWriteOk","get_userReadOk" => "getUserReadOk","get_sepCharForDeeplinks" => "getSepCharForDeeplinks");
	function __toString() { return 'org.silex.serverApi.ServerConfig'; }
}
