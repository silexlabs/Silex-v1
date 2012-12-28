<?php

class org_silex_htmlGenerator_Utils {
	public function __construct(){}
	static $deeplink;
	static $siteEditor;
	static $cssRules;
	static function addCssRule($selector, $content) {
		org_silex_htmlGenerator_Utils::$cssRules->set($selector, $content);
	}
	static function removeCssRule($selector) {
		org_silex_htmlGenerator_Utils::$cssRules->remove($selector);
	}
	static function getCssRule($selector) {
		return org_silex_htmlGenerator_Utils::$cssRules->get($selector);
	}
	static function getCssText() {
		$cssCode = null;
		$cssCode = "";
		if(null == org_silex_htmlGenerator_Utils::$cssRules) throw new HException('null iterable');
		$»it = org_silex_htmlGenerator_Utils::$cssRules->keys();
		while($»it->hasNext()) {
			$selector = $»it->next();
			$cssCode .= $selector . " {\x0A";
			$cssCode .= org_silex_htmlGenerator_Utils::$cssRules->get($selector) . "\x0A";
			$cssCode .= "}\x0A\x0A";
		}
		return $cssCode;
	}
	static function isSelectedIcon($icon) {
		{
			$_g = 0; $_g1 = org_silex_htmlGenerator_Utils::$deeplink->layers;
			while($_g < $_g1->length) {
				$layer = $_g1[$_g];
				++$_g;
				if($layer === $icon->iconPageName || $layer === $icon->iconDeeplinkName) {
					return true;
				}
				unset($layer);
			}
		}
		return false;
	}
	function __toString() { return 'org.silex.htmlGenerator.Utils'; }
}
org_silex_htmlGenerator_Utils::$cssRules = new Hash();
