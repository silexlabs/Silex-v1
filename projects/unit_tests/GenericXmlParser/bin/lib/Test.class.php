<?php

class Test {
	public function __construct() { if(!php_Boot::$skip_constructor) {
		$GLOBALS['%s']->push("Test::new");
		$�spos = $GLOBALS['%s']->length;
		$GLOBALS['%s']->pop();
	}}
	public function test_xmlEntities() {
		$GLOBALS['%s']->push("Test::test_xmlEntities");
		$�spos = $GLOBALS['%s']->length;
		$input = "<value>Quand un editeur de m&#xE9;dias riches rencontre un &#xE9;diteur XML</value>";
		$a = org_silex_core_XmlUtils::Xml2Dynamic(Xml::parse($input), null);
		utest_Assert::equals("Quand un editeur de médias riches rencontre un éditeur XML", $a, "Test parsing of two entities separated by PCDATA nodes.", _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 29, "className" => "Test", "methodName" => "test_xmlEntities")));
		$input1 = "<value>&#xE9;</value>";
		$a1 = org_silex_core_XmlUtils::Xml2Dynamic(Xml::parse($input1), null);
		utest_Assert::equals("é", $a1, "Test parsing of a single entity.", _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 33, "className" => "Test", "methodName" => "test_xmlEntities")));
		$input2 = "<value>&#xE9;&#xE9;</value>";
		$a2 = org_silex_core_XmlUtils::Xml2Dynamic(Xml::parse($input2), null);
		utest_Assert::equals("éé", $a2, "Test parsing of two entities next to each other.", _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 37, "className" => "Test", "methodName" => "test_xmlEntities")));
		$GLOBALS['%s']->pop();
	}
	public function test_cleanUpXml_1() {
		$GLOBALS['%s']->push("Test::test_cleanUpXml_1");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<rss a=\"b\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A\x09\x09\x09<title><![CDATA[Actualité N°1]]></title>\x0A            <description><![CDATA[Ceci est ma première actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A        <item>\x0A            <title><![CDATA[Actualité N°2]]></title>\x0A            <description><![CDATA[Ceci est ma deuxième actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu2</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$cleanedXml = org_silex_core_XmlUtils::cleanUp($inputXml);
		utest_Assert::equals($inputXml->firstElement()->getNodeName(), $cleanedXml->getNodeName(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 73, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		utest_Assert::equals($inputXml->firstElement()->get("a"), $cleanedXml->get("a"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 74, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		utest_Assert::equals($inputXml->firstElement()->firstElement()->getNodeName(), $cleanedXml->firstElement()->getNodeName(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 75, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		utest_Assert::equals("rss", $cleanedXml->getNodeName(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 77, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		utest_Assert::equals("b", $cleanedXml->get("a"), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 78, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		utest_Assert::equals("channel", $cleanedXml->firstElement()->getNodeName(), null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 79, "className" => "Test", "methodName" => "test_cleanUpXml_1")));
		$GLOBALS['%s']->pop();
	}
	public function test_cleanUpXml_2() {
		$GLOBALS['%s']->push("Test::test_cleanUpXml_2");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "";
		$inputXml = Xml::parse($inputString);
		$cleanedXml = org_silex_core_XmlUtils::cleanUp($inputXml);
		utest_Assert::same($inputXml, $cleanedXml, null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 95, "className" => "Test", "methodName" => "test_cleanUpXml_2")));
		utest_Assert::equals(null, null, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 98, "className" => "Test", "methodName" => "test_cleanUpXml_2")));
		$GLOBALS['%s']->pop();
	}
	public function testOofWorkaround() {
		$GLOBALS['%s']->push("Test::testOofWorkaround");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A\x09\x09\x09<title><![CDATA[Actualité N°1]]></title>\x0A            <description><![CDATA[Ceci est ma première actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A        <item>\x0A            <title><![CDATA[Actualité N°2]]></title>\x0A            <description><![CDATA[Ceci est ma deuxième actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu2</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), true);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 137, "className" => "Test", "methodName" => "testOofWorkaround")));
		$GLOBALS['%s']->pop();
	}
	public function testRss0() {
		$GLOBALS['%s']->push("Test::testRss0");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A\x09<!-- comment1 -->\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <!-- comment2 -->\x0A\x09\x09\x09<title><![CDATA[Actualité N°1]]></title>\x0A            <description><![CDATA[Ceci est ma première actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 177, "className" => "Test", "methodName" => "testRss0")));
		utest_Assert::equals("Ceci est un exemple de flux RSS 2.0", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 178, "className" => "Test", "methodName" => "testRss0")));
		utest_Assert::equals("http://www.example.org", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 179, "className" => "Test", "methodName" => "testRss0")));
		utest_Assert::equals("http://www.example.org/actu1", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 180, "className" => "Test", "methodName" => "testRss0")));
		$GLOBALS['%s']->pop();
	}
	public function testRss00() {
		$GLOBALS['%s']->push("Test::testRss00");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?><rss version=\"2.0\"><!-- comment1 --><channel><title>Mon site</title><description>Ceci est un exemple de flux RSS 2.0</description><lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate><link>http://www.example.org</link><item><!-- comment2 --><title><![CDATA[Actualité N°1]]></title><description><![CDATA[Ceci est ma première actualité]]></description><pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate><link>http://www.example.org/actu1</link></item></channel></rss>";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 198, "className" => "Test", "methodName" => "testRss00")));
		utest_Assert::equals("Ceci est un exemple de flux RSS 2.0", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 199, "className" => "Test", "methodName" => "testRss00")));
		utest_Assert::equals("http://www.example.org", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 200, "className" => "Test", "methodName" => "testRss00")));
		utest_Assert::equals("http://www.example.org/actu1", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 201, "className" => "Test", "methodName" => "testRss00")));
		$GLOBALS['%s']->pop();
	}
	public function testRss1() {
		$GLOBALS['%s']->push("Test::testRss1");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A\x09\x09\x09<title><![CDATA[Actualité N°1]]></title>\x0A            <description><![CDATA[Ceci est ma première actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 234, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("Ceci est un exemple de flux RSS 2.0", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 235, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("http://www.example.org", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 236, "className" => "Test", "methodName" => "testRss1")));
		utest_Assert::equals("http://www.example.org/actu1", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 237, "className" => "Test", "methodName" => "testRss1")));
		$GLOBALS['%s']->pop();
	}
	public function testRss2() {
		$GLOBALS['%s']->push("Test::testRss2");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\x0A<rss version=\"2.0\">\x0A    <channel>\x0A        <title>Mon site</title>\x0A        <description>Ceci est un exemple de flux RSS 2.0</description>\x0A        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>\x0A        <link>http://www.example.org</link>\x0A        <item>\x0A            <title><![CDATA[Actualité N°1]]></title>\x0A            <description><![CDATA[Ceci est ma première actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu1</link>\x0A        </item>\x0A        <item>\x0A            <title><![CDATA[Actualité N°2]]></title>\x0A            <description><![CDATA[Ceci est ma deuxième actualité]]></description>\x0A            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>\x0A            <link>http://www.example.org/actu2</link>\x0A        </item>\x0A    </channel>\x0A</rss>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Mon site", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 276, "className" => "Test", "methodName" => "testRss2")));
		utest_Assert::equals("Ceci est un exemple de flux RSS 2.0", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 277, "className" => "Test", "methodName" => "testRss2")));
		utest_Assert::equals("http://www.example.org", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 278, "className" => "Test", "methodName" => "testRss2")));
		utest_Assert::equals("http://www.example.org/actu1", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 279, "className" => "Test", "methodName" => "testRss2")));
		utest_Assert::equals("Actualité N°2", _hx_array_get($generatedOutput->channel->item, 1)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 280, "className" => "Test", "methodName" => "testRss2")));
		$GLOBALS['%s']->pop();
	}
	public function testRssFTV() {
		$GLOBALS['%s']->push("Test::testRssFTV");
		$�spos = $GLOBALS['%s']->length;
		$inputString = php_io_File::getContent("../test_files/rssFTV_input.xml");
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("Francetv info - Découverte", $generatedOutput->channel->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 298, "className" => "Test", "methodName" => "testRssFTV")));
		utest_Assert::equals("Francetv info - Découverte", $generatedOutput->channel->description, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 299, "className" => "Test", "methodName" => "testRssFTV")));
		utest_Assert::equals("http://www.francetv.fr/info/decouverte/", $generatedOutput->channel->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 300, "className" => "Test", "methodName" => "testRssFTV")));
		utest_Assert::equals("http://www.francetv.fr/info/a-budapest-un-defile-de-peres-noel-en-slip_38365.html", _hx_array_get($generatedOutput->channel->item, 0)->link, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 301, "className" => "Test", "methodName" => "testRssFTV")));
		utest_Assert::equals("Le boson de Higgs, une énigme de la physique en passe d'être résolue", _hx_array_get($generatedOutput->channel->item, 1)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 302, "className" => "Test", "methodName" => "testRssFTV")));
		$GLOBALS['%s']->pop();
	}
	public function testXml0() {
		$GLOBALS['%s']->push("Test::testXml0");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<root>\x0A\x09\x09\x09<user name=\"john\">\x0A\x09\x09\x09</user>\x0A\x09\x09\x09</root>\x0A\x09\x09\x09";
		$inputXml = Xml::parse($inputString);
		$output = _hx_anonymous(array());
		$output->user = _hx_anonymous(array());
		$output->user->attributes = _hx_anonymous(array());
		$output->user->attributes->name = "john";
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("john", $generatedOutput->user->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 333, "className" => "Test", "methodName" => "testXml0")));
		$GLOBALS['%s']->pop();
	}
	public function testXml1() {
		$GLOBALS['%s']->push("Test::testXml1");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<root>\x0A\x09\x09\x09<user name=\"john\">\x0A\x09\x09\x09\x09<phone>\x0A\x09\x09\x09\x09\x09<number>0000</number>\x0A\x09\x09\x09\x09\x09<number>111</number>\x0A\x09\x09\x09\x09</phone>\x0A\x09\x09\x09</user>\x0A\x09\x09\x09<user name=\"raph\">\x0A\x09\x09\x09\x09<phone>\x0A\x09\x09\x09\x09\x09<number>2222</number>\x0A\x09\x09\x09\x09\x09<number>333</number>\x0A\x09\x09\x09\x09</phone>\x0A\x09\x09\x09</user>\x0A\x09\x09\x09</root>\x0A\x09\x09\x09";
		$inputXml = Xml::parse($inputString);
		$output = _hx_anonymous(array());
		$output->user = _hx_anonymous(array());
		$output->user->attributes = _hx_anonymous(array());
		$output->user->attributes->name = "john";
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("john", _hx_array_get($generatedOutput->user, 0)->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 374, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("0000", _hx_array_get($generatedOutput->user, 0)->phone->number[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 375, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("111", _hx_array_get($generatedOutput->user, 0)->phone->number[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 376, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("raph", _hx_array_get($generatedOutput->user, 1)->attributes->name, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 378, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("2222", _hx_array_get($generatedOutput->user, 1)->phone->number[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 379, "className" => "Test", "methodName" => "testXml1")));
		utest_Assert::equals("333", _hx_array_get($generatedOutput->user, 1)->phone->number[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 380, "className" => "Test", "methodName" => "testXml1")));
		$GLOBALS['%s']->pop();
	}
	public function testXml2() {
		$GLOBALS['%s']->push("Test::testXml2");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<layer>\x0A\x09<subLayers>\x0A\x09\x09<subLayer zIndex=\"5\" id=\"fade\">\x0A\x09\x09\x09<components>\x0A\x09\x09\x09\x09<component>\x0A\x09\x09\x09\x09\x09<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>\x0A\x09\x09\x09\x09\x09<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>\x0A\x09\x09\x09\x09\x09<className>org.silex.ui.players.Image</className>\x0A\x09\x09\x09\x09\x09<componentRoot>main</componentRoot>\x0A\x09\x09\x09\x09\x09<properties>\x0A\x09\x09\x09\x09\x09\x09<playerName><![CDATA[logosilex4]]></playerName>\x0A\x09\x09\x09\x09\x09\x09<rotation type=\"Integer\">0</rotation>\x0A\x09\x09\x09\x09\x09\x09<y type=\"Integer\">16</y>\x0A\x09\x09\x09\x09\x09\x09<x type=\"Integer\">0</x>\x0A\x09\x09\x09\x09\x09\x09<alpha type=\"Integer\">100</alpha>\x0A\x09\x09\x09\x09\x09\x09<tabIndex type=\"Integer\">1</tabIndex>\x0A\x09\x09\x09\x09\x09\x09<tabEnabled type=\"Boolean\">false</tabEnabled>\x0A\x09\x09\x09\x09\x09\x09<tooltipText><![CDATA[]]></tooltipText>\x0A\x09\x09\x09\x09\x09\x09<visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin>\x0A\x09\x09\x09\x09\x09\x09<iconIsDefault type=\"Boolean\">false</iconIsDefault>\x0A\x09\x09\x09\x09\x09\x09<iconIsIcon type=\"Boolean\">true</iconIsIcon>\x0A\x09\x09\x09\x09\x09\x09<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>\x0A\x09\x09\x09\x09\x09\x09<iconPageName><![CDATA[p1]]></iconPageName>\x0A\x09\x09\x09\x09\x09\x09<descriptionText><![CDATA[]]></descriptionText>\x0A\x09\x09\x09\x09\x09\x09<scale type=\"Integer\">100</scale>\x0A\x09\x09\x09\x09\x09\x09<fadeInStep type=\"Integer\">100</fadeInStep>\x0A\x09\x09\x09\x09\x09\x09<tabChildren type=\"Boolean\">false</tabChildren>\x0A\x09\x09\x09\x09\x09\x09<_focusrect type=\"Boolean\">false</_focusrect>\x0A\x09\x09\x09\x09\x09\x09<visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool>\x0A\x09\x09\x09\x09\x09\x09<url><![CDATA[media/logosilex.jpg]]></url>\x0A\x09\x09\x09\x09\x09\x09<mask><![CDATA[ ]]></mask>\x0A\x09\x09\x09\x09\x09\x09<useHandCursor type=\"Boolean\">false</useHandCursor>\x0A\x09\x09\x09\x09\x09\x09<height type=\"Integer\">65</height>\x0A\x09\x09\x09\x09\x09\x09<width type=\"Integer\">65</width>\x0A\x09\x09\x09\x09\x09\x09<clickable type=\"Boolean\">true</clickable>\x0A\x09\x09\x09\x09\x09</properties>\x0A\x09\x09\x09\x09\x09<actions></actions>\x0A\x09\x09\x09\x09</component>\x0A\x09\x09\x09\x09<component>\x0A\x09\x09\x09\x09\x09<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>\x0A\x09\x09\x09\x09\x09<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>\x0A\x09\x09\x09\x09\x09<className>org.silex.ui.players.Image</className>\x0A\x09\x09\x09\x09\x09<componentRoot>main</componentRoot>\x0A\x09\x09\x09\x09\x09<properties>\x0A\x09\x09\x09\x09\x09\x09<playerName><![CDATA[logosilex4]]></playerName>\x0A\x09\x09\x09\x09\x09\x09<rotation type=\"Integer\">0</rotation>\x0A\x09\x09\x09\x09\x09\x09<y type=\"Integer\">16</y>\x0A\x09\x09\x09\x09\x09\x09<x type=\"Integer\">0</x>\x0A\x09\x09\x09\x09\x09\x09<alpha type=\"Integer\">100</alpha>\x0A\x09\x09\x09\x09\x09\x09<tabIndex type=\"Integer\">1</tabIndex>\x0A\x09\x09\x09\x09\x09\x09<tabEnabled type=\"Boolean\">false</tabEnabled>\x0A\x09\x09\x09\x09\x09\x09<tooltipText><![CDATA[]]></tooltipText>\x0A\x09\x09\x09\x09\x09\x09<visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin>\x0A\x09\x09\x09\x09\x09\x09<iconIsDefault type=\"Boolean\">false</iconIsDefault>\x0A\x09\x09\x09\x09\x09\x09<iconIsIcon type=\"Boolean\">true</iconIsIcon>\x0A\x09\x09\x09\x09\x09\x09<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>\x0A\x09\x09\x09\x09\x09\x09<iconPageName><![CDATA[p1]]></iconPageName>\x0A\x09\x09\x09\x09\x09\x09<descriptionText><![CDATA[]]></descriptionText>\x0A\x09\x09\x09\x09\x09\x09<scale type=\"Integer\">100</scale>\x0A\x09\x09\x09\x09\x09\x09<fadeInStep type=\"Integer\">100</fadeInStep>\x0A\x09\x09\x09\x09\x09\x09<tabChildren type=\"Boolean\">false</tabChildren>\x0A\x09\x09\x09\x09\x09\x09<_focusrect type=\"Boolean\">false</_focusrect>\x0A\x09\x09\x09\x09\x09\x09<visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool>\x0A\x09\x09\x09\x09\x09\x09<url><![CDATA[media/logosilex.jpg]]></url>\x0A\x09\x09\x09\x09\x09\x09<scaleMode><![CDATA[none&\$<jj<kk>]]></scaleMode>\x0A\x09\x09\x09\x09\x09\x09<mask><![CDATA[ ]]></mask>\x0A\x09\x09\x09\x09\x09\x09<useHandCursor type=\"Boolean\">false</useHandCursor>\x0A\x09\x09\x09\x09\x09\x09<height type=\"Integer\">65</height>\x0A\x09\x09\x09\x09\x09\x09<width type=\"Integer\">65</width>\x0A\x09\x09\x09\x09\x09\x09<clickable type=\"Boolean\">true</clickable>\x0A\x09\x09\x09\x09\x09</properties>\x0A\x09\x09\x09\x09\x09<actions></actions>\x0A\x09\x09\x09\x09</component>\x0A\x09\x09\x09</components>\x0A\x09\x09</subLayer>\x0A\x09</subLayers>\x0A</layer>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("fade", $generatedOutput->subLayers->subLayer->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 475, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("5", $generatedOutput->subLayers->subLayer->attributes->zIndex, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 476, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("plugins/baseComponents/as2/org.silex.ui.players.Image.swf", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->as2Url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 477, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("logosilex4", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->properties->playerName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 478, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("media/logosilex.jpg", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 0)->properties->url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 479, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("minimal.swf", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->iconLayoutName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 480, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("65", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->height, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 481, "className" => "Test", "methodName" => "testXml2")));
		utest_Assert::equals("true", _hx_array_get($generatedOutput->subLayers->subLayer->components->component, 1)->properties->clickable, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 482, "className" => "Test", "methodName" => "testXml2")));
		$GLOBALS['%s']->pop();
	}
	public function testXml3() {
		$GLOBALS['%s']->push("Test::testXml3");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<layer><subLayers><subLayer zIndex=\"5\" id=\"fade\"><components><component><as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url><html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url><className>org.silex.ui.players.Image</className><componentRoot>main</componentRoot><properties><playerName><![CDATA[logosilex4]]></playerName><rotation type=\"Integer\">0</rotation><y type=\"Integer\">16</y><x type=\"Integer\">0</x><alpha type=\"Integer\">100</alpha><tabIndex type=\"Integer\">1</tabIndex><tabEnabled type=\"Boolean\">false</tabEnabled><tooltipText><![CDATA[ ]]></tooltipText><visibleOutOfAdmin type=\"Boolean\">true</visibleOutOfAdmin><iconIsDefault type=\"Boolean\">false</iconIsDefault><iconIsIcon type=\"Boolean\">true</iconIsIcon><iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName><iconPageName><![CDATA[p1]]></iconPageName><descriptionText><![CDATA[ ]]></descriptionText><scale type=\"Integer\">100</scale><fadeInStep type=\"Integer\">100</fadeInStep><tabChildren type=\"Boolean\">false</tabChildren><visibleFrame_bool type=\"Boolean\">false</visibleFrame_bool><url><![CDATA[media/logosilex.jpg]]></url><scaleMode><![CDATA[none]]></scaleMode><mask><![CDATA[ ]]></mask><useHandCursor type=\"Boolean\">false</useHandCursor><height type=\"Integer\">65</height><width type=\"Integer\">65</width><clickable type=\"Boolean\">true</clickable></properties><actions></actions></component></components></subLayer></subLayers></layer>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("fade", $generatedOutput->subLayers->subLayer->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 502, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("5", $generatedOutput->subLayers->subLayer->attributes->zIndex, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 503, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("plugins/baseComponents/as2/org.silex.ui.players.Image.swf", $generatedOutput->subLayers->subLayer->components->component->as2Url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 504, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("logosilex4", $generatedOutput->subLayers->subLayer->components->component->properties->playerName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 505, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("media/logosilex.jpg", $generatedOutput->subLayers->subLayer->components->component->properties->url, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 506, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("minimal.swf", $generatedOutput->subLayers->subLayer->components->component->properties->iconLayoutName, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 507, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("65", $generatedOutput->subLayers->subLayer->components->component->properties->height, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 508, "className" => "Test", "methodName" => "testXml3")));
		utest_Assert::equals("true", $generatedOutput->subLayers->subLayer->components->component->properties->clickable, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 509, "className" => "Test", "methodName" => "testXml3")));
		$GLOBALS['%s']->pop();
	}
	public function testXml4() {
		$GLOBALS['%s']->push("Test::testXml4");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<!DOCTYPE root PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\x0A<root>\x0A  <entry id=\"25\">\x0A\x09\x09\x09<title handle=\"page01\">page01</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<pagename handle=\"page01\">page01</pagename>\x0A\x0A\x09\x09\x09<pagenumber handle=\"1\">1</pagenumber>\x0A\x09\x09\x09<order>1</order>\x0A\x09\x09</entry>\x0A  <entry id=\"70\">\x0A\x09\x09\x09<title handle=\"page02\">page02</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page02\">page02</page-name>\x0A\x09\x09\x09<page-number handle=\"2-3\">2-3</page-number>\x0A\x09\x09\x09<order>2</order>\x0A\x09\x09</entry>\x0A  <entry id=\"71\">\x0A\x09\x09\x09<title handle=\"page04\">page04</title>\x0A\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page04\">page04</page-name>\x0A\x09\x09\x09<page-number handle=\"4-5\">4-5</page-number>\x0A\x09\x09\x09<content>\x0A\x09\x09\x09\x09<item id=\"30\" handle=\"\" section-handle=\"\" section-name=\"\"></item>\x0A\x0A\x09\x09\x09</content>\x0A\x09\x09\x09<order>3</order>\x0A\x09\x09</entry>\x0A  <entry id=\"72\">\x0A\x09\x09\x09<title handle=\"page06\">page06</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page06\">page06</page-name>\x0A\x09\x09\x09<page-number handle=\"6-7\">6-7</page-number>\x0A\x09\x09\x09<order>4</order>\x0A\x09\x09</entry>\x0A  <entry id=\"73\">\x0A\x09\x09\x09<title handle=\"page08\">page08</title>\x0A\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page08\">page08</page-name>\x0A\x09\x09\x09<page-number handle=\"8-9\">8-9</page-number>\x0A\x09\x09\x09<order>5</order>\x0A\x09\x09</entry>\x0A\x0A  <entry id=\"74\">\x0A\x09\x09\x09<title handle=\"page10\">page10</title>\x0A\x09\x09\x09<group>\x0A\x09\x09\x09\x09<item handle=\"structure\">structure</item>\x0A\x09\x09\x09</group>\x0A\x09\x09\x09<page-name handle=\"page10\">page10</page-name>\x0A\x09\x09\x09<page-number handle=\"10\">10</page-number>\x0A\x0A\x09\x09\x09<order>6</order>\x0A\x09\x09</entry>\x0A</root>\x0A\x0A<!-- \x0A<events />\x0A -->\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("25", _hx_array_get($generatedOutput->entry, 0)->attributes->id, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 604, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("page01", _hx_array_get($generatedOutput->entry, 0)->title, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 605, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("structure", _hx_array_get($generatedOutput->entry, 0)->group->item, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 606, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("page01", _hx_array_get($generatedOutput->entry, 0)->pagename, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 607, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("1", _hx_array_get($generatedOutput->entry, 0)->pagenumber, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 608, "className" => "Test", "methodName" => "testXml4")));
		utest_Assert::equals("1", _hx_array_get($generatedOutput->entry, 0)->order, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 609, "className" => "Test", "methodName" => "testXml4")));
		$GLOBALS['%s']->pop();
	}
	public function testXml5() {
		$GLOBALS['%s']->push("Test::testXml5");
		$�spos = $GLOBALS['%s']->length;
		$inputString = php_io_File::getContent("../test_files/xml5_input.xml");
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("structure", $generatedOutput->element[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 629, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("lang.config%2Fstr", $generatedOutput->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 630, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("links", _hx_array_get($generatedOutput->element, 4)->element->element->attributes->name_str, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 631, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page01", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 0)->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 632, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page01", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 0)->element[2], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 633, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page10", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 5)->element[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 634, "className" => "Test", "methodName" => "testXml5")));
		utest_Assert::equals("page10", _hx_array_get(_hx_array_get($generatedOutput->element, 4)->element->element->element, 5)->element[2], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 635, "className" => "Test", "methodName" => "testXml5")));
		$GLOBALS['%s']->pop();
	}
	public function testXml6() {
		$GLOBALS['%s']->push("Test::testXml6");
		$�spos = $GLOBALS['%s']->length;
		$inputString = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\x0A<A>\x0A\x09<B b1=\"valb1\"  b2=\"valb2\">\x0A\x09\x09<C1>\x0A\x09\x09\x09<D1 a=\"1\">ValD1</D1>\x0A\x09\x09\x09<D1 a=\"2\">ValD2</D1>\x0A\x09\x09</C1>\x0A\x09\x09<C2 a=\"3\">ValC2</C2>\x0A\x09</B>\x0A</A>\x0A";
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("valb1", $generatedOutput->B->attributes->b1, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 664, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("valb2", $generatedOutput->B->attributes->b2, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 665, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValD1", $generatedOutput->B->C1->D1[0], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 666, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValD2", $generatedOutput->B->C1->D1[1], null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 667, "className" => "Test", "methodName" => "testXml6")));
		utest_Assert::equals("ValC2", $generatedOutput->B->C2, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 668, "className" => "Test", "methodName" => "testXml6")));
		$GLOBALS['%s']->pop();
	}
	public function testXml7() {
		$GLOBALS['%s']->push("Test::testXml7");
		$�spos = $GLOBALS['%s']->length;
		$inputString = php_io_File::getContent("../test_files/xml8_input.xml");
		$inputXml = Xml::parse($inputString);
		$generatedOutput = org_silex_core_XmlUtils::Xml2Dynamic($inputXml->firstElement(), null);
		utest_Assert::equals("cn", $generatedOutput->cn->flag->group->item, null, _hx_anonymous(array("fileName" => "Test.hx", "lineNumber" => 691, "className" => "Test", "methodName" => "testXml7")));
		$GLOBALS['%s']->pop();
	}
	static function main() {
		$GLOBALS['%s']->push("Test::main");
		$�spos = $GLOBALS['%s']->length;
		$runner = new utest_Runner();
		$runner->addCase(new Test(), null, null, null, null);
		utest_ui_Report::create($runner, null, null);
		$runner->run();
		$GLOBALS['%s']->pop();
	}
	function __toString() { return 'Test'; }
}
