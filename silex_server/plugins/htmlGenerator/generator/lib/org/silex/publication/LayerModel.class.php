<?php

class org_silex_publication_LayerModel {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->subLayers = new HList();
		$this->name = "";
	}}
	public $subLayers;
	public $name;
	public function getSubLayerNamed($name) {
		if(null == $this->subLayers) throw new HException('null iterable');
		$»it = $this->subLayers->iterator();
		while($»it->hasNext()) {
			$sl = $»it->next();
			if($sl->id === $name) {
				return $sl;
			}
		}
		return null;
	}
	public function save($basePath) {
		$path = $basePath . "/" . $this->name . ".xml";
		$fileOut = php_io_File::write($path, false);
		$fileOut->writeString(org_silex_publication_LayerParser::layer2XML($this)->toString());
		$fileOut->close();
		return true;
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
	static function load($basePath, $layerName) {
		$path = $basePath . "/" . $layerName . ".xml";
		$tmpLayer = org_silex_publication_LayerParser::xml2Layer(Xml::parse(php_io_File::getContent($path)));
		$tmpLayer->name = $layerName;
		$tmpLayer->subLayers = $tmpLayer->subLayers;
		return $tmpLayer;
	}
	function __toString() { return 'org.silex.publication.LayerModel'; }
}
