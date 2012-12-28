import php.FileSystem;
import php.io.File;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;
import php.Lib;
import org.silex.core.XmlUtils;

class Test {
	
    public static function main()
	{
		var runner = new Runner();
        runner.addCase(new Test());
        Report.create(runner);
        runner.run();
    }
      
	
    public function new()
	{
		
	}
    
	public function test_xmlEntities()
	{
		var input = "<value>Quand un editeur de m&#xE9;dias riches rencontre un &#xE9;diteur XML</value>";
		var a = XmlUtils.Xml2Dynamic(Xml.parse(input));
		Assert.equals("Quand un editeur de médias riches rencontre un éditeur XML", a, "Test parsing of two entities separated by PCDATA nodes.");

		var input = "<value>&#xE9;</value>";
		var a = XmlUtils.Xml2Dynamic(Xml.parse(input));
		Assert.equals("é", a, "Test parsing of a single entity.");
		
		var input = "<value>&#xE9;&#xE9;</value>";
		var a = XmlUtils.Xml2Dynamic(Xml.parse(input));
		Assert.equals("éé", a, "Test parsing of two entities next to each other.");
	}
	
	/**
	 * cleanUp xml test 1
	 */ 
    public function test_cleanUpXml_1()
	{
        // Input & output setting
		var inputString:String = '<rss a="b">
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
			<title><![CDATA[Actualité N°1]]></title>
            <description><![CDATA[Ceci est ma première actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
        <item>
            <title><![CDATA[Actualité N°2]]></title>
            <description><![CDATA[Ceci est ma deuxième actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu2</link>
        </item>
    </channel>
</rss>
';
		var inputXml:Xml = Xml.parse(inputString);
		
		// Tested process
		var cleanedXml:Xml = XmlUtils.cleanUp(inputXml);

		// Verification
		Assert.equals( inputXml.firstElement().nodeName, cleanedXml.nodeName );
		Assert.equals( inputXml.firstElement().get('a'), cleanedXml.get('a') );
		Assert.equals( inputXml.firstElement().firstElement().nodeName, cleanedXml.firstElement().nodeName );

		Assert.equals( 'rss', cleanedXml.nodeName );
		Assert.equals( 'b', cleanedXml.get('a') );
		Assert.equals( 'channel', cleanedXml.firstElement().nodeName );
		
	}

	/**
	 * cleanUp xml test 2
	 */ 
    public function test_cleanUpXml_2()
	{
        // Input & output setting
		var inputString:String = '';
		var inputXml:Xml = Xml.parse(inputString);
		
		// Tested process
		// empty xml
		var cleanedXml:Xml = XmlUtils.cleanUp(inputXml);
		Assert.same( inputXml, cleanedXml );
		
		// null xml
		Assert.equals( null, null );
		
	}

	/**
	 * Oof workaround test
	 */ 
    public function testOofWorkaround()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
			<title><![CDATA[Actualité N°1]]></title>
            <description><![CDATA[Ceci est ma première actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
        <item>
            <title><![CDATA[Actualité N°2]]></title>
            <description><![CDATA[Ceci est ma deuxième actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu2</link>
        </item>
    </channel>
</rss>
';
        var inputXml:Xml = Xml.parse(inputString);
			
		// Tested process
		var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement(),true);
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Mon site", generatedOutput.channel.title );
		//for (field in Reflect.fields(generatedOutput.channel))
		//{
			//trace(field);
		//}
		// cannot test this one
		//Assert.equals( "http://www.example.org/actu1", Reflect.field(generatedOutput.channel,'0') );
	}

	/**
	 * simplest rss test
	 */ 
    public function testRss0()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
	<!-- comment1 -->
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
            <!-- comment2 -->
			<title><![CDATA[Actualité N°1]]></title>
            <description><![CDATA[Ceci est ma première actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
    </channel>
</rss>
';
        var inputXml:Xml = Xml.parse(inputString);
			
		// Tested process
		var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Mon site", generatedOutput.channel.title );
		Assert.equals( "Ceci est un exemple de flux RSS 2.0", generatedOutput.channel.description );
		Assert.equals( "http://www.example.org", generatedOutput.channel.link );
		Assert.equals( "http://www.example.org/actu1", generatedOutput.channel.item[0].link );
	}

	/**
	 * simplest rss test
	 */ 
    public function testRss00()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="utf-8"?><rss version="2.0"><!-- comment1 --><channel><title>Mon site</title><description>Ceci est un exemple de flux RSS 2.0</description><lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate><link>http://www.example.org</link><item><!-- comment2 --><title><![CDATA[Actualité N°1]]></title><description><![CDATA[Ceci est ma première actualité]]></description><pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate><link>http://www.example.org/actu1</link></item></channel></rss>';

        var inputXml:Xml = Xml.parse(inputString);
			
		// Tested process
		var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Mon site", generatedOutput.channel.title );
		Assert.equals( "Ceci est un exemple de flux RSS 2.0", generatedOutput.channel.description );
		Assert.equals( "http://www.example.org", generatedOutput.channel.link );
		Assert.equals( "http://www.example.org/actu1", generatedOutput.channel.item[0].link );
	}

	/**
	 * simplest rss test
	 */ 
    public function testRss1()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
			<title><![CDATA[Actualité N°1]]></title>
            <description><![CDATA[Ceci est ma première actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
    </channel>
</rss>
';
        var inputXml:Xml = Xml.parse(inputString);
			
		
		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Mon site", generatedOutput.channel.title );
		Assert.equals( "Ceci est un exemple de flux RSS 2.0", generatedOutput.channel.description );
		Assert.equals( "http://www.example.org", generatedOutput.channel.link );
		Assert.equals( "http://www.example.org/actu1", generatedOutput.channel.item[0].link );
	}

	/**
	 * simplest rss test
	 */ 
    public function testRss2()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0">
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
            <title><![CDATA[Actualité N°1]]></title>
            <description><![CDATA[Ceci est ma première actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
        <item>
            <title><![CDATA[Actualité N°2]]></title>
            <description><![CDATA[Ceci est ma deuxième actualité]]></description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu2</link>
        </item>
    </channel>
</rss>
';
        var inputXml:Xml = Xml.parse(inputString);
			
		
		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Mon site", generatedOutput.channel.title );
		Assert.equals( "Ceci est un exemple de flux RSS 2.0", generatedOutput.channel.description );
		Assert.equals( "http://www.example.org", generatedOutput.channel.link );
		Assert.equals( "http://www.example.org/actu1", generatedOutput.channel.item[0].link );
		Assert.equals( "Actualité N°2", generatedOutput.channel.item[1].title );
	}

	/**
	 * FTV rss
	 */ 
    public function testRssFTV()
	{
        // Input & output setting
        var inputString:String = File.getContent('../test_files/rssFTV_input.xml');
		var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);

		// Verification
		Assert.equals( "Francetv info - Découverte", generatedOutput.channel.title );
		Assert.equals( "Francetv info - Découverte", generatedOutput.channel.description );
		Assert.equals( "http://www.francetv.fr/info/decouverte/", generatedOutput.channel.link );
		Assert.equals( "http://www.francetv.fr/info/a-budapest-un-defile-de-peres-noel-en-slip_38365.html", generatedOutput.channel.item[0].link );
		Assert.equals( "Le boson de Higgs, une énigme de la physique en passe d'être résolue", generatedOutput.channel.item[1].title );
		
	}

	/**
	 * simplest xml test
	 */ 
    public function testXml0()
	{
        // Input & output setting
		var inputString:String = '<root>
			<user name="john">
			</user>
			</root>
			';
        var inputXml:Xml = Xml.parse(inputString);
			
        var output:Dynamic = {};
		output.user = {};
		output.user.attributes = {};
		output.user.attributes.name = "john";

		
		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r', generatedOutput);
		//trace(generatedOutput.user.attributes);
		//trace(generatedOutput.user.attributes.get('name'));
		

		// Verification
		Assert.equals( "john", generatedOutput.user.attributes.name );
		//Assert.equals( "john", generatedOutput.user.attributes.get('name') );
	}

	/**
	 * simple xml test
	 */ 
	public function testXml1()
	{
        // Input & output setting
		var inputString:String = '<root>
			<user name="john">
				<phone>
					<number>0000</number>
					<number>111</number>
				</phone>
			</user>
			<user name="raph">
				<phone>
					<number>2222</number>
					<number>333</number>
				</phone>
			</user>
			</root>
			';
        var inputXml:Xml = Xml.parse(inputString);
			
        var output:Dynamic = {};
		output.user = {};
		output.user.attributes = {};
		output.user.attributes.name = "john";

		
		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		
		
		//untyped __call__("print_r", generatedOutput);

		
		// Verification
		Assert.equals( "john", generatedOutput.user[0].attributes.name );
		Assert.equals( "0000", generatedOutput.user[0].phone.number[0] );
		Assert.equals( "111", generatedOutput.user[0].phone.number[1] );

		Assert.equals( "raph", generatedOutput.user[1].attributes.name );
		Assert.equals( "2222", generatedOutput.user[1].phone.number[0] );
		Assert.equals( "333", generatedOutput.user[1].phone.number[1] );
	}
	
	/**
	 * simple layer file (indented)
	 */ 
    public function testXml2()
	{
        // Input & output setting
		var inputString:String = '<layer>
	<subLayers>
		<subLayer zIndex="5" id="fade">
			<components>
				<component>
					<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>
					<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>
					<className>org.silex.ui.players.Image</className>
					<componentRoot>main</componentRoot>
					<properties>
						<playerName><![CDATA[logosilex4]]></playerName>
						<rotation type="Integer">0</rotation>
						<y type="Integer">16</y>
						<x type="Integer">0</x>
						<alpha type="Integer">100</alpha>
						<tabIndex type="Integer">1</tabIndex>
						<tabEnabled type="Boolean">false</tabEnabled>
						<tooltipText><![CDATA[]]></tooltipText>
						<visibleOutOfAdmin type="Boolean">true</visibleOutOfAdmin>
						<iconIsDefault type="Boolean">false</iconIsDefault>
						<iconIsIcon type="Boolean">true</iconIsIcon>
						<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>
						<iconPageName><![CDATA[p1]]></iconPageName>
						<descriptionText><![CDATA[]]></descriptionText>
						<scale type="Integer">100</scale>
						<fadeInStep type="Integer">100</fadeInStep>
						<tabChildren type="Boolean">false</tabChildren>
						<_focusrect type="Boolean">false</_focusrect>
						<visibleFrame_bool type="Boolean">false</visibleFrame_bool>
						<url><![CDATA[media/logosilex.jpg]]></url>
						<mask><![CDATA[ ]]></mask>
						<useHandCursor type="Boolean">false</useHandCursor>
						<height type="Integer">65</height>
						<width type="Integer">65</width>
						<clickable type="Boolean">true</clickable>
					</properties>
					<actions></actions>
				</component>
				<component>
					<as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url>
					<html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url>
					<className>org.silex.ui.players.Image</className>
					<componentRoot>main</componentRoot>
					<properties>
						<playerName><![CDATA[logosilex4]]></playerName>
						<rotation type="Integer">0</rotation>
						<y type="Integer">16</y>
						<x type="Integer">0</x>
						<alpha type="Integer">100</alpha>
						<tabIndex type="Integer">1</tabIndex>
						<tabEnabled type="Boolean">false</tabEnabled>
						<tooltipText><![CDATA[]]></tooltipText>
						<visibleOutOfAdmin type="Boolean">true</visibleOutOfAdmin>
						<iconIsDefault type="Boolean">false</iconIsDefault>
						<iconIsIcon type="Boolean">true</iconIsIcon>
						<iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName>
						<iconPageName><![CDATA[p1]]></iconPageName>
						<descriptionText><![CDATA[]]></descriptionText>
						<scale type="Integer">100</scale>
						<fadeInStep type="Integer">100</fadeInStep>
						<tabChildren type="Boolean">false</tabChildren>
						<_focusrect type="Boolean">false</_focusrect>
						<visibleFrame_bool type="Boolean">false</visibleFrame_bool>
						<url><![CDATA[media/logosilex.jpg]]></url>
						<scaleMode><![CDATA[none&$<jj<kk>]]></scaleMode>
						<mask><![CDATA[ ]]></mask>
						<useHandCursor type="Boolean">false</useHandCursor>
						<height type="Integer">65</height>
						<width type="Integer">65</width>
						<clickable type="Boolean">true</clickable>
					</properties>
					<actions></actions>
				</component>
			</components>
		</subLayer>
	</subLayers>
</layer>
';
        var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		

		// Verification
		Assert.equals( "fade", generatedOutput.subLayers.subLayer.attributes.id );
		Assert.equals( "5", generatedOutput.subLayers.subLayer.attributes.zIndex );
		Assert.equals( "plugins/baseComponents/as2/org.silex.ui.players.Image.swf", generatedOutput.subLayers.subLayer.components.component[0].as2Url );
		Assert.equals( "logosilex4", generatedOutput.subLayers.subLayer.components.component[0].properties.playerName );
		Assert.equals( "media/logosilex.jpg", generatedOutput.subLayers.subLayer.components.component[0].properties.url );
		Assert.equals( "minimal.swf", generatedOutput.subLayers.subLayer.components.component[1].properties.iconLayoutName );
		Assert.equals( "65", generatedOutput.subLayers.subLayer.components.component[1].properties.height );
		Assert.equals( "true", generatedOutput.subLayers.subLayer.components.component[1].properties.clickable );
	}

	
	/**
	 * simple layer file (non indented)
	 */ 
    public function testXml3()
	{
        // Input & output setting
		var inputString:String = '<layer><subLayers><subLayer zIndex="5" id="fade"><components><component><as2Url>plugins/baseComponents/as2/org.silex.ui.players.Image.swf</as2Url><html5Url>plugins/baseComponents/html5#org.silex.ui.Image</html5Url><className>org.silex.ui.players.Image</className><componentRoot>main</componentRoot><properties><playerName><![CDATA[logosilex4]]></playerName><rotation type="Integer">0</rotation><y type="Integer">16</y><x type="Integer">0</x><alpha type="Integer">100</alpha><tabIndex type="Integer">1</tabIndex><tabEnabled type="Boolean">false</tabEnabled><tooltipText><![CDATA[ ]]></tooltipText><visibleOutOfAdmin type="Boolean">true</visibleOutOfAdmin><iconIsDefault type="Boolean">false</iconIsDefault><iconIsIcon type="Boolean">true</iconIsIcon><iconLayoutName><![CDATA[minimal.swf]]></iconLayoutName><iconPageName><![CDATA[p1]]></iconPageName><descriptionText><![CDATA[ ]]></descriptionText><scale type="Integer">100</scale><fadeInStep type="Integer">100</fadeInStep><tabChildren type="Boolean">false</tabChildren><visibleFrame_bool type="Boolean">false</visibleFrame_bool><url><![CDATA[media/logosilex.jpg]]></url><scaleMode><![CDATA[none]]></scaleMode><mask><![CDATA[ ]]></mask><useHandCursor type="Boolean">false</useHandCursor><height type="Integer">65</height><width type="Integer">65</width><clickable type="Boolean">true</clickable></properties><actions></actions></component></components></subLayer></subLayers></layer>
';
		var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		

		// Verification
		Assert.equals( "fade", generatedOutput.subLayers.subLayer.attributes.id );
		Assert.equals( "5", generatedOutput.subLayers.subLayer.attributes.zIndex );
		Assert.equals( "plugins/baseComponents/as2/org.silex.ui.players.Image.swf", generatedOutput.subLayers.subLayer.components.component.as2Url );
		Assert.equals( "logosilex4", generatedOutput.subLayers.subLayer.components.component.properties.playerName );
		Assert.equals( "media/logosilex.jpg", generatedOutput.subLayers.subLayer.components.component.properties.url );
		Assert.equals( "minimal.swf", generatedOutput.subLayers.subLayer.components.component.properties.iconLayoutName );
		Assert.equals( "65", generatedOutput.subLayers.subLayer.components.component.properties.height );
		Assert.equals( "true", generatedOutput.subLayers.subLayer.components.component.properties.clickable );
	}


	/**
	 * dynamic_demo xml menu
	 * 
	 * TODO: issue when using "-" character as node name.
	 * For instance "page-name" is not working but "pagename" is
	 * 
	 */ 
    public function testXml4()
	{
        // Input & output setting
		var inputString:String = '<!DOCTYPE root PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<root>
  <entry id="25">
			<title handle="page01">page01</title>
			<group>
				<item handle="structure">structure</item>
			</group>
			<pagename handle="page01">page01</pagename>

			<pagenumber handle="1">1</pagenumber>
			<order>1</order>
		</entry>
  <entry id="70">
			<title handle="page02">page02</title>
			<group>
				<item handle="structure">structure</item>

			</group>
			<page-name handle="page02">page02</page-name>
			<page-number handle="2-3">2-3</page-number>
			<order>2</order>
		</entry>
  <entry id="71">
			<title handle="page04">page04</title>

			<group>
				<item handle="structure">structure</item>
			</group>
			<page-name handle="page04">page04</page-name>
			<page-number handle="4-5">4-5</page-number>
			<content>
				<item id="30" handle="" section-handle="" section-name=""></item>

			</content>
			<order>3</order>
		</entry>
  <entry id="72">
			<title handle="page06">page06</title>
			<group>
				<item handle="structure">structure</item>

			</group>
			<page-name handle="page06">page06</page-name>
			<page-number handle="6-7">6-7</page-number>
			<order>4</order>
		</entry>
  <entry id="73">
			<title handle="page08">page08</title>

			<group>
				<item handle="structure">structure</item>
			</group>
			<page-name handle="page08">page08</page-name>
			<page-number handle="8-9">8-9</page-number>
			<order>5</order>
		</entry>

  <entry id="74">
			<title handle="page10">page10</title>
			<group>
				<item handle="structure">structure</item>
			</group>
			<page-name handle="page10">page10</page-name>
			<page-number handle="10">10</page-number>

			<order>6</order>
		</entry>
</root>

<!-- 
<events />
 -->
';
		var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		

		// Verification
		Assert.equals( "25", generatedOutput.entry[0].attributes.id );
		Assert.equals( "page01", generatedOutput.entry[0].title );
		Assert.equals( "structure", generatedOutput.entry[0].group.item );
		Assert.equals( "page01", generatedOutput.entry[0].pagename );
		Assert.equals( "1", generatedOutput.entry[0].pagenumber );
		Assert.equals( "1", generatedOutput.entry[0].order );
		
	}


	/**
	 * simple layer seo file (non indented)
	 */ 
    public function testXml5()
	{
        // Input & output setting
        var inputString:String = File.getContent('../test_files/xml5_input.xml');
		var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		

		// Verification
		Assert.equals( "structure", generatedOutput.element[0] );
		Assert.equals( "lang.config%2Fstr", generatedOutput.element[1] );
		Assert.equals( "links", generatedOutput.element[4].element.element.attributes.name_str );
		Assert.equals( "page01", generatedOutput.element[4].element.element.element[0].element[1] );
		Assert.equals( "page01", generatedOutput.element[4].element.element.element[0].element[2] );
		Assert.equals( "page10", generatedOutput.element[4].element.element.element[5].element[1] );
		Assert.equals( "page10", generatedOutput.element[4].element.element.element[5].element[2] );
		
	}

	/**
	 * simple layer seo file (non indented)
	 */ 
    public function testXml6()
	{
        // Input & output setting
		var inputString:String = '<?xml version="1.0" encoding="UTF-8"?>
<A>
	<B b1="valb1"  b2="valb2">
		<C1>
			<D1 a="1">ValD1</D1>
			<D1 a="2">ValD2</D1>
		</C1>
		<C2 a="3">ValC2</C2>
	</B>
</A>
';
		var inputXml:Xml = Xml.parse(inputString);
			

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		

		// Verification
		Assert.equals( "valb1", generatedOutput.B.attributes.b1 );
		Assert.equals( "valb2", generatedOutput.B.attributes.b2 );
		Assert.equals( "ValD1", generatedOutput.B.C1.D1[0] );
		Assert.equals( "ValD2", generatedOutput.B.C1.D1[1] );
		Assert.equals( "ValC2", generatedOutput.B.C2 );
	}

	/**
	 * dynamic_demo xml language data
	 * 
	 * TODO: issue when two pages nodes have the same name for a specific language
	 * This is a case which should not happen normally.
	 * 
	 */ 
    public function testXml7()
	{
		// Input & output setting
        var inputString:String = File.getContent('../test_files/xml8_input.xml');
		//trace(inputString);

		var inputXml:Xml = Xml.parse(inputString);

		// Tested process
        var generatedOutput:Dynamic = XmlUtils.Xml2Dynamic(inputXml.firstElement());
		//untyped __call__('print_r',generatedOutput);

		// Verification
		Assert.equals( "cn", generatedOutput.cn.flag.group.item );
	}


}