package ;

import php.Lib;
import php.NativeArray;
import utest.Assert;
import utest.Runner;
import utest.ui.Report;
import org.silex.core.XmlUtils;

import org.silex.core.seo.LayerSeo;
import org.silex.core.seo.LayerSeoModel;
import org.silex.core.seo.ComponentSeoModel;
import org.silex.core.seo.ComponentSeoLinkModel;

/**
 * ...
 * @author Raphael Harmel
 */

class Test {
	
	static inline var seoFileExtension:String = ".seodata.xml";
	static inline var testFilePath:String = '../test_files/';
	
	public static function main()
	{
		init();
		test();	
	}

    public function new()
	{
		
	}

    public static function init()
	{
		untyped __call__('require_once', '../../../../silex_server/rootdir.php');
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH)');
		untyped __php__('set_include_path(get_include_path() . PATH_SEPARATOR . ROOTPATH."cgi/library")');
    }

	public static function test()
	{
        var runner = new Runner();
        runner.addCase(new Test());
        Report.create(runner);
        runner.run();
    }

	
	public static function initlayerSeoNativeArray():NativeArray
	{
		
		var layerSeoData:NativeArray = null;
		
		var layerSeoDataHash:Hash<Dynamic> = new Hash<Dynamic>();
		layerSeoDataHash.set('title', 'titletest1');
		layerSeoDataHash.set('deeplink', 'deeplinkTitle1');
		layerSeoDataHash.set('description', 'description1');
		layerSeoDataHash.set('pubDate', 'pubDate1');
		
		var link1:Hash<Dynamic> = new Hash<Dynamic>();
		link1.set('deeplink','deep1');
		link1.set('description','desc1');
		link1.set('title','t1');
		link1.set('link','link1');
		
		var link2:Hash<Dynamic> = new Hash<Dynamic>();
		link2.set('deeplink','deep2');
		link2.set('description','desc2');
		link2.set('title','t2');
		link2.set('link','link2');
		
		var link3:Hash<Dynamic> = new Hash<Dynamic>();
		link3.set('deeplink','deep3');
		link3.set('description','desc3');
		link3.set('title','t3');
		link3.set('link','link3');
		
		var links1:Array<Dynamic> = new Array<Dynamic>();
		links1.push(Lib.associativeArrayOfHash(link1));
		links1.push(Lib.associativeArrayOfHash(link2));
		
		var links2:Array<Dynamic> = new Array<Dynamic>();
		links2.push(Lib.associativeArrayOfHash(link3));
		
		var component1:Hash<Dynamic> = new Hash<Dynamic>();
		component1.set('playerName', 'Selector');
		component1.set('className', 'org...S');
		component1.set('iconIsIcon', 'true');
		component1.set('urlBase','media/toto.xml');
		component1.set('xmlRootNodePath','<<rootNode>>');
		component1.set('links', Lib.toPhpArray(links1));
		
		var component2:Hash<Dynamic> = new Hash<Dynamic>();
		component2.set('playerName', 'Connector');
		component2.set('htmlEquivalent', 'equiv');
		component2.set('className', 'org...C');
		component2.set('iconIsIcon', 'false');
		component2.set('links', Lib.toPhpArray(links2));
		
		var components:Array<Dynamic> = new Array<Dynamic>();
		components.push(Lib.associativeArrayOfHash(component1));
		components.push(Lib.associativeArrayOfHash(component2));
		
		layerSeoDataHash.set('content', Lib.toPhpArray(components));
		
		layerSeoData = Lib.associativeArrayOfHash(layerSeoDataHash);
		
		return layerSeoData;
	}

	public static function initLayerSeoModel():LayerSeoModel
	{
		
		var layerSeoData:LayerSeoModel = null;
		layerSeoData.components = new Array<ComponentSeoModel>();
		
		layerSeoData.title = "lang.config";
		layerSeoData.description = "description lang.config";
		layerSeoData.pubDate = Date.now().toString();
		
		var componentSeoModel:ComponentSeoModel = null;
		componentSeoModel.className = "org....Image";
		componentSeoModel.playerName = "Image1";
		componentSeoModel.iconIsIcon = 'true';
		componentSeoModel.specificProperties = new Hash<String>();
		componentSeoModel.specificProperties.set('urlBase','media/toto.xml');
		componentSeoModel.specificProperties.set('xmlRootNodePath','<<rootNode>>');
		componentSeoModel.specificProperties.set('formName', '<<node1>>');
		
		var link:ComponentSeoLinkModel = null;
		link.title = "title1";
		link.deeplink = "deeplink1";
		link.link = "link1";
		link.description = "description1";
		
		componentSeoModel.links = new Array<ComponentSeoLinkModel>();
		componentSeoModel.links.push(link);
		
		layerSeoData.components.push(componentSeoModel);
		
		return layerSeoData;
	}

	public function testLayerSeoModel() {
		
        // Input setting
		var layerSeoData:LayerSeoModel = initLayerSeoModel();
		var layerSeoDataResult:LayerSeoModel;
        var fileName:String = testFilePath + 'testLayerSeoModel' + seoFileExtension;
		var deeplink:String = 'start/deeplink';
		
		/*layerSeoData = new LayerSeoModel();
		layerSeoDataResult = new LayerSeoModel();
		layerSeoData.title = "lang.config";
		layerSeoData.description = "description lang.config";
		layerSeoData.pubDate = Date.now().toString();
		
		var componentSeoModel:ComponentSeoModel = new ComponentSeoModel();
		componentSeoModel.className = "org....Image";
		componentSeoModel.playerName = "Image1";
		
		var link:ComponentSeoLinkModel = new ComponentSeoLinkModel();
		link.title = "linktitle1";
		link.deeplink = "linkdeeplink1";
		
		componentSeoModel.links.push(link);
		
		//layerSeoData.content.push(componentSeoModel);
		layerSeoData.components.push(componentSeoModel);*/
		

		// Tested process

		// Write LayerSeoModel to seo xml		
		// converts the layerSeoModel to Xml
		//untyped __call__('print_r',layerSeoData);
		var layerSeoModelXml:Xml = LayerSeo.layerSeoModel2Xml(layerSeoData, deeplink);
		//trace(layerSeoModelXml);
		//untyped __call__('print_r',layerSeoModelXml);
		// writes the Xml to layer seo file
		LayerSeo.writeXml(fileName, deeplink, layerSeoModelXml, true);

		//untyped __call__('print_r', layerSeoModelXml);

		// Read seo xml file
		var layerSeoXml:Xml = LayerSeo.readXml(fileName, deeplink);
		//untyped __call__('print_r',layerSeoXml);
		//var layerSeoNativeArray:NativeArray = null;
		layerSeoDataResult = LayerSeo.xml2LayerSeoModel(layerSeoXml);
		//untyped __call__('print_r',layerSeoDataResult);

		// Verification
		
		Assert.equals("lang.config", layerSeoDataResult.title);
		Assert.equals("description lang.config", layerSeoDataResult.description);
		
		Assert.equals("org....Image", layerSeoDataResult.components[0].className);
		Assert.equals("Image1", layerSeoDataResult.components[0].playerName);
		Assert.equals("true", layerSeoDataResult.components[0].iconIsIcon);
		Assert.equals('<<rootNode>>', layerSeoDataResult.components[0].specificProperties.get('xmlRootNodePath'));
		Assert.equals('<<node1>>', layerSeoDataResult.components[0].specificProperties.get('formName'));
		
		Assert.equals("title1", layerSeoDataResult.components[0].links[0].title);
		Assert.equals("deeplink1", layerSeoDataResult.components[0].links[0].deeplink);	
		Assert.equals("link1", layerSeoDataResult.components[0].links[0].link);	
		Assert.equals("description1", layerSeoDataResult.components[0].links[0].description);	
	}

	public function testLayerSeoModelNativeArray() {
		
        // Input setting
		var layerSeoData:NativeArray = initlayerSeoNativeArray();
		var layerSeoDataResult:LayerSeoModel;
        var fileName:String = testFilePath + 'testLayerSeoModelNativeArray' + seoFileExtension;
		var deeplink:String = 'start/deeplink';


		// Tested process

		// Write LayerSeoModel to seo xml
		// converts the input PHP native array to layerSeoModel
		var layerSeoModel:LayerSeoModel = LayerSeo.phpArray2LayerSeoModel(layerSeoData,deeplink);
		// converts the layerSeoModel to Xml
		var layerSeoModelXml:Xml = LayerSeo.layerSeoModel2Xml(layerSeoModel,deeplink);
		// writes the Xml to layer seo file
		LayerSeo.writeXml(fileName, deeplink, layerSeoModelXml, true);

		// Read seo xml file
		var layerSeoXml:Xml = LayerSeo.readXml(fileName, deeplink);
		layerSeoDataResult = LayerSeo.xml2LayerSeoModel(layerSeoXml);
		var layerSeoNativeArray:NativeArray = LayerSeo.layerSeoModel2PhpArray(layerSeoDataResult);

		
		// Verification

		Assert.equals("titletest1", untyped __var__("layerSeoNativeArray['title']"));
		Assert.equals("description1", untyped __var__("layerSeoNativeArray['description']"));
		
		Assert.equals("org...S", untyped __var__("layerSeoNativeArray['components'][0]['className']"));
		Assert.equals("Selector", untyped __var__("layerSeoNativeArray['components'][0]['playerName']"));
		
		Assert.equals('<<rootNode>>', untyped __var__("layerSeoNativeArray['components'][0]['xmlRootNodePath']"));

		Assert.equals("t1", untyped __var__("layerSeoNativeArray['components'][0]['links'][0]['title']"));
		Assert.equals("deep1", untyped __var__("layerSeoNativeArray['components'][0]['links'][0]['deeplink']"));
		Assert.equals("link1", untyped __var__("layerSeoNativeArray['components'][0]['links'][0]['link']"));
		Assert.equals("desc1", untyped __var__("layerSeoNativeArray['components'][0]['links'][0]['description']"));
		
	}

	/**
	 * checks if readXml is returning null on a V1 seo xml file
	 */
	public function test_checkAndReadXml_V1()
	{
        // Input setting
        var fileName:String = testFilePath + 'testV1' + seoFileExtension;
		var layerXml:Xml;

		// Tested process
		layerXml = LayerSeo.readXml(fileName);
		
		// Verification
		//Assert.equals(null, layerXml.firstChild());
		Assert.equals(null, layerXml);
	}

	/**
	 * checks if readXml is returning null on a V2 seo xml file
	 */
	public function test_checkAndReadXml_V2()
	{
        // Input setting
        var fileName:String = testFilePath + 'testV2' + seoFileExtension;
		var layerXml:Xml;

		// Tested process
		layerXml = LayerSeo.readXml(fileName);
		
		// Verification
		Assert.notEquals(null, layerXml.firstChild());
		Assert.equals('layerSeo', layerXml.nodeName);
		Assert.equals('emptyDeeplinkTitle', layerXml.elementsNamed('title').next().firstChild().toString());
	}
	
	/**
	 * v2 file: checks that LayerSeo.readXml returns the empty deeplink data in case it is called with no deeplink or an unexisting deeplink
	 */
	public function test_xml2LayerSeoModel_V2_1()
	{
        // Input setting
        var fileName:String = testFilePath + 'testV2' + seoFileExtension;
		var deeplink:String = "thisDeeplinkDoesNotExist";

		
		// Tested process
		
		// Read seo xml file
		var layerSeoXml:Xml = LayerSeo.readXml(fileName, deeplink);
		//untyped __call__('print_r',layerSeoXml);
		var layerSeoDataResult:LayerSeoModel = LayerSeo.xml2LayerSeoModel(layerSeoXml);
		//untyped __call__('print_r',layerSeoDataResult);
		
		
		// Verification
		Assert.equals("emptyDeeplinkTitle", layerSeoDataResult.title);
	}

}
