<?php

class org_silex_htmlGenerator_RenderingEngine {
	public function __construct() { 
	}
	public function getPublicationConfig($publicationName) {
		$siteEditor = new org_silex_serverApi_SiteEditor();
		return $siteEditor->getWebsiteConfig($publicationName, null);
	}
	public function render($url) {
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . "./");
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . "./cgi/library");
		org_silex_serverApi_helpers_Env::setIncludePath(org_silex_serverApi_helpers_Env::getIncludePath() . org_silex_serverApi_helpers_Env::getPathSeparator() . "./cgi/includes");
		$initializedSubLayers = new _hx_array(array());
		$configEditor = new org_silex_serverApi_ConfigEditor();
		$serverConfig = new org_silex_serverApi_ServerConfig();
		$deeplink = org_silex_htmlGenerator_Deeplink::parseURL($url, $serverConfig->getSilexServerIni()->get("DEFAULT_WEBSITE"));
		org_silex_htmlGenerator_Utils::$deeplink = $deeplink;
		$contentsPath = $serverConfig->getContentFolderForPublication($deeplink->publication);
		$silexPluginsConf = $configEditor->readConfigFile($serverConfig->getSilexServerIni()->get("SILEX_PLUGINS_CONF"), "phparray");
		$hookManager = org_silex_serverApi_HookManager::getInstance();
		$siteEditor = new org_silex_serverApi_SiteEditor();
		org_silex_htmlGenerator_Utils::$siteEditor = $siteEditor;
		org_silex_htmlGenerator_InterpreterContext::$websiteConfig = $siteEditor->getWebsiteConfig($deeplink->publication, null);
		$width = Std::parseInt($siteEditor->getWebsiteConfig($deeplink->publication, null)->get("layoutStageWidth"));
		$height = Std::parseInt($siteEditor->getWebsiteConfig($deeplink->publication, null)->get("layoutStageHeight"));
		$bgColor = $siteEditor->getWebsiteConfig($deeplink->publication, null)->get("bgColor");
		$redirectTo = null;
		$redirectTo = null;
		if($deeplink->layers->length === 0) {
			$deeplink->layers->push($siteEditor->getWebsiteConfig($deeplink->publication, null)->get("CONFIG_START_SECTION"));
		}
		$htmlCode = "";
		$layersHTMLEquivalent = new Hash();
		$layerCount = 0;
		$layerPath = new _hx_array(array());
		$idx = 0;
		while($idx <= $deeplink->layers->length) {
			$layer = $deeplink->layers[$idx++];
			$layerPath->push($layer);
			$layerCount++;
			$xmlContent = null;
			try {
				$xmlContent = php_io_File::getContent($contentsPath . $deeplink->publication . "/" . $layer . ".xml");
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e = $_ex_;
				{
					continue;
				}
			}
			$parsedLayer = null;
			try {
				$parsedLayer = org_silex_publication_LayerParser::xml2Layer(Xml::parse($xmlContent));
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				$e2 = $_ex_;
				{
					throw new HException(org_silex_htmlGenerator_exceptions_LayerException::parseError($layer));
				}
			}
			$parsedLayer->name = $layer;
			$orderedSubLayers = null;
			$orderedSubLayers = Lambda::harray($parsedLayer->subLayers);
			{
				$_g = 0;
				while($_g < $orderedSubLayers->length) {
					$subLayer = $orderedSubLayers[$_g];
					++$_g;
					$subLayerInstance = new org_silex_htmlGenerator_SubLayer();
					$subLayerInstance->layerName = $parsedLayer->name;
					$subLayerInstance->subLayerName = $subLayer->id;
					$initializedSubLayers->push($subLayerInstance);
					$comps = Lambda::harray($subLayer->components);
					$comps->reverse();
					{
						$_g1 = 0;
						while($_g1 < $comps->length) {
							$componentModel = $comps[$_g1];
							++$_g1;
							if(trim($componentModel->html5Url) !== "") {
								$pathToLoad = null;
								$pathToLoad = org_silex_serverApi_RootDir::getRootPath() . _hx_array_get(_hx_explode("#", $componentModel->html5Url), 0);
								$pathToLoad = trim($pathToLoad);
								if(_hx_char_at($pathToLoad, strlen($pathToLoad) - 1) === "/") {
									$pathToLoad = _hx_substr($pathToLoad, 0, strlen($pathToLoad) - 1);
								}
								if(trim($pathToLoad) !== "") {
									if(!Lambda::has(org_silex_htmlGenerator_RenderingEngine::$loadedHtml5Modules, $pathToLoad, null)) {
										php_Lib::loadLib($pathToLoad);
										org_silex_htmlGenerator_RenderingEngine::$loadedHtml5Modules->push($pathToLoad);
									}
								}
								unset($pathToLoad);
							}
							$className = _hx_array_get(_hx_explode("#", $componentModel->html5Url), 1);
							$componentInstance = null;
							try {
								$componentInstance = Type::createInstance(Type::resolveClass($className), new _hx_array(array()));
							}catch(Exception $»e) {
								$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
								$e3 = $_ex_;
								{
									$componentInstance = new org_silex_ui_UiBase();
								}
							}
							$componentInstance->__silex__layerPath__ = $layerPath->copy();
							$componentInstance->__silex__publicationName__ = $deeplink->publication;
							if(null == $componentModel->properties) throw new HException('null iterable');
							$»it = $componentModel->properties->keys();
							while($»it->hasNext()) {
								$propertyName = $»it->next();
								if(_hx_has_field($componentInstance, $propertyName)) {
									$componentInstance->{$propertyName} = $componentModel->properties->get($propertyName);
								}
								if($propertyName === "iconIsDefault" && _hx_equal($componentModel->properties->get($propertyName), true) && $layerCount === $deeplink->layers->length) {
									if(!_hx_equal($componentInstance->iconDeeplinkName, "") && _hx_field($componentInstance, "iconDeeplinkName") !== null) {
										$deeplink->layers->push($componentInstance->iconDeeplinkName);
									} else {
										$deeplink->layers->push($componentModel->properties->get("iconPageName"));
									}
								}
							}
							$subLayerInstance->initializedComponents->push(_hx_anonymous(array("componentModel" => $componentModel, "componentInstance" => $componentInstance)));
							org_silex_htmlGenerator_InterpreterContext::$components->set($componentInstance->playerName, $componentInstance);
							if($componentInstance->iconIsIcon) {
								$action = new org_silex_publication_ActionModel();
								$action->functionName = "open";
								$action->modifier = "onRelease";
								$params = new HList();
								if(_hx_equal($componentInstance->iconDeeplinkName, "") || _hx_field($componentInstance, "iconDeeplinkName") === null) {
									$params->add($componentInstance->__silex__layerPath__->join("/") . "/" . $componentInstance->iconPageName . "&amp;format=html");
								} else {
									$params->add($componentInstance->iconDeeplinkName . "&amp;format=html");
								}
								$action->parameters = $params;
								$componentModel->actions->add($action);
								unset($params,$action);
							}
							unset($e3,$componentModel,$componentInstance,$className);
						}
						unset($_g1);
					}
					unset($subLayerInstance,$subLayer,$comps);
				}
				unset($_g);
			}
			unset($xmlContent,$parsedLayer,$orderedSubLayers,$layer,$e2,$e);
		}
		{
			$_g = 0;
			while($_g < $initializedSubLayers->length) {
				$subLayer = $initializedSubLayers[$_g];
				++$_g;
				{
					$_g1 = 0; $_g2 = $subLayer->initializedComponents;
					while($_g1 < $_g2->length) {
						$component = $_g2[$_g1];
						++$_g1;
						if(null == $component->componentModel->actions) throw new HException('null iterable');
						$»it = $component->componentModel->actions->iterator();
						while($»it->hasNext()) {
							$action = $»it->next();
							$action1 = _hx_anonymous(array("component" => $component->componentInstance->playerName, "modifier" => $action->modifier, "functionName" => $action->functionName, "parameters" => Lambda::harray($action->parameters)));
							org_silex_htmlGenerator_JsCommunication::$actions->push($action1);
							org_silex_core_Interpreter::$actions->push($action1);
							unset($action1);
						}
						unset($component);
					}
					unset($_g2,$_g1);
				}
				unset($subLayer);
			}
		}
		org_silex_core_Interpreter::initActions();
		{
			$_g = 0;
			while($_g < $initializedSubLayers->length) {
				$subLayer = $initializedSubLayers[$_g];
				++$_g;
				try {
					$htmlCode .= $subLayer->returnHTML();
				}catch(Exception $»e) {
					$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
					$e = $_ex_;
					{
						$htmlCode .= "EXCEPTION - SubLayer: " . $subLayer->layerName . ") " . Std::string($e);
					}
				}
				unset($subLayer,$e);
			}
		}
		$jsCode = "window.silexActions='" . haxe_Serializer::run(org_silex_htmlGenerator_JsCommunication::$actions) . "';";
		return _hx_anonymous(array("redirectTo" => $redirectTo, "width" => $width, "height" => $height, "bgColor" => $bgColor, "htmlCode" => $htmlCode, "cssCode" => org_silex_htmlGenerator_Utils::getCssText(), "jsCode" => $jsCode));
	}
	static $loadedHtml5Modules;
	function __toString() { return 'org.silex.htmlGenerator.RenderingEngine'; }
}
org_silex_htmlGenerator_RenderingEngine::$loadedHtml5Modules = new _hx_array(array());
