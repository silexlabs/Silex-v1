<?php

class org_silex_core_seo_Constants {
	public function __construct(){}
	static $SEO_FILE_EXTENSION = ".seodata.xml";
	static $LAYER_SEO_PROPERTIES;
	static $COMPONENT_GENERIC_PROPERTIES;
	static $COMPONENT_LINK_PROPERTIES;
	static $LAYER_SEO_AGGREGATED_PROPERTIES;
	static $CHILD_LAYERS_NODE_NAME = "subLayers";
	static function getCharacter2EntityNameList() {
		$list = new Hash();
		$list->set("&", "&amp;");
		$list->set("\"", "&quot;");
		$list->set("'", "&apos;");
		$list->set("<", "&lt;");
		$list->set(">", "&gt;");
		return $list;
	}
	static function getEntityName2CharacterList() {
		$originalList = org_silex_core_seo_Constants::getCharacter2EntityNameList();
		$convertedList = new Hash();
		if(null == $originalList) throw new HException('null iterable');
		$»it = $originalList->keys();
		while($»it->hasNext()) {
			$character = $»it->next();
			$convertedList->set($originalList->get($character), $character);
		}
		return $convertedList;
	}
	function __toString() { return 'org.silex.core.seo.Constants'; }
}
org_silex_core_seo_Constants::$LAYER_SEO_PROPERTIES = new _hx_array(array("title", "description", "pubDate"));
org_silex_core_seo_Constants::$COMPONENT_GENERIC_PROPERTIES = new _hx_array(array("playerName", "className", "iconIsIcon", "htmlEquivalent", "tags", "description"));
org_silex_core_seo_Constants::$COMPONENT_LINK_PROPERTIES = new _hx_array(array("title", "link", "deeplink", "description"));
org_silex_core_seo_Constants::$LAYER_SEO_AGGREGATED_PROPERTIES = new _hx_array(array("title", "deeplink", "description", "tags", "htmlEquivalent", "links"));
