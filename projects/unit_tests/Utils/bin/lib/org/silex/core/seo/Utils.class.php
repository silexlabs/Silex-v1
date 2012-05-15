<?php

class org_silex_core_seo_Utils {
	public function __construct(){}
	static $TITLE_SEPARATOR = " - ";
	static $DESCRIPTION_SEPARATOR = ". ";
	static $TAGS_SEPARATOR = ",";
	static $HTML_EQUIVALENT_SEPARATOR = "";
	static function getPageSeoData($idSite, $deeplink, $urlBase) {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::getPageSeoData");
		$製pos = $GLOBALS['%s']->length;
		$serverConfig = new org_silex_serverApi_ServerConfig();
		$layerSeoFilePath = null;
		$pageSeoData = org_silex_core_seo_Utils::createLayerSeoAggregatedModel();
		$layerSeoAggregatedDataArray = new _hx_array(array());
		$layerSeoAggregatedData = org_silex_core_seo_Utils::createLayerSeoAggregatedModel();
		$layerSeo = null;
		$layersNames = new _hx_array(array());
		$layerName = null;
		$layerDeeplink = "";
		$titleArray = new _hx_array(array());
		$descriptionArray = new _hx_array(array());
		$tagsArray = new _hx_array(array());
		$htmlEquivalentArray = new _hx_array(array());
		$layersNames = _hx_explode("/", $deeplink);
		{
			$_g = 0;
			while($_g < $layersNames->length) {
				$layerName1 = $layersNames[$_g];
				++$_g;
				$layerDeeplink .= $layerName1 . "/";
				$layerSeoFilePath = org_silex_serverApi_RootDir::getRootPath() . $serverConfig->getContentFolderForPublication($idSite) . $idSite . "/" . $layerName1 . org_silex_core_seo_Constants::$SEO_FILE_EXTENSION;
				$layerSeo = org_silex_core_seo_LayerSeo::readLayerSeoModel($layerSeoFilePath, _hx_substr($layerDeeplink, 0, strlen($layerDeeplink) - 1));
				$layerSeoAggregatedData = org_silex_core_seo_Utils::aggregateLayerSeoData($layerSeo, $layerDeeplink, $urlBase);
				$layerSeoAggregatedDataArray->push($layerSeoAggregatedData);
				unset($layerName1);
			}
		}
		{
			$_g = 0;
			while($_g < $layerSeoAggregatedDataArray->length) {
				$layerSeoAggregatedData1 = $layerSeoAggregatedDataArray[$_g];
				++$_g;
				$titleArray->push($layerSeoAggregatedData1->title);
				$descriptionArray->push($layerSeoAggregatedData1->description);
				$tagsArray->push($layerSeoAggregatedData1->tags);
				$htmlEquivalentArray->push($layerSeoAggregatedData1->htmlEquivalent);
				{
					$_g1 = 0; $_g2 = $layerSeoAggregatedData1->subLayers;
					while($_g1 < $_g2->length) {
						$childLayer = $_g2[$_g1];
						++$_g1;
						$pageSeoData->subLayers->push($childLayer);
						unset($childLayer);
					}
					unset($_g2,$_g1);
				}
				unset($layerSeoAggregatedData1);
			}
		}
		$pageSeoData->deeplink = $deeplink;
		$pageSeoData->title = $titleArray->join(org_silex_core_seo_Utils::$TITLE_SEPARATOR);
		$pageSeoData->description = $descriptionArray->join(org_silex_core_seo_Utils::$DESCRIPTION_SEPARATOR);
		$pageSeoData->tags = $tagsArray->join(org_silex_core_seo_Utils::$TAGS_SEPARATOR);
		$pageSeoData->htmlEquivalent = $htmlEquivalentArray->join(org_silex_core_seo_Utils::$HTML_EQUIVALENT_SEPARATOR);
		{
			$GLOBALS['%s']->pop();
			return $pageSeoData;
		}
		$GLOBALS['%s']->pop();
	}
	static function getPageSeoDataAsPhpArray($idSite, $deeplink, $urlBase) {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::getPageSeoDataAsPhpArray");
		$製pos = $GLOBALS['%s']->length;
		$pageSeoData = org_silex_core_seo_Utils::getPageSeoData($idSite, $deeplink, $urlBase);
		{
			$裨mp = org_silex_core_seo_Utils::layerSeoAggregatedModel2PhpArray($pageSeoData);
			$GLOBALS['%s']->pop();
			return $裨mp;
		}
		$GLOBALS['%s']->pop();
	}
	static function aggregateLayerSeoData($layerSeo, $deeplink, $urlBase) {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::aggregateLayerSeoData");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoAggregatedData = org_silex_core_seo_Utils::createLayerSeoAggregatedModel();
		$descriptionArray = new _hx_array(array());
		$tagsArray = new _hx_array(array());
		$htmlEquivalentArray = new _hx_array(array());
		$linksArray = new _hx_array(array());
		$childLayersArray = new _hx_array(array());
		if(_hx_has_field($layerSeo, "title")) {
			$layerSeoAggregatedData->title = $layerSeo->title;
		}
		$layerSeoAggregatedData->deeplink = _hx_substr($deeplink, 0, strlen($deeplink) - 1);
		if(_hx_has_field($layerSeo, "description")) {
			$layerSeoAggregatedData->description = $layerSeo->description;
		}
		{
			$_g = 0; $_g1 = $layerSeo->components;
			while($_g < $_g1->length) {
				$component = $_g1[$_g];
				++$_g;
				if(_hx_has_field($component, "description")) {
					$descriptionArray->push($component->description);
				}
				if(_hx_has_field($component, "tags")) {
					$tagsArray->push($component->tags);
				}
				if(_hx_has_field($component, "htmlEquivalent")) {
					$htmlEquivalentArray->push($component->htmlEquivalent);
				}
				{
					$_g2 = 0; $_g3 = $component->links;
					while($_g2 < $_g3->length) {
						$link = $_g3[$_g2];
						++$_g2;
						$linksArray->push("<A HREF=\"" . $urlBase . $deeplink . $link->deeplink . "\">" . $link->title . "</A>");
						$childLayersArray->push($link);
						$layerSeoAggregatedData->subLayers->push($link);
						unset($link);
					}
					unset($_g3,$_g2);
				}
				unset($component);
			}
		}
		$layerSeoAggregatedData->description = $descriptionArray->join(org_silex_core_seo_Utils::$DESCRIPTION_SEPARATOR);
		$layerSeoAggregatedData->tags = $tagsArray->join(org_silex_core_seo_Utils::$TAGS_SEPARATOR);
		$layerSeoAggregatedData->htmlEquivalent = $htmlEquivalentArray->join(org_silex_core_seo_Utils::$HTML_EQUIVALENT_SEPARATOR);
		if($linksArray->length !== 0) {
			$layerSeoAggregatedData->links = "<ul><li>" . $linksArray->join("</li><li>") . "</li></ul>";
		}
		$layerSeoAggregatedData->subLayers = $childLayersArray;
		{
			$GLOBALS['%s']->pop();
			return $layerSeoAggregatedData;
		}
		$GLOBALS['%s']->pop();
	}
	static function layerSeoAggregatedModel2PhpArray($layerSeoAggregatedModel) {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::layerSeoAggregatedModel2PhpArray");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoAggregatedHash = new Hash();
		$layerSeoAggregatedNativeArray = null;
		$subLayersArray = null;
		$subLayersNativeArray = null;
		$linkHash = null;
		$linkNativeArray = null;
		if(null == org_silex_core_seo_Constants::$LAYER_SEO_AGGREGATED_PROPERTIES) throw new HException('null iterable');
		$蜴t = org_silex_core_seo_Constants::$LAYER_SEO_AGGREGATED_PROPERTIES->iterator();
		while($蜴t->hasNext()) {
			$layerSeoAggregatedModelProp = $蜴t->next();
			$layerSeoAggregatedHash->set($layerSeoAggregatedModelProp, Reflect::field($layerSeoAggregatedModel, $layerSeoAggregatedModelProp));
		}
		if($layerSeoAggregatedModel->subLayers->length !== 0) {
			$subLayersArray = new _hx_array(array());
			{
				$_g = 0; $_g1 = $layerSeoAggregatedModel->subLayers;
				while($_g < $_g1->length) {
					$link = $_g1[$_g];
					++$_g;
					$linkHash = new Hash();
					if(null == new _hx_array(array("title", "link", "deeplink", "description"))) throw new HException('null iterable');
					$蜴t = _hx_deref(new _hx_array(array("title", "link", "deeplink", "description")))->iterator();
					while($蜴t->hasNext()) {
						$linkProp = $蜴t->next();
						if(Reflect::field($link, $linkProp) !== null) {
							$linkHash->set($linkProp, Reflect::field($link, $linkProp));
						}
					}
					$linkNativeArray = php_Lib::associativeArrayOfHash($linkHash);
					$subLayersArray->push($linkNativeArray);
					$subLayersNativeArray = php_Lib::toPhpArray($subLayersArray);
					unset($link);
				}
			}
			$subLayersArray->push($subLayersNativeArray);
		}
		$layerSeoAggregatedHash->set(org_silex_core_seo_Constants::$CHILD_LAYERS_NODE_NAME, $subLayersNativeArray);
		$layerSeoAggregatedNativeArray = php_Lib::associativeArrayOfHash($layerSeoAggregatedHash);
		{
			$GLOBALS['%s']->pop();
			return $layerSeoAggregatedNativeArray;
		}
		$GLOBALS['%s']->pop();
	}
	static function createComponentSeoModel() {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::createComponentSeoModel");
		$製pos = $GLOBALS['%s']->length;
		$obj = _hx_anonymous(array("tags" => "", "specificProperties" => new Hash(), "playerName" => "", "links" => new _hx_array(array()), "iconIsIcon" => "", "htmlEquivalent" => "", "description" => "", "className" => ""));
		{
			$GLOBALS['%s']->pop();
			return $obj;
		}
		$GLOBALS['%s']->pop();
	}
	static function createComponentSeoLinkModel() {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::createComponentSeoLinkModel");
		$製pos = $GLOBALS['%s']->length;
		$obj = _hx_anonymous(array("title" => "", "link" => "", "deeplink" => "", "description" => ""));
		{
			$GLOBALS['%s']->pop();
			return $obj;
		}
		$GLOBALS['%s']->pop();
	}
	static function createLayerSeoModel() {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::createLayerSeoModel");
		$製pos = $GLOBALS['%s']->length;
		$obj = _hx_anonymous(array("title" => "", "description" => "", "pubDate" => "", "components" => new _hx_array(array())));
		{
			$GLOBALS['%s']->pop();
			return $obj;
		}
		$GLOBALS['%s']->pop();
	}
	static function createLayerSeoAggregatedModel() {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::createLayerSeoAggregatedModel");
		$製pos = $GLOBALS['%s']->length;
		$obj = _hx_anonymous(array("title" => "", "deeplink" => "", "description" => "", "tags" => "", "htmlEquivalent" => "", "links" => "", "subLayers" => new _hx_array(array())));
		{
			$GLOBALS['%s']->pop();
			return $obj;
		}
		$GLOBALS['%s']->pop();
	}
	static function html2Text($html) {
		$GLOBALS['%s']->push("org.silex.core.seo.Utils::html2Text");
		$製pos = $GLOBALS['%s']->length;
		$htmlRegExpr = new EReg("<([/A-Z0-9\\s=\"#-]*>)", "ig");
		$spaceRegExpr = new EReg("( )+", "g");
		$text = $htmlRegExpr->replace($html, " ");
		$text = rtrim(ltrim($spaceRegExpr->replace($text, " ")));
		{
			$GLOBALS['%s']->pop();
			return $text;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'org.silex.core.seo.Utils'; }
}
{
	require_once("rootdir.php");
	set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
	set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library");
}
