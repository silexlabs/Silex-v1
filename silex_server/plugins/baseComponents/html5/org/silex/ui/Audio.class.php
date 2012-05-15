<?php

class org_silex_ui_Audio extends org_silex_ui_UiBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $scale;
	public $autoPlay;
	public $autoSize;
	public $loop;
	public $showNavigation;
	public $bufferSize;
	public $mute;
	public $volume;
	public $useHandCursor;
	public $fadeInStep;
	public function returnHTML() {
		$playerName = null;
		$autoPlay = null;
		$loop = null;
		$playerName = " name='" . $this->playerName . "' ";
		if($this->autoPlay) {
			$autoPlay = " autoplay='autoplay' ";
		} else {
			$autoPlay = "";
		}
		if($this->loop) {
			$loop = " loop='loop' ";
		} else {
			$loop = "";
		}
		return "<audio style='width:" . $this->width . "px;height:" . $this->height . "px;' src='" . $this->url . "' width='" . $this->width . "' height='" . $this->height . "'" . ((($this->showNavigation) ? " controls='controls'" : "")) . $autoPlay . $loop . $playerName . "></audio>";
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
	function __toString() { return 'org.silex.ui.Audio'; }
}
