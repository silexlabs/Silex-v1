<?php

class org_silex_ui_UiBase extends org_silex_ui_MovieClip {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $playerName;
	public $descriptionText;
	public $tags;
	public $iconPageName;
	public $iconDeeplinkName;
	public $iconLayoutName;
	public $iconIsIcon;
	public $iconIsDefault;
	public $url;
	public $visibleOutOfAdmin;
	public $tooltipText;
	public $tabEnabled;
	public $tabIndex;
	public $__silex__layerPath__;
	public $__silex__publicationName__;
	public $__silex__actionshref__;
	public function getHTML() {
		$res = "";
		$styleVisible = "visibility:visible;";
		if(!$this->visibleOutOfAdmin) {
			$styleVisible = "visibility:hidden;";
		}
		if($this->iconIsIcon && ($this->iconDeeplinkName === "" || $this->iconDeeplinkName === null)) {
			$res .= "<a href='?/" . $this->__silex__publicationName__ . "/" . $this->__silex__layerPath__->join("/") . "/" . $this->iconPageName . "&amp;format=html&amp;selectedIcon=" . rawurlencode($this->__silex__layerPath__->join(".") . "." . $this->playerName) . "'>";
		} else {
			if($this->iconIsIcon) {
				$res .= "<a href='?/" . $this->iconDeeplinkName . "&amp;format=html&amp;selectedIcon=" . rawurlencode($this->__silex__layerPath__->join(".") . "." . $this->playerName) . "'>";
			} else {
				if($this->__silex__actionshref__ !== null) {
					$res .= "<a href='" . $this->__silex__actionshref__ . "'>";
				}
			}
		}
		$res .= "<div id='" . $this->playerName . "' class='silex-comp-UiBase' style='-webkit-transform-origin: 0 0;-moz-transform-origin: 0 0; -webkit-transform: rotate(" . $this->rotation . "deg);-moz-transform: rotate(" . $this->rotation . "deg);position:absolute;left:" . $this->x . "px;top:" . $this->y . "px;width:" . $this->width . "px;height:" . $this->height . "px;" . $styleVisible . "'>";
		$res .= $this->returnHTML();
		$res .= "</div>";
		if($this->iconIsIcon || $this->__silex__actionshref__ !== null) {
			$res .= "</a>";
		}
		return $res;
	}
	public function returnHTML() {
		return "";
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
	function __toString() { return 'org.silex.ui.UiBase'; }
}
