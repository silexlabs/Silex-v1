<?php

class org_silex_ui_components_buttons_LabelButton extends org_silex_ui_components_buttons_ButtonBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
		$this->centeredHoriz = false;
		$this->buttonLabelNormal = "label";
		$this->buttonLabelSelect = "<b>label</b>";
		$this->buttonLabelOver = "<u>label</u>";
		$this->buttonLabelPress = "<b>label</b>";
		$this->autoSize = true;
		$this->wordWrap = false;
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton:hover", "color: red");
	}}
	public $centeredHoriz;
	public $buttonLabelNormal;
	public $buttonLabelSelect;
	public $buttonLabelOver;
	public $buttonLabelPress;
	public $autoSize;
	public $wordWrap;
	public function returnHTML() {
		return "<div class='labelButton'>" . $this->buttonLabelNormal . "</div>";
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
	function __toString() { return 'org.silex.ui.components.buttons.LabelButton'; }
}
