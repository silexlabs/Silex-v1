<?php

class org_silex_ui_WikiParser {
	public function __construct(){}
	static $lastId = 0;
	static function transformToHTML($wikiCode) {
		$linksReg = new EReg("\\[\\[([^|]*)\\|([^|]*)\\]\\]", "g");
		$actionsReg = new EReg("\\[\\[([^]]+)\\]\\]", "");
		$str = null;
		$str = $wikiCode;
		while($actionsReg->match($str)) {
			$actionsStr = null;
			$actionsStr = _hx_explode("|", $actionsReg->matched(1));
			$wrapper = null;
			$wrapper = Xml::createElement("a");
			$wrapper->addChild(Xml::createPCData($actionsStr->pop()));
			$wrapper->set("id", org_silex_ui_WikiParser::getNextId());
			$action = null;
			$action = _hx_array_get(_hx_explode(":", $actionsStr[0]), 0);
			$parameters = null;
			$parameters = _hx_explode(",", _hx_substr($actionsStr[0], _hx_index_of($actionsStr[0], ":", null) + 1, null));
			switch(strtolower(org_silex_ui_WikiParser::removeHTML($action))) {
			case "open":{
				$url = org_silex_ui_WikiParser::removeHTML($parameters[0]);
				if(_hx_substr($url, 0, 1) === "/") {
					$url = _hx_substr($url, 1, null);
				}
				$websiteStartSection = org_silex_htmlGenerator_Utils::$siteEditor->getWebsiteConfig(org_silex_htmlGenerator_Utils::$deeplink->publication, null)->get("CONFIG_START_SECTION");
				if(_hx_array_get(_hx_explode("/", $url), 0) !== $websiteStartSection) {
					$url = $websiteStartSection . "/" . $url;
				}
				$url = "?/" . org_silex_htmlGenerator_Utils::$deeplink->publication . "/" . $url . "&format=html";
				$wrapper->set("href", $url);
				$str = str_replace($actionsReg->matched(0), $wrapper->toString(), $str);
			}break;
			case "http":{
				$wrapper->set("href", "http:" . htmlspecialchars_decode(org_silex_ui_WikiParser::removeHTML($parameters[0])));
				if($parameters->length > 1) {
					$wrapper->set("target", org_silex_ui_WikiParser::removeHTML($parameters[1]));
				} else {
					$wrapper->set("target", "_blank");
				}
				$str = str_replace($actionsReg->matched(0), $wrapper->toString(), $str);
			}break;
			case "openurl":{
				$wrapper->set("href", htmlspecialchars_decode(org_silex_ui_WikiParser::removeHTML($parameters[0])));
				if($parameters->length > 1) {
					$wrapper->set("target", org_silex_ui_WikiParser::removeHTML($parameters[1]));
				} else {
					$wrapper->set("target", "_blank");
				}
				$str = str_replace($actionsReg->matched(0), $wrapper->toString(), $str);
			}break;
			case "mailto":{
				$wrapper->set("href", "mailto:" . org_silex_ui_WikiParser::removeHTML($parameters[0]));
				if($parameters->length > 1) {
					$wrapper->set("target", org_silex_ui_WikiParser::removeHTML($parameters[1]));
				}
				$str = str_replace($actionsReg->matched(0), $wrapper->toString(), $str);
			}break;
			default:{
				$wrapper->set("href", "#");
				$str = str_replace($actionsReg->matched(0), $wrapper->toString(), $str);
			}break;
			}
			{
				$_g = 0;
				while($_g < $actionsStr->length) {
					$actionStr = $actionsStr[$_g];
					++$_g;
					$parameters1 = new _hx_array(array());
					{
						$_g1 = 0; $_g2 = _hx_explode(",", _hx_array_get(_hx_explode(":", $actionStr), 1));
						while($_g1 < $_g2->length) {
							$parameter = $_g2[$_g1];
							++$_g1;
							$parameters1->push(htmlspecialchars_decode(org_silex_ui_WikiParser::removeHTML($parameter)));
							unset($parameter);
						}
						unset($_g2,$_g1);
					}
					$action1 = _hx_anonymous(array("component" => $wrapper->get("id"), "modifier" => "onRelease", "functionName" => org_silex_ui_WikiParser::removeHTML(_hx_array_get(_hx_explode(" ", _hx_array_get(_hx_explode(":", $actionStr), 0)), 0)), "parameters" => $parameters1));
					$actions = Reflect::field(Type::resolveClass("org.silex.htmlGenerator.JsCommunication"), "actions");
					Reflect::callMethod($actions, Reflect::field($actions, "push"), new _hx_array(array($action1)));
					unset($parameters1,$actions,$actionStr,$action1);
				}
				unset($_g);
			}
			unset($wrapper,$parameters,$actionsStr,$action);
		}
		$imagesReg = new EReg("{{([^}\\?]*)([^}]*)}}", "");
		while($imagesReg->match($str)) {
			$url = $imagesReg->matched(1);
			$url = trim($url);
			$width = 0.0;
			$height = 0.0;
			$htmlSizeStr = "";
			if($imagesReg->matched(2) !== "") {
				$cleanSize = trim(str_replace("?", "", $imagesReg->matched(2)));
				$width = Std::parseFloat(_hx_array_get(_hx_explode("x", $cleanSize), 0));
				$height = Std::parseFloat(_hx_array_get(_hx_explode("x", $cleanSize), 1));
				$htmlSizeStr = "width='" . $width . "' height='" . $height . "'";
				unset($cleanSize);
			}
			if(strtolower(_hx_explode(".", $url)->pop()) !== "swf") {
				$str = $imagesReg->replace($str, "<img src='" . $url . "' " . $htmlSizeStr . " />");
			} else {
				$str = str_replace($imagesReg->matched(0), "<object>\x0A\x09\x09\x09\x09<param name=\"movie\" value=\"" . $url . "\">\x0A\x09\x09\x09\x09<embed src=\"" . $url . "\">\x0A\x09\x09\x09\x09</embed>\x0A\x09\x09\x09\x09</object>", $str);
			}
			unset($width,$url,$htmlSizeStr,$height);
		}
		return $str;
	}
	static function getNextId() {
		return "wikiPseudoComp-" . org_silex_ui_WikiParser::$lastId++;
	}
	static function removeHTML($str) {
		if($str === null) {
			return "";
		}
		$reg = new EReg("<[^>]+>", "g");
		return $reg->replace($str, "");
	}
	static function fallBackFlashToHTML($s) {
		$p_reg = new EReg("<P ALIGN=\"(.*?)\">", "gi");
		$size_reg = new EReg("<font size=\"(.*?)\">(.*?)</font>", "gi");
		$br_reg = new EReg("<br>", "gi");
		$b_reg = new EReg("<b>", "gi");
		$bend_reg = new EReg("</b>", "gi");
		$s = $p_reg->replace($s, "<p style=\"text-align: \$1;\">");
	}
	function __toString() { return 'org.silex.ui.WikiParser'; }
}
