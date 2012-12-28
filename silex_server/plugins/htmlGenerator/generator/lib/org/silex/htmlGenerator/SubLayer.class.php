<?php

class org_silex_htmlGenerator_SubLayer {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->initializedComponents = new _hx_array(array());
		$this->subLayerName = "";
		$this->layerName = "";
	}}
	public $initializedComponents;
	public $subLayerName;
	public $layerName;
	public function returnHTML() {
		$html = null;
		$html = "<div class=\"SILEXsubLayer\" id=\"" . $this->layerName . "-" . $this->subLayerName . "\" style=\"position:absolute;left:0px;top:0px\">";
		{
			$_g = 0; $_g1 = $this->initializedComponents;
			while($_g < $_g1->length) {
				$component = $_g1[$_g];
				++$_g;
				try {
					$html .= $component->componentInstance->getHTML();
				}catch(Exception $»e) {
					$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
					$e = $_ex_;
					{
						throw new HException($component->componentInstance->playerName . " " . Std::string($e));
					}
				}
				unset($e,$component);
			}
		}
		$html .= "</div>";
		return $html;
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
	function __toString() { return 'org.silex.htmlGenerator.SubLayer'; }
}
