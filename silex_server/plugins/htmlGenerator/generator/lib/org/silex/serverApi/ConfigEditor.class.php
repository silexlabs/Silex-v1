<?php
require_once dirname(__FILE__).'/../../../config_editor.extern.php';

class org_silex_serverApi_ConfigEditor {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->configEditorExtern = new config_editor();
	}}
	public $configEditorExtern;
	public function updateConfigFile($filePath, $fileFormat, $dataToMerge) {
		return $this->configEditorExtern->updateConfigFile($filePath, $fileFormat, php_Lib::associativeArrayOfHash($dataToMerge));
	}
	public function readConfigFile($filePath, $fileFormat) {
		return php_Lib::hashOfAssociativeArray($this->configEditorExtern->readConfigFile($filePath, $fileFormat));
	}
	public function mergeConfFilesIntoFlashvars($filesList) {
		return new _hx_array($this->configEditorExtern->mergeConfFilesIntoFlashvars(php_Lib::toPhpArray($filesList)));
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
	function __toString() { return 'org.silex.serverApi.ConfigEditor'; }
}
