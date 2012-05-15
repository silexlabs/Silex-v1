package ;

import org.silex.core.seo.Constants;
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

	/**
	 * htmlEntitiesEncode
	 */
	public function test_htmlEntitiesEncode_1()
	{
        // Input setting
		var strIn:String = '<<>>&&""';
		
		// Tested process
		//var strOut:String = org.silex.core.seo.Utils.htmlEntitiesEncode(strIn);
		var strOut:String = StringTools.htmlEscape(strIn);
		
		// Verification
		Assert.equals('&lt;&lt;&gt;&gt;&amp;&amp;\"\"', strOut);
	}

	/**
	 * htmlEntitiesDecode
	 */
	public function test_htmlEntitiesDecode_1()
	{
        // Input setting
		var strIn:String = '&lt;&lt;&gt;&gt;&amp;&amp;&quot;&quot;';
		var strOut = strIn;

		// Tested process
		//var strOut:String = org.silex.core.seo.Utils.htmlEntitiesDecode(strIn);
		var strOut:String = StringTools.htmlUnescape(strIn);

		// Verification
		Assert.equals('<<>>&&""', strOut);
	}

}
