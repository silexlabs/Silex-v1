<?php
require_once dirname(__FILE__).'/../../../site_editor.extern.php';

class org_silex_serverApi_SiteEditor {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::new");
		$»spos = $GLOBALS['%s']->length;
		$this->siteEditorExtern = new site_editor();
		$GLOBALS['%s']->pop();
	}}
	public $siteEditorExtern;
	public function getSectionSeoData($id_site, $deeplink, $urlBase) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::getSectionSeoData");
		$»spos = $GLOBALS['%s']->length;
		$tmp = null;
		$sectionSeoData = $this->siteEditorExtern->getSectionSeoData($id_site, $deeplink, $urlBase);
		$tmp = php_Lib::hashOfAssociativeArray($sectionSeoData);
		$layers = null;
		if($tmp->get("subLayers") !== null) {
			$layers = new _hx_array($tmp->get("subLayers"));
			{
				$_g1 = 0; $_g = $layers->length;
				while($_g1 < $_g) {
					$i = $_g1++;
					$layers[$i] = php_Lib::hashOfAssociativeArray($layers[$i]);
					unset($i);
				}
			}
		}
		{
			$GLOBALS['%s']->pop();
			return $tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function writeSectionData($xmlData, $xmlFileName, $sectionName, $id_site, $seoObject, $domObject) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::writeSectionData");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->writeSectionData($xmlData, $xmlFileName, $sectionName, $id_site, php_Lib::associativeArrayOfHash($seoObject), $domObject);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function storeSeoData($websiteContentFolderPath, $sectionName, $seoObject) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::storeSeoData");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->storeSeoData($websiteContentFolderPath, $sectionName, php_Lib::associativeArrayOfHash($seoObject));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function renameSection($siteName, $oldSectionName, $newSectionName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::renameSection");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->renameSection($siteName, $oldSectionName, $newSectionName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function duplicateSection($siteName, $oldSectionName, $newSectionName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::duplicateSection");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->duplicateSection($siteName, $oldSectionName, $newSectionName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function createSection($siteName, $newSectionName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::createSection");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->createSection($siteName, $newSectionName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function deleteSection($siteName, $sectionName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::deleteSection");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->deleteSection($siteName, $sectionName);
			$GLOBALS['%s']->pop();
			$»tmp;
			return;
		}
		$GLOBALS['%s']->pop();
	}
	public function savePublicationStructure($siteName, $xmlContent, $xmlContentPublished) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::savePublicationStructure");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->savePublicationStructure($siteName, $xmlContent, $xmlContentPublished);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function loadPublicationStructure($siteName, $isPublishedVersion) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::loadPublicationStructure");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->loadPublicationStructure($siteName, $isPublishedVersion);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function parse_client_site_ini_file($filePath) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::parse_client_site_ini_file");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = php_Lib::hashOfAssociativeArray($this->siteEditorExtern->parse_client_site_ini_file($filePath));
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getWebsiteConfig($id_site, $mergeWithServerConfig) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::getWebsiteConfig");
		$»spos = $GLOBALS['%s']->length;
		$tmp = null;
		if(($tmp = $this->siteEditorExtern->getWebsiteConfig($id_site, $mergeWithServerConfig)) !== null) {
			$»tmp = php_Lib::hashOfAssociativeArray($tmp);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		{
			$GLOBALS['%s']->pop();
			return null;
		}
		$GLOBALS['%s']->pop();
	}
	public function deleteWebsite($id_site) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::deleteWebsite");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->deleteWebsite($id_site);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function createWebsite($id_site) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::createWebsite");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->createWebsite($id_site);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function renameWebsite($id_site, $new_id) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::renameWebsite");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->renameWebsite($id_site, $new_id);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function writeWebsiteConfig($websiteInfo, $id_site) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::writeWebsiteConfig");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->writeWebsiteConfig(php_Lib::associativeArrayOfHash($websiteInfo), $id_site);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function duplicateWebsite($id_site, $newName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::duplicateWebsite");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->duplicateWebsite($id_site, $newName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getSiteThumb($siteName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::getSiteThumb");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->getSiteThumb($siteName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
	}
	public function getPagePreview($siteName, $pageName) {
		$GLOBALS['%s']->push("org.silex.serverApi.SiteEditor::getPagePreview");
		$»spos = $GLOBALS['%s']->length;
		{
			$»tmp = $this->siteEditorExtern->getPagePreview($siteName, $pageName);
			$GLOBALS['%s']->pop();
			return $»tmp;
		}
		$GLOBALS['%s']->pop();
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
	function __toString() { return 'org.silex.serverApi.SiteEditor'; }
}
