<?php
require_once dirname(__FILE__).'/../../../file_system_tools.extern.php';

class org_silex_serverApi_FileSystemTools {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->fileSystemToolsExtern = new file_system_tools();
	}}
	public function checkRights($filepath, $usertype, $action) {
		return $this->fileSystemToolsExtern->checkRights($filepath, $usertype, $action);
	}
	public function isAllowed($folder, $action, $allowNotExistingFiles = null) {
		return $this->fileSystemToolsExtern->isAllowed($folder, $action, $allowNotExistingFiles);
	}
	public function getAbsolutePath($path) {
		return $this->fileSystemToolsExtern->getAbsolutePath($path);
	}
	public function listFolderContent($folder, $isRecursive = null, $filter = null, $orderBy = null, $reverseOrder = null) {
		$nFilter = null;
		if($filter !== null) {
			$nFilter = php_Lib::toPhpArray($filter);
		} else {
			$nFilter = $filter;
		}
		return org_silex_serverApi_FileSystemItem::parseFolderContent($this->fileSystemToolsExtern->listFolderContent($folder, $isRecursive, $nFilter, $orderBy, $reverseOrder));
	}
	public function uploadItem($folder, $name, $session_id = null) {
		return $this->fileSystemToolsExtern->uploadItem($folder, $name, $session_id);
	}
	public function uploadFtpItem($folder, $name, $session_id = null) {
		return $this->fileSystemToolsExtern->uploadFtpItem($folder, $name, $session_id);
	}
	public function deleteFtpItem($folder, $name) {
		return $this->fileSystemToolsExtern->deleteFtpItem($folder, $name);
	}
	public function renameFtpItem($folder, $oldItemName, $newItemName) {
		return $this->fileSystemToolsExtern->renameFtpItem($folder, $oldItemName, $newItemName);
	}
	public function createFtpFolder($folder, $name) {
		return $this->fileSystemToolsExtern->createFtpFolder($folder, $name);
	}
	public function getFtpPath($folder) {
		return $this->fileSystemToolsExtern->getFtpPath($folder);
	}
	public function getFolderSize($folder) {
		return $this->fileSystemToolsExtern->getFolderSize($folder);
	}
	public function get_dir_size_info($path) {
		$res = new Hash();
		$tmp = php_Lib::hashOfAssociativeArray($this->fileSystemToolsExtern->get_dir_size_info($path));
		$res->set("size", Std::parseInt($tmp->get("size")));
		$res->set("count", Std::parseInt($tmp->get("count")));
		$res->set("dircount", Std::parseInt($tmp->get("dircount")));
		return $res;
	}
	public function readableFormatFileSize($size, $round = null) {
		return $this->fileSystemToolsExtern->readableFormatFileSize($size, $round);
	}
	public function writeToFile($xmlFileName, $xmlData) {
		return $this->fileSystemToolsExtern->writeToFile($xmlFileName, $xmlData);
	}
	public function isInFolder($filePath, $folderName) {
		return $this->fileSystemToolsExtern->isInFolder($filePath, $folderName);
	}
	public function sanitize($filePath, $allowNotExistingFiles = null) {
		return $this->fileSystemToolsExtern->sanitize($filePath, $allowNotExistingFiles);
	}
	public $fileSystemToolsExtern;
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
	static $writeAction;
	static $readAction;
	static $adminRole;
	static $userRole;
	static function getWriteAction() {
		return file_system_tools::WRITE_ACTION;
	}
	static function getReadAction() {
		return file_system_tools::READ_ACTION;
	}
	static function getAdminRole() {
		return file_system_tools::ADMIN_ROLE;
	}
	static function getUserRole() {
		return file_system_tools::USER_ROLE;
	}
	static $__properties__ = array("get_userRole" => "getUserRole","get_adminRole" => "getAdminRole","get_readAction" => "getReadAction","get_writeAction" => "getWriteAction");
	function __toString() { return 'org.silex.serverApi.FileSystemTools'; }
}
