<?php
require_once dirname(__FILE__).'/../../../server_content.extern.php';

class org_silex_serverApi_ServerContent {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->serverContentExtern = new server_content();
	}}
	public $serverContentExtern;
	public function getLanguagesList() {
		return $this->serverContentExtern->getLanguagesList();
	}
	public function listLanguageFolderContent() {
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->serverContentExtern->listLanguageFolderContent());
	}
	public function listWebsiteFolderContent($id_site) {
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->serverContentExtern->listWebsiteFolderContent($id_site));
	}
	public function listToolsFolderContent($path) {
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->serverContentExtern->listToolsFolderContent($path));
	}
	public function listFtpFolderContent($path, $isRecursive) {
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->serverContentExtern->listFtpFolderContent($path, $isRecursive));
	}
	public function listFolderContent($path, $isRecursive) {
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->serverContentExtern->listFolderContent($path, $isRecursive));
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
	function __toString() { return 'org.silex.serverApi.ServerContent'; }
}
