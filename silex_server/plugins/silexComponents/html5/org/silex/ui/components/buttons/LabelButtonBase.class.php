<?php

class org_silex_ui_components_buttons_LabelButtonBase extends org_silex_ui_components_buttons_ButtonBase {
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
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton:hover .labelButtonNormal", "display: none;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton:hover .labelButtonSelect", "display: none;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton:hover .labelButtonOver", "display: block;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton:hover .labelButtonPress", "display: none;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton .labelButtonNormal", "display: block;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton .labelButtonSelect", "display: none;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton .labelButtonOver", "display: none;");
		org_silex_htmlGenerator_Utils::addCssRule(".labelButton .labelButtonPress", "display: none;");
	}}
	public $centeredHoriz;
	public $buttonLabelNormal;
	public $buttonLabelSelect;
	public $buttonLabelOver;
	public $buttonLabelPress;
	public $autoSize;
	public $wordWrap;
	public function returnHTML() {
		$normal = null;
		$select = null;
		$over = null;
		$press = null;
		try {
			$normal = "<div class='labelButtonNormal'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fromFlashToHTML(Xml::parse("<rootnode>" . htmlspecialchars_decode($this->buttonLabelNormal) . "</rootnode>")->firstElement())->toString()) . "</div>";
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e = $_ex_;
			{
				$normal = "<div class='labelButtonNormal'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fallBackFlashToHTML(htmlspecialchars_decode($this->buttonLabelNormal))) . "</div>";
			}
		}
		try {
			$select = "<div class='labelButtonSelect'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fromFlashToHTML(Xml::parse("<rootnode>" . htmlspecialchars_decode($this->buttonLabelSelect) . "</rootnode>")->firstElement())->toString()) . "</div>";
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e2 = $_ex_;
			{
				$select = "<div class='labelButtonSelect'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fallBackFlashToHTML(htmlspecialchars_decode($this->buttonLabelSelect))) . "</div>";
			}
		}
		try {
			$over = "<div class='labelButtonOver'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fromFlashToHTML(Xml::parse("<rootnode>" . htmlspecialchars_decode($this->buttonLabelOver) . "</rootnode>")->firstElement())->toString()) . "</div>";
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e3 = $_ex_;
			{
				$over = "<div class='labelButtonOver'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fallBackFlashToHTML(htmlspecialchars_decode($this->buttonLabelOver))) . "</div>";
			}
		}
		try {
			$press = "<div class='labelButtonPress'>" . org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fromFlashToHTML(Xml::parse("<rootnode>" . htmlspecialchars_decode($this->buttonLabelPress) . "</rootnode>")->firstElement())->toString()) . "</div>";
		}catch(Exception $»e) {
			$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
			$e4 = $_ex_;
			{
				$press = org_silex_ui_components_buttons_LabelButtonBase::wikiStyle(org_silex_ui_components_buttons_LabelButtonBase::fallBackFlashToHTML(htmlspecialchars_decode($this->buttonLabelPress))) . "</div>";
			}
		}
		$style = null;
		$style = "";
		if($this->centeredHoriz) {
			$style .= "text-align: center;";
		}
		if(!org_silex_htmlGenerator_Utils::isSelectedIcon($this)) {
			return "<div class='labelButton' style='" . $style . "'>" . $normal . $select . $over . $press . "</div>";
		} else {
			return "<div class='selectedLabelButton' style='" . $style . "'>" . $select . "</div>";
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
	static function fromFlashToHTML($node) {
		$resultingNode = null;
		switch(strtolower($node->getNodeName())) {
		case "textformat":{
			$resultingNode = Xml::createElement("span");
		}break;
		case "p":{
			$resultingNode = Xml::createElement("p");
			$resultingNode->set("style", "margin:0px");
		}break;
		case "font":{
			$resultingNode = Xml::createElement("span");
		}break;
		case "b":{
			$resultingNode = Xml::createElement("span");
			$resultingNode->set("style", "font-weight:bold");
		}break;
		case "u":{
			$resultingNode = Xml::createElement("span");
			$resultingNode->set("style", "text-decoration:underline");
		}break;
		case "i":{
			$resultingNode = Xml::createElement("span");
			$resultingNode->set("style", "font-style:italic");
		}break;
		case "li":{
			$resultingNode = Xml::createElement("li");
		}break;
		default:{
			$resultingNode = Xml::createElement("span");
		}break;
		}
		if(null == $node) throw new HException('null iterable');
		$»it = $node->attributes();
		while($»it->hasNext()) {
			$attr = $»it->next();
			switch(strtolower($attr)) {
			case "align":{
				$resultingNode->set("style", $resultingNode->get("style") . ";" . "text-align:" . $node->get($attr));
			}break;
			case "face":{
				$resultingNode->set("style", $resultingNode->get("style") . ";" . "font-family:" . $node->get($attr));
			}break;
			case "size":{
				$resultingNode->set("style", $resultingNode->get("style") . ";" . "font-size:" . $node->get($attr) . "px");
			}break;
			case "color":{
				$resultingNode->set("style", $resultingNode->get("style") . ";" . "color:" . $node->get($attr));
			}break;
			case "letterspacing":{
			}break;
			default:{
				null;
			}break;
			}
		}
		if(null == $node) throw new HException('null iterable');
		$»it = $node->iterator();
		while($»it->hasNext()) {
			$cn = $»it->next();
			if($cn->nodeType == Xml::$CData || $cn->nodeType == Xml::$PCData) {
				$resultingNode->addChild(Xml::createPCData($cn->getNodeValue()));
			} else {
				if($cn->nodeType == Xml::$Element) {
					$resultingNode->addChild(org_silex_ui_components_buttons_LabelButtonBase::fromFlashToHTML($cn));
				}
			}
		}
		return $resultingNode;
	}
	static function wikiStyle($str) {
		$linksReg = new EReg("\\[\\[([^|]*)\\|([^|]*)\\]\\]", "g");
		$str = $linksReg->replace($str, "<a href='\$1'>\$2</a>");
		return $str;
	}
	static function fallBackFlashToHTML($s) {
		$p_reg = new EReg("<P ALIGN=\"(.*?)\">", "gi");
		$size_reg = new EReg("<font size=\"(.*?)\">(.*?)</font>", "gi");
		$br_reg = new EReg("<br>", "gi");
		$b_reg = new EReg("<b>", "gi");
		$bend_reg = new EReg("</b>", "gi");
		$s = $p_reg->replace($s, "<p style=\"text-align: \$1;\">");
		$s = $size_reg->replace($s, "<span style=\"font-size:\$1pt;\">\$2</span>");
		$s = $br_reg->replace($s, "<br />");
		$s = $b_reg->replace($s, "<strong>");
		$s = $bend_reg->replace($s, "</strong>");
		return $s;
	}
	function __toString() { return 'org.silex.ui.components.buttons.LabelButtonBase'; }
}
