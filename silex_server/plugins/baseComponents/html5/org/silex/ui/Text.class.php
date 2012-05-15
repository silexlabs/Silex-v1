<?php

class org_silex_ui_Text extends org_silex_ui_UiBase {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		parent::__construct();
	}}
	public $html;
	public $htmlText;
	public $embedFonts;
	public $cssUrl;
	public $scrollBar;
	public $typeWriterEffectSpeed;
	public $scrollbarWidth;
	public $selectable;
	public $multiline;
	public $textColor;
	public $textHeight;
	public $autoSize;
	public $border;
	public $borderColor;
	public $antiAliasType;
	public $background;
	public $backgroundColor;
	public $condenseWhite;
	public $maxChars;
	public $mouseWheelEnabled;
	public $password;
	public $restrict;
	public $wordWrap;
	public $textFormat;
	public function returnHTML() {
		$textToRet = null;
		$scrollBars = "";
		if($this->html) {
			$tmp = htmlspecialchars_decode($this->htmlText);
			try {
				$textToRet = org_silex_ui_WikiParser::transformToHTML(org_silex_ui_Text::fromFlashToHTML(Xml::parse("<rootnode>" . $tmp . "</rootnode>")->firstElement())->toString());
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e = $_ex_;
				{
					$textToRet = org_silex_ui_WikiParser::transformToHTML(org_silex_ui_Text::fallBackFlashToHTML($tmp));
				}
			}
		} else {
			$textToRet = $this->htmlText;
		}
		if($this->scrollBar) {
			$scrollBars = "overflow:auto;";
		} else {
			$scrollBars = "overflow:hidden;";
		}
		return "<div style='" . $scrollBars . "width:" . $this->width . "px;height:" . $this->height . "px;' debug='" . Std::string($this->html) . "'>" . $textToRet . "</div>";
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
			$resultingNode->set("style", "margin:0.2em; min-height:1.2em");
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
				$fontFamily = $node->get($attr);
				if($fontFamily === "_sans") {
					$fontFamily = "sans-serif";
				}
				$resultingNode->set("style", $resultingNode->get("style") . ";" . "font-family:" . $fontFamily);
				$fontFamily = null;
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
				$value = $cn->getNodeValue();
				$resultingNode->addChild(Xml::createPCData($value));
				$value = null;
				unset($value);
			} else {
				if($cn->nodeType == Xml::$Element) {
					$resultingNode->addChild(org_silex_ui_Text::fromFlashToHTML($cn));
				}
			}
		}
		return $resultingNode;
	}
	static function fallBackFlashToHTML($s) {
		$p_reg = new EReg("<P ALIGN=\"(.*?)\">", "gi");
		$size_reg = new EReg("<font size=\"(.*?)\">(.*?)</font>", "gi");
		$font_reg = new EReg("<font face=\"(.*?)\" size=\"(.*?)\" color=\"(.*?)\" letterspacing=\"(.*?)\" kerning=\"(.*?)\">(.*?)</font>", "gi");
		$br_reg = new EReg("<br>", "gi");
		$b_reg = new EReg("<b>", "gi");
		$bend_reg = new EReg("</b>", "gi");
		$s = $p_reg->replace($s, "<p style=\"text-align: \$1;\">");
		$s = $size_reg->replace($s, "<span style=\"font-size:\$1pt;\">\$2</span>");
		$s = $font_reg->replace($s, "<span style=\"font-size:\$2pt;font-color:\$3\">\$6</span>");
		$s = $br_reg->replace($s, "<br />");
		$s = $b_reg->replace($s, "<strong>");
		$s = $bend_reg->replace($s, "</strong>");
		return $s;
	}
	function __toString() { return 'org.silex.ui.Text'; }
}
