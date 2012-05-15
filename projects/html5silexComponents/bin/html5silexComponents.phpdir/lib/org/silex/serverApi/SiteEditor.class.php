<?php
require_once dirname(__FILE__).'/../../../site_editor.extern.php';

class org_silex_serverApi_SiteEditor {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$this->siteEditorExtern = new site_editor();
	}}
	public $siteEditorExtern;
	public function getSectionSeoData($id_site, $deeplink, $urlBase) {
		$tmp = php_Lib::hashOfAssociativeArray($this->siteEditorExtern->getSectionSeoData($id_site, $deeplink, $urlBase));
		$layers = null;
		$layers = new _hx_array($tmp->get("subLayers"));
		{
			$_g1 = 0; $_g = $layers->length;
			while($_g1 < $_g) {
				$i = $_g1++;
				$layers[$i] = php_Lib::hashOfAssociativeArray($layers[$i]);
				unset($i);
			}
		}
		$tmp->set("subLayers", $layers);
		return $tmp;
	}
	public function writeSectionData($xmlData, $xmlFileName, $sectionName, $id_site, $seoObject, $domObject) {
		return $this->siteEditorExtern->writeSectionData($xmlData, $xmlFileName, $sectionName, $id_site, php_Lib::associativeArrayOfHash($seoObject), $domObject);
	}
	public function storeSeoData($websiteContentFolderPath, $sectionName, $seoObject) {
		return $this->siteEditorExtern->storeSeoData($websiteContentFolderPath, $sectionName, php_Lib::associativeArrayOfHash($seoObject));
	}
	public function renameSection($siteName, $oldSectionName, $newSectionName) {
		return $this->siteEditorExtern->renameSection($siteName, $oldSectionName, $newSectionName);
	}
	public function duplicateSection($siteName, $oldSectionName, $newSectionName) {
		return $this->siteEditorExtern->duplicateSection($siteName, $oldSectionName, $newSectionName);
	}
	public function createSection($siteName, $newSectionName) {
		return $this->siteEditorExtern->createSection($siteName, $newSectionName);
	}
	public function deleteSection($siteName, $sectionName) {
		$this->siteEditorExtern->deleteSection($siteName, $sectionName);
		return;
	}
	public function savePublicationStructure($siteName, $xmlContent, $xmlContentPublished) {
		return $this->siteEditorExtern->savePublicationStructure($siteName, $xmlContent, $xmlContentPublished);
	}
	public function loadPublicationStructure($siteName, $isPublishedVersion) {
		return $this->siteEditorExtern->loadPublicationStructure($siteName, $isPublishedVersion);
	}
	public function parse_client_site_ini_file($filePath) {
		return php_Lib::hashOfAssociativeArray($this->siteEditorExtern->parse_client_site_ini_file($filePath));
	}
	public function getWebsiteConfig($id_site, $mergeWithServerConfig) {
		$tmp = null;
		if(($tmp = $this->siteEditorExtern->getWebsiteConfig($id_site, $mergeWithServerConfig)) !== null) {
			return php_Lib::hashOfAssociativeArray($tmp);
		}
		return null;
	}
	public function deleteWebsite($id_site) {
		return $this->siteEditorExtern->deleteWebsite($id_site);
	}
	public function createWebsite($id_site) {
		return $this->siteEditorExtern->createWebsite($id_site);
	}
	public function renameWebsite($id_site, $new_id) {
		return $this->siteEditorExtern->renameWebsite($id_site, $new_id);
	}
	public function writeWebsiteConfig($websiteInfo, $id_site) {
		return $this->siteEditorExtern->writeWebsiteConfig(php_Lib::associativeArrayOfHash($websiteInfo), $id_site);
	}
	public function duplicateWebsite($id_site, $newName) {
		return $this->siteEditorExtern->duplicateWebsite($id_site, $newName);
	}
	public function getSiteThumb($siteName) {
		return $this->siteEditorExtern->getSiteThumb($siteName);
	}
	public function getPagePreview($siteName, $pageName) {
		return $this->siteEditorExtern->getPagePreview($siteName, $pageName);
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
