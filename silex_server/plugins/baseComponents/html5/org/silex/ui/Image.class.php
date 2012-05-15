<?php

class org_silex_ui_Image extends org_silex_ui_UiBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $clickable;
	public $scale;
	public $useHandCursor;
	public $mask;
	public $scaleMode;
	public $visibleFrame_bool;
	public $shadow;
	public $shadowOffsetX;
	public $shadowOffsetY;
	public $_focusrect;
	public $tabChildren;
	public $fadeInStep;
	public function returnHTML() {
		if(strtolower(_hx_explode(".", $this->url)->pop()) !== "swf") {
			return "<img style='width:" . $this->width . "px;height:" . $this->height . "px; margin-top:0px; vertical-align:top;' src='" . $this->url . "'></img>";
		} else {
			return "<object scale=\"exactfit\" wmode=\"transparent\" width=\"" . $this->width . "\" height=\"" . $this->height . "\">\x0A\x09\x09\x09<param name=\"movie\" value=\"" . $this->url . "\">\x0A\x09\x09\x09<embed scale=\"exactfit\" wmode=\"transparent\" src=\"" . $this->url . "\" width=\"" . $this->width . "\" height=\"" . $this->height . "\">\x0A\x09\x09\x09</embed>\x0A\x09\x09\x09</object>";
		}
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
	function __toString() { return 'org.silex.ui.Image'; }
}
