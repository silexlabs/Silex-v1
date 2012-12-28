<?php

class org_silex_html_SilexIndex {
	public function __construct(){}
	static $serverConfig;
	static $siteEditor;
	static $serverContent;
	static $pluginManager;
	static $hookManager;
	static $configEditor;
	static $fileSystemTools;
	static $flashVars;
	static $flashParam;
	static $pathToMainTemplate = "templates/index/doMain.html";
	static $pathToRedirectToInstaller = "templates/index/redirectInstaller.html";
	static $pathToNotFoundIsNotFound = "templates/index/notFoundIsNotFound.html";
	static $silexApiJsScriptFolderUrl;
	static $websiteFonts;
	static function main() {
		org_silex_serverApi_helpers_Env::setIncludePath((org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator()) . org_silex_serverApi_RootDir::getRootPath());
		org_silex_serverApi_helpers_Env::setIncludePath(((org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator()) . org_silex_serverApi_RootDir::getRootPath()) . "cgi/library");
		org_silex_serverApi_helpers_Env::setIncludePath(((org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator()) . org_silex_serverApi_RootDir::getRootPath()) . "cgi/includes");
		require_once("cgi/includes/ComponentManager.php");
		require_once("cgi/includes/ComponentDescriptor.php");
		$isDefaultWebsite = false;
		$doRedirect = false;
		$url = null;
		$deeplink = "";
		$idSite = null;
		if(_hx_index_of($_SERVER['QUERY_STRING'], "/", null) === 0) {
			if(_hx_char_at($_SERVER['QUERY_STRING'], strlen($_SERVER['QUERY_STRING']) - 1) === "/") {
				$url = _hx_substr($_SERVER['QUERY_STRING'], 0, strlen($_SERVER['QUERY_STRING']) - 1);
				;
			}
			else {
				$url = $_SERVER['QUERY_STRING'];
				;
			}
			$url = _hx_substr($url, 1, strlen($url) - 1);
			$tab_url = _hx_explode("/", $url);
			$idSite = $tab_url->shift();
			$deeplink = $tab_url->join("/");
			if($deeplink !== "") {
				$doRedirect = true;
				;
			}
			unset($tab_url);
		}
		else {
			$idSite = php_Web::getParams()->get("id_site");
			if($idSite === null) {
				$isDefaultWebsite = true;
				;
			}
			;
		}
		null;
		null;
		null;
		if(!file_exists("conf/pass.php")) {
			org_silex_html_SilexIndex::redirectToInstaller();
			return;
			;
		}
		$serverConfig = new org_silex_serverApi_ServerConfig();
		$serverContent = new org_silex_serverApi_ServerContent();
		$siteEditor = new org_silex_serverApi_SiteEditor();
		$fst = new org_silex_serverApi_FileSystemTools();
		$hookManager = org_silex_serverApi_HookManager::getInstance();
		$pluginManager = new org_silex_serverApi_PluginManager();
		$configEditor = new org_silex_serverApi_ConfigEditor();
		org_silex_html_SilexIndex::$silexApiJsScriptFolderUrl = org_silex_serverApi_RootDir::getRootUrl() . $serverConfig->getSilexServerIni()->get("JAVASCRIPT_FOLDER");
		null;
		null;
		if($isDefaultWebsite) {
			$idSite = $serverConfig->getSilexServerIni()->get("DEFAULT_WEBSITE");
			;
		}
		else {
			if($idSite === $serverConfig->getSilexServerIni()->get("DEFAULT_WEBSITE")) {
				$isDefaultWebsite = true;
				;
			}
			;
		}
		$js_str = "";
		$fv_js_object = "";
		if(null == php_Web::getParams()) throw new HException('null iterable');
		$»it = php_Web::getParams()->keys();
		while($»it->hasNext()) {
		$key = $»it->next();
		{
			if(_hx_index_of($key, "/", null) !== -1) {
				continue;
				;
			}
			if($fv_js_object !== "") {
				$fv_js_object .= ",\x0A";
				;
			}
			$fv_js_object .= (($key . " : '") . str_replace("'", "\\'", str_replace("\\", "\\\\", php_Web::getParams()->get($key)))) . "'";
			$js_str .= ((("\$" . $key) . " = '") . str_replace("'", "\\'", str_replace("\\", "\\\\", php_Web::getParams()->get($key)))) . "'; ";
			;
		}
		}
		$silexPluginsConf = $configEditor->readConfigFile($serverConfig->getSilexServerIni()->get("SILEX_PLUGINS_CONF"), "phparray");
		$pluginManager->createActivePlugins($silexPluginsConf, $hookManager);
		$websiteConfig = $siteEditor->getWebsiteConfig($idSite, null);
		if($websiteConfig === null) {
			$websiteConfig = $siteEditor->getWebsiteConfig($serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE"), null);
			if($websiteConfig === null) {
				org_silex_html_SilexIndex::notFoundIsNotFound($serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE"));
				return;
				;
			}
			$idSite = $serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE");
			php_Web::setReturnCode(404);
			;
		}
		$pluginManager->createActivePlugins($websiteConfig, $hookManager);
		$websiteTitle = $websiteConfig->get("htmlTitle");
		$fontList = $websiteConfig->get("FONTS_LIST");
		$fonts = new _hx_array(array());
		if($fontList !== null && $fontList !== "") {
			{
				$_g = 0; $_g1 = _hx_explode("@", $fontList);
				while($_g < $_g1->length) {
					$fontFile = $_g1[$_g];
					++$_g;
					$fonts->push(($serverConfig->getSilexServerIni()->get("FONTS_FOLDER") . $fontFile) . "_importtest.swf");
					unset($fontFile);
				}
				unset($_g1,$_g);
			}
			org_silex_html_SilexIndex::$websiteFonts = $fonts->join(",");
			;
		}
		$favicon = "";
		if($websiteConfig->get("htmlIcon") !== null && $websiteConfig->get("htmlIcon") !== "") {
			$favicon = ((("<link rel=\"shortcut icon\" href=\"" . $websiteConfig->get("htmlIcon")) . "\"><link rel=\"icon\" href=\"") . $websiteConfig->get("htmlIcon")) . "\">";
			;
		}
		$mainRssFeed = "";
		if($websiteConfig->get("mainRssFeed") !== null && $websiteConfig->get("mainRssFeed") !== "") {
			$mainRssFeed = ("<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"" . $websiteConfig->get("mainRssFeed")) . "\">";
			;
		}
		$websiteKeywords = $websiteConfig->get("htmlKeywords");
		$defaultLanguage = $websiteConfig->get("DEFAULT_LANGUAGE");
		$linksUrlBase = org_silex_html_SilexIndex_0($configEditor, $deeplink, $defaultLanguage, $doRedirect, $favicon, $fontList, $fonts, $fst, $fv_js_object, $hookManager, $idSite, $isDefaultWebsite, $js_str, $mainRssFeed, $pluginManager, $serverConfig, $serverContent, $silexPluginsConf, $siteEditor, $url, $websiteConfig, $websiteKeywords, $websiteTitle);
		$seoDataHomePage = $siteEditor->getSectionSeoData($idSite, $websiteConfig->get("CONFIG_START_SECTION"), $linksUrlBase);
		$seoData = null;
		if($deeplink !== null && $deeplink !== "") {
			$seoData = $siteEditor->getSectionSeoData($idSite, $deeplink, $linksUrlBase);
			;
		}
		else {
			$seoData = $seoDataHomePage;
			$deeplink = "";
			;
		}
		$htmlTitle = $websiteConfig->get("htmlTitle");
		$htmlDescription = $seoData->get("description");
		$htmlTags = $seoData->get("tags");
		$htmlEquivalent = "<H4>This page content</H4><br/>" . $seoData->get("htmlEquivalent");
		$htmlKeywords = (("<H4>Website keywords</H4><br/>" . $seoDataHomePage->get("description")) . "<H4>This page keywords</H4><br/>") . $seoDataHomePage->get("description");
		$htmlLinks = (((((((("<h1>navigation</h1>" . $idSite) . " > ") . $deeplink) . "<h4><a href=\"") . $linksUrlBase) . $websiteConfig->get("CONFIG_START_SECTION")) . "/\">Home page: ") . $seoDataHomePage->get("title")) . "</a></h4>";
		$htmlLinks .= ("<H4>Links of this page (" . $seoData->get("title")) . ")</H4>";
		if($seoData->get("links") !== null) {
			$htmlLinks .= $seoData->get("links");
			;
		}
		$loaderPath = null;
		if(($loaderPath = $websiteConfig->get("loaderPath")) === null) {
			$loaderPath = "loaders/default.swf";
			;
		}
		$templateContext = _hx_anonymous(array("rootPath" => org_silex_serverApi_RootDir::getRootPath(), "rootUrl" => org_silex_serverApi_RootDir::getRootUrl(), "websiteConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($websiteConfig), "serverConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($serverConfig->getSilexServerIni()), "clientConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($serverConfig->getSilexClientIni()), "seoData" => org_silex_html_SilexIndex::fromHashToAnonymous($seoData), "idSite" => $idSite, "silexApiJsScriptFolderUrl" => org_silex_html_SilexIndex::$silexApiJsScriptFolderUrl, "js_str" => $js_str, "deeplink" => $deeplink, "loaderPath" => $loaderPath, "contentFolderForPublication" => $serverConfig->getContentFolderForPublication($idSite), "languagesList" => $serverContent->getLanguagesList(), "doRedirect" => null, "defaultLanguage" => $defaultLanguage, "fv_js_object" => $fv_js_object, "version" => php_io_File::getContent("version.txt"), "htmlTitle" => $htmlTitle, "htmlDescription" => $htmlDescription, "htmlTags" => $htmlTags, "htmlEquivalent" => $htmlEquivalent, "htmlKeywords" => $htmlKeywords, "isDefaultWebsite" => $isDefaultWebsite, "websiteFonts" => org_silex_html_SilexIndex::$websiteFonts));
		$template = new haxe_Template(php_io_File::getContent(org_silex_html_SilexIndex::$pathToMainTemplate));
		org_silex_html_SilexIndex::populateFlashVars($templateContext);
		$hookManager->callHooks("pre-index-head", new _hx_array(array()));
		php_Lib::hprint($template->execute($templateContext, _hx_anonymous(array("nowDate" => (isset(org_silex_html_SilexIndex::$formatNowDate) ? org_silex_html_SilexIndex::$formatNowDate: array("org_silex_html_SilexIndex", "formatNowDate")), "addToFlashVars" => (isset(org_silex_html_SilexIndex::$addToFlashVars) ? org_silex_html_SilexIndex::$addToFlashVars: array("org_silex_html_SilexIndex", "addToFlashVars")), "addToFlashParam" => (isset(org_silex_html_SilexIndex::$addToFlashParam) ? org_silex_html_SilexIndex::$addToFlashParam: array("org_silex_html_SilexIndex", "addToFlashParam")), "printFlashParam" => (isset(org_silex_html_SilexIndex::$printFlashParam) ? org_silex_html_SilexIndex::$printFlashParam: array("org_silex_html_SilexIndex", "printFlashParam")), "flashVarsAsParamString" => (isset(org_silex_html_SilexIndex::$flashVarsAsParamString) ? org_silex_html_SilexIndex::$flashVarsAsParamString: array("org_silex_html_SilexIndex", "flashVarsAsParamString")), "flashParamAsParamString" => (isset(org_silex_html_SilexIndex::$flashParamAsParamString) ? org_silex_html_SilexIndex::$flashParamAsParamString: array("org_silex_html_SilexIndex", "flashParamAsParamString")), "fromHashToArrayOfPair" => (isset(org_silex_html_SilexIndex::$fromHashToArrayOfPair) ? org_silex_html_SilexIndex::$fromHashToArrayOfPair: array("org_silex_html_SilexIndex", "fromHashToArrayOfPair")), "getFlashParam" => (isset(org_silex_html_SilexIndex::$getFlashParam) ? org_silex_html_SilexIndex::$getFlashParam: array("org_silex_html_SilexIndex", "getFlashParam")), "getFlashParamAsArrayOfPair" => (isset(org_silex_html_SilexIndex::$getFlashParamAsArrayOfPair) ? org_silex_html_SilexIndex::$getFlashParamAsArrayOfPair: array("org_silex_html_SilexIndex", "getFlashParamAsArrayOfPair")), "getFlashParamAsHTML" => (isset(org_silex_html_SilexIndex::$getFlashParamAsHTML) ? org_silex_html_SilexIndex::$getFlashParamAsHTML: array("org_silex_html_SilexIndex", "getFlashParamAsHTML")), "callHooks" => (isset(org_silex_html_SilexIndex::$callHooks) ? org_silex_html_SilexIndex::$callHooks: array("org_silex_html_SilexIndex", "callHooks")), "printFlashVars" => (isset(org_silex_html_SilexIndex::$printFlashVars) ? org_silex_html_SilexIndex::$printFlashVars: array("org_silex_html_SilexIndex", "printFlashVars"))))));
		unset($websiteTitle,$websiteKeywords,$websiteConfig,$url,$templateContext,$template,$siteEditor,$silexPluginsConf,$serverContent,$serverConfig,$seoDataHomePage,$seoData,$pluginManager,$mainRssFeed,$loaderPath,$linksUrlBase,$js_str,$isDefaultWebsite,$idSite,$htmlTitle,$htmlTags,$htmlLinks,$htmlKeywords,$htmlEquivalent,$htmlDescription,$hookManager,$fv_js_object,$fst,$fonts,$fontList,$favicon,$doRedirect,$defaultLanguage,$deeplink,$configEditor);
	}
	static function populateFlashVars($params) {
		org_silex_html_SilexIndex::addToFlashParam(null, "movie", (_hx_add($params->rootUrl, $params->loaderPath)) . "?flashId=silex");
		org_silex_html_SilexIndex::addToFlashParam(null, "src", (_hx_add($params->rootUrl, $params->loaderPath)) . "?flashId=silex");
		org_silex_html_SilexIndex::addToFlashParam(null, "type", "application/x-shockwave-flash");
		org_silex_html_SilexIndex::addToFlashParam(null, "bgColor", $params->websiteConfig->bgColor);
		org_silex_html_SilexIndex::addToFlashParam(null, "bgcolor", $params->websiteConfig->bgColor);
		org_silex_html_SilexIndex::addToFlashParam(null, "pluginspage", "http://www.adobe.com/products/flashplayer/");
		org_silex_html_SilexIndex::addToFlashParam(null, "scale", "noscale");
		org_silex_html_SilexIndex::addToFlashParam(null, "swLiveConnect", "true");
		org_silex_html_SilexIndex::addToFlashParam(null, "AllowScriptAccess", "always");
		org_silex_html_SilexIndex::addToFlashParam(null, "allowFullScreen", "true");
		org_silex_html_SilexIndex::addToFlashParam(null, "quality", "best");
		org_silex_html_SilexIndex::addToFlashParam(null, "wmode", "transparent");
		org_silex_html_SilexIndex::addToFlashVars(null, "ENABLE_DEEPLINKING", "false");
		org_silex_html_SilexIndex::addToFlashVars(null, "DEFAULT_WEBSITE", $params->serverConfig->DEFAULT_WEBSITE);
		org_silex_html_SilexIndex::addToFlashVars(null, "id_site", $params->idSite);
		org_silex_html_SilexIndex::addToFlashVars(null, "rootUrl", $params->rootUrl);
		org_silex_html_SilexIndex::addToFlashVars(null, "php_website_config_file", ((_hx_add($params->contentFolderForPublication, $params->idSite)) . "/") . $params->serverConfig->WEBSITE_CONF_FILE);
		org_silex_html_SilexIndex::addToFlashVars(null, "config_files_list", ((((_hx_add($params->contentFolderForPublication, $params->idSite)) . "/") . $params->serverConfig->WEBSITE_CONF_FILE) . ",") . $params->serverConfig->SILEX_CLIENT_CONF_FILES_LIST);
		org_silex_html_SilexIndex::addToFlashVars(null, "flashPlayerVersion", org_silex_html_SilexIndex_1($params));
		org_silex_html_SilexIndex::addToFlashVars(null, "CONFIG_START_SECTION", org_silex_html_SilexIndex_2($params));
		org_silex_html_SilexIndex::addToFlashVars(null, "SILEX_ADMIN_AVAILABLE_LANGUAGES", $params->languagesList);
		org_silex_html_SilexIndex::addToFlashVars(null, "SILEX_ADMIN_DEFAULT_LANGUAGE", $params->serverConfig->SILEX_ADMIN_DEFAULT_LANGUAGE);
		org_silex_html_SilexIndex::addToFlashVars(null, "htmlTitle", $params->htmlTitle);
		org_silex_html_SilexIndex::addToFlashVars(null, "wmode", "transparent");
		$preloadFilesList = ((((_hx_add($params->websiteConfig->layoutFolderPath, $params->websiteConfig->initialLayoutFile)) . ",fp") . $params->websiteConfig->flashPlayerVersion) . "/") . $params->websiteConfig->layerSkinUrl;
		if(org_silex_html_SilexIndex::$websiteFonts !== null && org_silex_html_SilexIndex::$websiteFonts !== "") {
			$preloadFilesList .= "," . org_silex_html_SilexIndex::$websiteFonts;
			;
		}
		org_silex_html_SilexIndex::addToFlashVars(null, "preload_files_list", $preloadFilesList);
		org_silex_html_SilexIndex::addToFlashVars(null, "forceScaleMode", "showAll");
		org_silex_html_SilexIndex::addToFlashVars(null, "initialContentFolderPath", $params->contentFolderForPublication);
		org_silex_html_SilexIndex::addToFlashVars(null, "silex_result_str", "_no_value_");
		org_silex_html_SilexIndex::addToFlashVars(null, "silex_exec_str", "_no_value_");
		org_silex_html_SilexIndex::addToFlashParam(null, "FlashVars", org_silex_html_SilexIndex::flashVarsAsParamString(null));
		unset($preloadFilesList);
	}
	static function escapeHTML($resolve, $str) {
		return StringTools::htmlEscape($str);
		;
	}
	static function callHooks($resolve, $hookName) {
		ob_start();
		org_silex_serverApi_HookManager::getInstance()->callHooks($hookName, new _hx_array(array()));
		$ret = ob_get_contents();
		ob_end_clean();
		return $ret;
		unset($ret);
	}
	static function getFlashParam($resolve) {
		return org_silex_html_SilexIndex::$flashParam;
		;
	}
	static function getFlashParamAsArrayOfPair($resolve) {
		return org_silex_html_SilexIndex::fromHashToArrayOfPair(null, org_silex_html_SilexIndex::getFlashParam(null));
		;
	}
	static function getFlashParamAsHTML($resolve) {
		$res = "";
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			if($k !== "src" && $k !== "pluginspage") {
				$res .= ((("\x0A<param name=\"" . $k) . "\" value=\"") . org_silex_html_SilexIndex::$flashParam->get($k)) . "\"/>";
				;
			}
			;
		}
		}
		return $res;
		unset($res);
	}
	static function addToFlashVars($resolve, $key, $value) {
		org_silex_html_SilexIndex::$flashVars->set($key, $value);
		return "";
		;
	}
	static function addToFlashParam($resolve, $key, $value) {
		org_silex_html_SilexIndex::$flashParam->set($key, $value);
		return "";
		;
	}
	static function printFlashParam($resolve) {
		$resA = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$resA->push(((($k . ":") . "\"") . org_silex_html_SilexIndex::$flashParam->get($k)) . "\"");
			;
		}
		}
		return ("{" . $resA->join(",")) . "}";
		unset($resA);
	}
	static function printFlashVars($resolve) {
		$resA = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashVars) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashVars->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$resA->push(((($k . ":") . "\"") . org_silex_html_SilexIndex::$flashVars->get($k)) . "\"");
			;
		}
		}
		return ("{" . $resA->join(",")) . "}";
		unset($resA);
	}
	static function formatNowDate($resolve) {
		return Date::now()->toString();
		;
	}
	static function flashVarsAsParamString($resolve) {
		$eachString = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashVars) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashVars->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$eachString->push(($k . "=") . org_silex_html_SilexIndex::$flashVars->get($k));
			;
		}
		}
		return $eachString->join("&");
		unset($eachString);
	}
	static function flashParamAsParamString($resolve) {
		$eachString = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$eachString->push((($k . "=\"") . org_silex_html_SilexIndex::$flashParam->get($k)) . "\"");
			;
		}
		}
		return $eachString->join(" ");
		unset($eachString);
	}
	static function fromHashToAnonymous($h) {
		$res = _hx_anonymous(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$res->{$k} = $h->get($k);
			;
		}
		}
		return $res;
		unset($res);
	}
	static function fromHashToArrayOfPair($resolve, $h) {
		$res = new _hx_array(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
		$k = $»it->next();
		{
			$tmp = _hx_anonymous(array("key" => $k, "value" => $h->get($k)));
			$res->push($tmp);
			unset($tmp);
		}
		}
		return $res;
		unset($res);
	}
	static function redirectToInstaller() {
		$temp = new haxe_Template(php_io_File::getContent(org_silex_html_SilexIndex::$pathToRedirectToInstaller));
		$root = org_silex_serverApi_RootDir::getRootUrl();
		if($root === null) {
			$root = "";
			;
		}
		php_Lib::hprint($temp->execute(_hx_anonymous(array("ROOTURL" => $root)), null));
		unset($temp,$root);
	}
	static function notFoundIsNotFound($notFoundName) {
		$temp = new haxe_Template(php_io_File::getContent(org_silex_html_SilexIndex::$pathToNotFoundIsNotFound));
		if($notFoundName === null) {
			$notFoundName = "";
			;
		}
		php_Web::setReturnCode(500);
		php_Lib::hprint($temp->execute(_hx_anonymous(array("notFoundName" => $notFoundName)), null));
		unset($temp);
	}
	function __toString() { return 'org.silex.html.SilexIndex'; }
}
org_silex_html_SilexIndex::$flashVars = new Hash();
org_silex_html_SilexIndex::$flashParam = new Hash();
;
function org_silex_html_SilexIndex_0(&$configEditor, &$deeplink, &$defaultLanguage, &$doRedirect, &$favicon, &$fontList, &$fonts, &$fst, &$fv_js_object, &$hookManager, &$idSite, &$isDefaultWebsite, &$js_str, &$mainRssFeed, &$pluginManager, &$serverConfig, &$serverContent, &$silexPluginsConf, &$siteEditor, &$url, &$websiteConfig, &$websiteKeywords, &$websiteTitle) {
if($serverConfig->getSilexServerIni()->get("USE_URL_REWRITE") === "true") {
	return (org_silex_serverApi_RootDir::getRootUrl() . $idSite) . "/";
	;
}
else {
	return ((org_silex_serverApi_RootDir::getRootUrl() . "?/") . $idSite) . "/";
	;
}
}
function org_silex_html_SilexIndex_1(&$params) {
if(_hx_field($params->websiteConfig, "flashPlayerVersion") !== null) {
	return $params->websiteConfig->flashPlayerVersion;
	;
}
else {
	return "7";
	;
}
}
function org_silex_html_SilexIndex_2(&$params) {
if(_hx_field($params->websiteConfig, "CONFIG_START_SECTION") !== null) {
	return $params->websiteConfig->CONFIG_START_SECTION;
	;
}
else {
	return "start";
	;
}
}