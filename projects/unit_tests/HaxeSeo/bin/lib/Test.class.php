<?php

class Test {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("Test::new");
		$製pos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function testLayerSeoModel() {
		$GLOBALS['%s']->push("Test::testLayerSeoModel");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoData = Test::initLayerSeoModel();
		$layerSeoDataResult = null;
		$fileName = "../test_files/" . "testLayerSeoModel" . ".seodata.xml";
		$deeplink = "start/deeplink";
		$layerSeoModelXml = org_silex_core_seo_LayerSeo::layerSeoModel2Xml($layerSeoData, $deeplink);
		org_silex_core_seo_LayerSeo::writeXml($fileName, $deeplink, $layerSeoModelXml, true);
		$layerSeoXml = org_silex_core_seo_LayerSeo::readXml($fileName, $deeplink);
		$layerSeoDataResult = org_silex_core_seo_LayerSeo::xml2LayerSeoModel($layerSeoXml);
		utest_Assert::equals("lang.config", $layerSeoDataResult->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 197, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("description lang.config", $layerSeoDataResult->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 198, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("org....Image", _hx_array_get($layerSeoDataResult->components, 0)->className, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 200, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("Image1", _hx_array_get($layerSeoDataResult->components, 0)->playerName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 201, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("true", _hx_array_get($layerSeoDataResult->components, 0)->iconIsIcon, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 202, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("<<rootNode>>", _hx_array_get($layerSeoDataResult->components, 0)->specificProperties->get("xmlRootNodePath"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 203, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("<<node1>>", _hx_array_get($layerSeoDataResult->components, 0)->specificProperties->get("formName"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 204, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("title1", _hx_array_get(_hx_array_get($layerSeoDataResult->components, 0)->links, 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 206, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("deeplink1", _hx_array_get(_hx_array_get($layerSeoDataResult->components, 0)->links, 0)->deeplink, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 207, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("link1", _hx_array_get(_hx_array_get($layerSeoDataResult->components, 0)->links, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 208, "className" => "Test", "methodName" => "testLayerSeoModel")));
		utest_Assert::equals("description1", _hx_array_get(_hx_array_get($layerSeoDataResult->components, 0)->links, 0)->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 209, "className" => "Test", "methodName" => "testLayerSeoModel")));
		$GLOBALS['%s']->pop();
	}
	public function testLayerSeoModelNativeArray() {
		$GLOBALS['%s']->push("Test::testLayerSeoModelNativeArray");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoData = Test::initlayerSeoNativeArray();
		$layerSeoDataResult = null;
		$fileName = "../test_files/" . "testLayerSeoModelNativeArray" . ".seodata.xml";
		$deeplink = "start/deeplink";
		$layerSeoModel = org_silex_core_seo_LayerSeo::phpArray2LayerSeoModel($layerSeoData, $deeplink);
		$layerSeoModelXml = org_silex_core_seo_LayerSeo::layerSeoModel2Xml($layerSeoModel, $deeplink);
		org_silex_core_seo_LayerSeo::writeXml($fileName, $deeplink, $layerSeoModelXml, true);
		$layerSeoXml = org_silex_core_seo_LayerSeo::readXml($fileName, $deeplink);
		$layerSeoDataResult = org_silex_core_seo_LayerSeo::xml2LayerSeoModel($layerSeoXml);
		$layerSeoNativeArray = org_silex_core_seo_LayerSeo::layerSeoModel2PhpArray($layerSeoDataResult);
		utest_Assert::equals("titletest1", $layerSeoNativeArray['title'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 239, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("description1", $layerSeoNativeArray['description'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 240, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("org...S", $layerSeoNativeArray['components'][0]['className'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 242, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("Selector", $layerSeoNativeArray['components'][0]['playerName'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 243, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("<<rootNode>>", $layerSeoNativeArray['components'][0]['xmlRootNodePath'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 245, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("t1", $layerSeoNativeArray['components'][0]['links'][0]['title'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 247, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("deep1", $layerSeoNativeArray['components'][0]['links'][0]['deeplink'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 248, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("link1", $layerSeoNativeArray['components'][0]['links'][0]['link'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 249, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		utest_Assert::equals("desc1", $layerSeoNativeArray['components'][0]['links'][0]['description'], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 250, "className" => "Test", "methodName" => "testLayerSeoModelNativeArray")));
		$GLOBALS['%s']->pop();
	}
	public function test_checkAndReadXml_V1() {
		$GLOBALS['%s']->push("Test::test_checkAndReadXml_V1");
		$製pos = $GLOBALS['%s']->length;
		$fileName = "../test_files/" . "testV1" . ".seodata.xml";
		$layerXml = null;
		$layerXml = org_silex_core_seo_LayerSeo::readXml($fileName, null);
		utest_Assert::equals(null, $layerXml, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 268, "className" => "Test", "methodName" => "test_checkAndReadXml_V1")));
		$GLOBALS['%s']->pop();
	}
	public function test_checkAndReadXml_V2() {
		$GLOBALS['%s']->push("Test::test_checkAndReadXml_V2");
		$製pos = $GLOBALS['%s']->length;
		$fileName = "../test_files/" . "testV2" . ".seodata.xml";
		$layerXml = null;
		$layerXml = org_silex_core_seo_LayerSeo::readXml($fileName, null);
		utest_Assert::notEquals(null, $layerXml->firstChild(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 284, "className" => "Test", "methodName" => "test_checkAndReadXml_V2")));
		utest_Assert::equals("layerSeo", $layerXml->getNodeName(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 285, "className" => "Test", "methodName" => "test_checkAndReadXml_V2")));
		utest_Assert::equals("emptyDeeplinkTitle", $layerXml->elementsNamed("title")->next()->firstChild()->toString(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 286, "className" => "Test", "methodName" => "test_checkAndReadXml_V2")));
		$GLOBALS['%s']->pop();
	}
	public function test_xml2LayerSeoModel_V2_1() {
		$GLOBALS['%s']->push("Test::test_xml2LayerSeoModel_V2_1");
		$製pos = $GLOBALS['%s']->length;
		$fileName = "../test_files/" . "testV2" . ".seodata.xml";
		$deeplink = "thisDeeplinkDoesNotExist";
		$layerSeoXml = org_silex_core_seo_LayerSeo::readXml($fileName, $deeplink);
		$layerSeoDataResult = org_silex_core_seo_LayerSeo::xml2LayerSeoModel($layerSeoXml);
		utest_Assert::equals("emptyDeeplinkTitle", $layerSeoDataResult->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 309, "className" => "Test", "methodName" => "test_xml2LayerSeoModel_V2_1")));
		$GLOBALS['%s']->pop();
	}
	static $seoFileExtension = ".seodata.xml";
	static $testFilePath = "../test_files/";
	static function main() {
		$GLOBALS['%s']->push("Test::main");
		$製pos = $GLOBALS['%s']->length;
		Test::init();
		Test::test();
		$GLOBALS['%s']->pop();
	}
	static function init() {
		$GLOBALS['%s']->push("Test::init");
		$製pos = $GLOBALS['%s']->length;
		require_once("../../../../silex_server/rootdir.php");
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library");
		$GLOBALS['%s']->pop();
	}
	static function test() {
		$GLOBALS['%s']->push("Test::test");
		$製pos = $GLOBALS['%s']->length;
		$runner = new utest_Runner();
		$runner->addCase(new Test(), null, null, null, null);
		utest_ui_Report::create($runner, null, null);
		$runner->run();
		$GLOBALS['%s']->pop();
	}
	static function initlayerSeoNativeArray() {
		$GLOBALS['%s']->push("Test::initlayerSeoNativeArray");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoData = null;
		$layerSeoDataHash = new Hash();
		$layerSeoDataHash->set("title", "titletest1");
		$layerSeoDataHash->set("deeplink", "deeplinkTitle1");
		$layerSeoDataHash->set("description", "description1");
		$layerSeoDataHash->set("pubDate", "pubDate1");
		$link1 = new Hash();
		$link1->set("deeplink", "deep1");
		$link1->set("description", "desc1");
		$link1->set("title", "t1");
		$link1->set("link", "link1");
		$link2 = new Hash();
		$link2->set("deeplink", "deep2");
		$link2->set("description", "desc2");
		$link2->set("title", "t2");
		$link2->set("link", "link2");
		$link3 = new Hash();
		$link3->set("deeplink", "deep3");
		$link3->set("description", "desc3");
		$link3->set("title", "t3");
		$link3->set("link", "link3");
		$links1 = new _hx_array(array());
		$links1->push(php_Lib::associativeArrayOfHash($link1));
		$links1->push(php_Lib::associativeArrayOfHash($link2));
		$links2 = new _hx_array(array());
		$links2->push(php_Lib::associativeArrayOfHash($link3));
		$component1 = new Hash();
		$component1->set("playerName", "Selector");
		$component1->set("className", "org...S");
		$component1->set("iconIsIcon", "true");
		$component1->set("urlBase", "media/toto.xml");
		$component1->set("xmlRootNodePath", "<<rootNode>>");
		$component1->set("links", php_Lib::toPhpArray($links1));
		$component2 = new Hash();
		$component2->set("playerName", "Connector");
		$component2->set("htmlEquivalent", "equiv");
		$component2->set("className", "org...C");
		$component2->set("iconIsIcon", "false");
		$component2->set("links", php_Lib::toPhpArray($links2));
		$components = new _hx_array(array());
		$components->push(php_Lib::associativeArrayOfHash($component1));
		$components->push(php_Lib::associativeArrayOfHash($component2));
		$layerSeoDataHash->set("content", php_Lib::toPhpArray($components));
		$layerSeoData = php_Lib::associativeArrayOfHash($layerSeoDataHash);
		{
			$GLOBALS['%s']->pop();
			return $layerSeoData;
		}
		$GLOBALS['%s']->pop();
	}
	static function initLayerSeoModel() {
		$GLOBALS['%s']->push("Test::initLayerSeoModel");
		$製pos = $GLOBALS['%s']->length;
		$layerSeoData = null;
		$layerSeoData->components = new _hx_array(array());
		$layerSeoData->title = "lang.config";
		$layerSeoData->description = "description lang.config";
		$layerSeoData->pubDate = Date::now()->toString();
		$componentSeoModel = null;
		$componentSeoModel->className = "org....Image";
		$componentSeoModel->playerName = "Image1";
		$componentSeoModel->iconIsIcon = "true";
		$componentSeoModel->specificProperties = new Hash();
		$componentSeoModel->specificProperties->set("urlBase", "media/toto.xml");
		$componentSeoModel->specificProperties->set("xmlRootNodePath", "<<rootNode>>");
		$componentSeoModel->specificProperties->set("formName", "<<node1>>");
		$link = null;
		$link->title = "title1";
		$link->deeplink = "deeplink1";
		$link->link = "link1";
		$link->description = "description1";
		$componentSeoModel->links = new _hx_array(array());
		$componentSeoModel->links->push($link);
		$layerSeoData->components->push($componentSeoModel);
		{
			$GLOBALS['%s']->pop();
			return $layerSeoData;
		}
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Test'; }
}
