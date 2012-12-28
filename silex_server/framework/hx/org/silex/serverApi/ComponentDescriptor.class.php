<?php
require_once dirname(__FILE__).'/../../../ComponentDescriptor.extern.php';

class org_silex_serverApi_ComponentDescriptor {
	public function __construct($descriptor = null) {
		if(!php_Boot::$skip_constructor) {
		if(($this->componentDescriptorExtern = $descriptor) === null) {
			$this->componentDescriptorExtern = new ComponentDescriptor();
		}
	}}
	public function setProperties($value) {
		$this->componentDescriptorExtern->properties = php_Lib::associativeArrayOfHash($value);
		return $value;
	}
	public function getProperties() {
		return php_Lib::hashOfAssociativeArray($this->componentDescriptorExtern->properties);
	}
	public function setSpecificEditorUrl($value) {
		return $this->componentDescriptorExtern->specificEditorUrl = $value;
	}
	public function getSpecificEditorUrl() {
		return $this->componentDescriptorExtern->specificEditorUrl;
	}
	public function setComponentRoot($value) {
		return $this->componentDescriptorExtern->componentRoot = $value;
	}
	public function getComponentRoot() {
		return $this->componentDescriptorExtern->componentRoot;
	}
	public function setClassName($value) {
		return $this->componentDescriptorExtern->className = $value;
	}
	public function setMetaData($value) {
		$this->componentDescriptorExtern->metaData = php_Lib::associativeArrayOfHash($value);
		return $value;
	}
	public function getMetaData() {
		return php_Lib::hashOfAssociativeArray($this->componentDescriptorExtern->metaData);
	}
	public function getClassName() {
		return $this->componentDescriptorExtern->className;
	}
	public function setHTML5Url($value) {
		return $this->componentDescriptorExtern->html5Url = $value;
	}
	public function getHTML5Url() {
		return $this->componentDescriptorExtern->html5Url;
	}
	public function setAs2Url($value) {
		return $this->componentDescriptorExtern->as2Url = $value;
	}
	public function getAs2Url() {
		return $this->componentDescriptorExtern->as2Url;
	}
	public function setComponentName($value) {
		return $this->componentDescriptorExtern->componentName = $value;
	}
	public function getComponentName() {
		return $this->componentDescriptorExtern->componentName;
	}
	public $properties;
	public $specificEditorUrl;
	public $componentRoot;
	public $metaData;
	public $className;
	public $html5Url;
	public $as2Url;
	public $componentName;
	public $componentDescriptorExtern;
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
	static $__properties__ = array("set_componentName" => "setComponentName","get_componentName" => "getComponentName","set_as2Url" => "setAs2Url","get_as2Url" => "getAs2Url","set_html5Url" => "setHTML5Url","get_html5Url" => "getHTML5Url","set_className" => "setClassName","get_className" => "getClassName","set_metaData" => "setMetaData","get_metaData" => "getMetaData","set_componentRoot" => "setComponentRoot","get_componentRoot" => "getComponentRoot","set_specificEditorUrl" => "setSpecificEditorUrl","get_specificEditorUrl" => "getSpecificEditorUrl","set_properties" => "setProperties","get_properties" => "getProperties");
	function __toString() { return 'org.silex.serverApi.ComponentDescriptor'; }
}
