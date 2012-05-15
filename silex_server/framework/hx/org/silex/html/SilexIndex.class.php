<?php

class org_silex_html_SilexIndex {
	public function __construct(){}
	static function __meta__() { $»args = func_get_args(); return call_user_func_array(self::$__meta__, $»args); }
	static $__meta__;
	static $idSite = "";
	static $deeplink = "";
	static $serverConfig;
	static $siteEditor;
	static $serverContent;
	static $pluginManager;
	static $hookManager;
	static $configEditor;
	static $fileSystemTools;
	static $flashVars;
	static $flashParam;
	static $pathToTemplateHead = "templates/index/head.html";
	static $pathToTemplateBody = "templates/index/body.html";
	static $pathToTemplateFooter = "templates/index/footer.html";
	static $pathToRedirectToInstaller = "templates/index/redirectInstaller.html";
	static $pathToNotFoundIsNotFound = "templates/index/notFoundIsNotFound.html";
	static $silexApiJsScriptFolderUrl;
	static $websitePreloadFileList;
	static $websiteFonts;
	static function main() {
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . org_silex_serverApi_RootDir::getRootPath());
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . org_silex_serverApi_RootDir::getRootPath() . "cgi/library");
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . org_silex_serverApi_RootDir::getRootPath() . "cgi/includes");
		require_once("cgi/includes/ComponentManager.php");
		require_once("cgi/includes/ComponentDescriptor.php");
		$isDefaultWebsite = false;
		$doRedirect = false;
		$url = null;
		$deeplink = "";
		$idSite = null;
		$url = php_Web::getParamsString();
		$url = _hx_array_get(_hx_explode("&", $url), 0);
		$url = urldecode($url);
		if(_hx_index_of($url, "/", null) === 0) {
			if(_hx_char_at($url, strlen($url) - 1) === "/") {
				$url = _hx_substr($url, 0, strlen($url) - 1);
			}
			$url = _hx_substr($url, 1, strlen($url) - 1);
			$tab_url = _hx_explode("/", $url);
			$idSite = $tab_url->shift();
			$deeplink = $tab_url->join("/");
			if($deeplink !== "") {
				$doRedirect = true;
			}
		} else {
			$idSite = php_Web::getParams()->get("id_site");
			if($idSite === null) {
				$isDefaultWebsite = true;
			}
		}
		org_silex_html_SilexIndex::$idSite = $idSite;
		org_silex_html_SilexIndex::$deeplink = $deeplink;
		null;
		null;
		null;
		if(!file_exists("conf/pass.php")) {
			org_silex_html_SilexIndex::redirectToInstaller();
			return;
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
		} else {
			if($idSite === $serverConfig->getSilexServerIni()->get("DEFAULT_WEBSITE")) {
				$isDefaultWebsite = true;
			}
		}
		$js_str = "";
		$fv_js_object = "";
		$fv_object = _hx_anonymous(array());
		if(null == php_Web::getParams()) throw new HException('null iterable');
		$»it = php_Web::getParams()->keys();
		while($»it->hasNext()) {
			$key = $»it->next();
			if(_hx_index_of($key, "/", null) !== -1) {
				continue;
			}
			if($fv_js_object !== "") {
				$fv_js_object .= ",\x0A";
			}
			$fv_js_object .= $key . " : '" . str_replace("'", "\\'", str_replace("\\", "\\\\", php_Web::getParams()->get($key))) . "'";
			$fv_object->{$key} = php_Web::getParams()->get($key);
			$js_str .= "\$" . $key . " = '" . str_replace("'", "\\'", str_replace("\\", "\\\\", php_Web::getParams()->get($key))) . "'; ";
		}
		$websiteConfig = $siteEditor->getWebsiteConfig($idSite, null);
		$renderer = null;
		$renderer = php_Web::getParams()->get("format");
		if($renderer === null || $renderer === "") {
			if($websiteConfig !== null) {
				$renderer = $websiteConfig->get("defaultFormat");
			}
		}
		if($renderer === null || $renderer === "") {
			$renderer = "flash";
		}
		if(php_Web::getParams()->get("autologin") === "1") {
			$renderer = "flash";
		}
		$silexPluginsConf = $configEditor->readConfigFile($serverConfig->getSilexServerIni()->get("SILEX_PLUGINS_CONF"), "phparray");
		$pluginManager->createActivePlugins($silexPluginsConf, $hookManager);
		if($websiteConfig === null) {
			$websiteConfig = $siteEditor->getWebsiteConfig($serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE"), null);
			if($websiteConfig === null) {
				org_silex_html_SilexIndex::notFoundIsNotFound($serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE"));
				return;
			}
			$idSite = $serverConfig->getSilexServerIni()->get("DEFAULT_ERROR_WEBSITE");
			php_Web::setReturnCode(404);
		}
		$websiteConfigPlugins = $websiteConfig->get("PLUGINS_LIST");
		$pluginManager->createActivePlugins($websiteConfig, $hookManager);
		$remotingContext = new haxe_remoting_Context();
		$remotingContext = org_silex_filters_FilterManager::applyFilters($remotingContext, _hx_anonymous(array()), "index-remoting-context");
		if(haxe_remoting_HttpConnection::handleRequest($remotingContext)) {
			return;
		}
		$websiteTitle = $websiteConfig->get("htmlTitle");
		$preloadFileListConf = $websiteConfig->get("PRELOAD_FILES_LIST");
		$preloadFiles = new _hx_array(array());
		if($preloadFileListConf !== null && $preloadFileListConf !== "") {
			{
				$_g = 0; $_g1 = _hx_explode("@", $preloadFileListConf);
				while($_g < $_g1->length) {
					$preloadFile = $_g1[$_g];
					++$_g;
					$preloadFiles->push($preloadFile);
					unset($preloadFile);
				}
			}
			org_silex_html_SilexIndex::$websitePreloadFileList = $preloadFiles->join(",");
		}
		$fontList = $websiteConfig->get("FONTS_LIST");
		$fonts = new _hx_array(array());
		if($fontList !== null && $fontList !== "") {
			{
				$_g = 0; $_g1 = _hx_explode("@", $fontList);
				while($_g < $_g1->length) {
					$fontFile = $_g1[$_g];
					++$_g;
					$fonts->push($serverConfig->getSilexServerIni()->get("FONTS_FOLDER") . $fontFile . "_import.swf");
					unset($fontFile);
				}
			}
			org_silex_html_SilexIndex::$websiteFonts = $fonts->join(",");
		}
		$favicon = "";
		if($websiteConfig->get("htmlIcon") !== null && $websiteConfig->get("htmlIcon") !== "") {
			$favicon = "<link rel=\"shortcut icon\" href=\"" . $websiteConfig->get("htmlIcon") . "\"><link rel=\"icon\" href=\"" . $websiteConfig->get("htmlIcon") . "\">";
		}
		$mainRssFeed = "";
		if($websiteConfig->get("mainRssFeed") !== null && $websiteConfig->get("mainRssFeed") !== "") {
			$mainRssFeed = "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"RSS\" href=\"" . $websiteConfig->get("mainRssFeed") . "\">";
		}
		$websiteKeywords = $websiteConfig->get("htmlKeywords");
		null;
		$defaultLanguage = $websiteConfig->get("DEFAULT_LANGUAGE");
		$linksUrlBase = org_silex_html_SilexIndex_0($configEditor, $deeplink, $defaultLanguage, $doRedirect, $favicon, $fontList, $fonts, $fst, $fv_js_object, $fv_object, $hookManager, $idSite, $isDefaultWebsite, $js_str, $mainRssFeed, $pluginManager, $preloadFileListConf, $preloadFiles, $remotingContext, $renderer, $serverConfig, $serverContent, $silexPluginsConf, $siteEditor, $url, $websiteConfig, $websiteConfigPlugins, $websiteKeywords, $websiteTitle);
		$seoDataHomePage = $siteEditor->getSectionSeoData($idSite, $websiteConfig->get("CONFIG_START_SECTION"), $linksUrlBase);
		$seoData = null;
		null;
		if($deeplink !== null && $deeplink !== "") {
			null;
			$seoData = $siteEditor->getSectionSeoData($idSite, $deeplink, $linksUrlBase);
		} else {
			null;
			$seoData = $seoDataHomePage;
			$deeplink = "";
		}
		$subLayersTitle = null;
		$subLayersTitle = "";
		$subLayersTitle = $seoData->get("title");
		null;
		$htmlTitle = $websiteConfig->get("htmlTitle");
		$htmlDescription = $seoData->get("description");
		if($websiteConfig->exists("htmlDescription")) {
			$htmlDescription = $websiteConfig->get("htmlDescription");
		} else {
			$htmlDescription = "";
		}
		$htmlTags = urldecode($seoData->get("tags"));
		$htmlEquivalent = "<H4>This page content</H4><br/>" . $seoData->get("htmlEquivalent");
		$htmlHeaderKeywords = $websiteKeywords . $seoDataHomePage->get("description");
		$htmlKeywords = "<H4>Website keywords</H4><br/>" . $websiteKeywords . "<H4>This page keywords</H4><br/>" . $seoDataHomePage->get("description");
		$htmlLinks = "<h1>navigation</h1>" . $idSite . " > " . $deeplink . "<h4><a href=\"" . $linksUrlBase . $websiteConfig->get("CONFIG_START_SECTION") . "/\">Home page: " . $seoDataHomePage->get("title") . "</a></h4>";
		$htmlLinks .= "<H4>Links of this page (" . $seoData->get("title") . ")</H4>";
		if($seoData->get("links") !== null) {
			$htmlLinks .= $seoData->get("links");
		}
		$loaderPath = null;
		if(($loaderPath = $websiteConfig->get("loaderPath")) === null) {
			$loaderPath = "loaders/default.swf";
		}
		if(Std::parseInt($websiteConfig->get("flashPlayerVersion")) < 8) {
			$websiteConfig->set("flashPlayerVersion", "8");
		}
		$templateContext = _hx_anonymous(array("rootPath" => org_silex_serverApi_RootDir::getRootPath(), "rootUrl" => org_silex_serverApi_RootDir::getRootUrl(), "websiteConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($websiteConfig), "serverConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($serverConfig->getSilexServerIni()), "clientConfig" => org_silex_html_SilexIndex::fromHashToAnonymous($serverConfig->getSilexClientIni()), "seoData" => org_silex_html_SilexIndex::fromHashToAnonymous($seoData), "idSite" => $idSite, "silexApiJsScriptFolderUrl" => org_silex_html_SilexIndex::$silexApiJsScriptFolderUrl, "js_str" => $js_str, "deeplink" => $deeplink, "loaderPath" => $loaderPath, "contentFolderForPublication" => $serverConfig->getContentFolderForPublication($idSite), "languagesList" => $serverContent->getLanguagesList(), "doRedirect" => $doRedirect, "defaultLanguage" => $defaultLanguage, "fv_js_object" => $fv_js_object, "version" => php_io_File::getContent("version.txt"), "htmlTitle" => $htmlTitle, "htmlDescription" => $htmlDescription, "htmlTags" => $htmlTags, "htmlEquivalent" => $htmlEquivalent, "htmlHeaderKeywords" => $htmlHeaderKeywords, "htmlKeywords" => $htmlKeywords, "isDefaultWebsite" => $isDefaultWebsite, "websiteFonts" => org_silex_html_SilexIndex::$websiteFonts, "websitePreloadFileList" => org_silex_html_SilexIndex::$websitePreloadFileList, "websiteConfigPlugins" => $websiteConfigPlugins, "subLayersTitle" => $subLayersTitle, "renderer" => $renderer, "shouldDisplayRenderer" => $renderer !== "flash"));
		$templateContext = org_silex_filters_FilterManager::applyFilters($templateContext, _hx_anonymous(array()), "template-context");
		$templateMacros = _hx_anonymous(array("nowDate" => (isset(org_silex_html_SilexIndex::$formatNowDate) ? org_silex_html_SilexIndex::$formatNowDate: array("org_silex_html_SilexIndex", "formatNowDate")), "addToFlashVars" => (isset(org_silex_html_SilexIndex::$addToFlashVars) ? org_silex_html_SilexIndex::$addToFlashVars: array("org_silex_html_SilexIndex", "addToFlashVars")), "addToFlashParam" => (isset(org_silex_html_SilexIndex::$addToFlashParam) ? org_silex_html_SilexIndex::$addToFlashParam: array("org_silex_html_SilexIndex", "addToFlashParam")), "printFlashParam" => (isset(org_silex_html_SilexIndex::$printFlashParam) ? org_silex_html_SilexIndex::$printFlashParam: array("org_silex_html_SilexIndex", "printFlashParam")), "flashVarsAsParamString" => (isset(org_silex_html_SilexIndex::$flashVarsAsParamString) ? org_silex_html_SilexIndex::$flashVarsAsParamString: array("org_silex_html_SilexIndex", "flashVarsAsParamString")), "flashParamAsParamString" => (isset(org_silex_html_SilexIndex::$flashParamAsParamString) ? org_silex_html_SilexIndex::$flashParamAsParamString: array("org_silex_html_SilexIndex", "flashParamAsParamString")), "fromHashToArrayOfPair" => (isset(org_silex_html_SilexIndex::$fromHashToArrayOfPair) ? org_silex_html_SilexIndex::$fromHashToArrayOfPair: array("org_silex_html_SilexIndex", "fromHashToArrayOfPair")), "getFlashParam" => (isset(org_silex_html_SilexIndex::$getFlashParam) ? org_silex_html_SilexIndex::$getFlashParam: array("org_silex_html_SilexIndex", "getFlashParam")), "getFlashParamAsArrayOfPair" => (isset(org_silex_html_SilexIndex::$getFlashParamAsArrayOfPair) ? org_silex_html_SilexIndex::$getFlashParamAsArrayOfPair: array("org_silex_html_SilexIndex", "getFlashParamAsArrayOfPair")), "getFlashParamAsHTML" => (isset(org_silex_html_SilexIndex::$getFlashParamAsHTML) ? org_silex_html_SilexIndex::$getFlashParamAsHTML: array("org_silex_html_SilexIndex", "getFlashParamAsHTML")), "callHooks" => (isset(org_silex_html_SilexIndex::$callHooks) ? org_silex_html_SilexIndex::$callHooks: array("org_silex_html_SilexIndex", "callHooks")), "printFlashVars" => (isset(org_silex_html_SilexIndex::$printFlashVars) ? org_silex_html_SilexIndex::$printFlashVars: array("org_silex_html_SilexIndex", "printFlashVars")), "encodeUrl" => (isset(org_silex_html_SilexIndex::$encodeUrl) ? org_silex_html_SilexIndex::$encodeUrl: array("org_silex_html_SilexIndex", "encodeUrl"))));
		$hookManager->callHooks("pre-index-head", new _hx_array(array($templateContext)));
		org_silex_html_SilexIndex::populateFlashVars($templateContext, $fv_object);
		$templateHead = new haxe_Template(php_io_File::getContent(org_silex_filters_FilterManager::applyFilters(org_silex_html_SilexIndex::$pathToTemplateHead, $templateContext, "template-index-head")));
		php_Lib::hprint($templateHead->execute($templateContext, $templateMacros));
		$templateBody = new haxe_Template(php_io_File::getContent(org_silex_filters_FilterManager::applyFilters(org_silex_html_SilexIndex::$pathToTemplateBody, $templateContext, "template-index-body")));
		php_Lib::hprint($templateBody->execute($templateContext, $templateMacros));
		$templateFooter = new haxe_Template(php_io_File::getContent(org_silex_filters_FilterManager::applyFilters(org_silex_html_SilexIndex::$pathToTemplateFooter, $templateContext, "template-index-footer")));
		php_Lib::hprint($templateFooter->execute($templateContext, $templateMacros));
	}
	static function populateFlashVars($params, $fv_object) {
		org_silex_html_SilexIndex::addToFlashParam(null, "movie", _hx_add($params->rootUrl, $params->loaderPath) . "?flashId=silex");
		org_silex_html_SilexIndex::addToFlashParam(null, "src", _hx_add($params->rootUrl, $params->loaderPath) . "?flashId=silex");
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
		org_silex_html_SilexIndex::addToFlashVars(null, "php_website_config_file", _hx_add($params->contentFolderForPublication, $params->idSite) . "/" . $params->serverConfig->WEBSITE_CONF_FILE);
		org_silex_html_SilexIndex::addToFlashVars(null, "config_files_list", _hx_add($params->contentFolderForPublication, $params->idSite) . "/" . $params->serverConfig->WEBSITE_CONF_FILE . "," . $params->serverConfig->SILEX_CLIENT_CONF_FILES_LIST);
		org_silex_html_SilexIndex::addToFlashVars(null, "flashPlayerVersion", org_silex_html_SilexIndex_1($fv_object, $params));
		org_silex_html_SilexIndex::addToFlashVars(null, "CONFIG_START_SECTION", org_silex_html_SilexIndex_2($fv_object, $params));
		org_silex_html_SilexIndex::addToFlashVars(null, "SILEX_ADMIN_AVAILABLE_LANGUAGES", $params->languagesList);
		org_silex_html_SilexIndex::addToFlashVars(null, "SILEX_ADMIN_DEFAULT_LANGUAGE", $params->serverConfig->SILEX_ADMIN_DEFAULT_LANGUAGE);
		org_silex_html_SilexIndex::addToFlashVars(null, "htmlTitle", $params->htmlTitle);
		org_silex_html_SilexIndex::addToFlashVars(null, "wmode", "transparent");
		$preloadFilesList = _hx_add($params->websiteConfig->layoutFolderPath, $params->websiteConfig->initialLayoutFile);
		if(org_silex_html_SilexIndex::$websitePreloadFileList !== null && org_silex_html_SilexIndex::$websitePreloadFileList !== "") {
			$preloadFilesList .= "," . org_silex_html_SilexIndex::$websitePreloadFileList;
		}
		if(org_silex_html_SilexIndex::$websiteFonts !== null && org_silex_html_SilexIndex::$websiteFonts !== "") {
			$preloadFilesList .= "," . org_silex_html_SilexIndex::$websiteFonts;
		}
		org_silex_html_SilexIndex::addToFlashVars(null, "preload_files_list", $preloadFilesList);
		org_silex_html_SilexIndex::addToFlashVars(null, "forceScaleMode", "showAll");
		org_silex_html_SilexIndex::addToFlashVars(null, "initialContentFolderPath", $params->contentFolderForPublication);
		org_silex_html_SilexIndex::addToFlashVars(null, "silex_result_str", "_no_value_");
		org_silex_html_SilexIndex::addToFlashVars(null, "silex_exec_str", "_no_value_");
		$propName = null;
		{
			$_g = 0; $_g1 = Reflect::fields($fv_object);
			while($_g < $_g1->length) {
				$propName1 = $_g1[$_g];
				++$_g;
				org_silex_html_SilexIndex::addToFlashVars(null, $propName1, Reflect::field($fv_object, $propName1));
				unset($propName1);
			}
		}
		org_silex_html_SilexIndex::addToFlashParam(null, "FlashVars", org_silex_html_SilexIndex::flashVarsAsParamString(null));
	}
	static function escapeHTML($resolve, $str) {
		return StringTools::htmlEscape($str);
	}
	static function encodeUrl($resolve, $str) {
		return rawurlencode($str);
	}
	static function callHooks($resolve, $hookName) {
		ob_start();
		org_silex_serverApi_HookManager::getInstance()->callHooks($hookName, new _hx_array(array(org_silex_html_SilexIndex::$idSite, org_silex_html_SilexIndex::$deeplink)));
		$ret = ob_get_contents();
		ob_end_clean();
		return $ret;
	}
	static function getFlashParam($resolve) {
		return org_silex_html_SilexIndex::$flashParam;
	}
	static function getFlashParamAsArrayOfPair($resolve) {
		return org_silex_html_SilexIndex::fromHashToArrayOfPair(null, org_silex_html_SilexIndex::getFlashParam(null));
	}
	static function getFlashParamAsHTML($resolve) {
		$res = "";
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			if($k !== "src" && $k !== "pluginspage") {
				$res .= "\x0A<param name=\"" . $k . "\" value=\"" . org_silex_html_SilexIndex::$flashParam->get($k) . "\"/>";
			}
		}
		return $res;
	}
	static function addToFlashVars($resolve, $key, $value) {
		org_silex_html_SilexIndex::$flashVars->set($key, $value);
		return "";
	}
	static function addToFlashParam($resolve, $key, $value) {
		org_silex_html_SilexIndex::$flashParam->set($key, $value);
		return "";
	}
	static function printFlashParam($resolve) {
		$resA = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$resA->push($k . ":" . "\"" . org_silex_html_SilexIndex::$flashParam->get($k) . "\"");
		}
		return "{" . $resA->join(",") . "}";
	}
	static function printFlashVars($resolve) {
		$resA = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashVars) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashVars->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$resA->push($k . ":" . "\"" . org_silex_html_SilexIndex::$flashVars->get($k) . "\"");
		}
		return "{" . $resA->join(",") . "}";
	}
	static function formatNowDate($resolve) {
		return Date::now()->toString();
	}
	static function flashVarsAsParamString($resolve) {
		$eachString = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashVars) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashVars->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$eachString->push($k . "=" . org_silex_html_SilexIndex::$flashVars->get($k));
		}
		return $eachString->join("&");
	}
	static function flashParamAsParamString($resolve) {
		$eachString = new _hx_array(array());
		if(null == org_silex_html_SilexIndex::$flashParam) throw new HException('null iterable');
		$»it = org_silex_html_SilexIndex::$flashParam->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$eachString->push($k . "=\"" . org_silex_html_SilexIndex::$flashParam->get($k) . "\"");
		}
		return $eachString->join(" ");
	}
	static function fromHashToAnonymous($h) {
		$res = _hx_anonymous(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$res->{$k} = $h->get($k);
		}
		return $res;
	}
	static function fromHashToArrayOfPair($resolve, $h) {
		$res = new _hx_array(array());
		if(null == $h) throw new HException('null iterable');
		$»it = $h->keys();
		while($»it->hasNext()) {
			$k = $»it->next();
			$tmp = _hx_anonymous(array("key" => $k, "value" => $h->get($k)));
			$res->push($tmp);
			unset($tmp);
		}
		return $res;
	}
	static function redirectToInstaller() {
		$temp = new haxe_Template(php_io_File::getContent(org_silex_html_SilexIndex::$pathToRedirectToInstaller));
		$root = org_silex_serverApi_RootDir::getRootUrl();
		if($root === null) {
			$root = "";
		}
		php_Lib::hprint($temp->execute(_hx_anonymous(array("ROOTURL" => $root)), null));
	}
	static function notFoundIsNotFound($notFoundName) {
		$temp = new haxe_Template(php_io_File::getContent(org_silex_html_SilexIndex::$pathToNotFoundIsNotFound));
		if($notFoundName === null) {
			$notFoundName = "";
		}
		php_Web::setReturnCode(500);
		php_Lib::hprint($temp->execute(_hx_anonymous(array("notFoundName" => $notFoundName)), null));
	}
	function __toString() { return 'org.silex.html.SilexIndex'; }
}
org_silex_html_SilexIndex::$__meta__ = _hx_anonymous(array("obj" => _hx_anonymous(array("appliedFilters" => new _hx_array(array(new _hx_array(array("template-index-head", "template-index-body", "template-index-footer", "template-context"))))))));
org_silex_html_SilexIndex::$flashVars = new Hash();
org_silex_html_SilexIndex::$flashParam = new Hash();
function org_silex_html_SilexIndex_0(&$configEditor, &$deeplink, &$defaultLanguage, &$doRedirect, &$favicon, &$fontList, &$fonts, &$fst, &$fv_js_object, &$fv_object, &$hookManager, &$idSite, &$isDefaultWebsite, &$js_str, &$mainRssFeed, &$pluginManager, &$preloadFileListConf, &$preloadFiles, &$remotingContext, &$renderer, &$serverConfig, &$serverContent, &$silexPluginsConf, &$siteEditor, &$url, &$websiteConfig, &$websiteConfigPlugins, &$websiteKeywords, &$websiteTitle) {
	if($serverConfig->getSilexServerIni()->get("USE_URL_REWRITE") === "true") {
		return org_silex_serverApi_RootDir::getRootUrl() . $idSite . "/";
	} else {
		return org_silex_serverApi_RootDir::getRootUrl() . "?/" . $idSite . "/";
	}
}
function org_silex_html_SilexIndex_1(&$fv_object, &$params) {
	if(_hx_field($params->websiteConfig, "flashPlayerVersion") !== null) {
		return $params->websiteConfig->flashPlayerVersion;
	} else {
		return "7";
	}
}
function org_silex_html_SilexIndex_2(&$fv_object, &$params) {
	if(_hx_field($params->websiteConfig, "CONFIG_START_SECTION") !== null) {
		return $params->websiteConfig->CONFIG_START_SECTION;
	} else {
		return "start";
	}
}
