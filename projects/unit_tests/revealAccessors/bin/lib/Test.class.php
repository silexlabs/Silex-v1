<?php

class Test {
	public function __construct() {
		if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("Test::new");
		$»spos = $GLOBALS['%s']->length;
		$idSite = "id_du_site";
		$this->_initAccessor = org_silex_core_AccessorManager::getInstance($idSite)->accessors;
		$GLOBALS['%s']->pop();
	}}
	public $_initAccessor;
	public function test0_splitTags() {
		$GLOBALS['%s']->push("Test::test0_splitTags");
		$»spos = $GLOBALS['%s']->length;
		utest_Assert::same(new _hx_array(array()), org_silex_core_AccessorManager::splitTags(null, null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 50, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array()), org_silex_core_AccessorManager::splitTags("", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 51, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1")), org_silex_core_AccessorManager::splitTags("item1", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 54, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2")), org_silex_core_AccessorManager::splitTags("item1((item2))", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 55, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2", "item3")), org_silex_core_AccessorManager::splitTags("item1((item2))item3", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 56, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2", "item3")), org_silex_core_AccessorManager::splitTags("((item1))((item2))((item3))", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 57, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2")), org_silex_core_AccessorManager::splitTags("item1((item2", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 60, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2")), org_silex_core_AccessorManager::splitTags("item1))item2", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 61, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2", "item3")), org_silex_core_AccessorManager::splitTags("item1))item2((item3", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 62, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2", "item3")), org_silex_core_AccessorManager::splitTags("item1((((item2))item3", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 63, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "", "item2", "", "item3")), org_silex_core_AccessorManager::splitTags("item1(())item2(())item3", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 64, "className" => "Test", "methodName" => "test0_splitTags")));
		utest_Assert::same(new _hx_array(array("item1", "item2", "))item3")), org_silex_core_AccessorManager::splitTags("item1((item2))))item3", null, null), null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 65, "className" => "Test", "methodName" => "test0_splitTags")));
		$GLOBALS['%s']->pop();
	}
	public function test2_getTarget() {
		$GLOBALS['%s']->push("Test::test2_getTarget");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <title><![CDATA[ActualitÃ© NÂ°1]]></title>\x0A            <description><![CDATA[Ceci est ma premiÃ¨re actualitÃ©]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		$generatedOutput->{"silex"} = $this->_initAccessor->silex;
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget(null, new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 101, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("", new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 102, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("test", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 103, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("silex", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 104, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("silex.toto", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 105, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("silex.config", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 106, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("silex.config.check", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 107, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals("http://localhost/silex_trunk/projects/unit_tests/revealAccessors/bin/", org_silex_core_AccessorManager::getTarget("silex.rootUrl", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 111, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals($generatedOutput->silex->config->id_site, org_silex_core_AccessorManager::getTarget("silex.config.id_site", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 113, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(null, org_silex_core_AccessorManager::getTarget("blablabla", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 115, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals($generatedOutput->channel->title, org_silex_core_AccessorManager::getTarget("channel.title", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 116, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->title, _hx_array_get(org_silex_core_AccessorManager::getTarget("channel.item", $generatedOutput, null), 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 117, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->description, _hx_array_get(org_silex_core_AccessorManager::getTarget("channel.item", $generatedOutput, null), 0)->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 118, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->pubDate, _hx_array_get(org_silex_core_AccessorManager::getTarget("channel.item", $generatedOutput, null), 0)->pubDate, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 119, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->link, _hx_array_get(org_silex_core_AccessorManager::getTarget("channel.item", $generatedOutput, null), 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 120, "className" => "Test", "methodName" => "test2_getTarget")));
		$silexConfig = new org_silex_serverApi_ServerConfig();
		utest_Assert::equals($silexConfig->getSilexServerIni()->get("DEFAULT_WEBSITE"), org_silex_core_AccessorManager::getTarget("silex.config.DEFAULT_WEBSITE", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 125, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals("manager", org_silex_core_AccessorManager::getTarget("silex.config.DEFAULT_WEBSITE", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 126, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals($silexConfig->getSilexClientIni()->get("accessorsLeftTag"), org_silex_core_AccessorManager::getTarget("silex.config.accessorsLeftTag", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 127, "className" => "Test", "methodName" => "test2_getTarget")));
		utest_Assert::equals($silexConfig->getSilexServerIni()->get("DEFAULT_WEBSITE"), $silexConfig->getSilexClientIni()->get("DEFAULT_WEBSITE"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 130, "className" => "Test", "methodName" => "test2_getTarget")));
		$GLOBALS['%s']->pop();
	}
	public function test3Rss1_revealAccessors() {
		$GLOBALS['%s']->push("Test::test3Rss1_revealAccessors");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <title><![CDATA[ActualitÃ© NÂ°1]]></title>\x0A            <description><![CDATA[Ceci est ma premiÃ¨re actualitÃ©]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		$generatedOutput->{"silex"} = $this->_initAccessor->silex;
		utest_Assert::equals("", org_silex_core_AccessorManager::revealAccessors(null, new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 170, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("", org_silex_core_AccessorManager::revealAccessors("", new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 171, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("test", org_silex_core_AccessorManager::revealAccessors("test", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 172, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("http://localhost/silex_trunk/projects/unit_tests/revealAccessors/bin/", org_silex_core_AccessorManager::getTarget("silex.rootUrl", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 179, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals($generatedOutput->silex->config->id_site, org_silex_core_AccessorManager::revealAccessors("<<silex.config.id_site>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 182, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("contents_themes/", org_silex_core_AccessorManager::revealAccessors("<<silex.config.initialContentFolderPath>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 184, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("test1", org_silex_core_AccessorManager::revealAccessors("test1", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 187, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("test1", org_silex_core_AccessorManager::revealAccessors("((test1))", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 188, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals($generatedOutput->channel->title, org_silex_core_AccessorManager::revealAccessors("<<channel.title>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 189, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals(_hx_add($generatedOutput->channel->title, $generatedOutput->channel->description), org_silex_core_AccessorManager::revealAccessors("<<channel.title>><<channel.description>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 190, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals($generatedOutput->channel->title . "string" . $generatedOutput->channel->description, org_silex_core_AccessorManager::revealAccessors("<<channel.title>>string<<channel.description>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 191, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("string1" . $generatedOutput->channel->title . "string2" . $generatedOutput->channel->description . "string3", org_silex_core_AccessorManager::revealAccessors("string1<<channel.title>>string2<<channel.description>>string3", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 192, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("ActualitÃ© NÂ°1", _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 195, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->title, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 196, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->description, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 197, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("channel.title", org_silex_core_AccessorManager::revealAccessors("<<channel.title", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 211, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("string1channel.titlestring2", org_silex_core_AccessorManager::revealAccessors("<<string1<<channel.title<<string2<<", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 212, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		utest_Assert::equals("string1channel.titlestring2", org_silex_core_AccessorManager::revealAccessors("string1<<channel.title<<string2<<", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 213, "className" => "Test", "methodName" => "test3Rss1_revealAccessors")));
		$GLOBALS['%s']->pop();
	}
	public function test4Rss2_revealAccessors() {
		$GLOBALS['%s']->push("Test::test4Rss2_revealAccessors");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <title><![CDATA[ActualitÃ© NÂ°1]]></title>\x0A            <description><![CDATA[Ceci est ma premiÃ¨re actualitÃ©]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A        <item>\x0A            <title><![CDATA[ActualitÃ© NÂ°2]]></title>\x0A            <description><![CDATA[Ceci est ma deuxiÃ¨me actualitÃ©]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu2</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		$generatedOutput->{"silex"} = $this->_initAccessor->silex;
		utest_Assert::equals("", org_silex_core_AccessorManager::revealAccessors(null, new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 255, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("", org_silex_core_AccessorManager::revealAccessors("", new _hx_array(array("item1")), null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 256, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("test", org_silex_core_AccessorManager::revealAccessors("test", null, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 257, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals($generatedOutput->silex->config->id_site, org_silex_core_AccessorManager::revealAccessors("<<silex.config.id_site>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 264, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("test1", org_silex_core_AccessorManager::revealAccessors("test1", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 266, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("test1", org_silex_core_AccessorManager::revealAccessors("((test1))", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 267, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals($generatedOutput->channel->title, org_silex_core_AccessorManager::revealAccessors("<<channel.title>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 268, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals(_hx_add($generatedOutput->channel->title, $generatedOutput->channel->description), org_silex_core_AccessorManager::revealAccessors("<<channel.title>><<channel.description>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 269, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals($generatedOutput->channel->title . "string" . $generatedOutput->channel->description, org_silex_core_AccessorManager::revealAccessors("<<channel.title>>string<<channel.description>>", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 270, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("string1" . $generatedOutput->channel->title . "string2" . $generatedOutput->channel->description . "string3", org_silex_core_AccessorManager::revealAccessors("string1<<channel.title>>string2<<channel.description>>string3", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 271, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("ActualitÃ© NÂ°1", _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 274, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->title, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 275, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 0)->description, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 0)->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 276, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("ActualitÃ© NÂ°2", _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 1)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 277, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 1)->title, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 1)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 278, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals(_hx_array_get($generatedOutput->channel->item, 1)->description, _hx_array_get(org_silex_core_AccessorManager::revealAccessors("<<channel.item>>", $generatedOutput, null), 1)->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 279, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("channel.title", org_silex_core_AccessorManager::revealAccessors("<<channel.title", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 287, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("string1channel.titlestring2", org_silex_core_AccessorManager::revealAccessors("<<string1<<channel.title<<string2<<", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 288, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		utest_Assert::equals("string1channel.titlestring2", org_silex_core_AccessorManager::revealAccessors("string1<<channel.title<<string2<<", $generatedOutput, null), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 289, "className" => "Test", "methodName" => "test4Rss2_revealAccessors")));
		$GLOBALS['%s']->pop();
	}
	public function testRss1() {
		$GLOBALS['%s']->push("Test::testRss1");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <title><![CDATA[ActualitÃ© NÂ°1]]></title>\x0A            <description><![CDATA[Ceci est ma premiÃ¨re actualitÃ©]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 323, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("Ceci est un exemple de flux RSS 2.0", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 324, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("http://www.example.org", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 325, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("http://www.example.org/actu1", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 326, "className" => "Test", "methodName" => "testRss1")));
		$GLOBALS['%s']->pop();
	}
	public function testXml0() {
		$GLOBALS['%s']->push("Test::testXml0");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<root>\x0A\x09\x09\x09<user name=\"john\">\x0A\x09\x09\x09</user>\x0A\x09\x09\x09</root>\x0A\x09\x09\x09";
		$inputXml = Xml::parse($inputString);
		$output = _hx_anonymous(array());
		$output->user = _hx_anonymous(array());
		$output->user->attributes = _hx_anonymous(array());
		$output->user->attributes->name = "john";
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("john", $generatedOutput->user->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 354, "className" => "Test", "methodName" => "testXml0")));
		$GLOBALS['%s']->pop();
	}
	public function testXml1() {
		$GLOBALS['%s']->push("Test::testXml1");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<root>\x0A\x09\x09\x09<user name=\"john\">\x0A\x09\x09\x09\x09<phone>\x0A\x09\x09\x09\x09\x09<number>0000</number>\x0A\x09\x09\x09\x09\x09<number>111</number>\x0A\x09\x09\x09\x09</phone>\x0A\x09\x09\x09</user>\x0A\x09\x09\x09<user name=\"raph\">\x0A\x09\x09\x09\x09<phone>\x0A\x09\x09\x09\x09\x09<number>2222</number>\x0A\x09\x09\x09\x09\x09<number>333</number>\x0A\x09\x09\x09\x09</phone>\x0A\x09\x09\x09</user>\x0A\x09\x09\x09</root>\x0A\x09\x09\x09";
		$inputXml = Xml::parse($inputString);
		$output = _hx_anonymous(array());
		$output->user = _hx_anonymous(array());
		$output->user->attributes = _hx_anonymous(array());
		$output->user->attributes->name = "john";
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("john", _hx_array_get($generatedOutput->user, 0)->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 392, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("0000", _hx_array_get($generatedOutput->user, 0)->phone->number[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 393, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("111", _hx_array_get($generatedOutput->user, 0)->phone->number[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 394, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("raph", _hx_array_get($generatedOutput->user, 1)->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 396, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("2222", _hx_array_get($generatedOutput->user, 1)->phone->number[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 397, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("333", _hx_array_get($generatedOutput->user, 1)->phone->number[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 398, "className" => "Test", "methodName" => "testXml1")));
		$GLOBALS['%s']->pop();
	}
	public function testXml2() {
		$GLOBALS['%s']->push("Test::testXml2");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<layer>\x0A\x09<subLayers>\x0A\x09\x09<subLayer zIndex=\"5\" id=\"fade\">\x0A\x09\x09\x09<components>\x0A\x09\x09\x09\x09<component>\x0A\x09\x09\x09\x09\x09<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>\x0A\x09\x09\x09\x09\x09<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>\x0A\x09\x09\x09\x09\x09<className>org.silex.ui.players.Image</className>\x0A\x09\x09\x09\x09\x09<componentRoot>main</componentRoot>\x0A\x09\x09\x09\x09\x09<properties>\x0A\x09\x09\x09\x09\x09\x09<playerName><![CDATA[logosilex4]]></playerName>\x0A\x09\x09\x09\x09\x09\x09<rotation type=\"Integer\">0</rotation>\x0A\x09\x09\x09\x09\x09\x09<y type=\"Integer\">16</y>\x0A\x09\x09\x09\x09\x09\x09<x type=\"Integer\">0</x>\x0A\x09\x09\x09\x09\x09\x09<alpha type=\"Integer\">100</alpha>\x0A\x09\x09\x09\x09\x09\x09<tabIndex type=\"Integer\">1</tabIndex>\x0A\x09\x09\x09\x09\x09\x09<tabEnabled type=\"Boolean\">false</tabEnabled>\x0A\x09\x09\x09\x09\x09\x09<tooltipText><![CDATA[]]></tooltipText>\x0A\x09\x09\x09\x09\x09\x09<visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin>\x0A\x09\x09\x09\x09\x09\x09<iconIsDefault type=\"Boolean\">false</iconIsDefault>\x0A\x09\x09\x09\x09\x09\x09<iconIsIcon type=\"Boolean\">true</iconIsIcon>\x0A\x09\x09\x09\x09\x09\x09<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>\x0A\x09\x09\x09\x09\x09\x09<iconPageName><![CDATA[p1]]></iconPageName>\x0A\x09\x09\x09\x09\x09\x09<descriptionText><![CDATA[]]></descriptionText>\x0A\x09\x09\x09\x09\x09\x09<scale type=\"Integer\">100</scale>\x0A\x09\x09\x09\x09\x09\x09<fadeInStep type=\"Integer\">100</fadeInStep>\x0A\x09\x09\x09\x09\x09\x09<tabChildren type=\"Boolean\">false</tabChildren>\x0A\x09\x09\x09\x09\x09\x09<_focusrect type=\"Boolean\">false</_focusrect>\x0A\x09\x09\x09\x09\x09\x09<visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool>\x0A\x09\x09\x09\x09\x09\x09<url><![CDATA[media/logosilex.jpg]]></url>\x0A\x09\x09\x09\x09\x09\x09<mask><![CDATA[ ]]></mask>\x0A\x09\x09\x09\x09\x09\x09<useHandCursor type=\"Boolean\">false</useHandCursor>\x0A\x09\x09\x09\x09\x09\x09<height type=\"Integer\">65</height>\x0A\x09\x09\x09\x09\x09\x09<width type=\"Integer\">65</width>\x0A\x09\x09\x09\x09\x09\x09<clickable type=\"Boolean\">true</clickable>\x0A\x09\x09\x09\x09\x09</properties>\x0A\x09\x09\x09\x09\x09<actions></actions>\x0A\x09\x09\x09\x09</component>\x0A\x09\x09\x09\x09<component>\x0A\x09\x09\x09\x09\x09<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>\x0A\x09\x09\x09\x09\x09<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>\x0A\x09\x09\x09\x09\x09<className>org.silex.ui.players.Image</className>\x0A\x09\x09\x09\x09\x09<componentRoot>main</componentRoot>\x0A\x09\x09\x09\x09\x09<properties>\x0A\x09\x09\x09\x09\x09\x09<playerName><![CDATA[logosilex4]]></playerName>\x0A\x09\x09\x09\x09\x09\x09<rotation type=\"Integer\">0</rotation>\x0A\x09\x09\x09\x09\x09\x09<y type=\"Integer\">16</y>\x0A\x09\x09\x09\x09\x09\x09<x type=\"Integer\">0</x>\x0A\x09\x09\x09\x09\x09\x09<alpha type=\"Integer\">100</alpha>\x0A\x09\x09\x09\x09\x09\x09<tabIndex type=\"Integer\">1</tabIndex>\x0A\x09\x09\x09\x09\x09\x09<tabEnabled type=\"Boolean\">false</tabEnabled>\x0A\x09\x09\x09\x09\x09\x09<tooltipText><![CDATA[]]></tooltipText>\x0A\x09\x09\x09\x09\x09\x09<visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin>\x0A\x09\x09\x09\x09\x09\x09<iconIsDefault type=\"Boolean\">false</iconIsDefault>\x0A\x09\x09\x09\x09\x09\x09<iconIsIcon type=\"Boolean\">true</iconIsIcon>\x0A\x09\x09\x09\x09\x09\x09<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>\x0A\x09\x09\x09\x09\x09\x09<iconPageName><![CDATA[p1]]></iconPageName>\x0A\x09\x09\x09\x09\x09\x09<descriptionText><![CDATA[]]></descriptionText>\x0A\x09\x09\x09\x09\x09\x09<scale type=\"Integer\">100</scale>\x0A\x09\x09\x09\x09\x09\x09<fadeInStep type=\"Integer\">100</fadeInStep>\x0A\x09\x09\x09\x09\x09\x09<tabChildren type=\"Boolean\">false</tabChildren>\x0A\x09\x09\x09\x09\x09\x09<_focusrect type=\"Boolean\">false</_focusrect>\x0A\x09\x09\x09\x09\x09\x09<visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool>\x0A\x09\x09\x09\x09\x09\x09<url><![CDATA[media/logosilex.jpg]]></url>\x0A\x09\x09\x09\x09\x09\x09<scaleMode><![CDATA[none&\$<jj<kk>]]></scaleMode>\x0A\x09\x09\x09\x09\x09\x09<mask><![CDATA[ ]]></mask>\x0A\x09\x09\x09\x09\x09\x09<useHandCursor type=\"Boolean\">false</useHandCursor>\x0A\x09\x09\x09\x09\x09\x09<height type=\"Integer\">65</height>\x0A\x09\x09\x09\x09\x09\x09<width type=\"Integer\">65</width>\x0A\x09\x09\x09\x09\x09\x09<clickable type=\"Boolean\">true</clickable>\x0A\x09\x09\x09\x09\x09</properties>\x0A\x09\x09\x09\x09\x09<actions></actions>\x0A\x09\x09\x09\x09</component>\x0A\x09\x09\x09</components>\x0A\x09\x09</subLayer>\x0A\x09</subLayers>\x0A</layer>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("fade", $generatedOutput->subLayers->subLayer->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 495, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("5", $generatedOutput->subLayers->subLayer->attributes->zIndex, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 496, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("plugins/baseComponents/as2/org.silex.ui.players.Image.swf", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->as2Url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 497, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("logosilex4", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->properties->playerName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 498, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("media/logosilex.jpg", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->properties->url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 499, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("minimal.swf", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->iconLayoutName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 500, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("65", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->height, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 501, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("true", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->clickable, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 502, "className" => "Test", "methodName" => "testXml2")));
		$GLOBALS['%s']->pop();
	}
	public function testXml3() {
		$GLOBALS['%s']->push("Test::testXml3");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<layer><subLayers><subLayer zIndex=\"5\" id=\"fade\"><components><component><as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url><html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url><className>org.silex.ui.players.Image</className><componentRoot>main</componentRoot><properties><playerName><![CDATA[logosilex4]]></playerName><rotation type=\"Integer\">0</rotation><y type=\"Integer\">16</y><x type=\"Integer\">0</x><alpha type=\"Integer\">100</alpha><tabIndex type=\"Integer\">1</tabIndex><tabEnabled type=\"Boolean\">false</tabEnabled><tooltipText><![CDATA[ ]]></tooltipText><visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin><iconIsDefault type=\"Boolean\">false</iconIsDefault><iconIsIcon type=\"Boolean\">true</iconIsIcon><iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName><iconPageName><![CDATA[p1]]></iconPageName><descriptionText><![CDATA[ ]]></descriptionText><scale type=\"Integer\">100</scale><fadeInStep type=\"Integer\">100</fadeInStep><tabChildren type=\"Boolean\">false</tabChildren><visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool><url><![CDATA[media/logosilex.jpg]]></url><scaleMode><![CDATA[none]]></scaleMode><mask><![CDATA[ ]]></mask><useHandCursor type=\"Boolean\">false</useHandCursor><height type=\"Integer\">65</height><width type=\"Integer\">65</width><clickable type=\"Boolean\">true</clickable></properties><actions></actions></component></components></subLayer></subLayers></layer>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("fade", $generatedOutput->subLayers->subLayer->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 522, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("5", $generatedOutput->subLayers->subLayer->attributes->zIndex, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 523, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("plugins/baseComponents/as2/org.silex.ui.players.Image.swf", $generatedOutput->subLayers->subLayer->components->component->as2Url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 524, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("logosilex4", $generatedOutput->subLayers->subLayer->components->component->properties->playerName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 525, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("media/logosilex.jpg", $generatedOutput->subLayers->subLayer->components->component->properties->url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 526, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("minimal.swf", $generatedOutput->subLayers->subLayer->components->component->properties->iconLayoutName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 527, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("65", $generatedOutput->subLayers->subLayer->components->component->properties->height, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 528, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("true", $generatedOutput->subLayers->subLayer->components->component->properties->clickable, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 529, "className" => "Test", "methodName" => "testXml3")));
		$GLOBALS['%s']->pop();
	}
	public function testXml4() {
		$GLOBALS['%s']->push("Test::testXml4");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<!DOCTYPE root PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\x0A<root>\x0A  <entry id=\"25\">\x0A\x09\x09\x09<title handle=\"page01\">page01</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<pagename handle=\"page01\">page01</pagename>\x0A\x0A\x09\x09\x09<pagenumber handle=\"1\">1</pagenumber>\x0A\x09\x09\x09<order>1</order>\x0A\x09\x09</entry>\x0A  <entry id=\"70\">\x0A\x09\x09\x09<title handle=\"page02\">page02</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page02\">page02</page-name>\x0A\x09\x09\x09<page-number handle=\"2-3\">2-3</page-number>\x0A\x09\x09\x09<order>2</order>\x0A\x09\x09</entry>\x0A  <entry id=\"71\">\x0A\x09\x09\x09<title handle=\"page04\">page04</title>\x0A\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page04\">page04</page-name>\x0A\x09\x09\x09<page-number handle=\"4-5\">4-5</page-number>\x0A\x09\x09\x09<content>\x0A\x09\x09\x09\x09<item id=\"30\" handle=\"\" section-handle=\"\" section-name=\"\"></item>\x0A\x0A\x09\x09\x09</content>\x0A\x09\x09\x09<order>3</order>\x0A\x09\x09</entry>\x0A  <entry id=\"72\">\x0A\x09\x09\x09<title handle=\"page06\">page06</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page06\">page06</page-name>\x0A\x09\x09\x09<page-number handle=\"6-7\">6-7</page-number>\x0A\x09\x09\x09<order>4</order>\x0A\x09\x09</entry>\x0A  <entry id=\"73\">\x0A\x09\x09\x09<title handle=\"page08\">page08</title>\x0A\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page08\">page08</page-name>\x0A\x09\x09\x09<page-number handle=\"8-9\">8-9</page-number>\x0A\x09\x09\x09<order>5</order>\x0A\x09\x09</entry>\x0A\x0A  <entry id=\"74\">\x0A\x09\x09\x09<title handle=\"page10\">page10</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page10\">page10</page-name>\x0A\x09\x09\x09<page-number handle=\"10\">10</page-number>\x0A\x0A\x09\x09\x09<order>6</order>\x0A\x09\x09</entry>\x0A</root>\x0A\x0A<!-- \x0A<events />\x0A -->\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("25", _hx_array_get($generatedOutput->entry, 0)->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 620, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("page01", _hx_array_get($generatedOutput->entry, 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 621, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("structure", _hx_array_get($generatedOutput->entry, 0)->group->item, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 622, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("page01", _hx_array_get($generatedOutput->entry, 0)->pagename, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 623, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("1", _hx_array_get($generatedOutput->entry, 0)->pagenumber, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 624, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("1", _hx_array_get($generatedOutput->entry, 0)->order, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 625, "className" => "Test", "methodName" => "testXml4")));
		$GLOBALS['%s']->pop();
	}
	public function testXml5() {
		$GLOBALS['%s']->push("Test::testXml5");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?><element type_str=\"object\" name_str=\"root\"><element type_str=\"string\" name_str=\"title\"><![CDATA[structure]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[lang.config%2Fstr]]></element><element type_str=\"string\" name_str=\"pubDate\"><![CDATA[Tue+Apr+12+11%3A53%3A00+GMT%2B0200+2011]]></element><element type_str=\"string\" name_str=\"urlBase\"><![CDATA[http%3A%2F%2Flocalhost%3A80%2Fsilex_trunk%2Fsilex_server%2Fdynamic_demo%2F]]></element><element type_str=\"object\" name_str=\"content\"><element type_str=\"object\" name_str=\"0\"><element type_str=\"object\" name_str=\"links\"><element type_str=\"object\" name_str=\"0\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage01.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page01]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page01]]></element></element><element type_str=\"object\" name_str=\"1\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage02.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page02]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page02]]></element></element><element type_str=\"object\" name_str=\"2\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage04.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page04]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page04]]></element></element><element type_str=\"object\" name_str=\"3\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage06.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page06]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page06]]></element></element><element type_str=\"object\" name_str=\"4\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage08.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page08]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page08]]></element></element><element type_str=\"object\" name_str=\"5\"><element type_str=\"string\" name_str=\"title\"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage10.png%26width%3D152%26height%3D99%0A]]></element><element type_str=\"string\" name_str=\"deeplink\"><![CDATA[page10]]></element><element type_str=\"string\" name_str=\"link\"><![CDATA[page10]]></element></element></element></element></element></element>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("structure", $generatedOutput->element[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 646, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("lang.config%2Fstr", $generatedOutput->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 647, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("links", _hx_array_get($generatedOutput->element, 4)->element->element->attributes->name_str, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 648, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page01", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 0)->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 649, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page01", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 0)->element[2], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 650, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page10", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 5)->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 651, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page10", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 5)->element[2], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 652, "className" => "Test", "methodName" => "testXml5")));
		$GLOBALS['%s']->pop();
	}
	public function testXml6() {
		$GLOBALS['%s']->push("Test::testXml6");
		$»spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\x0A<A>\x0A\x09<B b1=\"valb1\"  b2=\"valb2\">\x0A\x09\x09<C1>\x0A\x09\x09\x09<D1 a=\"1\">ValD1</D1>\x0A\x09\x09\x09<D1 a=\"2\">ValD2</D1>\x0A\x09\x09</C1>\x0A\x09\x09<C2 a=\"3\">ValC2</C2>\x0A\x09</B>\x0A</A>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("valb1", $generatedOutput->B->attributes->b1, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 681, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("valb2", $generatedOutput->B->attributes->b2, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 682, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValD1", $generatedOutput->B->C1->D1[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 683, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValD2", $generatedOutput->B->C1->D1[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 684, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValC2", $generatedOutput->B->C2, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 685, "className" => "Test", "methodName" => "testXml6")));
		$GLOBALS['%s']->pop();
	}
	public function test_slashSeparator() {
		$GLOBALS['%s']->push("Test::test_slashSeparator");
		$»spos = $GLOBALS['%s']->length;
		$generatedOutput = null;
		$generatedOutput->{"silex"} = $this->_initAccessor->silex;
		utest_Assert::equals($generatedOutput->silex->config->id_site, org_silex_core_AccessorManager::getTarget("silex/config/id_site", $generatedOutput, "/"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 698, "className" => "Test", "methodName" => "test_slashSeparator")));
		utest_Assert::equals("contents_themes/", org_silex_core_AccessorManager::revealAccessors("<<silex/config/initialContentFolderPath>>", $generatedOutput, "/"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 699, "className" => "Test", "methodName" => "test_slashSeparator")));
		utest_Assert::equals("contents/", org_silex_core_AccessorManager::revealAccessors("<<silex/config/CONTENT_FOLDER>>", $generatedOutput, "/"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 700, "className" => "Test", "methodName" => "test_slashSeparator")));
		utest_Assert::equals("contents/id_du_site/", org_silex_core_AccessorManager::revealAccessors("<<silex/config/CONTENT_FOLDER>>id_du_site/", $generatedOutput, "/"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 703, "className" => "Test", "methodName" => "test_slashSeparator")));
		utest_Assert::equals("contents/id_du_site/contents_themes/.jpg", org_silex_core_AccessorManager::revealAccessors("<<silex/config/CONTENT_FOLDER>>id_du_site/<<silex/config/initialContentFolderPath>>.jpg", $generatedOutput, "/"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 704, "className" => "Test", "methodName" => "test_slashSeparator")));
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
	static function main() {
		$GLOBALS['%s']->push("Test::main");
		$»spos = $GLOBALS['%s']->length;
		Test::init();
		$runner = new utest_Runner();
		$runner->addCase(new Test(), null, null, null, null);
		utest_ui_Report::create($runner, null, null);
		$runner->run();
		$GLOBALS['%s']->pop();
	}
	static function init() {
		$GLOBALS['%s']->push("Test::init");
		$»spos = $GLOBALS['%s']->length;
		require_once("../../../../silex_server/rootdir.php");
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH);
		set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library");
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Test'; }
}
