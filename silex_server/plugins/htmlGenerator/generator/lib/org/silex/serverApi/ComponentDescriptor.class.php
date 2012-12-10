<?php
require_once dirname(__FILE__).'/../../../ComponentDescriptor.extern.php';

class org_silex_serverApi_ComponentDescriptor {
	public function __construct($descriptor) {
		if(!php_Boot::$skip_constructor) {
		if(($this->componentDescriptorExtern = $descriptor) === null) {
			$this->componentDescriptorExtern = new ComponentDescriptor();
		}
	}}
	public $componentDescriptorExtern;
	public $componentName;
	public $as2Url;
	public $html5Url;
	public $className;
	public $metaData;
	public $componentRoot;
	public $specificEditorUrl;
	public $properties;
	public function getComponentName() {
		return $this->componentDescriptorExtern->componentName;
	}
	public function setComponentName($value) {
		return $this->componentDescriptorExtern->componentName = $value;
	}
	public function getAs2Url() {
		return $this->componentDescriptorExtern->as2Url;
	}
	public function setAs2Url($value) {
		return $this->componentDescriptorExtern->as2Url = $value;
	}
	public function getHTML5Url() {
		return $this->componentDescriptorExtern->html5Url;
	}
	public function setHTML5Url($value) {
		return $this->componentDescriptorExtern->html5Url = $value;
	}
	public function getClassName() {
		return $this->componentDescriptorExtern->className;
	}
	public function getMetaData() {
		return php_Lib::hashOfAssociativeArray($this->componentDescriptorExtern->metaData);
	}
	public function setMetaData($value) {
		$this->componentDescriptorExtern->metaData = php_Lib::associativeArrayOfHash($value);
		return $value;
	}
	public function setClassName($value) {
		return $this->componentDescriptorExtern->className = $value;
	}
	public function getComponentRoot() {
		return $this->componentDescriptorExtern->componentRoot;
	}
	public function setComponentRoot($value) {
		return $this->componentDescriptorExtern->componentRoot = $value;
	}
	public function getSpecificEditorUrl() {
		return $this->componentDescriptorExtern->specificEditorUrl;
	}
	public function setSpecificEditorUrl($value) {
		return $this->componentDescriptorExtern->specificEditorUrl = $value;
	}
	public function getProperties() {
		return php_Lib::hashOfAssociativeArray($this->componentDescriptorExtern->properties);
	}
	public function setProperties($value) {
		$this->componentDescriptorExtern->properties = php_Lib::associativeArrayOfHash($value);
		return $value;
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
	function __toString() { return 'org.silex.serverApi.ComponentDescriptor'; }
}
