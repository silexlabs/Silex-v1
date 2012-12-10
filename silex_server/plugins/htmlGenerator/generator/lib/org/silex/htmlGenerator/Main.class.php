<?php

class org_silex_htmlGenerator_Main {
	public function __construct(){}
	static function noFlashJS($idSite, $deeplink) {
		$websiteUrl = "'?/" . $idSite . "/" . $deeplink . "&format=html'";
		$scriptTag = "<script type='text/javascript'>\$no_flash_page=" . $websiteUrl . "</script>";
		php_Lib::hprint($scriptTag);
	}
	static function noFlashNoJS($idSite, $deeplink) {
		php_Lib::hprint("<p><a href='" . "?" . $idSite . "/&format=html'>You do not have Flash. You can try to access the HTML version of this site by clicking here.</a></p>");
	}
	static function main() {
		org_silex_filters_FilterManager::addFilter("template-index-head", (isset(org_silex_htmlGenerator_Main::$templateHeadFilter) ? org_silex_htmlGenerator_Main::$templateHeadFilter: array("org_silex_htmlGenerator_Main", "templateHeadFilter")), 1000);
		org_silex_filters_FilterManager::addFilter("template-index-body", (isset(org_silex_htmlGenerator_Main::$templateBodyFilter) ? org_silex_htmlGenerator_Main::$templateBodyFilter: array("org_silex_htmlGenerator_Main", "templateBodyFilter")), 1000);
		org_silex_filters_FilterManager::addFilter("template-index-footer", (isset(org_silex_htmlGenerator_Main::$templateFooterFilter) ? org_silex_htmlGenerator_Main::$templateFooterFilter: array("org_silex_htmlGenerator_Main", "templateFooterFilter")), 1000);
		org_silex_filters_FilterManager::addFilter("template-context", (isset(org_silex_htmlGenerator_Main::$templateContextFilter) ? org_silex_htmlGenerator_Main::$templateContextFilter: array("org_silex_htmlGenerator_Main", "templateContextFilter")), 0);
		org_silex_filters_FilterManager::addFilter("index-remoting-context", (isset(org_silex_htmlGenerator_Main::$remotingContextFilter) ? org_silex_htmlGenerator_Main::$remotingContextFilter: array("org_silex_htmlGenerator_Main", "remotingContextFilter")), 0);
	}
	static function templateHeadFilter($templateName, $context) {
		if(_hx_equal($context->renderer, "html")) {
			return "plugins/htmlGenerator/generator/res/head.html";
		} else {
			return $templateName;
		}
	}
	static function templateBodyFilter($templateName, $context) {
		if(_hx_equal($context->renderer, "html")) {
			return "plugins/htmlGenerator/generator/res/body.html";
		} else {
			return $templateName;
		}
	}
	static function templateFooterFilter($templateName, $context) {
		if(_hx_equal($context->renderer, "html")) {
			return "plugins/htmlGenerator/generator/res/footer.html";
		} else {
			return $templateName;
		}
	}
	static function templateContextFilter($templateContext, $context) {
		$templateContext->isIPad = _hx_deref(new EReg("iPad", "i"))->match($_SERVER["HTTP_USER_AGENT"]) || _hx_deref(new EReg("iPhone", "i"))->match($_SERVER["HTTP_USER_AGENT"]);
		if(_hx_equal($templateContext->renderer, "html")) {
			$renderResult = _hx_anonymous(array("redirectTo" => "", "height" => 0, "width" => 0, "bgColor" => "", "cssCode" => "", "htmlCode" => "", "jsCode" => ""));
			try {
				$renderResult = _hx_deref(new org_silex_htmlGenerator_RenderingEngine())->render(php_Web::getParamsString());
				$renderResult->htmlCode = "<div class=\"SILEXStage\" style=\"position:relative;margin-left:auto;margin-right:auto;width:" . $renderResult->width . "px;height:" . $renderResult->height . "px;background-color:#" . $renderResult->bgColor . "\">" . $renderResult->htmlCode . "</div>";
				if($renderResult->redirectTo !== null && $renderResult->redirectTo !== "?" . php_Web::getParamsString()) {
					header("Location" . ": " . $renderResult->redirectTo);
				}
			}catch(Exception $»e) {
				$_ex_ = ($»e instanceof HException) ? $»e->e : $»e;
				if(($e = $_ex_) instanceof org_silex_htmlGenerator_exceptions_LayerException){
					$»t = $e;
					switch($»t->index) {
					case 0:
					$layer = $»t->params[0];
					{
						$renderResult->htmlCode = "<span class='error'>" . $layer . " layer could not be found.</span>";
					}break;
					case 1:
					$layer = $»t->params[0];
					{
						$renderResult->htmlCode = "<span class='error'>" . $layer . " layer is malformed.</span>";
					}break;
					}
				} else throw $»e;;
			}
			$templateContext->bgColor = $renderResult->bgColor;
			$templateContext->cssCode = $renderResult->cssCode;
			$templateContext->htmlCode = $renderResult->htmlCode;
			$templateContext->jsCode = $renderResult->jsCode;
			return $templateContext;
		} else {
			return $templateContext;
		}
	}
	static function remotingContextFilter($remotingContext, $context) {
		$remotingContext->addObject("HTMLRenderingEngine", new org_silex_htmlGenerator_RenderingEngine(), null);
		return $remotingContext;
	}
	function __toString() { return 'org.silex.htmlGenerator.Main'; }
}
