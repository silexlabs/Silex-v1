import utest.Assert;
import utest.Runner;
import utest.ui.Report;
import php.Lib;
import org.silex.core.XmlUtils;
import org.silex.core.AccessorManager;
import org.silex.serverApi.ServerConfig;
//import org.silex.serverApi.RootDir;

class Test {
	
	// accessor to be initialised with default values 'id_site', 'initialContentFolderPath', client & server config
	private var _initAccessor:Dynamic;
	
    public static function main()
	{
		init();
		
		var runner = new Runner();
        runner.addCase(new Test());
        Report.create(runner);
        runner.run();
    }

    public static function init()
	{
		untyped __call__('require_once', '../../../../silex_server/rootdir.php');
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH)');
		//untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/include")');
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library")');
    }
	
    public function new()
	{
		var idSite:String = 'id_du_site';
		_initAccessor = AccessorManager.getInstance(idSite).accessors;
	}
	
	/**
	 * splitTags() test
	 */ 
    public function test0_splitTags()
	{
        // Input & output setting

		// Tested process

		// Verification
		// empty inputs
		Assert.same( [], AccessorManager.splitTags(null) );
		Assert.same( [], AccessorManager.splitTags('') );
		
		// normal cases
		Assert.same( ['item1'], AccessorManager.splitTags('item1') );
		Assert.same( ['item1','item2'], AccessorManager.splitTags('item1((item2))') );
		Assert.same( ['item1','item2','item3'], AccessorManager.splitTags('item1((item2))item3') );
		Assert.same( ['item1','item2','item3'], AccessorManager.splitTags('((item1))((item2))((item3))') );

		// corner cases
		Assert.same( ['item1','item2'], AccessorManager.splitTags('item1((item2') );
		Assert.same( ['item1','item2'], AccessorManager.splitTags('item1))item2') );
		Assert.same( ['item1','item2','item3'], AccessorManager.splitTags('item1))item2((item3') );
		Assert.same( ['item1','item2','item3'], AccessorManager.splitTags('item1((((item2))item3') );
		Assert.same( ['item1','','item2','','item3'], AccessorManager.splitTags('item1(())item2(())item3') );
		Assert.same( ['item1','item2','))item3'], AccessorManager.splitTags('item1((item2))))item3') );
	}


	/**
	 * getTarget() test
	 */ 
    public function test2_getTarget()
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
		Reflect.setField(generatedOutput, 'silex', _initAccessor.silex);
		//untyped __call__('print_r', generatedOutput);
		

		// Verification
		// empty inputs
		Assert.equals( null, AccessorManager.getTarget(null, ['item1'] ) );
		Assert.equals( null, AccessorManager.getTarget('', ['item1']) );
		Assert.equals( null, AccessorManager.getTarget('test', null) );
		Assert.equals( null, AccessorManager.getTarget('silex', null) );
		Assert.equals( null, AccessorManager.getTarget('silex.toto', null) );
		Assert.equals( null, AccessorManager.getTarget('silex.config', null) );
		Assert.equals( null, AccessorManager.getTarget('silex.config.check', null) );

		// normal generic cases
		// rootUrl
		Assert.equals( 'http://localhost/silex_trunk/projects/unit_tests/revealAccessors/bin/', AccessorManager.getTarget('silex.rootUrl', generatedOutput) );
		// site id
		Assert.equals( generatedOutput.silex.config.id_site, AccessorManager.getTarget('silex.config.id_site', generatedOutput) );
		// string
		Assert.equals( null, AccessorManager.getTarget('blablabla', generatedOutput) );
		Assert.equals( generatedOutput.channel.title, AccessorManager.getTarget('channel.title', generatedOutput) );
		Assert.equals( generatedOutput.channel.item[0].title, AccessorManager.getTarget('channel.item', generatedOutput)[0].title );
		Assert.equals( generatedOutput.channel.item[0].description, AccessorManager.getTarget('channel.item', generatedOutput)[0].description );
		Assert.equals( generatedOutput.channel.item[0].pubDate, AccessorManager.getTarget('channel.item', generatedOutput)[0].pubDate );
		Assert.equals( generatedOutput.channel.item[0].link, AccessorManager.getTarget('channel.item', generatedOutput)[0].link );

		// gets silex server & client config
		var silexConfig:ServerConfig = new ServerConfig();
		// normal silex cases
		Assert.equals( silexConfig.silexServerIni.get('DEFAULT_WEBSITE'), AccessorManager.getTarget('silex.config.DEFAULT_WEBSITE',generatedOutput) );
		Assert.equals( 'manager', AccessorManager.getTarget('silex.config.DEFAULT_WEBSITE',generatedOutput) );
		Assert.equals( silexConfig.silexClientIni.get('accessorsLeftTag'), AccessorManager.getTarget('silex.config.accessorsLeftTag',generatedOutput) );

		// issues
		Assert.equals( silexConfig.silexServerIni.get('DEFAULT_WEBSITE'), silexConfig.silexClientIni.get('DEFAULT_WEBSITE') );
		//Assert.equals( silexConfig.silexServerIni.get('accessorsLeftTag'), silexConfig.silexClientIni.get('accessorsLeftTag') );

		// corner cases
		
	}

	/**
	 * revealAccessors() test
	 */ 
    public function test3Rss1_revealAccessors()
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
		Reflect.setField(generatedOutput, 'silex', _initAccessor.silex);
		//untyped __call__('print_r', generatedOutput);
		

		// Verification
		// empty inputs
		Assert.equals( '', AccessorManager.revealAccessors(null, ['item1'] ) );
		Assert.equals( '', AccessorManager.revealAccessors('', ['item1']) );
		Assert.equals( 'test', AccessorManager.revealAccessors('test', null) );
		
		// tester avec des valeurs numériques
		

		// normal cases
		// rootUrl
		Assert.equals( 'http://localhost/silex_trunk/projects/unit_tests/revealAccessors/bin/', AccessorManager.getTarget('silex.rootUrl', generatedOutput) );
		// silex.config
		// site id
		Assert.equals( generatedOutput.silex.config.id_site, AccessorManager.revealAccessors('<<silex.config.id_site>>', generatedOutput) );
		// initialContentFolderPath
		Assert.equals( 'contents_themes/', AccessorManager.revealAccessors('<<silex.config.initialContentFolderPath>>', generatedOutput) );
		
		// strings
		Assert.equals( 'test1', AccessorManager.revealAccessors('test1', generatedOutput) );
		Assert.equals( 'test1', AccessorManager.revealAccessors('((test1))', generatedOutput) );
		Assert.equals( generatedOutput.channel.title, AccessorManager.revealAccessors('<<channel.title>>', generatedOutput) );
		Assert.equals( generatedOutput.channel.title + generatedOutput.channel.description, AccessorManager.revealAccessors('<<channel.title>><<channel.description>>', generatedOutput) );
		Assert.equals( generatedOutput.channel.title + 'string' + generatedOutput.channel.description, AccessorManager.revealAccessors('<<channel.title>>string<<channel.description>>', generatedOutput) );
		Assert.equals(  'string1' + generatedOutput.channel.title + 'string2' + generatedOutput.channel.description + 'string3', AccessorManager.revealAccessors('string1<<channel.title>>string2<<channel.description>>string3', generatedOutput) );
		// arrays
		//Assert.same( generatedOutput.channel.item, AccessorManager.revealAccessors('<<channel.item>>', generatedOutput) );
		Assert.equals( 'Actualité N°1', (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].title );
		Assert.equals( generatedOutput.channel.item[0].title, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].title );
		Assert.equals( generatedOutput.channel.item[0].description, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].description );
		// dynamic: cannot be checked as comparing two unknown types
		//trace(Type.typeof(generatedOutput.channel));
		//trace(Reflect.fields(generatedOutput.channel));
		//trace(Type.typeof(generatedOutput.channel.item));
		//trace(Reflect.fields(generatedOutput.channel.item));
		//trace(Type.typeof(generatedOutput.channel.item[0]));
		//trace(Reflect.fields(generatedOutput.channel.item[0]));
		//Assert.same( generatedOutput.channel.item, (AccessorManager.revealAccessors('<<channel>>', generatedOutput)).item );
		
		// corner cases
		//Assert.equals( null, AccessorManager.revealAccessors('<<channel.title', generatedOutput) );
		//Assert.equals( null, AccessorManager.revealAccessors('<<string1<<channel.title<<string2<<', generatedOutput) );
		//Assert.equals( null, AccessorManager.revealAccessors('string1<<channel.title<<string2<<', generatedOutput) );
		Assert.equals( 'channel.title', AccessorManager.revealAccessors('<<channel.title', generatedOutput) );
		Assert.equals( 'string1channel.titlestring2', AccessorManager.revealAccessors('<<string1<<channel.title<<string2<<', generatedOutput) );
		Assert.equals( 'string1channel.titlestring2', AccessorManager.revealAccessors('string1<<channel.title<<string2<<', generatedOutput) );
	}

	/**
	 * revealAccessors() test
	 */ 
    public function test4Rss2_revealAccessors()
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
		Reflect.setField(generatedOutput, 'silex', _initAccessor.silex);
		//untyped __call__('print_r', generatedOutput);
		

		// Verification
		// empty inputs
		Assert.equals( '', AccessorManager.revealAccessors(null, ['item1'] ) );
		Assert.equals( '', AccessorManager.revealAccessors('', ['item1']) );
		Assert.equals( 'test', AccessorManager.revealAccessors('test', null) );
		
		// tester avec des valeurs numériques
		

		// normal cases
		// site id
		Assert.equals( generatedOutput.silex.config.id_site, AccessorManager.revealAccessors('<<silex.config.id_site>>', generatedOutput) );
		// strings
		Assert.equals( 'test1', AccessorManager.revealAccessors('test1', generatedOutput) );
		Assert.equals( 'test1', AccessorManager.revealAccessors('((test1))', generatedOutput) );
		Assert.equals( generatedOutput.channel.title, AccessorManager.revealAccessors('<<channel.title>>', generatedOutput) );
		Assert.equals( generatedOutput.channel.title + generatedOutput.channel.description, AccessorManager.revealAccessors('<<channel.title>><<channel.description>>', generatedOutput) );
		Assert.equals( generatedOutput.channel.title + 'string' + generatedOutput.channel.description, AccessorManager.revealAccessors('<<channel.title>>string<<channel.description>>', generatedOutput) );
		Assert.equals(  'string1' + generatedOutput.channel.title + 'string2' + generatedOutput.channel.description + 'string3', AccessorManager.revealAccessors('string1<<channel.title>>string2<<channel.description>>string3', generatedOutput) );
		// arrays
		//Assert.same( generatedOutput.channel.item, AccessorManager.revealAccessors('<<channel.item>>', generatedOutput) );
		Assert.equals( 'Actualité N°1', (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].title );
		Assert.equals( generatedOutput.channel.item[0].title, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].title );
		Assert.equals( generatedOutput.channel.item[0].description, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[0].description );
		Assert.equals( 'Actualité N°2', (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[1].title );
		Assert.equals( generatedOutput.channel.item[1].title, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[1].title );
		Assert.equals( generatedOutput.channel.item[1].description, (AccessorManager.revealAccessors('<<channel.item>>', generatedOutput))[1].description );
		// dynamic: cannot be checked as comparing two unknown types
		//Assert.same( generatedOutput.channel.item, (AccessorManager.revealAccessors('<<channel>>', generatedOutput)).item );

		// corner cases
		/*Assert.equals( null, AccessorManager.revealAccessors('<<channel.title', generatedOutput) );
		Assert.equals( null, AccessorManager.revealAccessors('<<string1<<channel.title<<string2<<', generatedOutput) );
		Assert.equals( null, AccessorManager.revealAccessors('string1<<channel.title<<string2<<', generatedOutput) );*/
		Assert.equals( 'channel.title', AccessorManager.revealAccessors('<<channel.title', generatedOutput) );
		Assert.equals( 'string1channel.titlestring2', AccessorManager.revealAccessors('<<string1<<channel.title<<string2<<', generatedOutput) );
		Assert.equals( 'string1channel.titlestring2', AccessorManager.revealAccessors('string1<<channel.title<<string2<<', generatedOutput) );
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
		

		// Verification
		Assert.equals( "john", generatedOutput.user.attributes.name );
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
		/*trace(generatedOutput);
		untyped __call__('print_r',generatedOutput);*/
		

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
	 * dynamic menu xml of dynamic_demo
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
		var inputString:String = '<?xml version="1.0" encoding="UTF-8"?><element type_str="object" name_str="root"><element type_str="string" name_str="title"><![CDATA[structure]]></element><element type_str="string" name_str="deeplink"><![CDATA[lang.config%2Fstr]]></element><element type_str="string" name_str="pubDate"><![CDATA[Tue+Apr+12+11%3A53%3A00+GMT%2B0200+2011]]></element><element type_str="string" name_str="urlBase"><![CDATA[http%3A%2F%2Flocalhost%3A80%2Fsilex_trunk%2Fsilex_server%2Fdynamic_demo%2F]]></element><element type_str="object" name_str="content"><element type_str="object" name_str="0"><element type_str="object" name_str="links"><element type_str="object" name_str="0"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage01.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page01]]></element><element type_str="string" name_str="link"><![CDATA[page01]]></element></element><element type_str="object" name_str="1"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage02.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page02]]></element><element type_str="string" name_str="link"><![CDATA[page02]]></element></element><element type_str="object" name_str="2"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage04.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page04]]></element><element type_str="string" name_str="link"><![CDATA[page04]]></element></element><element type_str="object" name_str="3"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage06.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page06]]></element><element type_str="string" name_str="link"><![CDATA[page06]]></element></element><element type_str="object" name_str="4"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage08.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page08]]></element><element type_str="string" name_str="link"><![CDATA[page08]]></element></element><element type_str="object" name_str="5"><element type_str="string" name_str="title"><![CDATA[cgi%2Fscripts%2Fget_resized_image.php%3Ffile%3Dcontents%2Fdynamic_demo%2Fpage10.png%26width%3D152%26height%3D99%0A]]></element><element type_str="string" name_str="deeplink"><![CDATA[page10]]></element><element type_str="string" name_str="link"><![CDATA[page10]]></element></element></element></element></element></element>
';
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
	
	public function test_slashSeparator()
	{
		
		// Tested process
        var generatedOutput:Dynamic = null;
		Reflect.setField(generatedOutput, 'silex', _initAccessor.silex);
		//untyped __call__('print_r', generatedOutput);
		
		// simple cases
		Assert.equals( generatedOutput.silex.config.id_site, AccessorManager.getTarget('silex/config/id_site', generatedOutput,'/') );
		Assert.equals( 'contents_themes/', AccessorManager.revealAccessors('<<silex/config/initialContentFolderPath>>', generatedOutput,'/') );
		Assert.equals( 'contents/', AccessorManager.revealAccessors('<<silex/config/CONTENT_FOLDER>>', generatedOutput, '/') );
		
		// combinaisons
		Assert.equals( 'contents/id_du_site/', AccessorManager.revealAccessors('<<silex/config/CONTENT_FOLDER>>id_du_site/', generatedOutput,'/') );
		Assert.equals( 'contents/id_du_site/contents_themes/.jpg', AccessorManager.revealAccessors('<<silex/config/CONTENT_FOLDER>>id_du_site/<<silex/config/initialContentFolderPath>>.jpg', generatedOutput,'/') );
		
	}
}